# N-03 调查报告：冒烟退出泄漏警告（ObjectDB leaked / 9 resources still in use）

- 调查日期：2026-11-17
- 来源：Codex 复审 R3 新发现 N-03（`docs/CODEX_AUDIT_R3.md` §6）
- 范围：只查不改。本轮未修改 `game/` 与冒烟的任何逻辑代码；所有探针均在工作区外的临时副本（`.tmp-n03/`，已删除）上运行。
- 环境：Godot 4.3.stable（`~/workspace/tools/godot/Godot_v4.3-stable_linux.x86_64`），headless，命令与历次审计一致：`--headless --path <game> --script res://smoke.gd`。

## 结论（先行）

**分类：冒烟 harness 的退出清理时序噪声，间歇性出现（原始交付 4 次全量运行中出现 1 次）；不是游戏代码路径的泄漏，也不是修复轮 2 引入。**

**对出货的影响：不影响出货。** 理由见 §4：游戏运行期无任何累积泄漏（200 次存档/续玩循环节点、资源、子节点、孤儿计数全程持平）；该警告只可能出现在进程退出拆卸阶段，玩家不可见，且出货形态（Web/桌面）根本不经过 harness 的「反复新建/释放游戏实例」模式。

原始单次出现的确切微观触发点无法确证（复现失败，见 §2），最可能机制是退出瞬间异步拆卸（待发定时器/环境音播放）与 ObjectDB 清理检查之间的竞态，见 §3.4。此点如实标注为推断，不冒充实证。

## 1. 原始现象

`docs/smoke_fix_r2.log` 第 2217–2220 行，全 PASS 后：

```
SMOKE RESULT: PASS checks=1582 failures=0
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
ERROR: 9 resources still in use at exit (run with --verbose for details).
SMOKE_EXIT=0
```

同轮基线日志 `docs/smoke_fix_r2_baseline.log`（1536 项）无此警告与 ERROR。R3 因此存疑：是否由修复轮 2 引入，未定。

## 2. 复现与对照（本轮实跑）

| # | 代码 | 模式 | 结果 | 退出段 |
| --- | --- | --- | --- | --- |
| 1 | HEAD `e454cb3`（仓库原树） | `--verbose` 全量 | 1582 PASS | **干净**，无 leaked / still-in-use（日志 `docs/n03_run_head_verbose.log`） |
| 2 | HEAD `e454cb3`（仓库原树） | 普通全量（与交付同命令） | 1582 PASS | **干净**（日志 `docs/n03_run_head_plain.log`） |
| 3 | 基线 `55f4245`（临时副本，仅 main.gd/smoke.gd 与基线提交逐字节一致，md5 已核） | 普通全量 | 1536 PASS | **干净**（日志 `docs/n03_run_base_plain.log`），与原始基线日志一致 |
| 4 | 原始交付运行（修复轮 2 施工方） | 普通全量 | 1582 PASS | **出现** leaked 警告 + 9 resources ERROR（`docs/smoke_fix_r2.log`） |

即：同一份 HEAD 代码、同一条命令，本轮连续两次全量复跑均未复现；基线复跑亦干净。该现象为间歇性（已知样本 1/4），不与任何一份代码版本绑定。

## 3. 来源定位（三路探针）

探针在 HEAD 代码的临时副本上运行，只加观测、不改仓库文件。

### 3.1 探针 A：FIX-R2 新增断言段单独冷启动运行

把副本 harness 的 `run()` 改为只跑 `run_fix_r2()`（该段自带 `fresh5()`，自包含），在流程后与 `game.free()`＋3 帧后各测一次 Performance 计数（日志 `docs/n03_probeA.log`）：

- 流程后：orphan_nodes=0，nodes=113，resources=99
- free＋3 帧后：orphan_nodes=0，nodes=1（仅 root），resources=2
- 退出：**无任何泄漏警告/ERROR**，exit 0

结论：被 R3 点名的「最后一段测试」本身退出干净；实例释放后资源计数回落到引擎基线（2），无残留。

### 3.2 探针 B：出货形态——单实例反复存档/回标题/续玩

单个游戏实例（不释放，模拟出货游戏的真实生命周期）跑 20 次 `save_game() → pause_to_title() → continue_game5()` 循环，再连调 10 次 `start_chapter5()`（日志 `docs/n03_probeB.log`）：

- nodes=113、resources=93、children=107、orphan=0 —— 四项**全程不变**
- 最后不 free 实例直接 `quit()`（与出货游戏关进程同形态）：**无泄漏警告**，exit 0

### 3.3 探针 C：对象计数的瞬时项定性

200 次同上循环加密采样（日志 `docs/n03_probeC.log`）：

- 快速循环期间 OBJECT_COUNT 约 +2/次（待发的 SceneTreeTimer 及其回调等瞬时对象来不及到期）
- 静置 3 秒后回落到稳定平台（≈1691），第二轮 200 次后静置仍回到同一平台（1692）——**不跨轮累积**
- nodes/resources/children/orphan 依旧全程持平，退出干净

即循环路径只有「待到期定时器」量级的瞬时对象，无结构性保留。

### 3.4 为什么不是修复轮 2 引入

修复轮 2 对 `game/main.gd` 的全部改动只有两类（`git diff 55f4245..e454cb3` 可核）：

1. 存档字典 `.duplicate()` → `.duplicate(true)` 深拷贝：Dictionary/Array 在 Godot 4 中是引用计数的 Variant 容器，其深拷贝不新持有任何 Resource，更不产生 ObjectDB 注册对象残留——机制上无法解释「9 resources still in use」。
2. 纸轿倒影精灵纵坐标常量 558 → 546：纯数值，无资源生命周期变化。

harness 侧新增的 `run_fix_r2()` 经探针 A 单独验证退出干净。综合 §2 的版本对照（基线与 HEAD 在本轮复跑中同为干净、原始样本中基线干净而 HEAD 出现一次），该现象与代码版本无因果绑定，属退出时序竞态：全量冒烟末尾以同步 `advance_time` 大步推进、随即 `quit()`，若退出瞬间恰有待发定时器（如 `main.gd:1285` 的 0.45 秒铃声定时器回调）或环境音流仍挂在播放器上，清理检查可能先于异步拆卸完成而误报残留；交付运行当时机器负载（同会话内先跑基线全量、又并行截图/导出）会放大这种时序偏移。此机制与全部观测自洽，但因复现失败，定性为**最可能推断**，不当作已证事实。

附带澄清：verbose 运行时另有一行 `Orphan StringName: YXAmb`——那是音频总线名（`main.gd:408` 的 `BUS_AMB` 常量）的 StringName 记账提示，属另一子系统、仅 verbose 可见，与 ObjectDB/资源泄漏无关，勿混为一谈。

## 4. 对出货的影响判断

**不影响出货**，依据：

1. 运行期无累积：探针 B/C 证明玩家真实会反复走的存档→回标题→续玩、章节重开路径上，节点/资源/子节点/孤儿四项计数零增长；对象计数的波动是会自愈的待发定时器。
2. 出货形态不经过 harness 模式：泄漏警告的舞台是「SceneTree 脚本反复 `load().new()` 建实例又 `free()`」的测试骨架；出货游戏是单一场景实例跑到进程结束，探针 B 已按此形态验证退出干净。
3. 退一步说，即便某次进程退出时出现同类警告，它发生在拆卸阶段、进程随即终止，操作系统回收全部内存，对玩家无任何可见后果；它能损害的只有审计日志的「零 ERROR」观感（R3 的措辞关切成立，性质关切不成立）。

## 5. 修法建议（仅建议，未施工，留主控派工）

属 harness 侧的 cosmetic 修复，一处即可：

- **建议项（最小）**：`game/smoke.gd` 的 `run()` 在打印结果后、`quit()` 前，对最终游戏实例做一次显式收尾：停环境音/效果音播放器、`game.free()` 并 `await` 2–3 帧后再 `quit()`。探针 A 已实证此收尾路径退出干净（resources 回落到 2、无警告），可把退出输出从「间歇噪声」变「确定性干净」，保住后续审计「零 ERROR」的证据效力。改动只在 harness，不碰游戏逻辑；风险为零（退出前行为不参与任何断言）。
- **日志口径建议**：在该修复落地前，若全量冒烟再现此警告且 `SMOKE RESULT: PASS`＋退出码 0，同轮重跑一次即可判读（本轮样本：重跑即干净）；不要据单次退出警告回滚任何游戏侧修复。
- **若将来稳定复现**：第一诊断动作是带 `--verbose` 复跑——verbose 会逐个列出泄漏实例的类名/资源路径（本轮两次 verbose 均为干净、未能抓到清单）；拿到清单后再对类定点，不要盲改。

## 6. 证据文件

- `docs/n03_run_head_verbose.log` / `docs/n03_run_head_plain.log`：HEAD 全量复跑（1582 PASS，退出干净）
- `docs/n03_run_base_plain.log`：基线 55f4245 副本全量复跑（1536 PASS，退出干净）
- `docs/n03_probeA.log`：FIX-R2 段单独运行＋free 前后计数
- `docs/n03_probeB.log` / `docs/n03_probeC.log`：单实例循环累积探针
- 对照原件：`docs/smoke_fix_r2.log`（原始出现样本）、`docs/smoke_fix_r2_baseline.log`（原始基线样本）
