---
title: Unifi Security Gateway (USG) met KPN L2TP VPN
date: 2021-01-18 15:00:00 +0100
categories: [Documentatie, Handleiding]
tags: [usg, unifi, vpn]
seo:
  date_modified: 2021-01-18 19:54:03 +0100
---

```
LET OP! Deze handleiding is NOG NIET klaar, alle stappen zijn benoemd maar er mist uitleg en een schermafbeelding van de setvpn.sh plaatsen. Desondanks kan je, als je alles hebt doorgenomen, er voor kiezen om nu al hier mee aan de slag te gaan.
```

## Inleiding

Deze handleiding neem ik je mee hoe je met een L2TP VPN van buitenaf verbinding kan maken met de USG op je KPN FttH aansluiting. Deze handleiding is alleen van toepassing indien je ook IPTV hebt geconfigureerd via [deze](/usg-kpn-ftth/posts/unifi-security-gateway-kpn-ftth-iptv-ipv6/index.html) handleiding waarin we de USG rechtstreeks aansluiten op de FTTH verbinding van KPN.

```
LET OP! Deze handleiding werkt ALLEEN in combinatie met de handleiding waarin we de USG direct aansluiten op de FttH verbinding!
```

### Wat is een L2TP VPN?

Met een VPN (Virtual Private Network) maak je een verbinding vanaf, bijvoorbeeld, je telefoon of laptop via het internet met je USG. Nadat je inloggegevens zijn gecontroleerd is je telefoon of laptop onderdeel van het VPN Netwerk op de USG. Vanuit dit VPN netwerk kan je telefoon of laptop apparaten bereiken op je andere interne netwerk(en) of het internet bereiken via de USG waardoor het lijkt alsof je vanaf je thuis netwerk het internet op gaat.

## Voorbereiding

Voordat we daadwerkelijk gaan beginnen is het belangrijk om een aantal zaken voor te bereiden.

### Hardware 

De volgende hardware hebben we nodig om deze handleiding te kunnen voltooien.

|Type|Merk|Omschrijving
|:---|:--|:--|
|USG&nbsp;Router|Ubiquiti|Dit is de Ubiquiti Unifi security gateway (USG) die internet en IPTV verzorgt.|
|Unifi&nbsp;controller|Ubiquiti / anders|Met de controller stel je de USG in, deze kan op een stuk hardware (cloudkey) draaien maar ook op je computer, server, NAS rechstreeks of bijvoorbeeld via docker.|
|VPN Client|Telefoon/Laptop|Een apparaat wat L2TP VPN ondersteuning heeft (Andriod, IOS, Mac (OSX) of Windows) en de mogelijkheid om dit te testen buiten je eigen internet verbinding om, bijvoorbeeld via 4G of wifi van de buren.|

### Software

In deze handleiding ga ik er vanuit dat we Windows 10 gebruiken waarbij we onderstaande software gaan gebruiken. Graag deze bestanden downloaden zodat ze klaar staan als we gaan beginnen.

|Software|Omschrijving|
|:---|:--|
|[putty.exe&nbsp;(64&#x2011;bit)](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html){:target="_blank"}|Met dit programma kunnen we via SSH inloggen op de USG en eventueel de controller om commando's uit te voeren.|
|[WinSCP&nbsp;Portable](https://winscp.net/eng/downloads.php){:target="_blank"}|WinSCP gebruiken we om via Secure Copy Protocol bestanden van onze computer naar de USG en eventueel de controller te krijgen.|
|[usg-kpn-ftth-vpn zip](https://github.com/coolhva/usg-kpn-ftth/archive/vpn.zip){:target="_blank"}|De inhoud van mijn github repo met VPN ondersteuning in zip formaat zodat we alle bestanden in het juiste (UNIX) formaat hebben. Deze gaan we later naar de juiste locaties (Controller) verplaatsen.|

### Gegevens

Onderstaande informatie gaan we gebruiken in deze handleiding.

|Informatie|Omschrijving|
|:--|:---|
|Extern IP adres|Dit is het IPv4 adres van je KPN aansluiting, dit kan je achterhalen om via de KPN verbinding naar [Test-IPv6.com](https://test-ipv6.com/) te gaan.|
|URL&nbsp;Controller|Dit is het web adres waarop de unifi controller bereikbaar is, deze is bereikbaar op een IP adres en draait vaak op poort 8443 (HTTPS).|
|Controller&nbsp;login|De gebruikersnaam en wachtwoord om in te kunnen loggen op de controller.|
|SSH&nbsp;login&nbsp;gegevens USG|De gebruikersnaam en wachtwoord om via SSH in te kunnen loggen op de USG (zie kopje hieronder).|

![get_ip_address](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_vpn_get_remote_ip.png)

## Uitgangssituatie

Voordat we beginnen moeten we eerst weten waar we starten. In deze handleiding starten we met het volgende:

1. De USG zit met de WAN aansluiting direct aangesloten aan de NTU van KPN met een ethernet (UTP) kabel.
2. De LAN aansluiting van de USG zit met een ethernet (UTP) kabel verbonden met een switch.  
   Dat kan een unifi switch zijn maar mag ook een ander merk zijn, wel moet IGMP en VLAN ondersteund worden.
3. Op de switch (direct of via een andere switch), zit de unifi controller verbonden.  
   Dit kan een unifi cloud key zijn maar ook een computer, server of een NAS.
4. Ook zit de IPTV setupbox van KPN via een ethernet kabel verbonden aan een switch met IGMP en VLAN ondersteuning.
5. Deze handleiding ([link](/usg-kpn-ftth/posts/unifi-security-gateway-kpn-ftth-iptv-ipv6/index.html)) is uitgevoerd en TV en internet werkt op dit moment.
6. [Optioneel] De IPTV kastjes zitten in hun eigen VLAN door middel van deze handleiding [link](/usg-kpn-ftth/posts/unifi-security-gateway-kpn-iptv-vlan/index.html).

Als we de bestanden hebben gedownload pakken we de twee zip bestanden (winscp en usg-kpn-ftth vpn.zip) uit zodat we een map met WinSCP, een map met de configuratie bestanden en als laatst putty.exe hebben.

![files_downloaded](/usg-kpn-ftth/assets/img/usgkpn/files_downloaded.png)

## Oude interface inschakelen

Er is, helaas, een fout in de software van de Unifi controller geslopen waardoor je de VPN verbinding alleen succesvol kan instellen als je de oude interface gebruikt. Ga via <kbd>Settings</kdb> naar <kbd>System Settings</kbd> en schakel <kbd>New Settings</kbd> uit. Klik nu op <kbd>Apply Changes</kbd>.

![old_interface](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_vpn_use_old_settings.png)

## Radius server inschakelen

We gaan de radius server inschakelen, welke verantwoordelijk is voor het controleren van de inloggegevens. Ga naar <kbd>Settings</kbd>, klik op <kbd>Services</kbd>, <kbd>Radius</kbd> en daarna op <kbd>Server</kbd>. Schakel de <kbd>Enable RADIUS Server</kbd> naar <kbd>ON</kbd>, vul een <kbd>Secret</kbd> in (kies hier een wachtwoord wat intern in de USG zal worden gebruikt om te communiceren met de Radius server) en klik op <kbd>Apply Changes</kbd>.

![enable_radius](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_vpn_services_enable_radius.png)

![radius_users](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_vpn_users.png)

![radius_create_user](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_vpn_create_user.png)

ref: https://help.ui.com/hc/en-us/articles/115005445768-UniFi-USG-UDM-Configuring-L2TP-Remote-Access-VPN

<..>

## VPN Netwerk aanmaken

<..>

![networks_without_vpn](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_vpn_networks_without_vpn.png)

![create_vpn_network](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_vpn_create_network.png)

![networks_with_vpn](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_networks_with_vpn.png)

## Setvpn.sh plaatsen

<..>

setvpn.sh in /config/scripts/post-config.d/ plaatsen en CHMOD 755 uitvoeren.

## USG herstarten

Herstart nu de USG zodat de VPN instellingen worden geactiveerd en ook om te controleren dat na een herstart de VPN verbinding het zal doen.

## VPN Testen (iPhone)

<..>

![ios_settings_vpn](/usg-kpn-ftth/assets/img/usgkpnvpn/ios_settings_vpn.png)

![ios_vpn_create](/usg-kpn-ftth/assets/img/usgkpnvpn/ios_settings_vpn_create.png)

![ios_vpn_created](/usg-kpn-ftth/assets/img/usgkpnvpn/ios_settings_vpn_created.png)

![ios_vpn_connected](/usg-kpn-ftth/assets/img/usgkpnvpn/ios_settings_vpn_connected.png)

![ios_vpn_external_ip](/usg-kpn-ftth/assets/img/usgkpnvpn/ios_vpn_external_ip.png)

![ios_vpn_interal_server](/usg-kpn-ftth/assets/img/usgkpnvpn/ios_vpn_internal_server.png)

> Indien je me wilt bedanken (hoeft niet, mag wel) dan kan dat via [Buymeacoffee](https://www.buymeacoffee.com/coolhva).