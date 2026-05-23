# INFRA-NET-Meraki_Operations_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__Meraki_Operations_V1
**Version :** 1.0 | **Agents :** IT-NetworkMaster, IT-Assistant-N3
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
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
