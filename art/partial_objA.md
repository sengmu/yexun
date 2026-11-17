# 《夜巡》物件精灵 A 组（6 件）— 生成记录

通道：Codex 池 GPT 生图（image_gen / gpt-image-2），风格锚 concept_03_scene_ch1_SP.png（手绘 2D、低饱和灰蓝雾调、梦境柔光、水彩薄厚涂、侧视角、光从上左）。每件单物件居中、无人无其他物件、图内无文字。alpha 均经 python3 PIL 实测（mode 含 A、alpha 最小值 <10、透明像素占比 >5%），并合成到纯色底实测无光晕残留。

| 文件名 | 尺寸（PIL 实测） | alpha 状态 | 重Roll次数 |
|---|---|---|---|
| obj_incense.png | 1199x1312 | 真透明 | 0 |
| obj_sign.png | 1024x1536 | 真透明 | 1 |
| obj_candle.png | 1536x1024 | 真透明 | 0 |
| obj_drum.png | 1086x1448 | 真透明 | 0 |
| obj_sedan.png | 1774x887 | 真透明 | 0 |
| obj_flag.png | 887x1774 | 真透明 | 0 |

备注：
- obj_sign.png 首版合成检查时疑似带半透明光晕，重 Roll 1 次后定版；最终版合成到 #26303c 纯色底实测边缘干净、无光晕。
- obj_flag.png 旗面完全留空、无字无徽记，符合要求。
- obj_sedan.png 为组内最大幅面（1774 宽），雕花描金＋轿帘＋双抬杠齐全，无文字。
- 6 件全部真透明，无一件降级为纯色底，无「需抠图」项。
