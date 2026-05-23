# INFRA-NET-SonicWall_Operations_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__SonicWall_Operations_V1
**Version :** 1.0 | **Agents :** IT-NetworkMaster, IT-Assistant-N3
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
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
