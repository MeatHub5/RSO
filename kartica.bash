#!/bin/bash
set -u

MESTO="${1:-Nova-Gorica}"
IZHOD="/c/RSO/briefing.html"

# Zagon skripte za vreme (pazite, da je v nasvet.bash nastavljena absolutna pot do baze vreme.db)
VREME=$(/c/RSO/Vreme/nasvet.bash "$MESTO")
NOVICE=$(/c/RSO/novice/novice.bash 2>/dev/null)

# Popravljeno: Uporaba echo in prilagoditev za vodilne presledke iz nasvet.bash
TEMP=$(echo "$VREME" | sed -n 's/^[[:space:]]*Temperatura:[[:space:]]*//p')
VLAGA=$(echo "$VREME" | sed -n 's/^[[:space:]]*Vlaga:[[:space:]]*//p')
DANES=$(echo "$VREME" | sed -n 's/^[[:space:]]*Danes:[[:space:]]*//p')
OBLEKA=$(echo "$VREME" | sed -n 's/^[[:space:]]*Obleci:[[:space:]]*//p')
DEZNIK=$(echo "$VREME" | sed -n 's/^[[:space:]]*Deznik:[[:space:]]*//p')

# Pretvorba novic v HTML seznam <li>
HTML_NOVICE=$(echo "$NOVICE" | sed -E 's/^[[:space:]]*\*[[:space:]]*//; /^[[:space:]]*$/d; s/(.*)/<li>\1<\/li>/')

# Generiranje končne HTML datoteke
cat > "$IZHOD" <<HTML
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Vremensko poročilo za $MESTO</title>
</head>
<body>
    <h1>Vreme: $MESTO</h1>
    <p><b>Trenutno:</b> $TEMP (Vlaga: $VLAGA)</p>
    <p><b>Napoved za danes:</b> $DANES</p>
    <p><b>Kaj obleči:</b> $OBLEKA</p>
    <p><b>Dežnik:</b> $DEZNIK</p>
    
    <h2>Novice</h2>
    <ul>
        $HTML_NOVICE
    </ul>
</body>
</html>
HTML

echo "Poročilo je bilo uspešno ustvarjeno v: $IZHOD"
