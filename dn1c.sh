#!/bin/bash

if [ ! $# -eq 2  ] || [ $1 -lt 1 ] || [ $2 -lt 1 ]; then
   echo "Potrebno je vnesti veljavne vrstice in stolpce!"
   exit 1;
fi
row=$(( $RANDOM % $1+1))
column=$(( $RANDOM % $2+1))

echo "Pred tablo gre prisilni prostovoljec, ki sedi v vrsti $row in stolpcu $column."
exit 0



