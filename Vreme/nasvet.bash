#!/bin/bash
# Naloga: Procesi


set -u                                  # ustavi ob nedefinirani spremenljivki

MESTO="${1:-Nova-Gorica}"               # kraj podamo kot argument; privzeto Nova-Gorica
DANES=$(date +%F)                       # danasnji datum, npr. 2026-09-15
DB="vreme.db"


IFS='|' read -r TEMP VLAGA < <(
  sqlite3 "$DB" "SELECT temperatura,vlaga FROM trenutno
                 WHERE mesto='$MESTO'
                 AND pobrano_ob=(SELECT MAX(pobrano_ob) FROM trenutno);" | tr -d '\r')

# --- danasnja napoved (najnizja/najvisja temp, padavine) ---
IFS='|' read -r TMAX TMIN PAD < <(
  sqlite3 "$DB" "SELECT tmax,tmin,padavine FROM napoved
                 WHERE mesto='$MESTO' AND datum='$DANES'
                 AND pobrano_ob=(SELECT MAX(pobrano_ob) FROM napoved);" | tr -d '\r')

echo "  Kraj: $MESTO"
echo "  Temperatura: ${TEMP} C"
echo "  Vlaga: ${VLAGA} %"
echo "  Danes: ${TMIN}-${TMAX} C"
echo "  Padavine: ${PAD} mm"

###########2. DEL skripta iz baze pove, kaj obleči in ali rabiš dežnik.

# --- kaj obleci: odlocamo po NAJNIZJI napovedani temperaturi (TMIN) ---
T=${TMIN%.*}                            # odrezi decimalke: "7.0" -> "7" (za primerjavo s cela stevila)
if   [ "$T" -lt 0 ];  then OBLEKA="zimska bunda, kapa in rokavice"
elif [ "$T" -lt 10 ]; then OBLEKA="topla jakna in dolge hlace"
elif [ "$T" -lt 18 ]; then OBLEKA="pulover ali lahka jakna"
elif [ "$T" -lt 25 ]; then OBLEKA="majica, zjutraj morda pulover"
else                       OBLEKA="kratke hlace in majica"
fi

# --- deznik? padavine so decimalne (mm), zato primerjamo z awk ---
# awk "BEGIN{exit !(pogoj)}" vrne izhodno kodo 0, ce pogoj drzi.
if awk "BEGIN{exit !($PAD > 1)}"; then DEZNIK="DA, vzemi deznik ($PAD mm)"
else                                    DEZNIK="ni treba (${PAD} mm)"
fi  


echo "  Obleci: $OBLEKA"
echo "  Deznik: $DEZNIK"
