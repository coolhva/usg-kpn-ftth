# Ubiquiti USG with KPN FTTH, IPTV and IPv6
**USG PRO VERSION, WAN is ETH2 and LAN is ETH0, IPTV VLAN -> LAN is 661**

This repo contains the files you need to succesfully configure the USG with KPN FTTH with IPTV and IPv6 enabled.

Klik [hier](https://coolhva.github.io/usg-kpn-ftth/posts/unifi-security-gateway-kpn-ftth-iptv-ipv6/) voor een Nederlandse handleiding!

If you have X4ALL please click [here](https://github.com/coolhva/usg-kpn-ftth/tree/xs4all) to download the specific configuration for XS4ALL.

Please **[download a zip file](https://github.com/coolhva/usg-kpn-ftth/archive/master.zip)** with all the files and do not copy and paste the contents because of the UNIX file structure!

1. Place **config.gateway.json** at the unifi controller (*sites/default*) via SCP

   The config.gateway.json contains the main configuration with the different interfaces which are needed for internet (vlan 6) and IPTV (vlan 4). IPv4 is configured via PPPoE with the kpn/kpn username and password. KPN uses a TAG which is configured in the DSLAM to identify your connection and to give you your "permanent" public IPv4 address.

2. Place **kpn.sh** in */config/scripts/post-config.d/* via SCP
3. Execute `chmod +x /config/scripts/post-config.d/kpn.sh` on the USG

   After each firmware upgrade the routes file, used by the dhcp client at the exit hook (for the IPTV routes), is removed. To overcome this, after each upgrade the USG will execute this script which will create the routes file, renews the DHCP lease, restart the IGMP Proxy.

   KPN sends static routes via DHCP which the USG does not install by default. This script will install the DHCP routes when a DHCP lease is received. The chmod +x command allows the script to be executed. ([source](https://community.ubnt.com/t5/EdgeRouter/DHCP-CLIENT-OPTION-121-not-updates-routes-table/m-p/2506090/highlight/true#M223160))

4. The lan network (and portfowarding if needed) needs to be configured in the Unifi controller
5. Go to the USG in devices in the controller and force provisioning

After provisioning please reboot the USG. After two minutes IPv6 will be enabled. This can be checked by executing `show interfaces` on the USG. If IPTV does not work, please restart the USG again.

The PPPOE interface has no "public" IPv6 address because it uses the link local IPv6 address to route traffic to KPN. To see the remote address execute the following command ([source](https://community.ubnt.com/t5/EdgeRouter/EdgeRouter-X-PPPoE-IPv6/td-p/1893221)):
```
show interfaces pppoe pppoe2 log | match "IPV6|LL"
```

## VLANs

If you are using VLANs and have issues with the IPTV having hickups or being frozen you can try to change the config as follows:

At the "igmp-proxy" section replace "eth1" with "eth.{vlan}" where {vlan} would be the VLAN where your decoders are in. 

```
"eth1.100": {
    "alt-subnet": [
        "0.0.0.0/0"
    ],
    "role": "downstream",
    "threshold": "1"
}
```

To prevent the IPTV from flooding other network interfaces it's best to explicitly disable the proxy for these interfaces:

```
"eth1": {
    "role": "disabled",
    "threshold": "1"
},
"eth1.200": {
    "role": "disabled",
    "threshold": "1"
},
"eth1.300": {
    "role": "disabled",
    "threshold": "1"
}
```

XS4ALL (a Dutch ISP which uses the KPN platform has more information regarding the technical details), more info can be found [here](https://www.xs4all.nl/service/diensten/internet/installeren/modem-instellen/hoe-kan-ik-een-ander-modem-dan-fritzbox-instellen.htm)

This config.gateway.json has been tested on the following versions:

```
UniFi Security Gateway 3P: 4.4.51.5287926
Unifi Controller: 6.0.23 (atag_6.0.23_14253)
```

My Unifi WAN settings in the controller are as follows:

![unifiwan](https://raw.githubusercontent.com/coolhva/usg-kpn-ftth/master/unifi_wan.png)

At GoT I explain a little bit more about the MTU and troubleshooting:

Troubleshooting: https://gathering.tweakers.net/forum/list_message/60188896#60188896  
MTU and IPv6 workaround: https://gathering.tweakers.net/forum/list_message/57023231#57023231

