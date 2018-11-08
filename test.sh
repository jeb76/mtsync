#!/bin/bash

# Elimino /nombre_modulo, dejo lineas completas sin contrabarras, paso cadenas entre espacios en lineas diferentes
grep -v "\/" tmp/interface_bridge_mtmain.rsc |sed ':a;$!N;s/\\\s*\n\s*/ /;ta;P;D' |tr ' ' '\n' |egrep -v "^$|add" >tmp/tmp1
grep -v "\/" tmp/interface_bridge_mtbkp.rsc |sed ':a;$!N;s/\\\s*\n\s*/ /;ta;P;D' |tr ' ' '\n' |egrep -v "^$|add" >tmp/tmp2

# Elimino lineas iguales y dejo solo las que estan en el mtmain
grep -Fxvf tmp/tmp1 tmp/tmp2 >tmp/tmp3
SAMESTRINGS=$(grep -Fxf tmp/tmp1 tmp/tmp2 |tr '\n' ' ' |tr '\r' ' ')

#echo "DIFFSTRINGS=$(cat tmp/tmp3)"
#echo "SAMESTRINGS=$SAMESTRINGS"

while read STRING; do
        echo "set set set set [find where $SAMESTRINGS] $STRING" |fmt -w80
done <tmp/tmp3
