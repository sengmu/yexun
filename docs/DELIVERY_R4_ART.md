# 《夜巡》第四章 SP 素材集成台账（2026-11-17）

承 DELIVERY_R4.md 未解决项：SP 素材包（manifest 第四章小节 12 文件）已按 OBJ_ART4/CHAR_ART4 接口全量替换灰盒占位，不改玩法逻辑与设计。线上同址：https://yexun-ch1.musen-ai-9527.workers.dev/

## 逐件替换对照（灰盒占位 → SP 素材）

标定口径沿前三章（DELIVERY_R2_ART/R3_ART 同法）：spec[2]=SP 图 alpha 包围盒高占比、spec[3]=包围盒底边占比−0.5；spec[4] 按「保灰盒内容中心偏移」解算（脚本解算误差 0.000px）；角色 spec[3] 按「保灰盒落脚偏移」解算；target_h 全部沿灰盒值不变。

| 接口 id | 游戏文件 | SP 源 | target_h | spec[2] | spec[3] | spec[4] |
|---|---|---|---|---|---|---|
| shrine | obj4_shrine.png | obj_shrine_bridge.png | 150 | 0.827 | 0.424 | 10.7 |
| bridgebell | obj4_bridgebell.png | obj_bridge_bell.png | 140 | 0.856 | 0.457 | −2.3 |
| bridgerope | obj4_rope.png | obj_bridge_rope.png | 90 | 0.787 | 0.414 | 7.0 |
| bridgerope·加固态 | obj4_rope_fixed.png（新增） | obj_bridge_rope_fixed.png | 同上 | 同上 | 同上 | 同上 |
| sedanrope | obj4_sedanrope.png | obj_rope_carry.png | 130 | 0.841 | 0.435 | 21.4 |
| papercargo | obj4_papercargo.png | obj_paper_carry.png | 140 | 0.710 | 0.417 | −1.9 |
| riverlamp | obj4_riverlamp.png | obj_river_lamp.png | 150 | 0.980 | 0.488 | 27.8 |
| boat | obj4_boat.png | obj_ferry.png | 110 | 0.464 | 0.327 | −23.2 |
| dengjiang | char4_dengjiang.png | char_dengjiang.png | 172 | 0.967 | 0.510 | — |

复用件（lampstand/drum/palanquin/gong/paperfig＋头部拆分件与 8 名复用角色）未动；船工剪影占位 char4_ferryman 按 manifest 口径无 SP 精灵、保持不变。

底板：bg4_realm.png ← bg_bridge_realm.png、bg4_spirit.png ← bg_bridge_spirit.png（2172×724）。

剧情道具新引路轿（obj_sedan_new.png → game/art/obj4_sedannew.png）：灰盒层无占位精灵（仅对白与 flags.newsedan_done），本轮按第三章队员甲乙先例新增纯视觉道具精灵（SEDAN_NEW_POS=(2330,535) 河埠棚下、SEDAN_NEW_SPEC 按包围盒标定 th=100/0.907/0.452/0），sync_art 第四章分支在 newsedan_done 后点亮、随 cam_x 平移、灵域下叠 SPIRIT_TINT。不入附身图、不触碰任何判定/对白/存档逻辑。截图亲验：素白新轿供在渡口边，与神轿形制区分明确。

## 已知适配点处理

1. **底板 2172×724（3:1）对 2560 长卷**：沿第二章 cover-fit（sync_art 第四章分支既有实现 max(2560/W, 720/H)=1.1786，上下各裁约 67px 雾空与前景水面），零拉伸、零逻辑坐标改动。截图亲验：桥面、棚屋、远山完整，无露馅；底板桥栏为完好木栏、无任何断口（防剧透口径成立，断口只在桥栏绳精灵与调查文本上）。
2. **桥栏绳双态对位**：两态同尺寸同柱位出图，接入共用同一 spec，sync_art 在通用物件循环内按 flags.reinforced 换图（沿第二章 minisedan 换图先例）。同机位双态截图（ch4rope/ch4fixed）像素差分：差异仅限绳体带（屏 x 475–803、y 292–381），两端木柱（屏 x≈455／790）像素级同位、切换无跳位；原态中段崩丝割口清晰可辨，加固态割口被三层绳包完全覆盖、绳身绷直。
3. **铜铃木柱 vs 底板石栏**：按台账口径作桥头系铃独立小构件——精灵木柱自带短桩立于桥头坪，与底板石栏并置不冲突，截图亲验读作系铃桩、无违和。
4. **渡船朝向**：SP 图船头朝右，节点在东端渡口（2450,545），船身没入右缘水面、渡索横向出画，与构图口径一致，未翻转。

## 借嘴态表现复核

纸扎人复用二章精灵＋头部拆分件，借嘴态为引擎层表现（头停转＋暗红核＋金色双环纹）。专用截图 ch4bm（灵域，强制借嘴态）：放大图 zoom_bm_r4art.png 亲验——纸扎人头部正对前方不倾斜、灵核暗红、外圈金色双环纹（r=15/20）清晰可辨，与普通占位态（ch4eastspirit：暗红核＋单红脉动环、无金环）一眼可分。借嘴态成立。

## 验证

- 冒烟全量重跑：**787 PASS / 0 失败 / 0 脚本错误**（与集成前基线 smoke_r4art_base.log 逐项一致，第一至三章零回归），日志 docs/smoke_r4art.log。
- 验收截图（docs/shots/）：ch4_r4art.png（桥头·现实）、ch4spirit_r4art.png（桥头·灵域）、ch4east_r4art.png（河埠·现实）、ch4eastspirit_r4art.png（河埠·灵域）、ch4rope_r4art.png（桥栏绳·原态）、ch4fixed_r4art.png（桥栏绳·加固态）、ch4bm_r4art.png＋zoom_bm_r4art.png（借嘴态）、ch4sedan_r4art.png（新引路轿）、zoom_rope_r4art.png／zoom_ropefixed_r4art.png（双态局部）。逐张亲验：物件落点/灵核与判定点一致、无错位、无拉伸。为验收在 capture_scene 增 ch4rope/ch4fixed/ch4bm/ch4sedan 四个截图种类（仅工具代码，沿第二章先例）。
- 部署：Web 导出 → deploy/deploy_web.py 同址发布；脚本自验 GET / 200（7,661B）、index.js 200（331,495B）、index.wasm 200（35,376,909B 分片拼合）、index.pck 200（87,306,304B 分片拼合）；主控独立 curl 下载复核：pck/wasm/js 的 sha256 与本地导出逐字节一致（pck ec57c8b8…、wasm fe5cebc5…、js 8b649683…）。未碰任何 musen-ai.com 域名。

## 未解决项

- 沿 DELIVERY_R4 旧账：桥头/河埠环境轨（河水层）、7 件新物件标志音、借嘴声与应答版尾音未做，仍用既有双域环境轨与近似音（属音频线，非本轮范围）。
- P-10 待用户确认（点破段按稿现行文本上线，本轮未动对白）。
- 真人试玩三问（第四章版）与真浏览器点击亲验未过（沿前三章口径）。
- 轿绳担精灵横幅较宽（屏约 464px），下缘在开场对白框弹出时部分被压，属对白层遮挡常态；无对白时全幅可见（ch4rope 图左下可见其 pole＋绳捆）。
