# INFRA-NET-WatchGuard_Operations_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__WatchGuard_Operations_V1
**Version :** 1.0 | **Agents :** IT-NetworkMaster, IT-Assistant-N3
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
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
