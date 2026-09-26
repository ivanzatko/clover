# Clover — odinštalovanie (Windows). WezTerm, Claude Code, git a tvoje konverzácie nechá tak.
# Použitie (PowerShell): irm https://raw.githubusercontent.com/ivanzatko/clover/main/uninstall-win.ps1 | iex
foreach ($dir in @([Environment]::GetFolderPath('Programs'), [Environment]::GetFolderPath('Desktop'))) {
  Remove-Item (Join-Path $dir 'Clover.lnk') -ErrorAction SilentlyContinue
}
Remove-Item -Recurse -Force "$HOME\.config\clover", "$HOME\.claude\skills\vitaj" -ErrorAction SilentlyContinue
if (Test-Path "$HOME\.clover.lua") { Move-Item "$HOME\.clover.lua" "$HOME\.clover.lua.bak-$(Get-Date -Format yyyyMMdd-HHmmss)" }
$Set = "$HOME\.claude\settings.json"
if (Test-Path $Set) {
  $json = Get-Content $Set -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $json) { $json = [pscustomobject]@{} }
  if ($json -and $json.hooks) {
    foreach ($ev in @($json.hooks.PSObject.Properties.Name)) {
      $keep = @($json.hooks.$ev | Where-Object { -not (($_ | ConvertTo-Json -Depth 10) -match '\.config/clover/') })
      if ($keep.Count) { $json.hooks.$ev = $keep } else { $json.hooks.PSObject.Properties.Remove($ev) }
    }
    [IO.File]::WriteAllText($Set, ($json | ConvertTo-Json -Depth 30), [Text.UTF8Encoding]::new($false))
  }
}
Write-Host 'Clover je preč. Claude Code a tvoje konverzácie ostali.' -ForegroundColor Green
