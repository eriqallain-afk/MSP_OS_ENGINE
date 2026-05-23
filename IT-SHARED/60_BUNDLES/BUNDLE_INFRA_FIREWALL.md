# BUNDLE — BUNDLE_INFRA_FIREWALL
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Bundle ID :** BUNDLE_INFRA_FIREWALL
**Source ZIP :** INFRA_FIrewall.zip
**Généré :** 2026-04-04T20:19:33Z

## Contenu (runbooks)
1. **RUNBOOK__Meraki_Operations_V1** — RUNBOOK — Cisco Meraki : Opérations & Dépannage (Maj: 2026-03-20 | Agents: IT-NetworkMaster, IT-Assistant-N3)
2. **RUNBOOK__Fortinet_Operations_V1** — RUNBOOK — Fortinet FortiGate : Opérations & Dépannage (Maj: 2026-03-20 | Agents: IT-NetworkMaster, IT-Assistant-N3)
3. **RUNBOOK__SonicWall_Operations_V1** — RUNBOOK — SonicWall : Opérations & Dépannage (Maj: 2026-03-20 | Agents: IT-NetworkMaster, IT-Assistant-N3)
4. **RUNBOOK__Unifi_Mikrotik_Operations_V1** — RUNBOOK — Ubiquiti UniFi & MikroTik : Opérations & Dépannage (Maj: 2026-03-20 | Agents: IT-NetworkMaster, IT-Assistant-N3)
5. **RUNBOOK__WatchGuard_Operations_V1** — RUNBOOK — WatchGuard Firebox : Opérations & Dépannage (Maj: 2026-03-20 | Agents: IT-NetworkMaster, IT-Assistant-N3)

---

<!-- RUNBOOK_START: RUNBOOK__Meraki_Operations_V1 (INFRA__RUNBOOK__Meraki_Operations_V1.md) -->
# RUNBOOK — Cisco Meraki : Opérations & Dépannage
**ID :** RUNBOOK__Meraki_Operations_V1
**Version :** 1.0 | **Agents :** IT-NetworkMaster, IT-Assistant-N3
**Domaine :** INFRA — Réseau / Cloud-managed
**Mis à jour :** 2026-03-20

---

## 1. ACCÈS CONSOLE MERAKI

| Méthode | Accès |
|---|---|
| **Dashboard Cloud** | https://dashboard.meraki.com |
| **CLI SSH** (limité) | ssh -p 22 [user]@[IP_DEVICE] — accès limité par Meraki |

```
⛔ Meraki est 100% cloud-managed
⛔ Credentials dashboard : voir Passportal
⛔ NE PAS tenter d'accéder via SSH de façon extensive — utiliser le Dashboard
```

---

## 2. HEALTH CHECK MERAKI

### Via Dashboard
```
Organisation → Overview
→ Statut de tous les appareils (Online/Offline/Alerting)
→ Alertes actives

Network → [Nom réseau] → Summary
→ Clients connectés
→ Usage bande passante
→ Top applications

Switch → Monitor → Switches
→ Port status (Up/Down)
→ Erreurs de port

Wireless → Monitor → Access Points
→ APs Online/Offline
→ Clients WiFi connectés
→ Signal strength

Security → Monitor → Appliance Status
→ VPN status
→ Uplink (WAN) status
→ Bande passante consommée
```

---

## 3. DÉPANNAGE — DEVICE OFFLINE DANS LE DASHBOARD

```
Un appareil Meraki "offline" = il ne répond plus au cloud Meraki

Étapes :
1. Vérifier l'alimentation physique (voyants)
2. Vérifier la connectivité Internet de l'appareil
   → Meraki requiert accès sortant HTTPS vers *.meraki.com
   → Port 443 et UDP 7351 ouverts vers Internet

3. Si le réseau manque d'Internet mais l'appareil est physiquement opérationnel :
   → L'appareil continue à fonctionner en mode local (dernier config téléchargé)
   → Configuration ne peut PAS être modifiée pendant l'outage

4. Forcer reconnexion (si accessible localement) :
   → Brancher câble console ou accès local → reboot
   → Ou depuis le Dashboard si partiellement accessible : Device → Reboot

5. Si offline persistant > 15 min avec Internet fonctionnel :
   → Vérifier les certificats Meraki (problème rare)
   → Vérifier si l'organisation a des licences valides
```

---

## 4. VPN MERAKI — AUTO VPN ET CLIENT VPN

### Auto VPN (Site-à-site)
```
Security → VPN → Site-to-site VPN
→ Mode : Hub (concentrateur) ou Spoke (site distant)
→ Statut des tunnels : Établis (vert) / Dégradés (orange) / Inactifs (rouge)

Dépannage tunnel inactif :
1. Vérifier les deux côtés dans le Dashboard
2. Vérifier que les sous-réseaux locaux ne se chevauchent pas
3. Vérifier la connectivité WAN des deux côtés
4. Meraki Auto VPN est automatique — si les deux côtés sont Online, le tunnel se rétablit seul
```

### Client VPN (IPSec natif / AnyConnect)
```
Security → VPN → Client VPN
→ Activer/désactiver
→ Sous-réseau client VPN
→ Serveurs DNS
→ Authentification : AD ou Meraki local

Dépannage connexion client refusée :
1. Vérifier les credentials (voir Passportal)
2. Vérifier que le client est dans le groupe autorisé
3. Vérifier les règles firewall qui bloquent le VPN
4. Log : Security → Event Log → filtrer "VPN"
```

---

## 5. GESTION DES SWITCHES MERAKI

```
Switch → Configure → Switch ports
→ Modifier un port : VLAN, état (Up/Down), PoE

Dépannage port down :
1. Switch → Monitor → Switches → cliquer sur le switch
2. Identifier le port en question
3. Vérifier : "Port status" → Error disabled ? → Vérifier cause (boucle, STP)
4. Si PoE requis : vérifier budget PoE total du switch

VLAN Management :
Switch → Configure → Routing and DHCP
→ Interfaces SVI par VLAN
→ DHCP server par VLAN
```

---

## 6. GESTION DES ACCESS POINTS MERAKI

```
Wireless → Monitor → Access Points
→ Client count par AP
→ Signal strength
→ Channel utilization

Dépannage WiFi :
1. AP Offline → voir section Device Offline
2. Mauvaise connexion client → Wireless → Monitor → Clients → chercher le client
3. Interférences → Wireless → RF Profiles → vérifier les paramètres de canal
4. Capacité atteinte → ajouter un AP ou ajuster les seuils
```

---

## 7. LICENCES MERAKI — VÉRIFICATION

```
Organisation → Configure → License Info
→ Co-termination date : date à laquelle toutes les licences expirent
→ Devices under license : tous les appareils doivent avoir une licence

⚠️ Alerter si expiration < 60 jours (délai de renouvellement Meraki)
⚠️ Si un appareil n'a pas de licence → il cesse de fonctionner
```

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS reconfigurer un réseau Meraki depuis le Dashboard sans billet CW approuvé
⛔ NE JAMAIS supprimer un réseau de l'organisation (irréversible)
⛔ NE JAMAIS laisser expirer les licences sans alerte préalable
⛔ NE PAS tenter de modifier le firmware manuellement — Meraki gère les mises à jour automatiquement
⛔ NE JAMAIS configurer deux Hub Auto VPN avec les mêmes sous-réseaux
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Site entier offline (MX offline) | NOC | Immédiat |
| Perte de Dashboard Meraki global | NOC | 30 min |
| Licence expirée (appareils qui s'éteignent) | INFRA | Immédiat |
| Intrusion détectée (IDS/IPS Meraki) | SOC | Immédiat |
<!-- RUNBOOK_END: RUNBOOK__Meraki_Operations_V1 -->

---

<!-- RUNBOOK_START: RUNBOOK__Fortinet_Operations_V1 (INFRA__RUNBOOK__Fortinet_Operations_V1.md) -->
# RUNBOOK — Fortinet FortiGate : Opérations & Dépannage
**ID :** RUNBOOK__Fortinet_Operations_V1
**Version :** 1.0 | **Agents :** IT-NetworkMaster, IT-Assistant-N3
**Domaine :** INFRA — Réseau / Firewall
**Mis à jour :** 2026-03-20

---

## 1. ACCÈS CONSOLE FORTIGATE

| Méthode | Accès |
|---|---|
| **Web UI** | https://[IP_FORTIGATE] |
| **CLI SSH** | ssh admin@[IP_FORTIGATE] |
| **Console série** | 9600 baud, 8N1 |
| **FortiCloud** | https://www.forticloud.com |
| **FortiManager** | Centralisé si déployé |

```
⛔ Credentials : voir Passportal
```

---

## 2. HEALTH CHECK FORTIGATE

### Via Web UI
```
Dashboard → Status
→ CPU, Memory, Sessions, Uptime
→ Interface Status (vert = UP)
→ Licenses : vérifier les dates d'expiration

System → FortiGuard
→ Licences : UTM (AV, IPS, Web Filter), Support
→ Update Status : dernière mise à jour des signatures

Log & Report → Events → System Events
→ Alertes critiques récentes
```

### Via CLI SSH
```bash
# Connexion
ssh admin@[IP_FORTIGATE]

# État général
get system status
get system performance status

# Interfaces
get system interface
diagnose ip address list

# Sessions actives
get system session list | head -20
diagnose sys session stat

# VPN IPSec — tunnels actifs
get vpn ipsec tunnel summary
diagnose vpn ike status

# VPN SSL
get vpn ssl monitor
diagnose vpn ssl list

# Logs récents
execute log filter category 1
execute log display
```

---

## 3. VPN FORTIGATE — DÉPANNAGE

### VPN SSL (FortiClient / Portail web)
```bash
# Vérifier les utilisateurs connectés
get vpn ssl monitor

# Vérifier la configuration SSL VPN
get vpn ssl settings

# Logs VPN SSL
execute log filter category 1
execute log filter field user [username]
execute log display

# Terminer une session SSL VPN spécifique
diagnose vpn ssl del-user index [ID]
```

### VPN IPSec (Site-à-site)
```bash
# État des tunnels
get vpn ipsec tunnel summary
diagnose vpn tunnel list

# Voir les SAs actives
diagnose vpn ike gateway list
diagnose vpn tunnel list name [NOM_TUNNEL]

# Relancer un tunnel
diagnose vpn tunnel up [NOM_TUNNEL]

# Debug IKE (mode verbose — utiliser avec parcimonie)
diagnose debug application ike -1
diagnose debug enable
# Attendre 30 secondes, puis arrêter
diagnose debug disable
diagnose debug reset
```

---

## 4. DÉPANNAGE RÈGLES FIREWALL

```bash
# Voir les règles firewall
show firewall policy

# Vérifier le hit count d'une règle (trafic qui passe)
get firewall policy [ID_RÈGLE]

# Tracer un paquet (packet sniffer) — sans afficher les IPs dans les logs CW
diagnose sniffer packet [INTERFACE] "host [IP_SOURCE]" 4 0 l
# Arrêter avec Ctrl+C

# Debug flow (trace de paquets)
diagnose debug flow filter addr [IP_SOURCE]
diagnose debug flow show iprope enable
diagnose debug flow show function-name enable
diagnose debug flow trace start 100
diagnose debug enable
# Analyser, puis arrêter :
diagnose debug flow trace stop
diagnose debug disable
```

---

## 5. MISE À JOUR FIRMWARE FORTIGATE

```
⚠️ TOUJOURS sauvegarder la configuration avant mise à jour
⚠️ Vérifier la compatibilité de la version cible avec les fonctionnalités utilisées

1. Backup configuration :
   System → Maintenance → Backup (télécharger + stocker dans Passportal)

2. Télécharger le firmware :
   https://support.fortinet.com → Product Downloads → FortiOS

3. Appliquer :
   System → Firmware → Upload Firmware
   → Sélectionner le fichier .out
   → Choisir : "Backup current configuration and upgrade"

4. Validation post-mise à jour :
   → Interfaces actives
   → Règles firewall intactes
   → Licences valides
   → Tunnels VPN reconnectés
   → Accès Internet fonctionnel
```

---

## 6. LICENCES FORTIGUARD — VÉRIFICATION

```bash
# Via CLI
get system fortiguard-service status

# Via Web UI
System → FortiGuard → License Information
→ AV (Antivirus) : date d'expiration
→ IPS : date d'expiration
→ Web Filter : date d'expiration
→ Application Control : date d'expiration
```

```
⚠️ Alerter si une licence expire dans < 30 jours
Action : contacter le revendeur Fortinet pour renouvellement
```

---

## 7. NE PAS FAIRE

```
⛔ NE JAMAIS désactiver le mode IPS/UTM sur une règle sans approbation SOC
⛔ NE JAMAIS créer de règle "any to any accept" même temporairement
⛔ NE JAMAIS mettre à jour le firmware sans backup validé
⛔ NE JAMAIS modifier les règles en production sans billet CW approuvé
⛔ NE PAS exécuter "diagnose debug flow" > 5 minutes — impact sur les performances
```

---

## 8. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| FortiGate inaccessible | NOC | Immédiat |
| Licence UTM expirée (protection désactivée) | SOC + INFRA | Dans l'heure |
| Intrusion détectée (IPS alert) | SOC | Immédiat |
| Tunnel site-à-site down > 30 min | NOC | 30 min |
<!-- RUNBOOK_END: RUNBOOK__Fortinet_Operations_V1 -->

---

<!-- RUNBOOK_START: RUNBOOK__SonicWall_Operations_V1 (INFRA__RUNBOOK__SonicWall_Operations_V1.md) -->
# RUNBOOK — SonicWall : Opérations & Dépannage
**ID :** RUNBOOK__SonicWall_Operations_V1
**Version :** 1.0 | **Agents :** IT-NetworkMaster, IT-Assistant-N3
**Domaine :** INFRA — Réseau / Firewall
**Mis à jour :** 2026-03-20

---

## 1. ACCÈS CONSOLE SONICWALL

| Méthode | Accès |
|---|---|
| **Web UI (SonicOS)** | https://[IP_SONICWALL] |
| **CLI SSH** | ssh admin@[IP_SONICWALL] |
| **MySonicWall** | https://www.mysonicwall.com |
| **NSM (Network Security Manager)** | Centralisé si déployé |

---

## 2. HEALTH CHECK SONICWALL

### Via Web UI
```
Dashboard → Security Dashboard
→ CPU, RAM, Connexions actives, Débit
→ Interfaces : statut et utilisation

Network → Interfaces
→ Vérifier que WAN (X1) est UP avec une adresse IP

System → Licenses
→ Vérifier les dates d'expiration des services :
  Gateway Anti-Virus, IPS, App Control, SSL Inspection, Support

Log → View
→ Alertes critiques récentes (Critical, Alert)
```

---

## 3. VPN SONICWALL — DÉPANNAGE

### SSL VPN (NetExtender / SMA)
```
Network → SSL VPN → Client Settings
→ Vérifier que SSL VPN est activé
→ Vérifier les groupes d'accès

VPN → SSL VPN → User Status
→ Sessions actives
→ Déconnecter une session : sélectionner → Delete

Dépannage connexion refusée :
1. Vérifier que l'utilisateur est dans le bon groupe LDAP/Local
2. Vérifier la politique SSL VPN : Network → SSL VPN → Client Routes
3. Vérifier le certificat SSL : System → Certificates
4. Logs : Log → View → filtrer "SSL VPN"
```

### VPN IPSec (Site-à-site)
```
VPN → Settings → VPN Policies
→ Vérifier le statut du tunnel (icône verte = actif)
→ Forcer reconnexion : clic droit sur le tunnel → Disable → Enable

Dépannage :
1. VPN → Settings → VPN Policies → Edit la policy
   → Vérifier Phase 1 : IKE Version, DH Group, Encryption
   → Vérifier Phase 2 : Encryption, Authentication, PFS
   → Les deux côtés DOIVENT avoir les mêmes paramètres
2. Vérifier la clé partagée (voir Passportal)
3. Vérifier les réseaux locaux/distants (subnets)

Logs VPN :
Log → View → filtrer "IKE" ou "VPN"
```

### Global VPN Client (GVC)
```
Network → IPSec VPN → L2TP Server (ou GVC)
→ Vérifier l'activation
→ Vérifier les utilisateurs autorisés

Logs client : Event Viewer Windows → Applications et services → SonicWALL
```

---

## 4. RÈGLES FIREWALL — VÉRIFICATION ET DÉPANNAGE

```
Firewall → Access Rules
→ Navigation par zone : LAN→WAN, WAN→LAN, etc.
→ Vérifier le compteur "Count" pour confirmer qu'une règle est utilisée

Pour identifier le blocage :
Log → View → Chercher "Dropped" ou "Blocked" avec l'IP source/destination
→ La règle qui a bloqué est indiquée dans la colonne "Rule"
```

---

## 5. MISE À JOUR FIRMWARE SONICWALL

```
⚠️ SAUVEGARDER avant mise à jour

1. Backup configuration :
   System → Settings → Export Settings → télécharger .exp

2. MySonicWall → Télécharger le firmware cible
   OU via SonicOS : System → Settings → Firmware & Settings → Upload New Firmware

3. Appliquer :
   System → Settings → Firmware & Settings
   → Cliquer sur "Boot" pour le nouveau firmware

4. Validation post-mise à jour :
   → Interfaces actives
   → Règles firewall intactes
   → Services Security actifs
   → Tunnels VPN reconnectés
```

---

## 6. LICENCES ET RENOUVELLEMENT

```
System → Licenses → Manage Security Services Online
→ Liste des services avec dates d'expiration

⚠️ Alerter si expiration < 30 jours :
- Support 24x7 : indispensable pour les mises à jour firmware
- Gateway Anti-Virus / IPS : protection active
- App Control : contrôle des applications
```

---

## 7. NE PAS FAIRE

```
⛔ NE JAMAIS créer de règle "Any → Any" sans restrictions
⛔ NE JAMAIS modifier une règle existante sans documenter l'état avant dans CW
⛔ NE JAMAIS mettre à jour le firmware sans backup et fenêtre de maintenance approuvée
⛔ NE JAMAIS partager les credentials admin directement — utiliser Passportal
⛔ NE PAS désactiver le Deep Packet Inspection (DPI) sans approbation SOC
```

---

## 8. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| SonicWall inaccessible | NOC | Immédiat |
| Tunnels VPN tous down | NOC | 15 min |
| Licence de sécurité expirée | SOC + INFRA | Dans l'heure |
| Attaque détectée (IPS/AV) | SOC | Immédiat |
<!-- RUNBOOK_END: RUNBOOK__SonicWall_Operations_V1 -->

---

<!-- RUNBOOK_START: RUNBOOK__Unifi_Mikrotik_Operations_V1 (INFRA__RUNBOOK__Unifi_Mikrotik_Operations_V1.md) -->
# RUNBOOK — Ubiquiti UniFi & MikroTik : Opérations & Dépannage
**ID :** RUNBOOK__Unifi_Mikrotik_Operations_V1
**Version :** 1.0 | **Agents :** IT-NetworkMaster, IT-Assistant-N3
**Domaine :** INFRA — Réseau
**Mis à jour :** 2026-03-20

---

# PARTIE 1 — UBIQUITI UNIFI

## 1.1 ACCÈS CONSOLE UNIFI

| Méthode | Accès |
|---|---|
| **UniFi Network Application** | https://[IP_CONTROLEUR]:8443 (self-hosted) |
| **UniFi Cloud** | https://unifi.ui.com |
| **SSH appareil** | ssh ubnt@[IP_DEVICE] (ou admin) |

```
⛔ Credentials : voir Passportal
```

## 1.2 HEALTH CHECK UNIFI

### Via UniFi Network Application
```
Dashboard
→ Devices : tous les appareils (vert = Online, rouge = Offline, jaune = Isolé)
→ Clients connectés (filaire + WiFi)
→ Alertes et notifications

Topology → vue de la topologie réseau
→ Identifier les appareils orphelins ou déconnectés

Settings → System → Maintenance
→ Version du controleur
→ Sauvegardes automatiques
```

## 1.3 DÉPANNAGE DEVICE UNIFI OFFLINE

```bash
# 1. Vérifier l'alimentation et le câble réseau

# 2. SSH sur l'appareil si accessible
ssh ubnt@[IP_DEVICE]
# ou
ssh admin@[IP_DEVICE]

# Vérifier les logs
cat /var/log/messages | tail -50

# Vérifier la connexion au contrôleur
info

# Forcer l'adoption / reconnecter au contrôleur
set-inform http://[IP_CONTROLEUR]:8080/inform
```

## 1.4 GESTION DES APs UNIFI

```
Devices → Cliquer sur un AP
→ Onglet General : nom, MAC, IP, version firmware
→ Onglet Config : VLAN, SSID associés
→ Onglet Statistics : clients, utilisation channel, signal

Mise à jour firmware AP :
Devices → Sélectionner le ou les APs → Actions → Upgrade
⚠️ Les APs redémarrent — perte WiFi temporaire (~2 min par AP)
⚠️ Programmer hors heures de pointe
```

## 1.5 DÉPANNAGE WiFi UNIFI

```
Problème : clients ne se connectent pas au WiFi
1. Vérifier le SSID est activé : Settings → WiFi → statut du réseau WiFi
2. Vérifier le VLAN associé au SSID
3. Vérifier que l'AP couvre la zone (signal > -70 dBm)
4. Clients → chercher l'appareil → voir le signal et la raison de déconnexion

Problème : mauvaise performance WiFi
1. Wireless → Channel Utilization → canaux encombrés
2. Forcer un scan : Devices → AP → RF Scan
3. Changer le canal manuellement si interférences
```

---

# PARTIE 2 — MIKROTIK

## 2.1 ACCÈS CONSOLE MIKROTIK

| Méthode | Accès |
|---|---|
| **Winbox** | Application Windows — IP ou MAC address |
| **WebFig** | http://[IP_MIKROTIK] |
| **SSH** | ssh admin@[IP_MIKROTIK] |
| **Console série** | 115200 baud, 8N1 |
| **The Dude / Cloud** | Monitoring centralisé Mikrotik |

```
⛔ Credentials : voir Passportal
```

## 2.2 HEALTH CHECK MIKROTIK

### Via SSH / Winbox CLI
```bash
# Connexion SSH
ssh admin@[IP_MIKROTIK]

# État système
/system resource print

# Interfaces
/interface print
/interface monitor-traffic [INTERFACE] once

# Routes
/ip route print

# Adresses IP
/ip address print

# VPN actifs
/interface pppoe-client print        # PPPoE (ISP)
/ip ipsec active-peers print         # IPSec tunnels
/interface l2tp-server sessions print # L2TP VPN

# Logs récents
/log print where topics~"error"
/log print where topics~"critical"

# Vérifier les services actifs
/ip service print
```

## 2.3 VPN MIKROTIK

### VPN L2TP/IPSec (clients distants)
```bash
# Vérifier les connexions actives
/interface l2tp-server sessions print

# Vérifier la configuration du serveur VPN
/interface l2tp-server server print
/ip ipsec policy print
/ip ipsec proposal print
/ip ipsec peer print

# Logs VPN
/log print where topics~"ipsec"
```

### VPN IPSec Site-à-site
```bash
# Voir les tunnels établis
/ip ipsec active-peers print

# Voir les SAs actives
/ip ipsec installed-sa print

# Forcer la reconnexion d'un tunnel
/ip ipsec active-peers kill numbers=[ID]
# Le tunnel se reconnecte automatiquement
```

## 2.4 MISE À JOUR ROUTERBOARD MIKROTIK

```bash
# Via SSH
# Vérifier la version actuelle
/system routerboard print
/system resource get version

# Vérifier les mises à jour disponibles
/system package update check-for-updates

# ⚠️ Appliquer la mise à jour — redémarrage requis
/system package update install
# Le routeur redémarre automatiquement

# Mise à jour du firmware RouterBOARD
/system routerboard upgrade
/system reboot
```

## 2.5 BACKUP CONFIGURATION MIKROTIK

```bash
# Backup binaire (restauration complète)
/system backup save name=backup_$(date +%Y%m%d)

# Export texte (lisible, partiel)
/export file=config_$(date +%Y%m%d)

# Télécharger via FTP/SFTP ou via Winbox → Files
```

---

## 3. NE PAS FAIRE — UNIFI ET MIKROTIK

### UniFi
```
⛔ NE JAMAIS "Forget" un device depuis le contrôleur sans le reconfigurer physiquement
⛔ NE JAMAIS supprimer un site dans UniFi Cloud (irréversible avec perte de config)
⛔ NE PAS mettre à jour le contrôleur UniFi sans backup préalable
```

### MikroTik
```
⛔ NE JAMAIS exécuter /ip firewall filter add sans avoir testé la règle
⛔ NE JAMAIS désactiver le service Winbox sur le port 8291 sans avoir un accès alternatif
⛔ NE PAS appliquer une mise à jour firmware sans backup de la configuration
⛔ NE JAMAIS "Reset Configuration" sans backup — remet le routeur en configuration d'usine
```

---

## 4. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Site entier offline (gateway down) | NOC | Immédiat |
| Tous les APs WiFi offline | NOC | 15 min |
| Contrôleur UniFi inaccessible | INFRA | 30 min |
| Tunnel VPN MikroTik down persistant | NOC | 30 min |
<!-- RUNBOOK_END: RUNBOOK__Unifi_Mikrotik_Operations_V1 -->

---

<!-- RUNBOOK_START: RUNBOOK__WatchGuard_Operations_V1 (INFRA__RUNBOOK__WatchGuard_Operations_V1.md) -->
# RUNBOOK — WatchGuard Firebox : Opérations & Dépannage
**ID :** RUNBOOK__WatchGuard_Operations_V1
**Version :** 1.0 | **Agents :** IT-NetworkMaster, IT-Assistant-N3
**Domaine :** INFRA — Réseau / Firewall
**Mis à jour :** 2026-03-20

---

## 1. ACCÈS CONSOLE WATCHGUARD

| Méthode | Accès |
|---|---|
| **Web UI** | https://[IP_Firebox]:8080 (HTTP) ou 443 (HTTPS) |
| **WSM** | WatchGuard System Manager (application Windows) |
| **CLI** | SSH sur port 4118 |
| **WatchGuard Cloud** | https://ui.watchguard.com |

```
⛔ Credentials : voir Passportal — jamais documenter ici
⛔ NE PAS partager le compte admin principal — utiliser des comptes nominatifs
```

---

## 2. HEALTH CHECK WATCHGUARD

### Via Web UI
```
1. Connexion → Dashboard → Device Status
   → CPU, Mémoire, Connexions actives, Débit
   → Statut des interfaces (verts = actifs)
   → Alertes actives

2. System Status → Traffic Monitor
   → Connexions bloquées inhabituelles

3. VPN → VPN Statistics
   → Tunnels VPN actifs (Mobile VPN + Branch Office VPN)

4. System → Certificates
   → Dates d'expiration des certificats
   → Seuil : alerter si < 30 jours
```

### Via CLI (SSH port 4118)
```bash
# Connexion SSH
ssh -p 4118 admin@[IP_FIREBOX]

# État des interfaces
ifconfig

# Connexions actives
conntrack -L | head -50

# Statut VPN
show vpn

# Logs récents
show log | tail -100
```

---

## 3. VPN WATCHGUARD — TYPES ET DÉPANNAGE

### Mobile VPN SSL (utilisateurs distants)
```
Configuration : VPN → Mobile VPN → SSL
Port par défaut : 443 (TCP) ou 1194 (UDP)
Client : WatchGuard Mobile VPN with SSL

Dépannage connexion SSL VPN :
1. Vérifier que le service Mobile VPN SSL est actif : VPN → Mobile VPN → SSL → Enable
2. Vérifier le groupe de l'utilisateur : Authentication → Users and Groups
3. Vérifier le certificat SSL (expiration)
4. Vérifier les logs : Firewall → Log → Traffic Monitor → filtrer "SSL-VPN"
```

### Mobile VPN IKEv2 / IPSec
```
Port : UDP 500 + 4500 (IKEv2)
Dépannage :
1. Vérifier que l'utilisateur est dans le bon groupe VPN
2. Vérifier la politique d'accès Mobile VPN IPSec
3. Comparer les paramètres Phase 1 / Phase 2 avec le client
```

### Branch Office VPN (BOVPN) — Site-à-site
```
Configuration : VPN → Branch Office VPN → Manual BOVPN
Dépannage tunnel down :
1. WEB UI → VPN → Statistics → voir le tunnel en question
2. Vérifier que les deux côtés ont la même clé partagée (voir Passportal)
3. Vérifier les routes : les sous-réseaux doivent correspondre exactement
4. Relancer le tunnel : bouton "Reset" sur la statistique VPN
5. Si persistant : vérifier les logs IKE sur les deux côtés
```

---

## 4. GESTION DES RÈGLES FIREWALL

### Vérifier une règle existante
```
WEB UI → Firewall → Firewall Policies
→ Rechercher par nom, source ou destination
→ Vérifier que la règle est activée (coche verte)
→ Vérifier les logs de la règle : clic droit → View Log
```

### Dépannage connexion bloquée
```
1. Traffic Monitor → filtrer par IP source ou destination
2. Identifier la règle qui bloque (colonne "Rule")
3. Déterminer si le blocage est intentionnel ou non
4. Si ajout de règle nécessaire → TOUJOURS documenter dans CW avant modification
   ⛔ NE PAS modifier les règles en production sans billet et approbation
```

---

## 5. RENOUVELLEMENT CERTIFICAT WEB UI

```
⚠️ Le certificat Web UI expire régulièrement — surveiller l'expiration

Via WEB UI :
1. System → Certificates → View Certificates
2. Identifier le certificat "WatchGuard HTTPS Proxy Authority" ou le certificat Web
3. Si < 30 jours : planifier le renouvellement

Option 1 — Certificat auto-signé (simple) :
System → Certificates → Certificates → Regenerate

Option 2 — Certificat tiers (recommandé) :
System → Certificates → Import → coller le certificat et la clé privée
⛔ Clé privée → voir Passportal, jamais dans CW
```

---

## 6. MISE À JOUR FIRMWARE

```
⚠️ TOUJOURS sauvegarder la configuration avant une mise à jour

1. Backup configuration :
   System → Backup Image → sauvegarder localement + Passportal

2. Télécharger le firmware :
   https://software.watchguard.com/SoftwareDownloads

3. Appliquer :
   System → Software Management → Upload New Software
   → Sélectionner le fichier .sysa-dl
   → Planifier le reboot (hors heures ouvrables)

4. Validation post-mise à jour :
   → Interfaces actives
   → Règles firewall intactes
   → Tunnels VPN reconnectés
   → Accès Internet fonctionnel
```

---

## 7. NE PAS FAIRE

```
⛔ NE JAMAIS modifier les règles firewall sans billet CW et approbation
⛔ NE JAMAIS désactiver le firewall pour tester — créer une règle de test temporaire
⛔ NE JAMAIS stocker les credentials WatchGuard dans CW — utiliser Passportal
⛔ NE JAMAIS appliquer une mise à jour firmware en heures de production
   sans fenêtre de maintenance approuvée
⛔ NE PAS ouvrir des ports en "Any" vers "Any" — toujours limiter la source et destination
```

---

## 8. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Firewall inaccessible (pas de connexion Internet) | NOC | Immédiat |
| Tunnels VPN tous down | NOC | 15 min |
| Intrusion détectée / logs suspects | SOC | Immédiat |
| Renouvellement certificat < 7 jours | INFRA | Dans la journée |
<!-- RUNBOOK_END: RUNBOOK__WatchGuard_Operations_V1 -->

---
