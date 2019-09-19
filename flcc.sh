#!/usr/bin/env bash
#rt1

rm work.txt;

#fcc stand for : function library code counter
NFUNC_GLOBAL=1;

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

#for i in $(find . -type f -name '*.o' -print0 | while IFS= read -r -d '' file; do printf '%s\n' "$file"; done)
for i in $(find . -type f -executable -print0 | while IFS= read -r -d '' file; do printf '%s\n' "$file"; done)
do
   NTMP=$(nm $i | grep "T " | grep -v " _" | wc -l)
   NFUNC_GLOBAL=$((NFUNC_GLOBAL+NTMP))
   nm $i | grep "T " | grep -v " _" | wc -l >> work.txt;
done

NELEM_GLOBAL="$(wc -l work.txt | cut -f1 -d' ')"
clear;

echo -e "La moyenne pour : "${PWD##*/}" est de : ${RED}"$((NFUNC_GLOBAL/NELEM_GLOBAL))"${NC}"
echo -e "Moyenne definie sur : ${GREEN}"$NELEM_GLOBAL"${NC} fichier de type executable pour un total de ${GREEN}"$NFUNC_GLOBAL"${NC} fonction."
