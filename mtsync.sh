#!/bin/bash
# Descarga y compara configuraciones de 2 routers Mikrotik
# Variables
IPMTMAIN="172.31.255.2"
IPMTBKP="172.31.255.2"
SSHPORT="22"
ADMINUSER="admin"
ADMINPASS=""
FTPUSER="ftp"
FTPPASS=""
TEMPDIR="/root/scripts/mtsync/tmp"
EXPORTFILEMTMAIN="export_mtmain.rsc"
EXPORTFILEMTBKP="export_mtbkp.rsc"
LOGDIR="/root/scripts/mtsync/log"
LOGFILE="$LOGDIR/$0.log"

# Fin variables

# Verifico si esta instalado sshpass
if (which sshpass> /dev/null 2>&1)
	then
		echo "sshpass OK."
		echo ""
	else
		echo "sshpass no esta instalado! Instalelo para poder ejecutar $0."
		echo ""
fi

# Me conecto y creo los exports
sshpass -p $ADMINPASS ssh $ADMINUSER@$IPMTMAIN -p $SSHPORT -o StrictHostKeyChecking=no '/export compact file=export_mtmain' 2>&1 |tee -a $LOGFILE
sshpass -p $ADMINPASS ssh $ADMINUSER@$IPMTMAIN -p $SSHPORT -o StrictHostKeyChecking=no '/export compact file=export_mtbkp' 2>&1 |tee -a $LOGFILE

# Descargo los exports
wget -N -nv -P $TEMPDIR/ ftp://$IPMTMAIN:21/$EXPORTFILEMTMAIN --ftp-user=$FTPUSER --ftp-password=$FTPPASS 2>&1 |tee -a $LOGFILE
wget -N -nv -P $TEMPDIR/ ftp://$IPMTMAIN:21/$EXPORTFILEMTBKP --ftp-user=$FTPUSER --ftp-password=$FTPPASS 2>&1 |tee -a $LOGFILE

exit 0
