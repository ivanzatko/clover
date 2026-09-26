# Clover (Windows): spustí Clauda v paneli, obnoví session z minula (ak existuje a nebeží inde)
param([string]$Slot = '')
$f = "$HOME\.config\clover\state\slot-$Slot"
# úplne prvý štart: uvítanie v paneli 1 (clover.lua vtedy otvorí len jeden panel)
if ($Slot -eq '1' -and -not (Test-Path "$HOME\.config\clover\state\welcomed")) {
  & "$HOME\.config\clover\vitaj.ps1"
}
function Live($id) {
  Get-ChildItem "$HOME\.claude\sessions\*.json" -ErrorAction SilentlyContinue | Where-Object {
    ((Get-Content $_.FullName -Raw) -match "`"sessionId`":`"$id`"") -and (Get-Process -Id $_.BaseName -ErrorAction SilentlyContinue)
  }
}
if ($Slot -and (Test-Path $f) -and $env:CLOVER_RESTORE -ne '0') {
  $id, $dir = (Get-Content $f -Raw).Trim() -split ' ', 2
  if ($id -and (Test-Path "$HOME\.claude\projects\*\$id.jsonl") -and -not (Live $id)) {
    if ($dir) { Set-Location ($dir -replace '\\\\', '\') }
    claude --resume $id @args
    Remove-Item $f -ErrorAction SilentlyContinue
    return
  }
}
claude @args
if ($Slot) { Remove-Item $f -ErrorAction SilentlyContinue }
