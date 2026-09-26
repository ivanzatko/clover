# Clover (Windows): uvítacia obrazovka pri úplne prvom štarte (volá ju start.ps1 v paneli 1).
# Súbor je UTF-8 s BOM, inak Windows PowerShell 5 pokazí diakritiku.
Clear-Host
function W($t, $c = 'Gray') { Write-Host $t -ForegroundColor $c }
W ''
W '   🍀  Vitaj v Cloveri.' Green
W ''
W '   Toto okno je terminál. Vyzerá ako z filmu o hackeroch,'
W '   ale dnes nikoho hackovať nebudeme. Sľubujem.'
W ''
W '   Budeš sem písať normálnou slovenčinou. Odpovedať ti bude Claude,'
W '   a na rozdiel od chatu v prehliadači vie aj robiť: otvoriť súbor,'
W '   prepísať ho, pripraviť mail, upratať priečinok. Vždy sa ťa najprv'
W '   spýta, či smie.'
W ''
$LoggedIn = (Test-Path "$HOME\.claude.json") -and (Select-String -Path "$HOME\.claude.json" -SimpleMatch '"oauthAccount"' -Quiet)
if ($LoggedIn) {
  W '   Claude je už prihlásený, takže môžeme rovno začať.'
  W ''
  W '   Po Enteri napíš /vitaj. Päť minút a ukážem ti, v čom je Clover' White
  W '   iný než obyčajný terminál. Rukami, nie prednáškou.' White
  W ''
} else {
  W '   Čo sa stane, keď stlačíš Enter' White
  W ''
  W '   1. Claude sa spýta na farby. Daj Enter, na tom teraz nezáleží.' Yellow
  W '   2. Otvorí sa prehliadač a prihlásiš sa svojím Claude účtom.' Yellow
  W '      (Potrebuješ predplatné Pro alebo Max. Robí sa to len raz.)' DarkGray
  W '   3. Spýta sa, či dôveruje tomuto priečinku. Áno, je to tvoj' Yellow
  W '      domovský priečinok a bez tvojho súhlasu v ňom nič nezmení.'
  W '   4. Napíš /vitaj. Päť minút a ukážem ti, v čom je Clover' Yellow
  W '      iný než obyčajný terminál. Rukami, nie prednáškou.'
  W ''
  W '   Zatiaľ je tu jeden panel, aby sa ti prihlasovanie neotvorilo štyrikrát.' DarkGray
  W '   Nabudúce sa Clover otvorí rovno so štyrmi Claudmi.' DarkGray
  W ''
}
Read-Host '   Stlač Enter a ideme na to' | Out-Null
$st = "$HOME\.config\clover\state"
New-Item -ItemType Directory -Force $st | Out-Null
New-Item -ItemType File -Force "$st\welcomed" | Out-Null
Clear-Host
