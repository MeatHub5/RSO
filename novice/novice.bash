#!bin/bash
vir="https://img.rtvslo.si/feeds/03.xml"
curl -sS --fail --max-time 15 "$vir" 2>/dev/null \
| grep -oP '(?<=<title>).*?(?=</title>)' \
| tail -n +2 \
| head -n 10 \
| sed 's/^/  * /'
