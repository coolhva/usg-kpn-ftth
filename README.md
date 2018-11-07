# Ubiquity USG with KPN FTTH, IPTV and IPv6
This repo contains the files you need to succesfully configure the USG with KPN FTTH with IPTV and IPv6 enabled.

1. Place **config.gateway.json** at the unifi controller (*sites/default*) via SCP

   The config.gateway.json contains the main configuration with the different interfaces which are needed for internet (vlan 6) and IPTV (vlan 4). IPv4 is configured via PPPoE with the kpn/kpn username and password. KPN uses a TAG which is configured in the DSLAM to identify your connection and to give you your "permanent" public IPv4 address.

2. Place **dhcp_exit_hook.sh** in */etc/dhcp3/dhclient-exit-hooks.d/* via SCP
3. Execute `chmod +x /etc/dhcp3/dhclient-exit-hooks.d/dhcp_exit_hook.sh` on the USG

 KPN sends static routes via DHCP which the USG does not install by default. This script will install the DHCP routes when a DHCP lease is received. The chmod +x command allows the script to be executed. ([source](https://community.ubnt.com/t5/EdgeRouter/DHCP-CLIENT-OPTION-121-not-updates-routes-table/m-p/2506090/highlight/true#M223160))

4. Place **dhcp6.sh** in */config/scripts/post-config.d/* via SCP
5. Execute `chmod +x /config/scripts/post-config.d/dhcp6.sh` on the USG

 IPv6 works natively in the USG, the problem with KPN is that the json nesting will go too deep (interface, vlan and pppoe) and the USG will hit a bug ([source](https://community.ubnt.com/t5/UniFi-Routing-Switching/Configuration-commit-errors-IPv6-PPPoE-invalid-prefix-ID-value/td-p/2461935)) when it tries to parse the json. To overcome this, after 2 minutes the USG will execute this script which will configure IPv6 on the PPPoE interface and will remove the task from the taskscheduler.

6. The lan network (and portfowarding if needed) needs to be configured in the Unifi controller
7. Go to the USG in devices in the controller and force provisioning

After provisioning please reboot the USG. After two minutes IPv6 will be enabled. This can be checked by executing `show interfaces` on the USG.

The PPPOE interface has no "public" IPv6 address because it uses the link local IPv6 address to route traffic to KPN. To see the remote address execute the following command ([source](https://community.ubnt.com/t5/EdgeRouter/EdgeRouter-X-PPPoE-IPv6/td-p/1893221)):
```
show interfaces pppoe pppoe2 log | match "IPV6|LL"
```
