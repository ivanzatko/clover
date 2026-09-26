#!/bin/bash
# Clover: SessionStart hook — zapamätá si, ktorá Claude session beží v ktorom paneli,
# aby ju Clover pri ďalšom štarte obnovil. Mimo Cloveru nerobí nič.
[ -z "${CLOVER_SLOT:-}" ] && exit 0
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
