#!/bin/bash
# Clover — inštalácia pre Mac
# Použitie: curl -fsSL <KIT_URL>/install-mac.sh | bash
# Bezpečné spustiť opakovane: čo už máš, preskočí; tvoje súbory neprepíše (robí zálohu).
# Aktualizácia Clover = spustiť znova.
set -euo pipefail

KIT_URL="${KIT_URL:-https://raw.githubusercontent.com/ivanzatko/clover/main}"
WEZ_VER="20240203-110809-5046fc22"
WEZ_ZIP="https://github.com/wezterm/wezterm/releases/download/$WEZ_VER/WezTerm-macos-$WEZ_VER.zip"
# kontrolný súčet z oficiálneho releasu (…zip.sha256), pri novej verzii WezTermu aktualizovať
WEZ_SHA256="e77388cad55f2e9da95a220a89206a6c58f865874a629b7c3ea3c162f5692224"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"
APP=/Applications/Clover.app
CFG_DIR="$HOME/.config/clover"
# bez stien textu z Homebrew
export HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ENV_HINTS=1 HOMEBREW_NO_INSTALL_CLEANUP=1

B=$'\033[1m'; D=$'\033[2m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[0m'
say() { printf "\n${G}🍀 %s${R}\n" "$1"; }
why() { printf "${D}   %s${R}\n" "$@"; }      # čo a prečo, sivo pod nadpisom kroku
done_() { printf "   ${G}✓${R} %s\n" "${1:-hotovo}"; }
# pri curl | bash je stdin samotný skript, na Enter čakáme z terminálu (ak nejaký je)
TTY=""; { exec 3</dev/tty; } 2>/dev/null && TTY=1
pause() { [ -n "$TTY" ] && read -r -u 3 _ || true; }
fetch() { # fetch <súbor> <cieľ> — lokálna kópia, inak stiahnuť
  if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/$1" ]; then cp "$SCRIPT_DIR/$1" "$2"
  else curl -fsSL "$KIT_URL/$1" -o "$2"; fi
}
add_line() { grep -qsF "$1" "$2" || echo "$1" >> "$2"; }

[ -d "$APP" ] && EXISTING=1 || EXISTING=""

[ -n "$TTY" ] && clear
cat <<EOF

   ${G}🍀  Clover${R}  ${D}· inštalácia${R}

   Ahoj. O pár minút budeš mať appku, v ktorej ťa čakajú štyria Claudi.
   Kým to beží, budem ti rozprávať, čo robím a prečo. Nič tajné.

   ${B}Čo ťa čaká${R}
   ${Y}1${R}  Homebrew a git      nástroje, bez ktorých Claude nefunguje
   ${Y}2${R}  Claude Code         samotný Claude, rovno od Anthropicu
   ${Y}3${R}  Nastavenia          4 panely, skratky, pamäť na konverzácie
   ${Y}4${R}  Appka Clover        ikonka v Aplikáciách (~100 MB)
   ${Y}5${R}  Drobnosti           upratanie hlášok a sprievodca /vitaj

   ${B}Čo nerobím${R}: nemažem tvoje súbory, nič o tebe neposielam
   a tvoje nastavenia pred zmenou zálohujem.

   ${D}Čo už máš, preskočím. Ak toto spúšťaš znova, je to aktualizácia.${R}

EOF
if [ -n "$TTY" ]; then printf "   ${B}Enter${R} = ideme · ${B}Ctrl+C${R} = radšej nie  "; pause; fi

say "1/5 Homebrew a git"
why "Homebrew je obchod s aplikáciami pre terminál. Bez reklám a bez recenzií s jednou hviezdičkou." \
    "Git je stroj času na súbory. Claude ho potrebuje, aby vedel, čo zmenil, a vedel to vrátiť."
if ! command -v brew >/dev/null 2>&1; then
  echo
  echo "   ${Y}Mac si teraz vypýta heslo do počítača.${R}"
  echo "   Keď ho budeš písať, neuvidíš ani hviezdičky. To nie je chyba, Mac je len diskrétny."
  echo "   Napíš ho naslepo a stlač Enter. Ak sa objaví okno s Xcode nástrojmi, potvrď ho."
  echo "   ${D}Môže to trvať aj 10 minút. Ideálny čas na kávu.${R}"
  echo
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  BREW=/opt/homebrew/bin/brew; [ -x "$BREW" ] || BREW=/usr/local/bin/brew
  add_line "eval \"\$($BREW shellenv)\"" ~/.zprofile
  eval "$($BREW shellenv)"
fi
command -v git >/dev/null 2>&1 && git --version >/dev/null 2>&1 || brew install --quiet git
done_ "Homebrew aj git sú na mieste"

say "2/5 Claude Code"
why "Oficiálny inštalátor z claude.ai. Nič upravené, nič navyše." \
    "Prihlasovať sa budeš až v Cloveri, teraz sa len sťahuje."
if ! command -v claude >/dev/null 2>&1 && [ ! -x ~/.local/bin/claude ]; then
  curl -fsSL https://claude.ai/install.sh | bash
fi
add_line 'export PATH="$HOME/.local/bin:$PATH"' ~/.zprofile
done_ "Claude Code je nainštalovaný"

say "3/5 Nastavenia"
why "Toto je celé kúzlo Cloveru: 4 panely, skratky ako v bežnej appke," \
    "kopírovanie označením a pamäť, ktorá po reštarte vráti konverzácie na miesto." \
    "Tvoje vlastné nastavenia (~/.clover.lua) neprepisujem."
mkdir -p "$CFG_DIR"
fetch clover.lua "$CFG_DIR/clover.lua"
fetch skratky.txt "$CFG_DIR/skratky.txt"
fetch remember.sh "$CFG_DIR/remember.sh"
fetch start.sh "$CFG_DIR/start.sh"
fetch vitaj.sh "$CFG_DIR/vitaj.sh"
fetch assets/clover.icns "$CFG_DIR/clover.icns"
if [ ! -f ~/.clover.lua ]; then
  if [ -f ~/.claude-terminal.lua ]; then mv ~/.claude-terminal.lua ~/.clover.lua
  else fetch clover.example.lua ~/.clover.lua; fi
fi
# kto už Clover mal, uvítanie pre nováčikov neuvidí
if [ -n "$EXISTING" ]; then mkdir -p "$CFG_DIR/state"; touch "$CFG_DIR/state/welcomed"; fi
done_ "nastavenia sú v ~/.config/clover"

say "4/5 Appka Clover"
why "Stiahnem WezTerm, open source terminál od Weza Furlonga. To je motor Cloveru." \
    "Prezlečiem ho do štvorlístka, nastavím mu naše nastavenia a dám ho do Aplikácií."
# appku staviame len pri prvej inštalácii alebo novej verzii WezTermu;
# zmeny konfigu sa prejavia samé, bežiace sessions sa nezatvárajú
if [ -f "$APP/Contents/Resources/clover-version" ] && [ "$(cat "$APP/Contents/Resources/clover-version")" = "$WEZ_VER" ]; then
  done_ "appka už je, nastavenia som aktualizoval"
elif pgrep -f "$APP/Contents/MacOS" >/dev/null 2>&1; then
  echo "   Clover práve beží. Zavri ho (Cmd+Q) a spusti tento príkaz znova."
  echo "   Neboj, rozrobené konverzácie sa po otvorení vrátia na svoje miesto."
  exit 1
else
  TMP="$(mktemp -d)"
  echo "   Sťahujem ~100 MB. Pri pomalom internete je toto chvíľa na pretiahnutie chrbta."; curl -fL --progress-bar "$WEZ_ZIP" -o "$TMP/wez.zip"
  if [ "$(shasum -a 256 "$TMP/wez.zip" | cut -d' ' -f1)" != "$WEZ_SHA256" ]; then
    echo "   Stiahnutý súbor nesedí s kontrolným súčtom. Radšej končím, nič som nenainštaloval."
    echo "   Skús to o chvíľu znova (mohol sa len pokaziť download)."
    rm -rf "$TMP"; exit 1
  fi
  ditto -x -k "$TMP/wez.zip" "$TMP"
  SRC="$(find "$TMP" -maxdepth 2 -name WezTerm.app -type d | head -1)"
  rm -rf "$APP"
  ditto "$SRC" "$APP"
  rm -rf "$TMP"
  PL="$APP/Contents/Info.plist"; PB=/usr/libexec/PlistBuddy
  pset() { $PB -c "Set :$1 $2" "$PL" 2>/dev/null || $PB -c "Add :$1 string $2" "$PL"; }
  pset CFBundleName Clover
  pset CFBundleDisplayName Clover
  pset CFBundleIdentifier com.ivanzatko.clover
  cp "$CFG_DIR/clover.icns" "$APP/Contents/Resources/clover.icns"
  pset CFBundleIconFile clover.icns
  $PB -c "Delete :CFBundleIconName" "$PL" 2>/dev/null || true
  $PB -c "Delete :LSEnvironment" "$PL" 2>/dev/null || true
  $PB -c "Add :LSEnvironment dict" "$PL"
  $PB -c "Add :LSEnvironment:WEZTERM_CONFIG_FILE string $CFG_DIR/clover.lua" "$PL"
  echo "$WEZ_VER" > "$APP/Contents/Resources/clover-version"
  codesign --force --deep --sign - "$APP" 2>/dev/null
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$APP" 2>/dev/null || true
  done_ "Clover je v Aplikáciách"
fi

say "5/5 Drobnosti"
why "Vypnem hlášku „Last login“, ktorá nikoho nezaujíma." \
    "Claudovi založím súbor, kam si zapíše, kto si (ak ho ešte nemáš)," \
    "a pridám sprievodcu /vitaj, ktorý ťa prevedie prvými krokmi."
touch ~/.hushlogin                                   # žiadne „Last login…“
mkdir -p ~/.claude
[ -f ~/.claude/CLAUDE.md ] || fetch claude/CLAUDE.md ~/.claude/CLAUDE.md
[ -f ~/.claude/settings.json ] || fetch claude/settings.json ~/.claude/settings.json
# hook, vďaka ktorému Clover po reštarte obnoví rozrobené sessions
fetch add_hook.py "$CFG_DIR/add_hook.py" && /usr/bin/python3 "$CFG_DIR/add_hook.py" >/dev/null || true
mkdir -p ~/.claude/skills/vitaj
fetch claude/skills/vitaj/SKILL.md ~/.claude/skills/vitaj/SKILL.md
done_ "upratané"

cat <<EOF

   ${G}🍀  Hotovo.${R} Clover je v Aplikáciách a práve sa otvára.

   ${B}Čo bude ďalej${R}
   ${Y}→${R} Clover ťa privíta a vysvetlí prihlásenie do Clauda (robí sa len raz).
   ${Y}→${R} Potom napíš ${B}/vitaj${R}. Päť minút a budeš vedieť všetko podstatné.
   ${Y}→${R} Ťahák skratiek je vždy na ${B}Cmd+/${R}.

   ${D}Tip: pretiahni Clover z Aplikácií do Docku.
   Aktualizácia = spustiť tento istý príkaz znova.${R}

EOF
pgrep -f "$APP/Contents/MacOS" >/dev/null 2>&1 || open "$APP"
