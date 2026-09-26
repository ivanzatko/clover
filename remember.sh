#!/bin/bash
# Clover: SessionStart hook — zapamätá si, ktorá Claude session beží v ktorom paneli,
# aby ju Clover pri ďalšom štarte obnovil. Mimo Cloveru nerobí nič.
[ -z "${CLOVER_SLOT:-}" ] && exit 0
# Len Claude priamo v paneli (rodič = start.sh). Vnorený claude (napr. `claude -p` z Claudovho
# príkazu) zdedí CLOVER_SLOT, ale pamäť panela prepísať nesmie.
if [ -n "${CLOVER_PANE_PID:-}" ] && command -v ps >/dev/null 2>&1; then
  p=$PPID
  for _ in 1 2 3 4 5; do
    case "$(ps -o comm= -p "$p" 2>/dev/null)" in *claude*) break ;; esac
    p=$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' '); [ -z "$p" ] && exit 0
  done
  [ "$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ')" = "$CLOVER_PANE_PID" ] || exit 0
fi
input="$(cat)"
id="$(printf '%s' "$input" | sed -n 's/.*"session_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
dir="$(printf '%s' "$input" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -1)"
[ -z "$id" ] && exit 0
mkdir -p "$HOME/.config/clover/state"
# rovnaká session nesmie ostať zapísaná v inom paneli
for o in "$HOME"/.config/clover/state/slot-*; do
  [ -e "$o" ] && [ "$o" != "$HOME/.config/clover/state/slot-$CLOVER_SLOT" ] && grep -q "^$id " "$o" && rm -f "$o"
done
printf '%s %s\n' "$id" "$dir" > "$HOME/.config/clover/state/slot-$CLOVER_SLOT"
exit 0
