---
title: Unifi Security Gateway (USG) installeren met KPN FTTH inclusief IPTV en IPv6
date: 2019-12-31 15:00:00 +0100
categories: [Documentatie, Handleiding]
tags: [usg, unifi]
seo:
  date_modified: 2019-12-31 15:05:16 +0100
---

## Inleiding

In deze handleiding neem ik je mee hoe je een Unifi Security Gateway (USG) rechtstreeks kan aansluiten op glasvezel (FTTH) van KPN en daarbij gebruik kan maken van de IPTV kastjes die door KPN worden geleverd en IPv6.

## Voorbereiding

Voordat we daadwerkelijk gaan beginnen is het belangrijk om een aantal zaken voor te bereiden.

De volgende hardware is benodigd:

|Type|Merk|Omschrijving
|:---|:--|:--|
|Glasvezel NTU|Genexis/MC901|Dit is het kastje (vaak in de meterkast) waar aan de ene kant de glasvezel kabel in gaat en aan de andere kant een RJ45 aansluiting waar de UTP kabel naar de router in zit.|
|USG Router|Ubiquiti|Dit is de Ubiquiti Unifi security gateway (USG) die internet en IPTV verzorgt.|
|Switch|Ubiquiti / anders|De USG zit verbonden met een switch voor je lokale apparaten in je netwerk, deze switch moet wel IGMP ondersteunen vanwege IPTV.|
|IPTV Setupbox|Arcadyan / ZTE|Het kastje wat aan de ene kant met UTP op je switch zit aangesloten en aan de andere kant met HDMI (of SCART) aan je TV.|
|Unifi controller|Ubiquiti / anders|Met de controller stel je de USG in, deze kan op een stuk hardware (cloudkey) draaien maar ook op je computer/server/NAS rechstreeks of bijvoorbeeld via docker.|

In deze handleiding ga ik er vanuit dat we Windows 10 gebruiken en dan is de volgende software nodig:

|Software|Omschrijving|
|:---|:--|
|[putty.exe (64-bit)](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html){:target="_blank"}|Met dit programma kunnen we via SSH inloggen op de USG en eventueel de controller om commando's uit te voeren.|
|[WinSCP Portable](https://winscp.net/eng/downloads.php){:target="_blank"}|WinSCP gebruiken we om via Secure Copy Protocol bestanden van onze computer naar de USG en eventueel de controller te krijgen.|
|[usg-kpn-ftth zip](https://github.com/coolhva/usg-kpn-ftth/archive/master.zip){:target="_blank"}|De inhoud van mijn github repo in zip formaat zodat we alle bestanden in het juiste (UNIX) formaat hebben. Deze gaan we later naar de juiste locaties (USG/Controller) verplaatsen.|

De volgende gegevens zijn benodigd voordat we aan de slag gaan:

|Informatie|Omschrijving|
|:--|:---|
|URL Controller|Dit is het web adres waarop de unifi controller bereikbaar is, deze is bereikbaar op een IP adres en draait vaak op poort 8443 (HTTPS).|
|Controller login|De gebruikersnaam en wachtwoord om in te kunnen loggen op de controller.|
|SSH login gegevens USG|De gebruikersnaam en wachtwoord om via SSH in te kunnen loggen op de USG (zie kopje hieronder).|
|Toegang tot bestanden controller|Er moet een configuratie geplaatst worden op de controller. Indien je een Unifi Cloud Key hebt kan dat via SSH, de inloggegevens heb je ingesteld tijdens de initiële configuratie van de Cloud Key. Als je een docker container gebruikt die je toegang te hebben tot de data map. In het geval van een server/computer dien je ook toegang te hebben tot de data map.|

### SSH toegang unifi apparaten

Om toegang te krijgen tot de USG via SSH moet dit geconfigureerd zijn. In de webinterface van de controller ga je naar <kbd>settings</kbd> en dan naar <kbd>site</kbd> en scroll je naar beneden naar <kbd>device authentication</kbd>. Hier vink je <kbd>Enable SSH authentication</kbd> aan en kies je een gebruikersnaam en wachtwoord. Daarna klik je op <kbd>Apply Changes</kbd>. Vanaf nu kan je met deze gebruikersnaam en wachtwoord via SSH inloggen op de USG.

![unifi_controller_ssh](/usg-kpn-ftth/assets/img/usgkpn/unifi_controller_ssh.png)

## Uitgangssituatie

Voordat we beginnen moeten we eerst weten waar we starten. In deze handleiding start we met het volgende:

1. De USG zit met de WAN aansluiting direct aangesloten aan de NTU van KPN met een ethernet (UTP) kabel.
2. De LAN aansluiting van de USG zit met een ethernet (UTP) kabel verbonden met een switch.  
   Dat kan een unifi switch zijn maar mag ook een ander merk zijn, wel moet IGMP ondersteund worden.
3. Op de switch (direct of via een andere switch), zit de unifi controller verbonden.  
   Dit kan een unifi cloud key zijn maar ook een computer, server of een NAS.
4. Ook zit de IPTV setupbox van KPN via een ethernet kabel verbonden aan een switch.

Ubiquiti heeft zelf een afbeelding hoe de verschillende onderdelen met elkaar verbonden zijn:

![topology](/usg-kpn-ftth/assets/img/usgkpn/topology.png)

In dit geval is het modem de NTU, hieronder een overzicht van de verschillende NTU's die KPN ingebruik heeft:

![ntu](/usg-kpn-ftth/assets/img/usgkpn/ntu.png)

Daarnaast pakken we de twee zip bestanden (winscp en usg-kpn-ftth master.zip) uit zodat we een map met WinSCP, een map met de configuratie bestanden en als laatst putty.exe hebben.