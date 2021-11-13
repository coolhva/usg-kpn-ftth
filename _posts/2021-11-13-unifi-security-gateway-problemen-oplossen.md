---
title: Unifi Security Gateway (USG) problemen oplossen met KPN FTTH inclusief IPTV en IPv6
date: 2021-11-13 15:00:00 +0100
categories: [Documentatie, Handleiding]
tags: [usg, unifi]
seo:
  date_modified: 2021-11-13 16:00:03 +0100
---

## Problemen oplossen

Nadat de handleiding gevolgd is zou alles moeten werken, maar wat als het niet werkt? Ik laat hier stap voor stap zien welke stappen je kan ondernemen om het probleem te vinden, en daarna te verhelpen.

## Omgeving

In deze handleiding wordt gebruik gemaakt van de volgende omgeving waarbij de USG ```192.168.2.1``` als IP adres heeft:

![topology](/usg-kpn-ftth/assets/img/usgkpnproblemen/unifi_setup.png)

Om te zorgen dat ik met SSH in kan loggen op mijn USG heb ik in de controller bij site settings het volgende ingesteld (de public key is optioneel, maakt het inloggen wel sneller en makkelijker):

![device_authentication](/usg-kpn-ftth/assets/img/usgkpnproblemen/device_auth.png)

## Verbinding testen

Ik kijk eerst of de USG bereikbaar is vanuit mijn werkstation:

```shell
henk@mac ~ ping 192.168.2.1
PING 192.168.2.1 (192.168.2.1): 56 data bytes
64 bytes from 192.168.2.1: icmp_seq=0 ttl=64 time=2.028 ms
64 bytes from 192.168.2.1: icmp_seq=1 ttl=64 time=1.792 ms
64 bytes from 192.168.2.1: icmp_seq=2 ttl=64 time=1.164 ms
```

Als dat niet het geval is dan heb ik een uitdaging, meestal helpt dan een reboot en anders een factory reset en dan opnieuw provisionen. Wanneer ik wel verbinding heb kijk ik of ik internet verbinding heb door een ping naar de DNS server van cloudflare:

```shell
henk@mac ~ 
ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1): 56 data bytes
64 bytes from 1.1.1.1: icmp_seq=0 ttl=60 time=5.346 ms
64 bytes from 1.1.1.1: icmp_seq=1 ttl=60 time=9.598 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=60 time=5.702 ms
```

Mocht je geen internet verbinding hebben dan kan het zo zijn dat de config.gateway.json niet op de juiste plek staat, dat kan je ook zien doordat ```eth0.4```
, ```eth0.6``` en ```pppoe2``` niet aanwezig zijn in de lijst met interfaces, die zien we zo als we met SSH inloggen.

## Inloggen met SSH op de USG

We loggen in op de USG zelf met SSH om een aantal zaken te controleren:

```shell
henk@mac ~ ssh unifiadmin@192.168.2.1
Welcome to EdgeOS

By logging in, accessing, or using the Ubiquiti product, you
acknowledge that you have read and understood the Ubiquiti
License Agreement (available in the Web UI at, by default,
http://192.168.1.1) and agree to be bound by its terms.

Linux HVA-USG-GW 3.10.107-UBNT #1 SMP Fri Jul 26 15:07:52 UTC 2019 mips64

  ___ ___      .__________.__
 |   |   |____ |__\_  ____/__|
 |   |   /    \|  ||  __) |  |   (c) 2010-2019
 |   |  |   |  \  ||  \   |  |   Ubiquiti Networks, Inc.
 |______|___|  /__||__/   |__|
            |_/                  https://www.ui.com

      Welcome to EdgeOS on UniFi Security Gateway!


 **********************  WARNING!  **********************
 * Configuration changes made here are not persistent.  *
 * They will be overwritten by the controller on next   *
 * provision. Configuration must be done in controller. *
 ********************************************************

Last login: Thu Sep 26 15:36:01 2019 from 192.168.2.145
unifiadmin@HVA-USG-GW:~$
```

## Interfaces controleren

De eerste stap is om de interfaces te laten zien met ```show interfaces```:

```shell
unifiadmin@HVA-USG-GW:~$ show interfaces
Codes: S - State, L - Link, u - Up, D - Down, A - Admin Down
Interface    IP Address                        S/L  Description
---------    ----------                        ---  -----------
eth0         -                                 u/u  WAN
eth0.4       10.227.59.120/20                  u/u  IPTV
eth0.6       -                                 u/u
eth1         192.168.2.1/24                    u/u  LAN
             2a02:a455:984b:1:feec:daff:fed6:fc1e/64
eth1.10      10.13.37.1/24                     u/u
eth2         -                                 A/D
lo           127.0.0.1/8                       u/u
             ::1/128
pppoe2       86.94.235.23                      u/u
```

Zoals je hier ziet heb ik twee sub interfaces (VLANS) op eth0 (WAN) en één sub interface op eth1 (LAN). De sub interface op mijn LAN is het netwerk voor gasten en IOT. Ik raad je ook aan om IPTV apart in VLAN 661 te zetten met deze [handleiding](/usg-kpn-ftth/posts/unifi-security-gateway-kpn-iptv-vlan/index.html), dan zie je ```eth1.661``` ook tussen de interfaces staan.

In dit overzicht zijn een aantal zaken belangrijk:

1. ```eth0.4``` heeft een 10.x adres, deze wordt door KPN uitgegeven op VLAN4 en wordt gebruikt voor IPTV
2. ```eth1``` heeft een IPv4 en een IPv6 adres (dan is de IPv6 configuratie juist doorgevoerd)
3. ```pppoe2``` heeft het publieke IPV4 adres waarmee je bekend mee bent op het internet

## IPTV kernel route

Om het IPTV verkeer correct te kunnen routeren is het belangrijk dat de USG de route informatie, die meegegeven wordt met het DHCP antwoord vanuit KPN,wordt verwerkt in de route tabel. Het ```kpn.sh``` script maakt het juiste script aan in de DHCP exit hook map. Als alles goed functioneert is er een (kernel) route aanwezig voor ```213.75.112.0/21``` via ```eth0.4```.

```shell
unifiadmin@HVA-USG-GW:~$ show ip route
Codes: K - kernel route, C - connected, S - static, R - RIP, O - OSPF,
       I - ISIS, B - BGP, > - selected route, * - FIB route

K>* 0.0.0.0/0 is directly connected, pppoe2
C>* 10.13.37.0/24 is directly connected, eth1.10
C>* 10.227.48.0/20 is directly connected, eth0.4
C>* 127.0.0.0/8 is directly connected, lo
C>* 192.168.2.0/24 is directly connected, eth1
C>* 195.190.228.134/32 is directly connected, pppoe2
K>* 213.75.112.0/21 via 10.227.48.1, eth0.4
unifiadmin@HVA-USG-GW:~$
```

Als je geen kernel route hebt is het zaak om te kijken of het DHCP script bestaat en de juiste inhoud bevat met het commando ```cat /etc/dhcp3/dhclient-exit-hooks.d/routes | wc -l```:

```shell
unifiadmin@HVA-USG-GW:~$ cat /etc/dhcp3/dhclient-exit-hooks.d/routes | wc -l
63
```
Als het bestand niet bestaat of je krijgt 0 terug als antwoord dan staat dat script niet goed. Er zijn een aantal mogelijkheden welke allemaal opgelost worden door het uitvoeren van de volgende commando's na elkaar:

```shell
unifiadmin@HVA-USG-GW:~$ sudo rm /etc/dhcp3/dhclient-exit-hooks.d/routes
unifiadmin@HVA-USG-GW:~$ sudo rm /config/scripts/post-config.d/kpn.lock
unifiadmin@HVA-USG-GW:~$ sudo /config/scripts/post-config.d/kpn.sh
unifiadmin@HVA-USG-GW:~$ tail /var/log/kpn.log
[Sat Nov 13 17:49:51 CET 2021] [kpn.sh] Creating dhcp hook at /etc/dhcp3/dhclient-exit-hooks.d/routes
[Sat Nov 13 17:49:51 CET 2021] [kpn.sh] Release dhcp interface eth0.4
Releasing DHCP lease on eth0.4 ...
[Sat Nov 13 17:49:56 CET 2021] [kpn.sh] Renew dhcp interface eth0.4
Renewing DHCP lease on eth0.4 ...
[Sat Nov 13 17:49:58 CET 2021] [kpn.sh] Restarting IGMP proxy
Stopping IGMP proxy
Starting IGMP proxy service
[Sat Nov 13 17:50:01 CET 2021] [kpn.sh] removing lock file at /config/scripts/post-config.d/kpn.lock
[Sat Nov 13 17:50:01 CET 2021] [kpn.sh] Finished
```
Een foutmelding bij het verwijderen van ```routes``` of ```kpn.lock``` mogen worden genegeerd, als ze bestaan moeten ze eerst verwijderd worden voordat ```kpn.sh``` uitgevoerd kan worden. De ```tail /var/log/kpn.log``` laat de uitwerking zien van het uitvoeren van ```kpn.sh```, het routes bestand wordt geplaatst en de DHCP lease wordt vernieuwd en de IGMP proxy wordt herstart, nu zou IPTV het (weer) moeten doen.

## IPTV Multicast verkeer controleren

Om te zien of de IGMP proxy (die het TV verkeer van KPN doorzet naar je LAN) goed functioneert kan je kijken naar de multicast statistieken:

```shell
unifiadmin@HVA-USG-GW:~$ show ip multicast interfaces
Intf             BytesIn        PktsIn      BytesOut       PktsOut            Local
eth1               0.00b             0       33.23MB         54863      192.168.2.1
eth1.10            0.00b             0         0.00b             0       10.13.37.1
eth0.4           33.23MB         54863         0.00b             0    10.227.59.120
pppoe2             0.00b             0         0.00b             0     86.94.235.23
unifiadmin@HVA-USG-GW:~$
```

Hier zie je dat ```eth0.4``` 33 mb heeft ontvangen en ```eth1``` 33mb heeft verzonden. Als je IPTV in VLAN 661 hebt zitten zul je ```eth1.661``` in de lijst zien en dan moet deze interface het meeste ```BytesOut``` hebben.

## IGMP Proxy herstarten

Als je TV hapert dan kan je proberen om de IGMP proxy te herstarten:

```shell
unifiadmin@HVA-USG-GW:~$ restart igmp-proxy
Stopping IGMP proxy
Starting IGMP proxy service
```

Mocht de IGMP proxy niet draaien dan kan je het [igmpproxy.sh](https://raw.githubusercontent.com/coolhva/usg-kpn-ftth/master/igmpproxy.sh) script in de ```post-config.d``` map zetten waarbij elke minuut wordt gecontroleerd of IGMP proxy draait en gestart wordt als hij niet draait.

## Storende apparaten

Ik heb ook verhalen gehoord dat Chromecasts en andere streaming apparaten de IGMP proxy kunnen verstoren. Je zou kunnen proberen om deze van het netwerk af te halen en te testen of je IPTV problemen geeft, zo niet kan je ze weer aan het netwerk hangen en als je dan problemen ervaart met IPTV weet je wie de boosdoener is.

Het in een apart VLAN zetten van IPTV verhelpt bijna alle problemen maar soms blijven andere apapraten storen.

## Het werkt nog steeds niet...

Plaats dan een bericht in het [Tweakers.Net topic](https://gathering.tweakers.net/forum/list_messages/1883441/last) met de resultaten van bovenstaande stappen en dan proberen we het samen op te lossen!