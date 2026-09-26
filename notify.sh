#!/bin/bash
# Clover: „Kto na teba čaká". Claude Code hook (Notification / Stop / UserPromptSubmit).
# Zapíše stav panela do ~/.config/clover/state/wait/<pane id>; clover.lua ho každú sekundu
# prečíta, pošle notifikáciu a ukáže lištu. Mimo Cloveru nerobí nič.
# Použitie: notify.sh wait|done|clear   (JSON z Clauda na stdin)
state="$1"
[ -z "${WEZTERM_PANE:-}" ] && exit 0
[[ "$WEZTERM_PANE" =~ ^[0-9]+$ ]] || exit 0
input="$(cat)"

# len Claude priamo v paneli, nie vnorený (rovnaká poistka ako v remember.sh)
if [ -n "${CLOVER_PANE_PID:-}" ] && command -v ps >/dev/null 2>&1; then
  p=$PPID
  for _ in 1 2 3 4 5; do
    case "$(ps -o comm= -p "$p" 2>/dev/null)" in *claude*) break ;; esac
    p=$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' '); [ -z "$p" ] && exit 0
  done
  [ "$(ps -o ppid= -p "$p" 2>/dev/null | tr -d ' ')" = "$CLOVER_PANE_PID" ] || exit 0
fi

dir="$HOME/.config/clover/state/wait"
f="$dir/$WEZTERM_PANE"
case "$state" in
  clear) rm -f "$f" ;;
  wait|done)
    # „čakám na vstup" po minúte nečinnosti = pripomienka po „hotovo", nie nová udalosť
    [ "$state" = wait ] && printf '%s' "$input" | grep -q 'waiting for your input' && exit 0
    mkdir -p "$dir"
    printf '%s %s\n' "$state" "$(date +%s)" > "$f"
    ;;
esac
exit 0
