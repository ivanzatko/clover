# Clover — inštalácia pre Windows
# Použitie (PowerShell): irm <KIT_URL>/install-win.ps1 | iex
# Bezpečné spustiť opakovane: čo už máš, preskočí; tvoje súbory neprepíše (robí zálohu).
$ErrorActionPreference = 'Stop'

$KitUrl = if ($env:KIT_URL) { $env:KIT_URL } else { 'https://raw.githubusercontent.com/ivanzatko/clover/main' }
$ScriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { '' }
$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function Say($t) { Write-Host "`n🍀 $t" -ForegroundColor Green }
function Why([string[]]$lines) { foreach ($l in $lines) { Write-Host "   $l" -ForegroundColor DarkGray } }
function Ok($t = 'hotovo') { Write-Host "   ✓ $t" -ForegroundColor Green }
function Fetch($name, $dest) {
  $local = if ($ScriptDir) { Join-Path $ScriptDir $name } else { '' }
  if ($local -and (Test-Path $local)) { Copy-Item $local $dest -Force }
  else { Invoke-WebRequest -UseBasicParsing "$KitUrl/$name" -OutFile $dest }
}
function Has($cmd) { [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }
function WingetInstall($id) {
  winget install --id $id -e --accept-source-agreements --accept-package-agreements --silent
}

if (-not (Has winget)) {
  Write-Host 'Chýba winget (App Installer). Nainštaluj ho z Microsoft Store a spusti znova.' -ForegroundColor Red
  exit 1
}

$Existing = Test-Path (Join-Path ([Environment]::GetFolderPath('Programs')) 'Clover.lnk')

Clear-Host
Write-Host ''
Write-Host '   🍀  Clover · inštalácia' -ForegroundColor Green
Write-Host ''
Write-Host '   Ahoj. O pár minút budeš mať appku, v ktorej ťa čakajú štyria Claudi.'
Write-Host '   Kým to beží, budem ti rozprávať, čo robím a prečo. Nič tajné.'
Write-Host ''
Write-Host '   Čo ťa čaká' -ForegroundColor White
Write-Host '   1  Git                 bez neho Claude na Windows nefunguje'
Write-Host '   2  WezTerm             motor Cloveru (open source terminál)'
Write-Host '   3  Claude Code         samotný Claude, rovno od Anthropicu'
Write-Host '   4  Nastavenia          4 panely, skratky, pamäť, sprievodca /vitaj'
Write-Host ''
Write-Host '   Čo nerobím: nemažem tvoje súbory, nič o tebe neposielam'
Write-Host '   a tvoje nastavenia pred zmenou zálohujem.'
Write-Host ''
Write-Host '   Čo už máš, preskočím. Ak toto spúšťaš znova, je to aktualizácia.' -ForegroundColor DarkGray
Write-Host ''
Read-Host '   Enter = ideme · Ctrl+C = radšej nie' | Out-Null

Say '1/4 Git'
Why 'Git je stroj času na súbory. Claude ho potrebuje, aby vedel, čo zmenil, a vedel to vrátiť.',
    'Ak Windows ukáže okno „Chcete povoliť tejto aplikácii…“, daj Áno. To je inštalátor gitu.'
if (-not (Has git)) { WingetInstall 'Git.Git' }
Ok 'git je na mieste'

Say '2/4 WezTerm'
Why 'Open source terminál od Weza Furlonga. Na ňom Clover stojí, my mu len dáme nové šaty.'
if (-not (Test-Path "$env:ProgramFiles\WezTerm\wezterm-gui.exe")) { WingetInstall 'wez.wezterm' }
Ok 'WezTerm je nainštalovaný'

Say '3/4 Claude Code'
Why 'Oficiálny inštalátor z claude.ai. Nič upravené, nič navyše.',
    'Prihlasovať sa budeš až v Cloveri, teraz sa len sťahuje.'
$ClaudeBin = Join-Path $HOME '.local\bin'
if (-not (Has claude) -and -not (Test-Path (Join-Path $ClaudeBin 'claude.exe'))) {
  Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
}
$UserPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($UserPath -notlike "*$ClaudeBin*") {
  [Environment]::SetEnvironmentVariable('Path', "$UserPath;$ClaudeBin", 'User')
}
Ok 'Claude Code je nainštalovaný'

Say '4/4 Nastavenia a appka Clover'
Why 'Toto je celé kúzlo Cloveru: 4 panely, skratky ako v bežnej appke, kopírovanie označením',
    'a pamäť, ktorá po reštarte vráti konverzácie na miesto. Pridám skratku Clover na plochu',
    'a do Štart menu a sprievodcu /vitaj. Tvoje vlastné nastavenia neprepisujem.'
$Cfg = Join-Path $HOME '.config\clover'
New-Item -ItemType Directory -Force $Cfg | Out-Null
$Lua = Join-Path $Cfg 'clover.lua'
Fetch 'clover.lua' $Lua
Fetch 'skratky.txt' (Join-Path $Cfg 'skratky.txt')
Fetch 'remember.sh' (Join-Path $Cfg 'remember.sh')
Fetch 'start.ps1' (Join-Path $Cfg 'start.ps1')
Fetch 'vitaj.ps1' (Join-Path $Cfg 'vitaj.ps1')
# kto už Clover mal, uvítanie pre nováčikov neuvidí
if ($Existing) {
  New-Item -ItemType Directory -Force (Join-Path $Cfg 'state') | Out-Null
  New-Item -ItemType File -Force (Join-Path $Cfg 'state\welcomed') | Out-Null
}
Fetch 'assets/clover.ico' (Join-Path $Cfg 'clover.ico')
$Local = Join-Path $HOME '.clover.lua'
if (-not (Test-Path $Local)) { Fetch 'clover.example.lua' $Local }
# skratka „Clover“ v Štart menu a na ploche
$Gui = "$env:ProgramFiles\WezTerm\wezterm-gui.exe"
$Shell = New-Object -ComObject WScript.Shell
foreach ($dir in @([Environment]::GetFolderPath('Programs'), [Environment]::GetFolderPath('Desktop'))) {
  $lnk = $Shell.CreateShortcut((Join-Path $dir 'Clover.lnk'))
  $lnk.TargetPath = $Gui
  $lnk.Arguments = "--config-file `"$Lua`""
  $lnk.IconLocation = (Join-Path $Cfg 'clover.ico')
  $lnk.WorkingDirectory = $HOME
  $lnk.Save()
}
$ClaudeDir = Join-Path $HOME '.claude'
New-Item -ItemType Directory -Force $ClaudeDir | Out-Null
if (-not (Test-Path "$ClaudeDir\CLAUDE.md")) { Fetch 'claude/CLAUDE.md' "$ClaudeDir\CLAUDE.md" }
if (-not (Test-Path "$ClaudeDir\settings.json")) { Fetch 'claude/settings.json' "$ClaudeDir\settings.json" }
# hook, vďaka ktorému Clover po reštarte obnoví rozrobené sessions
$Set = "$ClaudeDir\settings.json"
$json = Get-Content $Set -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $json) { $json = [pscustomobject]@{} }
if (-not ($json | ConvertTo-Json -Depth 30 | Select-String 'clover/remember.sh' -Quiet)) {
  Copy-Item $Set "$Set.bak-$Stamp"
  if (-not $json.hooks) { $json | Add-Member hooks ([pscustomobject]@{}) }
  if (-not $json.hooks.SessionStart) { $json.hooks | Add-Member SessionStart @() }
  $json.hooks.SessionStart = @($json.hooks.SessionStart) + [pscustomobject]@{ hooks = @([pscustomobject]@{ type = 'command'; command = 'bash "$HOME/.config/clover/remember.sh"' }) }
  # bez BOM: PowerShell 5 by s -Encoding UTF8 pridal BOM a Claude by settings.json nemusel prečítať
  [IO.File]::WriteAllText($Set, ($json | ConvertTo-Json -Depth 30), [Text.UTF8Encoding]::new($false))
}

$Skill = Join-Path $ClaudeDir 'skills\vitaj'
New-Item -ItemType Directory -Force $Skill | Out-Null
Fetch 'claude/skills/vitaj/SKILL.md' (Join-Path $Skill 'SKILL.md')
Ok 'Clover je na ploche aj v Štart menu'

Write-Host ''
Write-Host '   🍀  Hotovo. Clover sa práve otvára.' -ForegroundColor Green
Write-Host ''
Write-Host '   Čo bude ďalej' -ForegroundColor White
Write-Host '   → Clover ťa privíta a vysvetlí prihlásenie do Clauda (robí sa len raz).'
Write-Host '   → Potom napíš /vitaj. Päť minút a budeš vedieť všetko podstatné.'
Write-Host '   → Ťahák skratiek je vždy na Ctrl+Shift+/.'
Write-Host ''
Write-Host '   Aktualizácia = spustiť tento istý príkaz znova.' -ForegroundColor DarkGray
Write-Host ''
Start-Process $Gui -ArgumentList "--config-file `"$Lua`""
