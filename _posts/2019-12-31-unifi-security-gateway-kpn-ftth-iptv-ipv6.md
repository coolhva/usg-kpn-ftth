---
title: Unifi Security Gateway (USG) installeren met KPN FTTH inclusief IPTV en IPv6
date: 2019-12-31 15:00:00 +0100
categories: [Documentatie, Handleiding]
tags: [usg] [unifi]
seo:
  date_modified: 2019-12-31 15:00:00 +0100
---

## Inleiding

In deze handleiding neem ik je mee hoe je een Unifi Security Gateway (USG) rechtstreeks kan aansluiten op glasvezel (FTTH) van KPN en daarbij gebruik kan maken van de IPTV kastjes die door KPN worden geleverd en IPv6.

## Voorbereiding

Voordat we daadwerkelijk gaan beginnen is het belangrijk om een aantal zaken voor te bereiden. De volgende hardware is benodigd:

|Type|Merk|Omschrijving
|:--|:--|:---|
|Glasvezel NTU|Genexis/MC901|Dit is het kastje (vaak in de meterkast) waar aan de ene kant de glasvezel kabel in gaat en waar een RJ45 aansluiting op zit waar de UTP kabel in zit naar het router toe|
|USG Router|Unifi|Dit is de Unifi security gateway (USG) dit internet en IPTV verzorgt|
|Switch|Unifi / anders|De USG zit verbonden met een switch voor je lokale apparaten in je netwerk, deze switch moet wel IGMP ondersteunen vanwege IPTV|
|IPTV Setupbox|Arcadyan|Het kastje wat aan de ene kant met UTP op je switch zit aangesloten en met HDMI (of SCART) aan je TV|

