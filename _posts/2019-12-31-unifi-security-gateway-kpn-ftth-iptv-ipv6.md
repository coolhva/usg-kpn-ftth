---
title: Unifi Security Gateway (USG) installeren met KPN FTTH inclusief IPTV en IPv6
date: 2019-12-31 15:00:00 +0100
categories: [Documentatie, Handleiding]
tags: [usg, unifi]
seo:
  date_modified: 2020-12-28 19:54:03 +0100
---

## Inleiding

In deze handleiding neem ik je mee hoe je een Unifi Security Gateway (USG) rechtstreeks kan aansluiten op glasvezel (FTTH) van KPN en daarbij gebruik kan maken van de IPTV kastjes die door KPN worden geleverd en IPv6.

## Voorbereiding

Voordat we daadwerkelijk gaan beginnen is het belangrijk om een aantal zaken voor te bereiden.

### Hardware 

De volgende hardware hebben we nodig om deze handleiding te kunnen voltooien.

|Type|Merk|Omschrijving
|:---|:--|:--|
|Glasvezel NTU|Genexis/MC901|Dit is het kastje (vaak in de meterkast) waar aan de ene kant de glasvezel kabel in gaat en aan de andere kant een RJ45 aansluiting waar de UTP kabel naar de router in zit.|
|USG Router|Ubiquiti|Dit is de Ubiquiti Unifi security gateway (USG) die internet en IPTV verzorgt.|
|Switch|Ubiquiti / anders|De USG zit verbonden met een switch voor je lokale apparaten in je netwerk, deze switch moet wel IGMP ondersteunen vanwege IPTV.|
|IPTV Setupbox|Arcadyan / ZTE|Het kastje wat aan de ene kant met UTP op je switch zit aangesloten en aan de andere kant met HDMI (of SCART) aan je TV.|
|Unifi controller|Ubiquiti / anders|Met de controller stel je de USG in, deze kan op een stuk hardware (cloudkey) draaien maar ook op je computer/server/NAS rechstreeks of bijvoorbeeld via docker.|

> ***Let op:*** deze handleiding is bedoeld voor een Ubiquity Unifi Security Gateway 3. Indien je een USG 4 Pro hebt dien je in de gateway.config.json en setroutes.sh de interfaces aan te passen op de manier waarop je je USG 4 Pro hebt aangesloten. Bij de USG 3 is eth0 WAN en eth1 LAN.

### Software

In deze handleiding ga ik er vanuit dat we Windows 10 gebruiken waarbij we onderstaande software gaan gebruiken. Graag deze bestanden downloaden zodat ze klaar staan als we gaan beginnen.

|Software|Omschrijving|
|:---|:--|
|[putty.exe (64-bit)](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html){:target="_blank"}|Met dit programma kunnen we via SSH inloggen op de USG en eventueel de controller om commando's uit te voeren.|
|[WinSCP Portable](https://winscp.net/eng/downloads.php){:target="_blank"}|WinSCP gebruiken we om via Secure Copy Protocol bestanden van onze computer naar de USG en eventueel de controller te krijgen.|
|[usg-kpn-ftth zip](https://github.com/coolhva/usg-kpn-ftth/archive/master.zip){:target="_blank"}|De inhoud van mijn github repo in zip formaat zodat we alle bestanden in het juiste (UNIX) formaat hebben. Deze gaan we later naar de juiste locaties (USG/Controller) verplaatsen.|

> ***Let op:*** Indien je XS4ALL hebt dien je [xs4all.zip](https://github.com/coolhva/usg-kpn-ftth/archive/xs4all.zip) te downloaden!

### Gegevens

Onderstaande informatie gaan we gebruiken in deze handleiding.

|Informatie|Omschrijving|
|:--|:---|
|URL Controller|Dit is het web adres waarop de unifi controller bereikbaar is, deze is bereikbaar op een IP adres en draait vaak op poort 8443 (HTTPS).|
|Controller login|De gebruikersnaam en wachtwoord om in te kunnen loggen op de controller.|
|IP adres USG|We maken met SSH verbinding naar dit IP adres een bestand te plaatsen en commando's uit te voeren.|
|SSH login gegevens USG|De gebruikersnaam en wachtwoord om via SSH in te kunnen loggen op de USG (zie kopje hieronder).|
|Toegang tot bestanden controller|Er moet een configuratie geplaatst worden op de controller. Indien je een Unifi Cloud Key hebt kan dat via SSH, de inloggegevens heb je ingesteld tijdens de initiële configuratie van de Cloud Key. Als je een docker container gebruikt die je toegang te hebben tot de data map. In het geval van een server/computer dien je ook toegang te hebben tot de data map.|

### SSH toegang unifi apparaten

Om toegang te krijgen tot de USG via SSH moet dit geconfigureerd zijn. In de webinterface van de controller ga je naar <kbd>settings</kbd> en dan naar <kbd>Controller Configuration</kbd> en scroll je naar beneden naar <kbd>Element SSH Authentication</kbd>. Hier vink je <kbd>Element SSH authentication</kbd> aan en kies je een gebruikersnaam en wachtwoord. Daarna klik je op <kbd>Apply Changes</kbd>. Vanaf nu kan je met deze gebruikersnaam en wachtwoord via SSH inloggen op de USG.

![unifi_controller_ssh](/usg-kpn-ftth/assets/img/usgkpn/unifi_controller_ssh.png)

## Uitgangssituatie

Voordat we beginnen moeten we eerst weten waar we starten. In deze handleiding starten we met het volgende:

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

Als we de bestanden hebben gedownload pakken we de twee zip bestanden (winscp en usg-kpn-ftth master.zip) uit zodat we een map met WinSCP, een map met de configuratie bestanden en als laatst putty.exe hebben.

![files_downloaded](/usg-kpn-ftth/assets/img/usgkpn/files_downloaded.png)

### IGMP snooping aanzetten

Het is belangrijk dat op de switch(es) IGMP snooping aan staat vanwege IPTV. In de unifi controller kan je dat vinden door naar <kbd>settings</kbd> en dan naar <kbd>networks</kbd> te gaan. In het overzicht van de netwerken klik je op <kbd>Edit</kbd> bij het LAN netwerk en vink je <kbd>Enable IGMP snooping</kbd> aan.

## Gateway.config.json plaatsen

Het eerste configuratie bestand wat we gaan plaatsen is een json bestand waarin een geavanceerde configuratie staat beschreven. Vanwege de complexiteit is dit niet in de webinterface in te stellen. Dit configuratie bestand is bedoeld voor de USG maar we gaan dit bestand plaatsen op de unifi controller. Zodra de unifi controller de USG de configuratie stuurt zal de unifi controller de instellingen van de webinterface samenvoegen met de geavanceerde configuratie en zo de complete configuratie naar de USG sturen.

De unifi controller kan op verschillende manieren aanwezig zijn in je netwerk:

1. Via een stuk hardware van Ubiquity zelf, een zogenoemde Unifi Cloud Key
2. Via een stuk software wat je op je computer/server installeert (Windows of Linux)
3. Via een (docker)container kan de controller draaien op een server of bijvoorbeeld op een NAS

De locatie van de <kbd>gateway.config.json</kbd> is altijd hetzelfde gezien vanuit de basis locatie, namelijk ```&lt;unifi_base&gt;/data/sites/site_ID```. In de meeste gevallen is de ```site_ID``` gelijk aan ```default``` maar de waarde kan anders zijn indien je in de controller een site hebt toegevoegd en daar je apparaten in hebt geconfigureerd. In de adresbalk van je browser zie je in welke site je zit, in mijn geval is dat ```default```.

De locatie van ```&lt;unifi_base&gt;``` hangt af waar de controller draait. Ubiquity heeft een [pagina](https://help.ubnt.com/hc/en-us/articles/115004872967) gemaakt waarop ze de verschillende locaties aangeven:

|Type controller|Locatie|
|:---|:---|
|UniFi Cloud Key|/usr/lib/unifi|
|Debian/Ubuntu Linux|/usr/lib/unifi|
|Windows|%userprofile%/Ubiquiti UniFi|
|macOS|~/Library/Application Support/UniFi|

In het geval van de cloudkey kan je navigeren naar /usr/lib/unifi/data/sites/default/ (vervang default als je een andere site_id gebruikt). Indien je de controller software lokaal draait (op Windows of Mac) dan kan je <kbd>gateway.config.json</kbd> naar de juiste locatie kopieëren door middel van de verkenner of finder. In mijn geval maak ik gebruik van een docker container op mijn Synology NAS en kan ik via SSH inloggen op de NAS en naar de juiste map navigeren die aan mijn docker container gekoppeld zit.

![winscp_controller](/usg-kpn-ftth/assets/img/usgkpn/winscp_controller.png)

Ik start door WinSCP.exe te openen en de gegevens van mijn controller in te vullen zodat ik via SSH (SCP) verbinding maak. Indien er een waarschuwing komt over een "unknown server" kan je deze met <kbd>Yes</kbd> beantwoorden, WinSCP waarschuwt je namelijk dat dit de eerste keer is dat je verbinding maakt met dit apparaat.

![winscp_controller_upload](/usg-kpn-ftth/assets/img/usgkpn/winscp_controller_upload.png)

In het rechter venster navigeer ik naar de locatie ```&lt;unifi_base&gt;/data/sites/site_ID```, in mijn geval is dat /volume1/docker/unifi/data/sites/default, ik heb namelijk de map /volume1/docker/unifi gekoppeld aan de unifi map in de docker container waardoor dit mijn ```&lt;unifi_base&gt;``` locatie is. In het linker venster navigeer ik naar de map waarin ik <kbd>usg-kpn-ftth-master.zip</kbd> heb uitgepakt, selecteer ik het bestand <kbd>gateway.config.json</kbd> en klik ik links boven op <kbd>Upload</kbd>. Hierna klik ik op <kbd>Ok</kbd> en is het bestand <kbd>gateway.config.json</kbd> naar de juiste locatie gekopieërd.

> Indien je op de controller naar de data map navigeert maar daarin geen map sites ziet kan je deze laten aanmaken, klik [hier](/usg-kpn-ftth/posts/unifi-security-gateway-sides-folder/index.html) voor de handleiding.

## Setroutes.sh plaatsen

Nadat we de JSON op de controller hebben geplaatst, gaan we nu een configuratie bestand op de USG plaatsen. Hiervoor klik ik in WinSCP op de knop <kbd>New Session</kbd> en vul ik de gegevens in van de USG. De eventuele waarschuwing van unkown server beantwoord ik met <kbd>Yes</kbd>. Een popup met een welkomstboodschap verschijnt en hier mag je op <kbd>Continue</kbd> klikken.

![winscp_usg](/usg-kpn-ftth/assets/img/usgkpn/winscp_usg.png)

Nadat de verbinding tot stand is gekomen navigeren we in het rechter venster naar de locatie ```/config/scripts/post-config.d```. In het linker scherm selecteren we setroutes.sh en klikken we weer op de knop <kbd>Upload</kbd>. Klik hierna op <kbd>Ok</kbd> en daarna is het bestand op de USG geplaatst.

![winscp_usg_upload](/usg-kpn-ftth/assets/img/usgkpn/winscp_usg_upload.png)

Nu moeten we het bestand uitvoerbaar maken. Dat doen we door de het bestand te selecteren en daarna met de rechtermuisknop er op te klikken en voor <kbd>Properties</kbd> te kiezen.

![winscp_usg_select](/usg-kpn-ftth/assets/img/usgkpn/winscp_usg_select.png)

In de eigenschappen mag je een vinkje zetten bij elke <kbd>X</kbd> (bij Octal komt nu 0755 te staan) en daarna op <kbd>Ok</kbd> klikken.

![winscp_usg_chmod](/usg-kpn-ftth/assets/img/usgkpn/winscp_usg_chmod.png)

Nu mag je WinSCP sluiten en in de controller naar <kbd>Devices</kbd> gaan. Klik daarna op de USG, rechts verschijnen de details en dan klik je op het tandwiel icoon. Daarna klik je op <kbd>Manage Device</kbd> en klik je in het kopje Force Provision op <kbd>Provision</kbd>.

![unifi_controller_force_provision](/usg-kpn-ftth/assets/img/usgkpn/unifi_controller_force_provision.png)

De USG gaat nu herstarten. Na dat internet het doet kan je de IPTV kastjes uitzetten, 10 seconden wachten, en deze weer aanzetten. Als het goed is heb je nu internet, IPTV en IPv6.

## IPTV op een apart netwerk

Het is mogelijk om de IPTV kastjes op een eigen netwerk te plaatsen om te kans op verstoring te verkleinen. De gebruikte switches dienen wel VLAN ondersteuning te hebben. Kijk voor deze handleiding op deze [link](/usg-kpn-ftth/posts/unifi-security-gateway-kpn-iptv-vlan/index.html)

## Meer informatie

Op de volgende links vindt je meer informatie over deze setup en hoe je problemen kan opsporen en verhelpen.

* [Tweakers.net forum problemen opsporen](https://gathering.tweakers.net/forum/list_message/60188454#60188454)
* [Github Repo met configuratie bestanden](https://github.com/coolhva/usg-kpn-ftth)
* [Tweakers.net forum MTU en KPN](https://gathering.tweakers.net/forum/list_message/57023231#57023231)
