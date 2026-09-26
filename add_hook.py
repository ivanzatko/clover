# Pridá Clover hooky do ~/.claude/settings.json (idempotentne, zvyšok nechá tak):
#   SessionStart     → remember.sh (obnova sessions po reštarte)
#   Notification     → notify.sh wait   (Claude čaká na povolenie / odpoveď)
#   Stop             → notify.sh done   (Claude dokončil)
#   UserPromptSubmit → notify.sh clear  (odpísal si, panel už nečaká)
import json, os, shutil, sys, time
p = os.path.expanduser('~/.claude/settings.json')
HOOKS = {
    'SessionStart': 'bash "$HOME/.config/clover/remember.sh"',
    'Notification': 'bash "$HOME/.config/clover/notify.sh" wait',
    'Stop': 'bash "$HOME/.config/clover/notify.sh" done',
    'UserPromptSubmit': 'bash "$HOME/.config/clover/notify.sh" clear',
}
d = {}
if os.path.exists(p):
    try: d = json.load(open(p, encoding='utf-8'))
    except Exception: sys.exit('settings.json sa nedá prečítať — hooky preskakujem')
hooks = d.setdefault('hooks', {})
def has(ev, cmd):
    return any(h.get('command') == cmd for e in hooks.get(ev, []) for h in e.get('hooks', []))
added = [ev for ev, cmd in HOOKS.items() if not has(ev, cmd)]
if not added: sys.exit(0)
if os.path.exists(p): shutil.copy(p, p + '.bak-' + time.strftime('%Y%m%d-%H%M%S'))
for ev in added:
    hooks.setdefault(ev, []).append({'hooks': [{'type': 'command', 'command': HOOKS[ev]}]})
os.makedirs(os.path.dirname(p), exist_ok=True)
json.dump(d, open(p, 'w', encoding='utf-8'), indent=2, ensure_ascii=False)
print('hooky pridané: ' + ', '.join(added))
