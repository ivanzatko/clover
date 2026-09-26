#!/bin/bash
# Clover — odinštalovanie (Mac). Claude Code, Homebrew, git a tvoje konverzácie nechá tak.
# Použitie: curl -fsSL https://raw.githubusercontent.com/ivanzatko/clover/main/uninstall-mac.sh | bash
G=$'\033[32m'; D=$'\033[2m'; R=$'\033[0m'
if pgrep -f "/Applications/Clover.app/Contents/MacOS" >/dev/null 2>&1; then
  echo "Clover práve beží. Zavri ho (Cmd+Q) a spusti príkaz znova."; exit 1
fi
rm -rf /Applications/Clover.app "$HOME/.config/clover" "$HOME/.claude/skills/vitaj"
[ -f "$HOME/.clover.lua" ] && mv "$HOME/.clover.lua" "$HOME/.clover.lua.bak-$(date +%Y%m%d-%H%M%S)"
rm -f "$HOME/.claude-terminal.lua"
# Clover hooky z ~/.claude/settings.json (zvyšok nastavení ostane)
/usr/bin/python3 - <<'PY'
import json, os
p = os.path.expanduser('~/.claude/settings.json')
try: d = json.load(open(p, encoding='utf-8'))
except Exception: raise SystemExit
hooks = d.get('hooks', {})
changed = False
for ev in list(hooks):
    keep = [h for h in hooks[ev] if '.config/clover/' not in json.dumps(h)]
    if keep != hooks[ev]:
        changed = True
        if keep: hooks[ev] = keep
        else: del hooks[ev]
if changed:
    if not hooks: d.pop('hooks', None)
    json.dump(d, open(p, 'w', encoding='utf-8'), indent=2, ensure_ascii=False)
PY
echo "${G}🍀 Clover je preč.${R} Claude Code a tvoje konverzácie ostali."
echo "${D}Tvoje osobné nastavenia som odložil do ~/.clover.lua.bak-… (ak si nejaké mal).${R}"
