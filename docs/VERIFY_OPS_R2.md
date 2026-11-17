# 独立核验报告 R2：ops 分支第二批交付（YX-10 / YX-05 / YX-13）

- 核验方：主控独立核验（只读，未改 game/ 与任何既有交付文件）
- 基线：YX-09 尖端 `86623c7`；待核分支 `codex/yexun-ops`
- 待核提交：`7733bb5`（YX-10 过稿门）、`2656ffd`（YX-10 实现）、`287920f`（YX-10 证据）、`5a38fd1`（YX-05）、`3a7ab5d`（YX-13）
- 方法：逐提交 diff 对基线、冒烟日志实数亲点（汇总行＋ FAIL 行扫描互证）、素材文件逐张实测尺寸、关键字符串与基线逐字比对

## 总评：三项均通过，无不通过项

分支自 `86623c7` 线性追加恰 5 个提交、零合并，main 未被本批触碰。全批 `game/main.gd` 合计 **+86 行 / 删除 0 行**——定稿台词与既有调用零改动（全批唯一删除行是 smoke.gd 中 `solve6()` 的函数签名扩展，见 YX-10 节）。

---

## YX-10 玩法 D 包（木箱／工夫茶／分粿巡更／口述回访）：通过

**过稿门（7733bb5）属实且先行。** 该提交仅新增 `docs/work/YX10_COPY_REVIEW.md`（97 行）：三项民俗来源均落档可查（中国非遗数字博物馆工夫茶研究、潮州市湘桥区文化馆红桃粿、新会地方文史更楼与巡夜工具，均附 URL），且逐项明示本作离散化处理（「不承诺复现完整茶艺工序」「三声练习节奏另行编排」「数量和盘位为本作操作设计」），未把本作虚构冒充真实民俗。新增文案全文在写代码前已完整列入过稿包；实现中的文案（folklore.gd PRACTICE 表、main.gd 三条木箱提示）与过稿包逐字一致（亲核 chest/tea/cake/bang 四组）。

**四项齐备且与细案一致**（对照 GAMEPLAY_ENRICHMENT_PLAN 顺位 3/4/5/7）：
- 木箱双域调查：现实查原清单（`archive_taken` 后）→ 灵域相邻节点观察（`folklore_context()=="observe"` 要求 spirit＋图邻接）→ 回现实复查登记，与细案「现实—灵域—现实」三段及「不新增案件结论」一致；原清单台词未动。
- 工夫茶：取档后、现实茶桌、Q 键／点击进入可退出面板；`select_portion` 强制轮流分斟（单杯不得超过最少杯），两段（分斟＋余沥）抽象为每杯目标 3，未改原取档窗口（冒烟有「原茶桌支开先于练习」断言）。
- 分粿／听梆：均门控于 `seg5==3 && people_ready`（聚人完成后），段二 45 秒留人作用未被触碰；分粿每盘上限 2、共 6 份；听梆容差与重听重拍按交付口径实现。
- 口述回访：六段正文（旧轿样／船工／侨批／更夫／雾径／长明灯空位）在基线 `86623c7` 的 main.gd 中逐条原文存在（亲核 6/6 命中），folklore.gd ORALS 表为复制复用，未新写人物对白；`capture()` 只读既有 seen 旗标、实际触发后才登记，未读条目不展示。

**可选性与不变量。** `folk_*` 旗标仅出现在 folklore 接线函数内（亲核全部引用行），未进入 `pre_all`、窗口、香时、模仿计数或任何通关收束；练习面板打开时 `_process` 提前返回、主线计时冻结（冒烟有状态不变断言：remaining／jump_count／flags 前后一致），练习完成不授予任何主线旗标（冒烟明示断言）。记录存独立键 `yexun_folklore_v1`（版本 1、白名单恢复、坏格式忽略、长度上限），不入章节存档与行为账；木箱三段状态借 flags 存储，随 R2 既有 `duplicate(true)` 隔离覆盖。

**接线方式干净。** 新增模块 `game/folklore.gd`（235 行，RefCounted）承载记录、面板状态与绘制；main.gd +86 行仅为 preload、标题页入口（J 键／按钮）、act3–6 后的 capture 钩子、context/open/after_action 与三处顶层拦截（process/input/draw），无既有逻辑行被改写。

**冒烟实数亲点属实。** `docs/work/yx10-smoke.log`（UTF-8）汇总行 `SMOKE RESULT: PASS checks=2050 failures=0`，全文以 FAIL 起首的结果行为 0；2050 = 基线 1862 + 188。新增断言为真实行为测试：沿实时图 BFS 路径 `jump_to`、真实鼠标事件坐标点按、Q/Esc 键入、以正常计时等待对手占位、三章完整取档路径、五章原聚人路径进段三、六章完整解法读空位；未见直接赋值造主线成功状态（仅面板内 `folklore.selected` 的 UI 选中赋值，与键盘导航等价）。渲染验证日志 `RENDER RESULT 17 / 0` 与自述一致。smoke.gd 唯一删除行是 `func solve6()` → `func solve6(record_lamp: bool = false)` 的签名扩展，原测试保留并增跑灯旁空位记录路径，非删测。

注记：
1. 文案「用户明确批准」这一事件本身不在仓库证据内；仓内链条（过稿门先行且标注待批 → 实现提交题为 approved → 文案与过稿稿逐字一致）与交付报告自述互相吻合，核验据此采信，批准原话以用户与公司侧沟通记录为准。
2. 回访记录在原生桌面构建下不跨进程持久（浏览器 localStorage），交付方已明示为本卡范围外；与 YX-05 指出的原生持久化缺口同类，Steam 发行前需另卡处理。
3. `yx10-render-errors.log` 中的退出清理警告（ObjectDB leaked／1 resource）与 N-03 已结案的 harness 退出时序噪声同类，交付方单独成文件披露，不构成检查失败。

## YX-05 Windows 验证包与立项准备：通过

**预设规范。** `export_presets.cfg` 仅在文件尾追加 `[preset.1]` Windows Desktop：`binary_format/architecture="x86_64"`、`embed_pck=false`（独立 EXE＋PCK）、`exclude_filter="smoke.gd"`、输出 `../build-windows/yexun.exe`；diff 无既有行改动，Web 预设逐字未动。

**验证包存放与校验明确。** 二进制按交付口径不入 Git，存放于公司侧 `E:/yexun-validation/Windows/yexun-windows-validation.zip`，准备单给出 exe（84,214,784 B）／pck（130,240,928 B）／zip（158,587,387 B）三者的 SHA-256。因二进制不在仓内，该组散列为交付方自报、本核验无法独立复算——存放位置与校验值记录完整，可日后按表复核。

**「启动及第三章实际路径通过」证据成立。** 证据链在仓：导出日志（savepack 含 folklore.gd，构建源含 YX-10）、正常启动日志（真实 OpenGL／RTX 4070）、`render-validation.gd` 与渲染启动日志——导出的 EXE 加载包内 Main.tscn、以真实渲染器出帧存图（windows-title.png／windows-ch3.png 均在仓），并在包内实跑第三章路径（教学→点香→跳茶桌支开管事→跳名册取档），日志含真实游戏对白原文且以 `WINDOWS VALIDATION chapter3 live archive=true` 收尾、退出码 0。注：该路径为在真实导出二进制内以游戏 API 驱动（与冒烟同风格），非真人原始输入操作；准备单未冒称人工试玩，口径相符。退出清理警告同 N-03 类，已如实附注。

**个人账号准备单齐备、边界守住。** 准备单覆盖账号／签约身份／协议／税务／收款／$100 应用费／权利记录七项，逐项标「待本人／未执行／未授权支付」，明示不把证件、税号、银行信息入仓，并注明依据页面与查阅日期；全卡未注册、未登录、未付费、未提交（diff 与日志无反证）。同时如实声明未签名、无 Steam SDK／成就／云存档、原生持久化待另卡——未把本地验证包冒充发行就绪。

## YX-13 Steam 胶囊图组：通过

**19 张逐张实测，规格全对。** 以 PIL 亲测全部 PNG 尺寸，与 STEAM_DECISION_PACK／YX-05 缺口盘点逐项对齐：Header 920×430、Small 462×174（另附核看图 120×45、184×69）、Main 1232×706、Vertical 748×896、Library Capsule 600×900、Library Header 920×430、Library Hero 3840×1240、Library Logo 1280×600（RGBA；规格为宽 1280 和／或高 720，宽达标）。19 张构成 = 8 组原图＋排字版（16）＋小胶囊核看图（2）＋全组对照预览 contact_sheet.png（1400×2560），双份与预览图齐备。

**标题字为本地排字，无生图直出中文。** `build_capsules.py` 以 Pillow `ImageFont.truetype` 加载项目本地字体 `game/fonts/LXGWWenKai-Subset.ttf`（霞鹜文楷，OFL 授权文件在仓）程序化绘制「夜巡」二字，脚本注明 no generation API；素材源为既有 SP 定稿主视觉 `concept/concept_01_keyvisual_SP.png` 的确定性裁切。manifest.json 记录母图与字体 SHA-256、Pillow 版本及逐文件尺寸／散列／角色，README 记录各尺寸字号与处理口径。Logo 透明性亲测：成品 alpha 范围 0–255、raw 为全透明源画布（与 README 披露一致）。

**自检口径吻合。** validation.txt 自述 46 项检查通过、19 张可读；本核验的独立实测结果与其一致。

注记：
1. `header_capsule.png` 与 `library_header.png`（及其 raw）为逐字节相同文件——两规格位同为 920×430、同裁切同排字，属一图填两位，README 使用表已并列披露；若 Steam 后台对两处素材有差异化期待，建页时再议。
2. Library Hero 为 1672×941 母图放大至 3840×1240，非原生 4K 细节，交付方已明示。
3. 6 张 1920×1080 最终发行构建实机截图仍缺，交付方已明示须后续按发行构建复拍，不在本卡 19 张之内。

---

## 存疑／注记汇总（均不构成不通过）

1. YX-10 文案批准原话不在仓内证据链（链条自洽，见 YX-10 注记 1）。
2. 原生持久化缺口：回访记录与现行存档在桌面构建下不跨进程持久（YX-10 注记 2、YX-05 准备单同述），Steam 发行前必须另卡解决。
3. YX-05 验证包散列为交付方自报（二进制不入仓，位置与校验值已记录）。
4. YX-13 Header 与 Library Header 逐字节相同；Hero 为放大图（均已由交付方披露）。
5. 真人验收仍未做：YX-10 手上活的教学与手感、YX-13 图组在 Steam 后台实际预览、YX-05 在干净 Windows 机器上的安装运行，均待真人环节；线上网页仍为 YX-11 版，YX-12 部署另行处理。
