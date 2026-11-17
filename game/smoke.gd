extends SceneTree

var game
var errors := 0
var checks := 0
const LINKS = {
 "incense": ["sticks"], "sticks": ["incense", "candle"],
 "candle": ["sticks", "drum"], "drum": ["candle", "palanquin", "horse"],
 "palanquin": ["drum", "flag", "beam"], "flag": ["palanquin", "umbrella"],
 "beam": ["palanquin", "lantern", "crackers"], "lantern": ["beam", "crackers"],
 "crackers": ["lantern", "beam"], "horse": ["drum"],
 "umbrella": ["flag", "loudspeaker"], "loudspeaker": ["umbrella"]
}

func _initialize() -> void:
 call_deferred("run")

func check(ok: bool, label: String) -> void:
 checks += 1
 if ok:
  print("PASS ", label)
 else:
  errors += 1
  print("FAIL ", label)

func path_to(target: String) -> Array:
 var queue: Array = [[str(game.current)]]
 var seen: Dictionary = {}
 while not queue.is_empty():
  var path: Array = queue.pop_front()
  var node: String = path.back()
  if node == target:
   return path
  if seen.has(node):
   continue
  seen[node] = true
  for other in game.graph[node]:
   var next: Array = path.duplicate()
   next.append(other)
   queue.append(next)
 return []

func move(target: String) -> void:
 game.set_spirit(true)
 var path: Array = path_to(target)
 check(not path.is_empty(), "BFS route to " + target)
 for index in range(1, path.size()):
  if str(game.current) == "umbrella" and str(path[index]) == "loudspeaker":
   game.set_spirit(false)
   game.act()
   game.set_spirit(true)
  var ok = game.jump_to(str(path[index]))
  check(bool(ok), "legal jump " + str(path[index - 1]) + " -> " + str(path[index]))

func use(target: String) -> void:
 move(target)
 game.set_spirit(false)
 game.act()
 game.set_spirit(true)

func fresh() -> void:
 if is_instance_valid(game):
  game.free()
 game = load("res://main.gd").new()
 root.add_child(game)
 game.start_game()
 game.set_spirit(false)
 game.act()
 game.start_incense()
 game.set_spirit(true)
 check(str(game.phase) == "playing", "title -> incense tutorial -> timed chapter")

func solve(alternative: bool) -> void:
 fresh()
 use("sticks")
 check(bool(game.flags.get("update1", false)), "fate update 1 recorded")
 use("palanquin")
 check(bool(game.flags.get("update2", false)), "fate update 2 recorded")
 use("candle")
 if alternative:
  use("loudspeaker")
 else:
  use("flag")
 use("beam")
 use("crackers")
 check(str(game.phase) == "ending", "alternative ending" if alternative else "six-step canonical ending")

func run() -> void:
 print("YEXUN R1 state-machine smoke: actual game API + legal graph jumps")
 solve(false)
 solve(true)
 fresh()
 use("drum")
 use("drum")
 check(str(game.phase) == "playing", "two drum strikes do not fail immediately")
 use("drum")
 check(str(game.phase) == "failure", "third drum strike reaches failure")
 game._process(5.1)
 check(str(game.phase) == "playing", "failure automatically retries after ghost dialogue")
 check(str(game.current) == "incense" and game.flags.is_empty(), "automatic retry resets possession and puzzle flags")
 fresh()
 var before: String = str(game.phase)
 game.set_spirit(true)
 game.advance_time(1000.0)
 check(str(game.phase) == before, "spirit realm pauses incense timer")
 game.set_spirit(false)
 game.advance_time(1000.0)
 check(str(game.phase) == "failure", "reality incense timeout reaches death event")
 fresh()
 check(not bool(game.jump_to("lantern")), "nonadjacent jump rejected")
 for node in LINKS:
  move(str(node))
  move("incense")
 check(str(game.current) == "incense", "all 12 nodes actually reachable from and return to incense")
 fresh()
 use("crackers")
 check(str(game.phase) == "playing" and not bool(game.flags.get("fuse", false)), "unprepared crackers reject ignition")
 use("sticks")
 game.set_spirit(false)
 game.advance_time(19.0)
 check(not bool(game.flags.get("pickup", false)), "Adi returns to frame when pickup window expires")
 use("palanquin")
 check(not bool(game.flags.get("safe", false)), "missed pickup window cannot silently secure Adi")
 fresh()
 use("sticks")
 use("palanquin")
 use("candle")
 use("flag")
 use("crackers")
 check(str(game.phase) == "playing", "crackers without beam preparation cannot complete chapter")
 fresh()
 use("beam")
 check(str(game.phase) == "playing" and game.remaining < 240.0, "premature beam shake accelerates collapse")
 use("beam")
 if str(game.phase) == "playing":
  use("beam")
 check(str(game.phase) == "failure", "repeated premature beam shakes fail")
 game.start_game()
 game.set_spirit(false)
 game.act()
 check(str(game.phase) == "explore", "incense tutorial opens free exploration")
 use("loudspeaker")
 game.start_incense()
 check(str(game.phase) == "playing" and str(game.current) == "incense", "starting timed chapter from distant exploration returns to incense")
 check(game.flags.is_empty() and game.remaining == 240.0, "timed chapter clears exploration effects and starts full incense")
 run_ch2()
 run_ch3()
 run_ch4()
 run_ch5()
 run_ch6()
 run_fix_r1()
 print("SMOKE RESULT: ", "PASS" if errors == 0 else "FAIL", " checks=", checks, " failures=", errors)
 quit(0 if errors == 0 else 1)




# ================= chapter 2 smoke (DESIGN_CH2_DRAFT v0.1) =================

func fresh2() -> void:
 if is_instance_valid(game):
  game.free()
 game = load("res://main.gd").new()
 root.add_child(game)
 game.start_chapter2()
 check(str(game.phase) == "tutorial" and str(game.current) == "palanquin", "ch2 opens inside the big sedan")
 game.set_spirit(false)
 game.act()
 check(str(game.phase) == "explore", "ch2 tutorial bell opens exploration")
 game.start_incense()
 check(str(game.phase) == "playing" and str(game.current) == "censer", "ch2 second incense starts at the shrine censer")
 check(game.remaining == 300.0, "ch2 incense is 300 seconds")
 game.set_spirit(true)

func bfs_seen(g: Dictionary, start: String, banned: String) -> Dictionary:
 var seen: Dictionary = {start: true}
 var queue: Array = [start]
 while not queue.is_empty():
  var n: String = queue.pop_front()
  for m in g[n]:
   if m == banned or seen.has(m):
    continue
   seen[m] = true
   queue.append(m)
 return seen

func run_ch2() -> void:
 print("YEXUN ch2 smoke: opponent system + solution chain + error branches")
 fresh2()
 var g: Dictionary = game.graph
 check(bfs_seen(g, "censer", "").size() == 12, "ch2 graph: all 12 nodes reachable without the conditional edge (S-2)")
 var symmetric = true
 for a in g:
  for b in g[a]:
   if a not in g[b]:
    symmetric = false
 check(symmetric, "ch2 graph: every edge is two-way")
 var s1_ok = true
 for banned in g:
  var start = "censer" if banned != "censer" else "gong"
  if bfs_seen(g, start, banned).size() != 11:
   s1_ok = false
 check(s1_ok, "ch2 graph: any single occupied node leaves the other 11 connected (S-1)")
 check(str(game.opp_pos) == "drum", "ch2 opponent opens on the drum (tuned first-encounter phase)")
 move("flag")
 check(not bool(game.jump_to("drum")), "occupied drum rejects possession with the fixed refusal")
 use("gong")
 check(bool(game.clean.has("drum")), "scared-off drum gains the clean mark")
 check(str(game.opp_pos) != "drum", "opponent fled the drum after the gong scare")
 check(bool(game.flags.get("update1", false)), "ch2 fate update 1: its rules are revealed")
 var drum_revisited = false
 var bad_station = ""
 for i in range(40):
  game.opp_timer = 0.0
  game.set_spirit(false)
  game.advance_time(0.1)
  if str(game.opp_pos) == "drum":
   drum_revisited = true
  if str(game.opp_pos) in ["censer", "teasign", "lampstand"]:
   bad_station = str(game.opp_pos)
 check(not drum_revisited, "clean drum is never re-occupied (immunity)")
 check(bad_station == "", "opponent never occupies censer / sign / lampstand")
 fresh2()
 move("gong")
 game.opp_pos = "palanquin"
 game.opp_idx = 2
 game.opp_timer = 0.0
 var before_remain: float = game.remaining
 game.set_spirit(false)
 game.advance_time(0.1)
 check(str(game.opp_pos) == "gong", "opponent advances along its written sequence")
 check(str(game.current) == "flag", "lingering player is squeezed back to the previous object")
 check(game.remaining < before_remain - 9.0, "squeeze-out costs 10 incense seconds")
 fresh2()
 move("minisedan")
 check(str(game.current) == "minisedan", "player may enter the small sedan while it is away")
 var rem_before: float = game.remaining
 game.set_spirit(false)
 game.advance_time(10.5)
 check(str(game.current) != "minisedan", "player is silently pushed out after 10 reality seconds in the small sedan")
 check(absf(game.remaining - (rem_before - 10.5)) < 0.6, "small-sedan overstay eject costs no incense")
 move("paperfig")
 game.opp_pos = "minisedan"
 game.opp_idx = 1
 var rem2: float = game.remaining
 check(not bool(game.jump_to("minisedan")), "occupied small sedan rejects entry")
 check(absf(game.remaining - (rem2 - 5.0)) < 0.01, "forcing the occupied small sedan costs 5 seconds")
 fresh2()
 use("umbrella")
 check("teasign" in game.graph["umbrella"], "opened umbrella adds the sign shortcut edge (shortcut only, S-2)")
 fresh2()
 use("crackers")
 check(bool(game.flags.get("crackers_used", false)) and str(game.phase) == "playing", "early crackers are spent but the chapter is not dead-ended (S-6)")
 fresh2()
 use("lampstand")
 check(bool(game.flags.get("sign_seen", false)), "lampstand investigation reveals the cut rope (guaranteed clue path, S-3)")
 move("vat")
 check(bool(game.flags.get("inv_vat", false)), "vat investigation: only the small sedan casts no reflection")
 use("gong")
 check(bool(game.flags.get("update1", false)), "first scare from the gong teaches the rules")
 use("flag")
 use("palanquin")
 check(bool(game.flags.get("xiaoying_safe", false)), "flag window + sedan bell moves Xiaoying off the sign for good")
 check(bool(game.flags.get("update2", false)), "ch2 fate update 2 recorded")
 use("vat")
 check(bool(game.flags.get("lianshen_safe", false)), "vat ripples draw Lianshen out from under her sign")
 use("teasign")
 check(bool(game.flags.get("loosened", false)), "sign loosened once both people are clear (safety preconditions, S-4)")
 use("crackers")
 check(str(game.phase) == "ending", "ch2 canonical ending: sign falls early on the empty street")
 fresh2()
 use("lampstand")
 use("gong")
 use("flag")
 use("palanquin")
 use("vat")
 use("teasign")
 use("drum")
 check(str(game.phase) == "ending", "ch2 alternative ending: drum as the final vibration source (distance-exempt)")
 fresh2()
 use("teasign")
 check(game.remaining < 300.0 and str(game.phase) == "playing", "blind sign shake costs 45 seconds and cannot finish")
 use("teasign")
 check(str(game.phase) == "failure" and str(game.fail_kind) == "xy_dead", "second blind shake drops the sign: Xiaoying branch (S-8)")
 game._process(5.1)
 check(str(game.phase) == "playing" and game.clean.is_empty() and str(game.opp_pos) == "drum", "ch2 failure auto-retries: opponent phase and clean marks reset")
 fresh2()
 use("gong")
 use("drum")
 use("drum")
 check(str(game.phase) == "playing", "two drum strikes do not fail immediately (ch2)")
 use("drum")
 check(str(game.phase) == "failure" and str(game.fail_kind) == "xy_dead", "third drum strike drops the sign early: Xiaoying branch")
 fresh2()
 game.set_spirit(false)
 game.advance_time(1000.0)
 check(str(game.phase) == "failure" and str(game.fail_kind) == "timeout", "ch2 incense timeout fails on the self-talk branch (S-8)")


# ================= chapter 3 smoke (DESIGN_CH3_DRAFT v0.1) =================

func fresh3() -> void:
 if is_instance_valid(game):
  game.free()
 game = load("res://main.gd").new()
 root.add_child(game)
 game.start_chapter3()
 check(str(game.phase) == "tutorial" and str(game.current) == "hallcenser", "ch3 opens on the ancestral hall altar")
 game.set_spirit(false)
 game.act()
 check(str(game.phase) == "explore", "ch3 tutorial sparks open exploration")
 game.start_incense()
 check(str(game.phase) == "playing" and str(game.current) == "hallcenser", "ch3 third incense starts at the hall altar")
 check(game.remaining == 330.0, "ch3 incense is 330 seconds")
 game.set_spirit(true)

func hop3(target: String) -> void:
 game.jump_count = 0
 move(target)

func use3(target: String) -> void:
 hop3(target)
 game.set_spirit(false)
 game.act()
 game.set_spirit(true)

func graph_without_edge(g: Dictionary, a: String, b: String) -> Dictionary:
 var copy: Dictionary = {}
 for k in g:
  var lst: Array = []
  for m in g[k]:
   if (k == a and m == b) or (k == b and m == a):
    continue
   lst.append(m)
  copy[k] = lst
 return copy

func run_ch3() -> void:
 print("YEXUN ch3 smoke: mimic opponent + dual scene graph + solution chain")
 fresh3()
 var g3: Dictionary = game.graph
 check(bfs_seen(g3, "hallcenser", "").size() == 12, "ch3 graph: all 12 nodes reachable across both scenes (S-1/S-2)")
 var symmetric3 = true
 for a in g3:
  for b in g3[a]:
   if a not in g3[b]:
    symmetric3 = false
 check(symmetric3, "ch3 graph: every edge is two-way (incl. both relay edges)")
 var s1_ok3 = true
 for banned in g3:
  var start3 = "hallcenser" if banned != "hallcenser" else "horse"
  if bfs_seen(g3, start3, banned).size() != 11:
   s1_ok3 = false
 check(s1_ok3, "ch3 graph: any single occupied node leaves the other 11 connected (S-1, dual scene)")
 check(bfs_seen(graph_without_edge(g3, "hallcenser", "oldcenser"), "hallcenser", "").size() == 12, "ch3 graph: incense relay cut, paper route still connects both scenes")
 check(bfs_seen(graph_without_edge(g3, "flag", "horse"), "hallcenser", "").size() == 12, "ch3 graph: one paper-route foot cut, the other plus incense relay still connect")
 check(bfs_seen(graph_without_edge(g3, "drum", "horse"), "hallcenser", "").size() == 12, "ch3 graph: other paper-route foot cut, still fully connected")
 check(str(game.opp3_pos) == "horse", "ch3 opponent opens on the paper horse in the corridor")
 check(not bool(game.jump_to("horse")), "occupied paper horse rejects possession with the fixed refusal")
 var seen_pos: Dictionary = {}
 for i in range(60):
  game.opp3_timer = 0.0
  game.set_spirit(false)
  game.advance_time(0.1)
  seen_pos[str(game.opp3_pos)] = true
 var never_ok = true
 for p in seen_pos:
  if p not in ["horse", "bamboo", "drum", "bell", "teatable"]:
   never_ok = false
 check(never_ok and not seen_pos.has("roster") and not seen_pos.has("sedanrem"), "opponent never occupies roster / sedan remains (never-occupy list)")
 fresh3()
 game.jump_to("teatable")
 game.jump_to("roster")
 check(str(game.opp3_pos) == "horse", "two jumps do not trigger the mimic advance")
 game.jump_to("hallcenser")
 check(str(game.opp3_pos) == "bamboo", "third jump triggers mimic advance (sequence fallback when no skill was used)")
 check(str(game.last_adv_mode) == "mimic" and game.fake_t >= 0.0, "mimic move is presented as the fake light trail (no landing glow)")
 check(game.jump_count == 0 and game.opp3_timer == 45.0, "mimic advance resets jump count and station timer together")
 fresh3()
 use3("teatable")
 check(bool(game.keeper_out), "tea lid summons the steward away: dispatch window opens")
 check(game.window3_left > 20.0, "tea-table window is 25 seconds (primary dispatch)")
 use3("roster")
 check(bool(game.flags.get("roster_tonight", false)), "roster inside the window: the new rope came from the storehouse (clue 1)")
 use3("roster")
 check(bool(game.flags.get("torn_seen", false)), "old archive: the page was torn out whole, not rotted (clue 2)")
 game.jump_count = 2
 game.jump_to("hallcenser")
 check(str(game.opp3_pos) == "teatable", "mimic advance lands on the last used skill object (the tea table, designed first encounter)")
 check(bool(game.flags.get("mimic_revealed", false)), "first mimic encounter speaks the two tells (paper-horse radar + unlit landing)")
 hop3("bell")
 game.set_spirit(false)
 game.act()
 game.set_spirit(true)
 check(bool(game.clean3.has("teatable")), "bell scare wins the tea table back with the clean mark")
 check(game.jump_count == 0, "scaring it off also resets the jump count")
 check(str(game.opp3_pos) != "teatable", "opponent fled the tea table after the scare")
 check(bool(game.flags.get("lie_heard", false)), "same beat: Shuisheng's too-quick lie is heard")
 fresh3()
 game.clean3["teatable"] = true
 game.last_skill = "teatable"
 game.jump_count = 2
 game.jump_to("teatable")
 check(str(game.opp3_pos) == "bamboo", "mimic target already clean: falls forward to the next sequence station")
 fresh3()
 game.jump_to("roster")
 game.jump_to("bell")
 check(str(game.current) == "bell", "setup: player waits on the bell")
 game.opp3_pos = "drum"
 game.opp3_idx = 2
 game.opp3_timer = 0.0
 var rem3: float = game.remaining
 game.set_spirit(false)
 game.advance_time(0.1)
 check(str(game.opp3_pos) == "bell", "timer advance follows the written sequence onto the bell")
 check(str(game.current) == "roster", "lingering player is squeezed back to the previous object")
 check(absf(game.remaining - (rem3 - 10.1)) < 0.6, "squeeze-out costs 10 incense seconds")
 fresh3()
 use3("hallcenser")
 check(bool(game.keeper_out) and game.window3_left <= 15.0, "altar sparks open the shorter 15 second window (alternative dispatch)")
 game.set_spirit(false)
 game.advance_time(16.0)
 check(not bool(game.keeper_out), "window closes when it lapses unused; the steward returns")
 use3("roster")
 check(not bool(game.flags.get("roster_tonight", false)), "roster cannot be read while the steward watches (dispatch first, S-5)")
 fresh3()
 use3("chest")
 check(bool(game.flags.get("chest_seen", false)), "optional: chest list confirms the paper sedan was sealed and stored (bonus clue)")
 use3("oldcenser")
 check(bool(game.flags.get("ember_seen", false)), "optional: old censer ember shows a lamp shape (bonus, no explanation)")
 game.opp3_pos = "horse"
 game.opp3_idx = 0
 use3("sedanrem")
 check(bool(game.flags.get("remains_seen", false)) and bool(game.flags.get("account_found", false)), "sedan remains and the account page corroborate each other (clue 3)")
 use3("bamboo")
 check(bool(game.flags.get("memory_seen", false)), "bamboo touch restores the first memory: the storehouse lamp was lit (the lie breaks)")
 fresh3()
 game.opp3_pos = "bamboo"
 game.opp3_idx = 1
 hop3("oldcenser")
 hop3("crackers")
 game.set_spirit(false)
 game.act()
 game.set_spirit(true)
 check(bool(game.clean3.has("bamboo")), "crackers scare the bamboo stand clean from next door (B-field ringer)")
 check(bool(game.flags.get("crackers_used", false)), "crackers are one-shot; spent early they still leave a way through (S-6)")
 fresh3()
 game.opp3_pos = "drum"
 game.opp3_idx = 2
 hop3("flag")
 hop3("horse")
 hop3("sedanrem")
 check(str(game.current) == "sedanrem", "paper route alone reaches the storage room (flag -> paper horse -> remains)")
 fresh3()
 use("teatable")
 use("roster")
 use("roster")
 use("bell")
 check(bool(game.clean3.has("teatable")), "canonical pace: mimic takes the tea table, bell scare clears it")
 check(bool(game.flags.get("lie_heard", false)), "canonical pace: the lie surfaces in the same beat")
 hop3("oldcenser")
 hop3("chest")
 use3("sedanrem")
 use("bamboo")
 use("flag")
 check(bool(game.flags.get("flag_raised", false)), "canonical pace: flag gathers the courtyard once the evidence chain is complete")
 use3("bell")
 check(str(game.phase) == "ending", "ch3 canonical ending: flag then bell keeps the team together")
 check(bool(game.flags.get("update1", false)), "ch3 fate update (the situation itself) recorded")
 fresh3()
 use3("bell")
 check(str(game.phase) == "playing" and not bool(game.flags.get("flag_raised", false)), "finale stays locked before the evidence chain is complete (S-4)")
 use3("teatable")
 use3("roster")
 use3("roster")
 hop3("oldcenser")
 hop3("chest")
 use3("sedanrem")
 use3("bamboo")
 hop3("oldcenser")
 hop3("hallcenser")
 use3("bell")
 check(str(game.phase) == "playing", "bell before flag only scatters the sound: no finale, redo allowed")
 game.opp3_pos = "teatable"
 game.opp3_idx = game.opp3_seq.find("teatable")
 hop3("bell")
 game.set_spirit(false)
 game.act()
 game.set_spirit(true)
 check(bool(game.flags.get("lie_heard", false)), "alternative path also hears the lie before the finale (FIX-R1 F-03)")
 use3("flag")
 check(bool(game.flags.get("flag_raised", false)), "flag first: every eye turns to the courtyard")
 use3("drum")
 check(str(game.phase) == "ending", "ch3 alternative ending: drum settles the team in place of the bell")
 fresh3()
 game.set_spirit(true)
 game.advance_time(1000.0)
 check(str(game.phase) == "playing", "ch3 spirit realm pauses the third incense")
 game.set_spirit(false)
 game.advance_time(1000.0)
 check(str(game.phase) == "failure" and str(game.fail_kind) == "timeout", "ch3 incense timeout: the team breaks up (situation failure only, S-8)")
 game._process(5.1)
 check(str(game.phase) == "playing" and str(game.opp3_pos) == "horse" and game.clean3.is_empty() and game.jump_count == 0, "ch3 failure auto-retries: opponent phase, clean marks and jump count reset")


# ================= chapter 4 smoke (DESIGN_CH4_DRAFT v0.1) =================

func fresh4() -> void:
 if is_instance_valid(game):
  game.free()
 game = load("res://main.gd").new()
 root.add_child(game)
 game.start_chapter4()
 check(str(game.phase) == "tutorial" and str(game.current) == "shrine", "ch4 opens on the bridgehead shrine")
 game.set_spirit(false)
 game.act()
 check(str(game.phase) == "explore", "ch4 tutorial sparks open exploration")
 game.start_incense()
 check(str(game.phase) == "playing" and str(game.current) == "shrine", "ch4 fourth incense starts at the shrine")
 check(game.remaining == 360.0, "ch4 incense is 360 seconds")
 game.set_spirit(true)

func set_opp4(pos: String) -> void:
 game.opp4_pos = pos
 game.opp4_idx = game.opp4_seq.find(pos)
 game.opp4_timer = 45.0

func cross4() -> void:
 use("bridgerope")
 use("bridgebell")
 use("lampstand")
 use("sedanrope")
 use("drum")
 check(bool(game.flags.get("crossed", false)), "ch4 crossing once rope seen + warning chain + reinforcement all hold")
 check(bool(game.flags.get("update1", false)), "ch4 fate update 1: the bridge holds, the golden body crosses")

func run_ch4() -> void:
 print("YEXUN ch4 smoke: borrow-mouth dialogue + warning chain + bridge graph")
 fresh4()
 var g4: Dictionary = game.graph
 check(bfs_seen(g4, "shrine", "").size() == 12, "ch4 graph: all 12 nodes reachable on the long scroll (S-1/S-2)")
 var symmetric4 = true
 for a in g4:
  for b in g4[a]:
   if a not in g4[b]:
    symmetric4 = false
 check(symmetric4, "ch4 graph: every edge is two-way (incl. the ferry-rope crossing)")
 var s1_ok4 = true
 for banned in g4:
  var start4 = "shrine" if banned != "shrine" else "boat"
  if bfs_seen(g4, start4, banned).size() != 11:
   s1_ok4 = false
 check(s1_ok4, "ch4 graph: any single occupied node leaves the other 11 connected (S-1)")
 check(bfs_seen(graph_without_edge(g4, "sedanrope", "boat"), "shrine", "").size() == 12, "ch4 graph: ferry-rope route cut, bridge routes still cross")
 check(bfs_seen(graph_without_edge(g4, "bridgerope", "riverlamp"), "shrine", "").size() == 12, "ch4 graph: one bridge route cut, the other crossings still hold")
 check(bfs_seen(graph_without_edge(g4, "bridgerope", "palanquin"), "shrine", "").size() == 12, "ch4 graph: sedan bridge link cut, still fully connected")
 check(str(game.opp4_pos) == "paperfig", "ch4 opponent opens on the paper figure at the river port")
 check(not bool(game.jump_to("paperfig")), "occupied paper figure rejects possession with the fixed refusal")
 var seen4: Dictionary = {}
 for i in range(60):
  game.opp4_timer = 0.0
  game.set_spirit(false)
  game.advance_time(0.1)
  seen4[str(game.opp4_pos)] = true
 var never4 = true
 for p in seen4:
  if p not in ["paperfig", "lampstand", "bridgebell", "gong", "drum"]:
   never4 = false
 check(never4 and not seen4.has("shrine") and not seen4.has("palanquin") and not seen4.has("bridgerope"), "opponent never occupies shrine / sedan / bridge rope (never-occupy list)")
 fresh4()
 set_opp4("lampstand")
 use("drum")
 check(bool(game.clean4.has("lampstand")), "adjacent ringer scares a normally-occupied station clean")
 check(str(game.opp4_pos) != "lampstand", "opponent fled the lampstand after the scare")
 fresh4()
 move("bridgebell")
 set_opp4("lampstand")
 game.opp4_timer = 0.0
 var rem4: float = game.remaining
 game.set_spirit(false)
 game.advance_time(0.1)
 check(str(game.opp4_pos) == "bridgebell", "timer advance follows the written sequence onto the bell")
 check(str(game.current) == "shrine", "lingering player is squeezed back to the previous object")
 check(absf(game.remaining - (rem4 - 10.1)) < 0.6, "squeeze-out costs 10 incense seconds")
 fresh4()
 use("bridgerope")
 check(bool(game.flags.get("rope_seen", false)), "rope investigation states the cut outright (guaranteed clue, S-3)")
 use("lampstand")
 check(not bool(game.flags.get("warn_lit", false)), "lamp before bell lights nothing: chain order enforced, feedback only")
 use("drum")
 check(not bool(game.flags.get("warn_done", false)), "drum before the light cannot stop the team")
 use("bridgebell")
 check(bool(game.flags.get("warn_bell", false)), "warning chain 1: the bell lifts every head")
 use("lampstand")
 check(bool(game.flags.get("warn_lit", false)), "warning chain 2: the light puts the cut before their eyes")
 use("drum")
 check(bool(game.flags.get("warn_done", false)), "warning chain 3: the off-beat drum stops the team")
 check(not bool(game.flags.get("crossed", false)), "no crossing before the rope is reinforced (S-4)")
 use("sedanrope")
 check(bool(game.flags.get("crossed", false)), "reinforcement completes the preconditions: the team crosses")
 fresh4()
 use("sedanrope")
 check(bool(game.flags.get("reinforced", false)) and not bool(game.flags.get("crossed", false)), "alternative: reinforcement may come before the warning chain")
 use("bridgerope")
 use("bridgebell")
 use("lampstand")
 use("drum")
 check(bool(game.flags.get("crossed", false)), "alternative order still crosses once all three preconditions hold")
 fresh4()
 use("boat")
 check(bool(game.flags.get("boat_seen", false)), "optional: the ferryman's father ferried the west-alley survivors (bonus)")
 use("papercargo")
 check(bool(game.flags.get("paper_sample_seen", false)), "optional: the old guide-sedan paper pattern under the cargo (bonus)")
 fresh4()
 cross4()
 check(bool(game.bm_active), "borrow-mouth begins when it holds the paper figure after the crossing")
 game.set_spirit(false)
 game.advance_time(10.0)
 check(str(game.opp4_pos) == "paperfig" and bool(game.bm_active) and game.opp4_timer == 45.0, "borrow-mouth: the 45 second station timer is paused while it waits")
 check(bool(game.bm_window_open), "the first answer window opens (teaching length)")
 use("papercargo")
 check(game.bm_round == 0 and bool(game.bm_window_open), "non-ringer skill inside the window: fixed refusal, no progress")
 use("drum")
 check(game.bm_round == 0 and bool(game.bm_window_open), "ringer from a non-adjacent object inside the window: neither answer nor scare")
 use("gong")
 check(game.bm_round == 1, "answer round 1 from the gong: the first full sentence lands")
 game.set_spirit(false)
 game.act()
 game.set_spirit(true)
 check(bool(game.bm_active) and str(game.opp4_pos) == "paperfig", "first out-of-window ringer between rounds only teaches; it stays")
 game.set_spirit(false)
 game.act()
 game.set_spirit(true)
 check(not bool(game.bm_active) and str(game.opp4_pos) != "paperfig", "second out-of-window ringer scares it off between rounds")
 check(not game.clean4.has("paperfig"), "borrow-mouth scare leaves NO clean mark on the paper figure (the written exception)")
 check(game.bm_round == 1, "completed rounds survive the scare-away (no dead end)")
 var guard4 = 0
 while str(game.opp4_pos) != "paperfig" and guard4 < 8:
  game.opp4_timer = 0.0
  game.set_spirit(false)
  game.advance_time(0.1)
  guard4 += 1
 check(str(game.opp4_pos) == "paperfig" and bool(game.bm_active), "it circles the sequence and returns to resume the dialogue")
 game.set_spirit(false)
 game.advance_time(3.5)
 check(bool(game.bm_window_open), "resumed dialogue reopens its answer window")
 game.set_spirit(false)
 game.advance_time(25.0)
 check(not bool(game.bm_window_open) and bool(game.bm_active) and game.bm_round == 1, "a missed window only repeats the fragment: no penalty, no round reset")
 game.set_spirit(false)
 game.advance_time(2.5)
 check(bool(game.bm_window_open), "the window reopens after the repeat")
 use("palanquin")
 check(game.bm_round == 2 and bool(game.flags.get("update2", false)), "answer round 2 from the sedan bell: fate update 2, the route is named")
 check(not bool(game.bm_active), "after round 2 it leaves the paper figure of its own accord")
 set_opp4("gong")
 use("lampstand")
 check(bool(game.flags.get("memory_seen", false)), "lampstand touch after the crossing restores the full memory (the death, fully revealed)")
 set_opp4("drum")
 use("papercargo")
 check(bool(game.flags.get("newsedan_done", false)), "paper cargo summons Xishu to make the new guide sedan")
 game.opp4_move_to("paperfig")
 check(bool(game.bm_active), "with bridge crossed, route answered and new sedan made, it returns for the last sentence")
 game.set_spirit(false)
 game.advance_time(3.5)
 check(bool(game.bm_window_open), "the final answer window opens only with all finale preconditions in place (S-4)")
 move("riverlamp")
 use("gong")
 check(str(game.phase) == "ending", "ch4 canonical ending: the last sentence is finished, the message from the hall arrives")
 fresh4()
 use("bridgerope")
 use("bridgerope")
 check(game.remaining < 316.0 and str(game.phase) == "playing", "first blind rope shake costs 45 seconds")
 use("bridgerope")
 check(str(game.phase) == "failure" and str(game.fail_kind) == "early_break", "second blind shake snaps the rope early: branch 3, under the bridge (S-8)")
 game._process(5.1)
 check(str(game.phase) == "playing" and game.bm_round == 0 and game.clean4.is_empty() and str(game.opp4_pos) == "paperfig", "ch4 failure auto-retries: opponent phase, clean marks and dialogue rounds reset")
 fresh4()
 use("bridgebell")
 use("bridgebell")
 use("bridgebell")
 check(str(game.phase) == "playing", "chain ring plus two idle rings do not fail yet")
 use("bridgebell")
 check(str(game.phase) == "failure" and str(game.fail_kind) == "early_break", "third idle bridgehead ring shakes the cut rope loose: branch 3")
 fresh4()
 game.set_spirit(false)
 game.advance_time(1000.0)
 check(str(game.phase) == "failure" and str(game.fail_kind) == "bridge_fall", "ch4 timeout before the crossing: the sedan falls on the bridge (branch 1, paper-sedan hint)")
 fresh4()
 cross4()
 game.set_spirit(false)
 game.advance_time(1000.0)
 check(str(game.phase) == "failure" and str(game.fail_kind) == "unfinished", "ch4 timeout after the crossing with the dialogue unfinished: branch 2 (S-8)")


# ================= chapter 5 smoke (DESIGN_CH5_DRAFT v0.1) =================


func path_avoiding(target: String, banned: String) -> Array:
 var queue: Array = [[str(game.current)]]
 var seen: Dictionary = {}
 while not queue.is_empty():
  var path: Array = queue.pop_front()
  var node: String = path.back()
  if node == target:
   return path
  if seen.has(node):
   continue
  seen[node] = true
  for other in game.graph[node]:
   if str(other) == banned and str(other) != target:
    continue
   var next: Array = path.duplicate()
   next.append(other)
   queue.append(next)
 return []

func move5(target: String) -> void:
 game.set_spirit(true)
 var path: Array = path_avoiding(target, str(game.opp5_pos))
 check(not path.is_empty(), "BFS route (avoiding it) to " + target)
 for index in range(1, path.size()):
  var ok = game.jump_to(str(path[index]))
  check(bool(ok), "legal jump " + str(path[index - 1]) + " -> " + str(path[index]))

func use5(target: String) -> void:
 move5(target)
 game.set_spirit(false)
 game.act()
 game.set_spirit(true)

func fresh5() -> void:
 if is_instance_valid(game):
  game.free()
 game = load("res://main.gd").new()
 root.add_child(game)
 game.start_chapter5()
 check(str(game.phase) == "tutorial" and str(game.current) == "everlamp", "ch5 opens on the ever-burning lamp")
 game.set_spirit(false)
 game.act()
 check(str(game.phase) == "explore", "ch5 tutorial wick opens exploration")
 game.start_incense()
 check(str(game.phase) == "playing" and str(game.current) == "everlamp", "ch5 first watch incense starts at the lamp")
 check(game.remaining == 180.0 and game.seg5 == 1, "ch5 segment 1 incense is 180 seconds (relay)")
 check(str(game.opp5_pos) == "candle" and bool(game.wait5), "ch5 opponent opens waiting at the altar candle (segment 1)")
 game.set_spirit(true)

func set_opp5(pos: String) -> void:
 game.opp5_pos = pos
 game.opp5_idx = game.opp5_seq.find(pos)
 game.opp5_timer = 45.0
 game.wait5 = false
 game.wait5_left = 0.0

func solve_seg1() -> void:
 use5("everlamp")
 check(bool(game.flags.get("lamp_seen", false)), "ch5 seg1: wick inspection first (the probe step is mandatory)")
 use5("oilpot")
 check(bool(game.flags.get("oil_ready", false)), "ch5 seg1: oil fetched to the altar by Xiaoying (dispatch)")
 use5("palanquin")
 check(game.trade5_used == 1 and bool(game.clean5.has("candle")), "ch5 trade 1: reporting for it buys the candle station clean")
 check(str(game.opp5_pos) == "" and game.yield5_left > 100.0, "ch5 trade 1: it withdraws to the small sedan, yield window open")
 use5("everlamp")
 check(bool(game.flags.get("update1", false)), "ch5 fate update 1: the lamp that was out for ten years burns steady")
 check(game.seg5 == 2 and game.remaining == 150.0, "ch5 segment 2 begins: 150 seconds, checkpoint taken")

func run_ch5() -> void:
 print("YEXUN ch5 smoke: trade system + three-incense relay + segment checkpoints")
 fresh5()
 var g5: Dictionary = game.graph
 check(bfs_seen(g5, "everlamp", "").size() == 12, "ch5 graph: all 12 nodes reachable across the three zones (S-1/S-2)")
 var symmetric5 = true
 for a in g5:
  for b in g5[a]:
   if a not in g5[b]:
    symmetric5 = false
 check(symmetric5, "ch5 graph: every edge is two-way (no conditional edges, S-2)")
 var s1_ok5 = true
 for banned in g5:
  var start5 = "everlamp" if banned != "everlamp" else "gengbang"
  if bfs_seen(g5, start5, banned).size() != 11:
   s1_ok5 = false
 check(s1_ok5, "ch5 graph: any single occupied node leaves the other 11 connected (S-1)")
 check(bfs_seen(graph_without_edge(g5, "everlamp", "palanquin"), "everlamp", "").size() == 12, "ch5 graph: one incense-smoke strand cut, the other still links hall and courtyard")
 check(bfs_seen(graph_without_edge(g5, "candle", "palanquin"), "everlamp", "").size() == 12, "ch5 graph: the other incense-smoke strand cut, still fully connected")
 check(bfs_seen(graph_without_edge(g5, "paperfig", "horse"), "everlamp", "").size() == 12, "ch5 graph: paper route cut, corridor route still links courtyard and back hall")
 check(bfs_seen(graph_without_edge(g5, "gengbang", "horse"), "everlamp", "").size() == 12, "ch5 graph: corridor route cut, paper route still links the back hall")
 check(not bool(game.jump_to("candle")), "occupied altar candle rejects possession with the fixed refusal")
 var seen5: Dictionary = {}
 for i in range(80):
  game.wait5 = false
  game.opp5_timer = 0.0
  game.set_spirit(false)
  game.advance_time(0.1)
  seen5[str(game.opp5_pos)] = true
 var never5 = true
 for p in seen5:
  if p not in ["paperfig", "candle", "gong", "drum"]:
   never5 = false
 check(never5 and not seen5.has("everlamp") and not seen5.has("palanquin") and not seen5.has("sedanrem"), "opponent never occupies the lamp / sedan / sedan remains (never-occupy list)")
 fresh5()
 check(game.wait5_left > 20.0, "first wait is the long teaching window (25s)")
 game.set_spirit(false)
 game.advance_time(26.0)
 check(not bool(game.wait5) and str(game.opp5_pos) == "candle", "wait lapses into ordinary occupation; the 45s station clock starts after")
 use5("drum")
 check(not bool(game.clean5.has("candle")), "scare in ch5 leaves NO clean mark (reporting, not driving, earns clean)")
 check(str(game.opp5_pos) != "candle", "opponent fled the candle after the scare")
 check(bool(game.teach5_scare), "first scare at the candle speaks the buy-don't-drive teaching line")
 fresh5()
 use5("gong")
 check(game.trade5_used == 0 and str(game.dialogue).contains("离它太远"), "ringer beyond adjacency during the wait: fixed too-far line, no trade")
 use5("oilpot")
 check(bool(game.flags.get("oil_ready", false)), "dispatch objects still work beside the waiting station (the oil run is not blocked)")
 game.opp5_move_to("paperfig")
 use5("horse")
 check(game.trade5_used == 0 and str(game.dialogue).contains("它只认响器"), "flavor object beside the waiting station: fixed ringers-only line, no trade")
 fresh5()
 solve_seg1()
 fresh5()
 use5("palanquin")
 check(game.trade5_used == 1 and game.yield5_left > 0.0, "setup: trade 1 opens the yield window")
 game.yield5_left = 0.05
 game.set_spirit(false)
 game.advance_time(0.1)
 check(not bool(game.clean5.has("candle")), "yield window burned unused: the clean mark is revoked, the station can be bought again (no dead end)")
 check(game.trade5_used == 0 and str(game.opp5_pos) != "", "burned trade is refunded (FIX-R1 F-01); it returns to the sequence")
 fresh5()
 solve_seg1()
 check(str(game.opp5_pos) == "paperfig" and bool(game.wait5), "segment 2 opens with it waiting in the paper figure")
 var adi_before: float = game.adi5_left
 game.set_spirit(false)
 game.advance_time(12.0)
 check(game.adi5_left < adi_before - 11.0, "segment 2: Adi's walk to the gate runs on story seconds")
 use5("gengbang")
 check(game.adi5_pause > 40.0, "watch-clapper dispatch: Ayong's roll call pauses Adi once (45s)")
 var adi_paused: float = game.adi5_left
 game.set_spirit(false)
 game.advance_time(2.0)
 check(absf(game.adi5_left - adi_paused) < 0.01, "Adi stays put while the roll-call pause lasts")
 use5("gong")
 check(bool(game.flags.get("update2", false)), "ch5 trade 2 at the paper figure: fate update 2, Adi stays")
 check(game.seg5 == 3 and game.remaining == 210.0 and game.trade5_used == 2, "segment 3 begins: 210 seconds, trade count carried over (2 used)")
 game.opp5_move_to("paperfig")
 check(bool(game.wait5), "segment 3: it waits in the paper figure one last time")
 use5("gong")
 check(bool(game.beat5_done) and game.trade5_used == 2, "the third trade is locked: the pledge is spoken, no count spent, no clean taken")
 check(not bool(game.flags.get("people_ready", false)), "finale stays locked before the people are gathered (S-4)")
 use5("porridge")
 check(bool(game.flags.get("porridge_done", false)) and not bool(game.flags.get("people_ready", false)), "porridge stall dispatch done; one dish is not yet a crowd")
 use5("cake")
 check(bool(game.flags.get("people_ready", false)), "cake dispatch completes the gathering: the people are all here")
 use5("everlamp")
 check(bool(game.flags.get("verse_done", false)), "with everyone present, Miaozhu speaks the whole sentence at last")
 use5("palanquin")
 check(bool(game.flags.get("rope_done", false)) and bool(game.flags.get("update3", false)), "Shuisheng walks in on his own and lays the cut rope before the sedan: fate update 3")
 use5("everlamp")
 check(str(game.phase) == "ending", "ch5 canonical ending: lamp, boy and team all held; the hook at the gate")
 fresh5()
 game.set_spirit(false)
 game.advance_time(1000.0)
 check(str(game.phase) == "failure" and str(game.fail_kind) == "lamp_out", "ch5 segment 1 timeout: the lamp dies (branch 1, Miaozhu hint)")
 game._process(5.1)
 check(str(game.phase) == "playing" and game.seg5 == 1 and game.trade5_used == 0, "failure retries only segment 1: checkpoint state restored")
 fresh5()
 solve_seg1()
 game.adi5_left = 1.0
 game.adi5_pause = 0.0
 game.set_spirit(false)
 game.advance_time(2.0)
 check(str(game.phase) == "failure" and str(game.fail_kind) == "adi_left", "ch5 segment 2: Adi walks out of the gate (branch 2, Ayong hint)")
 game._process(5.1)
 check(str(game.phase) == "playing" and game.seg5 == 2 and bool(game.flags.get("update1", false)) and game.trade5_used == 1, "segment 2 retry keeps segment 1's fate update and the segment-start trade count")
 fresh5()
 solve_seg1()
 use5("gong")
 use5("porridge")
 use5("cake")
 use5("everlamp")
 use5("palanquin")
 check(game.seg5 == 3 and bool(game.flags.get("rope_done", false)), "setup: reach segment 3 finale")
 game.set_spirit(false)
 game.advance_time(1000.0)
 check(str(game.phase) == "failure" and str(game.fail_kind) == "team_gone", "ch5 segment 3 timeout: the team drifts away (branch 3, paper-sedan hint)")
 game._process(5.1)
 check(str(game.phase) == "playing" and game.seg5 == 3 and bool(game.flags.get("update2", false)), "segment 3 retry keeps the first two fate updates (relay never rolls back)")
 fresh5()
 move5("gong")
 set_opp5("candle")
 game.opp5_timer = 0.0
 var rem5: float = game.remaining
 game.set_spirit(false)
 game.advance_time(0.1)
 check(str(game.opp5_pos) == "gong", "timer advance follows the written sequence candle -> gong")
 check(str(game.current) != "gong", "lingering player is squeezed back to the previous object")
 check(absf(game.remaining - (rem5 - 10.1)) < 0.6, "squeeze-out costs 10 incense seconds")


# ================= chapter 6 smoke (DESIGN_CH6_DRAFT v0.1) =================

func move6(target: String) -> void:
 game.set_spirit(true)
 var path: Array = path_to(target)
 check(not path.is_empty(), "ch6 BFS route to " + target)
 for index in range(1, path.size()):
  var ok = game.jump_to(str(path[index]))
  check(bool(ok), "ch6 legal jump " + str(path[index - 1]) + " -> " + str(path[index]))

func use6(target: String) -> void:
 move6(target)
 game.set_spirit(false)
 game.act()
 game.set_spirit(true)

func fresh6() -> void:
 if is_instance_valid(game):
  game.free()
 game = load("res://main.gd").new()
 root.add_child(game)
 game.start_chapter6()
 check(str(game.phase) == "tutorial" and str(game.current) == "everlamp", "ch6 opens on the ever-burning lamp")
 game.set_spirit(false)
 game.act()
 check(str(game.phase) == "explore", "ch6 tutorial: lamp filled and wick trimmed (lamp chain, final link)")
 game.start_incense()
 check(str(game.phase) == "playing" and game.seg6 == 1 and game.remaining == 360.0, "ch6 final incense: a single 360 seconds, segment 1 at the palace gate")
 check(game.acct6s_answer == 1 and game.acct6s_drive == 0, "ch6: with no stored account, the harmony preset applies (answer >= 1)")
 game.set_spirit(true)

func seg6_graph_checks() -> void:
 fresh6()
 var expect_size = [6, 7, 5, 5, 8, 6]
 var expect_fog = ["", "templebell", "gong", "lampstand", "", ""]
 for seg in range(1, 7):
  game.seg6_begin(seg, false)
  var g: Dictionary = game.graph
  var seen_all: Dictionary = bfs_seen(g, "palanquin", "")
  check(seen_all.size() == expect_size[seg - 1], "ch6 seg" + str(seg) + " graph: relay subgraph size " + str(expect_size[seg - 1]) + " (team + station items)")
  var symmetric6 = true
  for a in g:
   for b in g[a]:
    if a not in g[b]:
     symmetric6 = false
  check(symmetric6, "ch6 seg" + str(seg) + " graph: every edge two-way (no conditional edges, S-2)")
  check(g["sign"].is_empty(), "ch6 seg" + str(seg) + " graph: the fortune slip is a terminal node, never in the traversal graph")
  var sign_listed = false
  for a in g:
   if "sign" in g[a]:
    sign_listed = true
  check(not sign_listed, "ch6 seg" + str(seg) + " graph: no edge leads to the slip")
  check(str(game.fog6) == expect_fog[seg - 1], "ch6 seg" + str(seg) + ": fog-bound node matches the written table")
  var s1_ok6 = true
  for banned in seen_all:
   var start6 = "palanquin" if banned != "palanquin" else "drum"
   if bfs_seen(g, start6, banned).size() != seen_all.size() - 1:
    s1_ok6 = false
  check(s1_ok6, "ch6 seg" + str(seg) + " graph: any single fog-bound/removed node leaves the rest connected (S-1)")
  var bridge_ok6 = true
  for a in seen_all:
   for b in g[a]:
    if bfs_seen(graph_without_edge(g, a, b), a, "").size() != seen_all.size():
     bridge_ok6 = false
  check(bridge_ok6, "ch6 seg" + str(seg) + " graph: no bridge edges (every edge has an alternate route)")

func solve_to_seg3() -> void:
 use6("palanquin")
 use6("censer")
 use6("templebell")

func solve_to_seg5() -> void:
 solve_to_seg3()
 use6("lampstand")
 use6("drum")
 use6("gong")
 use6("palanquin")
 use6("lampstand")
 use6("palanquin")
 use6("drum")

func solve6() -> void:
 use6("palanquin")
 check(game.seg6 == 2 and bool(game.reported6.has("宫门")), "ch6 step 2: departure itself is the palace-gate report")
 check(str(game.fog6) == "templebell", "ch6 seg2: the temple bell is fog-bound on arrival")
 use6("censer")
 check(str(game.fog6) == "", "ch6 step 3: temple incense relit with an owner's fire, the fog unbinds")
 use6("templebell")
 check(game.seg6 == 3 and bool(game.reported6.has("土地庙")), "ch6 step 4: temple report, street segment begins")
 use6("lampstand")
 check(bool(game.flags.get("street_ready", false)), "ch6 step 5: lantern raised, Lianshen in place under the new signboard")
 use6("drum")
 check(str(game.fog6) == "", "ch6 step 6a: answer-first on the drum unbinds the road gong")
 use6("gong")
 check(game.seg6 == 4 and bool(game.reported6.has("溪尾街")), "ch6 step 6b: street report, bridge segment begins")
 check(game.trade6_left == 1, "ch6: station reports never consume the trade count (separate ledgers)")
 check(str(game.fog6) == "lampstand", "ch6 seg4: the lantern stand is fog-bound on arrival")
 use6("palanquin")
 check(str(game.fog6) == "", "ch6 step 7a: sedan-bell answer-first unbinds the lantern (source 1 of 2)")
 use6("lampstand")
 check(bool(game.flags.get("bridge_lit", false)), "ch6 step 7b: lantern raised, the bridge is lit")
 use6("palanquin")
 check(bool(game.flags.get("rollcall", false)), "ch6 step 8a: Ayong's roll call claims the ninth - the guide sedan")
 use6("drum")
 check(game.seg6 == 5 and bool(game.reported6.has("桥头")), "ch6 step 8b: bridge report, west alley segment begins")
 check(not bool(game.branch6), "ch6: the default harmony account does not trigger the dispersal branch")
 use6("flag")
 check(bool(game.flags.get("flag_open", false)), "ch6 step 9: banner unfurled at the alley mouth, team enters")
 use6("doorring")
 check(bool(game.flags.get("knock1", false)) and not bool(game.flags.get("knocked", false)), "ch6 step 10a: first knock is rusty, knocking not yet complete")
 use6("doorring")
 check(not bool(game.flags.get("knocked", false)), "ch6 step 10b: knocking again before the light arrives stays rusty (no punishment, no lock)")
 use6("lampstand")
 check(bool(game.flags.get("door_lit", false)), "ch6 step 10c: lantern light moved to the old house door")
 use6("doorring")
 check(bool(game.flags.get("knocked", false)), "ch6 step 10d: second knock runs clear - knocking complete")
 check(game.trade6_left == 1, "ch6: the third trade is still locked and pending before the alley report")
 use6("deepgong")
 check(bool(game.flags.get("trade_redeemed", false)) and game.trade6_left == 0, "ch6 step 11a: the first report ringer redeems the locked third trade (bound to the critical path)")
 use6("gong")
 use6("drum")
 check(bool(game.flags.get("update1", false)) and bool(game.reported6.has("西巷")), "ch6 step 11b: fate update 1 - the station owed for 63 years is reported")
 check(game.seg6 == 6, "ch6: the return segment begins after the alley report")
 use6("palanquin")
 check(bool(game.flags.get("pages_done", false)) and bool(game.reported6.has("祠堂前")), "ch6 step 12: confession heard, the torn roster page rewritten (performance station)")
 game.set_spirit(true)
 var ok_sign = game.jump_to("sign")
 check(bool(ok_sign) and str(game.phase) == "ending", "ch6 step 13: the last possession - onto the slip in Adi's arms; Acheng disperses at dawn")
 check(bool(game.flags.get("update2", false)), "ch6 step 13b: fate update 2 - the one who had to go, goes willingly")
 check(bool(game.all_clear), "ch6: the full-volume clear mark is set for the title screen")

func run_ch6() -> void:
 print("YEXUN ch6 smoke: clear-the-way + report + relay graph + behaviour ledger + finale")
 seg6_graph_checks()
 fresh6()
 check(not bool(game.jump_to("sign")), "ch6: the slip refuses possession long before its preconditions")
 check(str(game.dialogue).contains("攥得很紧"), "ch6: early slip attempt gives the fixed atmosphere line, no punishment")
 solve6()
 fresh6()
 use6("palanquin")
 check(not bool(game.jump_to("templebell")), "ch6: the fog-bound bell refuses possession")
 check(str(game.dialogue).contains("响不透"), "ch6: bound-bell refusal is the station's fixed muffled line")
 fresh6()
 solve_to_seg3()
 use6("palanquin")
 check(str(game.dialogue).contains("赶不走的") and bool(game.scare_tried6), "ch6: full-volume ringing at the fog-bound gong does nothing - the one-time rule line is spoken")
 check(str(game.fog6) == "gong", "ch6: the scare attempt leaves the fog exactly as it was (no scare judgement in ch6)")
 use6("drum")
 check(str(game.fog6) == "", "ch6 alt: unbinding before the lantern dispatch is allowed (order swap, street)")
 use6("lampstand")
 use6("gong")
 check(game.seg6 == 4 and bool(game.reported6.has("溪尾街")), "ch6 alt: street report still lands after the swapped order")
 use6("drum")
 check(str(game.fog6) == "", "ch6 alt: drum answer-first unbinds the lantern (source 2 of 2)")
 use6("drum")
 check(str(game.dialogue).contains("传不到桥心") and not bool(game.reported6.has("桥头")), "ch6: premature bridge report gives the fixed line and does not advance")
 fresh6()
 solve_to_seg5()
 game.seg6_begin(5, false)
 use6("gong")
 check(game.trio6.is_empty() and str(game.dialogue).contains("报到未齐"), "ch6: report trio before its preconditions gives muffled feedback only")
 fresh6()
 solve_to_seg5()
 use6("flag")
 use6("doorring")
 use6("lampstand")
 use6("doorring")
 use6("drum")
 check(bool(game.flags.get("trade_redeemed", false)), "ch6 alt: trio in drum-first order still redeems the third trade on the first ringer")
 use6("deepgong")
 use6("gong")
 check(bool(game.flags.get("update1", false)) and game.seg6 == 6, "ch6 alt: trio order is free - alley report lands in any order")
 fresh6()
 game.acct6s_drive = 3
 game.acct6s_answer = 0
 game.seg6_begin(5, false)
 check(bool(game.branch6), "ch6 branch: drive>0 and answer=0 triggers the dispersal branch at the alley mouth")
 use6("flag")
 check(str(game.dialogue).contains("响器不是赶人的") and not bool(game.flags.get("flag_open", false)), "ch6 branch: the dispersal performance plays first (full-volume scare fails, Miaozhu's line)")
 use6("flag")
 check(bool(game.flags.get("flag_open", false)), "ch6 branch: after the performance, the main line resumes unchanged")
 game.reported6["土地庙"] = true
 game.reported6["溪尾街"] = true
 game.reported6["桥头"] = true
 game.flags["flag_open"] = true
 game.flags["knocked"] = true
 use6("drum")
 use6("gong")
 use6("deepgong")
 check(bool(game.flags.get("update1", false)) and str(game.dialogue).contains("没有回头"), "ch6 branch consequence 1: no turning back, no nod - it leaves by the back view")
 fresh6()
 game.acct6s_drive = 0
 game.acct6s_answer = 0
 game.seg6_begin(5, false)
 check(not bool(game.branch6), "ch6 branch: a zero ledger (no drives, no answers) stays on the canon path")
 fresh6()
 game.acct6s_drive = 5
 game.acct6s_answer = 2
 game.seg6_begin(5, false)
 check(not bool(game.branch6), "ch6 branch: any recorded answer keeps the canon path")
 fresh6()
 solve_to_seg3()
 var snap_rem6: float = float(game.seg6_snap.get("remaining", -1.0))
 game.set_spirit(false)
 game.advance_time(1000.0)
 check(str(game.phase) == "failure" and str(game.speaker) == "莲婶", "ch6 rollback: street segment timeout is voiced by Lianshen's waiting (per-segment source, S-8)")
 game._process(5.1)
 check(str(game.phase) == "playing" and game.seg6 == 3 and absf(game.remaining - snap_rem6) < 0.01, "ch6 rollback: only the current segment restarts, incense restored to segment start")
 check(bool(game.reported6.has("土地庙")) and not bool(game.reported6.has("溪尾街")) and str(game.fog6) == "gong", "ch6 rollback: finished reports stand, the current segment's fog is restored")
 fresh6()
 game.set_spirit(false)
 game.advance_time(1000.0)
 check(str(game.phase) == "failure" and str(game.speaker) == "庙祝公", "ch6 rollback: palace-gate timeout is voiced by Miaozhu (per-segment source, S-8)")
 game._process(5.1)
 check(str(game.phase) == "playing" and game.seg6 == 1 and game.remaining == 360.0, "ch6 rollback: segment 1 restarts at the full 360 seconds")


# ================= FIX R1 regression suite (CODEX_AUDIT_R1) =================

func run_fix_r1() -> void:
 print("YEXUN FIX-R1 smoke: audit regression assertions + audio wiring")
 # ---- B: all 40 new audio streams load; system replacements use the real files ----
 fresh()
 var kinds = ["gong", "answer_bell", "answer_gong", "answer_drum", "report_full", "report_half", "amb2_realm", "amb2_spirit", "amb3_realm", "amb3_spirit", "amb3_store", "amb4_realm", "amb4_spirit", "amb5_realm", "amb5_spirit", "amb6_alley", "amb6_dawn", "bang", "boat", "borrowmouth", "bridgebell", "bridgerope", "deepgong", "doorring_clear", "doorring_rust", "everlamp", "kueh", "oilpot", "papercargo", "porridge", "riverlamp", "sedanrope", "shrine", "sign", "sugong", "suona", "templebell", "trade", "waitstill", "yieldcue"]
 var missing = ""
 for k in kinds:
  if game.get_stream(k) == null: missing += k + " "
 check(missing == "", "FIX-R1 audio: all 40 new streams load" + ((" (missing: " + missing + ")") if missing != "" else ""))
 game.play_gong()
 var gong_ok = false
 for p in game.fx_players:
  if p.stream != null and p.stream.resource_path.ends_with("gong.wav") and p.pitch_scale == 1.0: gong_ok = true
 check(gong_ok, "FIX-R1 audio: play_gong uses the real gong stream at pitch 1.0")
 game.play_answer("bell")
 var ans_ok = false
 for p in game.fx_players:
  if p.stream != null and p.stream.resource_path.ends_with("answer_bell.wav") and p.pitch_scale == 1.0: ans_ok = true
 check(ans_ok, "FIX-R1 audio: play_answer(bell) uses answer_bell at pitch 1.0")
 game.play_report6()
 var rep_ok = false
 for p in game.fx_players:
  if p.stream != null and p.stream.resource_path.ends_with("report_full.wav"): rep_ok = true
 check(rep_ok, "FIX-R1 audio: play_report6 uses the single report_full stream")
 # ---- F-03: tea-table scare before the roster read leaves no clean; the lie stays reachable ----
 fresh3()
 game.opp3_pos = "teatable"
 game.opp3_idx = game.opp3_seq.find("teatable")
 hop3("bell")
 game.set_spirit(false)
 game.act()
 game.set_spirit(true)
 check(not game.clean3.has("teatable"), "FIX-R1 F-03: scaring the tea table before reading the roster leaves NO clean mark")
 check(not bool(game.flags.get("lie_heard", false)), "FIX-R1 F-03: the lie is not heard before the roster is read")
 use3("teatable")
 use3("roster")
 check(bool(game.flags.get("roster_tonight", false)), "FIX-R1 F-03 setup: roster read after the dispatch")
 game.opp3_pos = "teatable"
 game.opp3_idx = game.opp3_seq.find("teatable")
 hop3("bell")
 game.set_spirit(false)
 game.act()
 game.set_spirit(true)
 check(bool(game.clean3.has("teatable")) and bool(game.flags.get("lie_heard", false)), "FIX-R1 F-03: after the roster, the same scare lands the clean mark and the lie")
 fresh3()
 game.flags["remains_seen"] = true
 game.flags["account_found"] = true
 game.flags["memory_seen"] = true
 game.flags["roster_tonight"] = true
 game.flags["torn_seen"] = true
 move("flag")
 game.set_spirit(false)
 game.act()
 game.set_spirit(true)
 check(not bool(game.flags.get("flag_raised", false)), "FIX-R1 F-03: the flag cannot rise while the lie is still unheard")
 game.flags["lie_heard"] = true
 game.set_spirit(false)
 game.act()
 game.set_spirit(true)
 check(bool(game.flags.get("flag_raised", false)), "FIX-R1 F-03: with all six preconditions the flag rises")
 # ---- F-02: an early scare off the paper figure leaves no clean; borrow-mouth still completes ----
 fresh4()
 use("gong")
 check(not game.clean4.has("paperfig"), "FIX-R1 F-02: scaring it off the paper figure in normal occupation leaves NO clean mark")
 check(str(game.opp4_pos) != "paperfig", "FIX-R1 F-02: it still flees the paper figure when scared")
 set_opp4("paperfig")
 cross4()
 check(bool(game.bm_active), "FIX-R1 F-02: borrow-mouth still begins after the early paper-figure scare")
 game.set_spirit(false)
 game.advance_time(10.0)
 check(bool(game.bm_window_open), "FIX-R1 F-02: the first answer window still opens")
 use("gong")
 check(game.bm_round == 1, "FIX-R1 F-02: answer round 1 still completes after the early scare")
 # ---- F-04: round 3 is gated on the memory; attaching to the lampstand grants it ----
 fresh4()
 cross4()
 game.set_spirit(false)
 game.advance_time(10.0)
 use("gong")
 check(game.bm_round == 1, "FIX-R1 F-04 setup: round 1 answered")
 game.set_spirit(false)
 game.act()
 game.set_spirit(true)
 game.set_spirit(false)
 game.act()
 game.set_spirit(true)
 var guard4x = 0
 while str(game.opp4_pos) != "paperfig" and guard4x < 8:
  game.opp4_timer = 0.0
  game.set_spirit(false)
  game.advance_time(0.1)
  guard4x += 1
 game.set_spirit(false)
 game.advance_time(3.5)
 use("palanquin")
 check(game.bm_round == 2, "FIX-R1 F-04 setup: round 2 answered")
 set_opp4("drum")
 use("papercargo")
 check(bool(game.flags.get("newsedan_done", false)), "FIX-R1 F-04 setup: the new sedan is made")
 game.opp4_move_to("paperfig")
 check(not bool(game.bm_active), "FIX-R1 F-04: round 3 borrow-mouth does NOT begin before the memory is recovered")
 move("lampstand")
 check(bool(game.flags.get("memory_seen", false)), "FIX-R1 F-04: merely attaching to the lampstand after the crossing restores the memory (attach-to-get)")
 game.opp4_move_to("paperfig")
 check(bool(game.bm_active), "FIX-R1 F-04: with the memory held, round 3 borrow-mouth begins")
 game.set_spirit(false)
 game.advance_time(3.5)
 check(bool(game.bm_window_open), "FIX-R1 F-04: the final answer window opens")
 move("riverlamp")
 use("gong")
 check(str(game.phase) == "ending", "FIX-R1 F-04: the round 3 answer completes the chapter")
 # ---- F-01: a burned segment-1 trade refunds; segment 2's only entry stays open ----
 fresh5()
 use5("everlamp")
 use5("oilpot")
 use5("palanquin")
 check(game.trade5_used == 1 and game.yield5_left > 0.0, "FIX-R1 F-01 setup: segment 1 trade opens the yield window")
 game.yield5_left = 0.05
 game.set_spirit(false)
 game.advance_time(0.1)
 check(game.trade5_used == 0, "FIX-R1 F-01: a burned trade is refunded (the count returns to 0)")
 check(not bool(game.clean5.has("candle")), "FIX-R1 F-01: the burned station's clean mark is revoked with the refund")
 game.opp5_move_to("candle")
 use5("palanquin")
 check(game.trade5_used == 1 and game.yield5_left > 0.0, "FIX-R1 F-01: the candle station can be bought again after the burn")
 use5("everlamp")
 check(game.seg5 == 2 and game.trade5_used == 1, "FIX-R1 F-01: the segment 2 snapshot carries count 1 (not the dead-end 2)")
 use5("gong")
 check(bool(game.flags.get("update2", false)) and game.trade5_used == 2, "FIX-R1 F-01: segment 2's only entry (the paper-figure trade) still opens after a segment-1 burn")
 # ---- F-05: segment 3 cannot close before the pledge beat ----
 fresh5()
 solve_seg1()
 use5("gong")
 use5("porridge")
 use5("cake")
 use5("everlamp")
 use5("palanquin")
 check(game.seg5 == 3 and bool(game.flags.get("rope_done", false)) and not bool(game.beat5_done), "FIX-R1 F-05 setup: the rope is laid, the pledge not yet spoken")
 use5("everlamp")
 check(str(game.phase) == "playing", "FIX-R1 F-05: without the pledge beat, the lamp does not close the chapter")
 game.opp5_move_to("paperfig")
 use5("gong")
 check(bool(game.beat5_done), "FIX-R1 F-05: the pledge beat lands at the waiting paper figure")
 use5("everlamp")
 check(str(game.phase) == "ending", "FIX-R1 F-05: after the pledge, the lamp closes the chapter")
 # ---- F-06: save/continue round trips keep the audited fields ----
 fresh2()
 game.window_left = 17.5
 game.sedan_stay = 4.25
 game.sedan_attempts = 2
 game.save_game()
 game.window_left = 0.0
 game.sedan_stay = 0.0
 game.sedan_attempts = 0
 game.continue_game2()
 check(absf(game.window_left - 17.5) < 0.01 and absf(game.sedan_stay - 4.25) < 0.01 and game.sedan_attempts == 2, "FIX-R1 F-06: ch2 flag window / small-sedan stay / attempts survive a save-continue round trip")
 fresh3()
 game.window3_left = 9.5
 game.squeezed3["bell"] = true
 game.save_game()
 game.window3_left = 0.0
 game.squeezed3 = {}
 game.continue_game3()
 check(absf(game.window3_left - 9.5) < 0.01 and bool(game.squeezed3.has("bell")), "FIX-R1 F-06: ch3 dispatch window and squeezed set survive a round trip")
 fresh4()
 game.squeezed4["gong"] = true
 game.bm_active = true
 game.bm_window_open = true
 game.bm_window = 13.0
 game.save_game()
 game.squeezed4 = {}
 game.bm_active = false
 game.bm_window_open = false
 game.bm_window = 0.0
 game.continue_game4()
 check(bool(game.squeezed4.has("gong")) and bool(game.bm_active) and bool(game.bm_window_open) and absf(game.bm_window - 13.0) < 0.01, "FIX-R1 F-06: ch4 squeezed set and the open borrow-mouth window survive a round trip")
 fresh5()
 game.adi5_pause = 33.0
 game.squeezed5["gong"] = true
 game.save_game()
 game.adi5_pause = 0.0
 game.squeezed5 = {}
 game.continue_game5()
 check(absf(game.adi5_pause - 33.0) < 0.01 and bool(game.squeezed5.has("gong")), "FIX-R1 F-06: ch5 Adi pause and squeezed set survive a round trip")
 # ---- F-09 + F-10: last-possession source law; the clear variant persists into the epilogue ----
 fresh6()
 solve_to_seg5()
 use6("flag")
 use6("doorring")
 use6("lampstand")
 use6("doorring")
 use6("deepgong")
 use6("gong")
 use6("drum")
 check(game.seg6 == 6 and bool(game.flags.get("update1", false)), "FIX-R1 F-09 setup: the alley is reported, the return segment begins")
 use6("palanquin")
 check(bool(game.flags.get("pages_done", false)), "FIX-R1 F-09 setup: the torn page is rewritten at the hall")
 move6("drum")
 check(not bool(game.jump_to("sign")), "FIX-R1 F-09: the last possession refuses any source but the sedan or the lamp")
 check(str(game.dialogue).contains("最后一附只能自神轿"), "FIX-R1 F-09: the refusal names the two lawful sources")
 move6("palanquin")
 var ok9 = game.jump_to("sign")
 check(bool(ok9) and str(game.phase) == "ending" and str(game.current) == "sign", "FIX-R1 F-09: from the sedan, the last possession lands on the slip")
 check(str(game.clear_variant) == "canon", "FIX-R1 F-10: a canon clear records the canon variant")
 game.enter_epilogue()
 check(str(game.phase) == "epilogue" and not bool(game.branch6), "FIX-R1 F-10: epilogue rewatch opens the canon frame for a canon clear")
 fresh6()
 game.branch6 = true
 game.last_attach6()
 check(str(game.clear_variant) == "branch", "FIX-R1 F-10: a dispersal clear records the branch variant")
 game.enter_epilogue()
 check(str(game.phase) == "epilogue" and bool(game.branch6), "FIX-R1 F-10: epilogue rewatch opens the dispersal frame for a branch clear")
 # ---- A-02: the puddle reflection exists only after the alley report, in both domains ----
 fresh6()
 game.seg6_begin(5, false)
 game.sync_art()
 check(not bool(game.sedan_refl_sprite.visible), "FIX-R1 A-02: no reflection before the alley is reported (S-10: only this one place)")
 game.flags["update1"] = true
 game.sync_art()
 check(bool(game.sedan_refl_sprite.visible), "FIX-R1 A-02: after the report, the paper sedan's reflection shows in the puddle (spirit domain)")
 game.set_spirit(false)
 game.sync_art()
 check(bool(game.sedan_refl_sprite.visible), "FIX-R1 A-02: the reflection also shows in the realm domain (dual-domain exception)")
