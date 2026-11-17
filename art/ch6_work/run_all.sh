#!/usr/bin/env bash
set -u
cd ~/workspace/yexun
POOL=~/workspace/codex-pet/codex-pool.sh
P=art/ch6_work/prompts
LOG=art/ch6_work/run.log
: > "$LOG"
run() {
  local name="$1" prompt="$2"; shift 2
  echo "=== $name $(date '+%T') ===" >> "$LOG"
  "$POOL" "$@" < "$prompt" >> "$LOG" 2>&1
  echo "--- rc=$? $name $(date '+%T') ---" >> "$LOG"
}
run p01_alley_realm   $P/p01_alley_realm.txt   -i concept/concept_10_westalley_ch6_SP.png
run p02_alley_spirit  $P/p02_alley_spirit.txt  -i art/bg_alley_realm.png
run p03_alley_dawn    $P/p03_alley_dawn.txt    -i art/bg_alley_realm.png
run p04_nextyear      $P/p04_palace_nextyear.txt -i concept/concept_15_ending_epilogue_SP.png -i art/bg_realm.png
run p05_temple_bell   $P/p05_temple_bell.txt   -i art/obj_bell.png -i art/obj_bridge_bell.png -i concept/concept_06_street_ch2_SP.png
run p06_doorring      $P/p06_doorring_rust.txt -i concept/concept_10_westalley_ch6_SP.png
run p07_doorring_clr  $P/p07_doorring_clear.txt -i art/obj_doorring.png
run p08_deepgong      $P/p08_deepgong.txt      -i art/obj_gong.png -i concept/concept_10_westalley_ch6_SP.png
run p09_lotstick      $P/p09_lotstick.txt      -i art/obj_sign.png
run p10_zhizao        $P/p10_zhizao_full.txt   -i concept/concept_12_characters_zhizao_dual_SP.png -i concept/concept_05_characters_SP.png
echo "ALL DONE $(date '+%T')" >> "$LOG"
