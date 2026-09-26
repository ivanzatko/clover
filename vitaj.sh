#!/bin/bash
# Clover: uvítacia obrazovka pri úplne prvom štarte (volá ju start.sh v paneli 1).
# Vysvetlí, čo sa ide diať, počká na Enter a potom sa spustí Claude.

B=$'\033[1m'; D=$'\033[2m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[0m'
clear
cat <<EOF

   ${G}🍀  Vitaj v Cloveri.${R}

   Toto okno je terminál. Vyzerá ako z filmu o hackeroch,
   ale dnes nikoho hackovať nebudeme. Sľubujem.

   Budeš sem písať normálnou slovenčinou. Odpovedať ti bude Claude,
   a na rozdiel od chatu v prehliadači vie aj ${B}robiť${R}: otvoriť súbor,
   prepísať ho, pripraviť mail, upratať priečinok. Vždy sa ťa najprv
   spýta, či smie.

   ${B}Čo sa stane, keď stlačíš Enter${R}

   ${Y}1.${R} Claude sa spýta na farby. Daj Enter, na tom teraz nezáleží.
   ${Y}2.${R} Otvorí sa prehliadač a prihlásiš sa svojím Claude účtom.
      ${D}(Potrebuješ predplatné Pro alebo Max. Robí sa to len raz.)${R}
   ${Y}3.${R} Spýta sa, či dôveruje tomuto priečinku. Áno, je to tvoj
      domovský priečinok a bez tvojho súhlasu v ňom nič nezmení.
   ${Y}4.${R} Napíš ${B}/vitaj${R} a Claude ťa za pár minút prevedie tým,
      čo potrebuješ vedieť. Je to celkom zábavné. Vážne.

   ${D}Zatiaľ je tu jeden panel, aby sa ti prihlasovanie neotvorilo štyrikrát.
   Nabudúce sa Clover otvorí rovno so štyrmi Claudmi.${R}

EOF
printf "   Stlač ${B}Enter${R} a ideme na to… "
read -r _
mkdir -p "$HOME/.config/clover/state"
touch "$HOME/.config/clover/state/welcomed"
clear
