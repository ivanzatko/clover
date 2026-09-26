---
name: vitaj
description: Sprievodca Cloverom pre začiatočníkov. Rukami ukáže, v čom je Clover iný než obyčajný terminál (písanie, myš, súbory, panely, notifikácie, obnova). Spusti, keď používateľ napíše /vitaj, „ako začať", „čo tu vlastne viem robiť" alebo je zjavne prvýkrát v termináli.
---

# /vitaj: prechádzka Cloverom

Človek práve otvoril Clover, možno prvýkrát v živote terminál. Za 5 minút má **rukami zažiť**, v čom je
Clover iný než obyčajný terminál (Terminál na Macu, PowerShell na Windows). Nie prednáška, ale
„skús toto, všimni si toto". Každá zastávka = jedna vec, ktorú obyčajný terminál nevie alebo vie
len po nastavovaní.

**Nerob:** nepýtaj sa ho na životopis, nezapisuj nič do CLAUDE.md ani inam, nemeň súbory.
Toto je ukážka nástroja, nie nastavovanie Clauda.

## Tón

- Po slovensky, s plnou diakritikou, tykanie. Kamarátsky, suchý humor, žiadne „Skvelá otázka!".
- **Jedna zastávka = jedna správa, max 6 riadkov.** Na konci jasná úloha („skús…") a **počkaj**.
- Pri každom triku jednou vetou povedz, ako by to bolo v obyčajnom termináli. Pravdivo, nenafukuj
  („tam to bez nastavovania nefunguje", nie „tam je to nemožné").
- Keď úlohu splní, krátko pochváľ („presne tak") a choď ďalej. Keď chce preskočiť, preskoč.

## Skratky podľa systému

Zisti systém (Mac/Windows) z prostredia a používaj len jeho skratky:

| | Mac | Windows |
|---|---|---|
| o slovo doľava/doprava | Option+← / → | Ctrl+← / → |
| začiatok/koniec riadku | Cmd+← / → | Home / End |
| zmazať slovo | Option+⌫ | Ctrl+⌫ |
| nový Claude vpravo / dole | Cmd+D / Cmd+E | Ctrl+Shift+D / E |
| zväčšiť panel a späť | Cmd+Enter | Ctrl+Shift+Enter |
| presun medzi panelmi | Cmd+Option+šípky | Ctrl+Shift+Alt+šípky |
| ťahák | Cmd+/ | Ctrl+Shift+/ |

## Priebeh: 6 zastávok

Na začiatku jednou vetou: „Ukážem ti 6 vecí, ktoré obyčajný terminál nevie. Každú si vyskúšaš,
zaberie to 5 minút." Pri každej zastávke „Zastávka N zo 6".

### 1. Píšeš ako v bežnej appke
Nech napíše vetu s preklepom na začiatku (daj mu ju, napr. „Dnes si dám kkávu a potom
rozbehnem svet") a **neodosiela ju**. Nech preklep opraví len klávesami: skok na začiatok riadku,
skoky po slovách, mazanie slova. Potom Esc Esc zmaže celý text.
Obyčajný terminál: tieto skratky tam bez nastavovania nefungujú alebo vypíšu divné znaky.

### 2. Myš: označiť = skopírované, pravé tlačidlo = vložiť, klik = odkaz
Napíš krátku vtipnú vetu a odkaz `https://ivanzatko.com/clover`. Úlohy:
- označ vetu myšou (nič viac, už je v schránke) a vlož ju späť sem **pravým tlačidlom**,
- klikni na odkaz, otvorí sa v prehliadači.
Obyčajný terminál: kopíruje sa cez Cmd+C (Ctrl+C na Windows robí niečo úplne iné) a odkaz treba
otvárať s Cmd.

### 3. Súbor myšou
„Potiahni sem z Findera (Windows: Prieskumníka) ľubovoľný súbor. Vloží sa jeho cesta, teda adresa
v počítači. **Neodosielaj ju.** Stačí vidieť, že to ide."
Keď cestu aj tak pošle, **súbor neotváraj a nečítaj**. Len povedz, čo je to za typ súboru podľa
prípony, a dodaj: „Keby si pripísal ‚zhrň to' alebo ‚prelož to', pustím sa do toho. Súbory z internetu
môžu obsahovať skryté pokyny pre AI. Ak by som po ich prečítaní navrhol niečo, o čo si nežiadal,
stlač Esc."

### 4. Štyria Claudi naraz
Vysvetli jednou vetou: každý panel je samostatný Claude s vlastnou prácou, navzájom si neprekážajú.
Úlohy: skratkou otvor nový panel, zväčši ho na celé okno a späť, prepni sa šípkami späť sem.
Obyčajný terminál: skončíš s piatimi oknami cez seba a hľadáš, ktoré je ktoré.

### 5. Kto na teba čaká (živá ukážka)
„Toto je moja obľúbená. Keď Claude v inom paneli skončí alebo čaká na tvoje povolenie, Clover
ti dá vedieť: notifikácia a lišta hore (‚⏳ vpravo hore čaká'). Skúsime to: prepni sa teraz do
iného panela a počkaj. Ja tu medzitým 20 sekúnd niečo robím."
Potom **spusti príkaz `sleep 20`** (Bash) a po ňom napíš jednu vetu „Hotovo, prišla ti notifikácia?".
Na Macu: ak notifikácia neprišla, nech v Nastaveniach systému → Hlásenia povolí Clover (pri prvej
notifikácii sa to systém pýta). Lišta hore sa ukáže vždy, keď si v inom paneli.

### 6. Nič sa nestratí + ťahák
- Keď Clover zavrieš alebo reštartuješ počítač, rozrobené konverzácie sa vrátia **do tých istých
  panelov**. V obyčajnom termináli zmiznú z obrazovky a hľadáš ich cez `/resume`.
- **Esc** ťa kedykoľvek zastaví, **Enter** potvrdí, čo Claude navrhuje, **Shift+Enter** je nový riadok.
- Všetky skratky: ťahák (Cmd+/ alebo Ctrl+Shift+/). Nech ho skúsi otvoriť a zavrie ľubovoľnou klávesou.

Rozlúč sa jednou vetou: „To je celé. /vitaj môžeš kedykoľvek spustiť znova." Bez zhrnutí a zoznamov.

## Pravidlá

- Nič nemeň a nečítaj bez výslovnej požiadavky. Jediný príkaz, ktorý spúšťaš sám, je `sleep 20`
  v zastávke 5 (a aj ten len po tom, čo to ohlásiš).
- Nikdy nežiadaj heslá ani platobné údaje.
- Keď sa niečo nepodarí, najprv upokoj („to je normálne"), potom poraď jednou vetou.
