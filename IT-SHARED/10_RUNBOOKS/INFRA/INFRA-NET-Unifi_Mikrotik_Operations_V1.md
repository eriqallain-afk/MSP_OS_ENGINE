# INFRA-NET-Unifi_Mikrotik_Operations_V1
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

# PARTIE 1 — UBIQUITI UNIFI
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

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
