# Clover 🍀

Terminál, ktorý sa otvorí rovno so 4 panelmi Claude Code (2×2), bez medzikrokov.
Mac aj Windows. Postavené na [WezTerm](https://github.com/wezterm/wezterm) (MIT licencia, © Wez Furlong).
Aktualizácia = spustiť inštalačný príkaz znova.

## Inštalácia (jeden príkaz)

**Mac** (Terminal):
```
curl -fsSL https://raw.githubusercontent.com/ivanzatko/clover/main/install-mac.sh | bash
```

**Windows** (PowerShell):
```
irm https://raw.githubusercontent.com/ivanzatko/clover/main/install-win.ps1 | iex
```

Nainštaluje: appku Clover, git, Claude Code, konfig. Na Macu aj Homebrew.
Počas inštalácie po slovensky vysvetľuje, čo robí a prečo.
Existujúce súbory neprepisuje (`~/.claude/CLAUDE.md`, `settings.json`), `settings.json` pred úpravou zálohuje.

## Prvé spustenie

1. Clover sa prvýkrát otvorí s **jedným** panelom a uvítaním (`vitaj.sh`), ktoré vysvetlí, čo sa bude diať.
   Jeden panel preto, aby sa prihlásenie do Clauda neotvorilo štyrikrát naraz.
2. Claude sa raz spýta na farby a prihlásenie (treba predplatné Pro alebo Max).
3. Napíš **`/vitaj`**: sprievodca (skill v `~/.claude/skills/vitaj`) ťa za pár minút prevedie
   tým podstatným. Zapíše si, kto si, vyskúšaš si kopírovanie, súbory myšou a panely.
4. Od ďalšieho štartu sa Clover otvára so štyrmi panelmi.

Kto Clover už mal, uvítanie neuvidí (inštalátor vytvorí `~/.config/clover/state/welcomed`).

## Skratky

| Čo | Mac | Windows |
|---|---|---|
| Nový panel s Claudom vpravo / dole | Cmd+D / Cmd+E | Ctrl+Shift+D / E |
| Panel s obyčajným terminálom | Cmd+Shift+N | Ctrl+Shift+N |
| Zväčšiť / vrátiť panel | Cmd+Enter | Ctrl+Shift+Enter |
| Presun medzi panelmi | Cmd+Alt+šípky | Ctrl+Shift+Alt+šípky |
| Zavrieť panel | Cmd+W | Ctrl+Shift+W |
| Nový riadok v Claudovi | Shift+Enter | Shift+Enter |
| **Ťahák všetkých skratiek** | **Cmd+/** | **Ctrl+Shift+/** |

## Obnova sessions

Zavrieš Clover → pri ďalšom štarte sa v každom z 4 panelov obnoví session, ktorá v ňom bežala.
Panel, v ktorom si Clauda ukončil cez `/exit`, začne načisto. Obnoví sa len session, ktorá má
aspoň jednu správu a nebeží práve v inom okne. Stará sa o to hook `remember.sh`
(SessionStart, pridaný do `~/.claude/settings.json`) + `start.sh`. Vypnúť: `restore = false` v `~/.clover.lua`.

## Osobné nastavenia

`~/.clover.lua`: priečinok, počet panelov (1/2/4), obnova sessions, font (predvolene 12), farby.

## Súbory

- `clover.lua` → `~/.config/clover/clover.lua` (Mac: načíta ho `/Applications/Clover.app`, Windows: skratka Clover)
- `clover.example.lua` → `~/.clover.lua`
- `claude/CLAUDE.md`, `claude/settings.json` → `~/.claude/` (len ak chýbajú)
- `vitaj.sh` / `vitaj.ps1` → uvítanie pri prvom štarte
- `claude/skills/vitaj/` → `~/.claude/skills/vitaj/` (sprievodca `/vitaj`, pri inštalácii sa aktualizuje)
- `assets/` ikona (`make_icon.py` ju vygeneruje)

## Licencia

MIT. Clover je nastavenie a skripty okolo [WezTermu](https://github.com/wezterm/wezterm)
(MIT, © Wez Furlong). Inštalátor sťahuje oficiálny WezTerm a oficiálny Claude Code.
Clover nie je produkt Anthropicu.
