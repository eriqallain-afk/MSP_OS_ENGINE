# MAINT-OPS-CMDB_AssetAudit_V1
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** MAINT | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__CMDB_Asset_Audit_V1
**Version :** 1.0 | **Agents :** IT-AssetMaster, IT-MaintenanceMaster
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Domaine :** INFRA — CMDB / Gestion des actifs
**Mis à jour :** 2026-03-20

---

## 1. CMDB CONNECTWISE MANAGE — STRUCTURE

```
ConnectWise Manage → Companies → [Client] → Configurations

Types d'actifs dans CW :
→ Servers (serveurs physiques et VMs)
→ Workstations (postes de travail)
→ Network Devices (switches, routers, firewalls, APs)
→ Printers (imprimantes)
→ Licenses (licences logicielles)
→ Other Hardware
```

---

## 2. AUDIT CMDB — VÉRIFICATION PÉRIODIQUE

### Fréquence recommandée
```
Mensuel : vérifier les configurations modifiées récemment
Trimestriel : audit complet par client
Annuel : nettoyage complet, archivage des actifs retirés
```

### Checklist d'audit CMDB

```
Pour chaque actif, vérifier :

SERVEURS
[ ] Nom de l'actif correspond au hostname réel
[ ] IP dans CW correspond à l'IP réelle (vérifier dans RMM ou réseau)
[ ] OS et version à jour
[ ] Date d'installation renseignée
[ ] Make/Model renseigné
[ ] Warranty expiry date renseignée
[ ] Fiche Hudu créée et à jour (via IT-ClientDocMaster)

POSTES DE TRAVAIL
[ ] Nom de l'actif = hostname Windows réel
[ ] Utilisateur assigné à jour
[ ] OS et version
[ ] Date d'installation
[ ] Make/Model + Serial Number

ÉQUIPEMENTS RÉSEAU
[ ] Nom = nom de l'appareil dans la console (WatchGuard, Meraki, etc.)
[ ] IP de gestion renseignée
[ ] Make/Model + Firmware version
[ ] Date d'installation
[ ] Warranty / Support expiry

ACTIFS RETIRÉS
[ ] Actifs hors service marqués "Inactive" ou "Retired"
[ ] NE PAS supprimer — archiver (traçabilité)
```

---

## 3. SYNCHRONISATION CW ↔ RMM

```
Les RMM (CW Automate, N-able, Datto RMM) peuvent synchroniser automatiquement
les actifs dans ConnectWise Manage.

Vérifier que la synchronisation est active :
→ CW Automate : Admin → Integrations → ConnectWise Manage → Asset Sync
→ N-able : Administration → ConnectWise Integration → Asset Mapping

Si un actif apparaît dans le RMM mais pas dans CW :
1. Vérifier le mapping du site/client dans le RMM
2. Forcer une synchronisation manuelle
3. Si toujours absent → créer manuellement dans CW
```

---

## 4. VÉRIFICATION HUDU ↔ CW

```
Les configurations CW et les fiches Hudu doivent être cohérentes.

Incohérences courantes à corriger :
→ Serveur dans CW sans fiche Hudu → créer la fiche (via IT-ClientDocMaster)
→ Fiche Hudu avec infos obsolètes → mettre à jour
→ Actif retiré dans CW mais fiche Hudu encore active → archiver la fiche Hudu
→ IP différente dans CW vs Hudu → réconcilier avec l'info correcte

Règle : CW = source de vérité pour les actifs | Hudu = source de vérité pour la documentation
```

---

## 5. RAPPORT D'ACTIFS PAR CLIENT

```powershell
# Script de rapport d'inventaire via CW API (si API configurée)
# Alternativement, exporter depuis CW :

# CW Manage → System → Reports → Configuration Reports
# → Configuration List par client
# → Exporter en Excel/CSV

# Analyse de base :
# - Combien d'actifs par type
# - Actifs avec warranty expirée
# - Actifs avec OS obsolète (Windows Server 2012/2016 end of life)
# - Actifs sans date d'installation (données incomplètes)
```

---

## 6. GESTION DU CYCLE DE VIE DES ACTIFS

### Étapes du cycle
```
NOUVEAU ACTIF
1. Réception physique
2. Configuration initiale
3. Création dans CW Manage (Configuration)
4. Création fiche Hudu (IT-ClientDocMaster)
5. Ajout dans RMM (monitoring)

EN PRODUCTION
→ Mises à jour régulières dans CW et Hudu
→ Suivi des garanties et licences
→ Rapport d'état mensuel

FIN DE VIE / REMPLACEMENT
1. Vérifier que les données sont migrées
2. Désinstaller les agents RMM
3. Marquer "Inactive" dans CW (ne pas supprimer)
4. Archiver la fiche Hudu
5. Documenter la date de retrait et le motif
```

### Alertes de renouvellement
```
Warranty expiry < 6 mois :
→ Créer une tâche CW pour le client : évaluation renouvellement/remplacement

End of Life OS :
→ Windows Server 2012 : EOL depuis oct 2023
→ Windows Server 2016 : EOL en 2027
→ Windows 10 : EOL en oct 2025
→ Créer un plan de migration
```

---

## 7. NE PAS FAIRE

```
⛔ NE JAMAIS supprimer un actif de CW — toujours marquer "Inactive" ou "Retired"
⛔ NE JAMAIS créer des doublons dans CW — vérifier avant toute création
⛔ NE PAS laisser le champ "Status" vide dans les configurations CW
⛔ NE PAS stocker les informations de connexion (IP, ports) dans CW sans les masquer
   → Utiliser Passportal pour les credentials
   → Utiliser Hudu pour la documentation des accès
⛔ NE PAS ignorer les actifs sans utilisateur assigné — investiguer
```

---

## 8. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Actifs non détectés par RMM (shadow IT potentiel) | SOC | Dans la journée |
| Warranty expirée sur actifs critiques | TECH + client | Planifié |
| Incohérences massives CMDB (> 20 actifs manquants) | INFRA | Dans la semaine |
