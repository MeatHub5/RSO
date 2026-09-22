#!/bin/bash
set -u
api="https://api.open-meteo.com/v1/forecast"
danes=$(date +%F)
arhiv="arhiv/$danes"
mkdir -p "$arhiv"
while IFS=";" read -r mesto sirina dolzina
do
url="$api?latitude=$sirina&longitude=$dolzina&current=temperature_2m&timezone=Europe%2FBerlin"
echo "$url"
if ! curl -sS --fail --max-time 20 -o "$arhiv/$mesto.json" "$url"; then
echo "napaka" >&2
continue
fi
jq -r --arg m "$mesto" '.current | [.time , .temperature_2m] | [$m] + . | @csv' "$arhiv/$mesto.json" >> trenutno_vreme.csv
done < mesta.txt
