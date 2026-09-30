
#!bin/bash
set -u
MESTO="${1:-Nova-Gorica}"
IZHOD="/c/RSO/briefing.html"
VREME=$(/c/RSO/Vreme/nasvet.bash "$MESTO")
NOVICE=$(/c/RSO//novice/novice.bash 2>/dev/null)
OBLEKA=$(printf 's\n' "$VREME" | sed -n 's/^Obleci: //p')
DEZNIK=$(printf 's\n' "$VREME" | sed -n 's/^Deznik: //p')
TEMP=$(printf "$VREME" | sed -n 's/^Temperatura: //p')
VLAGA=$(printf "$VREME" | sed -n 's/^Vlaga: //p')
DANES=$(printf "$VREME" | sed -n 's/^Danes: //p')
HTML_NOVICE=$(echo "$NOVICE" | sed 's/^[[:space:]]*\*[[:space:]]*/<li>/; s/$/<\/li>/')
cat > "$IZHOD" <<HTML
<!DOCTYPE html>
<html>
<head>
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


