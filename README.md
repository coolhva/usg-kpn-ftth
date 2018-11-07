# Ubiqity USG with KPN FTTH, IPTV and IPv6
This repo contains the files you need to succesfully configure the USG with KPN FTTH with IPTV and IPv6 enabled.

1. Place config.gateway.json at the unifi controller (sites/default)
2. Place dhcp_exit_hook.sh in /etc/dhcp3/dhclient-exit-hooks.d/routes/
3. Execute `chmod +x /etc/dhcp3/dhclient-exit-hooks.d/routes/dhcp_exit_hook.sh` on the USG
4. Place dhcp6.sh in /config/scripts/post-config.d/
5. Execute `chmod +x /config/scripts/post-config.d/dhcp6.sh`

The lan network needs to be configured in the Unifi controller

After provisioning please reboot the USG. After two minutes IPv6 will be enabled. This can be checked by executing `show interfaces` on the USG.

The PPPOE interfaces has no "public" IPv6 address because it uses the link local IPv6 address to route traffic to KPN. To see the remote address execute the following command:
```
show interfaces pppoe pppoe2 log | match "IPV6|LL"
```
[source](https://community.ubnt.com/t5/EdgeRouter/EdgeRouter-X-PPPoE-IPv6/td-p/1893221)