# 《夜巡》第三章 SP 素材集成台账（2026-11-17）

承 DELIVERY_R3.md 未解决项：SP 素材包（manifest 第三章小节 17 件）已按 OBJ_ART3/CHAR_ART3 接口全量替换灰盒占位，不改玩法逻辑与设计。线上同址：https://yexun-ch1.musen-ai-9527.workers.dev/

## 逐件替换对照（灰盒占位 → SP 素材）

标定口径沿前两章（DELIVERY_R2_ART 同法）：spec[2]=alpha 包围盒高占比、spec[3]=包围盒底边占比−0.5；spec[4] 按「保灰盒内容中心偏移」解算（解算前后中心偏移误差 ≤0.1px，脚本自验）；角色 spec[3] 按「保灰盒落脚偏移」解算；target_h 全部沿灰盒值不变。

| 接口 id | 游戏文件 | SP 源 | target_h | spec[2] | spec[3] | spec[4] |
|---|---|---|---|---|---|---|
| hallcenser | obj3_hallcenser.png | obj_altar.png | 160 | 0.972 | 0.481 | 19.7 |
| roster | obj3_roster.png | obj_register.png | 190 | 0.982 | 0.493 | 19.3 |
| bell | obj3_bell.png | obj_bell.png | 180 | 0.983 | 0.492 | 25.8 |
| teatable | obj3_teatable.png | obj_teatable.png | 130 | 0.860 | 0.438 | 49.3 |
| oldcenser | obj3_oldcenser.png | obj_incense_old.png | 120 | 0.915 | 0.465 | 60.3 |
| chest | obj3_chest.png | obj_chest.png | 140 | 0.927 | 0.469 | 29.5 |
| sedanrem | obj3_sedanrem.png | obj_sedan_wreck.png | 170 | 0.937 | 0.462 | 23.9 |
| bamboo | obj3_bamboo.png | obj_bamboo.png | 170 | 0.971 | 0.479 | 21.5 |
| liushu | char3_liushu.png | char_liushu.png | 178 | 0.984 | 0.455 | — |
| shuisheng | char3_shuisheng.png | char_shuisheng.png | 172 | 0.970 | 0.457 | — |
| keeper | char3_keeper.png | char_keeper.png | 168 | 0.989 | 0.454 | — |
| member_a（新增精灵） | char3_member_a.png | char_member_a.png | 172 | 0.947 | 0.458 | — |
| member_b（新增精灵） | char3_member_b.png | char_member_b.png | 170 | 0.966 | 0.450 | — |

复用件（flag/drum/crackers/horse 与阿澄/小英/阿勇/阿弟）未动。纸扎马雷达沿第二章方案：本章无头部拆分件，马身倾斜（±0.16 rad）＋被占物件暗红核＋红圈，未改。

队员甲乙说明：灰盒层二人仅存在于对白、无占位精灵，本轮按素材包交付新增为纯视觉 NPC（CHAR_ART3 增两条＋第三章站位表增两条默认站位：甲 (680,494)、乙 (750,466)，候队于正厅前坪人群内），不触碰任何玩法/对白/判定逻辑。截图亲验二人入群自然、无遮挡关键物件。

## 底板适配（已知适配点）

SP 底板 1672×941 为单屏幅，第三章舞台为 2560 长卷（A/B 双场景各 1280×720 拼接）。**选「按场景分幅 cover-fit」**：sync_art 第三章分支对 bg3a/bg3b 各自按 max(1280/W, 720/H) 均匀缩放（实测系数 0.7656，纵向裁约 0.4px、横向恰满），每幅独立盖满自己半屏。理由：①底板本身即按单屏构图交付（A 板=正厅＋前坪、B 板=廊下＋杂物间），与双场景拼接一一对应，无需跨幅拼接或边缘延展；②1672×941 与 1280×720 宽高比仅差 0.07%，cover-fit 近乎无裁切、零拉伸；③逻辑坐标、站位、镜头平移全部不动。截图亲验：双场景×双域四幅均满屏无黑边、无变形，A 板右侧敞门前坪与 B 板左缘廊下在接合部（x=1280）视觉连续。

## 验证

- 冒烟全量重跑：**583 PASS / 0 失败**（第一、二章 403 项零回归＋第三章 180 项），日志 docs/smoke_r3art.log。
- 验收截图（docs/shots/）：ch3_r3art.png（A·现实）、ch3spirit_r3art.png（A·灵域）、ch3b_r3art.png（B·现实）、ch3bspirit_r3art.png（B·灵域），另 ch1_r3art.png（第一章查漏）。逐张亲验：物件落点/灵核与判定点一致、无错位、无拉伸；灵域截图中对手暗红核＋红圈在竹器（B）/纸扎马（A）处可辨、纸扎马雷达倾斜生效；第一章画面无第三章精灵漏出。
- 部署：Web 导出 → deploy/deploy_web.py 同址发布；脚本自验 GET / 200（7,661B）、index.js 200（331,495B）、index.wasm 200（35,376,909B 分片拼合）、index.pck 200（76,760,256B 分片拼合）；主控独立 curl 下载复核：pck/wasm 的 sha256 与本地导出逐字节一致。未碰任何 musen-ai.com 域名。

## 未解决项

- 沿 DELIVERY_R3 旧账：杂物间环境轨（灵域轨压暗＋纸料摩擦底噪）未做，仍用既有双域环境轨；真人试玩三问（第三章版）与真浏览器点击亲验未过。
- 茶桌精灵大半被六叔公站位遮挡（节点环与人物为视觉主体），属站位构图常态；若试玩反馈读不清茶桌本体，可微调六叔公默认站位 x+30。
