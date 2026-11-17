# 《夜巡》第二章 SP 素材集成台账（2026-11-17）

承 DELIVERY_R2.md 未解决项：SP 素材包（manifest 第二章小节 14 件）已按 OBJ_ART2/CHAR_ART2 接口全量替换灰盒占位，不改玩法逻辑与设计。线上同址：https://yexun-ch1.musen-ai-9527.workers.dev/

## 逐件替换对照（灰盒占位 → SP 素材）

标定口径沿第一章：spec[2]=alpha 包围盒高占比、spec[3]=包围盒底边占比−0.5（第一章 16 件逐件反推吻合）；spec[4] 按「保灰盒内容中心偏移」解算，使灵核/判定点与视觉中心相对位置不变；角色 spec[3] 按「保灰盒落脚偏移」解算。

| 接口 id | 游戏文件 | SP 源 | target_h | spec[2] | spec[3] | spec[4] | 备注 |
|---|---|---|---|---|---|---|---|
| censer | obj_smallcenser.png | obj_incense_small.png | 120 | 0.925 | 0.443 | 14 | 直接替换 |
| vat | obj_vat.png | obj_watervat.png | 110 | 0.873 | 0.453 | 23 | 直接替换 |
| teasign | obj_teasign.png | obj_signboard.png | 170 | 0.986 | 0.486 | −13 | 横匾实测屏宽约 339px，与底板空招牌位相称 |
| paperfig | obj_paperfig.png | obj_paperman.png | 190 | 0.986 | 0.494 | 12 | 本体图已抹原头（颈上 316px 起羽化擦除），头部由拆分件接管；spec 按整 figure 标定 |
| minisedan | obj_minisedan.png | obj_sedan_small.png | 120（原灰盒 150） | 0.98 | 0.49 | 9 | 见下「小轿裁切」；高度下调因长杠使总幅宽过大、轿体不得大于神轿 |
| minisedan 灵域 | obj_minisedan_spirit.png（新增） | obj_sedan_small_spirit.png | 同上 | 同上 | 同上 | 同上 | 灵域切专用贴图（自带冷青＋帘缝暗红灵核），该物件灵域下不再叠 SPIRIT_TINT |
| gong | obj_gong.png | obj_gong.png | 150 | 0.908 | 0.462 | 14 | 直接替换 |
| ayong | char_ayong.png | char_ayong.png | 180 | 0.973 | 0.380 | — | 落脚偏移与灰盒一致 |
| lianshen | char_lianshen.png | char_lianshen.png | 168 | 0.979 | 0.380 | — | 同上 |
| xishu | char_xishu.png | char_xishu.png | 172 | 0.999 | 0.377 | — | 同上 |
| backview | char_backview.png | char_bearer_shadow.png | 178 | 0.987 | 0.373 | — | 同上 |

复用第一章素材（lampstand/umbrella/crackers/palanquin/flag/drum 与四名旧角色）未动。

## 底板适配（已知适配点①）

SP 底板实测 2172×724（≈3:1），舞台 2560×720。**选「等比缩放补幅（cover-fit）」**：sync_art 第二章分支改为均匀缩放 max(2560/W, 720/H)=1.1786，上下各裁约 67px（雾空与前景路面），理由：零拉伸变形、零逻辑坐标改动（站位映射收拢需改十余处硬编码站位且压缩街道间距；边缘延展会在土地庙/桥头两个必访边缘造镜像赝影）。截图亲验：月亮、屋脊、街面均完整，无露馅。

## 小轿裁切（已知适配点②）

按两变体 alpha 包围盒并集＋边距取公共裁框 (60,25)–(2110,695)，两图同框裁至 2050×670，保证现实/灵域版像素对齐后再定锚点（spec 见上表）。

## 纸扎人头部雷达

- 头部拆分件 obj_paperfig_head.png 作本体精灵子节点：相对缩放 0.305、支点＝颈座（本体局部 (−7,−442)，头部贴图 offset (−1.5,569)），几何经像素量测校准（颈座底与本体颈环中段重合）。
- 转向：每帧按轿中客所在物件的水平方向平滑倾斜（clamp ±0.30 rad，lerp 0.08），双域均生效（活体雷达本就该在现实域可见）；本体为正面头，横翻不成立，倾斜是唯一可读的 2D 转向语言。
- **灵域红指向线已撤**：头部朝向＋被占物件的暗红灵核＋脉动红环三者已足够定位对手，红线与头部信息重复且出戏。截图（东段灵域）亲验：无红线时潮鼓的暗红核＋红环仍一眼可辨。

## 验证

- 冒烟全量重跑：**403 PASS / 0 失败**（第一章 252 项零回归），日志 docs/smoke_r2art.log。
- 验收截图（docs/shots/）：ch2_r2art.png（西段·现实）、ch2spirit_r2art.png（西段·灵域）、ch2east_r2art.png（东段·现实）、ch2eastspirit_r2art.png（东段·灵域）、zoom_paper_1x.png（纸扎人头部贴合放大）、zoom_sedan_spirit.png（小轿灵域版帘缝暗红灵核放大）。逐张亲验：无错位、无拉伸、灵核与判定点一致、风格与第一章统一。为东段验收在 capture_scene 增 ch2east/ch2eastspirit 两个截图种类（仅工具代码）。
- 部署：Web 导出 → deploy/deploy_web.py 同址发布；线上 GET /、index.wasm（35,376,909B 分片拼合）、index.pck（55,236,272B）、index.js 均 200 且字节与本地一致。未碰任何 musen-ai.com 域名。

## 未解决项

- 沿 DELIVERY_R2 旧账：街道环境轨「远队伍人声层」未做（仍用第一章双域环境轨）；真人试玩三问（第二章版）与真浏览器点击亲验未过。
- 纸扎人双足悬于纸扎店展架横木前（沿灰盒落点，底板该处有展架立柱，读作陈列姿态）；若试玩反馈突兀，可下调其 spec[4] 落地。
