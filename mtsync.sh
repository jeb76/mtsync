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
                echo -e "\n${LIGHTRED}File $CONFIGFILE does not exist! Please provide the required config file${NC}"
                echo -e "\nFile $CONFIGFILE does not exist! Please provide the required config file" 2>&1 >>$LOGFILE
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
echo "TEMPDIR=$TEMPDIR"
echo "LOGDIR=$LOGDIR"
echo "LOGFILE=$LOGFILE"

# Check log dir
if [ ! -d "$LOGDIR" ]
        then
                mkdir -p $LOGDIR
                if [ ! $? -eq 0 ]; then
                        echo -e "\n${LIGHTRED}Directory $LOGDIR not exists and can not create it!${NC}"
                        echo -e "\nDirectory $LOGDIR not exists and can not create it!" 2>&1 >> $LOGFILE
                        exit 1
                fi
fi

# Check temp dir
if [ ! -d "$TEMPDIR" ]
        then
                mkdir -p $TEMPDIR
                if [ ! $? -eq 0 ]; then
                        echo -e "\n${LIGHTRED}Directory $TEMPDIR not exists and can not create it!${NC}"
                        echo -e "\nDirectory $TEMPDIR not exists and can not create it!" 2>&1 >> $LOGFILE
                        exit 1
                fi
fi

# Check sshpass
if (which sshpass> /dev/null 2>&1)
        then
                echo -e "\n${LIGHTGREEN}sshpass OK${NC}"
        else
                echo -e "\n${LIGHTRED}sshpass is not installed! Please install it to run $0${NC}"
                echo -e "\nsshpass is not installed! Please install it to run $0" 2>&1 >> $LOGFILE
fi

##### Default mode #####

# Connection and export creation
#sshpass -p $ADMINPASS ssh $ADMINUSER@$IPMTMAIN -p $SSHPORT -o StrictHostKeyChecking=no "/export compact file=$EXPORTFILEMTMAIN" 2>&1 |tee -a $LOGFILE
#sshpass -p $ADMINPASS ssh $ADMINUSER@$IPMTMAIN -p $SSHPORT -o StrictHostKeyChecking=no "/export compact file=$EXPORTFILEMTBKP" 2>&1 |tee -a $LOGFILE

# Download export via ftp
#wget -N -nv -P $TEMPDIR/ ftp://$IPMTMAIN:$FTPPORT/$EXPORTFILEMTMAIN.rsc --ftp-user=$FTPUSER --ftp-password=$FTPPASS 2>&1 |tee -a $LOGFILE
#wget -N -nv -P $TEMPDIR/ ftp://$IPMTMAIN:$FTPPORT/$EXPORTFILEMTBKP.rsc --ftp-user=$FTPUSER --ftp-password=$FTPPASS 2>&1 |tee -a $LOGFILE

### Exports comparison
# Get all modules from exports
egrep -o '^/.*' $TEMPDIR/$EXPORTFILEMTMAIN.rsc >$TEMPDIR/modules_mtmain.txt
egrep -o '^/.*' $TEMPDIR/$EXPORTFILEMTBKP.rsc >$TEMPDIR/modules_mtbkp.txt

# Modules only in mt bkp
grep -Fxvf $TEMPDIR/modules_mtmain.txt $TEMPDIR/modules_mtbkp.txt >$TEMPDIR/modules_mtbkp_only.txt

# for MODULE in $TEMPDIR/modules_mtbkp_only.txt
# do
# sed to insert remove [find] under module name

#awk "f && /^\//{exit} /^\/interface bridge/{f=1} f" $EXPORTFILEMTMAIN.rsc

exit 0
