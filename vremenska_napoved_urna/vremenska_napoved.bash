#!/bin/bash
set -u
api="https://api.open-meteo.com/v1/forecast"
danes=$(date +%F)
arhiv="arhiv/$danes"
mkdir -p "$arhiv"
while IFS=";" read -r mesto sirina dolzina
do
url="$api?latitude=$sirina&longitude=$dolzina&hourly=temperature_2m"
echo "$url"
if ! curl -sS --fail --max-time 20 -o "$arhiv/$mesto.json" "$url"; then
echo "napaka" >&2
continue
fi
jq -r --arg m "$mesto" '.hourly | [.time, .temperature_2m] | transpose[] | [$m] + . | @csv' "$arhiv/$mesto.json" >> urno_vreme.csv
done < mesta.txt
