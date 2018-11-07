#!/bin/vbash

readonly logFile="/var/log/postprovision.log"

source /opt/vyatta/etc/functions/script-template

configure > ${logFile}

delete system task-scheduler task postprovision >> ${logFile}
set interfaces ethernet eth0 vif 6 pppoe 2 dhcpv6-pd no-dns >> ${logFile}
set interfaces ethernet eth0 vif 6 pppoe 2 dhcpv6-pd pd 0 interface eth1 prefix-id :1 >> ${logFile}
set interfaces ethernet eth0 vif 6 pppoe 2 dhcpv6-pd pd 0 interface eth1 service slaac >> ${logFile}
set interfaces ethernet eth0 vif 6 pppoe 2 dhcpv6-pd pd 0 prefix-length /48 >> ${logFile}
set interfaces ethernet eth0 vif 6 pppoe 2 dhcpv6-pd rapid-commit disable >> ${logFile}
commit
exit

