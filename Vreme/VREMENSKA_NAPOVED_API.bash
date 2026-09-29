#!/bin/bash
# Naloga: beri vremenske podatke za mesta iz mesta.txt

#Predpogoj inštalacija: curl, jq
#Vhod:mesta.txt
#Klic:
#	chmod +x VREMENSKA_NAPOVED_API.bash
#	sed -i 's/\r$//' VREMENSKA_NAPOVED_API.bash
	
set -u
:<< 'SET -U'
Z eno vrstico na vrhu skripte bash preneha ugibati ali spremenljivke obstajajo
Skripta se ustavi na tisti vrstici, nadaljnje vrstice se ne izvedejo.
Primer:
rm -rf "$MAPA"/*        
	#Če je spremenljivka MAPA prazna, to postane  rm -rf /*
SET -U

API="https://api.open-meteo.com/v1/forecast"

DANES=$(date +%F)  

ARHIV="arhiv/$DANES"

mkdir -p "$ARHIV" #kreiram imenik "arhiv/današnji datum"; bere iz spremenljivke DANES.

echo "cas,mesto,temperatura,vlaga,veter" > TRENUTNO_VREME.csv
echo "mesto,cas,temperatura,vlaga,veter" > URNO_VREME.csv
echo "mesto,datum,tmax,tmin,padavin" > NAPOVED_VREMENA.csv

while IFS=';' read -r mesto sirina dolzina; #pogoj

do #dokler pogoj ustreza delamo:

    [ -z "$mesto" ] && continue # preskoci prazne vrstice
	#Ta ukaz preverja tekstovne nize. Kratica -z pomeni zero (nič).
	#Preveri, ali je spremenljivka prazna (nima nobenega znaka).
	#continue pa preskoči iteracijo zanke.
	
    case "$mesto" in \#*) continue;; esac           # preskoci komentarje


URL="$API?latitude=$sirina&longitude=$dolzina&current=temperature_2m,relative_humidity_2m,wind_speed_10m&hourly=wind_speed_10m,temperature_2m,relative_humidity_2m&daily=temperature_2m_max,precipitation_sum,temperature_2m_min&forecast_days=3&timezone=Europe%2FLjubljana"



set -x # Vklopi debugiranje

    if ! curl -sS --fail --max-time 20 -o "$ARHIV/$mesto.json" "$URL"; then
        echo "   NAPAKA: $mesto ni uspel" >&2
        continue
    fi
set +x  # Izklopi debugiranje

   
   jq -r --arg m "$mesto" \
       '[.current.time, $m, .current.temperature_2m, .current.relative_humidity_2m,
         .current.wind_speed_10m] | @csv' \
       "$ARHIV/$mesto.json" >> TRENUTNO_VREME.csv
	   
	jq -r --arg m "$mesto" \
       '.hourly | [.time, .temperature_2m, .relative_humidity_2m, .wind_speed_10m]
        | transpose[] | [$m] + . | @csv' \
       "$ARHIV/$mesto.json" >> URNO_VREME.csv

    jq -r --arg m "$mesto" \
       '.daily | [.time, .temperature_2m_max, .temperature_2m_min, .precipitation_sum]
        | transpose[] | [$m] + . | @csv' \
       "$ARHIV/$mesto.json" >> NAPOVED_VREMENA.csv

    sleep 1 #Open-Meteo dovoli 600 klicev na minuto, torej 10 na sekundo.
done < mesta.txt

echo
echo "Shranjeno v $ARHIV/  ($(ls "$ARHIV" | wc -l) datotek)"
echo "TRENUTNO_VREME.csv: $(($(wc -l < TRENUTNO_VREME.csv) - 1)) vrstic"
echo "URNO_VREME.csv:  $(($(wc -l < URNO_VREME.csv) - 1)) vrstic"
echo "NAPOVED_VREMENA.csv:  $(($(wc -l < NAPOVED_VREMENA.csv) - 1)) vrstic"

:<< 'ECHO'
#primer enojni dvojni narekovaji
echo "dvojni: $ARHIV"      # dvojni: arhiv/2026-09-04
echo 'enojni: $ARHIV'      # enojni: $ARHIV

ls "$ARHIV"          # izpiše imena datotek
ls "$ARHIV" | wc -l  # 3  -l...lines
ECHO