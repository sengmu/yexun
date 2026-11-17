# 《夜巡》第一章切片 R2 独立审计

审计日期：2026-11-16（UTC）。身份：独立审计员，只审不改。先完整阅读规格原件 §0–§7，再读实现、断言、交付材料并亲自复跑。以下路径均相对 `~/workspace/yexun/`，行号按本次审计快照。审计只新建本报告；未修改设计稿、工程、截图或旧日志。补充探针置于 `/tmp/yexun_r2_probe.gd`，仅调用现有工程 API。

**总评：有条件通过。** 正解、备选解、鼓三下失败与回溯有真实状态机支撑；原冒烟完整输出可复现，252 项、0 失败，退出码 0；两个脚本语法检查通过。三张截图与工程和后补成功日志相符。不能无条件宣称逐字逐项落实原规格：兼容规则尚标待裁定，部分空间摆位与花灯调查反馈有欠缺，旧交付材料未同步补截结果。未发现伪造 PASS、虚构截图或第 13 件可附身物件的证据。

## 1. §4 十二件物件逐项对表

判定以允许“色块＋名称＋灵核点”的灰盒标准为基础，不把缺少正式美术动画算作违规；位置仍按实际坐标和绘制区域核验。宫内区域为 x=25–410、y=160–550，宫埕为 x=425–1225、y=175–555（`game/main.gd:267–270`）。供桌、旗座、戏台口、竹椅等没有独立地标，不能据名称反推这些实体已被画出。

| # / 物件 | 判定 | 位置、单一动作与作用证据 |
|---|---|---|
| 1 大香炉 | 符合 | (95,350)，在宫内；初始附身点；唯一动作“火星上窜”，燕子以文本表现，推动教学进入探索。`game/main.gd:17,62–72,110–112`；规格 `DESIGN_CH1_SLICE.md:40`。 |
| 2 签筒 | 符合 | (220,310)，宫内烛台旁，灰盒未画供桌；摇签产生 `pickup`、18 秒窗口与 `update1`，签文“逢冲则避”存在。`game/main.gd:18,98–100,113–120,186–190`；规格 :41。 |
| 3 供桌烛台 | 符合 | (350,350)，宫内；唯一动作焰斜燎纸，触发庙祝公扑火及鞭炮搬运，置 `moved/fuse`；传火为兼容补充，详见第 5 节。`game/main.gd:19,131–139`；规格 :42。 |
| 4 潮鼓 | 部分符合 | 动作响一声、鼓声播放、三下提前失败均实现；但 (455,410) 落在所画宫埕区域，位于宫内色块右侧外部，未体现原表“宫门内侧”。门框未画，无法以隐藏门位置抵消该摆位差异。`game/main.gd:20,140–146,267–270`；规格 :43。 |
| 5 神轿 | 符合 | (650,395)，埕面中部；单一动作轻晃响铃。仅在仍捡签时置 `safe/update2`；第二铃有文本和 0.45 秒延迟播放。`game/main.gd:21,121–130`；规格 :44。 |
| 6 标旗 | 符合 | (570,235)，宫埕西侧；抖响置 `flag`，对白包含小英转头、背向埕心、阿勇停手与暂缓出发锣；旗座为灰盒省略。`game/main.gd:22,147–149,158`；规格 :45。 |
| 7 花灯 | 部分符合 | (1040,180)，高于横木，符合灯架顶端；单一“亮／旋转”动作有 `lantern` 标志与对白，但操作反馈仅为“绳结上有一道不自然的暗影”，未直接指出表内要求的“绳结断口”。明确“整齐的割痕”到终局才出现；`lantern` 标志也未驱动画面照明变化。`game/main.gd:23,150–152,210–215,260–264`；规格 :46、:70。 |
| 8 灯架横木 | 符合 | (1020,320)，灯架中段；唯一动作晃动。危险晃减 45 秒、第二次过早晃失败；安全前置齐备后第一次晃置 `armed`，再晃失控。`game/main.gd:24,153–165,271–272`；规格 :47。 |
| 9 鞭炮串 | 部分符合 | 唯一燃放动作受 `fuse` 门控，搬至 (1090,450) 后有双向近距边，准备后燃放可完成终局。初始 (870,230) 并未落在实际画出的两根柱 x=1010/1120 上，也无独立埕柱地标；“埕柱挂炮”的摆位只能从对白获知。`game/main.gd:25,133–138,166–171,271–272`；规格 :48、:65。 |
| 10 大声公 | 符合 | (820,465)，与油纸伞构成场边支路；戏台口未另画。唯一播放“收埕”录音的动作通过对白表达，置 `cleared`，可替代旗帜门控；规格不要求该录音另有配音文件。`game/main.gd:26,36,172–174,158`；规格 :49、:73。 |
| 11 纸扎马 | 符合 | (470,515)，宫外，连接潮鼓；唯一转头动作有“自己转回宫门”文本。`horse` 不参与通关门控。`game/main.gd:27,32,35,175–177`；规格 :50。 |
| 12 油纸伞 | 符合 | (670,535)，埕边；竹椅为灰盒省略。开伞置 `umbrella` 才能往返大声公；风飘用文本及通路解锁表示，坐标不发生移动，属于灰盒抽象而非实际飘移动画。`game/main.gd:28,33,36,93–96,178–180`；规格 :51。 |

**物件数量及越界：符合。** `nodes` 恰为 12 个条目（`game/main.gd:16–29`），`act()` 是每个条目一个分支（:109–180）。图中的电线被折叠为连边，没有第 13 个可附身节点。无背包、物品收集槽或独立组合技能。横木先晃、再跳鞭炮燃放，是规格 §5 第 6 步的顺序实现，不应因为涉及两物就误判为新组合技。音频播放器是引擎节点，不是第 13 件玩法物件。

## 2. §5 正解、备选与错误路径的真实状态机

**总体：符合因果前置与可达性；部分符合严格线性顺序的读法。** 不是仅打印 PASS。游戏以 `phase/current/spirit/flags/remaining/pickup_left` 保存状态（`game/main.gd:3–13`）；冒烟载入真实 `main.gd`、加入场景树、调用游戏方法（`game/smoke.gd:61–71`），并以布尔条件统计检查、失败与退出码（:18–24、:146–147）。

| 项目 | 判定 | 状态与断言证据 |
|---|---|---|
| 第 1 步：醒于香炉，走到签筒听信息 | 符合 | `start_game/start_incense` 置当前为香炉；`jump_to(sticks)` 首次置 `heard` 并给阿弟顶位、新绳对白（`game/main.gd:62–84,90–102`）。`game/smoke.gd:66–76` 真正走到签筒；原日志 :4–12。 |
| 第 2 步与更新① | 符合 | 仅 playing 中摇签置 `pickup=true,pickup_left=18,update1=true`，重复摇允许重启窗口但更新标志只首次新增；现实窗口耗尽撤销 pickup（`game/main.gd:113–120,183–190`）。冒烟检查 update1、窗口超时及后续不能偷偷保人（`game/smoke.gd:75–76,118–123`；日志 :11–12、:255–263）。 |
| 第 3 步与更新② | 符合 | 必须 playing 且 pickup 才置 `safe/update2`，不能仅响铃即保人（`game/main.gd:121–130`）。冒烟确查 update2，并覆盖错过捡签窗口的反例（`game/smoke.gd:77–78,121–123`；日志 :17–18、:262–263）。 |
| 第 4 步 | 符合兼容实现 | 烛台实际置 `moved/fuse`、更新鞭炮坐标与图边，不止对白（`game/main.gd:131–138`）。正解/备选均实际执行 candle（`game/smoke.gd:79`）；日志 :22、:54。原 smoke 未单独断言坐标和 fuse，但代码及后续通关依赖真实存在。 |
| 第 5 步 | 符合兼容实现 | 旗动作置 `flag`，晃横木准备需要 `flag OR cleared`（`game/main.gd:147–159`）。正解使用 flag（`game/smoke.gd:80–84`）；日志 :27–31。小英视线与阿勇停锣是旗标加文本，没有独立 NPC 朝向/锣调度系统。 |
| 第 6 步及终局 | 符合 | 晃横木需 `safe AND moved AND (flag OR cleared)` 才置 armed；鞭炮须 fuse，且 playing+armed 才 finish；finish 置 ending、附回花灯（`game/main.gd:153–171,210–215`）。moved 和 fuse 在正常接口内同由烛台置位；因此并非漏掉引线因果。冒烟真检查 ending，并反测“先燃放而未晃横木不能过关”（`game/smoke.gd:84–86,124–130`；日志 :31–35、:290–291）。 |
| 备选：喇叭代第 5 步 | 符合 | `solve(true)` 不调用旗的 act，改用喇叭；仍保留签、轿、烛台、横木、鞭炮。BFS 只经过旗节点不等于使用旗技能；去喇叭前确实开伞（`game/smoke.gd:43–59,73–86`）。日志 :43–72；最终 ending 真实成立。 |
| 错路：直接潮鼓三下 | 符合 | 计数器每响一声加一，>=3 调 fail；未 safe 时由阿弟亡魂提示；5 秒后 _process 调 retry，回香炉并清空谜题（`game/main.gd:140–145,194–208,221–225`）。冒烟对两下不失败、第三下 failure、自动重试与复位均有断言（`game/smoke.gd:92–100`；日志 :82–93）。已 safe 时使用阿澄对白，未虚构阿弟被砸死（main :197–200）。 |

**顺序边界：** 实现不是“必须输入 1→2→3→4→5→6”的步骤编号机。它强制“签窗口→轿”“烛台→可燃/移位”“安全调度＋保人＋移位→晃横木→燃放”，但允许先抖旗、先燎纸再叫阿弟。本次额外以实际 API 执行 `flag,candle,sticks,palanquin,beam,crackers`，仍得到 ending。这不绕过任何安全前置，也不自动构成错解；若原稿“6 步”要求绝对线性顺序，则为部分符合，须设计方明确。不能用现有 smoke 的正序通过证明所有乱序都被禁止。

补充实测：分别省略 safe、moved、安全窗口，横木都未置 armed；未开伞时跳喇叭返回 false；灵域 advance_time(1000) 后 remaining 仍精确为 240。相关原始观测附后。

## 3. §6 切片规格

| 项目 | 判定 | 证据及边界 |
|---|---|---|
| Godot 4.3、单场景、2D、1280×720 灰盒 | 符合 | 本次引擎 banner 为 4.3.stable.official.77dcf97d8；`game/project.godot:4,6–10`；`game/Main.tscn:1–4` 为挂 main.gd 的 Node2D。色块、标签、灵核由 `game/main.gd:251–298` 绘制；三张图均 1280×720。 |
| 双域切换、灵域停时、现实流时 | 符合 | Tab→set_spirit（main :86–88、:233）；advance_time 对非 playing 或 spirit 直接返回（:183–191）。现实方能施技（:104–108），该操作限制是原稿未明确的实现补充。 |
| 一炷香、失败、亡者提示与重试 | 符合 | 240 秒初值与重置（main :7、:67、:81）；现实超时 fail（:191）；阿弟亡魂给签筒/神轿/烛台提示（:194–200）；5 秒自动重试及 Enter/R 提前重试（:202–208、:223–237）。安全未完成分支由阿澄提示，符合避免虚构死亡的处理。 |
| 标题→教学→探索→点香→通关/失败闭环 | 符合 | main :62–84、:110–112、:194–215、:227–245、:254–265；smoke :61–100、:138–145。鼠标手感与真人盲玩不由 API 冒烟替代。 |
| 底部对话框＋说话人 | 符合 | main :293–298；灵域/现实 PNG 中可见底框、阿澄姓名和纸马对白。 |
| 章末字幕原文 | 符合 | main :263 严格为“今晚的巡境，多走了一条路。”；ending_r1.png 目视一致。有暗色背景、割痕和第二铃文字；本次未把背景必须纯 RGB 黑当作额外门槛。 |
| 鼓/铃/鞭炮本地音频存在且被引用 | 符合 | 三文件均为有效 RIFF/WAV，单声道、16 bit PCM、22050 Hz、26460 帧、1.2 秒、52964 字节；`game/audio/{drum,bell,crackers}.wav`。main :141、:122–124/:215、:169 分别调用，:217–219 动态加载同名 wav 并 play。音效实际扬声器听感不在本次无头验收范围。 |
| 无存档、无越界扩章 | 符合 | 已审 main/smoke/唯一场景，未见存档写入或第二章实现；玩法对象数量见第 1 节。 |

## 4. 冒烟真实性与亲自复跑记录

**符合。** 本次亲自在原工程目录运行用户指定命令，未重写旧 smoke_r1.log：

```sh
~/workspace/tools/godot/Godot_v4.3-stable_linux.x86_64 --headless --path ~/workspace/yexun/game --script res://smoke.gd
```

原样结果：
```text
SMOKE RESULT: PASS checks=252 failures=0
exit_code=0
```

独立计数 stdout 的 PASS 行为 252，FAIL 行为 0；**完整 stdout 与现存 `docs/smoke_r1.log` 逐字一致**，不只是汇总数字一致。原日志 :326 是同一结果。完整原始 stdout 保留在本报告附录 A。

随后分别亲自执行：
```sh
~/workspace/tools/godot/Godot_v4.3-stable_linux.x86_64 --headless --path ~/workspace/yexun/game --check-only --script res://main.gd
~/workspace/tools/godot/Godot_v4.3-stable_linux.x86_64 --headless --path ~/workspace/yexun/game --check-only --script res://smoke.gd
```

两条原始输出均仅为引擎 banner 和空行：
```text
Godot Engine v4.3.stable.official.77dcf97d8 - https://godotengine.org

```

main.gd：exit_code=0；smoke.gd：exit_code=0。均无 parse error。

**覆盖强度：部分符合全面验证的读法。** 252 是脚本实际累计的检查次数，其中大量是重复 BFS 路线/合法跳跃，不能等价为 252 种独立场景。LINKS 的邻接内容未用来比较实现边，只用它的键枚举 12 点（`game/smoke.gd:6–13,111–114`）；实际 BFS 使用 game.graph（:26–40），因此确实验证了实际可达，但未逐条验证图恰等于设计/兼容边表。暂停测试只断言 phase 未变，而不是 remaining 未减（:102–105）；本审计补充精确数值实测已通过。原 smoke 未覆盖每个安全前置的单独缺失、本章全文对白、音频可听性、鼠标交互和全部图形反馈。本次补充缺前置探针通过，不修改原 smoke。

## 5. REVIEW_R1.md 的可信度与兼容处理

| 报告论点 | 判定 | 独立判断与依据 |
|---|---|---|
| 原稿为 10+2 两分量 | 符合 | 独立按规格 :53–55 列边并 BFS，而非复用 REVIEW 邻接表。无向边：香炉–签筒、签筒–烛台、烛台–潮鼓、潮鼓–神轿、神轿–标旗、神轿–横木、横木–花灯、鞭炮–花灯（电线为路）、油纸伞–大声公、纸扎马–潮鼓。得到主分量 {香炉、签筒、烛台、潮鼓、神轿、标旗、横木、花灯、鞭炮、纸扎马} 共 10，孤立支路 {油纸伞、大声公} 共 2。原文宣称“全图强连通”与明列边不一致。即便宽松允许开伞后双向跳，仍无支路接主图的边；若仅允许顺风单向，连通问题更重。REVIEW :7–28 结论成立。 |
| 引线传火缺因果段 | 符合 | 规格 :48 要求烛台火燎引线，:64–65 只明确金纸着火和搬运，没有空间传火过程；且“挪远防走火”却搬到待倒灯架脚的动机欠解释。REVIEW :37 指出的是因果缺口，不是证明谜题永远无解。main :133–138 用同事件置 fuse 并对白承认“燎过引线”，填可燃门控，但仍没有具体展示火如何从供桌传到埕柱。 |
| 移位后鞭炮可达未定义 | 符合（风险，不是已证死局） | 规格 :54 的旧通路依赖电线，:65 搬运后未更新灵核跳跃关系；因此应认定缺定义，不能声称原稿已经证明搬后必不可达。REVIEW :39 采用“未说明/可能到不了”的风险表述准确。 |
| 双物件终局顺序未定义 | 符合 | 规格 :68 的“横木＋鞭炮”未说先后、持续时间或同时操作法；一魂不能同时附两物。REVIEW :39 的先晃准备再燃放补充合理，主流程保留。 |
| 实现补边与报告一致 | 符合 | 标旗–油纸伞双向边：main :33、:36；开伞门控：:93–96；烛台移位后保留花灯–鞭炮并新增横木–鞭炮双向边：:133–137。与 REVIEW :28、:39 一致。无新增物件。 |
| 其他时间/危险参数符合报告 | 符合 | 18 秒捡签、240 秒香期、45 秒危险扣时及重复晃失败均能在 main 找到，对应 REVIEW :51–64。抖旗和清场使用持续布尔标志，不是实际短时 NPC 动作窗口。香烧尽仍会失败，旗标不会无限停止总香期（main :183–200；补充探针实测 safe+flag+armed 后超时仍 failure，发言人为阿澄）。 |
| 没有改动原设计剧情设定 | 部分符合 | **原设计文件未改，核心人物、救弟、割绳钩子、第二铃、章末字幕未被改写。** 但增加连边、逆向开伞通行、现实才能施技、永久保人/调度标志、明确阈值和终局先后，确实补充或固定了玩法/时序解释；不能等同“零设计改动”。REVIEW 多处明确“待主控裁定”，有正确披露。备选中“小英撤离现场”仅在 REVIEW :47 作解释，游戏喇叭对白只说闲人离开（main :174），未单列小英撤离状态。 |

**原件保真：符合。** 本次算得设计稿 SHA256：
`430ba22b79466659300fdb35fc2a492d3c5dd29e63194c02c913bdf8a718ceb0`，
与 `docs/design_source.sha256:1` 一致。审计前后复核设计稿、工程内 31 个非 log 文件及 3 张截图内容均未改变。

REVIEW 作为“指出原稿缺定义，并披露工程兼容”的报告可信；不能将其“采用兼容后可形成闭环”提升为设计方已经批准所有补充。REVIEW :65 的截图未完成是旧时间点事实，现有补截证据已覆盖，详见第 6 节。

## 6. 截图真实性及 capture 记录核验

**三图画面与主控后补 capture 日志：符合。** 亲自打开全部 PNG 目视，并独立读取尺寸、文件字节数与像素统计；不是只读文件名。

| 文件 | 判定 | 尺寸 / 字节数 | 独立观察 |
|---|---|---|---|
| docs/shots/spirit_r1.png | 符合 | 1280×720 / 81236 | 灵域、香期 240、当前纸扎马、12 个青色实心灵核与连线、底框阿澄纸马对白。精确 RGB(83,247,235) 灵核色像素 2496。非主色比例 68.4630%，非黑比例 68.4630%。 |
| docs/shots/reality_r1.png | 符合 | 1280×720 / 78409 | 同场景、当前纸扎马、香期 239；没有实心灵核和图连线；保留当前附身的青色圆环，不能误把选中圆环叫成灵核。精确灵核色像素 0。非主色比例 68.4499%，非黑比例 100.0000%。 |
| docs/shots/ending_r1.png | 符合 | 1280×720 / 49420 | 章末原文字幕、第一章完、整齐割痕及第二铃文本均可见；无场景节点。非主色比例 1.8702%，非黑比例 100.0000%。 |

**同一工程来源判断：符合现有证据。** 对象坐标、色块、字体、文本、灵域绘线和现实隐藏灵核都匹配 `game/main.gd:251–298`；当前纸扎马和终局的状态也匹配 `capture_scene` 真实 API 路径（:331–349）。`docs/work/capture_main.log:6,17,28` 记录实际 llvmpipe OpenGL 渲染，:13、:24、:40 分别保存三图 error=0，:41–43 的尺寸外字节数和像素统计与本次独立计算完全一致。该证据支持真实 Godot viewport 抓图，未见外来示意图或无头黑图冒充的迹象。本次未重新生成截图，也不能仅凭 PNG 证明真人手动游玩过。

**旧 capture/交付陈述与现状：不符（文档滞后，不是截图造假）。** `docs/capture_r1.log:1–9` 声称截图失败、不存在 PNG；`docs/DELIVERY_R1.md:3,22,24` 仍称目录为空/未完成；`docs/REVIEW_R1.md:65` 同样未完成。旧 capture 日志修改时间 09:38:53 UTC，现三张 PNG 为 09:40:14、09:40:18、09:40:21 UTC，后补日志确有成功记录。因此应保留“先失败、后补截成功”的事实链，不能把旧失败日志用作否认现有三图的依据，也不能声称所有交付文档已一致。

PNG SHA256：
- spirit：`68cffdaf7fb5e5c082cfdb19e6ed7fce889b6ab0d0b65d2963e5fc574d78d17b`
- reality：`2fd388aa04233f97748455e43a527b916d312dee1a4dec13d5da112ac8702fd7`
- ending：`7b36f45cdeb2eb3c4b4ced4dc373a905d706d16e1e628ff320296f0c1f38377b`

## 7. 全部发现，按严重程度排序

本次未发现应直接判“不通过”的高危逻辑断链、伪造结果或工程解析错误。

1. **中 / 设计放行条件：兼容规则仍未定版。** REVIEW :28、:37–39、:47、:51–64 明确待裁定；实现已采用这些规则，并允许独立步骤交换次序。原稿保真不代表所有玩法补充已获确认。需由设计负责人确认，不能由审计员代签。这是本次“有条件通过”的主要边界。
2. **中 / 调查反馈不足：花灯没有在单独调查时清楚给出物件表要求的断口线索。** main :150–152 只给暗影，明确整齐割痕留到 :214、:261。不会阻断通关，但 §4 的调查作用仅部分符合。
3. **低 / 灰盒摆位：潮鼓在画出的宫内范围外；初始鞭炮不挂在画出的柱上。** main :20、:25、:267–272；其他供桌/戏台口/竹椅等地标省略，不能严谨宣称所有具体地点均有视觉实现。后者属于灰盒表达边界，不要求补正式美术。
4. **低 / 交付证据同步：旧报告与 capture_r1.log 仍报截图未完成。** 后补 capture_main.log 和三 PNG 已真实补齐；应在交付入口标明新的有效证据，避免读者误判。审计未代改任何旧文档。
5. **低 / 验证覆盖表述：252 项不代表 252 个独立玩法断言，也不验证完整设计保真。** smoke :18–24、:43–53、:102–114；含大量路线/跳边计数，暂停断言偏弱，部分安全门控缺独立反例。R2 补充探针支持门控正确，但真人操作、盲玩可读性与扬声器听验仍未验证。

**最终总评：有条件通过。** 可认定灰盒主状态机、两解通关、错误失败重试、三音频接线和三图交付真实成立。以逐项规格完全达标或 §7 真人验收完成为口径，则证据不足；需裁定兼容解释，并处理/接受上述已记录差异。审计发现均仅记录，未修复工程或改写设计。

## 附录 A：本次指定冒烟命令的完整原始 stdout

以下完整输出与 smoke_r1.log 逐字一致；进程退出码原样为 0。

```text
Godot Engine v4.3.stable.official.77dcf97d8 - https://godotengine.org

YEXUN R1 state-machine smoke: actual game API + legal graph jumps
阿澄：谁也看不见我……青色光点在香炉里。按 E 火星上窜；Tab 切现实／灵域。
阿澄：火星上窜，梁上燕子惊起。我的手……能碰到它们。
一炷香前：阿弟仍在灯架下绑绳。现实时间流动，灵域时间停顿。签筒、神轿或许能叫他离开。
PASS title -> incense tutorial -> timed chapter
PASS BFS route to sticks
庙祝公／小英：阿弟顶了他哥哥的轿位。／灯架今晚……绳是新换的。
PASS legal jump incense -> sticks
命运更新①：签文：逢冲则避。阿弟离架两步捡签，但很快会回来。趁现在叫他扶轿！
PASS fate update 1 recorded
PASS BFS route to palanquin
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
命运更新② · 阿勇：阿弟！轿杠沉，过来扶！【宫内慢半拍又响一铃。小英皱眉。落点下没人了。】
PASS fate update 2 recorded
PASS BFS route to candle
PASS legal jump palanquin -> drum
PASS legal jump drum -> candle
庙祝公：金纸烧起来了！【扑火，顺手摘下鞭炮，挪到灯架底座石礅；燎过的引线纸可以燃放。】
PASS BFS route to flag
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
PASS legal jump palanquin -> flag
小英／阿勇：什么声音？【小英望向埕西，背对埕心；旗影扫过，阿勇停手，出发锣暂缓。】
PASS BFS route to beam
PASS legal jump flag -> palanquin
PASS legal jump palanquin -> beam
阿澄：横木已经晃松。趁停锣清场的空隙，跳向架脚鞭炮燃放。
PASS BFS route to crackers
PASS legal jump beam -> crackers
阿弟／阿澄：若我还在下头……【灯架倒向空埕，无人受伤，夜巡推迟。附回花灯残骸，灯光照出绳结整齐的割痕。远处第二声轿铃又响了一次。】
PASS six-step canonical ending
阿澄：谁也看不见我……青色光点在香炉里。按 E 火星上窜；Tab 切现实／灵域。
阿澄：火星上窜，梁上燕子惊起。我的手……能碰到它们。
一炷香前：阿弟仍在灯架下绑绳。现实时间流动，灵域时间停顿。签筒、神轿或许能叫他离开。
PASS title -> incense tutorial -> timed chapter
PASS BFS route to sticks
庙祝公／小英：阿弟顶了他哥哥的轿位。／灯架今晚……绳是新换的。
PASS legal jump incense -> sticks
命运更新①：签文：逢冲则避。阿弟离架两步捡签，但很快会回来。趁现在叫他扶轿！
PASS fate update 1 recorded
PASS BFS route to palanquin
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
命运更新② · 阿勇：阿弟！轿杠沉，过来扶！【宫内慢半拍又响一铃。小英皱眉。落点下没人了。】
PASS fate update 2 recorded
PASS BFS route to candle
PASS legal jump palanquin -> drum
PASS legal jump drum -> candle
庙祝公：金纸烧起来了！【扑火，顺手摘下鞭炮，挪到灯架底座石礅；燎过的引线纸可以燃放。】
PASS BFS route to loudspeaker
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
PASS legal jump palanquin -> flag
PASS legal jump flag -> umbrella
阿澄：油纸伞张开，随风飘向戏台口。现在可以跳到大声公。
PASS legal jump umbrella -> loudspeaker
庙祝公录音：收埕！闲人离埕心，夜巡暂缓！【备选调度就绪；仍需阿弟扶轿、鞭炮就位，再晃横木燃放。】
PASS BFS route to beam
PASS legal jump loudspeaker -> umbrella
PASS legal jump umbrella -> flag
PASS legal jump flag -> palanquin
PASS legal jump palanquin -> beam
阿澄：横木已经晃松。趁停锣清场的空隙，跳向架脚鞭炮燃放。
PASS BFS route to crackers
PASS legal jump beam -> crackers
阿弟／阿澄：若我还在下头……【灯架倒向空埕，无人受伤，夜巡推迟。附回花灯残骸，灯光照出绳结整齐的割痕。远处第二声轿铃又响了一次。】
PASS alternative ending
阿澄：谁也看不见我……青色光点在香炉里。按 E 火星上窜；Tab 切现实／灵域。
阿澄：火星上窜，梁上燕子惊起。我的手……能碰到它们。
一炷香前：阿弟仍在灯架下绑绳。现实时间流动，灵域时间停顿。签筒、神轿或许能叫他离开。
PASS title -> incense tutorial -> timed chapter
PASS BFS route to drum
庙祝公／小英：阿弟顶了他哥哥的轿位。／灯架今晚……绳是新换的。
PASS legal jump incense -> sticks
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
阿澄：鼓震传到灯架。再乱敲，阿弟会来不及离开……（1／3）
PASS BFS route to drum
阿澄：鼓震传到灯架。再乱敲，阿弟会来不及离开……（2／3）
PASS two drum strikes do not fail immediately
PASS BFS route to drum
阿弟的亡魂：三下潮鼓震松主绳，原命运提前到来。 哥，签筒能叫我离架，神轿能留住我。烛台会让爷爷挪鞭炮。再来一次吧……
PASS third drum strike reaches failure
阿澄：谁也看不见我……青色光点在香炉里。按 E 火星上窜；Tab 切现实／灵域。
一炷香前：阿弟仍在灯架下绑绳。现实时间流动，灵域时间停顿。签筒、神轿或许能叫他离开。
阿弟的亡魂：香刚点燃。先看签筒，再听轿铃；架脚的鞭炮，要等烛台引来爷爷。
PASS failure automatically retries after ghost dialogue
PASS automatic retry resets possession and puzzle flags
阿澄：谁也看不见我……青色光点在香炉里。按 E 火星上窜；Tab 切现实／灵域。
阿澄：火星上窜，梁上燕子惊起。我的手……能碰到它们。
一炷香前：阿弟仍在灯架下绑绳。现实时间流动，灵域时间停顿。签筒、神轿或许能叫他离开。
PASS title -> incense tutorial -> timed chapter
PASS spirit realm pauses incense timer
阿弟的亡魂：一炷香燃尽，第三下出发锣响，灯架倒下。未完成改命。 哥，签筒能叫我离架，神轿能留住我。烛台会让爷爷挪鞭炮。再来一次吧……
PASS reality incense timeout reaches death event
阿澄：谁也看不见我……青色光点在香炉里。按 E 火星上窜；Tab 切现实／灵域。
阿澄：火星上窜，梁上燕子惊起。我的手……能碰到它们。
一炷香前：阿弟仍在灯架下绑绳。现实时间流动，灵域时间停顿。签筒、神轿或许能叫他离开。
PASS title -> incense tutorial -> timed chapter
PASS nonadjacent jump rejected
PASS BFS route to incense
PASS BFS route to incense
PASS BFS route to sticks
庙祝公／小英：阿弟顶了他哥哥的轿位。／灯架今晚……绳是新换的。
PASS legal jump incense -> sticks
PASS BFS route to incense
PASS legal jump sticks -> incense
PASS BFS route to candle
PASS legal jump incense -> sticks
PASS legal jump sticks -> candle
PASS BFS route to incense
PASS legal jump candle -> sticks
PASS legal jump sticks -> incense
PASS BFS route to drum
PASS legal jump incense -> sticks
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
PASS BFS route to incense
PASS legal jump drum -> candle
PASS legal jump candle -> sticks
PASS legal jump sticks -> incense
PASS BFS route to palanquin
PASS legal jump incense -> sticks
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
PASS BFS route to incense
PASS legal jump palanquin -> drum
PASS legal jump drum -> candle
PASS legal jump candle -> sticks
PASS legal jump sticks -> incense
PASS BFS route to flag
PASS legal jump incense -> sticks
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
PASS legal jump palanquin -> flag
PASS BFS route to incense
PASS legal jump flag -> palanquin
PASS legal jump palanquin -> drum
PASS legal jump drum -> candle
PASS legal jump candle -> sticks
PASS legal jump sticks -> incense
PASS BFS route to beam
PASS legal jump incense -> sticks
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
PASS legal jump palanquin -> beam
PASS BFS route to incense
PASS legal jump beam -> palanquin
PASS legal jump palanquin -> drum
PASS legal jump drum -> candle
PASS legal jump candle -> sticks
PASS legal jump sticks -> incense
PASS BFS route to lantern
PASS legal jump incense -> sticks
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
PASS legal jump palanquin -> beam
PASS legal jump beam -> lantern
PASS BFS route to incense
PASS legal jump lantern -> beam
PASS legal jump beam -> palanquin
PASS legal jump palanquin -> drum
PASS legal jump drum -> candle
PASS legal jump candle -> sticks
PASS legal jump sticks -> incense
PASS BFS route to crackers
PASS legal jump incense -> sticks
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
PASS legal jump palanquin -> beam
PASS legal jump beam -> lantern
PASS legal jump lantern -> crackers
PASS BFS route to incense
PASS legal jump crackers -> lantern
PASS legal jump lantern -> beam
PASS legal jump beam -> palanquin
PASS legal jump palanquin -> drum
PASS legal jump drum -> candle
PASS legal jump candle -> sticks
PASS legal jump sticks -> incense
PASS BFS route to horse
PASS legal jump incense -> sticks
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
PASS legal jump drum -> horse
PASS BFS route to incense
PASS legal jump horse -> drum
PASS legal jump drum -> candle
PASS legal jump candle -> sticks
PASS legal jump sticks -> incense
PASS BFS route to umbrella
PASS legal jump incense -> sticks
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
PASS legal jump palanquin -> flag
PASS legal jump flag -> umbrella
PASS BFS route to incense
PASS legal jump umbrella -> flag
PASS legal jump flag -> palanquin
PASS legal jump palanquin -> drum
PASS legal jump drum -> candle
PASS legal jump candle -> sticks
PASS legal jump sticks -> incense
PASS BFS route to loudspeaker
PASS legal jump incense -> sticks
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
PASS legal jump palanquin -> flag
PASS legal jump flag -> umbrella
阿澄：油纸伞张开，随风飘向戏台口。现在可以跳到大声公。
PASS legal jump umbrella -> loudspeaker
PASS BFS route to incense
PASS legal jump loudspeaker -> umbrella
PASS legal jump umbrella -> flag
PASS legal jump flag -> palanquin
PASS legal jump palanquin -> drum
PASS legal jump drum -> candle
PASS legal jump candle -> sticks
PASS legal jump sticks -> incense
PASS all 12 nodes actually reachable from and return to incense
阿澄：谁也看不见我……青色光点在香炉里。按 E 火星上窜；Tab 切现实／灵域。
阿澄：火星上窜，梁上燕子惊起。我的手……能碰到它们。
一炷香前：阿弟仍在灯架下绑绳。现实时间流动，灵域时间停顿。签筒、神轿或许能叫他离开。
PASS title -> incense tutorial -> timed chapter
PASS BFS route to crackers
庙祝公／小英：阿弟顶了他哥哥的轿位。／灯架今晚……绳是新换的。
PASS legal jump incense -> sticks
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
PASS legal jump palanquin -> beam
PASS legal jump beam -> lantern
PASS legal jump lantern -> crackers
阿澄：引线纸还未燎过，无法燃放。烛台的火能引来庙祝公。
PASS unprepared crackers reject ignition
PASS BFS route to sticks
PASS legal jump crackers -> lantern
PASS legal jump lantern -> beam
PASS legal jump beam -> palanquin
PASS legal jump palanquin -> drum
PASS legal jump drum -> candle
PASS legal jump candle -> sticks
命运更新①：签文：逢冲则避。阿弟离架两步捡签，但很快会回来。趁现在叫他扶轿！
阿弟：签捡到了……我回去绑绳。
PASS Adi returns to frame when pickup window expires
PASS BFS route to palanquin
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
小英：轿铃之后，宫里又有第二声铃……阿弟还在架下，先让他注意到落签。
PASS missed pickup window cannot silently secure Adi
阿澄：谁也看不见我……青色光点在香炉里。按 E 火星上窜；Tab 切现实／灵域。
阿澄：火星上窜，梁上燕子惊起。我的手……能碰到它们。
一炷香前：阿弟仍在灯架下绑绳。现实时间流动，灵域时间停顿。签筒、神轿或许能叫他离开。
PASS title -> incense tutorial -> timed chapter
PASS BFS route to sticks
庙祝公／小英：阿弟顶了他哥哥的轿位。／灯架今晚……绳是新换的。
PASS legal jump incense -> sticks
命运更新①：签文：逢冲则避。阿弟离架两步捡签，但很快会回来。趁现在叫他扶轿！
PASS BFS route to palanquin
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
命运更新② · 阿勇：阿弟！轿杠沉，过来扶！【宫内慢半拍又响一铃。小英皱眉。落点下没人了。】
PASS BFS route to candle
PASS legal jump palanquin -> drum
PASS legal jump drum -> candle
庙祝公：金纸烧起来了！【扑火，顺手摘下鞭炮，挪到灯架底座石礅；燎过的引线纸可以燃放。】
PASS BFS route to flag
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
PASS legal jump palanquin -> flag
小英／阿勇：什么声音？【小英望向埕西，背对埕心；旗影扫过，阿勇停手，出发锣暂缓。】
PASS BFS route to crackers
PASS legal jump flag -> palanquin
PASS legal jump palanquin -> beam
PASS legal jump beam -> crackers
阿澄：鞭炮炸响，但横木尚未晃松，未能放倒灯架。
PASS crackers without beam preparation cannot complete chapter
阿澄：谁也看不见我……青色光点在香炉里。按 E 火星上窜；Tab 切现实／灵域。
阿澄：火星上窜，梁上燕子惊起。我的手……能碰到它们。
一炷香前：阿弟仍在灯架下绑绳。现实时间流动，灵域时间停顿。签筒、神轿或许能叫他离开。
PASS title -> incense tutorial -> timed chapter
PASS BFS route to beam
庙祝公／小英：阿弟顶了他哥哥的轿位。／灯架今晚……绳是新换的。
PASS legal jump incense -> sticks
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
PASS legal jump palanquin -> beam
阿澄：横木猛晃！灯架更不稳了，香期骤减四十五秒。必须先让阿弟离开、安排震源并停锣或清场。
PASS premature beam shake accelerates collapse
PASS BFS route to beam
阿澄：横木猛晃！灯架更不稳了，香期骤减四十五秒。必须先让阿弟离开、安排震源并停锣或清场。
阿弟的亡魂：过早摇晃，灯架提前倒下。 哥，签筒能叫我离架，神轿能留住我。烛台会让爷爷挪鞭炮。再来一次吧……
PASS repeated premature beam shakes fail
阿澄：谁也看不见我……青色光点在香炉里。按 E 火星上窜；Tab 切现实／灵域。
阿澄：火星上窜，梁上燕子惊起。我的手……能碰到它们。
PASS incense tutorial opens free exploration
PASS BFS route to loudspeaker
庙祝公／小英：阿弟顶了他哥哥的轿位。／灯架今晚……绳是新换的。
PASS legal jump incense -> sticks
PASS legal jump sticks -> candle
PASS legal jump candle -> drum
PASS legal jump drum -> palanquin
PASS legal jump palanquin -> flag
PASS legal jump flag -> umbrella
阿澄：油纸伞张开，随风飘向戏台口。现在可以跳到大声公。
PASS legal jump umbrella -> loudspeaker
庙祝公录音：收埕！闲人离埕心，夜巡暂缓！【备选调度就绪；仍需阿弟扶轿、鞭炮就位，再晃横木燃放。】
一炷香前：阿弟仍在灯架下绑绳。现实时间流动，灵域时间停顿。签筒、神轿或许能叫他离开。
PASS starting timed chapter from distant exploration returns to incense
PASS timed chapter clears exploration effects and starts full incense
SMOKE RESULT: PASS checks=252 failures=0
```

## 附录 B：R2 只读补充探针

探针文件在 /tmp，未加入工程，调用现有 walk_to/use_at/act/advance_time/jump_to 等接口，没有直接伪造 flags。以下摘录本次原始观测行：

```text
R2 missing safe: armed=false phase=playing
R2 missing moved: armed=false phase=playing
R2 missing window: armed=false phase=playing
R2 independent steps reordered: phase=ending
R2 exact spirit timer unchanged=true remaining=240
R2 unopened umbrella -> loudspeaker=false
R2 armed before early crackers phase=playing armed=true
R2 safe + flag timeout phase=failure speaker=阿澄
```

该补充探针退出码为 0；退出时另出现下列原始诊断：
```text
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
     at: cleanup (core/object/object.cpp:2284)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:604)
```
此探针在同帧反复 new/free 游戏且触发延迟铃计时器，未清理完全部资源便退出；这些诊断来自附加探针运行，不能归入指定 smoke 的输出。指定 smoke 及两条 check-only 无此诊断。未据此认定实际玩家路径存在资源泄漏，也未更改工程。

