# INFRA-NET-Fortinet_Operations_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__Fortinet_Operations_V1
**Version :** 1.0 | **Agents :** IT-NetworkMaster, IT-Assistant-N3
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
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
