---
title: Unifi Security Gateway (USG) met KPN IPTV op een apart VLAN
date: 2020-12-08 15:00:00 +0100
categories: [Documentatie, Handleiding]
tags: [usg, unifi]
seo:
  date_modified: 2020-12-19 15:51:02 +0100
---

## Inleiding

Deze handleiding neem ik je mee hoe je de IPTV kastjes van KPN achter de USG in hun eigen netwerk (VLAN) zet zodat de kans op verstoring kleiner is. Deze handleiding borduurt verder op [deze](/usg-kpn-ftth/posts/unifi-security-gateway-kpn-ftth-iptv-ipv6/) handleiding waarin we de USG rechtstreeks aansluiten op de FTTH verbinding van KPN.

### Wat is een VLAN?

De meeste mensen hebben één netwerk thuis waarin alle apparaten zich bevinden. Hierdoor kan het soms gebeuren dat apparaten elkaar verstoren. Om dit probleem op te lossen is het mogelijk om verschillende netwerken over één fysieke kabel te laten lopen. Elk netwerk heeft bepaalde zaken nodig om te kunnen functioneren, denk aan het uitdelen van IP adressen en het doorsturen van verkeer naar andere netwerken. Deze taak neemt de USG op zich. We maken op de USG een nieuw netwerk (VLAN) aan, zorgen dat er ip adressen worden uitgedeeld en dat IPTV functioneert op dit netwerk.

Technisch gezien werkt het versturen van verkeer van meerdere netwerken over één kabel door het toevoegen van een identificatie nummer aan het verkeer. Zo weet de switch welk verkeer op welke fysieke aansluiting afgeleverd moet worden en wordt ook het verkeer van de verschillende netwerken gescheiden.

Het identificatie nummer van het netwerk (ook wel VLAN ID genoemd) kan tussen 0 en 4095 liggen. Ik heb voor deze handleiding VLAN ID 661 gekozen omdat 661 op dit moment het eerste speciale glasvezel kanaal is bij KPN en dat de kans dat mensen 661 thuis al gebruiken zeer klein is (in tegenstelling tot VLAN ID 10, 20, 30, etc.).

## Voorbereiding

Voordat we daadwerkelijk gaan beginnen is het belangrijk om een aantal zaken voor te bereiden.

### Hardware 

De volgende hardware hebben we nodig om deze handleiding te kunnen voltooien.

|Type|Merk|Omschrijving
|:---|:--|:--|
|Glasvezel NTU|Genexis/MC901|Dit is het kastje (vaak in de meterkast) waar aan de ene kant de glasvezel kabel in gaat en aan de andere kant een RJ45 aansluiting waar de UTP kabel naar de router in zit.|
|USG Router|Ubiquiti|Dit is de Ubiquiti Unifi security gateway (USG) die internet en IPTV verzorgt.|
|Switch|Ubiquiti / anders|De USG zit verbonden met een switch voor je lokale apparaten in je netwerk, deze switch moet wel IGMP ondersteunen vanwege IPTV maar voor deze handleiding moet deze ook ondersteuning voor VLANs bieden.|
|IPTV Setupbox|Arcadyan / ZTE|Het kastje wat aan de ene kant met UTP op je switch zit aangesloten en aan de andere kant met HDMI (of SCART) aan je TV.|
|Unifi controller|Ubiquiti / anders|Met de controller stel je de USG in, deze kan op een stuk hardware (cloudkey) draaien maar ook op je computer/server/NAS rechstreeks of bijvoorbeeld via docker.|

> ***Let op:*** deze handleiding is bedoeld voor een Ubiquity Unifi Security Gateway 3. Indien je een USG 4 Pro hebt dien je in de gateway.config.json de interfaces aan te passen op de manier waarop je je USG 4 Pro hebt aangesloten. Bij de USG 3 is eth0 WAN en eth1 LAN.

### Software

In deze handleiding ga ik er vanuit dat we Windows 10 gebruiken waarbij we onderstaande software gaan gebruiken. Graag deze bestanden downloaden zodat ze klaar staan als we gaan beginnen.

|Software|Omschrijving|
|:---|:--|
|[putty.exe (64-bit)](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html){:target="_blank"}|Met dit programma kunnen we via SSH inloggen op de USG en eventueel de controller om commando's uit te voeren.|
|[WinSCP Portable](https://winscp.net/eng/downloads.php){:target="_blank"}|WinSCP gebruiken we om via Secure Copy Protocol bestanden van onze computer naar de USG en eventueel de controller te krijgen.|
|[usg-kpn-ftth-vlan zip](https://github.com/coolhva/usg-kpn-ftth/archive/vlan.zip){:target="_blank"}|De inhoud van mijn github repo met IPTV VLAN ondersteuning in zip formaat zodat we alle bestanden in het juiste (UNIX) formaat hebben. Deze gaan we later naar de juiste locaties (Controller) verplaatsen.|

> ***Let op:*** Indien je XS4ALL hebt dien je [xs4all vlan.zip](https://github.com/coolhva/usg-kpn-ftth/archive/vlan-xs4all.zip) te downloaden!

### Gegevens

Onderstaande informatie gaan we gebruiken in deze handleiding.

|Informatie|Omschrijving|
|:--|:---|
|URL Controller|Dit is het web adres waarop de unifi controller bereikbaar is, deze is bereikbaar op een IP adres en draait vaak op poort 8443 (HTTPS).|
|Controller login|De gebruikersnaam en wachtwoord om in te kunnen loggen op de controller.|
|Toegang tot bestanden controller|Er moet een configuratie geplaatst worden op de controller. Indien je een Unifi Cloud Key hebt kan dat via SSH, de inloggegevens heb je ingesteld tijdens de initiële configuratie van de Cloud Key. Als je een docker container gebruikt die je toegang te hebben tot de data map. In het geval van een server/computer dien je ook toegang te hebben tot de data map.|

## Uitgangssituatie

Voordat we beginnen moeten we eerst weten waar we starten. In deze handleiding starten we met het volgende:

1. De USG zit met de WAN aansluiting direct aangesloten aan de NTU van KPN met een ethernet (UTP) kabel.
2. De LAN aansluiting van de USG zit met een ethernet (UTP) kabel verbonden met een switch.  
   Dat kan een unifi switch zijn maar mag ook een ander merk zijn, wel moet IGMP en VLAN ondersteund worden.
3. Op de switch (direct of via een andere switch), zit de unifi controller verbonden.  
   Dit kan een unifi cloud key zijn maar ook een computer, server of een NAS.
4. Ook zit de IPTV setupbox van KPN via een ethernet kabel verbonden aan een switch met IGMP en VLAN ondersteuning.
5. Deze handleiding ([link](https://coolhva.github.io/usg-kpn-ftth/posts/unifi-security-gateway-kpn-ftth-iptv-ipv6/)) is uitgevoerd en TV en internet werkt op dit moment.

Ubiquiti heeft zelf een afbeelding hoe de verschillende onderdelen met elkaar verbonden zijn:

![topology](/usg-kpn-ftth/assets/img/usgkpn/topology.png)

In dit geval is het modem de NTU, hieronder een overzicht van de verschillende NTU's die KPN ingebruik heeft:

![ntu](/usg-kpn-ftth/assets/img/usgkpn/ntu.png)

Als we de bestanden hebben gedownload pakken we de twee zip bestanden (winscp en usg-kpn-ftth vlan.zip) uit zodat we een map met WinSCP, een map met de configuratie bestanden en als laatst putty.exe hebben.

![files_downloaded](/usg-kpn-ftth/assets/img/usgkpn/files_downloaded.png)

## VLAN 661 toevoegen

Eerst gaan we VLAN 661 toevoegen op de controller zodat deze wordt toegevoegd op de USG.

Ga eerst naar<kbd>settings</kbd> en dan naar <kbd>networks</kbd>. In het overzicht van de netwerken klik je op <kbd>Add a New Network</kbd>.

![usg_controller_add_new_network](/usg-kpn-ftth/assets/img/usgkpnvlan/usg_controller_add_new_network.png)

Kies als naam <kbd>IPTV</kbd>, klik op <kbd>Advanced</kbd> en vul <kbd>661</kbd> in bij <kbd>VLAN ID</kbd>.

![usg_controller_add_network_settings_vlanid](/usg-kpn-ftth/assets/img/usgkpnvlan/usg_controller_add_network_settings_vlanid.png)

Scroll naar beneden en zet <kbd>IGMP snooping</kbd> aan.

![usg_controller_add_network_igmp_snooping](/usg-kpn-ftth/assets/img/usgkpnvlan/usg_controller_add_network_igmp_snooping.png)

Klik op <kbd>Apply changes</kbd> en in het overzicht zie je nu dat het IPTV netwerk er bij is gekomen.

![usg_controller_networks_witih_iptv](/usg-kpn-ftth/assets/img/usgkpnvlan/usg_controller_networks_witih_iptv.png)

> ***Let op:*** Wanneer je alleen unifi switches gebruikt tussen de USG en het IPTV kastje is het voldoende om nu de IPTV kastjes op VLAN 661 te plaatsen en kan je onderstaande stappen volgen. Als je andere merken switches gebruikt zorg dan dat VLAN 661 tagged naar de USG loopt en untagged naar het IPTV kastje loopt (en dat VLAN 661 de hele weg wordt doorgegeven als er meerdere switches worden gebruikt) en ga verder met de stap om de gateway.config.json op de controller te plaatsen.

Nu gaan we in het menu links naar <kbd>Clients</kbd> en klikken op het IPTV kastje van KPN. Klik op de link naast <kbd>port</kbd>, je gaat nu naar de switch waarbij de poort al geselecteerd is.

![usg_controller_iptv_device](/usg-kpn-ftth/assets/img/usgkpnvlan/usg_controller_iptv_device.png)

Ga met je muis over de poort heen en klik op het edit icoontje.

![usg_controller_devices_port_edit](/usg-kpn-ftth/assets/img/usgkpnvlan/usg_controller_devices_port_edit.png)

Klik nu op <kbd>Switch Port Profile</kbd> en kies voor <kbd>IPTV (661)</kbd>. Klik daarna op <kbd>Apply</kbd>

![usg_controller_set_switchport](/usg-kpn-ftth/assets/img/usgkpnvlan/usg_controller_set_switchport.png)

Nu gaan we verder met de aangepaste gateway.config.json plaatsen.

## Gateway.config.json plaatsen

Het configuratie bestand wat we gaan plaatsen is een json bestand waarin een geavanceerde configuratie staat beschreven. Vanwege de complexiteit is dit niet in de webinterface in te stellen. Dit configuratie bestand is bedoeld voor de USG maar we gaan dit bestand plaatsen op de unifi controller. Zodra de unifi controller de USG de configuratie stuurt zal de unifi controller de instellingen van de webinterface samenvoegen met de geavanceerde configuratie en zo de complete configuratie naar de USG sturen.

De unifi controller kan op verschillende manieren aanwezig zijn in je netwerk:

1. Via een stuk hardware van Ubiquity zelf, een zogenoemde Unifi Cloud Key
2. Via een stuk software wat je op je computer/server installeert (Windows of Linux)
3. Via een (docker)container kan de controller draaien op een server of bijvoorbeeld op een NAS

De locatie van de <kbd>gateway.config.json</kbd> is altijd hetzelfde gezien vanuit de basis locatie, namelijk <code class="highlighter-rouge">&lt;unifi_base&gt;/data/sites/site_ID</code>. In de meeste gevallen is de <code class="highlighter-rouge">site_ID</code> gelijk aan <code class="highlighter-rouge">default</code> maar de waarde kan anders zijn indien je in de controller een site hebt toegevoegd en daar je apparaten in hebt geconfigureerd. In de adresbalk van je browser zie je in welke site je zit, in mijn geval is dat <code class="highlighter-rouge">default</code>.

De locatie van <code class="highlighter-rouge">&lt;unifi_base&gt;</code> hangt af waar de controller draait. Ubiquity heeft een [pagina](https://help.ubnt.com/hc/en-us/articles/115004872967) gemaakt waarop ze de verschillende locaties aangeven:

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

In het rechter venster navigeer ik naar de locatie <code class="highlighter-rouge">&lt;unifi_base&gt;/data/sites/site_ID</code>, in mijn geval is dat /volume1/docker/unifi/data/sites/default, ik heb namelijk de map /volume1/docker/unifi gekoppeld aan de unifi map in de docker container waardoor dit mijn <code class="highlighter-rouge">&lt;unifi_base&gt;</code> locatie is. In het linker venster navigeer ik naar de map waarin ik <kbd>usg-kpn-ftth-vlan.zip</kbd> heb uitgepakt, selecteer ik het bestand <kbd>gateway.config.json</kbd> en klik ik links boven op <kbd>Upload</kbd>. Hierna klik ik op <kbd>Ok</kbd> en is het bestand <kbd>gateway.config.json</kbd> naar de juiste locatie gekopieërd.

> Indien je op een cloudkey naar de data map navigeert maar daarin geen map sites ziet kan je deze op twee manieren aanmaken.
> Automatisch:
> Via het aanmaken (en verwijderen) van een floorplan, klik (hier)[/usg-kpn-ftth/posts/unifi-security-gateway-sides-folder/] voor de handleiding.
> Handmatig:
> Hiervoor moet je inloggen met putty op de cloudkey en daarna onderstaande commando's uitvoeren.
```shell
mkdir -p /usr/lib/unifi/data/sites/default
chown unifi:unifi /usr/lib/unifi/data/sites/default
```
> Daarna is de map aangemaakt en kan je de gateway.config.json er in plaatsen.

## USG configuratie laten toepassen

Ga nu in de controller naar <kbd>Devices</kbd>. Klik daarna op de USG, rechts verschijnen de details en dan klik je op het tandwiel icoon. Daarna klik je op <kbd>Manage Device</kbd> en klik je in het kopje Force Provision op <kbd>Provision</kbd>.

![unifi_controller_force_provision](/usg-kpn-ftth/assets/img/usgkpn/unifi_controller_force_provision.png)

De USG gaat nu herstarten. Na dat internet het doet kan je de IPTV kastjes uitzetten, 10 seconden wachten, en deze weer aanzetten. Als het goed is heb je nu internet, IPTV en IPv6 waarbij intern de IPTV op een apart VLAN draait wat de kans op storingen zal verkleinen.

## Meer informatie

* [Tweakers.net forum topic](https://gathering.tweakers.net/forum/list_messages/1883441)
* [Github Repo met configuratie bestanden](https://github.com/coolhva/usg-kpn-ftth/tree/vlan)