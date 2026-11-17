P = "/home/hatch/workspace/yexun/game/main.gd"
src = open(P, encoding="utf-8").read()
old = '''func trade_pre5() -> bool:
 if yield5_left > 0.0 or opp5_pos == "": return false'''
new = '''func trade_pre5() -> bool:
 if seg5 == 3 and flags.get("verse_done", false) and not flags.get("rope_done", false) and current == "palanquin": return false
 if yield5_left > 0.0 or opp5_pos == "": return false'''
assert src.count(old) == 1, src.count(old)
src = src.replace(old, new, 1)
open(P, "w", encoding="utf-8").write(src)
print("fix3 OK")
