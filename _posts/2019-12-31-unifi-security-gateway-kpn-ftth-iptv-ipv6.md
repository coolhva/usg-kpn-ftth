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
|Glasvezel NTU|Genexis/MC901|Dit is het kastje (vaak in de meterkast) waar aan de ene kant de glasvezel kabel in gaat en aan de andere kant een RJ45 aansluiting waar de UTP kabel naar de router in zit|
|USG Router|Ubiquiti|Dit is de Ubiquiti Unifi security gateway (USG) dit internet en IPTV verzorgt|
|Switch|Ubiquiti / anders|De USG zit verbonden met een switch voor je lokale apparaten in je netwerk, deze switch moet wel IGMP ondersteunen vanwege IPTV|
|IPTV Setupbox|Arcadyan / ZTE|Het kastje wat aan de ene kant met UTP op je switch zit aangesloten en aan de andere kant met HDMI (of SCART) aan je TV|
|Unifi controller|Ubiquiti / anders|Met de controller stel je de USG in, deze kan op een stuk hardware (cloudkey) draaien maar ook op je computer/server/NAS rechstreeks of bijvoorbeeld via docker|

In deze handleiding ga ik er vanuit dat we Windows 10 gebruiken en dan is de volgende software nodig:

|Software|Omschrijving|
|:---|:--|
|[putty.exe (64-bit)](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)|Met dit programma kunnen we via SSH inloggen op de USG en eventueel de controller om commando's uit te voeren|
|[WinSCP Portable](https://winscp.net/eng/downloads.php)|WinSCP gebruiken we om via Secure Copy Protocol bestanden van onze computer naar de USG en eventueel de controller te krijgen|
|[usg-kpn-ftth zip](https://github.com/coolhva/usg-kpn-ftth/archive/master.zip)|De inhoud van mijn github repo in zip formaat zodat we alle bestanden in het juiste (UNIX) formaat hebben. Deze gaan we later naar de juiste locaties (USG/Controller) verplaatsen|
