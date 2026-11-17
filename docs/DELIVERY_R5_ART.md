# 《夜巡》第五章 SP 素材集成台账（2026-11-17）

承 DELIVERY_R5.md 未解决项②：SP 素材包（manifest 第五章小节 10 文件）已按 OBJ_ART5/CHAR_ART5 接口全量替换灰盒占位，不改玩法逻辑与设计。线上同址：https://yexun-ch1.musen-ai-9527.workers.dev/

本轮分工说明：换图、冒烟、截图由集成轮完成；本收尾轮补完截图亲验与归档、/tmp 导出验包、部署与独立复核，未改 main.gd 任何逻辑与标定参数。

## 逐件替换对照（灰盒占位 → SP 素材）

标定口径沿前四章：spec[2]=SP 图 alpha 包围盒高占比、spec[3]=包围盒底边占比−0.5、spec[4]=保内容中心偏移；target_h 全部沿灰盒值不变。

| 接口 id | 游戏文件 | SP 源 | target_h | spec[2] | spec[3] | spec[4] |
|---|---|---|---|---|---|---|
| everlamp | obj5_everlamp.png | obj_lamp_eternal.png（亮稳） | 175 | 0.665 | 0.293 | −4.0 |
| everlamp·发矮 | obj5_everlamp_low.png | obj_lamp_eternal_low.png | 同上（共用同一精灵/spec） | — | — | — |
| everlamp·将熄 | obj5_everlamp_dying.png | obj_lamp_eternal_dying.png | 同上（共用同一精灵/spec） | — | — | — |
| oilpot | obj5_oilpot.png | obj_oil_pot.png | 115 | 0.838 | 0.420 | −4.2 |
| porridge | obj5_porridge.png | obj_porridge_stall.png | 180 | 0.977 | 0.494 | 2.1 |
| cake | obj5_cake.png | obj_kueh_plate.png | 95 | 0.933 | 0.476 | 49.0 |
| gengbang | obj5_gengbang.png | obj_bang.png | 150 | 0.984 | 0.491 | −0.9 |
| laobo | char5_laobo.png | char_abo.png | 170 | 0.933 | 0.525（落脚口径） | — |

复用件（candle/palanquin/drum/gong/paperfig＋头部拆分件/horse 沿一、二章 SP 图，sedanrem 沿三章 SP 图）按第五章站位以 OBJ_ART5 内本章 spec 接入，图面未动；复用角色 8 人未动。

底板：bg5_realm.png ← bg_palace_realm.png、bg5_spirit.png ← bg_palace_spirit.png（2172×724）。

## 底板方案

底板 2172×724（3:1）对 3200×720 三段长卷舞台：sync_art 第五章分支 cover-fit（scale=max(3200/2172, 720/724)=1.4733，横向满幅、纵向居中裁切雾空与前景），零拉伸、零逻辑坐标改动（沿 manifest 接入留意「按 724 高对齐、横向站位收拢」口径）。截图亲验：正殿（神龛/供桌/侧间门）、宫埕（宫门/停轿空地）、后殿（廊下/杂物间）三段衔接连贯，物件站位与底板空位对齐，无露馅。

## 长明灯三态校验

- 引擎层：三态为同一精灵节点整图换纹理（sync_art 按段计时余量 lamp_frac 切换：>0.5 亮稳、≤0.5 发矮、≤0.22 将熄），共用同一 spec，节点位置/缩放不变。
- 图面层（PIL 实测三源图 alpha 包围盒）：亮稳 x 536–994 / y 134–811；发矮 x 537–994 / y 237–811；将熄 x 535–993 / y 295–811。底边三态同为 811、左右界差 ≤1px，差异仅在顶部——即火苗高度递减（678→575→517），灯盏与灯座本体坐标不动。逐像素差分的变化集中于火苗与半透明光晕区（光晕随灯势收缩，属设计内差分）。
- 截图层：ch5_r5art（亮稳）/ch5lamplow_r5art（发矮）/ch5lampdying_r5art（将熄）三张同机位亲验——灯碗与木凳灯座位置分毫不动，火苗由立直到矮半再到碗内残焰，递进成立。**结论：三态同盏同座、切换零跳位。**

## 双域验收图亲验

验收截图 9 张（docs/shots/，本轮自 /tmp/shots_r5art 归档）：title_r5art.png（标题五钮一行，第五章·守宫一夜在列）、ch5_r5art.png（正殿·现实）、ch5spirit_r5art.png（正殿·灵域）、ch5mid_r5art.png（宫埕·现实）、ch5midspirit_r5art.png（宫埕·灵域）、ch5east_r5art.png（后殿·现实）、ch5eastspirit_r5art.png（后殿·灵域）、ch5lamplow_r5art.png、ch5lampdying_r5art.png。逐张亲验：

- 物件落点与灵域灵核/判定点一致（灵域三张逐件核对：长明灯、添油壶、烛台、潮鼓、神轿、开道锣、纸扎人、夜粥摊、红桃粿盘、更梆、纸扎马、纸轿残件灵核均落在物件本体中心），无错位、无拉伸。
- 灵域呈冷青 SPIRIT_TINT 统一压色，现实/灵域同构图；夜粥摊老阿伯剪影级融入摊侧，与 manifest 口径一致；红桃粿盘灰粉压暗、与宫埕冷调并置不跳，manifest 的「引擎侧降饱和」预案未启用。
- DELIVERY_R5 未解决项①（标题/第五章 Xvfb 截图未取到）至此补齐销账。

## 验证

- 冒烟全量（集成轮，日志 docs/smoke_r5art.log）：**992 PASS / 0 失败 / 0 脚本错误**，与 DELIVERY_R5 基线一致、第一至四章零回归。日志时间 04:25 晚于 main.gd 最后修改 04:19，覆盖当前代码状态（本收尾轮复核确认）。
- 导出：按 R5 教训走 /tmp 导出（/tmp/yx5export）→ PCK 逐条目验包：199 个条目、MD5 全一致、第五章素材 10 文件（ctex＋.import）齐全 → 拷回 build-web → deploy/deploy_web.py 同址发布。脚本自验 GET / 200（7,661B）、index.js 200（331,495B）、index.wasm 200（35,376,909B 分片拼合）、index.pck 200（99,729,648B 分片拼合）。
- 独立复核（本轮 curl 下载线上三件套算 sha256，与本地导出逐字节一致）：
  - index.pck：99,729,648B，sha256 `b323e52863732044c2b748a3cde4698fc6d666ebdcd2cc1288146c916433bf1b`
  - index.wasm：35,376,909B，sha256 `fe5cebc590758c10bc4469be5a591e28edbde5ec8f458f21baeb83db50d028b9`
  - index.js：331,495B，sha256 `8b649683883a8be172e229a0479503d50cd5245ebf87aa71fda70bf720824075`

## 部署前后字节对照

| 文件 | 部署前（R5 灰盒包） | 部署后（SP 集成包） | 变化 |
|---|---|---|---|
| index.pck | 87,383,776 | 99,729,648 | +12,345,872（SP 素材入包） |
| index.wasm | 35,376,909 | 35,376,909 | 不变（同引擎构建，sha256 同上） |
| index.js | 331,495 | 331,495 | 不变（sha256 同上） |
| GET / | 200 | 200（7,661B） | 加载壳同前（patch_shell 幂等） |

未碰任何 musen-ai.com 域名，只动 yexun-ch1.musen-ai-9527.workers.dev。

## 未解决项

1. **发矮态浮光小注**：ch5lamplow 截图中灯碗上方有两点细小浮光（精灵火苗收小后的残晕与引擎 draw_glow 叠加，读作浮空火星）。非错位、非跳位；消除须素材侧改图或引擎侧在发矮/将熄态调低 glow 强度，本轮按「只收尾、不改逻辑」未动，留待后续表现轮次处置。
2. 沿 DELIVERY_R5 旧账：第五章音频线（宫内环境轨、新物件标志音、应答版尾音的素材层处理）未做；P-09（三炷香接力＋命运更新 3 次）与「净」来源演化待用户裁定（本章按稿现行文本上线）；真人试玩三问（第五章版）与真浏览器点击亲验未过（沿前四章口径）。
3. 红桃粿盘在宫埕段位于画面左下，无对白时全幅可见、对白框弹出时下缘被压（节点位置如此，属对白层遮挡常态，同四章轿绳担先例）。
