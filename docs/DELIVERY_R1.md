# 《夜巡》第一章切片 R1 交付说明

设计复核与Godot工程已完成；截图已于 R1 交付后补齐（见下「截图」段，2026-11-16 更新），并经 R2 独立审计目视＋像素核验属实。

复核结论：原稿图有10+2两个分量，伞/喇叭与主图不通；引线传火、移位后鞭炮可达、双物件终局顺序及NPC短暂窗口缺条件。详见 REVIEW_R1.md；其中所标「待主控裁定」的兼容处理已于 2026-11-16 由主控裁定 R1–R6 全部转正（设计稿 v1.1 修订记录）。R1/R2 阶段原件SHA256复验未变；此后 v1.1 修订为文末新增修订节＋正文括注，未改写 v1 原稿条文。

工程：game/project.godot、Main.tscn、main.gd、smoke.gd、font.ttc、audio/drum.wav、bell.wav、crackers.wav。单场景1280×720，12物件灰盒、标题/教学/自由探索/点香、双域、附身图、一物一技、底框对白、两次命运更新、两解通关、错误失败自动回溯、三文本恐怖钩子及合成音效已接线。

启动：
```sh
~/workspace/tools/godot/Godot_v4.3-stable_linux.x86_64 --path ~/workspace/yexun/game
```
Enter或点击开始；Tab切灵域/现实，灵域点击相邻物件跳跃，现实E施技；香炉教学后F进入一炷香前。1/4切倍率；默认240剧情秒，启动可追加 `-- --time-scale=4`。失败5秒后自动回香点，Enter可提前重试。不存档。

自动验证：main.gd、smoke.gd逐文件check-only通过；最终 smoke_r1.log 为 PASS checks=252 failures=0，包含正解、备选、鼓三下、自动重试、12节点实际双向可达、捡签窗口、时间暂停/超时及探索点香重置。独立审读见 AUDIT_R1.md（该审读采样时241项；最终扩展至252项）。无头主场景启动见 startup_r1.log。

冒烟复跑：
```sh
~/workspace/tools/godot/Godot_v4.3-stable_linux.x86_64 --headless --path ~/workspace/yexun/game --script res://smoke.gd > ~/workspace/yexun/docs/smoke_r1.log 2>&1
```

截图：R1 交付时因 Xvfb 显示套接字失败未完成（详见 capture_r1.log，保留为先失败记录）；随后已补截成功——docs/shots/{spirit,reality,ending}_r1.png 三张 1280×720 真实 Godot viewport 抓图齐备，成功记录见 docs/work/capture_main.log，R2 独立审计（AUDIT_R2.md §6）已逐张目视并核对尺寸/字节数/像素统计，确认与工程相符。未伪造图片。

2026-11-16 主控裁定落地：兼容处理 R1–R6 已全部转正定版（设计稿 DESIGN_CH1_SLICE.md 文末「v1.1 修订记录」）；R5 花灯调查文本已改为明示绳结断口/割痕线索，章末回收保留。复跑冒烟见 smoke_r2.log。

未完成：有渲染窗口的真人交互验收、实际扬声器听验；真人盲玩三问。未扩展第二章，无美术精修、无存档。
