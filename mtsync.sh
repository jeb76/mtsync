#!/bin/bash
# Synchronize configs between Mikrotik routers
# Variables


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
