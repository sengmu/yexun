# 《夜巡》二至六章音频接线规格表（AUDIO_WIRING）

生产：2026-11-17，合成脚本 `game/audio/tools/synth_audio_ch2_6.py`（沿第一章 `synth_audio.py` 本地合成体系：numpy/scipy 程序合成，零外部素材、零人声台词；人声层只有无词远人声氛围质感）。本表只给接线规格，**未改任何代码**；集成轮按本表改 `game/main.gd` 后须跑一次 Godot 导入（`--headless --import`）为新 wav 生成 `.wav.import`/uid，否则导出包不含新音（`get_stream()` 以 `res://audio/<name>.wav` 加载）。

## 0. 全局规格（与第一章一致）

- 格式：22050 Hz、单声道、16-bit WAV；文件直落 `game/audio/`，命名沿既有短名约定（`get_stream(kind)` 的 kind 即文件名去后缀）。
- 响度口径：环境轨 24.0s 无缝循环（2.5s 交叉淡化收尾回环）、峰值 ≤0.62、RMS 约 −18~−22 dB，经既有 `amb_players` 以 `AMBIENT_DB = -25.0` 播放、双域 0.3s 交叉淡入淡出（`start_ambience()`/`amb_targets` 机制不变）。FX 峰值 0.6~0.85，经 `play_fx(kind, db)` 以 `FX_DB = -3.0` 为默认播放；下表「播放音量」列的 dB 均为传给 `play_fx` 的参数（默认即 −3.0 不另注）。
- QA（全件实测）：削波 0、DC 偏移 ≤0.002、FX 尾音（末 50ms RMS）≤ −30 dB（自然衰减收尾）、环境轨循环接缝差 ≤0.025（与一章 amb_realm 的 0.041 同级或更优）。

## 1. 系统级替换（占位 → 正式）

| # | 占位现状（代码位置） | 正式文件 | 接线法 | 播放音量 |
|---|---|---|---|---|
| 1 | `play_gong()`（main.gd L2687）：`get_stream("drum")` + `pitch_scale=0.55` —— 开道锣一直用潮鼓降调占位 | `gong.wav`（1.80s，峰值 0.80，质心 471Hz） | `play_gong()` 改为 `get_stream("gong")`、`pitch_scale=1.0`。全部调用点自动生效：`act_sound2()` 的 else 分支（二章）、act5 `"gong"`、act6 `"gong"` 非报到路径。例外：`trio_hit6()` 的「闷响」反馈拍仍调 `play_gong()`，建议集成时给 `play_gong(db=-6.0, pitch=0.8)` 加可选参数专供该拍，勿与正式锣声同响度 | FX_DB |
| 2 | `play_bell_low()`（L1432）：`bell.wav` + `pitch_scale=0.62` + `volume_db=-13.0` —— 应答版一直是降调近似 | `answer_bell.wav`（2.00s）/`answer_gong.wav`（2.40s）/`answer_drum.wav`（1.60s），三件同规格：低一档基频、长尾（tau 0.62~1.1）、软起音、峰值 0.62 | 新增 `play_answer(kind)`：按触发物件选件（神轿/轿铃→answer_bell、开道锣→answer_gong、潮鼓→answer_drum），`pitch_scale=1.0`。`play_bell_low()` 改为转调 `play_answer("bell")` 作兼容。逐点替换见 §3 | FX_DB（文件本身已低一档，不再叠 −13dB） |
| 3 | `play_report6()`（report6 L4383 之后）：`drum+gong+b
...[truncated 7899 chars]