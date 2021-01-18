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

```
LET OP! Deze handleiding werkt ALLEEN in combinatie met de handleiding waarin we de USG direct aansluiten op de FttH verbinding!
```

### Wat is een L2TP VPN?

<...>

## Voorbereiding

Voordat we daadwerkelijk gaan beginnen is het belangrijk om een aantal zaken voor te bereiden.

### Hardware 

De volgende hardware hebben we nodig om deze handleiding te kunnen voltooien.

|Type|Merk|Omschrijving
|:---|:--|:--|
|USG&nbsp;Router|Ubiquiti|Dit is de Ubiquiti Unifi security gateway (USG) die internet en IPTV verzorgt.|
|Unifi&nbsp;controller|Ubiquiti / anders|Met de controller stel je de USG in, deze kan op een stuk hardware (cloudkey) draaien maar ook op je computer, server, NAS rechstreeks of bijvoorbeeld via docker.|

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
|Extern IP adres|Dit is het IP adres van je KPN aansluiting, dit kan je achterhalen om via de KPN verbinding naar [IP Chicken](https://www.ipchicken.com/) te gaan.|
|URL&nbsp;Controller|Dit is het web adres waarop de unifi controller bereikbaar is, deze is bereikbaar op een IP adres en draait vaak op poort 8443 (HTTPS).|
|Controller&nbsp;login|De gebruikersnaam en wachtwoord om in te kunnen loggen op de controller.|
|SSH&nbsp;login&nbsp;gegevens USG|De gebruikersnaam en wachtwoord om via SSH in te kunnen loggen op de USG (zie kopje hieronder).|

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

<..>

## Radius server inschakelen

ref: https://help.ui.com/hc/en-us/articles/115005445768-UniFi-USG-UDM-Configuring-L2TP-Remote-Access-VPN

<..>

## VPN Netwerk aanmaken

<..>

## Setvpn.sh plaatsen

<..>

## USG herstarten

De USG gaat nu herstarten. Na dat internet het doet kan je de IPTV kastjes uitzetten, 10 seconden wachten, en deze weer aanzetten. Als het goed is heb je nu internet, IPTV en IPv6 waarbij intern de IPTV op een apart VLAN draait wat de kans op storingen zal verkleinen.

## VPN Testen (iPhone)

<..>

> Indien je me wilt bedanken (hoeft niet, mag wel) dan kan dat via [Buymeacoffee](https://www.buymeacoffee.com/coolhva).