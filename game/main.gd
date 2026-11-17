extends Node2D

var phase = "title"
var current = "incense"
var spirit = true
var flags: Dictionary = {}
var remaining = 240.0
var time_scale = 1.0
var failure_wait = 0.0
var pickup_left = 0.0
var dialogue = ""
var speaker = "阿澄"
var history: Array[String] = []
var seen_tips: Dictionary = {}
var font: Font
var bg_sprite: Sprite2D
var bg_tex_realm: Texture2D
var bg_tex_spirit: Texture2D
var obj_sprites: Dictionary = {}
var char_sprites: Dictionary = {}
var hover_id = ""
var force_touch = false
var npc_pos: Dictionary = {}
var npc_walking: Dictionary = {}
var mz_queue: Array = []
var mz_trip_started = false
var crackers_vis = Vector2(870, 230)
var crackers_snap = true
var obj_anim_id = ""
var obj_anim_t = -1.0
var spark_t = -1.0
var spark_pos = Vector2.ZERO
var card_idx = 0
var kv_tex: Texture2D
var hook_sedan: Sprite2D
var ending_t = -1.0
var hook_bell_done = false
var save_data: Dictionary = {}
var has_save = false
var save_tick = 0.0
var paused = false
var vol_amb = 0.8
var vol_fx = 0.9
var vol_mute = false
var drag_slider = ""
var chapter = 1
var cam_x = 0.0
var prev_current = "incense"
var home_nodes: Dictionary = {}
var home_graph: Dictionary = {}
var obj_sprites2: Dictionary = {}
var bg2_tex_realm: Texture2D
var bg2_tex_spirit: Texture2D
var minisedan_tex: Texture2D
var minisedan_spirit_tex: Texture2D
var paper_head: Sprite2D
var paper_head_tilt = 0.0
var opp_seq = ["paperfig", "minisedan", "palanquin", "gong", "drum", "minisedan"]
var opp_idx = 0
var opp_pos = ""
var opp_timer = 45.0
var clean: Dictionary = {}
var window_left = 0.0
var sedan_stay = 0.0
var sedan_attempts = 0
var fail_kind = ""
var has_save2 = false
var save_data2: Dictionary = {}
const SAVE_KEY2 = "yexun_ch2_save_v1"
const CH2_NODES = {
 "censer": ["土地公小香炉", "火星上窜", Vector2(110,330)],
 "lampstand": ["花灯担", "亮／举高", Vector2(300,300)],
 "vat": ["大水缸", "水面泛涟漪", Vector2(560,430)],
 "teasign": ["顺兴招牌", "吱呀晃动", Vector2(600,215)],
 "umbrella": ["油纸伞", "开伞", Vector2(790,470)],
 "paperfig": ["纸扎人", "头转向", Vector2(1010,330)],
 "crackers": ["鞭炮串", "燃放", Vector2(1180,250)],
 "minisedan": ["小轿", "掀帘", Vector2(1420,400)],
 "palanquin": ["神轿（大老爷）", "轻晃→轿铃响", Vector2(1700,390)],
 "flag": ["标旗", "旗面抖响", Vector2(1900,260)],
 "drum": ["潮鼓", "响一声", Vector2(2050,420)],
 "gong": ["开道锣", "响一声", Vector2(2380,330)]
}
const CH2_GRAPH = {
 "censer": ["lampstand","palanquin"], "lampstand": ["censer","vat","teasign","palanquin"],
 "vat": ["lampstand","teasign","umbrella","paperfig"], "teasign": ["lampstand","vat"],
 "umbrella": ["vat","paperfig"], "paperfig": ["vat","umbrella","crackers","minisedan"],
 "crackers": ["paperfig","minisedan"], "minisedan": ["paperfig","crackers","palanquin","flag"],
 "palanquin": ["censer","lampstand","minisedan","flag","drum"],
 "flag": ["palanquin","drum","gong","minisedan"], "drum": ["palanquin","flag","gong"],
 "gong": ["flag","drum"]
}
const OBJ_ART2 = {
 "censer": ["obj_smallcenser.png", 120.0, 0.925, 0.443, 14.0],
 "lampstand": ["obj_lantern.png", 130.0, 0.996, 0.496, 0.0],
 "vat": ["obj_vat.png", 110.0, 0.873, 0.453, 23.0],
 "teasign": ["obj_teasign.png", 170.0, 0.986, 0.486, -13.0],
 "umbrella": ["obj_umbrella.png", 150.0, 0.966, 0.486, 15.0],
 "paperfig": ["obj_paperfig.png", 190.0, 0.986, 0.494, 12.0],
 "crackers": ["obj_firecracker.png", 200.0, 0.968, 0.484, -5.0],
 "minisedan": ["obj_minisedan.png", 120.0, 0.98, 0.49, 9.0],
 "palanquin": ["obj_sedan.png", 165.0, 0.968, 0.483, 10.0],
 "flag": ["obj_flag.png", 205.0, 0.943, 0.472, -15.0],
 "drum": ["obj_drum.png", 135.0, 0.877, 0.442, 30.0],
 "gong": ["obj_gong.png", 150.0, 0.908, 0.462, 14.0]
}
const CHAR_ART2 = {
 "ayong": ["char_ayong.png", 180.0, 0.973, 0.380],
 "lianshen": ["char_lianshen.png", 168.0, 0.979, 0.380],
 "xishu": ["char_xishu.png", 172.0, 0.999, 0.377],
 "backview": ["char_backview.png", 178.0, 0.987, 0.373]
}
var bg3a_sprite: Sprite2D
var bg3b_sprite: Sprite2D
var bg3a_tex_realm: Texture2D
var bg3a_tex_spirit: Texture2D
var bg3b_tex_realm: Texture2D
var bg3b_tex_spirit: Texture2D
var obj_sprites3: Dictionary = {}
var opp3_seq = ["horse", "bamboo", "drum", "bell", "teatable"]
var opp3_idx = 0
var opp3_pos = ""
var opp3_timer = 45.0
var clean3: Dictionary = {}
var squeezed3: Dictionary = {}
var jump_count = 0
var last_skill = ""
var window3_left = 0.0
var keeper_out = false
var last_adv_mode = ""
var fake_from = Vector2.ZERO
var fake_to = Vector2.ZERO
var fake_t = -1.0
var has_save3 = false
var save_data3: Dictionary = {}
const SAVE_KEY3 = "yexun_ch3_save_v1"
const CH3_NODES = {
 "hallcenser": ["祠堂香案", "火星上窜", Vector2(200,380)],
 "roster": ["巡境名册", "翻页", Vector2(430,320)],
 "bell": ["祠堂铜钟", "响一声", Vector2(640,300)],
 "teatable": ["工夫茶桌", "茶盖轻响", Vector2(850,400)],
 "flag": ["标旗", "旗面抖响", Vector2(1060,280)],
 "drum": ["潮鼓", "响一声", Vector2(1190,430)],
 "oldcenser": ["后殿旧香炉", "余烬微光", Vector2(1470,380)],
 "chest": ["旧木箱", "箱盖轻响", Vector2(1700,430)],
 "sedanrem": ["纸轿残件", "掀布", Vector2(1980,350)],
 "bamboo": ["旧竹器", "轻晃", Vector2(2190,300)],
 "crackers": ["鞭炮串", "燃放", Vector2(2400,260)],
 "horse": ["纸扎马", "头转向", Vector2(1305,520)]
}
const CH3_GRAPH = {
 "hallcenser": ["roster","bell","teatable","oldcenser"],
 "roster": ["hallcenser","bell","teatable"],
 "bell": ["hallcenser","roster","teatable","drum"],
 "teatable": ["hallcenser","roster","bell","flag"],
 "flag": ["teatable","drum","horse"],
 "drum": ["bell","flag","horse"],
 "sedanrem": ["bamboo","chest","horse"],
 "bamboo": ["sedanrem","chest","crackers"],
 "chest": ["sedanrem","bamboo","oldcenser"],
 "oldcenser": ["chest","crackers","hallcenser"],
 "crackers": ["bamboo","oldcenser","horse"],
 "horse": ["sedanrem","crackers","flag","drum"]
}
const OBJ_ART3 = {
 "hallcenser": ["obj3_hallcenser.png", 160.0, 0.972, 0.481, 19.7],
 "roster": ["obj3_roster.png", 190.0, 0.982, 0.493, 19.3],
 "bell": ["obj3_bell.png", 180.0, 0.983, 0.492, 25.8],
 "teatable": ["obj3_teatable.png", 130.0, 0.860, 0.438, 49.3],
 "flag": ["obj_flag.png", 205.0, 0.943, 0.472, -15.0],
 "drum": ["obj_drum.png", 135.0, 0.877, 0.442, 30.0],
 "oldcenser": ["obj3_oldcenser.png", 120.0, 0.915, 0.465, 60.3],
 "chest": ["obj3_chest.png", 140.0, 0.927, 0.469, 29.5],
 "sedanrem": ["obj3_sedanrem.png", 170.0, 0.937, 0.462, 23.9],
 "bamboo": ["obj3_bamboo.png", 170.0, 0.971, 0.479, 21.5],
 "crackers": ["obj_firecracker.png", 200.0, 0.968, 0.484, -5.0],
 "horse": ["obj_horse.png", 175.0, 0.979, 0.485, 20.0]
}
const CHAR_ART3 = {
 "liushu": ["char3_liushu.png", 178.0, 0.984, 0.455],
 "shuisheng": ["char3_shuisheng.png", 172.0, 0.970, 0.457],
 "keeper": ["char3_keeper.png", 168.0, 0.989, 0.454],
 "member_a": ["char3_member_a.png", 172.0, 0.947, 0.458],
 "member_b": ["char3_member_b.png", 170.0, 0.966, 0.450]
}
var bg4_tex_realm: Texture2D
var bg4_tex_spirit: Texture2D
var bridgerope_tex: Texture2D
var bridgerope_fixed_tex: Texture2D
var everlamp_tex: Texture2D
var everlamp_low_tex: Texture2D
var everlamp_dying_tex: Texture2D
var sedan_new_sprite: Sprite2D
var obj_sprites4: Dictionary = {}
var paper_head4: Sprite2D
var paper_head4_tilt = 0.0
var opp4_seq = ["paperfig", "lampstand", "bridgebell", "gong", "drum"]
var opp4_idx = 0
var opp4_pos = ""
var opp4_timer = 45.0
var clean4: Dictionary = {}
var squeezed4: Dictionary = {}
var bm_active = false
var bm_round = 0
var bm_window_open = false
var bm_window = 0.0
var bm_gap = 0.0
var bm_teach_used = false
var bm_first_done = false
var has_save4 = false
var save_data4: Dictionary = {}
const SAVE_KEY4 = "yexun_ch4_save_v1"
const BM_FRAGS = ["把我的路……", "宫门……土地庙……溪尾街……桥头……", "那年……"]
const CH4_NODES = {
 "shrine": ["桥头土地龛", "火星上窜", Vector2(150,380)],
 "bridgebell": ["系桥铜铃", "响一声", Vector2(330,270)],
 "bridgerope": ["桥栏绳", "轻晃", Vector2(900,320)],
 "lampstand": ["花灯担", "亮／举高", Vector2(300,440)],
 "drum": ["潮鼓", "响一声", Vector2(520,460)],
 "sedanrope": ["轿绳担", "绳响", Vector2(430,545)],
 "palanquin": ["神轿（大老爷）", "轻晃→轿铃响", Vector2(1500,430)],
 "gong": ["开道锣", "响一声", Vector2(1750,390)],
 "paperfig": ["纸扎人", "头转向", Vector2(2050,440)],
 "papercargo": ["纸料担", "纸响", Vector2(2260,490)],
 "riverlamp": ["河埠马灯", "亮／举高", Vector2(1300,470)],
 "boat": ["渡船", "船身轻晃", Vector2(2450,545)]
}
const CH4_GRAPH = {
 "shrine": ["bridgebell","lampstand","sedanrope"],
 "bridgebell": ["shrine","bridgerope","drum"],
 "bridgerope": ["bridgebell","drum","palanquin","riverlamp"],
 "lampstand": ["shrine","drum","sedanrope"],
 "drum": ["bridgebell","lampstand","bridgerope"],
 "sedanrope": ["shrine","lampstand","boat"],
 "palanquin": ["bridgerope","gong","paperfig","riverlamp","papercargo"],
 "gong": ["palanquin","paperfig","riverlamp"],
 "paperfig": ["palanquin","gong","papercargo"],
 "papercargo": ["paperfig","riverlamp","boat","palanquin"],
 "riverlamp": ["bridgerope","palanquin","gong","papercargo","boat"],
 "boat": ["papercargo","riverlamp","sedanrope"]
}
const OBJ_ART4 = {
 "shrine": ["obj4_shrine.png", 150.0, 0.827, 0.424, 10.7],
 "bridgebell": ["obj4_bridgebell.png", 140.0, 0.856, 0.457, -2.3],
 "bridgerope": ["obj4_rope.png", 90.0, 0.787, 0.414, 7.0],
 "lampstand": ["obj_lantern.png", 130.0, 0.996, 0.496, 0.0],
 "drum": ["obj_drum.png", 135.0, 0.877, 0.442, 30.0],
 "sedanrope": ["obj4_sedanrope.png", 130.0, 0.841, 0.435, 21.4],
 "palanquin": ["obj_sedan.png", 165.0, 0.968, 0.483, 10.0],
 "gong": ["obj_gong.png", 150.0, 0.908, 0.462, 14.0],
 "paperfig": ["obj_paperfig.png", 190.0, 0.986, 0.494, 12.0],
 "papercargo": ["obj4_papercargo.png", 140.0, 0.710, 0.417, -1.9],
 "riverlamp": ["obj4_riverlamp.png", 150.0, 0.980, 0.488, 27.8],
 "boat": ["obj4_boat.png", 110.0, 0.464, 0.327, -23.2]
}
const CHAR_ART4 = {
 "dengjiang": ["char4_dengjiang.png", 172.0, 0.967, 0.510],
 "ferryman": ["char4_ferryman.png", 170.0, 0.97, 0.45]
}
# 新引路轿：纯剧情道具（非附身节点），细叔扎成（flags.newsedan_done）后供在河埠棚下
const SEDAN_NEW_POS = Vector2(2330, 535)
const SEDAN_NEW_SPEC = [100.0, 0.907, 0.452, 0.0]

var bg5_tex_realm: Texture2D
var bg5_tex_spirit: Texture2D
var obj_sprites5: Dictionary = {}
var paper_head5: Sprite2D
var paper_head5_tilt = 0.0
var horse5_tilt = 0.0
var opp5_seq = ["paperfig", "candle", "gong", "drum"]
var opp5_idx = 0
var opp5_pos = ""
var opp5_timer = 45.0
var wait5 = false
var wait5_left = 0.0
var yield5_left = 0.0
var yield5_from = ""
var clean5: Dictionary = {}
var squeezed5: Dictionary = {}
var seg5 = 1
var trade5_used = 0
var adi5_left = 0.0
var adi5_pause = 0.0
var bang5_used = false
var teach5_done = false
var teach5_scare = false
var beat5_done = false
var seen_update3 = false
var seg5_snap: Dictionary = {}
var has_save5 = false
var save_data5: Dictionary = {}
const SAVE_KEY5 = "yexun_ch5_save_v1"
const CH5_SEG_DUR = [180.0, 150.0, 210.0]
const CH5_SEG_OPEN = ["candle", "paperfig", "gong"]
const CH5_YIELD_POS = Vector2(2330, 455)
const CH5_NODES = {
 "everlamp": ["长明灯", "拨芯", Vector2(300,400)],
 "candle": ["供桌烛台", "烛焰轻燎", Vector2(520,430)],
 "oilpot": ["添油壶", "壶盖轻响", Vector2(170,510)],
 "palanquin": ["神轿（大老爷）", "轻晃→轿铃响", Vector2(1500,430)],
 "drum": ["潮鼓", "响一声", Vector2(1230,465)],
 "gong": ["开道锣", "响一声", Vector2(1760,395)],
 "paperfig": ["纸扎人", "头转向", Vector2(1990,445)],
 "porridge": ["夜粥摊", "揭盖", Vector2(2290,480)],
 "cake": ["红桃粿盘", "分粿", Vector2(1620,525)],
 "gengbang": ["更梆", "敲梆", Vector2(2470,420)],
 "horse": ["纸扎马", "头转向", Vector2(2780,465)],
 "sedanrem": ["纸轿残件", "掀布", Vector2(3060,470)]
}
const CH5_GRAPH = {
 "everlamp": ["candle","oilpot","palanquin"],
 "candle": ["everlamp","oilpot","palanquin","drum"],
 "oilpot": ["everlamp","candle","gengbang"],
 "palanquin": ["everlamp","candle","drum","paperfig","cake"],
 "drum": ["candle","palanquin","gong"],
 "gong": ["drum","paperfig","gengbang"],
 "paperfig": ["palanquin","gong","porridge","horse"],
 "porridge": ["paperfig","cake","gengbang"],
 "cake": ["palanquin","porridge"],
 "gengbang": ["oilpot","gong","porridge","horse","sedanrem"],
 "horse": ["paperfig","gengbang","sedanrem"],
 "sedanrem": ["gengbang","horse"]
}
const OBJ_ART5 = {
 "everlamp": ["obj5_everlamp.png", 175.0, 0.665, 0.293, -4.0],
 "candle": ["obj_candle.png", 110.0, 0.847, 0.414, 55.0],
 "oilpot": ["obj5_oilpot.png", 115.0, 0.838, 0.420, -4.2],
 "palanquin": ["obj_sedan.png", 165.0, 0.968, 0.483, 10.0],
 "drum": ["obj_drum.png", 135.0, 0.877, 0.442, 30.0],
 "gong": ["obj_gong.png", 150.0, 0.908, 0.462, 14.0],
 "paperfig": ["obj_paperfig.png", 190.0, 0.986, 0.494, 12.0],
 "porridge": ["obj5_porridge.png", 180.0, 0.977, 0.494, 2.1],
 "cake": ["obj5_cake.png", 95.0, 0.933, 0.476, 49.0],
 "gengbang": ["obj5_gengbang.png", 150.0, 0.984, 0.491, -0.9],
 "horse": ["obj_horse.png", 175.0, 0.979, 0.485, 20.0],
 "sedanrem": ["obj3_sedanrem.png", 170.0, 0.937, 0.462, 23.9]
}
const CHAR_ART5 = {
 "laobo": ["char5_laobo.png", 170.0, 0.933, 0.525]
}
var bg6_tex_realm: Texture2D
var bg6_tex_spirit: Texture2D
var bg6_tex_dawn: Texture2D
var bg6_tex_nextyear: Texture2D
var ring_tex: Texture2D
var ring_clear_tex: Texture2D
var zhizao6_sprite: Sprite2D
var sedan_refl_sprite: Sprite2D
var clear_variant = ""
var amb3_store_on = false
var horse_epi_tex: Texture2D
var horse_epi_rect: Rect2i
var obj_sprites6: Dictionary = {}
var paper_head6: Sprite2D
var paper_head6_tilt = 0.0
var seg6 = 1
var fog6 = ""
var reported6: Dictionary = {}
var reported_nodes6: Dictionary = {}
var trio6: Dictionary = {}
var trade6_left = 1
var acct6_drive = 0
var acct6_answer = 1
var acct6s_drive = 0
var acct6s_answer = 1
var branch6 = false
var scare_tried6 = false
var seg6_snap: Dictionary = {}
var has_save6 = false
var save_data6: Dictionary = {}
var all_clear = false
const SAVE_KEY6 = "yexun_ch6_save_v1"
const BEHAVIOR_KEY = "yexun_behavior_v1"
const CLEAR_KEY = "yexun_cleared_v1"
const CH6_STATIONS = ["宫门", "土地庙", "溪尾街", "桥头", "西巷", "祠堂前"]
const CH6_SEG_ANCHOR = [640.0, 1150.0, 1650.0, 2150.0, 2650.0, 640.0]
const CH6_TEAM_OFF = {"palanquin": Vector2(0, 430), "lampstand": Vector2(-170, 300), "drum": Vector2(170, 465), "gong": Vector2(330, 390), "paperfig": Vector2(480, 445)}
const CH6_NODES = {
 "everlamp": ["长明灯", "拨芯", Vector2(300,400)],
 "palanquin": ["神轿（大老爷）", "轻晃→轿铃响", Vector2(640,430)],
 "lampstand": ["花灯担", "亮／举高", Vector2(470,300)],
 "drum": ["潮鼓", "响一声", Vector2(810,465)],
 "gong": ["开道锣", "响一声", Vector2(970,390)],
 "paperfig": ["纸扎人", "头转向", Vector2(1120,445)],
 "censer": ["土地公小香炉", "火星上窜", Vector2(1010,380)],
 "templebell": ["土地庙铜铃", "响一声", Vector2(1240,290)],
 "flag": ["标旗", "旗面抖响", Vector2(2380,270)],
 "deepgong": ["深波锣", "响一声", Vector2(2830,430)],
 "doorring": ["西巷门环", "轻叩", Vector2(3120,330)],
 "sign": ["「逢冲则避」签", "显字", Vector2(1020,505)]
}
const OBJ_ART6 = {
 "everlamp": ["obj5_everlamp.png", 175.0, 0.665, 0.293, -4.0],
 "palanquin": ["obj_sedan.png", 165.0, 0.968, 0.483, 10.0],
 "lampstand": ["obj_lantern.png", 130.0, 0.996, 0.496, 0.0],
 "drum": ["obj_drum.png", 135.0, 0.877, 0.442, 30.0],
 "gong": ["obj_gong.png", 150.0, 0.908, 0.462, 14.0],
 "paperfig": ["obj_paperfig.png", 190.0, 0.986, 0.494, 12.0],
 "censer": ["obj_smallcenser.png", 120.0, 0.925, 0.443, 14.0],
 "templebell": ["obj6_bell.png", 150.0, 0.918, 0.453, 1.5],
 "flag": ["obj_flag.png", 205.0, 0.943, 0.472, -15.0],
 "deepgong": ["obj6_deepgong.png", 170.0, 0.976, 0.485, 7.4],
 "doorring": ["obj6_ring.png", 135.0, 0.973, 0.486, 58.0],
 "sign": ["obj6_sign.png", 120.0, 0.977, 0.491, 6.5]
}
const CHAR_ART6 = {}
const SETTINGS_KEY = "yexun_ch1_settings_v1"
const BUS_AMB = "YXAmb"
const BUS_FX = "YXFx"
const WALK_SPEED = 150.0
const CARD_TEXTS = ["正月十五，溪尾村营老爷", "阿澄爬上竹棚挂灯——绳子，是新的", "你醒来时，香刚点燃。弟弟还在灯架底下"]
const SAVE_KEY = "yexun_ch1_save_v1"
const SPIRIT_TINT = Color(0.62, 0.82, 0.95)
const DRAW_OFF = {
 "sticks": Vector2(0, 55), "candle": Vector2(-175, -38),
 "drum": Vector2(-35, -5), "horse": Vector2(25, 10), "umbrella": Vector2(-30, 25)
}
const OBJ_ART = {
 "incense": ["obj_incense.png", 150.0, 0.952, 0.467, 25.0],
 "sticks": ["obj_sign.png", 95.0, 0.985, 0.493, 30.0],
 "candle": ["obj_candle.png", 110.0, 0.847, 0.414, 55.0],
 "drum": ["obj_drum.png", 135.0, 0.877, 0.442, 30.0],
 "palanquin": ["obj_sedan.png", 165.0, 0.968, 0.483, 10.0],
 "flag": ["obj_flag.png", 205.0, 0.943, 0.472, -15.0],
 "lantern": ["obj_lantern.png", 115.0, 0.996, 0.496, 0.0],
 "beam": ["obj_beam.png", 60.0, 0.562, 0.334, 5.0],
 "crackers": ["obj_firecracker.png", 200.0, 0.968, 0.484, -5.0],
 "loudspeaker": ["obj_megaphone.png", 84.0, 0.789, 0.394, 15.0],
 "horse": ["obj_horse.png", 175.0, 0.979, 0.485, 20.0],
 "umbrella": ["obj_umbrella.png", 150.0, 0.966, 0.486, 15.0]
}
const CHAR_ART = {
 "acheng": ["char_acheng.png", 185.0, 0.733, 0.383],
 "adi": ["char_adi.png", 175.0, 0.663, 0.339],
 "xiaoying": ["char_xiaoying.png", 180.0, 0.811, 0.436],
 "miaozhu": ["char_miaozhu.png", 165.0, 0.660, 0.346]
}
var audio: AudioStreamPlayer
var boom_audio: AudioStreamPlayer
const FX_DB = -3.0
const AMBIENT_DB = -25.0
var fx_players: Array[AudioStreamPlayer] = []
var fx_index = 0
var stream_cache: Dictionary = {}
var amb_players: Dictionary = {}
var amb_levels: Dictionary = {}
var amb_targets: Dictionary = {}
var amb_on = false
var fx_time = 0.0
var jump_from = Vector2.ZERO
var jump_to_pos = Vector2.ZERO
var jump_t = -1.0
var ripple_pos = Vector2.ZERO
var ripple_t = -1.0
var realm_t = -1.0
var shake_t = -1.0
var fate_t = -1.0
var fate_text = ""
var flash_id = ""
var flash_t = -1.0
var seen_update1 = false
var seen_update2 = false
var nodes = {
 "incense": ["大香炉", "火星上窜", Vector2(95,350)],
 "sticks": ["签筒", "摇→落一支签", Vector2(220,310)],
 "candle": ["供桌烛台", "焰斜→燎金纸", Vector2(350,350)],
 "drum": ["潮鼓", "响一声", Vector2(455,410)],
 "palanquin": ["神轿（大老爷）", "轻晃→轿铃响", Vector2(650,395)],
 "flag": ["标旗", "旗面抖响", Vector2(570,235)],
 "lantern": ["花灯", "亮／旋转", Vector2(1040,180)],
 "beam": ["灯架横木", "吱呀晃动", Vector2(1020,320)],
 "crackers": ["鞭炮串", "燃放", Vector2(870,230)],
 "loudspeaker": ["大声公", "播庙祝公录音「收埕」", Vector2(820,465)],
 "horse": ["纸扎马", "马头转向", Vector2(470,515)],
 "umbrella": ["油纸伞", "开伞", Vector2(670,535)]
}
var graph = {
 "incense": ["sticks"], "sticks": ["incense","candle"],
 "candle": ["sticks","drum"], "drum": ["candle","palanquin","horse"],
 "palanquin": ["drum","flag","beam"], "flag": ["palanquin","umbrella"],
 "beam": ["palanquin","lantern"], "lantern": ["beam","crackers"],
 "crackers": ["lantern"], "horse": ["drum"],
 "umbrella": ["flag","loudspeaker"], "loudspeaker": ["umbrella"]
}

func npos(id: String) -> Vector2:
 return nodes[id][2] + DRAW_OFF.get(id, Vector2.ZERO)

func _ready() -> void:
 home_nodes = nodes
 home_graph = graph
 var lxgw = load("res://fonts/LXGWWenKai-Subset.ttf")
 font = lxgw if lxgw != null else load("res://font.ttc")
 setup_audio_buses()
 audio = AudioStreamPlayer.new()
 audio.bus = BUS_FX
 add_child(audio)
 boom_audio = AudioStreamPlayer.new()
 boom_audio.bus = BUS_FX
 add_child(boom_audio)
 for i in range(8):
  var fp = AudioStreamPlayer.new()
  fp.volume_db = FX_DB
  fp.bus = BUS_FX
  add_child(fp)
  fx_players.append(fp)
 for key in ["realm", "spirit"]:
  var ap = AudioStreamPlayer.new()
  ap.volume_db = -60.0
  ap.bus = BUS_AMB
  var st = get_stream("amb_" + key)
  if st is AudioStreamWAV:
   st.loop_mode = AudioStreamWAV.LOOP_FORWARD
   st.loop_begin = 0
   st.loop_end = int(st.data.size() / 2)
  ap.stream = st
  add_child(ap)
  amb_players[key] = ap
  amb_levels[key] = 0.0
  amb_targets[key] = 0.0
 build_art()
 npc_pos = {"adi": adi_center(), "miaozhu": Vector2(300, 450), "xiaoying": Vector2(545, 465)}
 load_save_meta()
 load_settings()
 apply_volumes()
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--time-scale="):
   time_scale = maxf(0.1, float(arg.get_slice("=",1)))
 var capture = ""
 var capture_path = ""
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture="): capture = arg.get_slice("=",1)
  if arg.begins_with("--capture-path="): capture_path = arg.get_slice("=",1)
 if not capture.is_empty():
  call_deferred("capture_scene",capture,capture_path)
 queue_redraw()

func _exit_tree() -> void:
 for key in amb_players: amb_players[key].stop()
 for p in fx_players: p.stop()
 if boom_audio != null: boom_audio.stop()
 if audio != null: audio.stop()

func make_sprite(file: String, target_h: float, hfrac: float) -> Sprite2D:
 var sp = Sprite2D.new()
 var tex = load("res://art/" + file)
 sp.texture = tex
 if tex != null:
  var s = target_h / (float(tex.get_height()) * hfrac)
  sp.scale = Vector2(s, s)
 return sp

func build_art() -> void:
 bg_tex_realm = load("res://art/bg_realm.png")
 bg_tex_spirit = load("res://art/bg_spirit.png")
 kv_tex = load("res://art/opening_kv.png")
 bg_sprite = Sprite2D.new()
 bg_sprite.position = Vector2(640, 360)
 bg_sprite.z_index = -100
 bg_sprite.texture = bg_tex_realm
 if bg_tex_realm != null:
  bg_sprite.scale = Vector2(1280.0 / bg_tex_realm.get_width(), 720.0 / bg_tex_realm.get_height())
 add_child(bg_sprite)
 for id in OBJ_ART:
  var ospec = OBJ_ART[id]
  var osp = make_sprite(ospec[0], ospec[1], ospec[2])
  osp.z_index = -50
  add_child(osp)
  obj_sprites[id] = osp
 for cid in CHAR_ART:
  var cspec = CHAR_ART[cid]
  var csp = make_sprite(cspec[0], cspec[1], cspec[2])
  csp.z_index = -40
  add_child(csp)
  char_sprites[cid] = csp
 hook_sedan = make_sprite("obj_sedan.png", 118.0, 0.968)
 hook_sedan.z_index = -35
 hook_sedan.visible = false
 add_child(hook_sedan)
 bg2_tex_realm = load("res://art/bg2_realm.png")
 bg2_tex_spirit = load("res://art/bg2_spirit.png")
 minisedan_tex = load("res://art/obj_minisedan.png")
 minisedan_spirit_tex = load("res://art/obj_minisedan_spirit.png")
 for id in OBJ_ART2:
  var ospec2 = OBJ_ART2[id]
  var osp2 = make_sprite(ospec2[0], ospec2[1], ospec2[2])
  osp2.z_index = -50
  add_child(osp2)
  obj_sprites2[id] = osp2
 # 纸扎人头部拆分件：挂在本体精灵下（本体图已抹去原头），绕颈座支点转向轿中客所在方向
 paper_head = Sprite2D.new()
 paper_head.texture = load("res://art/obj_paperfig_head.png")
 paper_head.scale = Vector2(0.305, 0.305)
 paper_head.offset = Vector2(-1.5, 569.0)
 paper_head.position = Vector2(-7.0, -442.0)
 obj_sprites2["paperfig"].add_child(paper_head)
 for cid in CHAR_ART2:
  var cspec2 = CHAR_ART2[cid]
  var csp2 = make_sprite(cspec2[0], cspec2[1], cspec2[2])
  csp2.z_index = -40
  add_child(csp2)
  char_sprites[cid] = csp2
 bg3a_tex_realm = load("res://art/bg3a_realm.png")
 bg3a_tex_spirit = load("res://art/bg3a_spirit.png")
 bg3b_tex_realm = load("res://art/bg3b_realm.png")
 bg3b_tex_spirit = load("res://art/bg3b_spirit.png")
 bg3a_sprite = Sprite2D.new()
 bg3a_sprite.z_index = -100
 bg3a_sprite.visible = false
 add_child(bg3a_sprite)
 bg3b_sprite = Sprite2D.new()
 bg3b_sprite.z_index = -100
 bg3b_sprite.visible = false
 add_child(bg3b_sprite)
 for id in OBJ_ART3:
  var ospec3 = OBJ_ART3[id]
  var osp3 = make_sprite(ospec3[0], ospec3[1], ospec3[2])
  osp3.z_index = -50
  add_child(osp3)
  obj_sprites3[id] = osp3
 for cid in CHAR_ART3:
  var cspec3 = CHAR_ART3[cid]
  var csp3 = make_sprite(cspec3[0], cspec3[1], cspec3[2])
  csp3.z_index = -40
  add_child(csp3)
  char_sprites[cid] = csp3
 bg4_tex_realm = load("res://art/bg4_realm.png")
 bg4_tex_spirit = load("res://art/bg4_spirit.png")
 for id in OBJ_ART4:
  var ospec4 = OBJ_ART4[id]
  var osp4 = make_sprite(ospec4[0], ospec4[1], ospec4[2])
  osp4.z_index = -50
  add_child(osp4)
  obj_sprites4[id] = osp4
 # 桥栏绳双态：原态/加固态同尺寸同柱位，sync_art 按 flags.reinforced 换图（同 spec 不跳位）
 bridgerope_tex = obj_sprites4["bridgerope"].texture
 bridgerope_fixed_tex = load("res://art/obj4_rope_fixed.png")
 # 新引路轿道具精灵：默认隐藏，扎成后由 sync_art 第四章分支点亮
 sedan_new_sprite = make_sprite("obj4_sedannew.png", SEDAN_NEW_SPEC[0], SEDAN_NEW_SPEC[1])
 sedan_new_sprite.z_index = -45
 sedan_new_sprite.visible = false
 add_child(sedan_new_sprite)
 # 第四章纸扎人头部拆分件：与二章同法，绕颈座支点转向轿中客所在方向；借嘴态下头停住正对前方
 paper_head4 = Sprite2D.new()
 paper_head4.texture = load("res://art/obj_paperfig_head.png")
 paper_head4.scale = Vector2(0.305, 0.305)
 paper_head4.offset = Vector2(-1.5, 569.0)
 paper_head4.position = Vector2(-7.0, -442.0)
 obj_sprites4["paperfig"].add_child(paper_head4)
 for cid in CHAR_ART4:
  var cspec4 = CHAR_ART4[cid]
  var csp4 = make_sprite(cspec4[0], cspec4[1], cspec4[2])
  csp4.z_index = -40
  add_child(csp4)
  char_sprites[cid] = csp4
 bg5_tex_realm = load("res://art/bg5_realm.png")
 bg5_tex_spirit = load("res://art/bg5_spirit.png")
 for id in OBJ_ART5:
  var ospec5 = OBJ_ART5[id]
  var osp5 = make_sprite(ospec5[0], ospec5[1], ospec5[2])
  osp5.z_index = -50
  add_child(osp5)
  obj_sprites5[id] = osp5
 # 长明灯火苗三态：三图同尺寸同构图共用同一 spec，sync_art 按段计时余量整图切换（零跳位）
 everlamp_tex = obj_sprites5["everlamp"].texture
 everlamp_low_tex = load("res://art/obj5_everlamp_low.png")
 everlamp_dying_tex = load("res://art/obj5_everlamp_dying.png")
 # 第五章纸扎人头部拆分件：与二、四章同法，绕颈座支点转向轿中客所在方向（双雷达之一）
 paper_head5 = Sprite2D.new()
 paper_head5.texture = load("res://art/obj_paperfig_head.png")
 paper_head5.scale = Vector2(0.305, 0.305)
 paper_head5.offset = Vector2(-1.5, 569.0)
 paper_head5.position = Vector2(-7.0, -442.0)
 obj_sprites5["paperfig"].add_child(paper_head5)
 for cid in CHAR_ART5:
  var cspec5 = CHAR_ART5[cid]
  var csp5 = make_sprite(cspec5[0], cspec5[1], cspec5[2])
  csp5.z_index = -40
  add_child(csp5)
  char_sprites[cid] = csp5
 bg6_tex_realm = load("res://art/bg6_realm.png")
 bg6_tex_spirit = load("res://art/bg6_spirit.png")
 bg6_tex_dawn = load("res://art/bg6_dawn.png")
 bg6_tex_nextyear = load("res://art/bg6_nextyear.png")
 horse_epi_tex = load("res://art/obj_horse.png")
 if horse_epi_tex != null: horse_epi_rect = horse_epi_tex.get_image().get_used_rect()
 for id in OBJ_ART6:
  var ospec6 = OBJ_ART6[id]
  var osp6 = make_sprite(ospec6[0], ospec6[1], ospec6[2])
  osp6.z_index = -50
  add_child(osp6)
  obj_sprites6[id] = osp6
 # 第六章纸扎人头部拆分件：与二、四、五章同法，绕颈座支点指向随队的纸灶所在；它散去后垂首
 paper_head6 = Sprite2D.new()
 paper_head6.texture = load("res://art/obj_paperfig_head.png")
 paper_head6.scale = Vector2(0.305, 0.305)
 paper_head6.offset = Vector2(-1.5, 569.0)
 paper_head6.position = Vector2(-7.0, -442.0)
 obj_sprites6["paperfig"].add_child(paper_head6)
 for cid in CHAR_ART6:
  var cspec6 = CHAR_ART6[cid]
  var csp6 = make_sprite(cspec6[0], cspec6[1], cspec6[2])
  csp6.z_index = -40
  add_child(csp6)
  char_sprites[cid] = csp6
 # 门环双态：锈态/清声态同窗同 spec，sync_art 按 flags.knocked 换图（环心对齐不跳位）
 ring_tex = obj_sprites6["doorring"].texture
 ring_clear_tex = load("res://art/obj6_ring_clear.png")
 # 纸灶完整形态：灵域侧精灵，第五段立于旧宅门前雾位（3030），sync_art 第六章分支控制显隐/透明度
 zhizao6_sprite = make_sprite("char6_zhizao.png", 190.0, 0.978)
 zhizao6_sprite.z_index = -42
 zhizao6_sprite.visible = false
 add_child(zhizao6_sprite)
 # 水洼纸轿倒影（A-02/S-10 全卷唯一例外）：与纸灶同源的纸轿图，sync_art 第六章分支控制显隐/翻转
 sedan_refl_sprite = make_sprite("obj4_sedannew.png", 100.0, 0.907)
 sedan_refl_sprite.z_index = -55
 sedan_refl_sprite.visible = false
 add_child(sedan_refl_sprite)
 sync_art()

func place_char(sp: Sprite2D, cid: String, center: Vector2) -> void:
 var spec = CHAR_ART[cid] if CHAR_ART.has(cid) else (CHAR_ART2[cid] if CHAR_ART2.has(cid) else (CHAR_ART3[cid] if CHAR_ART3.has(cid) else (CHAR_ART4[cid] if CHAR_ART4.has(cid) else (CHAR_ART5[cid] if CHAR_ART5.has(cid) else CHAR_ART6[cid]))))
 sp.position = center + Vector2(0, spec[1] * (0.5 - spec[3]))

func adi_center() -> Vector2:
 if flags.get("safe", false): return Vector2(745, 470)
 if flags.get("pickup", false): return Vector2(330, 465)
 return Vector2(1055, 470)

func update_hover() -> void:
 hover_id = ""
 if phase in ["tutorial", "explore", "playing"]:
  var mp = get_global_mouse_position() + Vector2(cam_x, 0)
  for id in nodes:
   if mp.distance_to(npos(id)) < 60:
    hover_id = id
    break

func sync_art() -> void:
 if bg_sprite == null: return
 var in_game = phase != "title" and phase != "opening" and not (phase == "ending" and ending_t >= 3.6)
 bg_sprite.visible = in_game
 if bg3a_sprite != null:
  var show3 = in_game and chapter == 3
  bg3a_sprite.visible = show3
  bg3b_sprite.visible = show3
  if chapter == 3: bg_sprite.visible = false
  if show3:
   bg3a_sprite.texture = bg3a_tex_spirit if spirit else bg3a_tex_realm
   bg3b_sprite.texture = bg3b_tex_spirit if spirit else bg3b_tex_realm
   if bg3a_sprite.texture != null:
    var bs3a = maxf(1280.0 / bg3a_sprite.texture.get_width(), 720.0 / bg3a_sprite.texture.get_height())
    bg3a_sprite.scale = Vector2(bs3a, bs3a)
   if bg3b_sprite.texture != null:
    var bs3b = maxf(1280.0 / bg3b_sprite.texture.get_width(), 720.0 / bg3b_sprite.texture.get_height())
    bg3b_sprite.scale = Vector2(bs3b, bs3b)
   bg3a_sprite.position = Vector2(640 - cam_x, 360)
   bg3b_sprite.position = Vector2(1920 - cam_x, 360)
 if chapter == 2:
  bg_sprite.texture = bg2_tex_spirit if spirit else bg2_tex_realm
  if bg_sprite.texture != null:
   var bs2 = maxf(2560.0 / bg_sprite.texture.get_width(), 720.0 / bg_sprite.texture.get_height())
   bg_sprite.scale = Vector2(bs2, bs2)
  bg_sprite.position = Vector2(1280 - cam_x, 360)
 elif chapter == 4:
  bg_sprite.texture = bg4_tex_spirit if spirit else bg4_tex_realm
  if bg_sprite.texture != null:
   var bs4 = maxf(2560.0 / bg_sprite.texture.get_width(), 720.0 / bg_sprite.texture.get_height())
   bg_sprite.scale = Vector2(bs4, bs4)
  bg_sprite.position = Vector2(1280 - cam_x, 360)
 elif chapter == 5:
  bg_sprite.texture = bg5_tex_spirit if spirit else bg5_tex_realm
  if bg_sprite.texture != null:
   var bs5 = maxf(3200.0 / bg_sprite.texture.get_width(), 720.0 / bg_sprite.texture.get_height())
   bg_sprite.scale = Vector2(bs5, bs5)
  bg_sprite.position = Vector2(1600 - cam_x, 360)
 elif chapter == 6:
  bg_sprite.texture = bg6_tex_spirit if spirit else (bg6_tex_dawn if flags.get("update1", false) and bg6_tex_dawn != null else bg6_tex_realm)
  if bg_sprite.texture != null:
   var bs6 = maxf(3200.0 / bg_sprite.texture.get_width(), 720.0 / bg_sprite.texture.get_height())
   bg_sprite.scale = Vector2(bs6, bs6)
  bg_sprite.position = Vector2(1600 - cam_x, 360)
 else:
  bg_sprite.texture = bg_tex_spirit if spirit else bg_tex_realm
  if bg_tex_realm != null:
   bg_sprite.scale = Vector2(1280.0 / bg_tex_realm.get_width(), 720.0 / bg_tex_realm.get_height())
  bg_sprite.position = Vector2(640, 360)
 for id in obj_sprites:
  obj_sprites[id].visible = in_game and chapter == 1
 for id in obj_sprites2:
  obj_sprites2[id].visible = in_game and chapter == 2
 for id in obj_sprites3:
  obj_sprites3[id].visible = in_game and chapter == 3
 for id in obj_sprites4:
  obj_sprites4[id].visible = in_game and chapter == 4
 for id in obj_sprites5:
  obj_sprites5[id].visible = in_game and chapter == 5
 for id in obj_sprites6:
  obj_sprites6[id].visible = in_game and chapter == 6
 var osprites = obj_sprites if chapter == 1 else (obj_sprites2 if chapter == 2 else (obj_sprites3 if chapter == 3 else (obj_sprites4 if chapter == 4 else (obj_sprites6 if chapter == 6 else obj_sprites5))))
 var oart = OBJ_ART if chapter == 1 else (OBJ_ART2 if chapter == 2 else (OBJ_ART3 if chapter == 3 else (OBJ_ART4 if chapter == 4 else (OBJ_ART6 if chapter == 6 else OBJ_ART5))))
 for id in osprites:
  var sp: Sprite2D = osprites[id]
  var spec = oart[id]
  var base_pos = crackers_vis if (chapter == 1 and id == "crackers") else npos(id)
  base_pos -= Vector2(cam_x, 0)
  if chapter == 2 and id == "minisedan":
   sp.texture = minisedan_spirit_tex if spirit else minisedan_tex
  if chapter == 4 and id == "bridgerope":
   sp.texture = bridgerope_fixed_tex if flags.get("reinforced", false) else bridgerope_tex
  if chapter == 5 and id == "everlamp":
   var lamp_frac = clampf(remaining / CH5_SEG_DUR[seg5 - 1], 0.0, 1.0)
   sp.texture = everlamp_dying_tex if lamp_frac <= 0.22 else (everlamp_low_tex if lamp_frac <= 0.5 else everlamp_tex)
  if chapter == 6 and id == "doorring":
   sp.texture = ring_clear_tex if flags.get("knocked", false) else ring_tex
  if sp.texture != null:
   var s = spec[1] / (float(sp.texture.get_height()) * spec[2])
   var grow = 0.0
   if id == flash_id and flash_t >= 0.0: grow = 0.06 * (1.0 - flash_t)
   sp.scale = Vector2(s, s) * (1.0 + grow)
  sp.position = base_pos + Vector2(0, spec[4] + spec[1] * (0.5 - spec[3]))
  sp.modulate = SPIRIT_TINT if spirit else Color.WHITE
  if chapter == 2 and id == "minisedan" and spirit: sp.modulate = Color.WHITE
  sp.rotation = 0.0
  if id == obj_anim_id and obj_anim_t >= 0.0:
   apply_obj_anim(sp, id, obj_anim_t)
 if chapter == 3 and obj_sprites3.has("horse"):
  var hsp3: Sprite2D = obj_sprites3["horse"]
  var tilt3 = 0.0
  if in_game and opp3_pos != "" and opp3_pos != "horse":
   tilt3 = clampf((npos(opp3_pos).x - npos("horse").x) * 0.0004, -0.16, 0.16)
  hsp3.rotation = lerpf(hsp3.rotation, tilt3, 0.08)
 if chapter == 4 and paper_head4 != null:
  var tilt4 = 0.0
  if in_game and opp4_pos != "" and opp4_pos != "paperfig" and not bm_active:
   tilt4 = clampf((npos(opp4_pos).x - npos("paperfig").x) * 0.00045, -0.30, 0.30)
  paper_head4_tilt = lerpf(paper_head4_tilt, tilt4, 0.08)
  paper_head4.rotation = paper_head4_tilt
 if chapter == 5:
  var rtarget = Vector2.ZERO
  var has_target = false
  if in_game and yield5_left > 0.0:
   rtarget = CH5_YIELD_POS
   has_target = true
  elif in_game and opp5_pos != "":
   rtarget = npos(opp5_pos)
   has_target = true
  if paper_head5 != null:
   var tilt5 = 0.0
   if has_target and opp5_pos != "paperfig":
    tilt5 = clampf((rtarget.x - npos("paperfig").x) * 0.00045, -0.30, 0.30)
   paper_head5_tilt = lerpf(paper_head5_tilt, tilt5, 0.08)
   paper_head5.rotation = paper_head5_tilt
  if obj_sprites5.has("horse"):
   var hsp5: Sprite2D = obj_sprites5["horse"]
   var htilt5 = 0.0
   if has_target:
    htilt5 = clampf((rtarget.x - npos("horse").x) * 0.0004, -0.16, 0.16)
   horse5_tilt = lerpf(horse5_tilt, htilt5, 0.08)
   hsp5.rotation = horse5_tilt
 if chapter == 6 and paper_head6 != null:
  var tilt6 = 0.0
  if in_game and not flags.get("update1", false):
   var mist6 = CH6_SEG_ANCHOR[seg6 - 1] + 380.0
   tilt6 = clampf((mist6 - npos("paperfig").x) * 0.00045, -0.30, 0.30)
  paper_head6_tilt = lerpf(paper_head6_tilt, tilt6, 0.08)
  paper_head6.rotation = paper_head6_tilt
 if zhizao6_sprite != null:
  var zshow = in_game and chapter == 6 and spirit and (seg6 == 5 or (seg6 == 6 and bool(flags.get("update1", false)) and cam_x > 1400.0))
  zhizao6_sprite.visible = zshow
  if zshow:
   zhizao6_sprite.position = Vector2(3030, 470) - Vector2(cam_x, 0) + Vector2(0, 190.0 * (0.5 - 0.495))
   zhizao6_sprite.modulate = Color(1, 1, 1, 0.95 if flags.get("update1", false) else 0.62)
 if sedan_refl_sprite != null:
  var rshow = in_game and chapter == 6 and bool(flags.get("update1", false)) and (seg6 == 5 or (seg6 == 6 and cam_x > 1400.0))
  sedan_refl_sprite.visible = rshow
  if rshow:
   sedan_refl_sprite.position = Vector2(3048, 546) - Vector2(cam_x, 0)
   var rs = absf(sedan_refl_sprite.scale.x)
   sedan_refl_sprite.scale = Vector2(rs, -rs * 0.40)
   sedan_refl_sprite.modulate = Color(0.78, 0.87, 0.96, 0.50)
 if chapter == 2:
  if paper_head != null:
   var tilt_goal = 0.0
   if in_game and opp_pos != "" and opp_pos != "paperfig":
    tilt_goal = clampf((npos(opp_pos).x - npos("paperfig").x) * 0.00045, -0.30, 0.30)
   paper_head_tilt = lerpf(paper_head_tilt, tilt_goal, 0.08)
   paper_head.rotation = paper_head_tilt
  var ch2_defaults = {"adi": Vector2(1460, 485), "miaozhu": Vector2(120, 455), "xiaoying": Vector2(600, 470), "lianshen": Vector2(648, 482), "ayong": Vector2(1790, 458), "xishu": Vector2(1055, 458)}
  for cid in ["adi", "miaozhu", "xiaoying", "lianshen", "ayong", "xishu"]:
   var csp: Sprite2D = char_sprites[cid]
   var cpos: Vector2 = npc_pos.get(cid, ch2_defaults[cid])
   if npc_walking.get(cid, false): cpos.y += sin(fx_time * 11.0) * 2.0
   place_char(csp, cid, cpos - Vector2(cam_x, 0))
   csp.visible = in_game
   csp.modulate = SPIRIT_TINT if spirit else Color.WHITE
  var bv: Sprite2D = char_sprites["backview"]
  var show_bv = phase == "ending" and ending_t >= 1.2 and ending_t < 3.4
  bv.visible = show_bv
  if show_bv:
   var ba = 0.9
   if ending_t < 2.2: ba = 0.9 * (ending_t - 1.2) / 1.0
   place_char(bv, "backview", Vector2(1505, 472) - Vector2(cam_x, 0))
   bv.modulate = Color(0.08, 0.10, 0.14, ba)
  var ac2: Sprite2D = char_sprites["acheng"]
  var show_ac2 = in_game and spirit
  ac2.visible = show_ac2
  if show_ac2:
   place_char(ac2, "acheng", npos(current) - Vector2(cam_x, 0) + Vector2(-78, -95) + Vector2(0, sin(fx_time * 1.4) * 5.0))
   ac2.modulate = Color(1, 1, 1, 0.88)
  if hook_sedan != null: hook_sedan.visible = false
 elif chapter == 3:
  for cid in CHAR_ART2:
   char_sprites[cid].visible = false
  char_sprites["miaozhu"].visible = false
  var ch3_defaults = {"liushu": Vector2(850, 478), "keeper": Vector2(455, 462), "shuisheng": Vector2(1150, 472), "xiaoying": Vector2(1010, 478), "ayong": Vector2(1090, 462), "adi": Vector2(1210, 492), "member_a": Vector2(680, 494), "member_b": Vector2(750, 466)}
  for cid in ["liushu", "keeper", "shuisheng", "xiaoying", "ayong", "adi", "member_a", "member_b"]:
   var csp3: Sprite2D = char_sprites[cid]
   var cpos3: Vector2 = npc_pos.get(cid, ch3_defaults[cid])
   if npc_walking.get(cid, false): cpos3.y += sin(fx_time * 11.0) * 2.0
   place_char(csp3, cid, cpos3 - Vector2(cam_x, 0))
   csp3.visible = in_game
   csp3.modulate = SPIRIT_TINT if spirit else Color.WHITE
  var ac3: Sprite2D = char_sprites["acheng"]
  var show_ac3 = in_game and spirit
  ac3.visible = show_ac3
  if show_ac3:
   place_char(ac3, "acheng", npos(current) - Vector2(cam_x, 0) + Vector2(-78, -95) + Vector2(0, sin(fx_time * 1.4) * 5.0))
   ac3.modulate = Color(1, 1, 1, 0.88)
  if hook_sedan != null: hook_sedan.visible = false
 elif chapter == 4:
  for cid in char_sprites:
   char_sprites[cid].visible = false
  var ch4_defaults = {"miaozhu": Vector2(300, 470), "dengjiang": Vector2(390, 505), "liushu": Vector2(720, 478), "ayong": Vector2(620, 505), "xiaoying": Vector2(830, 485), "adi": Vector2(1010, 500), "shuisheng": Vector2(1180, 485), "xishu": Vector2(2180, 505), "ferryman": Vector2(2420, 505)}
  for cid in ch4_defaults:
   var csp4: Sprite2D = char_sprites[cid]
   var cpos4: Vector2 = npc_pos.get(cid, ch4_defaults[cid])
   if npc_walking.get(cid, false): cpos4.y += sin(fx_time * 11.0) * 2.0
   place_char(csp4, cid, cpos4 - Vector2(cam_x, 0))
   csp4.visible = in_game
   csp4.modulate = SPIRIT_TINT if spirit else Color.WHITE
  var ac4: Sprite2D = char_sprites["acheng"]
  var show_ac4 = in_game and spirit
  ac4.visible = show_ac4
  if show_ac4:
   place_char(ac4, "acheng", npos(current) - Vector2(cam_x, 0) + Vector2(-78, -95) + Vector2(0, sin(fx_time * 1.4) * 5.0))
   ac4.modulate = Color(1, 1, 1, 0.88)
  if sedan_new_sprite != null:
   var show_sn = in_game and flags.get("newsedan_done", false)
   sedan_new_sprite.visible = show_sn
   if show_sn:
    sedan_new_sprite.position = SEDAN_NEW_POS - Vector2(cam_x, 0) + Vector2(0, SEDAN_NEW_SPEC[3] + SEDAN_NEW_SPEC[0] * (0.5 - SEDAN_NEW_SPEC[2]))
    sedan_new_sprite.modulate = SPIRIT_TINT if spirit else Color.WHITE
  if hook_sedan != null: hook_sedan.visible = false
 elif chapter == 5:
  for cid in char_sprites:
   char_sprites[cid].visible = false
  var ch5_defaults = {"miaozhu": Vector2(560, 470), "xiaoying": Vector2(660, 495), "ayong": Vector2(2160, 470), "adi": Vector2(2060, 505), "lianshen": Vector2(1720, 510), "shuisheng": Vector2(1360, 495), "liushu": Vector2(2330, 460), "xishu": Vector2(2680, 505), "laobo": Vector2(2340, 515)}
  for cid in ch5_defaults:
   if cid == "shuisheng" and not flags.get("verse_done", false): continue
   if cid == "liushu" and seg5 != 3: continue
   if cid == "xishu" and seg5 != 3: continue
   var csp5b: Sprite2D = char_sprites[cid]
   var cpos5: Vector2 = npc_pos.get(cid, ch5_defaults[cid])
   if cid == "adi":
    if seg5 == 2 and not flags.get("update2", false):
     var prog5 = clampf(1.0 - adi5_left / 120.0, 0.0, 1.0)
     cpos5 = Vector2(lerpf(1500.0, 2130.0, prog5), 495)
    elif flags.get("update2", false):
     cpos5 = Vector2(1560, 505)
   if npc_walking.get(cid, false): cpos5.y += sin(fx_time * 11.0) * 2.0
   place_char(csp5b, cid, cpos5 - Vector2(cam_x, 0))
   csp5b.visible = in_game
   csp5b.modulate = SPIRIT_TINT if spirit else Color.WHITE
   if cid == "liushu": csp5b.modulate = Color(0.30, 0.42, 0.55, 0.92) if spirit else Color(0.30, 0.36, 0.46, 0.92)
  var ac5: Sprite2D = char_sprites["acheng"]
  var show_ac5 = in_game and spirit
  ac5.visible = show_ac5
  if show_ac5:
   place_char(ac5, "acheng", npos(current) - Vector2(cam_x, 0) + Vector2(-78, -95) + Vector2(0, sin(fx_time * 1.4) * 5.0))
   ac5.modulate = Color(1, 1, 1, 0.88)
  if hook_sedan != null: hook_sedan.visible = false
 elif chapter == 6:
  for cid in char_sprites:
   char_sprites[cid].visible = false
  var ch6_defaults = ch6_npc_defaults()
  for cid in ch6_defaults:
   var csp6b: Sprite2D = char_sprites[cid]
   var cpos6: Vector2 = npc_pos.get(cid, ch6_defaults[cid])
   if npc_walking.get(cid, false): cpos6.y += sin(fx_time * 11.0) * 2.0
   place_char(csp6b, cid, cpos6 - Vector2(cam_x, 0))
   csp6b.visible = in_game
   csp6b.modulate = SPIRIT_TINT if spirit else Color.WHITE
  var ac6: Sprite2D = char_sprites["acheng"]
  var show_ac6 = in_game and spirit
  ac6.visible = show_ac6
  if show_ac6:
   place_char(ac6, "acheng", npos(current) - Vector2(cam_x, 0) + Vector2(-78, -95) + Vector2(0, sin(fx_time * 1.4) * 5.0))
   ac6.modulate = Color(1, 1, 1, 0.88)
  if hook_sedan != null: hook_sedan.visible = false
 else:
  for cid in CHAR_ART2:
   char_sprites[cid].visible = false
  var adi_pos: Vector2 = npc_pos.get("adi", adi_center())
  if npc_walking.get("adi", false): adi_pos.y += sin(fx_time * 11.0) * 2.0
  elif adi_center() == Vector2(1055, 470): adi_pos.y += sin(fx_time * 2.4) * 2.0
  place_char(char_sprites["adi"], "adi", adi_pos)
  var mz_pos: Vector2 = npc_pos.get("miaozhu", Vector2(300, 450))
  if npc_walking.get("miaozhu", false): mz_pos.y += sin(fx_time * 11.0) * 2.0
  place_char(char_sprites["miaozhu"], "miaozhu", mz_pos)
  place_char(char_sprites["xiaoying"], "xiaoying", npc_pos.get("xiaoying", Vector2(545, 465)))
  for cid in ["adi", "miaozhu", "xiaoying"]:
   char_sprites[cid].visible = in_game
   char_sprites[cid].modulate = SPIRIT_TINT if spirit else Color.WHITE
  var mz: Sprite2D = char_sprites["miaozhu"]
  mz.rotation = sin(fx_time * 0.8) * 0.015
  if mz.texture != null:
   var mzs = CHAR_ART["miaozhu"][1] / (float(mz.texture.get_height()) * CHAR_ART["miaozhu"][2])
   mz.scale = Vector2(mzs, mzs) * (1.0 + 0.01 * sin(fx_time * 1.05))
  var xy: Sprite2D = char_sprites["xiaoying"]
  if xy.texture != null:
   var xys = CHAR_ART["xiaoying"][1] / (float(xy.texture.get_height()) * CHAR_ART["xiaoying"][2])
   xy.scale = Vector2(xys, xys) * (1.0 + 0.01 * sin(fx_time * 1.05 + 1.7))
  var ac: Sprite2D = char_sprites["acheng"]
  var show_ac = in_game and spirit
  ac.visible = show_ac
  if show_ac:
   place_char(ac, "acheng", npos(current) + Vector2(-78, -95) + Vector2(0, sin(fx_time * 1.4) * 5.0))
   ac.modulate = Color(1, 1, 1, 0.88)
  if hook_sedan != null:
   var show_hook = phase == "ending" and ending_t >= 1.1 and ending_t < 3.6
   hook_sedan.visible = show_hook
   if show_hook:
    var ha = 0.85
    if ending_t < 2.5: ha = 0.85 * (ending_t - 1.1) / 1.4
    else: ha = 0.85 * (3.6 - ending_t) / 1.0
    hook_sedan.position = Vector2(1148, 452)
    hook_sedan.modulate = Color(0.10, 0.13, 0.18, clampf(ha, 0.0, 0.85))


func apply_obj_anim(sp: Sprite2D, id: String, t: float) -> void:
 var env = 1.0 - t
 match id:
  "sticks": sp.rotation = sin(t * PI * 3.0) * env * 0.16
  "flag": sp.rotation = sin(t * PI * 2.0) * env * 0.12
  "beam":
   sp.rotation = sin(t * PI * 2.0) * env * 0.02
   sp.position.x += sin(t * PI * 2.0) * env * 4.0
  "palanquin":
   sp.rotation = sin(t * PI * 1.5) * env * 0.03
   sp.position.y -= sin(t * PI) * 3.0
  "horse": sp.rotation = sin(t * PI) * 0.07
  "umbrella": sp.scale *= 1.0 + 0.15 * sin(t * PI)
  "drum": sp.scale *= 1.0 + 0.05 * sin(t * 40.0) * env
  "lantern": sp.scale *= 1.0 + 0.05 * sin(t * PI)

func move_npc(cid: String, target: Vector2, delta: float) -> bool:
 var cur: Vector2 = npc_pos.get(cid, target)
 if cur.distance_to(target) < 2.0:
  npc_pos[cid] = target
  npc_walking[cid] = false
  return true
 npc_pos[cid] = cur.move_toward(target, WALK_SPEED * delta)
 npc_walking[cid] = true
 return false

func update_npcs(delta: float) -> void:
 if npc_pos.is_empty(): return
 if chapter == 4:
  var crossed4: bool = flags.get("crossed", false)
  move_npc("ayong", Vector2(1480, 485) if crossed4 else Vector2(620, 505), delta)
  move_npc("xiaoying", Vector2(1650, 478) if crossed4 else Vector2(830, 485), delta)
  move_npc("adi", Vector2(1930, 495) if crossed4 else Vector2(1010, 500), delta)
  return
 if chapter == 3:
  move_npc("keeper", Vector2(215, 470) if keeper_out else Vector2(455, 462), delta)
  move_npc("xiaoying", Vector2(470, 478) if flags.get("archive_taken", false) else Vector2(1010, 478), delta)
  return
 if chapter == 2:
  move_npc("xiaoying", Vector2(1660, 470) if flags.get("xiaoying_safe", false) else Vector2(600, 470), delta)
  move_npc("lianshen", Vector2(505, 478) if flags.get("lianshen_safe", false) else Vector2(648, 482), delta)
  return
 move_npc("adi", adi_center(), delta)
 if flags.get("moved", false) and not mz_trip_started:
  mz_trip_started = true
  mz_queue = [[Vector2(985, 462), 1.0], [Vector2(300, 450), 0.0]]
 if not mz_queue.is_empty():
  var step: Array = mz_queue[0]
  if move_npc("miaozhu", step[0], delta):
   if float(step[1]) > 0.0:
    step[1] = float(step[1]) - delta
   else:
    mz_queue.pop_front()
 elif not flags.get("moved", false):
  move_npc("miaozhu", Vector2(300, 450), delta)

func say(who: String, line: String) -> void:
 speaker = who
 dialogue = line
 history.append(who + "：" + line)
 print(who + "：" + line)
 queue_redraw()

func start_game() -> void:
 clear_save()
 chapter = 1
 nodes = home_nodes
 graph = home_graph
 cam_x = 0.0
 opp_pos = ""
 phase = "tutorial"
 current = "incense"
 spirit = true
 flags = {}
 mz_trip_started = false
 mz_queue.clear()
 crackers_snap = true
 ending_t = -1.0
 seen_update1 = false
 seen_update2 = false
 remaining = 240.0
 pickup_left = 0.0
 nodes.crackers[2] = Vector2(870,230)
 graph.beam = ["palanquin","lantern"]
 graph.crackers = ["lantern"]
 say("阿澄", "谁也看不见我……青色光点在香炉里。按 E 火星上窜；Tab 切现实／灵域。")
 append_tip("spirit", "这里是灵域，时间是停的。点旁边发青光的物件，就能附过去。")
 start_ambience()

func start_incense() -> void:
 if phase != "explore": return
 if chapter == 6:
  start_incense6()
  return
 if chapter == 5:
  start_incense5()
  return
 if chapter == 4:
  start_incense4()
  return
 if chapter == 3:
  start_incense3()
  return
 if chapter == 2:
  start_incense2()
  return
 phase = "playing"
 current = "incense"
 nodes.crackers[2] = Vector2(870,230)
 graph.beam = ["palanquin","lantern"]
 graph.crackers = ["lantern"]
 remaining = 240.0
 flags = {}
 seen_update1 = false
 seen_update2 = false
 pickup_left = 0.0
 say("一炷香前", "阿弟仍在灯架下绑绳。现实时间流动，灵域时间停顿。签筒、神轿或许能叫他离开。")
 play_fx("rewind", -7.0)
 save_game()

func set_spirit(value: bool) -> void:
 spirit = value
 realm_t = 0.0
 if amb_on:
  amb_targets["spirit"] = 1.0 if value else 0.0
  amb_targets["realm"] = 0.0 if value else 1.0
 if value and phase in ["tutorial","explore","playing"]:
  append_tip("spirit", "这里是灵域，时间是停的。点旁边发青光的物件，就能附过去。")
 queue_redraw()

func jump_to(id: String) -> bool:
 if not spirit or phase not in ["tutorial","explore","playing"]: return false
 if chapter == 2 and opp_pos != "" and id == opp_pos:
  if id == "minisedan" and phase == "playing":
   remaining = maxf(0.0, remaining - 5.0)
   sedan_attempts += 1
   if sedan_attempts >= 3:
    say("阿澄", "轿帘里伸出一只纸手，把你推了出来。【街那头，小英莫名打了个寒颤。】")
   else:
    say("阿澄", "轿帘里伸出一只纸手，把你推了出来。")
  else:
   say("阿澄", "里面……有东西了。")
  return false
 if chapter == 3 and opp3_pos != "" and id == opp3_pos:
  say("阿澄", "里面……有东西了。")
  return false
 if chapter == 4 and opp4_pos != "" and id == opp4_pos:
  say("阿澄", "里面……有东西了。")
  return false
 if chapter == 5 and opp5_pos != "" and id == opp5_pos:
  say("阿澄", "里面……有东西了。")
  return false
 if chapter == 6 and id == "sign":
  if seg6 == 6 and flags.get("update1", false) and flags.get("pages_done", false) and not flags.get("sign_done", false):
   if current not in ["palanquin", "everlamp"]:
    say("阿澄", "最后一附，得从队伍的头上落过去——神轿的铃、长明灯的火，才送得到阿弟怀里。【最后一附只能自神轿／长明灯附向签。】")
    return false
   last_attach6()
   return true
  say("阿澄", "阿弟把签攥得很紧，像怕它凉。【归程还没走完——补路报全、补页写完，才轮到这最后一附。】")
  return false
 if chapter == 6 and fog6 != "" and id == fog6:
  if fog6 == "templebell":
   say("阿澄", "铃面像蒙着水，响不透。【雾锢：它停在这里，把铜铃压住了。这一站欠的东西补上，雾才肯退——先附土地公小香炉，火星上窜，重燃庙香。】")
  elif fog6 == "gong":
   say("阿澄", "锣面覆着水渍纹，雾沉沉地压着——附不进去。【先应它一声：附潮鼓按 E，应答版。】")
  else:
   say("阿澄", "灯光发闷，雾把花灯担压住了——附不进去。【先应它一声：神轿轿铃或潮鼓，应答版。】")
  return false
 if id not in graph[current]: return false
 if (current == "umbrella" and id == "loudspeaker") or (current == "loudspeaker" and id == "umbrella"):
  if not flags.get("umbrella",false):
   say("阿澄", "先让油纸伞张开，借风飘到戏台口。")
   return false
 var before_jump = dialogue
 jump_from = npos(current)
 jump_to_pos = npos(id)
 jump_t = 0.0
 prev_current = current
 current = id
 play_fx("jump", -7.0)
 if chapter == 3 and phase == "playing":
  if not flags.get("beat1", false):
   flags.beat1 = true
   dialogue += "【灵域边缘，另一道青光跟着动了一下——只有轨迹，一闪就没了。】"
  jump_count += 1
  if jump_count >= 3: opp3_advance_mimic()
 if id == "sticks" and not flags.get("heard",false):
  flags.heard = true
  say("庙祝公／小英", "阿弟顶了他哥哥的轿位。／灯架今晚……绳是新换的。")
 if chapter == 2 and id == "vat" and not flags.get("inv_vat",false):
  flags.inv_vat = true
  say("阿澄", "缸水静得出奇。街上的轿，一顶一顶都有倒影——只有纸扎店边那顶小轿，水里空空的，什么都没有。")
 if chapter == 2 and id == "minisedan":
  sedan_stay = 0.0
 if chapter == 4 and id == "lampstand" and flags.get("crossed", false) and not flags.get("memory_seen", false):
  flags.memory_seen = true
  say("阿澄（记忆）", "花灯担的竹骨受潮发霉，触感裂开记忆——傍晚，我发现灯架主绳的割痕，攥着绳头去问庙祝公「这口子怎么齐得像刀裁的」，他支吾着没敢接话；我爬上戏台竹棚，脚下脆响；坠落前最后一眼——祠堂库房门口，水生站在那里，看着我，一个字也没说。【死因全揭：四件事，在同一瞬间对上了。我望向桥下的水，想起那一眼里闪过的不是求救，是——他怎么站在库房门口。】")
  if opp4_pos == "paperfig": bm_maybe_enter()
 if chapter == 3: ch3_store_check()
 if dialogue == before_jump:
  append_tip("possess", "附上了！按 Tab 回到现实，再按 E，就能用这个物件的本事。")
 queue_redraw()
 save_game()
 return true

func act() -> void:
 if phase not in ["tutorial","explore","playing"]: return
 if spirit:
  say("阿澄", "先切回现实，才可牵动物件。灵域只供观察和跳跃。")
  return
 if chapter == 6:
  act6()
  return
 if chapter == 5:
  act5()
  return
 if chapter == 4:
  act4()
  return
 if chapter == 3:
  act3()
  return
 if chapter == 2:
  act2()
  return
 match current:
  "incense":
   play_fx("incense")
   say("阿澄", "火星上窜，梁上燕子惊起。我的手……能碰到它们。")
   if phase == "tutorial": phase = "explore"
  "sticks":
   play_fx("sticks")
   if phase == "playing":
    flags.pickup = true
    pickup_left = 18.0
    var first_update: bool = not flags.get("update1",false)
    flags.update1 = true
    say("命运更新①" if first_update else "阿弟", "签文：逢冲则避。阿弟离架两步捡签，但很快会回来。趁现在叫他扶轿！")
   else: say("阿澄", "一支签落在埕边。先按 F 进入「一炷香前」，才能改写这段命运。")
  "palanquin":
   play_fx("palanquin")
   play_sound("bell")
   flags.second_bell = true
   get_tree().create_timer(0.45).timeout.connect(func(): play_sound("bell"))
   if phase == "playing" and flags.get("pickup",false):
    flags.safe = true
    var first_update: bool = not flags.get("update2",false)
    flags.update2 = true
    say("命运更新② · 阿勇" if first_update else "阿勇", "阿弟！轿杠沉，过来扶！【宫内慢半拍又响一铃。小英皱眉。落点下没人了。】")
   else: say("小英", "轿铃之后，宫里又有第二声铃……阿弟还在架下，先让他注意到落签。")
  "candle":
   play_fx("candle")
   if phase == "playing":
    flags.moved = true
    flags.fuse = true
    nodes.crackers[2] = Vector2(1090,450)
    graph.beam = ["palanquin","lantern","crackers"]
    graph.crackers = ["lantern","beam"]
    say("庙祝公", "金纸烧起来了！【扑火，顺手摘下鞭炮，挪到灯架底座石礅；燎过的引线纸可以燃放。】")
   else: say("阿澄", "烛焰斜向金纸。先进入一炷香前。")
  "drum":
   play_sound("drum")
   if phase == "playing":
    flags.drums = flags.get("drums",0) + 1
    if flags.drums >= 3: fail("三下潮鼓震松主绳，原命运提前到来。")
    else: say("阿澄", "鼓震传到灯架。再乱敲，阿弟会来不及离开……（%d／3）" % flags.drums)
   else: say("阿澄", "鼓声惊动全埕。")
  "flag":
   play_fx("flag")
   flags.flag = true
   say("小英／阿勇", "什么声音？【小英望向埕西，背对埕心；旗影扫过，阿勇停手，出发锣暂缓。】")
  "lantern":
   play_fx("lantern")
   flags.lantern = true
   say("阿澄", "花灯亮起、缓缓旋转。灯光照清了主绳的绳结——断口整齐，纤维是被利刃齐齐割开的，绝不是磨断的。这绳……是被人割过一半的。")
  "beam":
   play_fx("beam")
   if phase != "playing":
    say("阿澄", "横木吱呀作响。乱晃只会使它更早倒下。")
   elif flags.get("armed",false):
    fail("横木反复晃动，失去控制，灯架提前倒下。")
   elif flags.get("safe",false) and flags.get("moved",false) and (flags.get("flag",false) or flags.get("cleared",false)):
    flags.armed = true
    say("阿澄", "横木已经晃松。趁停锣清场的空隙，跳向架脚鞭炮燃放。")
   else:
    remaining = maxf(0.0,remaining - 45.0)
    flags.shakes = flags.get("shakes",0) + 1
    say("阿澄", "横木猛晃！灯架更不稳了，香期骤减四十五秒。必须先让阿弟离开、安排震源并停锣或清场。")
    if flags.shakes >= 2 or remaining <= 0: fail("过早摇晃，灯架提前倒下。")
  "crackers":
   if not flags.get("fuse",false): say("阿澄", "引线纸还未燎过，无法燃放。烛台的火能引来庙祝公。")
   else:
    play_sound("crackers")
    if phase == "playing" and flags.get("armed",false): finish()
    else: say("阿澄", "鞭炮炸响，但横木尚未晃松，未能放倒灯架。")
  "loudspeaker":
   play_fx("loudspeaker")
   flags.cleared = true
   say("庙祝公录音", "收埕！闲人离埕心，夜巡暂缓！【备选调度就绪；仍需阿弟扶轿、鞭炮就位，再晃横木燃放。】")
  "horse":
   play_fx("horse")
   flags.horse = true
   say("阿澄", "纸扎马头转向……可我一松手，它自己转回了宫门。那里有什么？")
  "umbrella":
   play_fx("umbrella")
   flags.umbrella = true
   say("阿澄", "油纸伞张开，随风飘向戏台口。现在可以跳到大声公。")
 flash_id = current
 flash_t = 0.0
 obj_anim_id = current
 obj_anim_t = 0.0
 if current == "crackers" and flags.get("fuse", false):
  spark_pos = npos("crackers")
  spark_t = 0.0
 append_tip("act", "对，就是这么用物件的本事：先在灵域选好物件，Tab 回现实，按 E 动手。")
 save_game()
 queue_redraw()

func advance_time(delta: float) -> void:
 if phase != "playing" or spirit: return
 remaining -= delta * time_scale
 if chapter == 2: tick_ch2(delta)
 if chapter == 3: tick_ch3(delta)
 if chapter == 4: tick_ch4(delta)
 if chapter == 5: tick_ch5(delta)
 if chapter == 6: tick_ch6(delta)
 if pickup_left > 0 and not flags.get("safe",false):
  pickup_left -= delta * time_scale
  if pickup_left <= 0:
   flags.pickup = false
   say("阿弟", "签捡到了……我回去绑绳。")
 if remaining <= 0:
  if chapter == 6:
   if phase == "playing": fail6()
  elif chapter == 5:
   if phase == "playing":
    if seg5 == 1: fail5("第一炷香烧到了头。油尽了——长明灯的火苗矮下去，一点一点，灭了。", "lamp_out")
    elif seg5 == 2: fail5("第二炷香烧到了头。阿弟攥着签，到底还是往宫门外去了。", "adi_left")
    else: fail5("第三炷香烧到了头。人没齐，话没说完——守夜的人一个个起身，往宫门外走。", "team_gone")
  elif chapter == 4:
   if flags.get("crossed", false): fail4("第四炷香烧到了头。桥是过了，可它的话还没说完——祠堂的传话先一步抵达，队伍奉命回宫，河埠的灯一盏盏熄了。", "unfinished")
   else: fail4("第四炷香烧到了头。安全前置未齐，队伍照常起轿——行至桥面中段，割伤的栏绳崩断，神轿倾侧，金身受损，巡境当众半途而废。", "bridge_fall")
  elif chapter == 3: fail3()
  elif chapter == 2: fail2("第二炷香烧到了头。土地庙那边摆了摆手，阿勇喊起轿——匾落下来的那一声，隔着一整条街都听得见。", "timeout")
  else: fail("一炷香燃尽，第三下出发锣响，灯架倒下。未完成改命。")
 queue_redraw()

func fail(reason: String) -> void:
 phase = "failure"
 failure_wait = 5.0
 play_fx("rewind")
 if flags.get("safe",false):
  say("阿澄", reason + " 阿弟已经扶轿离开落点，但未能完成安全放倒的闭环。回到香点，仍需烛台、停锣或清场，再晃横木燃放。")
 else:
  say("阿弟的亡魂", reason + " 哥，签筒能叫我离架，神轿能留住我。烛台会让爷爷挪鞭炮。再来一次吧……")

func retry() -> void:
 if chapter == 6:
  retry6()
  return
 if chapter == 5:
  retry5()
  return
 if chapter == 4:
  retry4()
  return
 if chapter == 3:
  retry3()
  return
 if chapter == 2:
  retry2()
  return
 var was_safe: bool = flags.get("safe",false)
 start_game()
 phase = "explore"
 start_incense()
 spirit = true
 say("阿澄" if was_safe else "阿弟的亡魂", "香刚点燃。先看签筒，再听轿铃；架脚的鞭炮，要等烛台引来爷爷。")

func finish() -> void:
 start_shake()
 clear_save()
 ending_t = 0.0
 hook_bell_done = false
 phase = "ending"
 current = "lantern"
 flags.ending = true
 say("阿弟／阿澄", "若我还在下头……【灯架倒向空埕，无人受伤，夜巡推迟。附回花灯残骸，灯光照出绳结整齐的割痕。远处第二声轿铃又响了一次。】")
 play_sound("bell")

func get_stream(kind: String) -> AudioStream:
 if not stream_cache.has(kind):
  stream_cache[kind] = load("res://audio/" + kind + ".wav")
 return stream_cache[kind]

func play_fx(kind: String, db: float = FX_DB) -> void:
 if fx_players.is_empty(): return
 var s = get_stream(kind)
 if s == null: return
 var p: AudioStreamPlayer = fx_players[fx_index]
 fx_index = (fx_index + 1) % fx_players.size()
 p.stream = s
 p.volume_db = db
 p.pitch_scale = 1.0
 p.play()

func set_ambience_pair(realm_kind: String, spirit_kind: String) -> void:
 var kinds = {"realm": realm_kind, "spirit": spirit_kind}
 for key in kinds:
  if not amb_players.has(key): continue
  var p: AudioStreamPlayer = amb_players[key]
  var st = get_stream(kinds[key])
  if st == null or p.stream == st: continue
  if st is AudioStreamWAV:
   st.loop_mode = AudioStreamWAV.LOOP_FORWARD
   st.loop_begin = 0
   st.loop_end = int(st.data.size() / 2)
  p.stream = st
  if amb_on: p.play()

func ch3_store_check() -> void:
 var in_store = current in ["oldcenser", "chest", "sedanrem", "bamboo", "crackers"]
 if in_store == amb3_store_on: return
 amb3_store_on = in_store
 if in_store: set_ambience_pair("amb3_store", "amb3_store")
 else: set_ambience_pair("amb3_realm", "amb3_spirit")

func start_ambience() -> void:
 amb_on = true
 match chapter:
  2: set_ambience_pair("amb2_realm", "amb2_spirit")
  3:
   amb3_store_on = false
   set_ambience_pair("amb3_realm", "amb3_spirit")
  4: set_ambience_pair("amb4_realm", "amb4_spirit")
  5: set_ambience_pair("amb5_realm", "amb5_spirit")
  _: set_ambience_pair("amb_realm", "amb_spirit")
 for key in amb_players:
  var p: AudioStreamPlayer = amb_players[key]
  if not p.playing: p.play()
 amb_targets["spirit"] = 1.0 if spirit else 0.0
 amb_targets["realm"] = 0.0 if spirit else 1.0

func play_bell_low() -> void:
 play_answer("bell")

func play_answer(kind: String) -> void:
 if fx_players.is_empty(): return
 var s = get_stream("answer_" + kind)
 if s == null: return
 var p: AudioStreamPlayer = fx_players[fx_index]
 fx_index = (fx_index + 1) % fx_players.size()
 p.stream = s
 p.volume_db = FX_DB
 p.pitch_scale = 1.0
 p.play()

func answer_kind_for(id: String) -> String:
 if id == "gong": return "gong"
 if id == "drum": return "drum"
 return "bell"

func ls_store():
 if not Engine.has_singleton("JavaScriptBridge"): return null
 var jb = Engine.get_singleton("JavaScriptBridge")
 if jb == null: return null
 return jb.get_interface("localStorage")

func setup_audio_buses() -> void:
 for bname in [BUS_AMB, BUS_FX]:
  if AudioServer.get_bus_index(bname) < 0:
   AudioServer.add_bus()
   var bi = AudioServer.bus_count - 1
   AudioServer.set_bus_name(bi, bname)
   AudioServer.set_bus_send(bi, "Master")

func apply_volumes() -> void:
 var ai = AudioServer.get_bus_index(BUS_AMB)
 if ai >= 0:
  AudioServer.set_bus_volume_db(ai, linear_to_db(maxf(vol_amb, 0.0001)))
  AudioServer.set_bus_mute(ai, vol_mute or vol_amb <= 0.001)
 var fi = AudioServer.get_bus_index(BUS_FX)
 if fi >= 0:
  AudioServer.set_bus_volume_db(fi, linear_to_db(maxf(vol_fx, 0.0001)))
  AudioServer.set_bus_mute(fi, vol_mute or vol_fx <= 0.001)

func save_settings() -> void:
 var ls = ls_store()
 if ls == null: return
 ls.setItem(SETTINGS_KEY, JSON.stringify({"amb": vol_amb, "fx": vol_fx, "mute": vol_mute}))

func load_settings() -> void:
 var ls = ls_store()
 if ls == null: return
 var raw = ls.getItem(SETTINGS_KEY)
 if raw == null: return
 var parsed = JSON.parse_string(str(raw))
 if typeof(parsed) == TYPE_DICTIONARY:
  vol_amb = clampf(float(parsed.get("amb", vol_amb)), 0.0, 1.0)
  vol_fx = clampf(float(parsed.get("fx", vol_fx)), 0.0, 1.0)
  vol_mute = bool(parsed.get("mute", false))

func set_paused(v: bool) -> void:
 if v == paused: return
 if v and phase not in ["tutorial", "explore", "playing", "failure"]: return
 paused = v
 drag_slider = ""
 for key in amb_players: amb_players[key].stream_paused = v
 for p in fx_players: p.stream_paused = v
 if boom_audio != null: boom_audio.stream_paused = v
 if audio != null: audio.stream_paused = v
 queue_redraw()

func pause_restart() -> void:
 set_paused(false)
 if chapter == 6:
  clear_save6()
  start_chapter6()
 elif chapter == 5:
  clear_save5()
  start_chapter5()
 elif chapter == 4:
  clear_save4()
  start_chapter4()
 elif chapter == 3:
  clear_save3()
  start_chapter3()
 elif chapter == 2:
  clear_save2()
  start_chapter2()
 else:
  clear_save()
  start_opening()

func pause_to_title() -> void:
 set_paused(false)
 amb_on = false
 for key in amb_players:
  amb_players[key].stop()
  amb_levels[key] = 0.0
 phase = "title"
 queue_redraw()

func web_platform() -> bool:
 return OS.has_feature("web")

func toggle_fullscreen() -> void:
 if web_platform():
  var jb = Engine.get_singleton("JavaScriptBridge")
  jb.eval("if (document.fullscreenElement) { document.exitFullscreen(); } else { document.documentElement.requestFullscreen(); }")
 else:
  var mode = DisplayServer.window_get_mode()
  DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if mode == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)

func pause_btn_rect() -> Rect2:
 return Rect2(1214, 14, 44, 44)

func fs_btn_rect() -> Rect2:
 return Rect2(1166, 14, 44, 44)

func pause_panel() -> Rect2:
 return Rect2(365, 125, 550, 480)

func pause_btn_row(y: float) -> Rect2:
 return Rect2(440, y, 400, 50)

func slider_track(kind: String) -> Rect2:
 return Rect2(532, 436 if kind == "amb" else 486, 308, 12)

func set_vol_from_x(kind: String, mx: float) -> void:
 var tr = slider_track(kind)
 var v = clampf((mx - tr.position.x) / tr.size.x, 0.0, 1.0)
 if kind == "amb": vol_amb = v
 else: vol_fx = v
 apply_volumes()
 save_settings()

func handle_pause_click(p: Vector2) -> void:
 if pause_btn_row(215).has_point(p):
  set_paused(false)
 elif pause_btn_row(280).has_point(p):
  pause_restart()
 elif pause_btn_row(345).has_point(p):
  pause_to_title()
 elif Rect2(440, 524, 200, 34).has_point(p):
  vol_mute = not vol_mute
  apply_volumes()
  save_settings()
  queue_redraw()
 elif slider_track("amb").grow(8).has_point(p):
  drag_slider = "amb"
  set_vol_from_x("amb", p.x)
 elif slider_track("fx").grow(8).has_point(p):
  drag_slider = "fx"
  set_vol_from_x("fx", p.x)

func draw_top_buttons() -> void:
 if web_platform():
  var fr = fs_btn_rect()
  var fc = fr.get_center()
  draw_circle(fc, 20, Color(0.05, 0.1, 0.18, 0.55))
  draw_arc(fc, 20, 0, TAU, 40, Color(0.45, 0.9, 0.85, 0.8), 2.0)
  for sx in [-1.0, 1.0]:
   for sy in [-1.0, 1.0]:
    draw_line(fc + Vector2(sx * 5, sy * 10), fc + Vector2(sx * 10, sy * 10), Color("d7f5f0"), 2.0)
    draw_line(fc + Vector2(sx * 10, sy * 5), fc + Vector2(sx * 10, sy * 10), Color("d7f5f0"), 2.0)
 if phase in ["tutorial", "explore", "playing", "failure"] and not paused:
  var pr = pause_btn_rect()
  var pc = pr.get_center()
  draw_circle(pc, 20, Color(0.05, 0.1, 0.18, 0.55))
  draw_arc(pc, 20, 0, TAU, 40, Color(0.45, 0.9, 0.85, 0.8), 2.0)
  draw_rect(Rect2(pc + Vector2(-7, -9), Vector2(5, 18)), Color("d7f5f0"))
  draw_rect(Rect2(pc + Vector2(2, -9), Vector2(5, 18)), Color("d7f5f0"))

func draw_pause_button(r: Rect2, label: String) -> void:
 draw_rect(r, Color(0.10, 0.16, 0.26, 0.9))
 draw_rect(r, Color("c9a86a"), false, 1.5)
 var w = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 21).x
 text_at(Vector2(r.position.x + (r.size.x - w) * 0.5, r.position.y + 33), label, 21, Color("e8ecf2"))

func draw_slider_row(kind: String, label: String, v: float) -> void:
 var tr = slider_track(kind)
 text_at(Vector2(440, tr.position.y + 12), label, 19, Color("d7dee8"))
 draw_rect(tr, Color(0.16, 0.22, 0.32, 0.9))
 if v > 0.0:
  draw_rect(Rect2(tr.position, Vector2(tr.size.x * v, tr.size.y)), Color("c9a86a"))
 var knob = Vector2(tr.position.x + tr.size.x * v, tr.position.y + 6)
 draw_circle(knob, 10, Color("ffd98a"))
 draw_arc(knob, 10, 0, TAU, 32, Color(0.05, 0.08, 0.14, 0.8), 2.0)
 text_at(Vector2(856, tr.position.y + 12), "%d%%" % int(round(v * 100.0)), 17, Color("93a7bd"))

func draw_pause_menu() -> void:
 draw_rect(Rect2(0, 0, 1280, 720), Color(0.02, 0.04, 0.08, 0.62))
 var panel = pause_panel()
 draw_rect(panel, Color(0.05, 0.08, 0.15, 0.96))
 draw_rect(panel, Color("c9a86a"), false, 2.0)
 text_at(Vector2(594, 182), "暂 停", 34, Color("a8eeeb"))
 draw_pause_button(pause_btn_row(215), "继续")
 draw_pause_button(pause_btn_row(280), "重新开始本章")
 draw_pause_button(pause_btn_row(345), "回标题")
 draw_slider_row("amb", "环境音", vol_amb)
 draw_slider_row("fx", "效果音", vol_fx)
 var mbox = Rect2(440, 528, 24, 24)
 draw_rect(mbox, Color(0.10, 0.16, 0.26, 0.9))
 draw_rect(mbox, Color("c9a86a"), false, 1.5)
 if vol_mute:
  draw_line(mbox.position + Vector2(5, 5), mbox.position + Vector2(19, 19), Color("ffd98a"), 2.5)
  draw_line(mbox.position + Vector2(19, 5), mbox.position + Vector2(5, 19), Color("ffd98a"), 2.5)
 text_at(Vector2(478, 548), "静音", 20, Color("d7dee8"))
 text_at(Vector2(548, 592), "Esc 继续 · 设置会自动保存", 15, Color("93a7bd"))

func save_game() -> void:
 if phase not in ["tutorial", "explore", "playing", "failure"]: return
 if chapter == 6:
  save_game6()
  return
 if chapter == 5:
  save_game5()
  return
 if chapter == 4:
  save_game4()
  return
 if chapter == 3:
  save_game3()
  return
 if chapter == 2:
  save_game2()
  return
 var data = {"phase": phase, "current": current, "spirit": spirit, "remaining": remaining, "flags": flags, "seen_tips": seen_tips}
 has_save = true
 save_data = data.duplicate(true)
 var ls = ls_store()
 if ls != null: ls.setItem(SAVE_KEY, JSON.stringify(data))

func clear_save() -> void:
 has_save = false
 save_data = {}
 var ls = ls_store()
 if ls != null: ls.removeItem(SAVE_KEY)

func load_save_meta() -> void:
 var ls = ls_store()
 if ls == null: return
 var raw = ls.getItem(SAVE_KEY)
 if raw != null:
  var parsed = JSON.parse_string(str(raw))
  if typeof(parsed) == TYPE_DICTIONARY and parsed.has("flags"):
   save_data = parsed
   has_save = true
 var raw2 = ls.getItem(SAVE_KEY2)
 if raw2 != null:
  var parsed2 = JSON.parse_string(str(raw2))
  if typeof(parsed2) == TYPE_DICTIONARY and parsed2.has("flags"):
   save_data2 = parsed2
   has_save2 = true
 var raw3 = ls.getItem(SAVE_KEY3)
 if raw3 != null:
  var parsed3 = JSON.parse_string(str(raw3))
  if typeof(parsed3) == TYPE_DICTIONARY and parsed3.has("flags"):
   save_data3 = parsed3
   has_save3 = true
 var raw4 = ls.getItem(SAVE_KEY4)
 if raw4 != null:
  var parsed4 = JSON.parse_string(str(raw4))
  if typeof(parsed4) == TYPE_DICTIONARY and parsed4.has("flags"):
   save_data4 = parsed4
   has_save4 = true
 var raw5 = ls.getItem(SAVE_KEY5)
 if raw5 != null:
  var parsed5 = JSON.parse_string(str(raw5))
  if typeof(parsed5) == TYPE_DICTIONARY and parsed5.has("flags"):
   save_data5 = parsed5
   has_save5 = true
 var raw6 = ls.getItem(SAVE_KEY6)
 if raw6 != null:
  var parsed6 = JSON.parse_string(str(raw6))
  if typeof(parsed6) == TYPE_DICTIONARY and parsed6.has("flags"):
   save_data6 = parsed6
   has_save6 = true
 var cv = str(ls.getItem(CLEAR_KEY)) if ls.getItem(CLEAR_KEY) != null else ""
 if cv == "branch":
  all_clear = true
  clear_variant = "branch"
 elif cv != "":
  all_clear = true
  clear_variant = "canon"

func continue_game() -> void:
 if not has_save: return
 var d: Dictionary = save_data
 start_game()
 var ph = str(d.get("phase", "playing"))
 phase = ph if ph in ["tutorial", "explore", "playing"] else "playing"
 current = str(d.get("current", "incense"))
 spirit = bool(d.get("spirit", true))
 remaining = float(d.get("remaining", 240.0))
 flags = (d.get("flags", {}) as Dictionary).duplicate(true)
 for k in ["drums", "shakes"]:
  if flags.has(k): flags[k] = int(flags[k])
 seen_tips = (d.get("seen_tips", {}) as Dictionary).duplicate(true)
 seen_update1 = bool(flags.get("update1", false))
 seen_update2 = bool(flags.get("update2", false))
 pickup_left = 12.0 if flags.get("pickup", false) and not flags.get("safe", false) else 0.0
 if flags.get("moved", false):
  nodes.crackers[2] = Vector2(1090, 450)
  graph.beam = ["palanquin", "lantern", "crackers"]
  graph.crackers = ["lantern", "beam"]
  crackers_snap = true
 say("阿澄", "香还燃着……回到没走完的那一步。")
 queue_redraw()

func start_opening() -> void:
 phase = "opening"
 card_idx = 0
 queue_redraw()

func advance_opening() -> void:
 card_idx += 1
 if card_idx >= CARD_TEXTS.size(): start_game()
 else: queue_redraw()

func draw_sparks() -> void:
 if spark_t < 0.0: return
 for k in range(10):
  var ang = float(k) * 2.4 + fx_time * 3.0
  var dir2 = Vector2(cos(ang), sin(ang))
  draw_line(spark_pos + dir2 * 4.0, spark_pos + dir2 * (10.0 + 9.0 * sin(fx_time * 31.0 + k)), Color(1.0, 0.72, 0.3, 0.9 * (1.0 - spark_t)), 2.0)

func play_sound(kind: String) -> void:
 play_fx(kind)
 if kind == "crackers":
  start_shake()
  play_boom()

func start_shake() -> void:
 shake_t = 0.0

func play_boom() -> void:
 var stream = get_stream("boom")
 if stream != null and boom_audio != null:
  boom_audio.stream = stream
  boom_audio.play()

func append_tip(key: String, line: String) -> void:
 if seen_tips.get(key,false): return
 seen_tips[key] = true
 dialogue = dialogue + "　【" + line + "】"
 history.append("提示：" + line)
 queue_redraw()

func objective_text() -> String:
 if chapter == 6: return objective_text6()
 if chapter == 5: return objective_text5()
 if chapter == 4: return objective_text4()
 if chapter == 3: return objective_text3()
 if chapter == 2: return objective_text2()
 if phase == "tutorial": return "试一试：按 Tab 切到现实，再按 E，用香炉的本事"
 if phase == "explore": return "四处附身看看，准备好了按 F 点香，开始改命"
 if phase == "playing":
  if not flags.get("update1",false): return "救弟弟第一步：附到签筒上，回现实按 E 摇签"
  if not flags.get("safe",false): return "趁阿弟捡签：附到神轿，回现实按 E 晃铃喊他扶轿"
  if not flags.get("moved",false): return "附到供桌烛台按 E 燎金纸，让庙祝公把鞭炮挪到灯架脚"
  if not (flags.get("flag",false) or flags.get("cleared",false)): return "附到标旗按 E 抖响，拖住出发锣（或用大声公清场）"
  if not flags.get("armed",false): return "附到灯架横木按 E，把横木晃松"
  return "最后一步：附到鞭炮串按 E 燃放，放倒灯架！"
 if phase == "failure": return "没关系，马上重新点香，再来一次"
 if phase == "ending": return "第一章完"
 return ""

func hint_text() -> String:
 if chapter == 6: return hint_text6()
 if chapter == 5: return hint_text5()
 if chapter == 4: return hint_text4()
 if chapter == 3: return hint_text3()
 if chapter == 2: return hint_text2()
 if phase == "title": return "按 Enter 或点一下，就能开始。"
 if phase == "tutorial": return "你现在附在大香炉上。按 Tab 切到现实，再按 E，让火星上窜，试试手。"
 if phase == "explore": return "在灵域点发青光的物件可以附身四处看。看够了按 F 点香，进入「一炷香前」开始改命。"
 if phase == "playing":
  if not flags.get("update1",false): return "先去签筒：灵域里点它附身，Tab 回现实按 E 摇签。签落下，阿弟会离开灯架去捡。"
  if not flags.get("safe",false): return "趁阿弟捡签的空当，附到神轿上，Tab 回现实按 E 晃轿铃，阿勇会喊阿弟来扶轿，他就离开落点了。"
  if not flags.get("moved",false): return "阿弟安全了。去供桌烛台按 E，烛火燎到金纸，庙祝公就会顺手把鞭炮挪到灯架脚边。"
  if not (flags.get("flag",false) or flags.get("cleared",false)): return "去标旗按 E 抖响它，吸引大家注意、拖住出发锣；或者开油纸伞飘去大声公，用录音清场。"
  if not flags.get("armed",false): return "去灯架横木按 E，把横木晃松——阿弟已离开、鞭炮已就位，现在晃才安全。"
  return "附到架脚的鞭炮串上按 E 燃放，灯架会倒向空埕，阿弟就得救了！"
 if phase == "failure": return "别慌，不会真死。等一下（或按 Enter）就会重新点香。记住：签筒叫人离架，神轿留人，烛台引来庙祝公挪鞭炮。"
 if phase == "ending": return "第一章完了。按 Enter 回到标题。"
 return "按 Tab 切换灵域／现实，灵域点物件附身，现实按 E 用物件的本事。"

func show_hint() -> void:
 say("提示", hint_text())

func _process(delta: float) -> void:
 if paused:
  queue_redraw()
  return
 advance_time(delta)
 fx_time += delta
 update_npcs(delta)
 if nodes.has("crackers"):
  if crackers_snap:
   crackers_vis = npos("crackers")
   crackers_snap = false
  else:
   crackers_vis = crackers_vis.move_toward(npos("crackers"), delta * 320.0)
 if obj_anim_t >= 0.0:
  obj_anim_t += delta / 0.7
  if obj_anim_t >= 1.0:
   obj_anim_t = -1.0
   obj_anim_id = ""
 if spark_t >= 0.0:
  spark_t += delta / 0.5
  if spark_t >= 1.0: spark_t = -1.0
 if phase == "ending" and ending_t >= 0.0:
  ending_t += delta
  if ending_t >= 0.8 and not hook_bell_done:
   hook_bell_done = true
   play_bell_low()
 if phase == "playing":
  save_tick += delta
  if save_tick >= 5.0:
   save_tick = 0.0
   save_game()
 if jump_t >= 0.0:
  jump_t += delta / 0.35
  if jump_t >= 1.0:
   jump_t = -1.0
   ripple_pos = jump_to_pos
   ripple_t = 0.0
   play_fx("land", -9.0)
 if ripple_t >= 0.0:
  ripple_t += delta / 0.45
  if ripple_t >= 1.0: ripple_t = -1.0
 if fake_t >= 0.0:
  fake_t += delta / 0.8
  if fake_t >= 1.0: fake_t = -1.0
 if realm_t >= 0.0:
  realm_t += delta / 0.3
  if realm_t >= 1.0: realm_t = -1.0
 if shake_t >= 0.0:
  shake_t += delta / 0.2
  if shake_t >= 1.0: shake_t = -1.0
 if fate_t >= 0.0:
  fate_t += delta / 1.2
  if fate_t >= 1.0: fate_t = -1.0
 if flash_t >= 0.0:
  flash_t += delta / 0.4
  if flash_t >= 1.0: flash_t = -1.0
 if flags.get("update1",false) and not seen_update1:
  seen_update1 = true
  fate_text = "命运更新 ①"
  fate_t = 0.0
  play_fx("fate", -5.0)
 if flags.get("update2",false) and not seen_update2:
  seen_update2 = true
  fate_text = "命运更新 ②"
  fate_t = 0.0
  play_fx("fate", -5.0)
 if chapter == 5 and flags.get("update3",false) and not seen_update3:
  seen_update3 = true
  fate_text = "命运更新 ③"
  fate_t = 0.0
  play_fx("fate", -5.0)
 if amb_on:
  for key in amb_players:
   var cur: float = amb_levels[key]
   var tgt: float = amb_targets[key]
   if cur != tgt:
    cur = move_toward(cur, tgt, delta / 0.3)
    amb_levels[key] = cur
    amb_players[key].volume_db = -60.0 + cur * (AMBIENT_DB + 60.0)
 if phase == "failure":
  failure_wait -= delta
  if failure_wait <= 0: retry()
 var cam_goal = 0.0
 if chapter >= 2: cam_goal = clampf(npos(current).x - 640.0, 0.0, 1920.0 if chapter >= 5 else 1280.0)
 cam_x = move_toward(cam_x, cam_goal, delta * 1000.0)
 update_hover()
 sync_art()
 queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo:
  if paused and event.keycode != KEY_ESCAPE: return
  match event.keycode:
   KEY_ENTER:
    if phase == "opening": advance_opening()
    elif phase == "epilogue":
     phase = "title"
     queue_redraw()
    elif phase == "title": start_opening()
    elif phase == "ending":
     if chapter != 1: pause_to_title()
     else: start_game()
    elif phase == "failure": retry()
   KEY_SPACE:
    if phase == "opening": advance_opening()
   KEY_ESCAPE:
    if paused: set_paused(false)
    elif phase == "opening": start_game()
    elif phase in ["tutorial", "explore", "playing", "failure"]: set_paused(true)
   KEY_C:
    if phase == "title" and has_save: continue_game()
   KEY_2:
    if phase == "title":
     if has_save2: continue_game2()
     else: start_chapter2()
   KEY_3:
    if phase == "title":
     if has_save3: continue_game3()
     else: start_chapter3()
   KEY_4:
    if phase == "title":
     if has_save4: continue_game4()
     else: start_chapter4()
    else: time_scale = 4.0
   KEY_5:
    if phase == "title":
     if has_save5: continue_game5()
     else: start_chapter5()
   KEY_6:
    if phase == "title":
     if has_save6: continue_game6()
     else: start_chapter6()
   KEY_T:
    if phase == "title" and all_clear:
     enter_epilogue()
   KEY_TAB: set_spirit(not spirit)
   KEY_E: act()
   KEY_F: start_incense()
   KEY_H: show_hint()
   KEY_R:
    if phase == "failure": retry()
   KEY_1: time_scale = 1.0
 if event is InputEventMouseMotion:
  if paused and drag_slider != "" and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
   set_vol_from_x(drag_slider, get_global_mouse_position().x)
  return
 if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
  var p = get_global_mouse_position()
  if not event.pressed:
   if paused: drag_slider = ""
   return
  if web_platform() and phase != "opening" and fs_btn_rect().has_point(p):
   toggle_fullscreen()
   return
  if paused:
   handle_pause_click(p)
   return
  if phase in ["tutorial", "explore", "playing", "failure"] and pause_btn_rect().has_point(p):
   set_paused(true)
   return
  if phase == "epilogue":
   phase = "title"
   queue_redraw()
   return
  if phase == "opening":
   if Rect2(1152, 18, 110, 40).has_point(p): start_game()
   else: advance_opening()
   return
  if phase == "title":
   if all_clear and Rect2(400, 318, 640, 38).has_point(p):
    enter_epilogue()
    return
   var tb_x = [20.0, 226.0, 432.0, 638.0, 844.0, 1050.0]
   var tb_has = [has_save, has_save2, has_save3, has_save4, has_save5, has_save6]
   var clicked_tb = -1
   for bi in range(6):
    if Rect2(tb_x[bi], 648, 198, 44).has_point(p):
     clicked_tb = bi
     break
   if clicked_tb >= 0:
    if tb_has[clicked_tb] and Rect2(tb_x[clicked_tb] + 150, 648, 48, 44).has_point(p):
     if clicked_tb == 0: clear_save()
     elif clicked_tb == 1: clear_save2()
     elif clicked_tb == 2: clear_save3()
     elif clicked_tb == 3: clear_save4()
     elif clicked_tb == 4: clear_save5()
     else: clear_save6()
    if clicked_tb == 0:
     if has_save: continue_game()
     else: start_opening()
    elif clicked_tb == 1:
     if has_save2: continue_game2()
     else: start_chapter2()
    elif clicked_tb == 2:
     if has_save3: continue_game3()
     else: start_chapter3()
    elif clicked_tb == 3:
     if has_save4: continue_game4()
     else: start_chapter4()
    elif clicked_tb == 4:
     if has_save5: continue_game5()
     else: start_chapter5()
    else:
     if has_save6: continue_game6()
     else: start_chapter6()
   else: start_opening()
   return
  if touch_ui() and phase in ["tutorial", "explore", "playing"]:
   var btns = touch_buttons()
   for b in range(btns.size()):
    if p.distance_to(btns[b]) < 38:
     if b == 0: set_spirit(not spirit)
     elif b == 1: act()
     elif b == 2: start_incense()
     else: show_hint()
     return
  for id in nodes:
   if p.distance_to(npos(id) - Vector2(cam_x, 0)) < 52:
    jump_to(id)
    break

func touch_ui() -> bool:
 if force_touch: return true
 if OS.has_feature("web_android") or OS.has_feature("web_ios"): return true
 if DisplayServer.is_touchscreen_available(): return true
 return DisplayServer.window_get_size().x < 900

func touch_buttons() -> Array:
 return [Vector2(1214, 512), Vector2(1122, 512), Vector2(1030, 512), Vector2(938, 512)]

func text_at(pos: Vector2, value: String, size: int = 18, color: Color = Color.WHITE) -> void:
 draw_string(font,pos,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func _draw() -> void:
 if font == null: return
 var shake_off = Vector2.ZERO
 if shake_t >= 0.0:
  var kk = 1.0 - shake_t
  shake_off = Vector2(sin(fx_time * 140.0), cos(fx_time * 173.0)) * 3.0 * kk
 draw_set_transform(shake_off, 0.0, Vector2.ONE)
 if phase == "title" or phase == "epilogue" or (phase == "ending" and ending_t >= 3.6):
  draw_rect(Rect2(0,0,1280,720),Color("060c17") if spirit else Color("201a20"))
 if phase == "opening":
  if card_idx == 0 and kv_tex != null:
   draw_texture_rect(kv_tex, Rect2(0, 0, 1280, 720), false, Color(0.52, 0.55, 0.62))
  elif card_idx == 1 and bg_tex_realm != null:
   draw_texture_rect_region(bg_tex_realm, Rect2(0, 0, 1280, 720), Rect2(60, 120, 1080, 608))
  elif bg_tex_realm != null:
   draw_texture_rect_region(bg_tex_realm, Rect2(0, 0, 1280, 720), Rect2(520, 180, 1080, 608))
  draw_rect(Rect2(0, 0, 1280, 720), Color(0.02, 0.03, 0.06, 0.42))
  var ct = CARD_TEXTS[card_idx]
  var cw = ct.length() * 37.0
  text_at(Vector2((1280.0 - cw) * 0.5, 385), ct, 36, Color("e8f2ee"))
  text_at(Vector2(505, 640), "点击 / Enter 继续", 19, Color("93a7bd"))
  text_at(Vector2(1172, 48), "跳过", 19, Color("93a7bd"))
  draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
  return
 if phase == "epilogue":
  draw_finale6()
  draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
  return
 if phase == "title":
  for i in range(6):
   var mx = fmod(fx_time * (6.0 + i * 1.7) + i * 260.0, 1560.0) - 140.0
   var my = 90.0 + i * 105.0 + sin(fx_time * 0.35 + i * 1.9) * 16.0
   draw_circle(Vector2(mx,my),120.0 + i * 14.0,Color(0.45,0.62,0.78,0.045))
  var breathe = 0.75 + 0.25 * sin(fx_time * 1.6)
  draw_glow(Vector2(215,215),54.0,Color(1.0,0.72,0.38),0.16 * breathe)
  draw_glow(Vector2(1065,215),54.0,Color(1.0,0.72,0.38),0.16 * breathe)
  draw_circle(Vector2(215,215),13,Color(1.0,0.8,0.5,0.85))
  draw_circle(Vector2(1065,215),13,Color(1.0,0.8,0.5,0.85))
  text_at(Vector2(420,235),"夜 巡",72,Color("a8eeeb"))
  text_at(Vector2(30,305),"第一章 · 一炷香前 ｜ 第二章 · 多出的那顶轿 ｜ 第三章 · 名册上少了一个 ｜ 第四章 · 轿里人借嘴说话 ｜ 第五章 · 守宫一夜 ｜ 第六章 · 把路走完",17)
  text_at(Vector2(300,385),"溪尾村，正月十五夜。你醒来时，香刚点燃。",24)
  text_at(Vector2(330,465),"Enter 开始第一章 · 数字键 2–6 进对应章 · 全六章",22)
  text_at(Vector2(565,525),"怎么玩",26,Color("d8b777"))
  text_at(Vector2(215,565),"你已经死了，是一缕鬼魂，只能附在物件上行动。",20)
  text_at(Vector2(85,600),"Tab 切换灵域／现实：灵域里点发青光的物件跳过去附身；现实里按 E，用这个物件的本事。",20)
  text_at(Vector2(60,635),"目标：每一炷香烧完前，把该改的命运改掉。卡住按 F 重新点香，不会真死。",20)
  if all_clear:
   text_at(Vector2(400,342),"全卷通关 ✓ 把路走完了 · 按 T 回看尾声（次年正月十五）",19,Color("ffd98a"))
  var tb_labels = ["第一章 · 一炷香前", "第二章 · 多出的那顶轿", "第三章 · 名册上少了一个", "第四章 · 轿里人借嘴说话", "第五章 · 守宫一夜", "第六章 · 把路走完"]
  var tb_cont = ["第一章·续上一炷香（C）", "第二章·续第二炷香（2）", "第三章·续第三炷香（3）", "第四章·续第四炷香（4）", "第五章·续守宫夜（5）", "第六章·续最后一炷香（6）"]
  var tb_has2 = [has_save, has_save2, has_save3, has_save4, has_save5, has_save6]
  for bi2 in range(6):
   var bx2 = 20.0 + bi2 * 206.0
   draw_rect(Rect2(bx2, 648, 198, 44), Color(0.10, 0.16, 0.26, 0.85))
   draw_rect(Rect2(bx2, 648, 198, 44), Color("c9a86a"), false, 1.5)
   text_at(Vector2(bx2 + 8, 676), tb_cont[bi2] if tb_has2[bi2] else tb_labels[bi2], 13, Color("ffd98a") if tb_has2[bi2] else Color("d7dee8"))
   if tb_has2[bi2]: text_at(Vector2(bx2 + 158, 676), "重开", 12, Color("93a7bd"))
  draw_top_buttons()
  draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
  return
 if phase == "ending":
  if ending_t < 3.6:
   var da = 0.30 + 0.45 * clampf(ending_t / 3.6, 0.0, 1.0)
   draw_rect(Rect2(0, 0, 1280, 720), Color(0.01, 0.02, 0.05, da))
   for i in range(4):
    var mx2 = fmod(fx_time * (4.0 + i) + i * 340.0, 1500.0) - 110.0
    draw_circle(Vector2(mx2, 430.0 + i * 55.0), 130.0 + i * 22.0, Color(0.55, 0.68, 0.82, 0.05))
   draw_sparks()
   draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
   return
  if chapter == 6:
   draw_finale6()
   draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
   return
  if chapter == 2:
   text_at(Vector2(215,180),"名册八人。阿勇数了三遍——街上站着九个背影。",28,Color("8dded7"))
   text_at(Vector2(300,245),"多出的那个站在小轿旁，一动不动。",24,Color("9dabbc"))
   text_at(Vector2(150,300),"小英压低声音：名册是阿勇管的……可排班换绳，都是祠堂里定的。",20,Color("9dabbc"))
   text_at(Vector2(215,375),"「点名的时候，多了一个。」",42)
   text_at(Vector2(525,465),"第二章完",30,Color("d8b777"))
   text_at(Vector2(455,525),"Enter 返回标题",20)
   draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
   return
  if chapter == 5:
   text_at(Vector2(150,180),"六叔公站在宫门口的暗处，听完所有的话，说：「那最后一程……我来抬。」",24,Color("8dded7"))
   text_at(Vector2(150,245),"天边，已经开始发白。阿勇望着他的背影，把名册翻到被撕掉的那一页装订线处，轻轻按平。",20,Color("9dabbc"))
   text_at(Vector2(190,300),"灯守住了，人留下了，队伍站齐了——真相，是活人自己说完的。",20,Color("9dabbc"))
   text_at(Vector2(300,375),"今夜，宫里的香没有断。",42)
   text_at(Vector2(525,465),"第五章完",30,Color("d8b777"))
   text_at(Vector2(455,525),"Enter 返回标题",20)
   draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
   return
  if chapter == 4:
   text_at(Vector2(150,180),"纸灶借着纸扎人的嘴，一字一顿：「那年……他们没响锣。」",24,Color("8dded7"))
   text_at(Vector2(150,245),"桥那头，祠堂的人传话来：今年巡境，到此为止。队伍回宫，西巷不走了。",20,Color("9dabbc"))
   text_at(Vector2(190,300),"小轿安静地停在棚后，像六十三年前一样，又一次等到了一句「不走了」。",20,Color("9dabbc"))
   text_at(Vector2(300,375),"金身过桥了，它的话，也说完了。",42)
   text_at(Vector2(525,465),"第四章完",30,Color("d8b777"))
   text_at(Vector2(455,525),"Enter 返回标题",20)
   draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
   return
  if chapter == 3:
   text_at(Vector2(190,180),"小英掌心的账页——「纸扎陈阿灶，扎引路纸轿一顶，工钱未结。」",24,Color("8dded7"))
   text_at(Vector2(150,245),"阿澄盯着库房的方向，听见自己在记忆里踩上竹棚的声音——上竹棚之前，他看见库房的灯，亮着。",20,Color("9dabbc"))
   text_at(Vector2(300,375),"今夜，队伍没有散。",42)
   text_at(Vector2(525,465),"第三章完",30,Color("d8b777"))
   text_at(Vector2(455,525),"Enter 返回标题",20)
   draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
   return
  text_at(Vector2(230,180),"花灯残骸照出绳结：整齐的割痕。",28,Color("8dded7"))
  text_at(Vector2(300,245),"远处，第二声轿铃又响了一次。",24,Color("9dabbc"))
  text_at(Vector2(230,375),"今晚的巡境，多走了一条路。",42)
  text_at(Vector2(525,465),"第一章完",30,Color("d8b777"))
  text_at(Vector2(455,525),"Enter 返回标题教学",20)
  draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
  return
 draw_set_transform(shake_off - Vector2(cam_x, 0), 0.0, Vector2.ONE)
 if spirit:
  for id in graph:
   for other in graph[id]:
    draw_line(npos(id),npos(other),Color(0.1,0.45,0.48,0.5),2)
  var occ2 = opp_pos if chapter == 2 else (opp3_pos if chapter == 3 else (opp4_pos if chapter == 4 else (opp5_pos if chapter == 5 else "")))
  if occ2 != "":
   draw_arc(npos(occ2), 26.0 + 4.0 * sin(fx_time * 2.0), 0, TAU, 40, Color(0.75, 0.16, 0.14, 0.75), 2.5)
 for id in nodes:
  var p: Vector2 = npos(id)
  if id == flash_id and flash_t >= 0.0: draw_glow(p,62.0,Color(1.0,0.85,0.45),0.35 * (1.0 - flash_t))
  if spirit:
   var pulse = 1.0 + 0.15 * sin(fx_time * (5.0 if id == current else 2.0) + float(id.hash() % 7))
   var core_col = Color("53f7eb")
   var occ_pos = opp_pos if chapter == 2 else (opp3_pos if chapter == 3 else (opp4_pos if chapter == 4 else (opp5_pos if chapter == 5 else "")))
   if occ_pos != "" and id == occ_pos: core_col = Color(0.45, 0.08, 0.10)
   if chapter == 6 and fog6 != "" and id == fog6: core_col = Color(0.45, 0.08, 0.10)
   draw_circle(p, 8.0 * pulse, core_col)
   if chapter == 4 and bm_active and id == "paperfig":
    draw_arc(p, 15.0, 0, TAU, 40, Color(0.92, 0.76, 0.45, 0.9), 2.5)
    draw_arc(p, 20.0, 0, TAU, 40, Color(0.92, 0.76, 0.45, 0.45), 1.5)
   if chapter == 5 and wait5 and yield5_left <= 0.0 and id == opp5_pos:
    draw_arc(p, 15.0, 0, TAU, 40, Color(0.88, 0.34, 0.26, 0.9), 2.5)
    draw_arc(p, 20.0, 0, TAU, 40, Color(0.88, 0.34, 0.26, 0.45), 1.5)
   if chapter == 6 and fog6 != "" and id == fog6:
    draw_arc(p, 15.0, 0, TAU, 40, Color(0.75, 0.16, 0.14, 0.85), 2.5)
    draw_arc(p, 21.0, 0, TAU, 40, Color(0.45, 0.55, 0.62, 0.55), 1.5)
   var clean_dict = clean4 if chapter == 4 else (clean3 if chapter == 3 else (clean5 if chapter == 5 else (reported_nodes6 if chapter == 6 else clean)))
   if chapter >= 2 and clean_dict.has(id): draw_arc(p, 16.0, 0, TAU, 32, Color(0.85, 0.72, 0.42, 0.8), 2.0)
   if id == current: draw_glow(p, 30.0 * pulse, Color(0.4, 1.0, 0.95), 0.35)
  if id == current: draw_arc(p,45,0,TAU,40,Color("72fff5"),3)
  if id == current or id == hover_id:
   var label = nodes[id][0]
   var lw = label.length() * 19.0 + 16.0
   var lp = p + Vector2(-lw * 0.5, -80)
   draw_rect(Rect2(lp, Vector2(lw, 28)), Color(0.03, 0.06, 0.12, 0.78))
   draw_rect(Rect2(lp, Vector2(lw, 28)), Color("53f7eb") if spirit else Color("c9a86a"), false, 1.0)
   text_at(lp + Vector2(8, 21), label, 17, Color("d7f5f0"))
 if phase in ["tutorial", "explore", "playing", "failure"]:
  if chapter == 2:
   var lp2 = npos("lampstand") + Vector2(0, -26)
   var lr2 = 52.0 * (0.85 + 0.15 * sin(fx_time * 0.9))
   if obj_anim_id == "lampstand" and obj_anim_t >= 0.0: lr2 *= 1.0 + 0.6 * sin(obj_anim_t * PI)
   draw_glow(lp2, lr2, Color(1.0, 0.78, 0.45), 0.13)
   draw_glow(npos("censer") + Vector2(0, -40), 18.0 * (0.85 + 0.15 * sin(fx_time * 2.3)), Color(1.0, 0.62, 0.25), 0.30)
  elif chapter == 3:
   draw_glow(npos("hallcenser") + Vector2(0, -52), 20.0 * (0.85 + 0.15 * sin(fx_time * 2.3)), Color(1.0, 0.62, 0.25), 0.30)
   draw_glow(npos("oldcenser") + Vector2(0, -30), 13.0 * (0.85 + 0.15 * sin(fx_time * 1.7 + 1.1)), Color(1.0, 0.55, 0.25), 0.22)
  elif chapter == 4:
   draw_glow(npos("shrine") + Vector2(0, -40), 18.0 * (0.85 + 0.15 * sin(fx_time * 2.3)), Color(1.0, 0.62, 0.25), 0.30)
   var lg4 = npos("lampstand") + Vector2(0, -26)
   var lr4 = 46.0 * (0.85 + 0.15 * sin(fx_time * 0.9))
   if obj_anim_id == "lampstand" and obj_anim_t >= 0.0: lr4 *= 1.0 + 0.6 * sin(obj_anim_t * PI)
   draw_glow(lg4, lr4, Color(1.0, 0.78, 0.45), 0.13)
   draw_glow(npos("riverlamp") + Vector2(0, -30), 40.0 * (0.85 + 0.15 * sin(fx_time * 1.1 + 0.7)), Color(1.0, 0.78, 0.45), 0.12)
  elif chapter == 5:
   var lamp_frac5 = clampf(remaining / CH5_SEG_DUR[seg5 - 1], 0.0, 1.0)
   if lamp_frac5 > 0.22:
    draw_glow(npos("everlamp") + Vector2(0, -11), lerpf(10.0, 30.0, lamp_frac5) * (0.85 + 0.15 * sin(fx_time * 2.1)), Color(1.0, 0.72, 0.38), 0.30 * lamp_frac5)
   draw_glow(npos("candle") + Vector2(21, 13), 13.0 * (0.85 + 0.15 * sin(fx_time * 2.3)), Color(1.0, 0.62, 0.25), 0.34)
   if seg5 == 3:
    draw_glow(npos("porridge") + Vector2(0, -46), 34.0 * (0.85 + 0.15 * sin(fx_time * 1.3 + 0.5)), Color(1.0, 0.66, 0.34), 0.14)
   if yield5_left > 0.0:
    draw_circle(CH5_YIELD_POS, 7.0, Color(0.45, 0.08, 0.10))
    draw_arc(CH5_YIELD_POS, 16.0, 0, TAU, 32, Color(0.75, 0.16, 0.14, 0.5), 2.0)
  elif chapter == 6:
   draw_glow(npos("everlamp") + Vector2(0, -11), 30.0 * (0.85 + 0.15 * sin(fx_time * 2.1)), Color(1.0, 0.72, 0.38), 0.30)
   if seg6 == 2:
    draw_glow(npos("censer") + Vector2(0, -30), 14.0 * (0.85 + 0.15 * sin(fx_time * 2.3)), Color(1.0, 0.62, 0.25), 0.30)
  else:
   var br_a = 0.85 + 0.15 * sin(fx_time * 0.9)
   var lan_pos = npos("lantern") + Vector2(0, -26)
   var lan_r = 52.0 * br_a
   var lan_al = 0.13 * br_a
   if obj_anim_id == "lantern" and obj_anim_t >= 0.0:
    lan_r *= 1.0 + 0.6 * sin(obj_anim_t * PI)
    lan_al *= 1.8
   draw_glow(lan_pos, lan_r, Color(1.0, 0.78, 0.45), lan_al)
   draw_glow(Vector2(152, 205), 40.0 * (0.85 + 0.15 * sin(fx_time * 0.9 + 2.1)), Color(1.0, 0.74, 0.4), 0.10)
   var cp2 = npos("candle")
   var fl = 1.0
   if obj_anim_id == "candle" and obj_anim_t >= 0.0: fl = 1.0 + 0.9 * sin(obj_anim_t * PI)
   draw_glow(cp2 + Vector2(-14, -48), 15.0 * fl * (0.85 + 0.15 * sin(fx_time * 2.3)), Color(1.0, 0.62, 0.25), 0.38)
   draw_glow(cp2 + Vector2(16, -50), 13.0 * fl * (0.85 + 0.15 * sin(fx_time * 2.3 + 1.3)), Color(1.0, 0.62, 0.25), 0.34)
   if obj_anim_id == "incense" and obj_anim_t >= 0.0:
    for k in range(3):
     draw_circle(npos("incense") + Vector2(sin(fx_time * 2.0 + k) * 6.0, -95 - k * 26), 11.0 + k * 6.0, Color(0.75, 0.82, 0.9, 0.16 * (1.0 - obj_anim_t)))
   if obj_anim_id == "loudspeaker" and obj_anim_t >= 0.0:
    for k in range(2):
     var rr = 18.0 + (obj_anim_t + float(k) * 0.3) * 46.0
     draw_arc(npos("loudspeaker") + Vector2(-52, -6), rr, PI * 0.55, PI * 1.45, 24, Color(0.8, 0.9, 1.0, 0.4 * (1.0 - obj_anim_t)), 2.0)
 draw_sparks()
 if spirit: draw_rect(Rect2(cam_x,0,1280,720),Color(0.25,0.5,0.85,0.08))
 if spirit and jump_t >= 0.0:
  var jt = jump_t * jump_t * (3.0 - 2.0 * jump_t)
  var jp = jump_from.lerp(jump_to_pos,jt)
  var dirv = (jump_to_pos - jump_from).normalized()
  for k in range(3):
   draw_circle(jp - dirv * float(k) * 11.0,6.0 - k,Color(0.45,1.0,0.95,0.35 + 0.2 * float(2 - k)))
  draw_glow(jp,26.0,Color(0.45,1.0,0.95),0.5)
  draw_circle(jp,7,Color("b8fff8"))
 if ripple_t >= 0.0:
  draw_arc(ripple_pos,12.0 + 38.0 * ripple_t,0,TAU,48,Color(0.45,1.0,0.95,0.7 * (1.0 - ripple_t)),3)
 if spirit and chapter == 3 and fake_t >= 0.0:
  var fa2 = 1.0 - fake_t
  draw_line(fake_from, fake_to, Color(0.45, 1.0, 0.95, 0.38 * fa2), 3.0)
  draw_arc(fake_to, 10.0 + 26.0 * fake_t, 0, TAU, 40, Color(0.35, 0.45, 0.5, 0.55 * fa2), 2.5)
 if phase in ["tutorial", "explore", "playing", "failure"] and chapter == 1:
  draw_glow(Vector2(263 + sin(fx_time * 0.8) * 4.0, 488), 20.0, Color(1.0, 0.72, 0.38), 0.10 + 0.03 * sin(fx_time * 1.6))
 if not spirit:
  for i in range(90):
   var sd = float(i) * 137.13
   var rx = fmod(sd * 7.31, 1280.0)
   var ry = fmod(sd * 3.7 + fx_time * (620.0 + fmod(sd, 180.0)), 780.0) - 30.0
   draw_line(Vector2(rx, ry), Vector2(rx - 3.5, ry + 13.0), Color(0.75, 0.85, 0.95, 0.26), 1.0)
  for i in range(5):
   var ph = fmod(fx_time / 2.8 + float(i) * 0.37, 1.0)
   var rc = Vector2(90.0 + fmod(float(i) * 467.7, 1100.0), 512.0 + fmod(float(i) * 89.3, 48.0))
   draw_arc(rc, 3.0 + 15.0 * ph, 0, TAU, 24, Color(0.8, 0.9, 1.0, 0.18 * (1.0 - ph)), 1.0)
 draw_set_transform(shake_off, 0.0, Vector2.ONE)
 text_at(Vector2(30,38),("夜巡 · 一炷香前" if chapter == 1 else ("夜巡 · 多出的那顶轿" if chapter == 2 else ("夜巡 · 名册上少了一个" if chapter == 3 else ("夜巡 · 轿里人借嘴说话" if chapter == 4 else ("夜巡 · 把路走完" if chapter == 6 else "夜巡 · 守宫一夜"))))) + "  |  " + ("灵域 · 时间停顿" if spirit else "现实 · 时间流动"),25,Color("7ae8dd"))
 text_at(Vector2(30,77),"Tab 切换　点相邻灵核跳跃　E 使用物件　F 点香回溯　H 提示　1 / 4 时间倍率",19,Color("93a7bd"))
 text_at(Vector2(30,110),"当前："+nodes[current][0]+"  ·  "+nodes[current][1],21,Color("d7dee8"))
 text_at(Vector2(850,112),"香期 %03d 秒 ×%.0f" % [int(maxf(0,remaining)),time_scale],23)
 if phase in ["tutorial","explore","playing","failure"]: text_at(Vector2(30,143),"当前该做："+objective_text(),21,Color("ffd98a"))
 if flags.get("update1",false): text_at(Vector2(1010,143),"命运① ✓",18,Color("e8c789"))
 if flags.get("update2",false): text_at(Vector2(1140,143),"命运② ✓",18,Color("e8c789"))
 if chapter == 5 and flags.get("update3",false): text_at(Vector2(1140,168),"命运③ ✓",18,Color("e8c789"))
 if chapter == 5 and phase in ["playing","failure"]:
  var pips5 = ""
  for pi5 in range(3):
   pips5 += "○" if pi5 < trade5_used else "●"
  text_at(Vector2(700,143),"报到锣记 " + pips5,18,Color("e8c789"))
 if chapter == 6 and phase in ["playing","failure"]:
  var pips6 = ""
  for si6 in range(6):
   pips6 += ("●" if reported6.has(CH6_STATIONS[si6]) else "○") + CH6_STATIONS[si6] + " "
  text_at(Vector2(30,168),"报到 " + pips6,17,Color("e8c789"))
  text_at(Vector2(566,168),"交易锣记 " + ("● 待兑现（余 1）" if trade6_left > 0 else "○ 已兑现"),17,Color("e8c789"))
 draw_rect(Rect2(20,574,1240,132),Color(0.04,0.07,0.16,0.92))
 draw_rect(Rect2(20,574,1240,132),Color("c9a86a"),false,2.0)
 var tag_w = 30 + speaker.length() * 22
 draw_rect(Rect2(36,586,tag_w,30),Color(0.08,0.12,0.24,0.95))
 draw_rect(Rect2(36,586,tag_w,30),Color("c9a86a"),false,1.5)
 text_at(Vector2(48,609),speaker,20,Color("8ef2e6"))
 var lines = wrap_line(dialogue, sixty())
 for i in range(mini(lines.size(),3)):
  text_at(Vector2(40,636+i*25),lines[i],18)
 if phase == "failure": text_at(Vector2(420,557),"命运未改 · 亡魂对话后自动重试 / Enter",22,Color("ff8f86"))
 if realm_t >= 0.0:
  draw_rect(Rect2(0,0,1280,720),Color(0.62,0.74,0.86,sin(realm_t * PI) * 0.55))
 if fate_t >= 0.0:
  var fa = sin(fate_t * PI)
  var ec = Color(0.4,0.95,0.9,0.75 * fa)
  draw_rect(Rect2(0,0,1280,10),ec)
  draw_rect(Rect2(0,710,1280,10),ec)
  draw_rect(Rect2(0,0,10,720),ec)
  draw_rect(Rect2(1270,0,10,720),ec)
  text_at(Vector2(520,205),fate_text,36,Color(0.65,0.97,0.92,fa))
 if touch_ui() and not paused and phase in ["tutorial", "explore", "playing"]:
  var labels = ["域", "E", "F", "H"]
  var btns = touch_buttons()
  for b in range(btns.size()):
   draw_circle(btns[b], 36, Color(0.05, 0.1, 0.18, 0.55))
   draw_arc(btns[b], 36, 0, TAU, 40, Color(0.45, 0.9, 0.85, 0.8), 2.0)
   text_at(btns[b] + Vector2(-11, 8), labels[b], 22, Color("d7f5f0"))
 draw_top_buttons()
 if paused: draw_pause_menu()
 draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func draw_glow(center: Vector2, radius: float, color: Color, alpha: float) -> void:
 var steps = 5
 for s in range(steps):
  var frac = 1.0 - float(s) / float(steps)
  var c = color
  c.a = alpha * (1.0 - frac + 0.2)
  draw_circle(center, radius * frac, c)

func sixty() -> int:
 return 61

func wrap_line(value: String, count: int) -> Array[String]:
 var result: Array[String] = []
 for i in range(0,value.length(),count): result.append(value.substr(i,count))
 return result

func walk_to(target: String) -> bool:
 set_spirit(true)
 var paths: Array = [[current]]
 var visited: Array = [current]
 while not paths.is_empty():
  var path: Array = paths.pop_front()
  if path.back() == target:
   for item in path.slice(1):
    if not jump_to(item): return false
   return true
  for neighbor in graph[path.back()]:
   if neighbor not in visited:
    visited.append(neighbor)
    var next = path.duplicate()
    next.append(neighbor)
    paths.append(next)
 return false

func use_at(target: String) -> void:
 walk_to(target)
 set_spirit(false)
 act()

func capture_scene(kind: String, path: String) -> void:
 if DisplayServer.get_name() == "headless":
  push_error("CAPTURE FAIL: headless display has no rendered framebuffer; use Xvfb or a real display.")
  get_tree().quit(2)
  return
 if kind == "touch": force_touch = true
 if kind == "glyph":
  start_game()
  use_at("incense")
  start_incense()
  for id in ["sticks","palanquin","candle"]: use_at(id)
  realm_t = -1.0
  await get_tree().process_frame
  await get_tree().process_frame
  await RenderingServer.frame_post_draw
  var gerr = get_viewport().get_texture().get_image().save_png(path)
  print("CAPTURE ",kind," ",path," error=",gerr)
  get_tree().quit(gerr)
  return
 if kind == "opening":
  start_opening()
  await get_tree().create_timer(0.7).timeout
  await RenderingServer.frame_post_draw
  var oerr = get_viewport().get_texture().get_image().save_png(path)
  print("CAPTURE ",kind," ",path," error=",oerr)
  get_tree().quit(oerr)
  return
 if kind == "title":
  await get_tree().create_timer(1.2).timeout
  await RenderingServer.frame_post_draw
  var terr = get_viewport().get_texture().get_image().save_png(path)
  print("CAPTURE ",kind," ",path," error=",terr)
  get_tree().quit(terr)
  return
 if kind == "pause":
  start_game()
  use_at("incense")
  start_incense()
  set_paused(true)
  await get_tree().create_timer(0.4).timeout
  await RenderingServer.frame_post_draw
  var perr = get_viewport().get_texture().get_image().save_png(path)
  print("CAPTURE ",kind," ",path," error=",perr)
  get_tree().quit(perr)
  return
 if kind == "ch2" or kind == "ch2spirit" or kind == "ch2east" or kind == "ch2eastspirit":
  start_chapter2()
  use_at("palanquin")
  start_incense()
  walk_to("drum" if kind.begins_with("ch2east") else "lampstand")
  set_spirit(kind == "ch2spirit" or kind == "ch2eastspirit")
  await get_tree().create_timer(1.6).timeout
  await RenderingServer.frame_post_draw
  var cerr = get_viewport().get_texture().get_image().save_png(path)
  print("CAPTURE ",kind," ",path," error=",cerr)
  get_tree().quit(cerr)
  return
 if kind == "ch6" or kind == "ch6spirit" or kind == "ch6alley" or kind == "ch6alleyspirit":
  start_chapter6()
  set_spirit(false)
  act()
  start_incense()
  if kind.begins_with("ch6alley"):
   seg6_begin(5, false)
   walk_to("flag")
  else:
   walk_to("drum")
  set_spirit(kind.ends_with("spirit"))
  await get_tree().create_timer(1.6).timeout
  await RenderingServer.frame_post_draw
  var cerr6 = get_viewport().get_texture().get_image().save_png(path)
  print("CAPTURE ",kind," ",path," error=",cerr6)
  get_tree().quit(cerr6)
  return
 if kind == "ch6temple":
  start_chapter6()
  set_spirit(false)
  act()
  start_incense()
  seg6_begin(2, false)
  walk_to("templebell")
  set_spirit(false)
  await get_tree().create_timer(2.2).timeout
  await RenderingServer.frame_post_draw
  var terr62 = get_viewport().get_texture().get_image().save_png(path)
  print("CAPTURE ",kind," ",path," error=",terr62)
  get_tree().quit(terr62)
  return
 if kind == "ch6door" or kind == "ch6ring" or kind == "ch6dawn" or kind == "ch6dawnr":
  start_chapter6()
  set_spirit(false)
  act()
  start_incense()
  seg6_begin(5, false)
  if kind == "ch6ring": flags["knocked"] = true
  if kind == "ch6dawn" or kind == "ch6dawnr": flags["update1"] = true
  walk_to("doorring")
  set_spirit(kind == "ch6dawn")
  await get_tree().create_timer(2.8).timeout
  await RenderingServer.frame_post_draw
  var derr6 = get_viewport().get_texture().get_image().save_png(path)
  print("CAPTURE ",kind," ",path," error=",derr6)
  get_tree().quit(derr6)
  return
 if kind == "ch6refl0":
  start_chapter6()
  set_spirit(false)
  act()
  start_incense()
  seg6_begin(5, false)
  walk_to("doorring")
  dialogue = ""
  speaker = ""
  set_spirit(true)
  await get_tree().create_timer(3.4).timeout
  await RenderingServer.frame_post_draw
  var rerr0 = get_viewport().get_texture().get_image().save_png(path)
  print("CAPTURE ",kind," ",path," error=",rerr0)
  get_tree().quit(rerr0)
  return
 if kind == "ch6refl" or kind == "ch6reflr":
  start_chapter6()
  set_spirit(false)
  act()
  start_incense()
  seg6_begin(5, false)
  flags["update1"] = true
  walk_to("doorring")
  dialogue = ""
  speaker = ""
  set_spirit(kind == "ch6refl")
  await get_tree().create_timer(3.4).timeout
  await RenderingServer.frame_post_draw
  var rerr6 = get_viewport().get_texture().get_image().save_png(path)
  print("CAPTURE ",kind," ",path," error=",rerr6)
  get_tree().quit(rerr6)
  return
 if kind == "ch6finale":
  phase = "epilogue"
  await get_tree().create_timer(0.8).timeout
  await RenderingServer.frame_post_draw
  var ferr6 = get_viewport().get_texture().get_image().save_png(path)
  print("CAPTURE ",kind," ",path," error=",ferr6)
  get_tree().quit(ferr6)
  return
 if kind == "title6":
  all_clear = true
  await get_tree().create_timer(1.2).timeout
  await RenderingServer.frame_post_draw
  var gerr6 = get_viewport().get_texture().get_image().save_png(path)
  print("CAPTURE ",kind," ",path," error=",gerr6)
  get_tree().quit(gerr6)
  return
 if kind == "ch5" or kind == "ch5spirit" or kind == "ch5mid" or kind == "ch5midspirit" or kind == "ch5east" or kind == "ch5eastspirit" or kind == "ch5lamplow" or kind == "ch5lampdying":
  start_chapter5()
  set_spirit(false)
  act()
  start_incense()
  walk_to("sedanrem" if kind.begins_with("ch5east") else ("paperfig" if kind.begins_with("ch5mid") else "oilpot"))
  if kind == "ch5lamplow": remaining = 80.0
  if kind == "ch5lampdying": remaining = 35.0
  set_spirit(kind.ends_with("spirit"))
  await get_tree().create_timer(1.6).timeout
  await RenderingServer.frame_post_draw
  var cerr5 = get_viewport().get_texture().get_image().save_png(path)
  print("CAPTURE ",kind," ",path," error=",cerr5)
  get_tree().quit(cerr5)
  return
 if kind == "ch4" or kind == "ch4spirit" or kind == "ch4east" or kind == "ch4eastspirit":
  start_chapter4()
  set_spirit(false)
  act()
  start_incense()
  walk_to("boat" if kind.begins_with("ch4east") else "lampstand")
  set_spirit(kind == "ch4spirit" or kind == "ch4eastspirit")
  await get_tree().create_timer(1.6).timeout
  await RenderingServer.frame_post_draw
  var cerr4 = get_viewport().get_texture().get_image().save_png(path)
  print("CAPTURE ",kind," ",path," error=",cerr4)
  get_tree().quit(cerr4)
  return
 if kind == "ch4rope" or kind == "ch4fixed" or kind == "ch4bm" or kind == "ch4sedan":
  start_chapter4()
  set_spirit(false)
  act()
  start_incense()
  if kind == "ch4fixed": flags["reinforced"] = true
  if kind == "ch4sedan": flags["newsedan_done"] = true
  if kind == "ch4bm":
   flags["crossed"] = true
   opp4_pos = "paperfig"
   bm_active = true
   bm_window_open = true
   current = "gong"
  elif kind == "ch4sedan":
   walk_to("boat")
  else:
   current = "bridgerope"
  set_spirit(kind == "ch4bm")
  await get_tree().create_timer(1.6).timeout
  await RenderingServer.frame_post_draw
  var cerrx = get_viewport().get_texture().get_image().save_png(path)
  print("CAPTURE ",kind," ",path," error=",cerrx)
  get_tree().quit(cerrx)
  return
 if kind == "ch3" or kind == "ch3spirit" or kind == "ch3b" or kind == "ch3bspirit":
  start_chapter3()
  set_spirit(false)
  act()
  start_incense()
  walk_to("sedanrem" if kind.begins_with("ch3b") else "teatable")
  set_spirit(kind.ends_with("spirit"))
  await get_tree().create_timer(1.6).timeout
  await RenderingServer.frame_post_draw
  var cerr3 = get_viewport().get_texture().get_image().save_png(path)
  print("CAPTURE ",kind," ",path," error=",cerr3)
  get_tree().quit(cerr3)
  return
 start_game()
 use_at("incense")
 start_incense()
 if kind == "ending" or kind == "hook":
  for id in ["sticks","palanquin","candle","flag","beam","crackers"]: use_at(id)
 elif kind == "walk":
  use_at("sticks")
  set_spirit(false)
  await get_tree().create_timer(2.0).timeout
 else:
  use_at("horse")
  set_spirit(kind == "spirit")
 if kind == "hook":
  var guard = 0.0
  while ending_t < 2.3 and guard < 6.0:
   await get_tree().process_frame
   guard += 0.05
 realm_t = -1.0
 await get_tree().process_frame
 await get_tree().process_frame
 await RenderingServer.frame_post_draw
 var err = get_viewport().get_texture().get_image().save_png(path)
 print("CAPTURE ",kind," ",path," error=",err)
 get_tree().quit(err)

# ================= 第二章「多出的那顶轿」（DESIGN_CH2_DRAFT v0.1 施工） =================

func start_chapter2() -> void:
 chapter = 2
 nodes = CH2_NODES.duplicate(true)
 graph = CH2_GRAPH.duplicate(true)
 phase = "tutorial"
 current = "palanquin"
 prev_current = "palanquin"
 spirit = true
 flags = {}
 remaining = 300.0
 pickup_left = 0.0
 ending_t = -1.0
 hook_bell_done = false
 seen_update1 = false
 seen_update2 = false
 fail_kind = ""
 clean = {}
 opp_pos = "paperfig"
 opp_idx = 0
 opp_timer = 45.0
 window_left = 0.0
 sedan_stay = 0.0
 sedan_attempts = 0
 npc_pos = {"adi": Vector2(1460, 485), "miaozhu": Vector2(120, 455), "xiaoying": Vector2(600, 470), "lianshen": Vector2(648, 482), "ayong": Vector2(1790, 458), "xishu": Vector2(1055, 458)}
 npc_walking = {}
 cam_x = clampf(npos("palanquin").x - 640.0, 0.0, 1280.0)
 say("阿勇／莲婶／细叔", "都齐了？灯架堵了埕口，今晚改走老街！／我这匾的绳，是新换的。／我这店里，今晚没扎过轿。【纸扎店门口，纸扎人的头正缓缓转向神轿。】")
 append_tip("spirit", "这里是灵域，时间是停的。点旁边发青光的物件，就能附过去。")
 start_ambience()
 queue_redraw()

func start_incense2() -> void:
 phase = "playing"
 current = "censer"
 prev_current = "censer"
 nodes = CH2_NODES.duplicate(true)
 graph = CH2_GRAPH.duplicate(true)
 remaining = 300.0
 flags = {}
 clean = {}
 seen_update1 = false
 seen_update2 = false
 fail_kind = ""
 opp_pos = "drum"
 opp_idx = 4
 opp_timer = 45.0
 window_left = 0.0
 sedan_stay = 0.0
 sedan_attempts = 0
 say("庙祝公", "改道走老街的香……要烧得慢些。【第二炷香点燃：香过半，队伍才起轿过桥。街心那头，潮鼓的灵核怎么暗了一块红？】")
 play_fx("rewind", -7.0)
 save_game()

func opp_advance() -> void:
 for step in range(opp_seq.size()):
  opp_idx = (opp_idx + 1) % opp_seq.size()
  var st: String = opp_seq[opp_idx]
  if clean.has(st): continue
  opp_pos = st
  opp_timer = 45.0
  if st == current and phase == "playing": squeeze_out()
  return
 opp_pos = ""
 opp_timer = 45.0

func squeeze_out() -> void:
 var dest = prev_current
 if dest == opp_pos or dest == "" or dest == current: dest = "censer"
 current = dest
 remaining = maxf(0.0, remaining - 10.0)
 sedan_stay = 0.0
 play_fx("rewind", -9.0)
 say("阿澄", "那件物件里猛地一沉——我被挤了出来，香火跟着矮了一截。【被它占住的物件进不去；相邻的响器能把它惊走。】")
 queue_redraw()
 save_game()

func try_scare(id: String) -> bool:
 if opp_pos == "" or opp_pos not in graph.get(current, []): return false
 var from = opp_pos
 if from != "minisedan": clean[from] = true
 var first: bool = not flags.get("update1", false)
 flags.update1 = true
 flags.scare_done = true
 opp_advance()
 if first:
  say("命运更新①", "响声炸开，那件物件里的「东西」被惊走了。【命运更新①：看清它的规矩了——它怕响；被惊走的地方，它不敢再回。】")
 else:
  say("阿澄", "惊走了。它跳去了别处，这件物件它不敢再回。")
 bump_behavior("drive")
 return true

func rhythm_hit(id: String) -> void:
 if flags.get("xiaoying_safe", false) and flags.get("lianshen_safe", false):
  say("阿澄", "锣鼓声滚过骑楼，匾晃了晃，没落下来——绳还吊着一股，得先把它晃松。")
  return
 var key = "drums2" if id == "drum" else "gongs2"
 flags[key] = int(flags.get(key, 0)) + 1
 var n = int(flags[key])
 if n >= 3:
  if not flags.get("xiaoying_safe", false):
   fail2("锣鼓连响三下，假信号提前震落了招牌——小英还在匾下领舞。", "xy_dead")
  else:
   fail2("锣鼓连响三下，假信号提前震落了招牌——莲婶还站在自家匾底下。", "ls_hurt")
 else:
  say("阿澄", "声浪撞上骑楼，匾跟着颤。匾下还有人，再乱敲要出事……（%d／3）" % n)

func play_gong(db: float = FX_DB, pitch: float = 1.0) -> void:
 if fx_players.is_empty(): return
 var s = get_stream("gong")
 if s == null: return
 var p: AudioStreamPlayer = fx_players[fx_index]
 fx_index = (fx_index + 1) % fx_players.size()
 p.stream = s
 p.volume_db = db
 p.pitch_scale = pitch
 p.play()

func act_sound2(id: String) -> void:
 if id == "drum": play_sound("drum")
 else: play_gong()
 if flags.get("loosened", false):
  finish2()
  return
 if try_scare(id): return
 rhythm_hit(id)

func act2() -> void:
 match current:
  "censer":
   play_fx("incense")
   say("阿澄", "火星上窜，土地公的香烟打了个旋。土地公在跟前——难怪它从不近这儿。")
   if phase == "tutorial": phase = "explore"
  "lampstand":
   play_fx("lantern")
   flags.sign_seen = true
   say("阿澄", "花灯举高，光照上茶铺招牌的主绳——断口整齐，纤维是被利刃齐齐割开的，跟灯架那根一模一样。这匾，也是被人割过一半的。")
  "vat":
   play_fx("lantern")
   if flags.get("lianshen_safe", false):
    say("阿澄", "水面又漾了一圈。莲婶已经站在缸边了，匾下没她。")
   else:
    flags.lianshen_safe = true
    say("莲婶", "哎，水缸怎么自个儿漾起来了？【莲婶出门查看，站到缸边同细叔说话——离开了招牌正下方。】")
  "teasign":
   play_fx("beam")
   if flags.get("xiaoying_safe", false) and flags.get("lianshen_safe", false):
    if not flags.get("loosened", false):
     flags.loosened = true
     say("阿澄", "匾身吱呀倾斜，割伤的绳口崩开一线——松动了。只差一记够响的震动：锣、鼓、鞭炮，任一响起来都行。")
    else:
     say("阿澄", "匾已经松动了，就差一记响。")
   else:
    remaining = maxf(0.0, remaining - 45.0)
    flags.sign_shakes = int(flags.get("sign_shakes", 0)) + 1
    if flags.sign_shakes >= 2:
     if not flags.get("xiaoying_safe", false):
      fail2("招牌晃到第二下，割伤的主绳再也吊不住——整匾砸向匾下的人。", "xy_dead")
     else:
      fail2("招牌晃到第二下，割伤的主绳再也吊不住——匾砸下来，碎木划开了莲婶的额头。", "ls_hurt")
    else:
     say("阿澄", "匾晃得吓人，香期骤减四十五秒。匾下还有人——先把人引开，再动它。")
  "umbrella":
   play_fx("umbrella")
   if not flags.get("umbrella", false):
    flags.umbrella = true
    graph.teasign = ["lampstand", "vat", "umbrella"]
    graph.umbrella = ["vat", "paperfig", "teasign"]
   say("阿澄", "油纸伞张开，顺着骑楼的风飘高——现在能直接跳上招牌了。")
  "paperfig":
   play_fx("horse")
   if opp_pos != "":
    say("阿澄", "纸扎人的头缓缓转着，永远朝着一个方向——它在看「它」。顺着它的目光找，不会错。")
   else:
    say("阿澄", "纸扎人的头垂着，一动不动。")
  "crackers":
   if flags.get("crackers_used", false):
    say("阿澄", "鞭炮已经放过了，只剩一地红纸屑。")
   else:
    flags.crackers_used = true
    play_sound("crackers")
    spark_pos = npos("crackers")
    spark_t = 0.0
    if flags.get("loosened", false):
     finish2()
    elif not try_scare("crackers"):
     say("阿澄", "鞭炮在纸扎店门口炸响，红纸屑落了一街。")
  "minisedan":
   play_fx("horse")
   flags.rope_seen = true
   say("阿澄", "掀开轿帘——纸人怀里抱着一截断绳。断口整齐，跟灯架、招牌同款。它把这个，当宝贝收着。")
  "palanquin":
   play_fx("palanquin")
   play_sound("bell")
   get_tree().create_timer(0.5).timeout.connect(func(): play_bell_low())
   if phase == "tutorial":
    phase = "explore"
    say("阿澄", "轿铃响过，街尾小轿那头，慢半拍回了一声。【经香烟路去街口土地庙——庙祝公在那儿等着点第二炷香。准备好了，按 F 点香。】")
   elif flags.get("flagwin", false) and not flags.get("xiaoying_safe", false):
    flags.xiaoying_safe = true
    flags.flagwin = false
    window_left = 0.0
    var first2: bool = not flags.get("update2", false)
    flags.update2 = true
    say("命运更新② · 阿勇" if first2 else "阿勇", "小英！轿杠沉，过来压轿！【小英走至街心神轿旁压轿，不再回匾下。轿铃余音里，小轿方向又回了一声铃——比宫里那次更近、更清。小英皱眉：谁的轿……在回铃？】")
   else:
    say("阿澄", "轿铃响。小轿那头，慢半拍回了一声——它在听。")
  "flag":
   play_fx("flag")
   if not flags.get("xiaoying_safe", false):
    flags.flagwin = true
    window_left = 20.0
    say("小英", "什么响动？【领舞的小英停步，回望街西——趁现在，摇神轿的铃喊她压轿！】")
   else:
    say("阿澄", "旗面抖响。小英已经在神轿边了，用不着再引她。")
  "drum":
   act_sound2("drum")
  "gong":
   act_sound2("gong")
 flash_id = current
 flash_t = 0.0
 obj_anim_id = current
 obj_anim_t = 0.0
 if phase == "playing" and opp_pos != "" and current not in ["drum", "gong", "crackers"] and opp_pos in graph.get(current, []):
  dialogue += "【它不怕这个。】"
 append_tip("act", "对，就是这么用物件的本事：先在灵域选好物件，Tab 回现实，按 E 动手。")
 save_game()
 queue_redraw()

func tick_ch2(delta: float) -> void:
 var step = delta * time_scale
 if opp_pos != "":
  opp_timer -= step
  if opp_timer <= 0.0: opp_advance()
 if window_left > 0.0 and not flags.get("xiaoying_safe", false):
  window_left -= step
  if window_left <= 0.0:
   flags.flagwin = false
   say("小英", "没人喊我？【小英回到茶铺匾下，继续领舞。】")
 if current == "minisedan" and opp_pos != "minisedan":
  sedan_stay += step
  if sedan_stay >= 10.0:
   sedan_stay = 0.0
   var dest2 = prev_current
   if dest2 == "minisedan" or dest2 == "": dest2 = "paperfig"
   current = dest2
   say("阿澄", "轿里一沉，像有什么回来了——我被无声地推了出来。")
   queue_redraw()

func fail2(reason: String, kind: String) -> void:
 phase = "failure"
 failure_wait = 5.0
 fail_kind = kind
 play_fx("rewind")
 if kind == "xy_dead":
  var hint = "哥……标旗能叫我回头，神轿的铃能喊我去压轿。再来一次，先把我叫离匾下。"
  if not flags.get("update1", false):
   hint = "哥……纸扎人的头，一直在看它在哪。锣、鼓、鞭炮，响的能把它惊走。再来一次吧……"
  say("小英的亡魂", reason + " " + hint)
 elif kind == "ls_hurt":
  say("阿澄", reason + " 莲婶伤得不重，可这不算改命。缸里的水能引她出门——先清走匾下的人，再动招牌。回到香点，重来。")
 else:
  say("阿澄", reason + " 若小英还站在匾下，先用标旗开窗口、神轿铃喊她压轿；莲婶要用大水缸引开。回到香点，重来。")

func retry2() -> void:
 clear_save2()
 start_chapter2()
 phase = "explore"
 start_incense2()
 spirit = true
 say("阿澄", "香刚点燃。纸扎人的头会告诉我它在哪；响器能惊走它。先把匾下的人引开，再动招牌。")

func finish2() -> void:
 start_shake()
 play_boom()
 clear_save2()
 ending_t = 0.0
 hook_bell_done = false
 phase = "ending"
 flags.ending = true
 say("小英／莲婶", "又是新绳……断口齐得，像刀裁的。【整匾提前落在空街上，碎木四溅，无人受伤。队伍终于要起轿了——出发前，阿勇按名册点人。】")
 queue_redraw()

func objective_text2() -> String:
 if phase == "tutorial": return "试一试：按 Tab 切到现实，再按 E，摇一摇神轿的铃"
 if phase == "explore": return "沿香烟路去土地公小香炉，准备好了按 F 点第二炷香"
 if phase == "playing":
  if not flags.get("sign_seen", false): return "先调查：附花灯担，回现实按 E 举高，照清招牌的主绳"
  if not flags.get("update1", false) and not flags.get("xiaoying_safe", false): return "潮鼓被它占了：顺纸扎人的头找它，去开道锣按 E 把它惊走"
  if not flags.get("xiaoying_safe", false): return "救小英：标旗按 E 开窗口，再附神轿按 E 摇铃喊她压轿"
  if not flags.get("lianshen_safe", false): return "附大水缸按 E 泛涟漪，引莲婶离开招牌底下"
  if not flags.get("loosened", false): return "人都离匾了：附顺兴招牌按 E，把匾晃松"
  return "最后一记震动：鞭炮燃放，或锣、鼓任一响起来！"
 if phase == "failure": return "没关系，回到香点再来——它占的位置、净标记都会重置"
 if phase == "ending": return "第二章完"
 return ""

func hint_text2() -> String:
 if phase == "title": return "按 Enter 或点一下，就能开始。"
 if phase == "tutorial": return "你附在神轿里。按 Tab 切到现实，再按 E 摇铃，听听街尾的回声。"
 if phase == "explore": return "在灵域点发青光的物件附身四处看。去街口土地公小香炉，准备好了按 F 点第二炷香。"
 if phase == "playing":
  if not flags.get("sign_seen", false): return "先去花灯担：灵域点它附身，Tab 回现实按 E 举高。灯光会照清招牌主绳的断口。"
  if not flags.get("update1", false) and not flags.get("xiaoying_safe", false): return "潮鼓的灵核暗红——它在里面，进不去。纸扎人的头正指着它。去相邻的开道锣（桥头侧）按 E 响一声，响器能把它惊走；被惊走的物件它不敢再回。"
  if not flags.get("xiaoying_safe", false): return "小英还在匾下领舞。先附标旗按 E 抖响，她会停步回望（窗口 20 秒，灵域里不计时）；趁窗口附神轿按 E 摇铃，阿勇会喊她来压轿，她就此离匾。"
  if not flags.get("lianshen_safe", false): return "莲婶还站在自家招牌底下。附大水缸按 E 泛起涟漪，她听见水声会出门查看，站到缸边。"
  if not flags.get("loosened", false): return "匾下没人了。附顺兴招牌按 E 晃它——先把匾晃松，再用一记响震落它。招牌可以从花灯担、水缸过去，开了油纸伞也能直达。"
  return "匾松动了。鞭炮串燃放、潮鼓响、开道锣响，任一记震动都能让它提前落在空街上——震源不论远近。"
 if phase == "failure": return "别慌，不会真死。等一下（或按 Enter）就会回到第二炷香点燃处，它占的位置和净标记都会重置。"
 if phase == "ending": return "第二章完了。按 Enter 回到标题。"
 return "按 Tab 切换灵域／现实，灵域点物件附身，现实按 E 用物件的本事。"

func save_game2() -> void:
 var data = {"phase": phase, "current": current, "spirit": spirit, "remaining": remaining, "flags": flags, "seen_tips": seen_tips, "opp_pos": opp_pos, "opp_idx": opp_idx, "opp_timer": opp_timer, "clean": clean, "window_left": window_left, "sedan_stay": sedan_stay, "sedan_attempts": sedan_attempts}
 has_save2 = true
 save_data2 = data.duplicate(true)
 var ls = ls_store()
 if ls != null: ls.setItem(SAVE_KEY2, JSON.stringify(data))

func clear_save2() -> void:
 has_save2 = false
 save_data2 = {}
 var ls = ls_store()
 if ls != null: ls.removeItem(SAVE_KEY2)

func continue_game2() -> void:
 if not has_save2: return
 var d: Dictionary = save_data2
 start_chapter2()
 var ph = str(d.get("phase", "playing"))
 phase = ph if ph in ["tutorial", "explore", "playing"] else "playing"
 current = str(d.get("current", "censer"))
 prev_current = current
 spirit = bool(d.get("spirit", true))
 remaining = float(d.get("remaining", 300.0))
 flags = (d.get("flags", {}) as Dictionary).duplicate(true)
 for k in ["drums2", "gongs2", "sign_shakes"]:
  if flags.has(k): flags[k] = int(flags[k])
 seen_tips = (d.get("seen_tips", {}) as Dictionary).duplicate(true)
 seen_update1 = bool(flags.get("update1", false))
 seen_update2 = bool(flags.get("update2", false))
 clean = (d.get("clean", {}) as Dictionary).duplicate(true)
 opp_pos = str(d.get("opp_pos", "paperfig"))
 opp_idx = int(d.get("opp_idx", 0))
 opp_timer = float(d.get("opp_timer", 45.0))
 if flags.get("umbrella", false):
  graph.teasign = ["lampstand", "vat", "umbrella"]
  graph.umbrella = ["vat", "paperfig", "teasign"]
 window_left = float(d.get("window_left", 12.0 if flags.get("flagwin", false) else 0.0))
 sedan_stay = float(d.get("sedan_stay", 0.0))
 sedan_attempts = int(d.get("sedan_attempts", 0))
 say("阿澄", "香还燃着……回到没走完的那一步。")
 queue_redraw()

# ================= 第三章「名册上少了一个」（DESIGN_CH3_DRAFT v0.1 施工） =================

func start_chapter3() -> void:
 chapter = 3
 nodes = CH3_NODES.duplicate(true)
 graph = CH3_GRAPH.duplicate(true)
 phase = "tutorial"
 current = "hallcenser"
 prev_current = "hallcenser"
 spirit = true
 flags = {}
 remaining = 330.0
 pickup_left = 0.0
 ending_t = -1.0
 hook_bell_done = false
 seen_update1 = false
 seen_update2 = false
 fail_kind = ""
 clean3 = {}
 squeezed3 = {}
 opp3_pos = "horse"
 opp3_idx = 0
 opp3_timer = 45.0
 jump_count = 0
 last_skill = ""
 window3_left = 0.0
 keeper_out = false
 last_adv_mode = ""
 fake_t = -1.0
 npc_pos = {"liushu": Vector2(850, 478), "keeper": Vector2(455, 462), "shuisheng": Vector2(1150, 472), "xiaoying": Vector2(1010, 478), "ayong": Vector2(1090, 462), "adi": Vector2(1210, 492)}
 npc_walking = {}
 cam_x = clampf(npos("hallcenser").x - 640.0, 0.0, 1280.0)
 say("阿勇／队员", "点名对不上数，祠堂管事说要核对排班——队伍在祠堂前临停查册。／临停查册，不算到站——这站，还欠着。【前坪有人小声念：老爷保号。廊下纸扎马的头，先动了半分。】")
 append_tip("spirit", "这里是灵域，时间是停的。点旁边发青光的物件，就能附过去。")
 start_ambience()
 queue_redraw()

func start_incense3() -> void:
 phase = "playing"
 current = "hallcenser"
 prev_current = "hallcenser"
 nodes = CH3_NODES.duplicate(true)
 graph = CH3_GRAPH.duplicate(true)
 remaining = 330.0
 flags = {}
 clean3 = {}
 squeezed3 = {}
 seen_update1 = false
 seen_update2 = false
 fail_kind = ""
 opp3_pos = "horse"
 opp3_idx = 0
 opp3_timer = 45.0
 jump_count = 0
 last_skill = ""
 window3_left = 0.0
 keeper_out = false
 last_adv_mode = ""
 fake_t = -1.0
 npc_pos = {"liushu": Vector2(850, 478), "keeper": Vector2(455, 462), "shuisheng": Vector2(1150, 472), "xiaoying": Vector2(1010, 478), "ayong": Vector2(1090, 462), "adi": Vector2(1210, 492)}
 npc_walking = {}
 say("阿澄", "神轿临停祠堂前，祠堂燃香接驾。我顺着香烟，落到香案上。【第三炷香点起：临停之内，查清名册、绳源和那句谎——还要把队伍保住。】")
 play_fx("rewind", -7.0)
 save_game()

func opp3_move_to(st: String, mode: String) -> void:
 var from_pos = opp3_pos
 opp3_pos = st
 opp3_idx = opp3_seq.find(st)
 opp3_timer = 45.0
 jump_count = 0
 last_adv_mode = mode
 if mode == "mimic":
  fake_from = npos(from_pos) if from_pos != "" else npos(st)
  fake_to = npos(st)
  fake_t = 0.0
 if st == current and phase == "playing":
  squeeze_out3(st)
 queue_redraw()

func opp3_advance_seq(mode: String) -> void:
 for step in range(1, opp3_seq.size()):
  var ni = (opp3_idx + step) % opp3_seq.size()
  var st: String = opp3_seq[ni]
  if clean3.has(st): continue
  if st == current and squeezed3.has(st): continue
  opp3_move_to(st, mode)
  return
 opp3_timer = 45.0
 jump_count = 0
 last_adv_mode = mode

func opp3_reveal_tip() -> void:
 if flags.get("mimic_revealed", false): return
 flags.mimic_revealed = true
 dialogue += "【它在学你走路。——看纸扎马，它指的才是真的；它落下去的地方，不亮。】"
 history.append("提示：它在学你走路。看纸扎马，它指的才是真的；它落下去的地方，不亮。")
 queue_redraw()

func opp3_advance_mimic() -> void:
 var target = last_skill
 if target != "" and target != opp3_pos and not clean3.has(target) and not (target == current and squeezed3.has(target)):
  opp3_move_to(target, "mimic")
 else:
  opp3_advance_seq("mimic")
 opp3_reveal_tip()

func squeeze_out3(st: String) -> void:
 squeezed3[st] = true
 var dest = prev_current
 if dest == st or dest == "" or dest == current: dest = "hallcenser"
 current = dest
 remaining = maxf(0.0, remaining - 10.0)
 play_fx("rewind", -9.0)
 say("阿澄", "那件物件里猛地一沉——我被挤了出来，香火跟着矮了一截。【它落到了我刚用过的物件上；被占的物件进不去，相邻的响器能把它惊走。】")
 queue_redraw()
 save_game()

func scare3() -> bool:
 if opp3_pos == "" or opp3_pos not in graph.get(current, []): return false
 var from = opp3_pos
 var keep_clean3 = not (from == "teatable" and not flags.get("roster_tonight", false) and not flags.get("lie_heard", false))
 if keep_clean3: clean3[from] = true
 jump_count = 0
 opp3_advance_seq("scare")
 if from == "teatable" and flags.get("roster_tonight", false) and not flags.get("lie_heard", false):
  flags.lie_heard = true
  say("阿澄／水生", "惊走了——茶桌空出来，它学来的坐姿散在半空。【小英拿换绳栏去问水生，水生脱口而出：没有。库房灯一整晚没亮过。——说得太快，快得像背过。阿勇在旁边皱了皱眉。】")
 elif from == "teatable" and not keep_clean3:
  say("阿澄", "惊走了——它在茶桌上学来的坐姿里，藏着一句话没漏出来。【先去翻今晚的名册，再回来惊这一场——有些话，得等看过册子才听得懂。】")
 else:
  say("阿澄", "惊走了。它跳去了别处，这件物件它不敢再回。学步的节奏，也断了。")
 bump_behavior("drive")
 return true

func tick_ch3(delta: float) -> void:
 var step = delta * time_scale
 if opp3_pos != "":
  opp3_timer -= step
  if opp3_timer <= 0.0: opp3_advance_seq("timer")
 if keeper_out and not flags.get("archive_taken", false):
  window3_left -= step
  if window3_left <= 0.0:
   keeper_out = false
   say("阿澄", "六叔公端着续好的水回座，管册老者也回了柜前。窗口过了——再想法子把人引开就是。")

func act3() -> void:
 var pre_all: bool = flags.get("remains_seen", false) and flags.get("account_found", false) and flags.get("memory_seen", false) and flags.get("roster_tonight", false) and flags.get("torn_seen", false) and flags.get("lie_heard", false)
 match current:
  "hallcenser":
   play_fx("incense")
   if phase == "tutorial":
    phase = "explore"
    say("阿澄", "火星上窜，惊起梁上燕子。我的手……能碰到它们。【顺着香烟能去后殿旧香炉——两处香火同源，烟能通，魂也能通。】")
   elif not flags.get("archive_taken", false) and not keeper_out:
    keeper_out = true
    window3_left = 15.0
    say("阿澄", "火星上窜，管册老者起身添香，离开了册柜。【窗口只有 15 秒——趁现在去翻名册。】")
   else:
    say("阿澄", "火星上窜，香烟笔直。祠堂的香，和后殿那炉同源。")
  "roster":
   play_fx("sticks")
   if flags.get("archive_taken", false) or keeper_out:
    if not flags.get("roster_tonight", false):
     flags.roster_tonight = true
     flags.archive_taken = true
     keeper_out = false
     window3_left = 0.0
     say("阿澄／小英", "小英以核对行次为名抱出历年旧档，与今晚排班册分开放。【翻今晚排班册：今晚的人一笔不差；换绳栏明明白白——「库房新绳，水生经手。」绳，出自祠堂库房。】")
    elif not flags.get("torn_seen", false):
     flags.torn_seen = true
     say("阿澄／管册老者", "翻历年旧档——六十三年前那一年的巡境记录，整页不见了，装订线上一排整齐的撕口。这页不是朽烂脱落，是被人整页撕走的。【小英问管册老者，老者答：我爹那辈的事，问我我也说不清。六叔公在一旁斟茶，不阻拦、不动怒，只用一道茶把所有人的火气压在杯沿上。】")
    else:
     say("阿澄", "两册都看全了：换绳出自库房，旧页整页被撕。剩下的，去杂物间找。")
   else:
    say("阿澄", "管册老者守在柜前，寸步不离。当面翻册，等于当面翻脸——得先把人引开。（茶桌的茶盖、香案的火星，都能支开他。）")
  "bell":
   last_skill = "bell"
   play_sound("bell")
   if pre_all and flags.get("flag_raised", false):
    finish3()
   elif scare3():
    pass
   elif pre_all:
    say("阿澄", "钟声散在各自说话的人群里，没人听全。【先以标旗把全场视线聚拢，再敲钟定局。】")
   else:
    say("阿澄", "证据还没齐，现在按不住。【钟声响过，场面只是将起，又缓缓落回去。】")
  "drum":
   last_skill = "drum"
   play_sound("drum")
   if pre_all and flags.get("flag_raised", false):
    finish3()
   elif scare3():
    pass
   elif pre_all:
    say("阿澄", "鼓声滚过前坪，可全场还没看向一处。【先抖标旗聚拢视线，再以响声定局。】")
   else:
    say("阿澄", "鼓声响过前坪。证据还没齐，场面按不住。")
  "teatable":
   last_skill = "teatable"
   play_fx("candle")
   if not flags.get("archive_taken", false) and not keeper_out:
    keeper_out = true
    window3_left = 25.0
    say("阿澄／六叔公", "茶盖轻响。六叔公以为茶凉了，起身续水，顺手把守柜的管事也支去烧水。【册柜前空出 25 秒——趁现在，小英取档。】")
   elif keeper_out:
    say("阿澄", "茶盖又响了一声。六叔公还没回座——窗口还开着，快去名册柜。")
   else:
    say("六叔公", "茶香袅袅。六叔公亲自冲的凤凰单丛，关公巡城，三只品杯一滴不洒：食茶，慢慢查。")
  "flag":
   play_fx("flag")
   if pre_all:
    if not flags.get("flag_raised", false):
     flags.flag_raised = true
     say("阿澄／阿勇", "旗面抖响，压过满坪议论——全场都看向前坪。【小英攥着账页起身要问，又被这一下顿住。就差一声钟（或一记鼓），把场面定住。】")
    else:
     say("阿澄", "全场还看着前坪。就差一声钟，把话说圆。")
   else:
    say("阿澄", "证据还没齐，现在按不住。【旗响了一声，场面只是将起，又缓缓落回去。】")
  "horse":
   last_skill = "horse"
   play_fx("horse")
   if opp3_pos != "":
    say("阿澄", "纸扎马的头缓缓转向——它认魂不认人，永远朝着它此刻所在的地方。轨迹可以假，马头不会假。顺着它找，不会错。")
   else:
    say("阿澄", "纸扎马的头垂着，一动不动。")
  "bamboo":
   last_skill = "bamboo"
   play_fx("beam")
   if not flags.get("memory_seen", false):
    flags.memory_seen = true
    say("阿澄（记忆）", "竹料的触感裂开一道残影——傍晚，我发现割痕后往竹棚走，余光里祠堂库房的灯亮着，灯影里有人站在门口。【脸还没看清，记忆断了。可这一块已经够了：库房的灯亮过——水生，说了谎。】")
   else:
    say("阿澄", "旧竹器轻晃，竹篾声干燥。库房的灯，在记忆里还亮着。")
  "chest":
   play_fx("beam")
   if not flags.get("chest_seen", false):
    flags.chest_seen = true
    say("阿澄", "箱盖轻响。箱底压着当年封存的清单，字迹尚清：「纸轿一顶，拆存。」【封存是真事，拆存是实据。】")
   else:
    say("阿澄", "旧木箱里只有霉味和旧纸。清单看过了。")
  "oldcenser":
   play_fx("incense")
   if not flags.get("ember_seen", false):
    flags.ember_seen = true
    say("阿澄", "余烬微光。炉底泛起一瞬旧火的残影——一盏曾经亮过的灯的形状，只给形状，不给解释。")
   else:
    say("阿澄", "后殿旧香炉，余烬早凉了。烟路那头，就是祠堂香案。")
  "sedanrem":
   play_fx("horse")
   if not flags.get("remains_seen", false):
    flags.remains_seen = true
    flags.account_found = true
    say("阿澄／小英", "掀开牌位布——布上的字被水渍吃掉大半，只剩一个「灶」字的下半截，和「西巷」两个字。【同一拍，小英在旧档夹层里翻到一张漏网的支出账页，一字一字读出声：纸扎陈阿灶，扎引路纸轿一顶，工钱未结。——陈阿灶这个名字，六十三年第一次重新被人读出来。】")
   else:
    say("阿澄", "残件静静躺着。「灶」字下半截，「西巷」二字——轿是他的，人也是他的。")
  "crackers":
   if flags.get("crackers_used", false):
    say("阿澄", "鞭炮已经放过了，只剩一地红纸屑。")
   else:
    flags.crackers_used = true
    play_sound("crackers")
    spark_pos = npos("crackers")
    spark_t = 0.0
    if not scare3():
     say("阿澄", "鞭炮在杂物间门边炸响。这一件响器先行放掉了——B 场少了一件响器，但路不止一条，不至于死局。")
 flash_id = current
 flash_t = 0.0
 obj_anim_id = current
 obj_anim_t = 0.0
 if phase == "playing" and opp3_pos != "" and current not in ["bell", "drum", "crackers"] and opp3_pos in graph.get(current, []):
  dialogue += "【它不怕这个。】"
 append_tip("act", "对，就是这么用物件的本事：先在灵域选好物件，Tab 回现实，按 E 动手。")
 save_game()
 queue_redraw()

func fail3() -> void:
 phase = "failure"
 failure_wait = 5.0
 fail_kind = "timeout"
 play_fx("rewind")
 var hint = "场面还没按住——证据齐了，就先抖标旗聚视线，再敲钟定局。"
 if not flags.get("roster_tonight", false) or not flags.get("torn_seen", false):
  hint = "名册柜还没看全——先以茶盖或火星引开管事，再翻今晚排班册与历年旧档。"
 elif not flags.get("remains_seen", false):
  hint = "杂物间还没去——香烟路（香案—旧香炉）、纸路（经纸扎马）都能过去，残件和账页在那头。"
 say("阿澄", "第三炷香烧到了头。质问在祠堂前当场爆开，队员撂了挑子——队伍在祠堂前散了，今夜的巡境，办不成了。【" + hint + "】回到香点，重来。")

func retry3() -> void:
 clear_save3()
 start_chapter3()
 phase = "explore"
 start_incense3()
 spirit = true
 say("阿澄", "香刚点燃。它会学我走路——看纸扎马指的方向，落点不亮的是它。先引开管事查册，再去杂物间。")

func finish3() -> void:
 start_shake()
 clear_save3()
 ending_t = 0.0
 hook_bell_done = false
 phase = "ending"
 flags.ending = true
 flags.update1 = true
 say("命运更新① · 阿勇", "一声定局。阿勇趁势整队，扬声把话说圆：厝边头尾，有话天亮讲——先过桥！【命运更新①：今夜队伍不会散了——质问推迟到桥头之后，该走的路，一站不会少。小英攥着账页，退后一步。队伍起轿续行。】")
 queue_redraw()

func objective_text3() -> String:
 if phase == "tutorial": return "试一试：按 Tab 切到现实，再按 E，让香案火星上窜"
 if phase == "explore": return "四处附身看看，准备好了按 F 点第三炷香"
 if phase == "playing":
  if not keeper_out and not flags.get("archive_taken", false): return "引开管册老者：附工夫茶桌按 E 茶盖轻响（或香案火星，窗口短）"
  if not flags.get("roster_tonight", false): return "趁窗口附名册按 E 翻页：查今晚排班册的换绳栏"
  if not flags.get("torn_seen", false): return "再附名册按 E 翻历年旧档：找六十三年前那一页"
  if not flags.get("remains_seen", false): return "去后殿杂物间：附纸轿残件按 E 掀布（香烟路／纸路任选）"
  if not flags.get("memory_seen", false): return "附旧竹器按 E 轻晃：触一触那段记忆"
  if not flags.get("flag_raised", false): return "证据齐了：附标旗按 E 抖响，先把全场视线聚拢"
  return "最后一响：附祠堂铜钟按 E（或潮鼓），把场面定住"
 if phase == "failure": return "没关系，回到香点再来——它的位置、净标记、步数都会重置"
 if phase == "ending": return "第三章完"
 return ""

func hint_text3() -> String:
 if phase == "title": return "按 Enter 或点一下，就能开始。"
 if phase == "tutorial": return "你顺香烟落在祠堂香案上。按 Tab 切到现实，再按 E，让火星上窜，试试手。"
 if phase == "explore": return "在灵域点发青光的物件附身四处看。双场景：香案—旧香炉是香烟路，前坪—纸扎马是纸路。准备好了按 F 点第三炷香。"
 if phase == "playing":
  if not keeper_out and not flags.get("archive_taken", false): return "管册老者守着册柜。附工夫茶桌按 E，茶盖一响，六叔公会起身续水、把管事支去烧水，空出 25 秒窗口；附香案火星上窜也能引开管事，只是窗口 15 秒。"
  if not flags.get("roster_tonight", false): return "趁管事不在，附名册按 E 翻今晚排班册——换绳栏写着绳的出处。"
  if not flags.get("torn_seen", false): return "再翻名册，翻历年旧档那一册——六十三年前那一年，整页不见了。"
  if not flags.get("remains_seen", false): return "去后殿杂物间：从香案顺香烟路到旧香炉，或从前坪经纸扎马走纸路。附纸轿残件按 E 掀布，残字和小英的账页会互证。"
  if not flags.get("memory_seen", false): return "附旧竹器按 E 轻晃。竹料的触感里，藏着傍晚的一段记忆。它若被占了，用相邻的鞭炮把它惊走。"
  if not flags.get("flag_raised", false): return "证据齐了。先附标旗按 E 抖响，把全场视线聚到前坪——次序不能反，先旗后钟。"
  return "附祠堂铜钟按 E 响一声定局；铜钟被占或不便时，潮鼓响一声同样整队。"
 if phase == "failure": return "别慌，不会真死。等一下（或按 Enter）就会回到第三炷香点燃处，它的位置、净标记和学步计数都会重置。"
 if phase == "ending": return "第三章完了。按 Enter 回到标题。"
 return "按 Tab 切换灵域／现实，灵域点物件附身，现实按 E 用物件的本事。它每跟你学三步，就抢你刚用过的物件——看纸扎马的头，分辨它真身。"

func save_game3() -> void:
 var data = {"phase": phase, "current": current, "spirit": spirit, "remaining": remaining, "flags": flags, "seen_tips": seen_tips, "opp3_pos": opp3_pos, "opp3_idx": opp3_idx, "opp3_timer": opp3_timer, "clean3": clean3, "jump_count": jump_count, "last_skill": last_skill, "keeper_out": keeper_out, "window3_left": window3_left, "squeezed3": squeezed3}
 has_save3 = true
 save_data3 = data.duplicate(true)
 var ls = ls_store()
 if ls != null: ls.setItem(SAVE_KEY3, JSON.stringify(data))

func clear_save3() -> void:
 has_save3 = false
 save_data3 = {}
 var ls = ls_store()
 if ls != null: ls.removeItem(SAVE_KEY3)

func continue_game3() -> void:
 if not has_save3: return
 var d: Dictionary = save_data3
 start_chapter3()
 var ph = str(d.get("phase", "playing"))
 phase = ph if ph in ["tutorial", "explore", "playing"] else "playing"
 current = str(d.get("current", "hallcenser"))
 prev_current = current
 spirit = bool(d.get("spirit", true))
 remaining = float(d.get("remaining", 330.0))
 flags = (d.get("flags", {}) as Dictionary).duplicate(true)
 seen_tips = (d.get("seen_tips", {}) as Dictionary).duplicate(true)
 seen_update1 = bool(flags.get("update1", false))
 clean3 = (d.get("clean3", {}) as Dictionary).duplicate(true)
 opp3_pos = str(d.get("opp3_pos", "horse"))
 opp3_idx = int(d.get("opp3_idx", 0))
 opp3_timer = float(d.get("opp3_timer", 45.0))
 jump_count = int(d.get("jump_count", 0))
 last_skill = str(d.get("last_skill", ""))
 keeper_out = bool(d.get("keeper_out", false))
 window3_left = float(d.get("window3_left", 12.0 if keeper_out and not flags.get("archive_taken", false) else 0.0))
 squeezed3 = (d.get("squeezed3", {}) as Dictionary).duplicate(true)
 say("阿澄", "香还燃着……回到没走完的那一步。")
 queue_redraw()

# ================= 第四章「轿里人借嘴说话」（DESIGN_CH4_DRAFT v0.1 施工） =================

func ch4_npc_defaults() -> Dictionary:
 return {"miaozhu": Vector2(300, 470), "dengjiang": Vector2(390, 505), "liushu": Vector2(720, 478), "ayong": Vector2(620, 505), "xiaoying": Vector2(830, 485), "adi": Vector2(1010, 500), "shuisheng": Vector2(1180, 485), "xishu": Vector2(2180, 505), "ferryman": Vector2(2420, 505)}

func ch4_reset_state() -> void:
 nodes = CH4_NODES.duplicate(true)
 graph = CH4_GRAPH.duplicate(true)
 flags = {}
 clean4 = {}
 squeezed4 = {}
 seen_update1 = false
 seen_update2 = false
 fail_kind = ""
 opp4_pos = "paperfig"
 opp4_idx = 0
 opp4_timer = 45.0
 bm_active = false
 bm_round = 0
 bm_window_open = false
 bm_window = 0.0
 bm_gap = 0.0
 bm_teach_used = false
 bm_first_done = false
 npc_pos = ch4_npc_defaults()
 npc_walking = {}

func start_chapter4() -> void:
 chapter = 4
 ch4_reset_state()
 phase = "tutorial"
 current = "shrine"
 prev_current = "shrine"
 spirit = true
 remaining = 360.0
 pickup_left = 0.0
 ending_t = -1.0
 hook_bell_done = false
 cam_x = 0.0
 say("庙祝公／阿澄", "过桥先敬土地，香过半，才起轿。【隔桥望去，河埠棚边的纸扎人，头正缓缓转向桥头——它在看过桥的队伍。桥头人群里有人小声说：今年这桥，不知稳不稳当。】")
 append_tip("spirit", "这里是灵域，时间是停的。点旁边发青光的物件，就能附过去。")
 start_ambience()
 queue_redraw()

func start_incense4() -> void:
 chapter = 4
 ch4_reset_state()
 phase = "playing"
 current = "shrine"
 prev_current = "shrine"
 spirit = true
 remaining = 360.0
 pickup_left = 0.0
 ending_t = -1.0
 hook_bell_done = false
 cam_x = 0.0
 say("庙祝公", "过桥香点上了。香过半，才起轿。【第四炷香：桥头一停、过桥、河埠一休整，都在这一炷香里。河埠棚边的纸扎人，灵核已经暗了一块红。】")
 play_fx("rewind", -7.0)
 save_game()

func opp4_move_to(st: String) -> void:
 opp4_pos = st
 opp4_idx = opp4_seq.find(st)
 opp4_timer = 45.0
 if st == current and phase == "playing":
  squeeze_out4(st)
  return
 if st == "paperfig":
  bm_maybe_enter()
 queue_redraw()

func opp4_advance() -> void:
 for step in range(1, opp4_seq.size()):
  var ni = (opp4_idx + step) % opp4_seq.size()
  var st: String = opp4_seq[ni]
  if clean4.has(st): continue
  if st == current and squeezed4.has(st): continue
  opp4_move_to(st)
  return
 opp4_timer = 45.0

func squeeze_out4(st: String) -> void:
 squeezed4[st] = true
 var dest = prev_current
 if dest == st or dest == "" or dest == current: dest = "shrine"
 current = dest
 remaining = maxf(0.0, remaining - 10.0)
 play_fx("rewind", -9.0)
 say("阿澄", "那件物件里猛地一沉——我被挤了出来，香火跟着矮了一截。【被它占住的物件进不去；相邻的响器能把它惊走。】")
 queue_redraw()
 save_game()

func scare4() -> bool:
 if opp4_pos == "" or bm_active: return false
 if opp4_pos not in graph.get(current, []): return false
 var from = opp4_pos
 if from != "paperfig": clean4[from] = true
 opp4_advance()
 say("阿澄", "惊走了。它跳去了别处，这件物件它不敢再回。")
 bump_behavior("drive")
 return true

func bm_maybe_enter() -> void:
 if phase != "playing" or bm_active: return
 if opp4_pos != "paperfig": return
 if not flags.get("crossed", false): return
 if bm_round >= 3: return
 if bm_round == 2 and not flags.get("newsedan_done", false): return
 if bm_round == 2 and not flags.get("memory_seen", false): return
 bm_active = true
 bm_window_open = false
 bm_gap = 3.0
 say("纸扎人", "纸扎人的头，停住了。【嘴部一阵纸响，漏出不成句的字音——它在借纸扎人的嘴说话。它在等回话。】")
 play_fx("borrowmouth")
 queue_redraw()

func bm_open_window() -> void:
 bm_window_open = true
 bm_window = 30.0 if (bm_round == 0 and not bm_first_done) else 20.0
 if bm_round == 0 and not bm_first_done:
  say("阿澄", "「" + BM_FRAGS[bm_round] + "」【锣声轻点……像在回它的话。它说话的时候，响器是回话，不是驱赶——在它旁边的响器（开道锣、神轿）上按 E，应答它。】")
 else:
  say("纸扎人", "「" + BM_FRAGS[bm_round] + "」【它在等回话。】")
 queue_redraw()

func bm_answer() -> void:
 bm_window_open = false
 bm_first_done = true
 play_answer(answer_kind_for(current))
 var r = bm_round
 bm_round += 1
 bump_behavior("answer")
 if r == 0:
  say("纸灶（借嘴）", "「把我的路……」——「……还给我。」【第一句，成句了。活人那头，纸扎人只漏出一阵纸响，和一个「路」字。】")
  bm_gap = 5.0
 elif r == 1:
  flags.update2 = true
  bm_active = false
  say("纸灶（借嘴）／庙祝公／老花灯匠", "「宫门……土地庙……溪尾街……桥头……」——「……西巷。」【命运更新②：它要的不是哪件物件，是西巷那一站。庙祝公听见纸响里漏出的「路」「锣」二字，脸色当场变了，当着小英与阿勇说出旧规：引路小轿本就是巡境的正式编制，是空轿，专供路上捡到的无主之物搭乘；正式经过一站，响器要应答一声，叫「报到」。金身在座的轿，他坐不进去。老花灯匠望着队尾，一字一句：扎那顶轿的人叫陈阿灶，西巷的纸扎匠；那年改道漏了西巷，他妻女没出来，他抱着轿在宫门口等队伍回来补走那一站，等到天亮。老爷保号，没保住他。那个背影走路的样子，像极了当年的灶叔。老人又拉住小英：你是西巷林家的丫头吧？你娘小时候跟我说，铃要响两遍，才算队伍到齐——她听了一辈子少掉的那一遍。】")
  opp4_advance()
 else:
  bm_active = false
  finish4()
  return
 queue_redraw()
 save_game()

func bm_scare_away() -> void:
 bm_active = false
 bm_window_open = false
 bm_gap = 0.0
 say("阿澄", "赶走了……它还会回来。它想说的，还没说。【纸扎人没有留下「净」记——它绕序列一圈，还会回来，把话说完。】")
 bump_behavior("drive")
 opp4_advance()
 queue_redraw()
 save_game()

func ringer_pre4() -> bool:
 if bm_active:
  var adj: bool = current in graph.get("paperfig", [])
  if bm_window_open:
   if adj:
    bm_answer()
   else:
    say("阿澄", "离它太远，它听不见。")
   return true
  if adj:
   if not bm_teach_used:
    bm_teach_used = true
    say("阿澄", "它话没说完——这时候的响，是驱赶，不是回话。【轮次之间它在攒气；等它把碎句说出口，再应答。这一次，不算惊走。】")
   else:
    bm_scare_away()
   return true
  return false
 if scare4(): return true
 return false

func noise4() -> void:
 if flags.get("reinforced", false):
  say("阿澄", "响声滚过桥头。桥栏缠固过了，震一震，不碍事。")
  return
 flags.bridge_noise = int(flags.get("bridge_noise", 0)) + 1
 var n = int(flags.bridge_noise)
 if n >= 3:
  fail4("桥头的响器连敲三下，震动提前崩断了割伤的栏绳——队伍还没上桥，今夜却到此为止了。", "early_break")
 else:
  say("阿澄", "响声撞上桥栏，割口跟着颤。桥栏没加固之前，桥头的响器别乱敲……（%d／3）" % n)

func try_cross4() -> void:
 if flags.get("crossed", false): return
 if not (flags.get("rope_seen", false) and flags.get("warn_done", false) and flags.get("reinforced", false)): return
 flags.crossed = true
 flags.update1 = true
 start_shake()
 say("命运更新① · 阿勇／小英／陈六合", "缠好了——过桥！【队伍起轿过桥：神轿行至桥面中段，栏绳在缠固处绷紧，发出一声闷响——没有断。命运更新①：桥，稳住了，金身安然过桥，桥头的人都亲眼看见了那处断口。河埠落轿，小英当众举起换下来的半截旧栏绳：这不是头一根了。人群里一句话当晚就传开——祠堂的绳，根根都是割的。陈六合伸手摸了摸断口，指尖一缩，「意外」两个字没说出来，只说：先过桥。阿勇整队：厝边头尾，歇脚食口茶再走。】")
 bm_maybe_enter()
 queue_redraw()
 save_game()

func act4() -> void:
 match current:
  "shrine":
   play_fx("shrine")
   if phase == "tutorial":
    phase = "explore"
    say("阿澄", "火星上窜，土地龛的香烟打了个旋。土地公有主之地——它从不近这儿；金身在座的轿，它也坐不进去。【准备好了，按 F 点过桥香。】")
   else:
    say("阿澄", "火星上窜，过桥香的烟笔直。香过半，才起轿。")
  "bridgebell":
   if not ringer_pre4():
    play_fx("bridgebell")
    if not flags.get("warn_bell", false):
     flags.warn_bell = true
     say("阿澄／众人", "铜铃声脆，桥头所有人的头，都抬了起来——看桥栏。【示警第一段：先以铃声把人叫起来。】")
    else:
     noise4()
  "bridgerope":
   play_fx("bridgerope")
   if not flags.get("rope_seen", false):
    flags.rope_seen = true
    say("阿澄", "栏绳在手里一沉——分量不对。新换的栏绳上有一处断口，整齐、系利刃割过一半，与灯架、招牌同款。崩丝是从割口处起的：锣鼓一震、重轿一压，就是原命运。【必达明示：这桥，是被人害的。】")
   elif flags.get("reinforced", false):
    say("阿澄", "缠固三层的栏绳沉甸甸的，割口被压在绳股里。这一段，稳了。")
   else:
    remaining = maxf(0.0, remaining - 45.0)
    flags.rope_shakes4 = int(flags.get("rope_shakes4", 0)) + 1
    if int(flags.rope_shakes4) >= 2:
     fail4("第二下盲晃，割伤的栏绳当场崩断——桥未断、人未上桥，可今夜过桥无望，半程中断。", "early_break")
    else:
     say("阿澄", "栏绳猛晃，割口又崩开一线，香期骤减四十五秒。没加固之前别再晃它——先让活人看见，先加固。")
  "lampstand":
   play_fx("lantern")
   if flags.get("crossed", false) and not flags.get("memory_seen", false):
    flags.memory_seen = true
    say("阿澄（记忆）", "花灯担的竹骨受潮发霉，触感裂开记忆——傍晚，我发现灯架主绳的割痕，攥着绳头去问庙祝公「这口子怎么齐得像刀裁的」，他支吾着没敢接话；我爬上戏台竹棚，脚下脆响；坠落前最后一眼——祠堂库房门口，水生站在那里，看着我，一个字也没说。【死因全揭：四件事，在同一瞬间对上了。我望向桥下的水，想起那一眼里闪过的不是求救，是——他怎么站在库房门口。】")
   elif not flags.get("warn_bell", false):
    say("阿澄", "花灯举高，光扫过桥栏——可没人抬头，白照了。【先有个响动，把桥头的人叫起来，再举灯。】")
   elif not flags.get("warn_lit", false):
    flags.warn_lit = true
    say("阿勇／小英", "灯光沿桥栏扫过去，正照在那处断口上——阿勇和小英，都看见了。【示警第二段：把断口送到他们眼前。】")
   else:
    say("阿澄", "花灯举高，灯光稳稳压在桥栏上。断口在光里，清清楚楚。")
  "drum":
   if not ringer_pre4():
    if flags.get("warn_lit", false) and not flags.get("warn_done", false):
     flags.warn_done = true
     play_sound("drum")
     say("阿勇", "停轿！桥栏有问题！【示警第三段：一记不合节拍的重音——阿勇听出鼓点不对，吼停了队伍。】")
    else:
     play_sound("drum")
     noise4()
  "sedanrope":
   play_fx("sedanrope")
   if not flags.get("reinforced", false):
    flags.reinforced = true
    say("阿勇", "备具坪里绳响了一声——阿勇想起整捆备用轿绳，带人取绳，当众把桥栏割口一段缠固三层。【加固完成：桥栏，稳住了。】")
   else:
    say("阿澄", "轿绳担上，整捆备用绳还码着。桥栏已经缠固，用不上了。")
  "palanquin":
   if not ringer_pre4():
    play_fx("palanquin")
    play_sound("bell")
    say("阿澄", "轿铃响。金身在座的轿——它坐不进去，只能在队尾一带打转。")
  "gong":
   if not ringer_pre4():
    play_gong()
    say("阿澄", "锣声滚过河埠的水面，惊起一串涟漪。")
  "paperfig":
   play_fx("horse")
   if bm_active:
    say("阿澄", "纸扎人的头停住了，嘴部纸响断续——它在借这张嘴说话。等它把碎句说出口，用相邻的响器回它的话。")
   elif opp4_pos != "":
    say("阿澄", "纸扎人的头缓缓转着，永远朝着它此刻所在的地方。纸扎物认魂不认人——顺着它找，不会错。")
   else:
    say("阿澄", "纸扎人的头垂着，一动不动。")
  "papercargo":
   if bm_active and bm_window_open:
    say("阿澄", "它听不懂这个。")
   elif flags.get("update2", false) and not flags.get("newsedan_done", false):
    flags.newsedan_done = true
    play_fx("papercargo")
    say("细叔", "纸料一响，细叔抬起头——当着众人的面摊开竹篾色纸，扎一顶新的引路小轿，手稳得不像在赶夜工：编制里的引路轿，缺一顶正经的。旧的那顶……走了六十三年，该歇了。胶己人的活，慢慢做。【新轿扎成，先在河埠棚下供着。】")
    bm_maybe_enter()
   elif not flags.get("paper_sample_seen", false):
    flags.paper_sample_seen = true
    play_fx("papercargo")
    say("阿澄", "纸料担底压着一张发黄的旧纸样——六十三年前的引路轿轿样，边角有一个「灶」字的起笔。【可选调查：细叔认旧手艺的伏笔。错过也不影响点破。】")
   else:
    play_fx("papercargo")
    say("阿澄", "纸料担沙沙作响。细叔的行李，竹篾色纸码得整整齐齐。")
  "riverlamp":
   play_fx("riverlamp")
   if bm_active and not flags.get("bm_lit", false):
    flags.bm_lit = true
    say("阿澄", "马灯举高，光照在纸扎人脸上——纸响的来源，摆到明处了：它在借纸扎人的嘴说话。【借嘴·必达明示：它开口时，在相邻响器上回它的话。】")
   else:
    say("阿澄", "马灯举高，照亮回程的桥面，也照着棚边。水光在灯下碎成一片。")
  "boat":
   play_fx("boat")
   if not flags.get("boat_seen", false):
    flags.boat_seen = true
    say("船工", "船身轻晃，船工搭话：他爹那辈说，六十三年前涨水的那一夜，是摆渡人把西巷逃出来的人一船一船往高处送。送到的都在，差的那几位，是没等到船。【可选调查：西巷之夜，活人侧的重量。】")
   else:
    say("阿澄", "渡船在索上轻轻晃。渡索那头，系着桥头备具坪的轿绳担。")
 flash_id = current
 flash_t = 0.0
 obj_anim_id = current
 obj_anim_t = 0.0
 if phase == "playing" and not bm_active and opp4_pos != "" and current not in ["bridgebell", "drum", "gong", "palanquin"] and opp4_pos in graph.get(current, []):
  dialogue += "【它不怕这个。】"
 append_tip("act", "对，就是这么用物件的本事：先在灵域选好物件，Tab 回现实，按 E 动手。")
 try_cross4()
 save_game()
 queue_redraw()

func tick_ch4(delta: float) -> void:
 var step = delta * time_scale
 if bm_active:
  if bm_window_open:
   bm_window -= step
   if bm_window <= 0.0:
    bm_window_open = false
    bm_gap = 2.0
    say("纸扎人", "「" + BM_FRAGS[bm_round] + "」【它把碎句又说了一遍——窗口重开，不扣香、不重置轮次。】")
  elif bm_gap > 0.0:
   bm_gap -= step
   if bm_gap <= 0.0:
    bm_open_window()
 elif opp4_pos != "":
  opp4_timer -= step
  if opp4_timer <= 0.0:
   opp4_advance()

func fail4(reason: String, kind: String) -> void:
 phase = "failure"
 failure_wait = 5.0
 fail_kind = kind
 play_fx("rewind")
 if kind == "bridge_fall":
  say("纸扎小轿方向", reason + " 【小轿方向漏出断续纸响，拼出半个字音——「……栏……」它比谁都怕这座桥再断一次。先去桥栏绳看清割口，再铃、光、鼓把人叫停、把桥加固。】")
 elif kind == "unfinished":
  var hint = "它在等回话——应答不是驱赶：等它把碎句说出口，在它旁边的响器上回它。"
  if bm_round >= 1 and not flags.get("update2", false):
   hint = "它数到了桥头就停住——它在等你应答，接上它没走完的那一站。"
  if flags.get("update2", false):
   hint = "先去听它把路线数完；细叔的新引路轿扎成，它才肯把最后一句说完。"
  say("阿澄", reason + " 【" + hint + "】回到香点，重来。")
 else:
  say("阿澄", reason + " 【断在桥下，不是桥上：先让活人看见割口、先加固，再谈过桥。】回到香点，重来。")

func retry4() -> void:
 clear_save4()
 start_chapter4()
 phase = "explore"
 start_incense4()
 spirit = true
 say("阿澄", "香刚点燃。先看桥栏，再铃、光、鼓；它借纸扎人的嘴说话时，响器是回话，不是驱赶。")

func finish4() -> void:
 start_shake()
 clear_save4()
 ending_t = 0.0
 hook_bell_done = false
 phase = "ending"
 flags.ending = true
 say("纸灶（借嘴）", "「那年……」——「……他们没响锣。」【它一字一顿说完，自愿离开纸扎人，退回棚后的小轿方向，雾沉下去。同一拍，桥那头人影晃动——祠堂的人传话到了：今年巡境，到此为止。】")
 queue_redraw()

func objective_text4() -> String:
 if phase == "tutorial": return "试一试：按 Tab 切到现实，再按 E，让土地龛火星上窜"
 if phase == "explore": return "四处附身看看，准备好了按 F 点第四炷香（过桥香）"
 if phase == "playing":
  if not flags.get("rope_seen", false): return "先调查：附桥栏绳按 E 轻晃，摸清栏绳的分量"
  if not flags.get("warn_done", false): return "示警链：铜铃响→花灯担举高照断口→潮鼓重音停队，次序别反"
  if not flags.get("reinforced", false): return "加固：附轿绳担按 E 绳响，让阿勇取备用绳缠固桥栏"
  if not flags.get("crossed", false): return "三项齐备：队伍起轿过桥"
  if not flags.get("update2", false): return "河埠休整：它占住纸扎人借嘴说话——用相邻响器「应答」它，别驱赶"
  if not flags.get("memory_seen", false): return "附上花灯担：竹骨的触感里，有一段完整的记忆"
  if not flags.get("newsedan_done", false): return "附纸料担按 E 纸响：让细叔扎一顶新的引路轿"
  return "回纸扎人旁边：听它把最后一句说完（开道锣／神轿铃应答）"
 if phase == "failure": return "没关系，回到香点再来——它的位置、净标记、对话轮次都会重置"
 if phase == "ending": return "第四章完"
 return ""

func hint_text4() -> String:
 if phase == "title": return "按 Enter 或点一下，就能开始。"
 if phase == "tutorial": return "你顺神轿香火落在桥头土地龛上。按 Tab 切到现实，再按 E，让火星上窜，试试手。"
 if phase == "explore": return "在灵域点发青光的物件附身四处看。整张长卷自一开始就全域可达：桥头、桥面、河埠任走。准备好了按 F 点过桥香。"
 if phase == "playing":
  if not flags.get("rope_seen", false): return "先附桥栏绳按 E 轻晃一次——只调查这一次不扣香。栏绳的分量不对，断口是明示给你的。"
  if not flags.get("warn_done", false): return "示警链次序写死：先附系桥铜铃按 E 响（把人叫起来），再附花灯担按 E 举高（把断口照给他们看），最后附潮鼓按 E 一记重音（阿勇吼停队伍）。次序错只给反馈、不扣香。铜铃若被它占了，先在相邻的潮鼓上把它惊走。"
  if not flags.get("reinforced", false): return "附轿绳担按 E 绳响：阿勇会想起备具坪的整捆备用轿绳，带人把桥栏割口缠固三层。加固也可以赶在示警链之前做。"
  if not flags.get("crossed", false): return "割口已明示、队伍已停、桥栏已加固——再动手做任一步，队伍就起轿过桥。"
  if not flags.get("update2", false): return "它占住纸扎人时若头停住、灵核起环纹，就是借嘴态：它在等回话。等窗口打开（它说出碎句），去相邻的开道锣或神轿上按 E——那是应答，不是驱赶。窗口外在轮次间隙驱赶它，它不记「净」，绕一圈还会回来续接。"
  if not flags.get("memory_seen", false): return "回桥头附上花灯担：竹骨受潮的触感会裂开完整的记忆——发现割痕、问庙祝公、上竹棚、最后一眼的库房门口。"
  if not flags.get("newsedan_done", false): return "附纸料担按 E 纸响：细叔会当众扎一顶新的引路轿。它把话说完的这一夜，活人那头也得有一件东西做成。"
  return "它回到纸扎人借嘴，说出「那年……」——在相邻的开道锣或神轿上按 E 应答，接上最后一句。"
 if phase == "failure": return "别慌，不会真死。等一下（或按 Enter）就会回到第四炷香点燃处，它的位置、净标记和对话轮次都会重置。"
 if phase == "ending": return "第四章完了。按 Enter 回到标题。"
 return "按 Tab 切换灵域／现实，灵域点物件附身，现实按 E 用物件的本事。它说话时，响器是回话；它不说话时，响器才是驱赶。"

func save_game4() -> void:
 var data = {"phase": phase, "current": current, "spirit": spirit, "remaining": remaining, "flags": flags, "seen_tips": seen_tips, "opp4_pos": opp4_pos, "opp4_idx": opp4_idx, "opp4_timer": opp4_timer, "clean4": clean4, "bm_round": bm_round, "bm_first_done": bm_first_done, "bm_teach_used": bm_teach_used, "squeezed4": squeezed4, "bm_active": bm_active, "bm_window_open": bm_window_open, "bm_window": bm_window, "bm_gap": bm_gap}
 has_save4 = true
 save_data4 = data.duplicate(true)
 var ls = ls_store()
 if ls != null: ls.setItem(SAVE_KEY4, JSON.stringify(data))

func clear_save4() -> void:
 has_save4 = false
 save_data4 = {}
 var ls = ls_store()
 if ls != null: ls.removeItem(SAVE_KEY4)

func continue_game4() -> void:
 if not has_save4: return
 var d: Dictionary = save_data4
 start_chapter4()
 var ph = str(d.get("phase", "playing"))
 phase = ph if ph in ["tutorial", "explore", "playing"] else "playing"
 current = str(d.get("current", "shrine"))
 prev_current = current
 spirit = bool(d.get("spirit", true))
 remaining = float(d.get("remaining", 360.0))
 flags = (d.get("flags", {}) as Dictionary).duplicate(true)
 seen_tips = (d.get("seen_tips", {}) as Dictionary).duplicate(true)
 seen_update1 = bool(flags.get("update1", false))
 seen_update2 = bool(flags.get("update2", false))
 clean4 = (d.get("clean4", {}) as Dictionary).duplicate(true)
 opp4_pos = str(d.get("opp4_pos", "paperfig"))
 opp4_idx = int(d.get("opp4_idx", 0))
 opp4_timer = float(d.get("opp4_timer", 45.0))
 bm_round = int(d.get("bm_round", 0))
 bm_first_done = bool(d.get("bm_first_done", false))
 bm_teach_used = bool(d.get("bm_teach_used", false))
 bm_active = bool(d.get("bm_active", false))
 bm_window_open = bool(d.get("bm_window_open", false))
 bm_window = float(d.get("bm_window", 0.0))
 bm_gap = float(d.get("bm_gap", 0.0))
 squeezed4 = (d.get("squeezed4", {}) as Dictionary).duplicate(true)
 if not bm_active: bm_maybe_enter()
 say("阿澄", "香还燃着……回到没走完的那一步。")
 queue_redraw()

# ================= 第五章「守宫一夜」（DESIGN_CH5_DRAFT v0.1 施工） =================

func ch5_npc_defaults() -> Dictionary:
 return {"miaozhu": Vector2(560, 470), "xiaoying": Vector2(660, 495), "ayong": Vector2(2160, 470), "adi": Vector2(2060, 505), "lianshen": Vector2(1720, 510), "shuisheng": Vector2(1360, 495), "liushu": Vector2(2330, 460), "xishu": Vector2(2680, 505), "laobo": Vector2(2340, 515)}

func ch5_reset_state() -> void:
 nodes = CH5_NODES.duplicate(true)
 graph = CH5_GRAPH.duplicate(true)
 flags = {}
 clean5 = {}
 squeezed5 = {}
 seg5 = 1
 trade5_used = 0
 seg5_snap = {}
 seen_update1 = false
 seen_update2 = false
 seen_update3 = false
 fail_kind = ""
 opp5_pos = "candle"
 opp5_idx = 1
 opp5_timer = 45.0
 wait5 = false
 wait5_left = 0.0
 yield5_left = 0.0
 yield5_from = ""
 adi5_left = 0.0
 adi5_pause = 0.0
 bang5_used = false
 teach5_done = false
 teach5_scare = false
 beat5_done = false
 npc_pos = ch5_npc_defaults()
 npc_walking = {}

func start_chapter5() -> void:
 chapter = 5
 ch5_reset_state()
 phase = "tutorial"
 current = "everlamp"
 prev_current = "everlamp"
 spirit = true
 remaining = 180.0
 pickup_left = 0.0
 ending_t = -1.0
 hook_bell_done = false
 cam_x = 0.0
 say("庙祝公／阿澄", "队伍奉命回宫，停办令先一步传回，宫里的人正在散。庙祝公站在正殿门口，攥着那盏熄了十年的长明灯，从神龛底下摸出自己留了十年的半瓶陈油，亲手把灯重新点起来，对小英说：「宫里的香，还没断。」阿勇把名册往怀里一塞，站到宫门口：「数人我来。少一个，我第一个不答应。」【半程巡境：不出巡，只把今晚的队伍、灯火和话，都守到能说完的时候。】")
 append_tip("spirit", "这里是灵域，时间是停的。点旁边发青光的物件，就能附过去。")
 start_ambience()
 queue_redraw()

func start_incense5() -> void:
 chapter = 5
 ch5_reset_state()
 seg5_begin(1, true)

func seg5_begin(n: int, announce: bool, resnap: bool = true) -> void:
 seg5 = n
 if resnap:
  seg5_snap = {"trade": trade5_used, "clean": clean5.duplicate(true), "flags": flags.duplicate(true)}
 remaining = CH5_SEG_DUR[n - 1]
 current = "everlamp"
 prev_current = "everlamp"
 spirit = true
 squeezed5 = {}
 yield5_left = 0.0
 yield5_from = ""
 adi5_pause = 0.0
 adi5_left = 120.0 if n == 2 else 0.0
 npc_pos = ch5_npc_defaults()
 npc_walking = {}
 var st: String = CH5_SEG_OPEN[n - 1]
 opp5_pos = st
 opp5_idx = opp5_seq.find(st)
 opp5_timer = 45.0
 wait5 = true
 wait5_left = 25.0 if (n == 1 and not teach5_done) else 15.0
 play_fx("waitstill")
 if n == 1: teach5_done = true
 phase = "playing"
 if announce:
  if n == 1:
   say("庙祝公", "第一炷守宫香点上了。【守灯：长明灯只添了半瓶陈油，烧不到天亮。先附长明灯拨芯，看清油面。】")
   dialogue += "【阿澄自语：它在等我开价……锣轻点，尾音放长——我替它响这一站，它让一步。系统提示：它静候的时候，响器是开价，不是驱赶。开价只有三次。】"
  elif n == 2:
   say("阿澄", "更梆响过一记，第二炷香点起。【守人：阿弟攥着那支签，坐在宫门边——桥头那句流言，他听见了。】")
  else:
   say("阿澄", "第三炷香点起。【守队伍：埕角那几个人还没走，也没站回来。今夜的话，要说给齐人听。】")
 play_fx("rewind", -7.0)
 save_game()
 queue_redraw()

func opp5_move_to(st: String) -> void:
 opp5_pos = st
 opp5_idx = opp5_seq.find(st)
 opp5_timer = 45.0
 wait5 = true
 wait5_left = 15.0
 play_fx("waitstill")
 if st == current and phase == "playing":
  squeeze_out5(st)
 queue_redraw()

func opp5_advance_from(from: String) -> void:
 var start_i = opp5_seq.find(from)
 for step in range(1, opp5_seq.size()):
  var ni = (start_i + step) % opp5_seq.size()
  var st: String = opp5_seq[ni]
  if clean5.has(st): continue
  if st == current and squeezed5.has(st): continue
  opp5_move_to(st)
  return
 opp5_move_to(from)

func opp5_advance() -> void:
 opp5_advance_from(opp5_pos)

func squeeze_out5(st: String) -> void:
 squeezed5[st] = true
 var dest = prev_current
 if dest == st or dest == "" or dest == current: dest = "everlamp"
 current = dest
 remaining = maxf(0.0, remaining - 10.0)
 play_fx("rewind", -9.0)
 say("阿澄", "那件物件里猛地一沉——我被挤了出来，香火跟着矮了一截。【被它占住的物件进不去；它静候时响器是开价，普通占位时响器是驱赶。】")
 queue_redraw()
 save_game()

func scare5() -> bool:
 if opp5_pos == "" or wait5 or yield5_left > 0.0: return false
 if opp5_pos not in graph.get(current, []): return false
 var from = opp5_pos
 if seg5 == 1 and from == "candle" and not teach5_scare and not flags.get("trade1_done", false):
  teach5_scare = true
  say("阿澄", "赶走了……可灯旁的位子，它还会回来。得跟它买。【惊走只是驱赶，不是报到——这一站没有留下「净」记。】")
 else:
  say("阿澄", "惊走了。它绕去别处——赶得走它，报不了到，这一站没有留下「净」记。")
 bump_behavior("drive")
 opp5_advance()
 queue_redraw()
 save_game()
 return true

func trade5_do(station: String) -> void:
 trade5_used += 1
 bump_behavior("answer")
 clean5[station] = true
 wait5 = false
 opp5_pos = ""
 yield5_left = 120.0
 yield5_from = station
 play_answer(answer_kind_for(current))
 play_fx("trade")
 play_fx("yieldcue", -6.0)
 if station == "candle" and seg5 == 1:
  flags.trade1_done = true
  say("阿澄", "锣声轻点，尾音放长——【应答版】这一声，是替它报到：正殿站，报「回宫」。它雾退到宫埕边缘的小轿处候着，灯旁的位子，让出来了。【交易一成立：让位窗口 120 秒内，小英能近灯添油。报到锣记，用去一枚。】")
 elif station == "paperfig" and seg5 == 2:
  flags.update2 = true
  seg5_begin(3, false)
  say("阿澄／阿弟", "锣声轻点，尾音放长——替它报到：宫埕站，报「宫门」。它离开纸扎人，退场时打宫门方向过——纸扎人的头追着它，缓缓转过去，正对上站在宫门口的阿弟。阿弟钉住了：它在看我。他攥签的手，慢慢松开，走回埕心，在神轿的轿杠边坐下。【命运更新②：要走的人，留下来了。更梆响过一记，第三炷香点起——守队伍。】")
 else:
  var report = "回宫" if station == "candle" else "宫门"
  say("阿澄", "锣声轻点，尾音放长——替它报到：「" + report + "」。它退到小轿处候位，让出这一站。【交易成立：让位窗口 120 秒；这一站，本章内它不再回来。】")
 save_game()
 queue_redraw()

func trade_pre5() -> bool:
 if seg5 == 3 and flags.get("verse_done", false) and not flags.get("rope_done", false) and current == "palanquin": return false
 if yield5_left > 0.0 or opp5_pos == "": return false
 var is_ringer = current in ["drum", "gong", "palanquin"]
 var adj = opp5_pos in graph.get(current, [])
 if wait5:
  if is_ringer:
   if not adj:
    say("阿澄", "离它太远，它听不见。")
    return true
   if seg5 == 3 and opp5_pos == "paperfig":
    if not beat5_done:
     beat5_done = true
     wait5 = false
     opp5_pos = ""
     yield5_left = 30.0
     yield5_from = "beat"
     play_answer("bell")
     say("阿澄", "「最后一次，等你回家的时候，我亲手给你报到。」【响器以应答版轻响一声——它雾动如点头，自愿让开。宫埕地面上，一条淡淡的雾径一闪而过，指向西巷。】")
    else:
     say("阿澄", "不用了。最后一次，留着——留到送它回家的那一站。")
    return true
   if trade5_used >= 2:
    say("阿澄", "「最后一次，等你回家的时候，我亲手给你报到。」【报到锣记只剩最后一枚——那一枚，开价判定不开。它听得懂，雾动了动，没有催。】")
    return true
   trade5_do(opp5_pos)
   return true
  return false
 if is_ringer and adj:
  return scare5()
 return false

func check_people5() -> void:
 if flags.get("porridge_done", false) and flags.get("cake_done", false) and not flags.get("people_ready", false):
  flags.people_ready = true
  dialogue += "【人齐了——散在各处的人，此刻都在宫埕里，手里都有口热的。庙祝公站起来，走到正殿门口。】"
  queue_redraw()
  save_game()

func act5() -> void:
 if trade_pre5():
  flash_id = current
  flash_t = 0.0
  obj_anim_id = current
  obj_anim_t = 0.0
  save_game()
  queue_redraw()
  return
 if phase == "playing" and seg5 == 3 and flags.get("people_ready", false) and not flags.get("verse_done", false):
  flags.verse_done = true
  play_fx("incense")
  say("庙祝公", "「绳是新换的。割口我傍晚就验出来了。我拿去问六叔公，他说祠堂的事，轮不到宫里管。我没敢再说。阿澄那晚……是看见了割口，才上的竹棚——他攥着绳头来问过我，问这口子怎么齐得像刀裁的，我支吾着没敢接话。他要是等到我一句话，就不会自己爬上去。」【他带出私签来历：「逢冲则避」是我早年自己塞进签筒的——我这辈子，话都让签替我说了。又说起善堂：纸灶的身后，是善堂的人收的。施棺簿上写着呢——陈阿灶，施棺一口，葬西巷尾。这事从来不是没人记，是没人敢提。说完，宫埕里静了很久，只有粥摊的蒸汽还在往上冒。】")
  flash_id = current
  flash_t = 0.0
  save_game()
  queue_redraw()
  return
 match current:
  "everlamp":
   play_fx("everlamp")
   if phase == "tutorial":
    phase = "explore"
    say("阿澄", "灯芯一拨，火苗立起来——熄了十年的灯，今夜是庙祝公亲手点的。【准备好了，按 F 点第一炷守宫香。】")
   elif phase == "playing" and seg5 == 1 and not flags.get("lamp_seen", false):
    flags.lamp_seen = true
    say("阿澄", "拨芯看油面：半瓶陈油只够烧到后半夜，油面正一点点见底。灯旁的供桌烛台上，灵核是环纹的，雾聚不散——它先一步到了灯旁，占着灯旁的位子。庙祝公几次想近灯又缩回手：那股冷得不对的气，活人说不出，身子先知道。【添油的整壶新油在庙祝公房里（添油壶）；近灯之前，先要灯旁没「东西」。】")
   elif phase == "playing" and seg5 == 1 and not flags.get("update1", false):
    if flags.get("oil_ready", false) and yield5_left > 0.0 and yield5_from == "candle":
     flags.update1 = true
     seg5_begin(2, false)
     say("命运更新① · 小英／庙祝公", "庙祝公这才得以近灯，小英添足新油、拨起灯芯——火苗重新立稳，亮过开场。【命运更新①：熄了十年的灯，亮稳了。】更梆响过一记，第二炷香点起。【守人：阿弟攥着那支签坐在宫门边——桥头那句「祠堂的绳，根根都是割的」，他听见了。】")
    elif not flags.get("oil_ready", false) and not clean5.has("candle"):
     say("庙祝公", "它还在这宫里……我这手，抖。【添油前置未齐：油还没取来（侧间添油壶），灯旁的位子也还被它占着。】")
    elif not flags.get("oil_ready", false):
     say("阿澄", "灯旁空了，可油还没取来——侧间房门口，添油壶那儿，响一声，小英就想起来了。")
    elif yield5_left > 0.0:
     say("阿澄", "油到了、灯旁也让开了——再拨一次芯，就能添油。")
    else:
     say("阿澄", "让位窗口过了，它又回到灯旁那一带——等它静候，再跟它买一次。")
   elif phase == "playing" and seg5 == 3 and flags.get("rope_done", false) and not beat5_done:
    say("阿澄", "还差最后一件——它还在纸扎人里等着，等我亲口应它那一句。【先去应它：它在纸扎人处静候时，拿它旁边的响器（潮鼓／开道锣／神轿）应它一声，把承诺说出口。】")
   elif phase == "playing" and seg5 == 3 and flags.get("rope_done", false):
    finish5()
    return
   else:
    say("阿澄", "长明灯亮稳了。火是活人的火——它近不得这盏灯。")
  "candle":
   play_fx("candle")
   if clean5.has("candle"):
    say("阿澄", "烛焰轻燎，灯旁这一站报过到了——净的，它不再回来。")
   else:
    say("阿澄", "烛焰轻燎，供桌上的金纸卷了边。长明灯旁，冷气还没退净。")
  "oilpot":
   play_fx("oilpot")
   if phase == "playing" and seg5 == 1 and not flags.get("oil_ready", false):
    flags.oil_ready = true
    say("小英", "壶盖轻响——侧间里，小英听见动静，想起庙祝公房里那整壶新油，取来放在供桌边待用。【油已到供桌边。】")
   else:
    say("阿澄", "添油壶沉甸甸的。守夜的油，都在这一壶里。")
  "palanquin":
   play_fx("palanquin")
   play_sound("bell")
   if phase == "playing" and seg5 == 3 and flags.get("verse_done", false) and not flags.get("rope_done", false):
    flags.rope_done = true
    flags.update3 = true
    say("命运更新③ · 水生／阿勇", "人群散去一半时，水生从宫门外走进来——没人押他，没人喊他。他怀里抱着那截带割痕的旧绳，放在神轿前，跪下说全：绳是他割的，是六叔公授意的；阿澄坠落时，他就在库房门口。问他为什么留着这截绳，他说：「扔了，我就真当没这回事了。」埕角那几个年轻队员一个一个站回来，阿勇翻开名册逐个点名，声音稳了：老爷保号，人齐了。【命运更新③：要散的队伍，站齐了。】")
   else:
    say("阿澄", "轿铃响。金身在座的轿——它坐不进去，只能在宫里一带打转。")
  "drum":
   play_sound("drum")
   say("阿澄", "鼓声滚过宫埕，雾被震开一线。")
  "gong":
   play_gong()
   say("阿澄", "锣声贴着埕面过去，惊起一串回响。")
  "paperfig":
   play_fx("horse")
   if wait5 and opp5_pos in graph.get(current, []):
    say("阿澄", "它只认响器。【它在等开价——只有响器（潮鼓／开道锣／神轿铃）的应答，它才听得懂。】")
   else:
    say("阿澄", "纸扎人的头缓缓转着，永远朝着它此刻所在的地方。后殿廊下的纸扎马也一样——双读互证，不会错。")
  "porridge":
   play_fx("porridge")
   if phase == "playing" and seg5 == 3 and not flags.get("porridge_done", false):
    flags.porridge_done = true
    say("夜粥摊老阿伯", "揭盖——蒸汽与粥香漫进宫埕。老阿伯把炉火拨旺，冲宫里喊：「守夜的人，出来食碗糜再守——厝边一场，算我的。」守夜的人陆续走出来，端碗蹲在埕边。【粥摊前有人闲谈：一个说明年去深圳打工，一个说他爹问他抬轿抬到几时。】")
    check_people5()
   elif seg5 == 3:
    say("阿澄", "粥锅温着，蒸汽不断。守夜的人手里，都有口热的了。")
   else:
    say("阿澄", "宫门口空着，只有雾。夜粥摊还没支起来。")
  "cake":
   play_fx("kueh")
   if phase == "playing" and seg5 == 3 and not flags.get("cake_done", false):
    flags.cake_done = true
    say("莲婶", "粿盘轻响——莲婶端着那盘年节供桌上的红桃粿，一个一个分过去，红艳艳地冒着热气：「胶己人，先垫垫肚子。」【她是西巷后人——她留在宫里守夜，本身就是「补路」二字的人形注脚。】")
    check_people5()
   elif flags.get("cake_done", false) and not flags.get("qiaopi_seen", false):
    flags.qiaopi_seen = true
    say("莲婶", "分完粿，莲婶低声说起茶铺里压着的一沓旧侨批——过番的人把话写在纸上，托人带过海。【她说：话必须送到。】")
   else:
    say("阿澄", "红桃粿盘空了大半，粿印的纹样还留着热气。")
  "gengbang":
   play_fx("bang")
   if phase == "playing" and seg5 == 2 and not flags.get("update2", false) and not bang5_used:
    bang5_used = true
    adi5_pause = 45.0
    say("阿勇", "梆声一响，阿勇想起巡更点名，扬声喊住正要离队的阿弟：「阿弟！名册上还差你一个！」阿弟停步回头。【更梆拖延：阿弟的脚步停住 45 秒——买的是时间，不是解决。全章只此一次。】")
   elif seg5 == 3 and not flags.get("geng_seen", false):
    flags.geng_seen = true
    say("更夫", "敲梆——守夜的老更夫搭话，说起十年前的那一夜：灯熄的那年，宫里的夜比今年还静，「静得连更都不想敲」。【可选：长明灯熄的那十年，活人侧的重量。】")
   else:
    say("阿澄", "梆声沉沉，报着更次。守夜的人听着，心里有数。")
  "horse":
   play_fx("horse")
   if wait5 and opp5_pos in graph.get(current, []):
    say("阿澄", "它只认响器。【它在等开价——只有响器（潮鼓／开道锣／神轿铃）的应答，它才听得懂。】")
   else:
    say("阿澄", "纸扎马的头缓缓转着，永远朝着它此刻所在的地方。宫埕的纸扎人也一样——双读互证，不会错。")
  "sedanrem":
   play_fx("horse")
   if wait5 and opp5_pos in graph.get(current, []):
    say("阿澄", "它只认响器。【它在等开价——只有响器（潮鼓／开道锣／神轿铃）的应答，它才听得懂。】")
   elif not flags.get("remains5_seen", false):
    flags.remains5_seen = true
    say("阿澄", "掀布——灵域地面浮出一条淡淡的雾径，自杂物间往宫门方向延出去，出宫门，拐向西巷，约五秒，散了。【可选调查：它守着的，从来不是这座宫。】")
   else:
    say("阿澄", "纸轿残件静静停在布下。里子不是轿身——它在上面停不住。")
 flash_id = current
 flash_t = 0.0
 obj_anim_id = current
 obj_anim_t = 0.0
 append_tip("act", "对，就是这么用物件的本事：先在灵域选好物件，Tab 回现实，按 E 动手。")
 save_game()
 queue_redraw()

func tick_ch5(delta: float) -> void:
 var step = delta * time_scale
 if yield5_left > 0.0:
  yield5_left -= step
  if yield5_left <= 0.0:
   var from = yield5_from
   yield5_from = ""
   if from == "beat":
    opp5_advance_from("paperfig")
   elif from != "":
    if clean5.has(from) and not ((from == "candle" and flags.get("update1", false)) or (from == "paperfig" and flags.get("update2", false))):
     clean5.erase(from)
     trade5_used = maxi(0, trade5_used - 1)
     if from == "candle": flags.trade1_done = false
    opp5_advance_from(from)
 elif wait5:
  wait5_left -= step
  if wait5_left <= 0.0:
   wait5 = false
   opp5_timer = 45.0
 elif opp5_pos != "":
  opp5_timer -= step
  if opp5_timer <= 0.0:
   opp5_advance()
 if seg5 == 2 and not flags.get("update2", false) and phase == "playing":
  if adi5_pause > 0.0:
   adi5_pause -= step
  else:
   adi5_left -= step
   if adi5_left <= 0.0:
    adi5_left = 0.0
    fail5("阿弟攥着签走出了宫门——去库房的路，夜里黑。他和水生的话，今夜要说岔了。", "adi_left")

func fail5(reason: String, kind: String) -> void:
 phase = "failure"
 failure_wait = 5.0
 fail_kind = kind
 play_fx("rewind")
 if kind == "lamp_out":
  var hint = "先附长明灯拨芯看清油面——油在侧间房里，它占着灯旁。"
  if flags.get("oil_ready", false):
   hint = "油已到供桌边了——等它在烛台静候，自相邻响器替它报到，买它让位，再添油。"
  elif flags.get("lamp_seen", false):
   hint = "先去侧间：添油壶响一声，小英会把整壶新油取到供桌边。"
  say("庙祝公", reason + " 【他捧着灯盏站在黑里，半天说出一句：「十年了……又熄了。」" + hint + "】回到本段香点，重来——已守住的段落不回滚。")
 elif kind == "adi_left":
  say("阿勇", reason + " 【他的喊声在宫门外回响——「名册上还差你一个」还没喊出口。更梆能替他喊住阿弟一次；可阿弟真正留下，要等纸扎人静候时，替它报到、让它把头转过来。】回到本段香点，重来。")
 else:
  say("纸灶小轿方向", reason + " 【小轿方向漏出断续纸响，拼出半个字音——「……人……齐……」它比谁都懂：人不齐，话说不完。夜粥摊的盖、红桃粿盘的粿，两件都齐了，人才齐。】回到本段香点，重来。")

func retry5() -> void:
 if seg5_snap.has("trade"):
  trade5_used = int(seg5_snap["trade"])
  clean5 = (seg5_snap["clean"] as Dictionary).duplicate(true)
  flags = (seg5_snap["flags"] as Dictionary).duplicate(true)
 seen_update1 = bool(flags.get("update1", false))
 seen_update2 = bool(flags.get("update2", false))
 seen_update3 = bool(flags.get("update3", false))
 seg5_begin(seg5, false, false)
 say("阿澄", "香刚点燃——回到这一段的开头。已守住的段落、已落的命运更新，都不回滚。")

func finish5() -> void:
 start_shake()
 clear_save5()
 ending_t = 0.0
 hook_bell_done = false
 phase = "ending"
 flags.ending = true
 say("阿澄", "三线皆守、真相在活人世界全揭。我望着重新亮稳的长明灯，第一次感到疲惫——香快烧完了，我能做的事正在变少，活人能做的事，正在变多。【第三炷香烧到最后一截，宫门口的暗处，有了动静。】")
 queue_redraw()

func objective_text5() -> String:
 if phase == "tutorial": return "试一试：按 Tab 切到现实，再按 E，拨一拨长明灯的灯芯"
 if phase == "explore": return "四处附身看看，准备好了按 F 点第一炷守宫香"
 if phase == "playing":
  if seg5 == 1:
   if not flags.get("lamp_seen", false): return "守灯：附长明灯按 E 拨芯，先看清油面"
   if not flags.get("oil_ready", false) and not clean5.has("candle"): return "取油与开价次序自由：添油壶引小英取油／它静候时以相邻响器替它报到"
   if not flags.get("oil_ready", false): return "取油：附添油壶按 E 壶盖轻响，小英会把新油取到供桌边"
   if yield5_left > 0.0 and yield5_from == "candle": return "灯旁让开了：附长明灯按 E 拨芯添油（窗口 %d 秒）" % int(yield5_left)
   return "等它在供桌烛台静候（环纹灵核），自相邻响器（神轿／潮鼓）替它报到开价"
  if seg5 == 2:
   return "守人：阿弟正往宫门走（余 %d 秒）——等它在纸扎人静候，以相邻响器替它报到" % int(adi5_left)
  if seg5 == 3:
   if not flags.get("porridge_done", false) or not flags.get("cake_done", false): return "守队伍：夜粥摊揭盖、红桃粿盘分粿，两件齐了，人就齐了"
   if not flags.get("verse_done", false): return "人齐了：庙祝公站起来了——按 E，听他把话说完"
   if not flags.get("rope_done", false): return "附神轿按 E：宫门外，有人自己走进来了"
   return "附长明灯按 E：望着这盏灯，把这一夜收束"
 if phase == "failure": return "没关系，回到本段香点再来——已守住的段落不回滚"
 if phase == "ending": return "第五章完"
 return ""

func hint_text5() -> String:
 if phase == "title": return "按 Enter 或点一下，就能开始。"
 if phase == "tutorial": return "你顺香火落在长明灯上。按 Tab 切到现实，再按 E 拨芯，试试手。"
 if phase == "explore": return "在灵域点发青光的物件附身四处看。整张老爷宫全景自一开始就全域可达：正殿、宫埕、后殿任走。准备好了按 F 点第一炷守宫香。"
 if phase == "playing":
  if seg5 == 1:
   if not flags.get("lamp_seen", false): return "先附长明灯按 E 拨芯看油面：半瓶陈油烧不到天亮，灯旁的烛台被它占着——三件事都写在明处。"
   if not flags.get("update1", false): return "守灯三步次序自由，只看添油那一刻：油到供桌边（添油壶响→小英取油）、它让位（它在烛台静候时，去相邻的神轿或潮鼓上按 E 替它报到开价）、灯没熄。开价只有三次，第三次留着——别在普通占位时乱敲，那只是惊走，不留「净」记。"
  if seg5 == 2:
   if not flags.get("update2", false): return "阿弟往宫门走，全程 120 秒。它在纸扎人静候时，去相邻的开道锣或神轿上按 E 替它报到——它退场打宫门方向过，纸扎人的头会转过去，阿弟就钉住了。来不及先附更梆敲一记：阿勇能喊住他一次，停 45 秒。"
  if seg5 == 3:
   if not flags.get("people_ready", false): return "守队伍先把人聚齐：宫门口夜粥摊按 E 揭盖、宫埕红桃粿盘按 E 分粿，两件都做了，人才齐。段三它在纸扎人静候时别开价——最后一次，留着。"
   if not flags.get("verse_done", false): return "人齐了，庙祝公站起来了——随便在哪件物件上按 E，听他把全句说完。"
   if not flags.get("rope_done", false): return "全句说完，宫门外有人自己走进来了——附神轿按 E，看他把绳放在轿前。"
   return "附长明灯按 E：望着重新亮稳的灯，把这一夜收束。"
 if phase == "failure": return "别慌，不会真死。等一下（或按 Enter）就会回到本段香点——已守住的段落和命运更新不回滚，交易计数回到本段开始时的样子。"
 if phase == "ending": return "第五章完了。按 Enter 回到标题。"
 return "按 Tab 切换灵域／现实，灵域点物件附身，现实按 E 用物件的本事。它静候时，响器是开价；它普通占位时，响器才是驱赶。"

func save_game5() -> void:
 var data = {"phase": phase, "current": current, "spirit": spirit, "remaining": remaining, "flags": flags, "seen_tips": seen_tips, "seg5": seg5, "trade5_used": trade5_used, "clean5": clean5, "opp5_pos": opp5_pos, "opp5_idx": opp5_idx, "opp5_timer": opp5_timer, "wait5": wait5, "wait5_left": wait5_left, "yield5_left": yield5_left, "yield5_from": yield5_from, "adi5_left": adi5_left, "bang5_used": bang5_used, "beat5_done": beat5_done, "teach5_done": teach5_done, "teach5_scare": teach5_scare, "adi5_pause": adi5_pause, "squeezed5": squeezed5, "snap": seg5_snap}
 has_save5 = true
 save_data5 = data.duplicate(true)
 var ls = ls_store()
 if ls != null: ls.setItem(SAVE_KEY5, JSON.stringify(data))

func clear_save5() -> void:
 has_save5 = false
 save_data5 = {}
 var ls = ls_store()
 if ls != null: ls.removeItem(SAVE_KEY5)

func continue_game5() -> void:
 if not has_save5: return
 var d: Dictionary = save_data5
 start_chapter5()
 var ph = str(d.get("phase", "playing"))
 phase = ph if ph in ["tutorial", "explore", "playing"] else "playing"
 current = str(d.get("current", "everlamp"))
 prev_current = current
 spirit = bool(d.get("spirit", true))
 remaining = float(d.get("remaining", 180.0))
 flags = (d.get("flags", {}) as Dictionary).duplicate(true)
 seen_tips = (d.get("seen_tips", {}) as Dictionary).duplicate(true)
 seen_update1 = bool(flags.get("update1", false))
 seen_update2 = bool(flags.get("update2", false))
 seen_update3 = bool(flags.get("update3", false))
 seg5 = int(d.get("seg5", 1))
 trade5_used = int(d.get("trade5_used", 0))
 clean5 = (d.get("clean5", {}) as Dictionary).duplicate(true)
 opp5_pos = str(d.get("opp5_pos", CH5_SEG_OPEN[seg5 - 1]))
 opp5_idx = int(d.get("opp5_idx", 0))
 opp5_timer = float(d.get("opp5_timer", 45.0))
 wait5 = bool(d.get("wait5", false))
 wait5_left = float(d.get("wait5_left", 0.0))
 yield5_left = float(d.get("yield5_left", 0.0))
 yield5_from = str(d.get("yield5_from", ""))
 adi5_left = float(d.get("adi5_left", 0.0))
 adi5_pause = float(d.get("adi5_pause", 0.0))
 squeezed5 = (d.get("squeezed5", {}) as Dictionary).duplicate(true)
 bang5_used = bool(d.get("bang5_used", false))
 beat5_done = bool(d.get("beat5_done", false))
 teach5_done = bool(d.get("teach5_done", false))
 teach5_scare = bool(d.get("teach5_scare", false))
 seg5_snap = (d.get("snap", {}) as Dictionary).duplicate(true)
 say("阿澄", "香还燃着……回到没守完的那一段。")
 queue_redraw()

# ================= 第六章「把路走完」（DESIGN_CH6_DRAFT v0.1 施工） =================

func bump_behavior(kind: String) -> void:
 var ls = ls_store()
 if ls == null: return
 var d: Dictionary = {}
 var raw = ls.getItem(BEHAVIOR_KEY)
 if raw != null:
  var p = JSON.parse_string(str(raw))
  if typeof(p) == TYPE_DICTIONARY: d = p
 d[kind] = int(d.get(kind, 0)) + 1
 ls.setItem(BEHAVIOR_KEY, JSON.stringify(d))

func read_behavior6() -> void:
 acct6_drive = 0
 acct6_answer = 1
 var ls = ls_store()
 if ls == null: return
 var raw = ls.getItem(BEHAVIOR_KEY)
 if raw != null:
  var p = JSON.parse_string(str(raw))
  if typeof(p) == TYPE_DICTIONARY:
   acct6_drive = int(p.get("drive", 0))
   acct6_answer = int(p.get("answer", 0))

func ch6_graph_for(seg: int) -> Dictionary:
 var g: Dictionary = {
  "palanquin": ["lampstand", "drum", "paperfig"],
  "lampstand": ["palanquin", "drum"],
  "drum": ["palanquin", "lampstand", "gong"],
  "gong": ["drum", "paperfig"],
  "paperfig": ["gong", "palanquin"],
  "everlamp": [], "censer": [], "templebell": [], "flag": [], "deepgong": [], "doorring": [], "sign": []
 }
 if seg == 1 or seg == 6:
  g["everlamp"] = ["palanquin", "lampstand"]
  g["palanquin"].append("everlamp")
  g["lampstand"].append("everlamp")
 elif seg == 2:
  g["censer"] = ["palanquin", "templebell"]
  g["templebell"] = ["censer", "lampstand"]
  g["palanquin"].append("censer")
  g["lampstand"].append("templebell")
 elif seg == 5:
  g["flag"] = ["palanquin", "gong", "doorring"]
  g["deepgong"] = ["gong", "drum", "doorring"]
  g["doorring"] = ["flag", "deepgong"]
  g["palanquin"].append("flag")
  g["gong"].append("flag")
  g["gong"].append("deepgong")
  g["drum"].append("deepgong")
 return g

func ch6_place_team() -> void:
 var ax = CH6_SEG_ANCHOR[seg6 - 1]
 for id in CH6_TEAM_OFF:
  nodes[id][2] = Vector2(ax, 0.0) + CH6_TEAM_OFF[id]
 nodes["sign"][2] = Vector2(ax + 380.0, 505)

func ch6_npc_defaults() -> Dictionary:
 match seg6:
  1: return {"miaozhu": Vector2(430, 470), "liushu": Vector2(780, 478), "ayong": Vector2(920, 460), "adi": Vector2(1085, 500), "xiaoying": Vector2(520, 495), "laobo": Vector2(170, 515)}
  2: return {"miaozhu": Vector2(905, 472), "ayong": Vector2(1330, 460), "adi": Vector2(1470, 500), "xiaoying": Vector2(1420, 495)}
  3: return {"lianshen": Vector2(1560, 488), "ayong": Vector2(1830, 460), "adi": Vector2(1960, 500), "xiaoying": Vector2(1420, 478), "member_a": Vector2(1500, 500), "member_b": Vector2(2050, 478)}
  4: return {"dengjiang": Vector2(1980, 505), "ferryman": Vector2(2330, 505), "ayong": Vector2(2290, 460), "adi": Vector2(2430, 500), "xiaoying": Vector2(1900, 485)}
  5: return {"liushu": Vector2(2920, 472), "lianshen": Vector2(3030, 505), "adi": Vector2(2760, 505), "ayong": Vector2(2560, 460), "xishu": Vector2(2430, 508), "xiaoying": Vector2(2500, 472)}
  _: return {"miaozhu": Vector2(430, 470), "liushu": Vector2(700, 478), "shuisheng": Vector2(820, 488), "ayong": Vector2(940, 460), "adi": Vector2(560, 505), "xishu": Vector2(262, 505)}

func ch6_reset_state() -> void:
 nodes = CH6_NODES.duplicate(true)
 seg6 = 1
 graph = ch6_graph_for(1)
 ch6_place_team()
 flags = {}
 reported6 = {}
 reported_nodes6 = {}
 trio6 = {}
 fog6 = ""
 trade6_left = 1
 branch6 = false
 scare_tried6 = false
 seg6_snap = {}
 seen_update1 = false
 seen_update2 = false
 fail_kind = ""
 npc_pos = ch6_npc_defaults()
 npc_walking = {}

func start_chapter6() -> void:
 chapter = 6
 ch6_reset_state()
 read_behavior6()
 phase = "tutorial"
 current = "everlamp"
 prev_current = "everlamp"
 spirit = true
 remaining = 360.0
 pickup_left = 0.0
 ending_t = -1.0
 hook_bell_done = false
 cam_x = 0.0
 say("庙祝公／阿澄", "三线皆守、真相在活人世界全揭。六叔公站在宫门口的暗处，说完那句「那最后一程……我来抬」，天边开始发白——又压了回去。破晓前，最后一炷香。【这一程，不赶谁、不抢谁：队伍贯通七站，我替它把站，一站一站报全。】")
 append_tip("spirit", "这里是灵域，时间是停的。点旁边发青光的物件，就能附过去。")
 start_ambience()
 queue_redraw()

func start_incense6() -> void:
 chapter = 6
 ch6_reset_state()
 read_behavior6()
 acct6s_drive = acct6_drive
 acct6s_answer = acct6_answer
 remaining = 360.0
 seg6_begin(1, true)

func seg6_begin(n: int, announce: bool, resnap: bool = true) -> void:
 seg6 = n
 if n == 5: set_ambience_pair("amb6_alley", "amb6_alley")
 elif n == 6 and flags.get("update1", false): set_ambience_pair("amb6_dawn", "amb6_dawn")
 elif n == 1: set_ambience_pair("amb_realm", "amb_spirit")
 graph = ch6_graph_for(n)
 ch6_place_team()
 fog6 = "templebell" if n == 2 else ("gong" if n == 3 else ("lampstand" if n == 4 else ""))
 if n == 5:
  branch6 = acct6s_drive > 0 and acct6s_answer == 0
 if current in ["everlamp", "censer", "templebell", "flag", "deepgong", "doorring", "sign"]:
  current = "palanquin"
  prev_current = "palanquin"
 spirit = true
 npc_pos = ch6_npc_defaults()
 npc_walking = {}
 if resnap:
  seg6_snap = {"flags": flags.duplicate(true), "reported": reported6.duplicate(true), "rnodes": reported_nodes6.duplicate(true), "trio": trio6.duplicate(true), "remaining": remaining, "trade": trade6_left}
 phase = "playing"
 if announce:
  match n:
   1: say("庙祝公", "最后一炷香点上了。路线写得明明白白：宫门→土地庙→溪尾街→桥头→西巷→祠堂前→回宫，一站不少。【附神轿按 E 晃铃——起轿。】")
   2: say("阿澄", "土地庙到了。灵域里，檐下的铜铃灵核暗红、覆着水渍纹——雾锢：它停在这里了。【这一站欠的，是庙里断了的香。附土地公小香炉按 E，火星上窜，重燃庙香。】")
   3: say("阿澄", "溪尾街。莲婶站在挂好的新招牌下——绳是阿勇亲手换的，招牌稳稳的。【先附花灯担按 E 举高，照亮这条街。】")
   4: say("阿澄", "桥头。桥面的雾比往年浓，花灯的光发闷。【先应它一声，解开花灯；再照桥、点名、响鼓报到。】")
   5: say("阿澄", "西巷口。雾在这里不沉，只是厚——它不在这里停住，它在等队伍进来。【附标旗按 E 展开，进巷；到旧宅门口，先叩门，再报到。】")
   6: say("阿澄", "祠堂前到了。这一站的话，是活人说给活人听的——我能做的，只有听完。【在任何物件上按 E，旁观这一站。】")
 play_fx("rewind", -7.0)
 save_game()
 queue_redraw()

func report6(station: String, node: String) -> void:
 reported6[station] = true
 if node != "": reported_nodes6[node] = true
 bump_behavior("answer")
 save_game()
 queue_redraw()

func play_report6() -> void:
 play_fx("report_full")

func mist_try6() -> void:
 play_sound("bell")
 if not scare_tried6:
  scare_tried6 = true
  say("阿澄", "轿铃满音量响过去——雾，不动。【赶不走的。它没占着什么——它是在等这一站走完。】")
 else:
  say("阿澄", "雾还是不动。这一站欠的东西补上，它才肯让开。")

func trio_hit6(id: String) -> void:
 if not (reported6.has("土地庙") and reported6.has("溪尾街") and reported6.has("桥头")) or not flags.get("knocked", false) or not flags.get("flag_open", false):
  play_gong(-6.0, 0.8)
  say("阿澄", "锣声闷在雾里，没有出去。【报到未齐：沿途三站要先报全，旧宅的门要先叩响，队伍要先进巷到齐。】")
  return
 if trio6.has(id):
  play_gong(-6.0, 0.8)
  say("阿澄", "这一件，已经响过了。")
  return
 var first = trio6.is_empty()
 trio6[id] = true
 if id == "deepgong": play_fx("deepgong")
 elif id == "gong":
  play_gong()
  play_fx("sugong", -6.0)
 else: play_sound("drum")
 if first:
  trade6_left = 0
  flags.trade_redeemed = true
  bump_behavior("answer")
  say("阿澄", "「最后一次——我亲手给你报到。」【交易第 3 次，在此兑现：交易锣记最后一枚亮起、随声散去，计数归零。还剩两件。】")
 elif trio6.size() < 3:
  say("阿澄", "报到三件，已响 %d 件——还差 %d 件。" % [trio6.size(), 3 - trio6.size()])
 if trio6.size() >= 3:
  play_fx("report_half")
  play_fx("suona", -6.0)
  var rt6 = get_tree().create_timer(2.4)
  var wr6 = weakref(self)
  rt6.timeout.connect(func(): var g6 = wr6.get_ref(); if g6 != null: g6.play_fx("report_half"))
  flags.update1 = true
  reported6["西巷"] = true
  reported_nodes6["deepgong"] = true
  var cold = branch6
  seg6_begin(6, false)
  if cold:
   say("命运更新① · 西巷", "三件响完，整套报到成立——活人侧同拍：阿勇把锣槌递到阿弟手里，阿弟双手握槌，亲手敲响补路的第一声锣；潮鼓、轿铃、深波锣、苏锣层层叠进来，唢呐在最后拔起一条亮线。灵域里，小轿旁的雾散开：它把纸轿放下，没有回头，径直散入晨光。旧宅门口的水洼里，第一次映出纸轿完整的倒影。细叔上前把旧纸轿在门口摆正：「厝边的物件，厝边的人送到。」【命运更新①：欠了六十三年的一站，报到了。】天边开始发白——队伍回程，祠堂前还有一站。")
  else:
   say("命运更新① · 西巷", "三件响完，整套报到成立——活人侧同拍：阿勇把锣槌递到阿弟手里：「这一声，你来。」阿弟双手握槌，亲手敲响补路的第一声锣；潮鼓、轿铃、深波锣、苏锣层层叠进来，唢呐在最后拔起一条亮线——六十三年前没响的那一声，被补成了一整套。灵域里，小轿旁的雾散开，纸灶恢复完整形态一瞬：一个抱着纸轿的普通中年人，衣角还带着六十三年前那夜的水。他把纸轿轻轻放在旧宅门口，转头望了一眼队伍，点了点头。纸扎人的头，缓缓垂下、正对前方。旧宅门口的水洼里，第一次映出纸轿完整的倒影——它有了倒影，等于它完整了。细叔上前把旧纸轿在门口摆正：「厝边的物件，厝边的人送到。」【命运更新①：欠了六十三年的一站，报到了。】天边开始发白——队伍回程，祠堂前还有一站。")
 save_game()
 queue_redraw()

func branch_insert6() -> void:
 # 驱散弱支线（P-06 现行口径）：西巷入口一段演出，不设判定、不耗香时，后果见 trio 完成与最后一帧
 say("庙祝公／阿澄", "西巷入口，雾比别处更浓，沉成一道横在巷口的雾墙。我的手先动了——满音量的一记响器：雾被撕开一瞬，随即合拢，比先前更厚。纸扎人的头猛地垂下又抬起。活人侧，庙祝公恰在此时开口（他看不见雾墙，他说的是规矩）：「响器不是赶人的。是报到的——走到人家门口，先报到，才进门。」我收了手。【驱散支线：惊走版的声音，只此一次。解法、前置，分毫不变。】")

func last_attach6() -> void:
 flags.sign_done = true
 flags.update2 = true
 current = "sign"
 play_fx("sign")
 finish6()

func act6() -> void:
 if phase == "playing" and seg6 == 6 and not flags.get("pages_done", false):
  flags.pages_done = true
  reported6["祠堂前"] = true
  play_fx("incense")
  say("六叔公／庙祝公", "神轿在祠堂前停轿行礼——这一站的报到，是停轿礼成。六叔公当众认错：改道是他祖父定的、撕页是他父亲做的、割绳是他授意的，阿澄的死，祠堂担「失察」二字。庙祝公把名册递到他手里，他把撕掉的那一页补写回来——哪一站、漏了谁、谁家的人没回来，第一个签上自己的名，退了理事之位。水生站在他身后，把自己的名字写在补页的边角。阿勇接过名册，扬声点名收束：「胶己人，一个不少。」【死因线至此全格收束：不送官、不翻案为命案。】队伍回宫——天快亮了，香只剩最后一截。【灵域里点阿弟怀里的签——最后一附。】")
  flash_id = current
  flash_t = 0.0
  obj_anim_id = current
  obj_anim_t = 0.0
  save_game()
  queue_redraw()
  return
 match current:
  "everlamp":
   play_fx("everlamp")
   if phase == "tutorial":
    phase = "explore"
    say("庙祝公", "出发前，他给长明灯添满油、剪齐灯芯——火苗稳稳的，这盏灯今夜不会再熄。六叔公换上轿夫的短打，站到神轿最后一程的轿杠旁。夜粥摊老阿伯在宫门口收摊相送：粥摊摆了四十年，头一回送整支队伍出门。【准备好了，按 F 点最后一炷香。】")
   elif seg6 == 1:
    say("阿澄", "灯油满满、灯芯齐整。宫里的灯守住了，队伍才出得了门——这一程，是守宫那一夜的结果。")
   elif seg6 == 6 and not flags.get("lamp_lit6", false):
    flags.lamp_lit6 = true
    say("阿澄", "灯油满满、灯芯齐整，灯旁空着一个位置——那是留给新引路轿的。【可选：与尾声的供轿互文。】")
   else:
    say("阿澄", "长明灯亮着。隔着一夜的路，它还亮着。")
  "palanquin":
   play_fx("palanquin")
   play_sound("bell")
   if phase == "playing" and seg6 == 1 and not reported6.has("宫门"):
    reported6["宫门"] = true
    bump_behavior("answer")
    seg6_begin(2, false)
    say("阿澄／小轿方向", "轿铃响，队伍起轿出宫门。小轿方向传来一声应答铃——第一次，没有慢半拍：它已经在队伍的节拍里了。【报到 · 宫门：出发即报到。宫门段收束。】队伍行至土地庙停轿——灵域里，檐下的铜铃灵核暗红、覆着水渍纹：雾锢，它停在这里了。【这一站欠的，是庙里断了的香。附土地公小香炉按 E，火星上窜，重燃庙香。】")
   elif phase == "playing" and seg6 == 4 and fog6 == "lampstand":
    play_answer("bell")
    fog6 = ""
    bump_behavior("answer")
    say("阿澄", "轿铃以应答版轻响——雾听了一下，缓缓退开：花灯重新亮起。【解锢：这站欠的，是没人应它一声。附花灯担按 E 举高，照开桥面。】")
   elif phase == "playing" and seg6 == 4 and not flags.get("bridge_lit", false):
    say("阿澄", "先让花灯把桥面照开——附花灯担按 E 举高。")
   elif phase == "playing" and seg6 == 4 and not flags.get("rollcall", false):
    flags.rollcall = true
    say("阿勇", "轿铃轻响，阿勇就着灯光逐个点名：数到队尾时顿了顿，喊——「引路轿，跟上。」小轿的铃同拍应了一声。【第九个，被活人自己点名认领了。附潮鼓按 E 响鼓——报到 · 桥头。】")
    save_game()
   elif phase == "playing" and seg6 == 3 and fog6 == "gong":
    mist_try6()
   else:
    say("阿澄", "轿铃响。队伍的节拍，稳稳的。")
  "lampstand":
   play_fx("lantern")
   if phase == "playing" and seg6 == 3 and not flags.get("street_ready", false):
    flags.street_ready = true
    say("莲婶", "灯光扫过整条街面：雾里显形——开道锣被锢住了，锣面覆着水渍纹，锣架旁的雾沉得比别处低。莲婶迎出两步，站到招牌正下方——六十三年前，她父辈就是站在这门口等队伍的：「今年走到我门口，锣要响大声点，我爹在天上也听听。」【莲婶到位。欠茶铺账的队员被她当众讨账，讪笑着说回来就还。先附潮鼓按 E 应它一声，解开锣；再响锣报到。】")
    save_game()
   elif phase == "playing" and seg6 == 4 and not flags.get("bridge_lit", false):
    flags.bridge_lit = true
    say("阿澄／摆渡人后代", "花灯举高——灯光照开桥面，露出桥心干爽的路面；四章加固过的桥栏绳，在灯光里一闪。桥头站着摆渡人的后代送行：他爷爷那辈在溪上摆渡，六十三年前涨水的那夜，渡船拴在祠堂这岸，一整夜没人来坐——「不是河过不去，是没人想起西巷还有人。」他说他今年不摆渡了，要跟队走一趟西巷。【照桥完成。附神轿按 E 晃铃，阿勇点名。】")
    save_game()
   elif phase == "playing" and seg6 == 5 and flags.get("knock1", false) and not flags.get("door_lit", false):
    flags.door_lit = true
    say("阿澄", "花灯举高，光移到旧宅门口——门环上的锈，在光里看得清清楚楚。【再附门环按 E 轻叩。】")
    save_game()
   elif phase == "playing" and seg6 == 5:
    say("阿澄", "花灯的光照进多年没人走的巷子——下山虎旧宅群连排，门窗黑着，只有巷底纸灶旧宅的门牌还在。替父上阵的队员在巷口轻声说，他爹年轻时给纸扎店送过纸。")
   else:
    say("阿澄", "花灯亮着。队伍的灯火，是整条路上唯一移动的暖光带。")
  "drum":
   if phase == "playing" and seg6 == 3 and fog6 == "gong":
    play_answer("drum")
    fog6 = ""
    bump_behavior("answer")
    say("阿澄", "潮鼓以应答版在锢住的开道锣旁响一声——雾听了一下，缓缓退开。【解锢：这站欠的不是香，是没人应它一声。先应它，它才肯让人响。附开道锣按 E——报到 · 溪尾街。】")
   elif phase == "playing" and seg6 == 4 and fog6 == "lampstand":
    play_answer("drum")
    fog6 = ""
    bump_behavior("answer")
    say("阿澄", "潮鼓以应答版在花灯担旁响一声——雾退开，花灯重新亮起。【解锢。附花灯担按 E 举高，照开桥面。】")
   elif phase == "playing" and seg6 == 4 and not reported6.has("桥头"):
    if not flags.get("bridge_lit", false) or not flags.get("rollcall", false):
     play_sound("drum")
     say("阿澄", "雾没散，鼓声传不到桥心。【报到未齐：花灯要先解锢、照桥，阿勇的点名要先落。】")
    else:
     report6("桥头", "drum")
     play_report6()
     seg6_begin(5, false)
     say("阿澄", "潮鼓响——报到 · 桥头成立，大锣鼓的重音落在桥心，声场过溪。【队伍过桥。桥头段收束。】桥那头就是西巷：雾不沉、只是厚——它不在这里停住，它在等队伍进来。【附标旗按 E 展开进巷；旧宅门口，先叩门，再报到。】")
   elif phase == "playing" and seg6 == 5:
    trio_hit6("drum")
   else:
    play_sound("drum")
    say("阿澄", "鼓声滚过，雾被震开一线。")
  "gong":
   if phase == "playing" and seg6 == 3 and not reported6.has("溪尾街"):
    if not flags.get("street_ready", false):
     play_gong()
     say("阿澄", "锣响了，可招牌下还空着——这一站的人还没到。【先附花灯担按 E 举高照街，莲婶到位，再响锣报到。】")
    else:
     report6("溪尾街", "gong")
     play_report6()
     seg6_begin(4, false)
     say("阿澄", "开道锣响——报到 · 溪尾街成立。活人侧的锣手同拍把锣敲得又响又稳：莲婶那句「响大声点」，由活人自己的手兑现。【溪尾街段收束。】队伍行至桥头——桥面的雾比往年浓，花灯担被雾锢住，灯光发闷。【先应它一声：神轿轿铃或潮鼓，应答版。】")
   elif phase == "playing" and seg6 == 5:
    trio_hit6("gong")
   else:
    play_gong()
    say("阿澄", "锣声贴着地面过去，惊起一串回响。")
  "paperfig":
   play_fx("horse")
   if flags.get("update1", false):
    say("阿澄", "纸扎人的头垂着，正对前方——近旁只剩我一个亡魂了。它指了一整夜，今夜，它歇了。")
   else:
    say("阿澄", "纸扎人的头缓缓转着，指向队伍中段的小轿旁——它一路跟着队伍走，就在那里。不领先，不掉队。")
  "censer":
   play_fx("incense")
   if phase == "playing" and seg6 == 2 and fog6 == "templebell":
    fog6 = ""
    play_fx("shrine")
    bump_behavior("answer")
    say("阿澄／庙祝公", "火星上窜——引燃庙祝公刚续上的新香，庙香重燃；同拍，铜铃上的雾退开。【解锢：它近不得有主的香火——这一站欠的，是庙里断了的香。补上，它就让开。】庙祝公停香行礼——起身时回望宫里的方向：那点灯火隔着一夜的路，还亮着。【附铜铃按 E——报到 · 土地庙。】")
    save_game()
   else:
    say("阿澄", "火星上窜。土地公的小香炉，有主的香火——它近不得。")
  "templebell":
   play_fx("templebell")
   if phase == "playing" and seg6 == 2 and fog6 == "" and not reported6.has("土地庙"):
    report6("土地庙", "templebell")
    play_report6()
    seg6_begin(3, false)
    say("阿澄", "铜铃响——报到 · 土地庙成立，队伍的锣鼓同拍跟上半套。【土地庙段收束。】队伍行至溪尾街：茶铺门口，莲婶站在挂好的新招牌下等队伍——绳是阿勇亲手换的，招牌稳稳的。【先附花灯担按 E 举高，照亮这条街。】")
   else:
    say("阿澄", "铜铃轻响，庙前的风跟着动了一下。")
  "flag":
   play_fx("flag")
   if phase == "playing" and seg6 == 5 and branch6 and not flags.get("branch_seen", false):
    flags.branch_seen = true
    branch_insert6()
    save_game()
   elif phase == "playing" and seg6 == 5 and not flags.get("flag_open", false):
    flags.flag_open = true
    say("阿澄／小英", "标旗在巷口展开——潮绣旗面在花灯光里立起来，小英领舞入巷，英歌槌起势。花灯光扫过连排的下山虎旧厝：有几家的门环上还缠着褪色的红绳——当年走的人家，门一直没锁过。【可选：西巷的空置不是荒废，是等。】队伍在旧宅门口停轿——附西巷门环按 E，先叩门。")
    save_game()
   elif phase == "playing" and seg6 == 5:
    say("阿澄", "标旗立在巷口，旗面在晨风里轻轻响。")
   else:
    say("阿澄", "旗面抖响。")
  "doorring":
   if phase == "playing" and seg6 == 5:
    if not flags.get("flag_open", false):
     say("阿澄", "巷口的队伍还没进来——先附标旗按 E 展开，领队入巷。")
    elif not flags.get("knock1", false):
     flags.knock1 = true
     play_fx("doorring_rust")
     say("阿澄／六叔公", "队伍在旧宅门口停轿，六叔公放下轿杠，对着旧宅门口深深弯下腰。门环轻叩——第一叩，锈涩、声哑。【回家先叩门。附花灯担按 E 举高，把光移到门口，再叩。】")
     save_game()
    elif not flags.get("door_lit", false):
     play_fx("doorring_rust")
     say("阿澄", "还是锈涩声——等灯光移到门口。【先附花灯担按 E 举高。】")
    elif not flags.get("knocked", false):
     flags.knocked = true
     play_fx("doorring_clear")
     say("阿澄", "第二叩——锈屑落下，声清了。【叩门完成。报到三件：开道锣、潮鼓、深波锣，次序自由，各响一次——第一件响起，就是替它报到的那一次。】")
     save_game()
    else:
     play_fx("doorring_clear")
     say("阿澄", "门环声清。门里的人，听得见了。")
   else:
    play_fx("doorring_rust")
    say("阿澄", "锈死的门环，叩声由涩转清。")
  "deepgong":
   if phase == "playing" and seg6 == 5:
    trio_hit6("deepgong")
   else:
    play_gong()
    say("阿澄", "深波锣的低音，贴着巷子走。")
 flash_id = current
 flash_t = 0.0
 obj_anim_id = current
 obj_anim_t = 0.0
 append_tip("act", "对，就是这么用物件的本事：先在灵域选好物件，Tab 回现实，按 E 动手。")
 save_game()
 queue_redraw()

func tick_ch6(delta: float) -> void:
 # 本章无对手侧逐帧状态：雾锢、报到、活人调度均为确定性判定，香时由 advance_time 统一推进
 pass

func fail6() -> void:
 phase = "failure"
 failure_wait = 5.0
 fail_kind = "incense_out"
 play_fx("rewind")
 match seg6:
  1: say("庙祝公", "香在长明灯前烧到尽头，庙祝公重新点香——他的手很稳：「心不齐，路走不远。重来。」【回到宫门段起点：列队、起轿，重来。】")
  2:
   if fog6 == "": say("阿澄", "庙里的香又断了，铜铃在雾里只剩一个轮廓。【铜铃上的雾退了，可报到还没响——附铜铃，响它一声。回到土地庙段起点。】")
   else: say("阿澄", "庙里的香又断了，铜铃在雾里只剩一个轮廓。【指向：庙香断了——附土地公小香炉，火星上窜，把庙祝公续上的新香引燃。回到土地庙段起点。】")
  3: say("莲婶", "茶铺的灯一盏盏熄了，莲婶还站在招牌下等——等锣响大声点。【指向：花灯照街、潮鼓应锣、开道锣报到。回到溪尾街段起点。】")
  4: say("阿勇", "雾把桥重新吞回去，阿勇的点名声停在桥这头——「……花灯担？潮鼓？」【指向：应一声解开花灯，照亮桥面，再点名、响鼓。回到桥头段起点。】")
  5: say("纸扎人", "巷子里的雾合拢，旧宅的门牌隐进黑里；纸扎人的头仍稳稳对着巷底——它还在等。【无声的指向：标旗、叩门、报到三件。回到西巷段起点。】")
  _: say("名册", "天边发白又压回去，名册还摊在祠堂前的桌上，墨迹未干。【指向：补页还没写完，最后一附还没落。回到归程段起点——补路的成果不回滚。】")

func retry6() -> void:
 if seg6_snap.has("flags"):
  flags = (seg6_snap["flags"] as Dictionary).duplicate(true)
  reported6 = (seg6_snap["reported"] as Dictionary).duplicate(true)
  reported_nodes6 = (seg6_snap["rnodes"] as Dictionary).duplicate(true)
  trio6 = (seg6_snap["trio"] as Dictionary).duplicate(true)
  trade6_left = int(seg6_snap["trade"])
  remaining = float(seg6_snap["remaining"])
 seen_update1 = bool(flags.get("update1", false))
 seen_update2 = bool(flags.get("update2", false))
 seg6_begin(seg6, false, false)
 say("阿澄", "香刚点燃——回到这一段的开头。已报到的站、已落的命运更新，都不回滚。")

func enter_epilogue() -> void:
 branch6 = clear_variant == "branch"
 phase = "epilogue"
 queue_redraw()

func finish6() -> void:
 start_shake()
 clear_save6()
 clear_variant = "branch" if branch6 else "canon"
 var ls = ls_store()
 if ls != null: ls.setItem(CLEAR_KEY, clear_variant)
 all_clear = true
 ending_t = 0.0
 hook_bell_done = false
 phase = "ending"
 flags.ending = true
 say("阿澄／阿弟", "最后一附——我落在阿弟怀里的签上。签面浮起一行水汽般的字影，转瞬隐去。阿弟只来得及认出一个字的轮廓，没有读全；他先是愣住，然后把签贴在胸口，哭得站不稳，又慢慢站直。那行字的全文，他当晚在梦里逐字看清——写的是什么，故事不说。【命运更新②：该走的人，换成了自愿走的。】破晓的阳光越过宫墙时，我随最后一缕香烟散去——香尽，天亮。这一程，走完了。")
 queue_redraw()

func draw_finale6() -> void:
 if bg6_tex_nextyear != null:
  draw_texture_rect(bg6_tex_nextyear, Rect2(0, 0, 1280, 720), false)
  draw_rect(Rect2(0, 0, 1280, 720), Color(0.03, 0.05, 0.10, 0.38))
  if horse_epi_tex != null and horse_epi_rect.size.x > 0:
   var hh6 = 168.0
   var hw6 = hh6 * float(horse_epi_rect.size.x) / float(horse_epi_rect.size.y)
   if branch6:
    draw_set_transform(Vector2(215, 572), 0.055, Vector2.ONE)
    draw_texture_rect_region(horse_epi_tex, Rect2(-hw6 / 2, -hh6, hw6, hh6), horse_epi_rect)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
   else:
    draw_texture_rect_region(horse_epi_tex, Rect2(215 - hw6 / 2, 566 - hh6, hw6, hh6), horse_epi_rect)
 text_at(Vector2(150, 150), "小英把英歌槌收好，说年要教村里的女孩子打头槌。", 20, Color("9dabbc"))
 text_at(Vector2(150, 195), "细叔把新引路轿供进宫里，与长明灯并列；莲婶回茶铺开火烧水，招牌在晨光里稳稳的。", 20, Color("9dabbc"))
 text_at(Vector2(150, 240), "莲婶拉住阿弟，替他理了理衣领：「明年你就十五了，该出花园了——老爷保号，平平安安，是大人了。」", 20, Color("9dabbc"))
 text_at(Vector2(150, 285), "庙祝公把长明灯擦亮，对水生说：明天起，你跟我守宫。", 20, Color("9dabbc"))
 text_at(Vector2(150, 330), "要去深圳打工的队员把英歌槌擦了又擦——明年还回不回来，他没说。", 20, Color("9dabbc"))
 text_at(Vector2(400, 415), "第二年正月十五，阿弟站上了哥哥的轿夫位。", 24, Color("8dded7"))
 text_at(Vector2(316, 460), "队伍出发前，他冲着宫门口的空气说了一句「哥，走了」——", 24, Color("8dded7"))
 if branch6:
  text_at(Vector2(448, 505), "宫门口的纸扎马，垂着头，静静的，没有动。", 24, Color("8dded7"))
 else:
  text_at(Vector2(448, 505), "宫门口的纸扎马，头轻轻点了一下。", 24, Color("8dded7"))
 text_at(Vector2(540, 575), "全卷完 · 夜巡", 30, Color("d8b777"))
 text_at(Vector2(455, 625), "Enter 返回标题", 20)

func objective_text6() -> String:
 if phase == "tutorial": return "试一试：按 Tab 切到现实，再按 E，听庙祝公把出发前的事做完"
 if phase == "explore": return "四处附身看看，准备好了按 F 点最后一炷香"
 if phase == "playing":
  match seg6:
   1: return "宫门：附神轿按 E 晃铃——起轿，出发即报到"
   2:
    if fog6 != "": return "土地庙：附土地公小香炉按 E 火星上窜，重燃庙香，解开铜铃的雾锢"
    return "土地庙：附铜铃按 E 响铃——报到"
   3:
    if not flags.get("street_ready", false): return "溪尾街：附花灯担按 E 举高照街，莲婶到位"
    if fog6 != "": return "溪尾街：附潮鼓按 E 应它一声（应答版），解开开道锣的雾锢"
    return "溪尾街：附开道锣按 E 响锣——报到"
   4:
    if fog6 != "": return "桥头：附神轿晃铃或潮鼓按 E，应它一声，解开花灯担的雾锢"
    if not flags.get("bridge_lit", false): return "桥头：附花灯担按 E 举高，照开桥面"
    if not flags.get("rollcall", false): return "桥头：附神轿按 E 晃铃，阿勇点名"
    return "桥头：附潮鼓按 E 响鼓——报到"
   5:
    if not flags.get("flag_open", false): return "西巷：附标旗按 E 展开，领队入巷"
    if not flags.get("knocked", false): return "西巷：附门环按 E 叩门（先叩、花灯移光、再叩）"
    return "西巷：报到三件各响一次（开道锣／潮鼓／深波锣，次序自由）——交易第 3 次在此兑现"
   6:
    if not flags.get("pages_done", false): return "祠堂前：按 E 旁观——认错、补页，是活人说给活人听的"
    return "归程：灵域里点阿弟怀里的签——最后一附"
 if phase == "failure": return "没关系，回到本段起点再来——已报到的站不回滚"
 if phase == "ending": return "全卷完"
 return ""

func hint_text6() -> String:
 if phase == "title": return "按 Enter 或点一下，就能开始。"
 if phase == "tutorial": return "你顺香火落在长明灯上。按 Tab 切到现实，再按 E，听庙祝公添满灯油、剪齐灯芯，试试手。"
 if phase == "explore": return "在灵域点发青光的物件附身四处看。这一章不再赶它、不再跟它开价——队伍走到哪一站，就替它把哪一站报全。准备好了按 F 点最后一炷香。"
 if phase == "playing":
  match seg6:
   1: return "宫门段：庙祝公添满长明灯（状态链末环），六叔公换上轿夫短打站到轿杠旁。附神轿按 E 晃铃起轿——宫门这一站，出发即报到。"
   2: return "雾锢不是占位：它不在物件里，是它「停在这里不肯走」的重量压住了铜铃。解锢法每站不同，共同原则是补上这一站欠的东西——土地庙欠的是断了的庙香：附土地公小香炉按 E 火星上窜，重燃庙香，雾自退；再附铜铃按 E 报到。"
   3: return "溪尾街欠的是一声应答。先附花灯担按 E 举高照街、莲婶到位（调度与解锢次序可换）；再附潮鼓按 E——在锢住的开道锣旁以应答版响一声，雾退；最后附开道锣按 E 报到。满音量乱敲赶不走雾锢。"
   4: return "桥头解锢是双源：附神轿晃铃、或附潮鼓，在花灯担旁以应答版响一声都算。解锢后附花灯担按 E 照桥，再附神轿按 E 落阿勇的点名，最后附潮鼓按 E 报到。前置未齐时响鼓，只得一句「雾没散，鼓声传不到桥心」。"
   5: return "西巷没有锢点——它在家门口不等处理。附标旗按 E 展开入巷；附门环按 E 叩门：第一叩锈涩，去花灯担把光移到门口，再叩才清。叩门后报到三件（开道锣、潮鼓、深波锣）次序自由各响一次；第一件响起，第五章锁定的第 3 次交易就此兑现——亲手给它报到。"
   6: return "归程段先在祠堂前停轿：随便在哪件物件上按 E，旁观六叔公认错、补写名册撕页、水生在边角留名。补页落后，灵域里点阿弟怀里的签（队伍旁的青光点）——最后一附，附入即终局。"
 if phase == "failure": return "别慌，不会真死。等一下（或按 Enter）就会回到本段起点——已报到的站、已落的命运更新不回滚，香时恢复为本段开始时的样子。"
 if phase == "ending": return "全卷完了。按 Enter 回到标题；标题页按 T 可以回看尾声。"
 return "按 Tab 切换灵域／现实，灵域点物件附身，现实按 E 用物件的本事。这一章的规矩是清路与报到：雾锢靠补上这一站欠的东西解开，报到靠响器在队伍到齐的拍上响起。"

func save_game6() -> void:
 var data = {"phase": phase, "current": current, "spirit": spirit, "remaining": remaining, "flags": flags, "seen_tips": seen_tips, "seg6": seg6, "reported6": reported6, "rnodes": reported_nodes6, "trio6": trio6, "trade6_left": trade6_left, "fog6": fog6, "scare_tried6": scare_tried6, "branch6": branch6, "acct_d": acct6s_drive, "acct_a": acct6s_answer, "snap": seg6_snap}
 has_save6 = true
 save_data6 = data.duplicate(true)
 var ls = ls_store()
 if ls != null: ls.setItem(SAVE_KEY6, JSON.stringify(data))

func clear_save6() -> void:
 has_save6 = false
 save_data6 = {}
 var ls = ls_store()
 if ls != null: ls.removeItem(SAVE_KEY6)

func continue_game6() -> void:
 if not has_save6: return
 var d: Dictionary = save_data6
 start_chapter6()
 var ph = str(d.get("phase", "playing"))
 phase = ph if ph in ["tutorial", "explore", "playing"] else "playing"
 seg6 = int(d.get("seg6", 1))
 graph = ch6_graph_for(seg6)
 ch6_place_team()
 npc_pos = ch6_npc_defaults()
 npc_walking = {}
 current = str(d.get("current", "everlamp"))
 prev_current = current
 spirit = bool(d.get("spirit", true))
 remaining = float(d.get("remaining", 360.0))
 flags = (d.get("flags", {}) as Dictionary).duplicate(true)
 seen_tips = (d.get("seen_tips", {}) as Dictionary).duplicate(true)
 seen_update1 = bool(flags.get("update1", false))
 seen_update2 = bool(flags.get("update2", false))
 reported6 = (d.get("reported6", {}) as Dictionary).duplicate(true)
 reported_nodes6 = (d.get("rnodes", {}) as Dictionary).duplicate(true)
 trio6 = (d.get("trio6", {}) as Dictionary).duplicate(true)
 trade6_left = int(d.get("trade6_left", 1))
 fog6 = str(d.get("fog6", ""))
 scare_tried6 = bool(d.get("scare_tried6", false))
 branch6 = bool(d.get("branch6", false))
 acct6s_drive = int(d.get("acct_d", acct6_drive))
 acct6s_answer = int(d.get("acct_a", acct6_answer))
 seg6_snap = (d.get("snap", {}) as Dictionary).duplicate(true)
 if seg6 == 5: set_ambience_pair("amb6_alley", "amb6_alley")
 elif seg6 == 6 and flags.get("update1", false): set_ambience_pair("amb6_dawn", "amb6_dawn")
 say("阿澄", "香还燃着……回到没走完的那一段。")
 queue_redraw()
