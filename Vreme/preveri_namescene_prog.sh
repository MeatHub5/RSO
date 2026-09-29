#!/bin/bash
for p in curl jq sqlite3; do
  if command -v "$p" >/dev/null 2>&1; then
    echo "OK       $p"
  else
    echo "MANJKA   $p"
  fi
done