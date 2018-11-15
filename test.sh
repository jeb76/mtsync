#!/bin/bash

# Elimino /nombre_modulo, dejo lineas completas sin contrabarras
grep -v "\/" tmp/ip_pool_mtmain.rsc |sed ':a;$!N;s/\\\s*\n\s*/ /;ta;P;D' >tmp/tmp1
#|tr ' ' '\n' |egrep -v "^$|add" >tmp/tmp1
#| awk '{print NR, "\t", $0}'
grep -v "\/" tmp/ip_pool_mtbkp.rsc |sed ':a;$!N;s/\\\s*\n\s*/ /;ta;P;D' >tmp/tmp2
#|tr ' ' '\n' |egrep -v "^$|add" >tmp/tmp2

# Elimino lineas iguales y dejo solo las que existan en el mtmain
grep -Fxvf tmp/tmp2 tmp/tmp1 >tmp/tmp3

#cat tmp/tmp3

# La lagica funciona bien para objetos que tienen el mismo "name" en 
# ambos export y requiere un "set" en vez de "add" en el export bkp.
# Todavia no funciona si hay un cambio de "name" en algun objeto que
# ya existia.

# Paso cadenas entre espacios en lineas diferentes y comparo
while read LINE; do
	OBJECTNAME=$(echo $LINE| egrep -o '\sname=\w{1,}' |sed -e 's/^\s//g')
	#echo "OBJECTNAME=$OBJECTNAME"
	if [ ! -z $OBJECTNAME ]
		then
			# Busco una linea con el OBJECTNAME en mt bkp
			OBJECTNAMEINBKP=$(grep -o $OBJECTNAME tmp/tmp2)
			#echo "OBJECTNAMEINBKP=$OBJECTNAMEINBKP"
			if [ ! -z $OBJECTNAMEINBKP ]
				then
					# Paso cadenas entre espacios en lineas diferentes
					grep $OBJECTNAME tmp/tmp2 |tr ' ' '\n' |egrep -v "^$|add" >tmp/tmp5
					echo $LINE |tr ' ' '\n' |egrep -v "^$|add|^[0-9]+\s{1,}" >tmp/tmp4
					# Elimino lineas iguales y dejo solo las que estan en el mtmain
					grep -Fxvf tmp/tmp5 tmp/tmp4 >tmp/tmp6
					# Dejo en una sola linea los strings que coinciden
					SAMESTRINGS=$(grep -Fxf tmp/tmp4 tmp/tmp5 |tr '\n' ' ' |tr '\r' ' ')
					#echo "DIFFSTRINGS=$(cat tmp/tmp6)"
					#echo "SAMESTRINGS=$SAMESTRINGS"
					while read STRING; do
						echo "set [ find where $SAMESTRINGS] $STRING"
					done <tmp/tmp6
				else
					echo $LINE
			fi
		else
			echo $LINE
	fi
done <tmp/tmp3



