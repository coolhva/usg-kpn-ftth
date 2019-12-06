#!/bin/vbash

readonly logFile="/var/log/postprovisionoptimize.log"

source /opt/vyatta/etc/functions/script-template

configure > ${logFile}

delete system task-scheduler task postprovisionoptimize >> ${logFile}
set interfaces ethernet eth0 mtu 1512 
commit
set interfaces ethernet eth0 vif 6 mtu 1508
commit
set interfaces ethernet eth0 vif 6 pppoe 2 mtu 1500
commit
exit

