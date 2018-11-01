#!/bin/bash
# Synchronize configs between Mikrotik routers
#
# Local variables
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
NC='\033[0m' #No color
CONFIGFILE=./mtsync.conf

# Get parameters
if [ ! -f "$CONFIGFILE" ]
	then
		MSG="File $CONFIGFILE does not exist! Please provide the required config file"
		echo -e "\n${LIGHTRED}$MSG${NC}\n"
		echo -e "\n$MSG\n" 2>&1 >>$LOGFILE
		exit 1
	else
		source $CONFIGFILE
fi

# Debug
echo "MODE=$MODE"
echo "IPMTMAIN=$IPMTMAIN"
echo "IPMTBKP=$IPMTBKP"
echo "SSHPORT=$SSHPORT"
echo "ADMINUSER=$ADMINUSER"
echo "ADMINPASS=$ADMINPASS"
echo "FTPPORT=$FTPPORT"
echo "FTPUSER=$FTPUSER"
echo "FTPPASS=$FTPPASS"
echo "EXPORTDIR=$EXPORTDIR"
echo "IMPORTDIR=$IMPORTDIR"
echo "TEMPDIR=$TEMPDIR"
echo "LOGDIR=$LOGDIR"
echo "LOGFILE=$LOGFILE"
echo ""

# Check dirs
declare -a DIRARRAY=("$LOGDIR" "$EXPORTDIR" "$IMPORTDIR" "$TEMPDIR")

for DIR in "${DIRARRAY[@]}"
do
	if [ ! -d "$DIR" ]
		then
			echo -e "Creating directory $DIR..."
			mkdir -p $DIR
			if [ ! $? -eq 0 ]
				then
					MSG="Directory $DIR not exists and can not create it!"
					echo -e "${LIGHTRED}$MSG${NC}"
					echo -e "$MSG" 2>&1 >> $LOGFILE
					exit 1
			fi
	fi
done

# Check sshpass
if (which sshpass> /dev/null 2>&1)
	then
		echo -e "${LIGHTGREEN}sshpass OK${NC}"
	else
		MSG="sshpass is not installed! Please install it to run $0"
		echo -e "${LIGHTRED}$MSG${NC}"
		echo -e "$MSG" 2>&1 >> $LOGFILE
		exit 1
fi

##### Default mode #####

# Connection and export creation
#sshpass -p $ADMINPASS ssh $ADMINUSER@$IPMTMAIN -p $SSHPORT -o StrictHostKeyChecking=no "/export compact file=$EXPORTFILEMTMAIN" 2>&1 |tee -a $LOGFILE
#sshpass -p $ADMINPASS ssh $ADMINUSER@$IPMTMAIN -p $SSHPORT -o StrictHostKeyChecking=no "/export compact file=$EXPORTFILEMTBKP" 2>&1 |tee -a $LOGFILE

# Download export via ftp
#wget -N -nv -P $IMPORTDIR/ ftp://$IPMTMAIN:$FTPPORT/$EXPORTFILEMTMAIN.rsc --ftp-user=$FTPUSER --ftp-password=$FTPPASS 2>&1 |tee -a $LOGFILE
#wget -N -nv -P $IMPORTDIR/ ftp://$IPMTMAIN:$FTPPORT/$EXPORTFILEMTBKP.rsc --ftp-user=$FTPUSER --ftp-password=$FTPPASS 2>&1 |tee -a $LOGFILE

### Exports comparison
# Get all modules from exports
if [ -s "$IMPORTDIR/$EXPORTFILEMTMAIN.rsc" ]
	then
		egrep -o '^/.*' $IMPORTDIR/$EXPORTFILEMTMAIN.rsc >$TEMPDIR/modules_mtmain.tmp
	else
		MSG="File $IMPORTDIR/$EXPORTFILEMTMAIN.rsc not exists or is not readeable! Aborting..."
		echo -e "${LIGHTRED}$MSG${NC}\n"
		echo -e "$MSG" 2>&1 >> $LOGFILE
		exit 2
fi

if [ -s "$IMPORTDIR/$EXPORTFILEMTBKP.rsc" ]
	then
		egrep -o '^/.*' $IMPORTDIR/$EXPORTFILEMTBKP.rsc >$TEMPDIR/modules_mtbkp.tmp
	else
		MSG="File $IMPORTDIR/$EXPORTFILEMTBKP.rsc not exists or is not readeable! Aborting..."
		echo -e "${LIGHTRED}$MSG${NC}\n"
		echo -e "$MSG" 2>&1 >> $LOGFILE
		exit 2
fi

# Modules only in mt bkp
grep -Fxvf $TEMPDIR/modules_mtmain.tmp $TEMPDIR/modules_mtbkp.tmp >$TEMPDIR/modules_mtbkp_only.tmp

# For every module only in mt bkp create an export file to remove it
if [ -s "$TEMPDIR/modules_mtbkp_only.tmp" ]
	then
		while read LINE; do
			echo "$LINE" |sed -e 's/^\/.*$/&\nremove \[find default=no\]/g' >>$EXPORTDIR/remove.auto.rsc
		done <$TEMPDIR/modules_mtbkp_only.tmp
fi

# For every module (Block of export script) of mt main compare with every module of mt main and generate an export file
# with differences

## Solucionar problema con sdiff
if [ -s "$TEMPDIR/modules_mtmain.tmp" ]
	then
		while read MODULE; do
			MODULEMTMAIN=$(echo $MODULE |sed -e 's/\///g' -e 's/\s/_/g' -e 's/$/_mtmain.rsc/g')
			MODULEMTBKP=$(echo $MODULE |sed -e 's/\///g' -e 's/\s/_/g' -e 's/$/_mtbkp.rsc/g')
			MODULEEXPORT=$(echo $MODULE |sed -e 's/\///g' -e 's/\s/_/g' -e 's/$/.auto.rsc/g')
			awk 'f && /^\//{exit} /^\'"$MODULE"'/{f=1} f' $IMPORTDIR/$EXPORTFILEMTMAIN.rsc >$TEMPDIR/$MODULEMTMAIN
			awk 'f && /^\//{exit} /^\'"$MODULE"'/{f=1} f' $IMPORTDIR/$EXPORTFILEMTBKP.rsc >$TEMPDIR/$MODULEMTBKP
			yes "1" |sdiff -sa $TEMPDIR/$MODULEMTMAIN $TEMPDIR/$MODULEMTBKP -o $MODULEEXPORT
			echo ""
			sleep 2s
		done <$TEMPDIR/modules_mtmain.tmp
fi

#awk "f && /^\//{exit} /^\/interface bridge/{f=1} f" $EXPORTFILEMTMAIN.rsc

exit 0
