# Clover 🍀

Terminál, ktorý sa otvorí rovno so 4 panelmi Claude Code (2×2), bez medzikrokov.
Mac aj Windows. Postavené na [WezTerm](https://github.com/wezterm/wezterm) (MIT licencia, © Wez Furlong).
O novej verzii dá Clover vedieť sám, aktualizuje sa cez Cmd+Shift+U (Windows Ctrl+Shift+U).

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

## E-mail a káva ☕

Clover je zadarmo. Inštalátor sa raz spýta na e-mail a pošle ho na ivanzatko.com
(`/api/clover/install`: e-mail, systém, verzia), aby Ivan vedel, kto Clover používa.
Nikomu ho nedá. Pri aktualizácii sa už nepýta (`~/.config/clover/email`).

Prvých 48 hodín po inštalácii ukazuje Clover hore lištu „☕ Sadol ti Clover?“ a raz za spustenie
notifikáciu s odkazom na kávu za 20 € (Cmd+Shift+K, Windows Ctrl+Shift+K). Po zaplatení
alebo po 48 hodinách to zmizne a už sa nevráti. Nič sa nezamyká.

## Prvé spustenie

1. Clover sa prvýkrát otvorí s **jedným** panelom a uvítaním (`vitaj.sh`), ktoré vysvetlí, čo sa bude diať.
   Jeden panel preto, aby sa prihlásenie do Clauda neotvorilo štyrikrát naraz.
2. Claude sa raz spýta na farby a prihlásenie (treba predplatné Pro alebo Max).
3. Napíš **`/vitaj`**: sprievodca (skill v `~/.claude/skills/vitaj`) ti za 5 minút rukami ukáže,
   v čom je Clover iný než obyčajný terminál: písanie, myš, súbory, panely, „kto na teba čaká“, obnova.
4. Od ďalšieho štartu sa Clover otvára so štyrmi panelmi. Kto je do Clauda už prihlásený,
   má štyri panely hneď.

Kto Clover už mal, uvítanie neuvidí (inštalátor vytvorí `~/.config/clover/state/welcomed`).

## Aktualizácie

Clover si raz za 6 hodín stiahne súbor [`VERSION`](VERSION) (1. riadok verzia, ďalšie novinky)
a porovná ho s `~/.config/clover/version`. Keď je na GitHube novšia verzia, príde notifikácia
a hore sa ukáže lišta. **Samo sa nič neinštaluje.** Aktualizáciu spustíš Cmd+Shift+U
(Windows Ctrl+Shift+U): v novom tabe beží ten istý inštalátor v tichom režime (`CLOVER_UPDATE=1`),
prepíše konfig a skripty a nastavenia sa načítajú bez reštartu. Rozrobené konverzácie ostanú.

Ručne to ide aj tak, že spustíš inštalačný príkaz znova.

## Odinštalovanie

Claude Code, Homebrew, git a tvoje konverzácie ostanú. Zmizne appka, nastavenia Cloveru a hook.

**Mac:** `curl -fsSL https://raw.githubusercontent.com/ivanzatko/clover/main/uninstall-mac.sh | bash`

**Windows:** `irm https://raw.githubusercontent.com/ivanzatko/clover/main/uninstall-win.ps1 | iex`

## Bezpečnosť

- WezTerm na Macu sa sťahuje z oficiálneho releasu a overuje sa kontrolným súčtom (SHA-256).
  Na Windows ho inštaluje winget, ktorý robí to isté.
- Na klik sa otvárajú len webové odkazy (`http`, `https`) a `mailto`. Iné schémy nie.
- `~/.claude/settings.json` sa pred úpravou zálohuje a mení sa v ňom len pridanie jedného hooku.
- Zákazy v šablóne `claude/settings.json` sú základná poistka, nie ochrana. Dôležité je čítať,
  čo Claude žiada, a keď to nesedí, stlačiť Esc.

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

## Kto na teba čaká

Keď Claude v niektorom paneli čaká na tvoje povolenie alebo dokončí prácu a ty sa práve pozeráš
inam, príde notifikácia („Claude vpravo hore čaká na teba") a hore sa ukáže lišta so stavom.
Keď sa na panel pozrieš alebo mu odpíšeš, zmizne. Robia to hooky `Notification`, `Stop`
a `UserPromptSubmit` (`notify.sh`) a `update-status` v `clover.lua`.
Na Macu sa pri prvej notifikácii systém spýta, či ich Clover smie posielať.

## Obnova sessions

Zavrieš Clover → pri ďalšom štarte sa v každom z 4 panelov obnoví session, ktorá v ňom bežala.
Panel, v ktorom si Clauda ukončil cez `/exit`, začne načisto. Obnoví sa len session, ktorá má
aspoň jednu správu a nebeží práve v inom okne. Stará sa o to hook `remember.sh`
(SessionStart, pridaný do `~/.claude/settings.json`) + `start.sh`. Vypnúť: `restore = false` v `~/.clover.lua`.

## Osobné nastavenia

`~/.clover.lua`: priečinok, počet panelov (1/2/4), obnova sessions, písmo, farby.
Písmo sa na Macu nastaví podľa obrazovky (12 na FullHD, Retina MacBook ~9,5). Ak si nastavíš
`font_size`, platí tvoje.

## Súbory

- `clover.lua` → `~/.config/clover/clover.lua` (Mac: načíta ho `/Applications/Clover.app`, Windows: skratka Clover)
- `clover.example.lua` → `~/.clover.lua`
- `claude/CLAUDE.md`, `claude/settings.json` → `~/.claude/` (len ak chýbajú)
- `notify.sh` → hook pre „kto na teba čaká"
- `vitaj.sh` / `vitaj.ps1` → uvítanie pri prvom štarte
- `claude/skills/vitaj/` → `~/.claude/skills/vitaj/` (sprievodca `/vitaj`, pri inštalácii sa aktualizuje)
- `assets/` ikona (`make_icon.py` ju vygeneruje)

## Licencia

MIT. Clover je nastavenie a skripty okolo [WezTermu](https://github.com/wezterm/wezterm)
(MIT, © Wez Furlong). Inštalátor sťahuje oficiálny WezTerm a oficiálny Claude Code.
Clover nie je produkt Anthropicu.
