#!/bin/bash
# Clover: spustí Clauda v paneli. Ak má panel (slot) uloženú session z minula, obnoví ju —
# ale len ak naozaj existuje (má správy) a nebeží práve v inom okne.
# Použitie: start.sh <slot> [parametre pre claude]
main() {
  slot="$1"; shift
  export CLOVER_PANE_PID=$$   # remember.sh podľa toho spozná Clauda priamo v paneli (nie vnoreného)
  f="$HOME/.config/clover/state/slot-$slot"

  # úplne prvý štart: uvítanie v paneli 1 (clover.lua vtedy otvorí len jeden panel)
  if [ "$slot" = 1 ] && [ ! -e "$HOME/.config/clover/state/welcomed" ]; then
    bash "$HOME/.config/clover/vitaj.sh"
  fi

  live() { # beží session $1 v nejakom živom procese?
    local j
    for j in "$HOME"/.claude/sessions/*.json; do
      [ -e "$j" ] || continue
      grep -q "\"sessionId\":\"$1\"" "$j" 2>/dev/null && kill -0 "$(basename "$j" .json)" 2>/dev/null && return 0
    done
    return 1
  }

  if [ -n "$slot" ] && [ -s "$f" ] && [ "${CLOVER_RESTORE:-1}" = 1 ]; then
    read -r id dir < "$f"
    if [[ "$id" =~ ^[0-9a-f-]{36}$ ]] && ls "$HOME"/.claude/projects/*/"$id".jsonl >/dev/null 2>&1 && ! live "$id"; then
      cd "$dir" 2>/dev/null
      claude --resume "$id" "$@"
      rm -f "$f"
      exit
    fi
  fi
  claude "$@"
  [ -n "$slot" ] && rm -f "$f"   # /exit → panel nabudúce začne načisto
}
main "$@"; exit
