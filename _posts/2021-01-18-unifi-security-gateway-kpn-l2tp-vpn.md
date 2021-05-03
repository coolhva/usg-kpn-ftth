---
title: Unifi Security Gateway (USG) met KPN L2TP VPN
date: 2021-01-18 15:00:00 +0100
categories: [Documentatie, Handleiding]
tags: [usg, unifi, vpn]
seo:
  date_modified: 2021-01-18 19:54:03 +0100
---

## Inleiding

Deze handleiding neem ik je mee hoe je met een L2TP VPN van buitenaf verbinding kan maken met de USG op je KPN FttH aansluiting. Deze handleiding is alleen van toepassing indien je ook IPTV hebt geconfigureerd via [deze](/usg-kpn-ftth/posts/unifi-security-gateway-kpn-ftth-iptv-ipv6/index.html) handleiding waarin we de USG rechtstreeks aansluiten op de FTTH verbinding van KPN.

### Wat is een L2TP VPN?

Met een VPN (Virtual Private Network) maak je een verbinding vanaf, bijvoorbeeld, je telefoon of laptop via het internet met je USG. Nadat je inloggegevens zijn gecontroleerd is je telefoon of laptop onderdeel van het VPN netwerk op de USG. Vanuit dit VPN netwerk kan je telefoon of laptop apparaten bereiken op je andere interne netwerk(en) of het internet bereiken via de USG waardoor het lijkt alsof je vanaf je thuis netwerk het internet op gaat.

## Voorbereiding

Voordat we daadwerkelijk gaan beginnen is het belangrijk om een aantal zaken voor te bereiden.

### Hardware 

De volgende hardware hebben we nodig om deze handleiding te kunnen voltooien.

|Type|Merk|Omschrijving
|:---|:--|:--|
|USG&nbsp;Router|Ubiquiti|Dit is de Ubiquiti Unifi security gateway (USG) die internet en IPTV verzorgt.|
|Unifi&nbsp;controller|Ubiquiti / anders|Met de controller stel je de USG in, deze kan op een stuk hardware (cloudkey) draaien maar ook op je computer, server, NAS rechstreeks of bijvoorbeeld via docker.|
|VPN Client|Telefoon/Laptop|Een apparaat wat L2TP VPN ondersteuning heeft (Andriod, IOS, Mac (OSX) of Windows) en de mogelijkheid om dit te testen buiten je eigen internet verbinding om, bijvoorbeeld via 4G of WiFi van de buren.|

### Gegevens

Onderstaande informatie gaan we gebruiken in deze handleiding.

|Informatie|Omschrijving|
|:--|:---|
|Extern IPv4 adres|Dit is het IPv4 adres van je KPN aansluiting, dit kan je achterhalen om via je KPN verbinding naar bijvoorbeeld [test-ipv6.com](https://test-ipv6.com/) te gaan. ![get_ip_address](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_vpn_get_remote_ip.png)|
|URL&nbsp;Controller|Dit is het web adres waarop de unifi controller bereikbaar is, deze is bereikbaar op een IP adres en draait vaak op poort 8443 (HTTPS).|
|Controller&nbsp;login|De gebruikersnaam en wachtwoord om in te kunnen loggen op de controller.|

## Uitgangssituatie

Voordat we beginnen moeten we eerst weten waar we starten. In deze handleiding starten we met het volgende:

1. De USG zit met de WAN aansluiting direct aangesloten aan de NTU van KPN met een ethernet (UTP) kabel.
2. De LAN aansluiting van de USG zit met een ethernet (UTP) kabel verbonden met een switch.  
   Dat kan een unifi switch zijn maar mag ook een ander merk zijn, wel moet IGMP en VLAN ondersteund worden.
3. Op de switch (direct of via een andere switch), zit de unifi controller verbonden.  
   Dit kan een unifi cloud key zijn maar ook een computer, server of een NAS.
4. Ook zit de IPTV setupbox van KPN via een ethernet kabel verbonden aan een switch met IGMP en VLAN ondersteuning.
5. Deze handleiding ([link](/usg-kpn-ftth/posts/unifi-security-gateway-kpn-ftth-iptv-ipv6/index.html)) is uitgevoerd en TV en internet werkt op dit moment.
6. `[Optioneel]` De IPTV kastjes zitten in hun eigen VLAN door middel van deze handleiding [link](/usg-kpn-ftth/posts/unifi-security-gateway-kpn-iptv-vlan/index.html).

## Oude interface inschakelen

Er is, helaas, een fout in de software van de Unifi controller geslopen waardoor je de VPN verbinding alleen succesvol kan instellen als je de oude interface gebruikt. Ga via <kbd>Settings</kbd> naar <kbd>System Settings</kbd> en schakel <kbd>New Settings</kbd> uit. Klik nu op <kbd>Apply Changes</kbd>.

![old_interface](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_vpn_use_old_settings.png)

## Radius server inschakelen

We gaan de radius server inschakelen, welke verantwoordelijk is voor het controleren van de inloggegevens. Ga naar <kbd>Settings</kbd>, klik op <kbd>Services</kbd>, <kbd>Radius</kbd> en daarna op <kbd>Server</kbd>. Schakel de <kbd>Enable RADIUS Server</kbd> naar <kbd>ON</kbd>, vul een <kbd>Secret</kbd> in (kies hier een wachtwoord wat intern in de USG zal worden gebruikt om te communiceren met de Radius server) en klik op <kbd>Apply Changes</kbd>.

![enable_radius](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_vpn_services_enable_radius.png)

Klik nu op de <kbd>Users</kbd> tab en klik op <kbd>+ Create New User</kbd>.

![radius_users](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_vpn_users.png)

Vul bij <kbd>Name</kbd> een gebruikersnaam en bij <kbd>Password</kbd> een wachtwoord in. Deze gegevens zal je ook moeten invullen in de VPN client om verbinding te maken met de USG. Laat <kbd>VLAN</kbd> leeg, kies bij <kbd>Tunnel Type</kbd> voor <kbd>3&nbsp;-&nbsp;Layer&nbsp;Two&nbsp;Tunneling&nbsp;Protocol&nbsp;(L2TP)</kbd> en bij <kbd>Tunnel Medium Type</kbd> voor <kbd>1&nbsp;-&nbsp;IPv4&nbsp;(IP&nbsp;version&nbsp;4)</kbd>. Klik nu op <kbd>Save</kbd>.

![radius_create_user](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_vpn_create_user.png)

## VPN Netwerk aanmaken

Nadat we de Radius server hebben ingeschakeld en een gebruiker hebben aangemaakt gaan we nu een VPN Netwerk toevoegen waar VPN gebruikers onderdeel van worden zodra ze via VPN verbinding maken met de USG.

Ga via <kbd>Settings</kbd> naar <kbd>Networks</kbd> en klik op <kbd>+ Create New Network</kbd>.

![networks_without_vpn](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_vpn_networks_without_vpn.png)

Maak een nieuw VPN netwerk met de volgende gegevens:

|Omschrijving|Keuze|
|:--|:---|
|Name|Kies een naam voor het VPN netwerk, bijvoorbeeld VPN.|
|Purpose|Remote User VPN|
|VPN Type|L2TP Server|
|Pre-Shared Key|Kies een wachtwoord, dit wachtwoord moet je straks ook invullen in je VPN client.|
|Gateway&nbsp;IP/Subnet|Vul hier 100.64.64.64/24 in, deze ip reeks is speciaal[^fn-ip100-64] en wordt niet intern gebruikt en zorgt dat je geen IP conflict krijgt.|
|Name Server|Auto|
|WINS Server|Uitgevinkt|
|Site-to-Site VPN|Uitgevinkt|
|RADIUS Profile|Default|
|MS-CHAP v2|Uitgevinkt|

Klik nu op <kbd>Save</kbd>.

![create_vpn_network](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_vpn_create_network.png)

In de lijst met netwerken moet het nieuw aangemaakte VPN netwerk er nu bij staan.

![networks_with_vpn](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_networks_with_vpn.png)

## WAN Netwerk controleren

Het is belangrijk om te zorgen dat het WAN netwerk niet is geconfigureerd en dat <kbd>Use VLAN ID</kbd> is uitgevinkt. Het WAN netwerk wordt namelijk via de config.gateway.json geconfigureerd en ook kpn.sh gaat er vanuit dat het WAN netwerk als volgt is ingesteld. Je kan deze instellingen bereiken door via <kbd>Settings</kbd> naar <kbd>Networks</kbd> te gaan en dan te kiezen voor <kbd>Edit</kbd> bij het <kbd>WAN</kbd> netwerk.

![networks_wan](/usg-kpn-ftth/assets/img/usgkpnvpn/usg_vpn_wan.png)

## VPN Testen
In dit voorbeeld pak ik een iPhone maar dezelfde logica kan worden gebruikt op een Android telefoon of laptop.

Ga op de iPhone naar <kbd>Settings</kbd> en daarna naar <kbd>VPN</kbd>. Kies voor <kbd>Add VPN Configuration...</kbd>.

![ios_settings_vpn](/usg-kpn-ftth/assets/img/usgkpnvpn/ios_settings_vpn.png){: width="500"}

Vul de volgende gegevens in:

|Omschrijving|Keuze|
|:--|:---|
|Type|L2TP|
|Description|Kies een naam voor het VPN verbinding, bijvoorbeeld Thuis.|
|Server|Het externe IPv4 adres van je KPN internet verbinding.|
|Account|De gebruikersnaam die je in de Radius configuratie hebt aangemaakt.|
|RSA SecurID|Uitgeschakeld|
|Password|Het wachtwoord die je hebt gebruikt bij het aanmaken van de gebruiker in de Radius configuratie.|
|Secret|Vul hier de <kbd>Pre-Shared Key</kbd> in die je bij het aanmaken van het VPN netwerk hebt gekozen.|
|Send All Traffic|Ja. Aangezien het L2TP protocol geen voorziening heeft om aan te geven welke netwerken via de VPN moeten lopen moet al het verkeer via de VPN lopen wil je toegang krijgen tot apparaten in je eigen netwerk(en).|
|Proxy|Off|

Kies daarna op <kbd>Done</kbd>.

![ios_vpn_create](/usg-kpn-ftth/assets/img/usgkpnvpn/ios_settings_vpn_create.png){: width="500"}

In het overzicht is de VPN verbinding er nu bijgekomen. Selecteer deze verbinding en zorg dat je verbonden bent via een ander netwerk dan je eigen KPN internet verbinding (bijvoorbeeld via 4G of WiFi van je buren).

![ios_vpn_created](/usg-kpn-ftth/assets/img/usgkpnvpn/ios_settings_vpn_created.png){: width="500"}

Zet nu de VPN verbinding aan door de knop om te zetten in de <kbd>Status</kbd> regel. Als alles goed gaat zal je nu zien dat je verbonden bent.

![ios_vpn_connected](/usg-kpn-ftth/assets/img/usgkpnvpn/ios_settings_vpn_connected.png){: width="500"}

Je kan nu naar je webbrowser gaan en in google vragen naar <kbd>what is my ip</kbd>. Als resultaat zie je het IPv4 adres waar Google ziet waar je vandaan komt. Dit is, als je al het verkeer doorstuurt naar de USG, het IPv4 adres van je KPN Internet verbinding.

![ios_vpn_external_ip](/usg-kpn-ftth/assets/img/usgkpnvpn/ios_vpn_external_ip.png){: width="500"}

Ook kan je nu verbinding maken met apparaten in je eigen netwerk, hieronder een voorbeeld van de login pagina van de unifi controller op mijn interne netwerk.

![ios_vpn_interal_server](/usg-kpn-ftth/assets/img/usgkpnvpn/ios_vpn_internal_server.png){: width="500"}

[^fn-ip100-64]: 100.64.0.0/10 Reserved IP Space, CGN: [Wikipedia](https://en.wikipedia.org/wiki/IPv4_shared_address_space)

> Indien je me wilt bedanken (hoeft niet, mag wel) dan kan dat via [Buymeacoffee](https://www.buymeacoffee.com/coolhva).