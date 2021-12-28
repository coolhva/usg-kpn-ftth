#!/bin/vbash
#############################################################################
#                                                                           #
#  :::    ::: :::::::::  ::::    :::      :::    :::  ::::::::   ::::::::   #
#  :+:   :+:  :+:    :+: :+:+:   :+:      :+:    :+: :+:    :+: :+:    :+:  #
#  +:+  +:+   +:+    +:+ :+:+:+  +:+      +:+    +:+ +:+        +:+         #
#  +#++:++    +#++:++#+  +#+ +:+ +#+      +#+    +:+ +#++:++#++ :#:         #
#  +#+  +#+   +#+        +#+  +#+#+#      +#+    +#+        +#+ +#+   +#+#  #
#  #+#   #+#  #+#        #+#   #+#+#      #+#    #+# #+#    #+# #+#    #+#  #
#  ###    ### ###        ###    ####       ########   ########   ########   #
#                                                                           #
#############################################################################
# Author      : Henk van Achterberg (coolhva)                               #
# GitHub      : https://github.com/coolhva/usg-kpn-ftth/                    #
# Version     : 0.4 (BETA)                                                  #
#---------------------------------------------------------------------------#
# Description :                                                             #
#                                                                           #
# This file does the following things:                                      #
#   1. Creates the dhcp exit hook, needed to install the kernel route to    #
#      the IPTV platform of KPN.                                            #
#   2. Creates a post-config hook to run this file after a config commit    #
#   3. Checks and fixes the correct MTU on interface eth2 and eth2 vif 6    #
#   4. Checks and fixes the correct L2TP VPN configuration, if applicable   #
#---------------------------------------------------------------------------#
# Installation :                                                            #
#                                                                           #
# Place this file at /config/scripts/post-config.d/kpn.sh and make it       #
# executable (chmod +x /config/scripts/post-config.d/kpn.sh).               #
#############################################################################

readonly logFile="/var/log/kpn.log"

echo "[$(date)] [kpn.sh] Executed at $(date)" >> ${logFile}

  # Check for lock file and exit if it is present
  if [ -f "/config/scripts/post-config.d/kpn.lock" ]; then
  
  # Calculate seconds between creation of the kpn.lock file and now
  timeDelta=$(expr $(date +%s) - $(stat -c %Y /config/scripts/post-config.d/kpn.lock))
  
  # Check if lock file is old enough to remove and continue the script
  if [ $timeDelta -gt 120 ]; then
    echo "[$(date)] [kpn.sh] lock file exists but is older then 120 seconds, removing lock file" >> ${logFile}
    rm /config/scripts/post-config.d/kpn.lock
  else
    echo "[$(date)] [kpn.sh] lock file /config/scripts/post-config.d/kpn.lock exists, stopping execution" >> ${logFile}
    exit
  fi

fi

# Create lock file so kpn.sh will not execute simultaniously
echo "[$(date)] kpn.sh] creating lock file at /config/scripts/post-config.d/kpn.lock" >> ${logFile}
touch /config/scripts/post-config.d/kpn.lock

# Check if the dhcp hook exists, this will run after retrieving a dhcp lease
if [ ! -f "/etc/dhcp3/dhclient-exit-hooks.d/routes" ]; then
echo "[$(date)] [kpn.sh] routes dhcp hook does not exist" >> ${logFile}

# Read the routes file (base64 encoded) in to the ROUTES variable
read -r -d '' ROUTES <<- EndOfFile
IyBzZXQgY2xhc3NsZXNzIHJvdXRlcyBiYXNlZCBvbiB0aGUgZm9ybWF0IHNwZWNpZmllZCBpbiBS
RkMzNDQyCiMgZS5nLjoKIyAgIG5ld19yZmMzNDQyX2NsYXNzbGVzc19zdGF0aWNfcm91dGVzPScy
NCAxOTIgMTY4IDEwIDE5MiAxNjggMSAxIDggMTAgMTAgMTcgNjYgNDEnCiMgc3BlY2lmaWVzIHRo
ZSByb3V0ZXM6CiMgICAxOTIuMTY4LjEwLjAvMjQgdmlhIDE5Mi4xNjguMS4xCiMgICAxMC4wLjAu
MC84IHZpYSAxMC4xNy42Ni40MQojCiMvZXRjL2RoY3AzL2RoY2xpZW50LWV4aXQtaG9va3MuZC9y
b3V0ZXMKClJVTj0ieWVzIgoKCmlmIFsgIiRSVU4iID0gInllcyIgXTsgdGhlbgoJaWYgWyAtbiAi
JG5ld19yZmMzNDQyX2NsYXNzbGVzc19zdGF0aWNfcm91dGVzIiBdOyB0aGVuCgkJaWYgWyAiJHJl
YXNvbiIgPSAiQk9VTkQiIF0gfHwgWyAiJHJlYXNvbiIgPSAiUkVCT09UIiBdOyB0aGVuCgoJCQlz
ZXQgLS0gJG5ld19yZmMzNDQyX2NsYXNzbGVzc19zdGF0aWNfcm91dGVzCgoJCQl3aGlsZSBbICQj
IC1ndCAwIF07IGRvCgkJCQluZXRfbGVuZ3RoPSQxCgkJCQl2aWFfYXJnPScnCgoJCQkJY2FzZSAk
bmV0X2xlbmd0aCBpbgoJCQkJCTMyfDMxfDMwfDI5fDI4fDI3fDI2fDI1KQoJCQkJCQluZXRfYWRk
cmVzcz0iJHsyfS4kezN9LiR7NH0uJHs1fSIKCQkJCQkJZ2F0ZXdheT0iJHs2fS4kezd9LiR7OH0u
JHs5fSIKCQkJCQkJc2hpZnQgOQoJCQkJCQk7OwoJCQkJCTI0fDIzfDIyfDIxfDIwfDE5fDE4fDE3
KQoJCQkJCQluZXRfYWRkcmVzcz0iJHsyfS4kezN9LiR7NH0uMCIKCQkJCQkJZ2F0ZXdheT0iJHs1
fS4kezZ9LiR7N30uJHs4fSIKCQkJCQkJc2hpZnQgOAoJCQkJCQk7OwoJCQkJCTE2fDE1fDE0fDEz
fDEyfDExfDEwfDkpCgkJCQkJCW5ldF9hZGRyZXNzPSIkezJ9LiR7M30uMC4wIgoJCQkJCQlnYXRl
d2F5PSIkezR9LiR7NX0uJHs2fS4kezd9IgoJCQkJCQlzaGlmdCA3CgkJCQkJCTs7CgkJCQkJOHw3
fDZ8NXw0fDN8MnwxKQoJCQkJCQluZXRfYWRkcmVzcz0iJHsyfS4wLjAuMCIKCQkJCQkJZ2F0ZXdh
eT0iJHszfS4kezR9LiR7NX0uJHs2fSIKCQkJCQkJc2hpZnQgNgoJCQkJCQk7OwoJCQkJCTApCSMg
ZGVmYXVsdCByb3V0ZQoJCQkJCQluZXRfYWRkcmVzcz0iMC4wLjAuMCIKCQkJCQkJZ2F0ZXdheT0i
JHsyfS4kezN9LiR7NH0uJHs1fSIKCQkJCQkJc2hpZnQgNQoJCQkJCQk7OwoJCQkJCSopCSMgZXJy
b3IKCQkJCQkJcmV0dXJuIDEKCQkJCQkJOzsKCQkJCWVzYWMKCgkJCQkjIHRha2UgY2FyZSBvZiBs
aW5rLWxvY2FsIHJvdXRlcwoJCQkJaWYgWyAiJHtnYXRld2F5fSIgIT0gJzAuMC4wLjAnIF07IHRo
ZW4KCQkJCQl2aWFfYXJnPSJ2aWEgJHtnYXRld2F5fSIKCQkJCWZpCgoJCQkJIyBzZXQgcm91dGUg
KGlwIGRldGVjdHMgaG9zdCByb3V0ZXMgYXV0b21hdGljYWxseSkKCQkJCWlwIC00IHJvdXRlIGFk
ZCAiJHtuZXRfYWRkcmVzc30vJHtuZXRfbGVuZ3RofSIgJHt2aWFfYXJnfSBkZXYgIiR7aW50ZXJm
YWNlfSIgPi9kZXYvbnVsbCAyPiYxCgkJCWRvbmUKCQlmaQoJZmkKZmk=
EndOfFile

echo "[$(date)] [kpn.sh] Creating dhcp hook at /etc/dhcp3/dhclient-exit-hooks.d/routes" >> ${logFile}
# Decode the base64 ROUTES HOOK variable and post the output to routes
echo "$ROUTES" | base64 -d > /etc/dhcp3/dhclient-exit-hooks.d/routes
# Make set-kpn-hook.sh executable
chmod +x /etc/dhcp3/dhclient-exit-hooks.d/routes
# Release the dhcp lease on the IPTV interface
echo "[$(date)] [kpn.sh] Release dhcp interface eth2.4" >> ${logFile}
/opt/vyatta/bin/vyatta-op-cmd-wrapper release dhcp interface eth2.4 >> ${logFile}
# Request a new lease on the IPTV interface (routes hook wil run)
echo "[$(date)] [kpn.sh] Renew dhcp interface eth2.4" >> ${logFile}
/opt/vyatta/bin/vyatta-op-cmd-wrapper renew dhcp interface eth2.4 >> ${logFile}
# Upstream routes are now in place, restarting igmp proxy to pick up the changes
echo "[$(date)] [kpn.sh] Restarting IGMP proxy" >> ${logFile}
/opt/vyatta/bin/vyatta-op-cmd-wrapper restart igmp-proxy >> ${logFile}
fi

# Check if the post-config hook exists, this will run after a succesful commit
if [ ! -f "/etc/commit/post-hooks.d/set-kpn-hook.sh" ]; then
echo "[$(date)] [kpn.sh] The file /etc/commit/post-hooks.d/set-kpn-hook.sh does not exists, creating hook now" >> ${logFile}

# Read the set-kpn-hook.sh file (base64 encoded) in to the HOOK variable
read -r -d '' HOOK <<- EndOfFile
IyEvYmluL3ZiYXNoCnJlYWRvbmx5IGxvZ0ZpbGU9Ii92YXIvbG9nL2twbi5sb2ci
CgplY2hvICJbJChkYXRlKV0gW3NldC1rcG4taG9vay5zaF0gRXhlY3V0ZWQgYXQg
JChkYXRlKSIgPj4gJHtsb2dGaWxlfQplY2hvICJbJChkYXRlKV0gW3NldC1rcG4t
aG9vay5zaF0gQ29uZmlndXJhdGlvbiBjaGFuZ2VzIGhhdmUgYmVlbiBjb21taXRl
ZCwgYWRkaW5nIGNyb250YWIgZm9yIGtwbi5zaCIgPj4gJHtsb2dGaWxlfQplY2hv
ICIqICAgICogICAgKiAgICAqICAgICogICAgcm9vdCAgICAvY29uZmlnL3Njcmlw
dHMvcG9zdC1jb25maWcuZC9rcG4uc2giID4gL2V0Yy9jcm9uLmQva3Bu
EndOfFile

# Decode the base64 encoded HOOK variable and post the output to set-kpn-hook.sh
echo "$HOOK" | base64 -d > /etc/commit/post-hooks.d/set-kpn-hook.sh
# Make set-kpn-hook.sh executable
chmod +x /etc/commit/post-hooks.d/set-kpn-hook.sh
fi

# Delete the kpn crontab file, if exists, to avoid runnig this file every minute
if [ -f "/etc/cron.d/kpn" ]; then
echo "[$(date)] [kpn.sh] KPN found in crontab, removing /etc/cron.d/kpn" >> ${logFile}
    rm /etc/cron.d/kpn
fi

# Load environment variables to be able to configure the USG via this script
source /opt/vyatta/etc/functions/script-template

# Check if the mtu is set for eth2, if not, set the value for eth2 and vif 6
if [ ! $(cli-shell-api returnActiveValue interfaces ethernet eth2 mtu) ]; then
    echo "[$(date)] [kpn.sh] MTU for eth2 not configured, adjusting config" >> ${logFile}
    echo "[$(date)] [kpn.sh] Disconnecting pppoe2 before changing MTU" >> ${logFile}
    /opt/vyatta/bin/vyatta-op-cmd-wrapper disconnect interface pppoe2 >> ${logFile}
    configure >> ${logFile}
    echo "[$(date)] [kpn.sh] Setting mtu for eth2 to 1512" >> ${logFile}
    set interfaces ethernet eth2 mtu 1512 >> ${logFile}
    echo "[$(date)] [kpn.sh] Setting mtu for eth2 vif 6 to 1508" >> ${logFile}
    set interfaces ethernet eth2 vif 6 mtu 1508 >> ${logFile}
    echo "[$(date)] [kpn.sh] Commiting" >> ${logFile}
    commit
    echo "[$(date)] [kpn.sh] Connecting pppoe2 after changing MTU" >> ${logFile}
    /opt/vyatta/bin/vyatta-op-cmd-wrapper connect interface pppoe2 >> ${logFile}
    # This will remove the lock file and exit the bash script, and via the commit hook will run this script again.
    echo "[$(date)] [kpn.sh] removing lock file at /config/scripts/post-config.d/kpn.lock" >> ${logFile}
    rm /config/scripts/post-config.d/kpn.lock
    exit
fi

# Check if the dhcp-interface is set for the l2tp vpn, if so remove it and add outside-address
if [ $(cli-shell-api returnActiveValue vpn l2tp remote-access dhcp-interface) ]; then
  readonly dhcpint=$(cli-shell-api returnActiveValue vpn l2tp remote-access dhcp-interface)
  echo "[$(date)] [kpn.sh] Config value $dhcpint for vpn l2tp remote-access dhcp-interface found, adjusting config" >> ${logFile}
  configure >> ${logFile}
  echo "[$(date)] [kpn.sh] Setting ipsec-interface to pppoe2" >> ${logFile}
  set vpn ipsec ipsec-interfaces interface pppoe2 >> ${logFile}
  echo "[$(date)] [kpn.sh] Deleting dhcp interface $dhcpint" >> ${logFile}
  delete vpn l2tp remote-access dhcp-interface $dhcpint >> ${logFile}
  echo "[$(date)] [kpn.sh] Setting outside-address to 0.0.0.0" >> ${logFile}
  set vpn l2tp remote-access outside-address 0.0.0.0 >> ${logFile}
  echo "[$(date)] [kpn.sh] Commiting" >> ${logFile}
  commit
  # This will remove the lock file and exit the bash script, and via the commit hook will run this script again.
  echo "[$(date)] [kpn.sh] removing lock file at /config/scripts/post-config.d/kpn.lock" >> ${logFile}
  rm /config/scripts/post-config.d/kpn.lock
  exit
fi

# removing lock file and finish execution
echo "[$(date)] [kpn.sh] removing lock file at /config/scripts/post-config.d/kpn.lock" >> ${logFile}
rm /config/scripts/post-config.d/kpn.lock
echo "[$(date)] [kpn.sh] Finished" >> ${logFile}