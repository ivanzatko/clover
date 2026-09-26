# Pridá Clover SessionStart hook do ~/.claude/settings.json (idempotentne, zvyšok nechá tak)
import json, os, shutil, sys, time
p = os.path.expanduser('~/.claude/settings.json')
cmd = 'bash "$HOME/.config/clover/remember.sh"'
d = {}
if os.path.exists(p):
    try: d = json.load(open(p, encoding='utf-8'))
    except Exception: sys.exit('settings.json sa nedá prečítať — hook preskakujem')
    if 'clover/remember.sh' in json.dumps(d): sys.exit(0)
    shutil.copy(p, p + '.bak-' + time.strftime('%Y%m%d-%H%M%S'))
d.setdefault('hooks', {}).setdefault('SessionStart', []).append({'hooks': [{'type': 'command', 'command': cmd}]})
os.makedirs(os.path.dirname(p), exist_ok=True)
json.dump(d, open(p, 'w', encoding='utf-8'), indent=2, ensure_ascii=False)
print('hook pridaný')
