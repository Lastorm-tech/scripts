#!/usr/bin/env bash
#rt1

rm work.txt;

#locc stand for : line of code counter
NLINE_GLOBAL=1;

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

for i in $(find . -type f -name '*.c' -print0 | while IFS= read -r -d '' file; do printf '%s\n' "$file"; done)
do
   NTMP=$(wc -l "$i"| cut -f1 -d' ')
   NLINE_GLOBAL=$((NLINE_GLOBAL+NTMP))
   wc -l "$i" >> work.txt;
done

NELEM_GLOBAL="$(wc -l work.txt | cut -f1 -d' ')"
clear;

echo -e "La moyenne pour : "${PWD##*/}" est de : ${RED}"$((NLINE_GLOBAL/NELEM_GLOBAL))"${NC}"
echo -e "Moyenne definie sur : ${GREEN}"$NELEM_GLOBAL"${NC} fichier de type *.c pour un total de ${GREEN}"$NLINE_GLOBAL"${NC} ligne de code."
