# 《夜巡》音频接线规格

以 `main@4c98d67` 的素材库存和 `game/main.gd` 实际调用为准。表内覆盖 `game/audio/` 的 60 个 WAV，其中 40 个由 `game/audio/tools/synth_audio_ch2_6.py` 生成，另外 20 个为既有素材。仓库内有 60 个对应的 `.wav.import`。

## 格式与混音

- 二至六章合成脚本输出 22050 Hz、单声道、16 位 PCM WAV。环境轨长 24 秒，合成时以 2.5 秒交叉淡化拼接循环；脚本的峰值参数是振幅上限，与 Godot 播放增益分别计算。
- 文件由 `get_stream(kind)` 按 `res://audio/<kind>.wav` 加载并缓存。新增或重制资源后，先从 `game/` 运行 Godot `--headless --import`，再导出。
- 表内 dB 为播放器增益。环境声走 `YXAmb`，激活轨为 −25 dB，非激活轨为 −60 dB。游戏进行中切换现实／灵域时，双轨在约 0.3 秒内按 dB 插值。换章或换场景时由 `set_ambience_pair()` 挂载对应素材并设为向前循环。
- 普通音效走 `YXFx`，默认 −3 dB、原始音高。独立爆响播放器也走 `YXFx`，播放器增益为默认 0 dB。设置菜单的两路总线音量叠加在上述增益上。

## 环境轨（13 件）

| 文件 | 实际触发点 | 播放增益 |
| --- | --- | --- |
| `amb_realm.wav` | 第一章及六章默认现实域；六章第一段重设默认对 | −25 dB |
| `amb_spirit.wav` | 第一章及六章默认灵域；六章第一段重设默认对 | −25 dB |
| `amb2_realm.wav` | 二章开局或续玩，现实域 | −25 dB |
| `amb2_spirit.wav` | 二章开局或续玩，灵域 | −25 dB |
| `amb3_realm.wav` | 三章默认现实域；离开后殿杂物间时恢复 | −25 dB |
| `amb3_spirit.wav` | 三章默认灵域；离开后殿杂物间时恢复 | −25 dB |
| `amb3_store.wav` | 三章附身后进入杂物间节点（旧香炉、木箱、纸轿残件、旧竹器、爆竹串），两域共用 | −25 dB |
| `amb4_realm.wav` | 四章开局或续玩，现实域 | −25 dB |
| `amb4_spirit.wav` | 四章开局或续玩，灵域 | −25 dB |
| `amb5_realm.wav` | 五章开局或续玩，现实域 | −25 dB |
| `amb5_spirit.wav` | 五章开局或续玩，灵域 | −25 dB |
| `amb6_alley.wav` | 六章进入或续玩第五段（西巷），两域共用 | −25 dB |
| `amb6_dawn.wav` | 六章进入或续玩第六段，且命运更新①已完成，两域共用 | −25 dB |

## 响器、应答与报到（14 件）

| 文件 | 实际触发点 | 播放增益 |
| --- | --- | --- |
| `bell.wav` | 一、二、四、五、六章神轿摇铃，三章钟；一章收束亦用铃，一章神轿部分动作 0.45 秒后再响；六章试图驱雾走普通铃 | −3 dB |
| `drum.wav` | 各章潮鼓普通操作；四章示警第三拍；六章桥头报到、西巷三件之一 | −3 dB |
| `gong.wav` | 二章开道锣、四至六章普通锣声；六章溪尾街与西巷报到。西巷报到条件未齐或响器重复时，改播闷响反馈 | 普通 −3 dB、音高 1.0；闷响 −6 dB、音高 0.8 |
| `answer_bell.wav` | `play_bell_low()` 的旧入口（结局钩子、二章神轿延迟 0.5 秒）；四章借嘴与五章交易中的轿铃或其他默认映射；五章承诺拍；六章神轿铃解桥头花灯之锢 | −3 dB，音高 1.0 |
| `answer_gong.wav` | 四章借嘴或五章交易时，触发响器为开道锣 | −3 dB，音高 1.0 |
| `answer_drum.wav` | 四章借嘴或五章交易时，触发响器为潮鼓；六章潮鼓解开道锣或花灯之锢 | −3 dB，音高 1.0 |
| `bridgebell.wav` | 四章桥铃示警第一拍 | −3 dB |
| `templebell.wav` | 六章土地庙铜铃交互及该站报到 | −3 dB |
| `deepgong.wav` | 六章西巷报到中深波锣有效计入三件时 | −3 dB |
| `sugong.wav` | 六章西巷有效响开道锣时，与 `gong.wav` 同点叠播 | −6 dB |
| `suona.wav` | 六章西巷三件齐后单独触发，与首遍 `report_half.wav` 同点播放 | 单独播放 −6 dB |
| `report_half.wav` | 六章西巷三件齐时首播，2.4 秒后再播一次 | 两次均 −3 dB |
| `report_full.wav` | 六章土地庙、溪尾街、桥头报到成功时调用 `play_report6()` | −3 dB |
| `crackers.wav` | 一至三章爆竹操作；`play_sound("crackers")` 同时启动震屏与 `boom.wav` | −3 dB |

应答按触发响器选择。素材本身已降基频，播放器无需再降调或叠加旧占位的 −13 dB。

## 交互和系统反馈（33 件）

| 文件 | 实际触发点 | 播放增益 |
| --- | --- | --- |
| `bang.wav` | 五章更梆操作 | −3 dB |
| `beam.wav` | 一、二、三章梁／竹木物件交互 | −3 dB |
| `boat.wav` | 四章船只交互 | −3 dB |
| `boom.wav` | 爆竹的附加爆响；二章结束时独立触发 | 0 dB，独立播放器 |
| `borrowmouth.wav` | 四章开启借嘴 | −3 dB |
| `bridgerope.wav` | 四章桥栏绳交互 | −3 dB |
| `candle.wav` | 一、三、五章烛台交互 | −3 dB |
| `doorring_clear.wav` | 六章旧宅门口已移灯后的第二叩及之后的清响 | −3 dB |
| `doorring_rust.wav` | 六章旧宅第一叩、未照亮时再叩及普通锈环反馈 | −3 dB |
| `everlamp.wav` | 五、六章长明灯交互 | −3 dB |
| `fate.wav` | 命运更新的通用反馈（由每帧检查相应演出状态时触发） | −5 dB |
| `flag.wav` | 一、二、三、六章标旗交互 | −3 dB |
| `horse.wav` | 纸扎马及复用该音效的纸扎人物、纸扎物交互 | −3 dB |
| `incense.wav` | 一、二、三、五、六章香炉类交互，三章含旧香炉，六章含小香炉重燃 | −3 dB |
| `jump.wav` | 成功跳附物件 | −7 dB |
| `kueh.wav` | 五章红桃粿盘交互 | −3 dB |
| `land.wav` | 附身动画中到达落点时 | −9 dB |
| `lantern.wav` | 一、二、四、六章花灯类交互，六章用于照街、照桥和移灯照门 | −3 dB |
| `loudspeaker.wav` | 一章扩音器交互 | −3 dB |
| `oilpot.wav` | 五章添油壶响盖 | −3 dB |
| `palanquin.wav` | 一、二、四、五、六章神轿互动中的轿体声，常与普通铃同点播放 | −3 dB |
| `papercargo.wav` | 四章三类新轿纸扎物料交互 | −3 dB |
| `porridge.wav` | 五章夜粥摊揭盖 | −3 dB |
| `rewind.wav` | 各章进入失败阶段；点香或开始指定段落；二至五章被对手挤出时复用 | 失败 −3 dB；点香／段落提示 −7 dB；挤出 −9 dB |
| `riverlamp.wav` | 四章河灯交互 | −3 dB |
| `sedanrope.wav` | 四章轿绳担交互及桥栏加固 | −3 dB |
| `shrine.wav` | 四章土地庙交互；六章土地庙小香炉重燃时叠在香火反馈上 | −3 dB |
| `sign.wav` | 六章成功完成最后一附 | −3 dB |
| `sticks.wav` | 一、三章签筒交互 | −3 dB |
| `trade.wav` | 五章普通交易成立，叠在所选响器的应答上 | −3 dB |
| `umbrella.wav` | 一、二章伞交互 | −3 dB |
| `waitstill.wav` | 五章段落开始或对手移站时进入静候 | −3 dB |
| `yieldcue.wav` | 五章普通交易成立，与响器应答和 `trade.wav` 同点播放 | −6 dB |

五章承诺拍单发 `answer_bell.wav`，不套用普通交易的三件叠音。六章西巷报到音序为逐件触发、三件齐播放半套并叠唢呐、2.4 秒后重复半套。土地庙、溪尾街与桥头的整套报到另走 `play_report6()`。

## 复核入口

- 环境轨：`start_ambience()`、`set_ambience_pair()`、`ch3_store_check()`、`seg6_begin()`、`continue_game6()`。
- 应答及交易：`play_answer()`、`answer_kind_for()`、`trade5_do()`。
- 报到：`trio_hit6()`、`play_report6()`。
- 本表核对素材库存和实际接线。混音响度、重复触发的听感、浏览器实际输出仍需试听。
