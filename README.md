# Ubiquity USG with KPN FTTH, IPTV and IPv6
This repo contains the files you need to succesfully configure the USG with KPN FTTH with IPTV and IPv6 enabled.

1. Place **config.gateway.json** at the unifi controller (*sites/default*) via SCP

   The config.gateway.json contains the main configuration with the different interfaces which are needed for internet (vlan 6) and IPTV (vlan 4). IPv4 is configured via PPPoE with the kpn/kpn username and password. KPN uses a TAG which is configured in the DSLAM to identify your connection and to give you your "permanent" public IPv4 address.

2. Place **routes** in */etc/dhcp3/dhclient-exit-hooks.d/* via SCP
3. Execute `sudo chmod +x /etc/dhcp3/dhclient-exit-hooks.d/routes` on the USG

   KPN sends static routes via DHCP which the USG does not install by default. This script will install the DHCP routes when a DHCP lease is received. The chmod +x command allows the script to be executed. ([source](https://community.ubnt.com/t5/EdgeRouter/DHCP-CLIENT-OPTION-121-not-updates-routes-table/m-p/2506090/highlight/true#M223160))

4. Place **dhcp6.sh** in */config/scripts/post-config.d/* via SCP
5. Execute `chmod +x /config/scripts/post-config.d/dhcp6.sh` on the USG

   IPv6 works natively in the USG, the problem with KPN is that the json nesting will go to deep (interface, vlan and pppoe) and the USG will hit a bug ([source](https://community.ubnt.com/t5/UniFi-Routing-Switching/Configuration-commit-errors-IPv6-PPPoE-invalid-prefix-ID-value/td-p/2461935)) when it tries to parse the json. To overcome this, after 2 minutes the USG will execute this script which will configure IPv6 on the PPPoE interface and will remove the task from the taskscheduler.

6. Place **setroutes.sh** in */config/scripts/post-config.d/* via SCP
7. Execute `chmod +x /config/scripts/post-config.d/setroutes.sh` on the USG

   After each firmware upgrade the routes file, used by the dhcp client at the exit hook (for the IPTV routes), is removed. To overcome this, after 2 minutes the USG will execute this script which will create the routes file, renews the DHCP lease, and remove the task from the taskscheduler.

8. The lan network (and portfowarding if needed) needs to be configured in the Unifi controller
9. Go to the USG in devices in the controller and force provisioning

After provisioning please reboot the USG. After two minutes IPv6 will be enabled. This can be checked by executing `show interfaces` on the USG.

The PPPOE interface has no "public" IPv6 address because it uses the link local IPv6 address to route traffic to KPN. To see the remote address execute the following command ([source](https://community.ubnt.com/t5/EdgeRouter/EdgeRouter-X-PPPoE-IPv6/td-p/1893221)):
```
show interfaces pppoe pppoe2 log | match "IPV6|LL"
```

XS4ALL (a Dutch ISP which uses the KPN platform has more information regarding the technical details), more info can be found [here](https://www.xs4all.nl/service/diensten/internet/installeren/modem-instellen/hoe-kan-ik-een-ander-modem-dan-fritzbox-instellen.htm)

This config.gateway.json has been tested on the following versions:

```
UniFi Security Gateway 3P: 4.4.44.5213844
Unifi Controller: 5.11.46 (Build: atag_5.11.46_12723)
```

My unifi WAN settings in the controller are as follows:

![unifiwan](https://raw.githubusercontent.com/coolhva/usg-kpn-ftth/master/unifi_wan.png)