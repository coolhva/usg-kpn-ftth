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
# Version     : 0.2 (ALPHA)                                                 #
#---------------------------------------------------------------------------#
# Description :                                                             #
#                                                                           #
# This file does the following things:                                      #
#   1. Creates the igmp proxy check crontab to run this script each minute. #
#   2. Check if igmpproxy is running, if not, execute restart igmp-proxy.   #
#---------------------------------------------------------------------------#
# Installation :                                                            #
#                                                                           #
# Place this file at /config/scripts/post-config.d/igmpproxy.sh and make it #
# executable (chmod +x /config/scripts/post-config.d/igmpproxy.sh).         #
#############################################################################

readonly logFile="/var/log/igmpproxy.log"

# Check if the post-config hook exists, this will run after a succesful commit
if [ ! -f "/etc/cron.d/igmpproxy" ]; then
echo "[$(date)] [igmpproxy.sh] The file /etc/cron.d/igmpproxy does not exists, creating crontab now" >> ${logFile}

# Create the crontab file
echo "*    *    *    *    *    root    /config/scripts/post-config.d/igmpproxy.sh" > /etc/cron.d/igmpproxy
fi

# Check if igmp proxy is running and restart if not.
if ! pidof igmpproxy >/dev/null 2>&1; then
echo "[$(date)] [igmpproxy.sh] IGMP Proxy not running" >> ${logFile}

# Restarting igmp proxy
echo "[$(date)] [igmpproxy.sh] Restarting IGMP proxy" >> ${logFile}
/opt/vyatta/bin/vyatta-op-cmd-wrapper restart igmp-proxy >> ${logFile}
fi