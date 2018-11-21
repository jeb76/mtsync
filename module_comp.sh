#!/bin/bash

# Funciona bien salvo cuando el comentario tiene una barra /

# Delete "/module name", one line without backslashes
grep -v "\/" $TEMPDIR/$MODULEMTMAIN |sed ':a;$!N;s/\\\s*\n\s*/ /;ta;P;D' >$TEMPDIR/tmp1
grep -v "\/" $TEMPDIR/$MODULEMTBKP |sed ':a;$!N;s/\\\s*\n\s*/ /;ta;P;D' >$TEMPDIR/tmp2

# Delete same lines, keep lines only in mtmain.
grep -Fxvf $TEMPDIR/tmp2 $TEMPDIR/tmp1 >$TEMPDIR/tmp3

# Delete same lines, keep lines only in mtbkp.
grep -Fxvf $TEMPDIR/tmp1 $TEMPDIR/tmp2  >$TEMPDIR/tmp4

echo ""
echo "mtmain only lines:"
cat $TEMPDIR/tmp3

echo ""
echo "mtbkp only lines:"
cat $TEMPDIR/tmp4
echo ""

if [ -s $TEMPDIR/tmp3 ] && [ -s $TEMPDIR/tmp4 ]
	then
		echo $MODULE >>$EXPORTDIR/update.auto.rsc
		# Convert lines in mtbkp only: remove [find where parametro=x parametro=y]
		while read LINE; do
			PARAMETERS=$(echo $LINE |sed -e 's/add\s//g' |tr '\n' ' ' |tr '\r' ' ')
			# Export to file
			echo "remove [find where $PARAMETERS]" |sed -e 's/\s\s]/]/g' >>$EXPORTDIR/update.auto.rsc
		done <$TEMPDIR/tmp4
		cat $TEMPDIR/tmp3 >>$EXPORTDIR/update.auto.rsc
		echo "Module $MODULE done"
		echo ""
fi

if [ ! -s $TEMPDIR/tmp3 ] && [ -s $TEMPDIR/tmp4 ]
	then
		echo $MODULE >>$EXPORTDIR/update.auto.rsc
		# Convert lines in mtbkp only: remove [find where parametro=x parametro=y]
		while read LINE; do
			PARAMETERS=$(echo $LINE |sed -e 's/add\s//g' |tr '\n' ' ' |tr '\r' ' ')
			# Export to file
			echo "remove [find where $PARAMETERS]" |sed -e 's/\s\s]/]/g' >>$EXPORTDIR/update.auto.rsc
		done <$TEMPDIR/tmp4
		echo "Module $MODULE done"
		echo ""
fi

if [ -s $TEMPDIR/tmp3 ] && [ ! -s $TEMPDIR/tmp4 ]
	then
		echo $MODULE >>$EXPORTDIR/update.auto.rsc
		cat $TEMPDIR/tmp3 >>$EXPORTDIR/update.auto.rsc
		echo "Module $MODULE done"
		echo ""
fi
