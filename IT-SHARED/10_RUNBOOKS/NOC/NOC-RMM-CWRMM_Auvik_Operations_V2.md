# NOC-RMM-CWRMM_Auvik_Operations_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-Commandare-NOC | @IT-BackupDRMaster | @IT-MonitoringMaster | @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** NOC | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__CWRMM_Auvik_Operations_V1
**Version :** 1.0 | **Agents :** IT-MonitoringMaster, IT-Commandare-NOCDispatcher, IT-Assistant-N3
**Domaine :** NOC — RMM & Network Monitoring
**Mis à jour :** 2026-03-20

---

# PARTIE 1 — CONNECTWISE RMM (CW AUTOMATE / COMMAND)
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

## 1.1 ACCÈS CONNECTWISE RMM

| Produit | Accès |
|---|---|
| **CW Automate (LabTech)** | https://[votre-serveur]:443 |
| **CW Command** | https://command.connectwise.com |
| **CW Manage (PSA)** | https://[votre-serveur]/ConnectWise ou SaaS |

---

## 1.2 HEALTH CHECK MATINAL CW RMM

```
CW Automate → Dashboard
→ Agents Online/Offline
→ Alertes actives par priorité
→ Patch Status

CW Command → Summary
→ Device health par site
→ Alertes NOC
→ Tickets ouverts liés aux alertes
```

---

## 1.3 ALERTES CW RMM — TRAITEMENT

```
CW Automate → Monitors → Alert Tickets
→ Tickets créés automatiquement par les moniteurs

Traitement :
1. Ouvrir le ticket d'alerte dans CW Manage
2. Acquitter l'alerte dans CW Automate
3. Investiguer selon le type d'alerte (voir tableau ci-dessous)
4. Documenter les actions dans la note CW interne
5. Fermer l'alerte si résolue

Moniteurs typiques et actions :

| Moniteur | Seuil | Action |
|---|---|---|
| CPU Alert | > 85% 15 min | Vérifier processus |
| Disk Space | < 10% | Nettoyage + escalade |
| Service Down | Service critique | Restart-Service |
| Windows Update | > 30 jours sans patch | Planifier patching |
| Backup Failure | Job Veeam/Datto | Voir runbook backup |
| Event Log Error | ID 1000/6008/etc | Analyser + escalade |
| Agent Offline | > 5 min | Vérifier réseau |
```

---

## 1.4 SCRIPTS CW AUTOMATE — EXÉCUTION

```
CW Automate → Script Manager
→ Rechercher le script
→ Clic droit → Run Now → sélectionner le ou les appareils
→ Voir les résultats : Script Logs

Créer un script one-shot rapide :
Scripts → New Script → PowerShell → coller le code → Save → Run
```

---

## 1.5 MODE MAINTENANCE CW AUTOMATE

```
Computers → [Ordinateur] → Actions → Set Maintenance Mode
→ Durée : en minutes
→ Tous les moniteurs sont suspendus pendant la durée

⚠️ OBLIGATOIRE avant maintenance planifiée
⚠️ TOUJOURS désactiver après
```

---

## 1.6 PATCH MANAGEMENT CW AUTOMATE

```
Patch Manager → Patch Status
→ Vue par client/site
→ Filtrer : Missing Critical Patches

Approuver et planifier :
1. Patch Policies → sélectionner la politique du client
2. Approuver les catégories : Security Updates, Critical Updates
3. Patch Window : configurer la fenêtre de maintenance (ex: sam 02h00)
4. Results : Patch History → vérifier le résultat
```

---

# PARTIE 2 — AUVIK

## 2.1 PRÉSENTATION AUVIK

Auvik est une solution de **Network Monitoring & Management** cloud.
Il découvre, cartographie et supervise l'infrastructure réseau (switches, routers, firewalls, APs).

**Portail :** https://[votre-domaine].auvik.com

---

## 2.2 HEALTH CHECK AUVIK

```
Dashboard → Overview
→ Devices : Online/Offline/Warning
→ Alertes actives
→ Network Topology : carte du réseau

Devices → [Client]
→ Statut de chaque équipement réseau
→ CPU/Memory/Interface utilization
→ Dernière communication (timestamp)
```

---

## 2.3 ALERTES AUVIK

```
Alerts → Active Alerts
→ Trier par : Severity, Device, Type

Types d'alertes Auvik fréquentes :

| Type | Signification | Action |
|---|---|---|
| Device Offline | Plus de polling SNMP | Vérifier connectivité + escalade NOC |
| Interface Down | Port réseau down | Vérifier câble + appareil connecté |
| High Interface Utilization | Bande passante > seuil | Analyser trafic + escalade NOC |
| Config Change | Configuration modifiée | Vérifier qui a fait le changement |
| License Expiry | Licence équipement proche expiration | Planifier renouvellement |
```

---

## 2.4 TOPOLOGIE ET CARTOGRAPHIE RÉSEAU

```
Network → Topology
→ Vue graphique de l'infrastructure réseau
→ Cliquer sur un équipement → détails (interfaces, IP, MAC, neighbours)

Utile pour :
→ Identifier un équipement inconnu
→ Tracer le chemin réseau entre deux points
→ Identifier les équipements non managés
```

---

## 2.5 HISTORIQUE DE CONFIGURATION (CONFIG BACKUP)

```
Devices → [Équipement] → Configuration
→ Voir les configurations sauvegardées automatiquement
→ Comparer deux versions (diff)
→ Télécharger une version pour restauration

⚠️ Si Auvik détecte un changement de configuration → alerte automatique
→ Vérifier si le changement était planifié
→ Si non planifié : investiguer → escalade SOC si suspect
```

---

## 3. NE PAS FAIRE

### CW RMM
```
⛔ NE JAMAIS exécuter un script à risque (suppression, modification système) sans test
⛔ NE PAS oublier le mode maintenance avant intervention
⛔ NE JAMAIS supprimer un agent CW sans désinstaller logiciellement d'abord
```

### Auvik
```
⛔ NE JAMAIS ignorer une alerte "Config Change" non planifiée — peut indiquer une compromission
⛔ NE PAS supprimer des équipements d'Auvik sans désinstaller l'agent Auvik
⛔ NE PAS modifier les seuils d'alerte sans documenter la raison
```

---

## 4. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Plusieurs équipements offline simultanément (Auvik) | NOC | Immédiat |
| Config Change non planifié sur firewall/switch | SOC | Dans l'heure |
| CW RMM inaccessible | NOC + INFRA | 30 min |
| > 50 alertes critiques simultanées | NOC | Immédiat |
