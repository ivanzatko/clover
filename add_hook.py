# Pridá Clover hooky do ~/.claude/settings.json (idempotentne, zvyšok nechá tak):
#   SessionStart     → remember.sh (obnova sessions po reštarte)
#   Notification     → notify.sh wait   (Claude čaká na povolenie / odpoveď)
#   Stop             → notify.sh done   (Claude dokončil)
#   UserPromptSubmit → notify.sh clear  (odpísal si, panel už nečaká)
import json, os, shutil, sys, time
p = os.path.expanduser('~/.claude/settings.json')
def cmd(script, arg=''):
    # keď súbor chýba (napr. rozbitá inštalácia), hook potichu skončí namiesto chyby v každej odpovedi
    run = f'bash "$f"{" " + arg if arg else ""}'
    return f'f="$HOME/.config/clover/{script}"; [ -f "$f" ] && {run}; exit 0'
HOOKS = {
    'SessionStart': cmd('remember.sh'),
    'Notification': cmd('notify.sh', 'wait'),
    'Stop': cmd('notify.sh', 'done'),
    'UserPromptSubmit': cmd('notify.sh', 'clear'),
}
d = {}
if os.path.exists(p):
    try: d = json.load(open(p, encoding='utf-8'))
    except Exception: sys.exit('settings.json sa nedá prečítať — hooky preskakujem')
hooks = d.setdefault('hooks', {})
def clover(e): return '.config/clover/' in json.dumps(e)
def current(ev): return [h.get('command') for e in hooks.get(ev, []) if clover(e) for h in e.get('hooks', [])]
added = [ev for ev, c in HOOKS.items() if current(ev) != [c]]
if not added: sys.exit(0)
if os.path.exists(p): shutil.copy(p, p + '.bak-' + time.strftime('%Y%m%d-%H%M%S'))
for ev in added:
    # staré alebo zdvojené Clover hooky preč, zvyšok (tvoje hooky) nechaj
    hooks[ev] = [e for e in hooks.get(ev, []) if not clover(e)]
    hooks.setdefault(ev, []).append({'hooks': [{'type': 'command', 'command': HOOKS[ev]}]})
os.makedirs(os.path.dirname(p), exist_ok=True)
json.dump(d, open(p, 'w', encoding='utf-8'), indent=2, ensure_ascii=False)
print('hooky nastavené: ' + ', '.join(added))
