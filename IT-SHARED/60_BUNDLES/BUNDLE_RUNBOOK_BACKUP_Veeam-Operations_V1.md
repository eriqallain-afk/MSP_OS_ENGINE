# BUNDLE RUNBOOK BACKUP Veeam-Operations V1
**Type :** Bundle Runbook — Assemblage complet
**Agents :** IT-BackupDRMaster, IT-MaintenanceMaster, IT-Assistant-N3 | IT-SysAdmin
**Description :** Veeam Backup — Opérations locales et cloud, restauration, test DR
**Mis à jour :** 2026-03-20

> Ce bundle regroupe runbooks + templates + checklists liés à ce domaine.
> Uploader en Knowledge dans les GPTs concernés.


---
<!-- SOURCE: RUNBOOK__IT_VEEAM_OPERATIONS_V1 -->
## RUNBOOK — Veeam Backup Operations (Console)

# RUNBOOK — VEEAM Backup Operations (MSP)
**ID :** RUNBOOK__IT_VEEAM_OPERATIONS_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N3, IT-BackupDRMaster
**Mis à jour :** 2026-03-20

---

## 1. VÉRIFICATION QUOTIDIENNE — ÉTAT DES JOBS

### Procédure de vérification matinale
```
1. Ouvrir VBR Console → onglet Home → Last 24 Hours
2. Vérifier le statut de chaque job :
   ✅ Success   → OK, aucune action
   ⚠️ Warning   → Ouvrir le job → lire le message → décider
   ❌ Failed    → Intervention immédiate → voir section 2
   🔵 Running  → Normal si dans la fenêtre de maintenance
                 Anormal si hors fenêtre → investiguer

3. Vérifier l'espace des repositories :
   VBR Console → Backup Infrastructure → Backup Repositories
   → Espace libre > 20% → OK
   → Espace libre < 20% → alerte → voir section 5

4. Vérifier les Veeam Agents (postes/serveurs sans agent VBR) :
   VBR Console → Inventory → Physical Infrastructure
   → Statut de chaque agent
```

---

## 2. JOB EN ÉCHEC (FAILED) — DIAGNOSTIC

### Lire l'erreur exacte
```
1. VBR Console → Jobs → clic droit sur le job → Statistics
2. Cliquer sur la session en échec
3. Lire le message d'erreur dans le volet inférieur
4. Noter : le message EXACT, le VM/serveur concerné, l'heure d'échec
```

### Tableau des erreurs courantes

| Message d'erreur | Cause probable | Action |
|---|---|---|
| `Unable to connect to the guest` | Agent VEEAM absent ou service arrêté sur la VM | Vérifier le service VeeamGuestHelper sur la VM cible |
| `Snapshot not found` | Snapshot VMware orphelin en conflit | vSphere → VM → Supprimer les snapshots orphelins |
| `Insufficient space` | Repository plein | Agrandir le repository OU purger les restore points anciens |
| `Access denied` | Compte de service VEEAM sans droits suffisants | Vérifier les droits du compte service sur la cible |
| `Network error` / `Connection refused` | Problème réseau entre serveur VEEAM et cible | Ping du serveur VEEAM vers la cible — vérifier firewall |
| `The process cannot access the file` | Fichier verrouillé par une application | Identifier l'application — planifier hors heures |
| `VSSControl: Failed to create VSS snapshot` | Problème VSS sur la VM | Exécuter `vssadmin list writers` sur la VM cible |
| `Task was canceled` | Timeout ou fenêtre de maintenance dépassée | Étendre la fenêtre ou optimiser le job |
| `Failed to download disk` | Problème datastore ou réseau vSphere | Vérifier la santé du datastore vSphere |
| `Backup job result: Warning — some VMs were excluded` | VMs en erreur exclues automatiquement | Identifier les VMs exclues dans le log détaillé |

### Diagnostics PowerShell — à exécuter sur le serveur VEEAM
```powershell
# Service VEEAM — vérifier qu'il tourne
Get-Service -Name "VeeamBackupSvc" | Select-Object Name, Status, StartType

# Connexion à la VM cible (remplacer par le nom réel)
# Test réseau depuis le serveur VEEAM
Test-NetConnection -ComputerName "NOM-VM-CIBLE" -Port 445
Test-NetConnection -ComputerName "NOM-VM-CIBLE" -Port 6160  # Port agent VEEAM

# VSS sur la VM cible (exécuter sur la VM elle-même)
vssadmin list writers
vssadmin list shadows
```

### Procédure — Problème VSS
```
Sur la VM affectée :
1. Exécuter : vssadmin list writers
   → Repérer les writers en état "Failed" ou "Waiting for completion"

2. Si writer en échec — redémarrer le service associé :
   Writer "SqlServerWriter"   → Restart-Service MSSQLSERVER
   Writer "IIS Metabase"      → Restart-Service IISADMIN
   Writer "Registry Writer"   → Redémarrer le serveur (dernier recours)
   Writer "System Writer"     → Redémarrer le serveur

3. Re-lancer le job VEEAM manuellement après correction
   ✅ Validation : job complète avec Success ou Warning acceptable

⛔ NE PAS ignorer un VSS writer en échec répété — escalader à IT-BackupDRMaster
```

---

## 3. JOB EN WARNING — ANALYSE

```
Warning ≠ Failed — le backup a réussi mais avec des anomalies.
TOUJOURS lire le détail avant de décider.

Warnings acceptables (à documenter) :
- VM éteinte au moment du job → normale si planifiée
- Quelques fichiers locked (log applicatifs) → normal
- Durée légèrement dépassée → surveiller la tendance

Warnings à investiguer :
- Retry count élevé (> 2 retries) → instabilité réseau ou ressources
- VM exclue automatiquement → TOUJOURS identifier pourquoi
- Espace repository < 30% → planifier expansion

Warnings à escalader vers IT-BackupDRMaster :
- Warning répété sur le même objet 3 jours consécutifs
- VM critique (DC, SQL, Exchange) avec warning
```

---

## 4. RESTAURATION FICHIER INDIVIDUEL

```
AVANT DE COMMENCER :
✅ Confirmer avec le client quel fichier / quelle version / quelle date
✅ Confirmer l'emplacement de restauration (original ou alternatif)
⛔ NE PAS restaurer à l'emplacement original sans confirmation explicite
   — tu vas écraser la version actuelle du fichier

ÉTAPES :
1. VBR Console → Backups → chercher la VM ou le serveur source
2. Clic droit → Restore guest files → Windows (ou Linux)
3. Sélectionner le point de restauration (date/heure)
   → Choisir le point le plus proche AVANT la perte
4. L'explorateur de restauration s'ouvre — naviguer jusqu'au fichier
5. Clic droit sur le fichier :
   → "Restore" → Original location (écrase l'existant — confirmer)
   → "Copy to" → Emplacement alternatif (plus sûr)
6. Vérifier que le fichier restauré est complet et non corrompu
   ✅ Validation : l'utilisateur ouvre le fichier et confirme que le contenu est correct

⛔ NE PAS fermer la session de restauration avant validation par l'utilisateur
⛔ NE PAS restaurer plusieurs versions en même temps
```

---

## 5. RESTAURATION VM COMPLÈTE

```
⚠️ [ACTION CRITIQUE — IMPACT MAJEUR]
Cette action va remplacer ou recréer une VM entière.
Risques : perte des données depuis le dernier backup, impact sur les utilisateurs.
Confirmes-tu l'exécution ? (oui / non)

PRÉ-REQUIS AVANT DE COMMENCER :
✅ Approbation du superviseur ou du client obtenue par écrit
✅ Confirmer le dernier point de restauration valide
✅ Confirmer l'environnement cible (même datastore ? même réseau ?)
✅ Vérifier l'espace disponible sur le datastore cible
✅ NOC informé (impact potentiel sur les utilisateurs)

ÉTAPES :
1. VBR Console → Backups → trouver la VM cible
2. Clic droit → Restore entire VM
3. Sélectionner le point de restauration
4. Choisir la destination :
   → "Restore to original location" : remplace la VM existante
   → "Restore to new location" : crée une nouvelle VM (préférable pour test)
5. Options de restauration :
   → Power on VM after restoring : selon le besoin
   → Connected to network : décocher pour test avant mise en production
6. Lancer la restauration — surveiller la progression dans VBR
7. Validation post-restauration :
   → VM démarrée et accessible (RDP/ping)
   → Services critiques fonctionnels (AD, SQL, IIS selon le rôle)
   → Données intègres — vérification avec le client
   → Mise à jour CMDB (Hudu) si changement de configuration

⛔ NE PAS mettre la VM restaurée en production sans validation complète
⛔ NE PAS supprimer l'ancienne VM avant validation de la restaurée
⛔ NE PAS oublier de reconnecter au réseau après validation en isolation
```

---

## 6. GESTION DU REPOSITORY — ESPACE DISQUE

### Vérification de l'espace
```powershell
# Sur le serveur VEEAM — espace des repositories
# (Exécuter dans VBR Console → Backup Infrastructure → Repositories)
# Ou via PowerShell si module VEEAM chargé :
Get-VBRBackupRepository | Select-Object Name,
  @{N='TotalGB';E={[math]::Round($_.Info.CachedTotalSpace/1GB,1)}},
  @{N='FreeGB';E={[math]::Round($_.Info.CachedFreeSpace/1GB,1)}},
  @{N='Free%';E={[math]::Round($_.Info.CachedFreeSpace/$_.Info.CachedTotalSpace*100,0)}}
```

### Libérer de l'espace — procédure
```
Option 1 — Purge automatique (safe)
→ VBR Console → Backup Repository → clic droit → Compact full backup
→ VBR supprime automatiquement les restore points hors politique de rétention
✅ Validation : espace libéré visible dans les propriétés du repository

Option 2 — Supprimer manuellement des restore points anciens
→ VBR Console → Backups → clic droit sur le backup → Delete from disk
⚠️ [ACTION À RISQUE] Tu vas supprimer des points de restauration définitivement.
⛔ NE PAS supprimer les restore points en dehors de la politique de rétention définie
⛔ NE PAS supprimer le seul restore point existant pour une VM critique

Option 3 — Étendre le repository
→ Escalader à IT-BackupDRMaster ou IT-Commandare-Infra
```

---

## 7. VEEAM AGENT — POSTES ET SERVEURS

### Vérifier l'état d'un agent
```
VBR Console → Inventory → Physical Infrastructure → chercher le poste
OU directement sur le poste :
→ Icône VEEAM dans la barre des tâches → ouvrir la console locale
→ Vérifier le dernier statut de backup
```

### Job d'agent en échec
```
Erreurs fréquentes sur les agents :

"Volume Shadow Copy Service error"
→ Même procédure VSS que section 2

"Failed to connect to Veeam backup server"
→ Vérifier que le poste est sur le réseau
→ Vérifier que le service VeeamBackupSvc tourne sur le serveur central
→ Vérifier le firewall (port 9501)

"Backup target is not available"
→ Vérifier que le repository cible est accessible (partage réseau ?)
→ Vérifier les droits du compte utilisateur sur le partage
```

---

## 8. TEST D'INTÉGRITÉ BACKUP

```
Fréquence recommandée : mensuel pour les VMs critiques (DC, SQL, Exchange)

MÉTHODE RAPIDE — Montage et connexion :
1. VBR Console → Backups → clic droit sur la VM → Instant Recovery
2. La VM démarre directement depuis le backup (sans restauration complète)
3. Tester RDP / connexion → vérifier les services critiques
4. Une fois validé : clic droit sur la session → Stop publishing
   ✅ Validation : la VM de test répond et les services fonctionnent
   ⚠️ NE PAS laisser la VM en mode Instant Recovery plus de 30 min
      en production — les écritures ne sont pas persistantes

MÉTHODE COMPLÈTE — SureBackup :
→ Configurer un SureBackup Job dans VBR
→ Il démarre la VM en isolation, exécute des tests automatiques, produit un rapport
→ Escalader à IT-BackupDRMaster pour la configuration initiale
```

---

## 9. ESCALADES BACKUP

| Situation | Escalader vers | Urgence |
|---|---|---|
| VM critique en échec 2 jours consécutifs | IT-BackupDRMaster | Dans l'heure |
| Repository à < 10% d'espace libre | IT-Commandare-Infra | Dans l'heure |
| Restauration VM complète requise | IT-BackupDRMaster + superviseur | Immédiat |
| Suspicion de corruption des backups | IT-BackupDRMaster | Immédiat |
| Datto en panne ou alerte critique | IT-Commandare-NOC | Immédiat |
| RTO dépassé (restauration trop longue) | IT-BackupDRMaster | Immédiat |

---

## 10. DOCUMENTATION POST-INTERVENTION

Après toute intervention VEEAM, documenter dans CW :
```
CW_NOTE_INTERNE :
- Job concerné + VM(s) affectée(s)
- Message d'erreur exact
- Cause identifiée
- Action corrective appliquée
- Résultat : job relancé manuellement → Success / Warning / Failed
- Suivi requis : Oui/Non

Si restauration effectuée :
- Point de restauration utilisé (date/heure)
- Type : fichier / VM complète
- Validé par : [nom du technicien / client]
- Données perdues depuis le backup : [période]
```

---

*Runbook v1.0 — 2026-03-20 — IT MSP Intelligence Platform*
*Agents : IT-Assistant-N3, IT-BackupDRMaster*


---
<!-- SOURCE: RUNBOOK__Veeam_Cloud_Operations_V1 -->
## RUNBOOK — Veeam Cloud Connect

# RUNBOOK — Veeam Cloud Connect & Backup as a Service
**ID :** RUNBOOK__Veeam_Cloud_Operations_V1
**Version :** 1.0 | **Agents :** IT-BackupDRMaster, IT-Assistant-N3
**Domaine :** INFRA — Backup Cloud
**Mis à jour :** 2026-03-20

---

## 1. PRÉSENTATION VEEAM CLOUD CONNECT

Veeam Cloud Connect permet de sauvegarder vers le cloud d'un fournisseur MSP
et d'effectuer des restaurations depuis le cloud (Disaster Recovery as a Service).

**Composants :**
- **Cloud Repository** : stockage cloud des backups off-site
- **Cloud Host** : hôte de réplication/restauration cloud
- **Service Provider Console** : portail MSP de gestion centralisée

---

## 2. ACCÈS ET GESTION

| Accès | Description |
|---|---|
| **VBR Console** | Console Veeam locale — configuration des jobs cloud |
| **Veeam Service Provider Console** | https://[URL_VSPC] — portail MSP centralisé |
| **Veeam Cloud Connect portail** | Interface client (si déployé) |

---

## 3. CONFIGURATION D'UN JOB BACKUP VERS LE CLOUD

```
Dans VBR Console (côté client) :
1. Backup Jobs → New Backup Job → [Nom] → Next
2. Virtual Machines : sélectionner les VMs à sauvegarder
3. Storage : choisir le Cloud Repository (fournisseur)
   → Celui-ci apparaît si le Cloud Connect est configuré
4. Guest Processing : activer VSS application-aware
5. Schedule : planification (ex: quotidien 22h)
6. Retention : nombre de points de restauration à conserver
7. Finish → Run Now (pour tester)
```

---

## 4. VÉRIFICATION DES BACKUPS CLOUD

```
VBR Console → Home → Last 24 Hours
→ Filtrer par Repository : Cloud Repository

Veem Service Provider Console :
VSPC → Companies → [Client] → Protected Data
→ Backup size
→ Dernière synchronisation réussie
→ Points de restauration disponibles
```

---

## 5. RESTAURATION DEPUIS LE CLOUD

### Restauration de fichiers
```
VBR Console → Backups → Cloud → [Backup]
→ Clic droit → Restore guest files
→ Sélectionner le point de restauration cloud
→ Browser → naviguer → Restore

⚠️ La restauration depuis le cloud est plus lente (dépend de la bande passante)
Compter : ~50-200 MB/s selon la connexion
```

### Failover vers le Cloud (Disaster Recovery)
```
⚠️ Procédure d'urgence — VM démarre dans le cloud du fournisseur

VBR Console → Backups → Cloud → [VM] → Failover to Cloud
→ Sélectionner le point de restauration
→ La VM démarre dans l'infrastructure cloud
→ Accès via VPN ou Direct Connect au fournisseur

Failback (retour au site primaire) :
1. VBR Console → Home → [VM en cours de Failover] → Failback to Production
2. Choisir la VM cible (restauration sur le site original)
3. Commiter le Failback une fois validé
```

---

## 6. SURVEILLANCE VIA SERVICE PROVIDER CONSOLE

```
VSPC → Alarms
→ Backup Jobs Failed
→ License Usage
→ Storage Usage Warnings

VSPC → Reporting → Backup Status Report
→ Export PDF/HTML pour rapport client
```

---

## 7. GESTION DES QUOTAS CLOUD

```
Si le quota de stockage cloud est dépassé :
1. VSPC → Companies → [Client] → Edit → Cloud Resources → Adjust quota
2. OU supprimer d'anciens points de restauration dans VBR
3. Vérifier la politique de rétention (durée et nombre de points)
```

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS supprimer un Cloud Repository actif sans avoir vérifié les dépendances
⛔ NE JAMAIS laisser un Failover actif > 72h sans plan de Failback validé
⛔ NE PAS ignorer les alertes de quota dépassé (les backups s'arrêtent)
⛔ NE JAMAIS modifier les paramètres de bande passante Cloud Connect en heures de production
   sans préavis au client
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Synchronisation cloud en échec > 48h | BackupDR | Dans l'heure |
| Quota cloud dépassé | BackupDR + TECH | Dans la journée |
| Failover cloud activé | BackupDR + INFRA | Suivi immédiat |
| Restauration urgente depuis cloud | BackupDR | Immédiat |


---
<!-- SOURCE: TEMPLATE_BACKUP_DR-Test-et-Restore_V1 -->
## TEMPLATE — Rapport DR Test et Demande de Restauration

# TEMPLATE_BACKUP_DR-Test-et-Restore_V1
**Agent :** IT-BackupDRMaster, IT-MaintenanceMaster
**Usage :** Rapport de test DR + Demande de restauration formelle
**Mis à jour :** 2026-03-20

---

## PARTIE 1 — RAPPORT TEST DR

```
═══════════════════════════════════════════════
RAPPORT TEST DISASTER RECOVERY
Client        : [NOM CLIENT]
Date du test  : [YYYY-MM-DD]
Effectué par  : [Technicien]
Billet CW     : #[XXXXXX]
Solution backup : [Datto / Veeam / Keepit / Autre]
═══════════════════════════════════════════════

SCÉNARIO TESTÉ
Type : [Restauration fichier / VM complète / Instant Virtualization / Bare Metal]
Asset testé  : [Nom VM ou serveur]
Point de restauration utilisé : [Date/heure du snapshot]
Objectif RPO : [Xh] | Objectif RTO : [Xh]

PROCÉDURE EXÉCUTÉE
1. [Étape 1 — ex: Démarrage VM via Instant Virtualization Datto]
2. [Étape 2 — ex: Test RDP/connexion]
3. [Étape 3 — ex: Validation des services critiques]
4. [Étape 4 — ex: Arrêt de la VM de test]

RÉSULTATS
RPO réel : [Xh depuis le dernier backup sain]
RTO réel : [Xh Ymin pour atteindre un état opérationnel]

Validation :
☐ VM/système a démarré correctement
☐ Services critiques opérationnels : [Liste]
☐ Données accessibles et intègres
☐ Accès réseau/utilisateurs fonctionnel (si testé)
☐ Screenshot backup présent (Datto)

Résultat global : ✅ PASS / ❌ FAIL / ⚠️ PARTIEL

ÉCARTS ET ACTIONS CORRECTIVES
[Si FAIL ou PARTIEL : décrire l'écart et l'action pour y remédier]

PROCHAINE DATE DE TEST RECOMMANDÉE : [YYYY-MM-DD]
═══════════════════════════════════════════════
```

---

## PARTIE 2 — DEMANDE DE RESTAURATION

```
═══════════════════════════════════════════════
DEMANDE DE RESTAURATION
Billet CW      : #[XXXXXX]
Client         : [NOM]
Date/Heure     : [YYYY-MM-DD HH:MM]
Demandé par    : [Nom utilisateur / responsable]
Technicien     : [NOM]
═══════════════════════════════════════════════

OBJET DE LA RESTAURATION
Type : ☐ Fichier(s)/Dossier(s)  ☐ VM complète  ☐ Base de données  ☐ Autre

Fichier(s) concerné(s) :
• [Chemin et nom exact du fichier ou dossier]
• [Fichier 2 si applicable]

Serveur/VM source : [NOM]
Solution backup   : [Datto / Veeam / Keepit]

POINT DE RESTAURATION DEMANDÉ
Date/heure souhaitée : [YYYY-MM-DD HH:MM]
(dernier backup disponible avant la perte/corruption)

DESTINATION
☐ Emplacement original (écrase l'existant — confirmer avec client)
☐ Emplacement alternatif : [Préciser le chemin]
☐ Téléchargement local (pour vérification)

AUTORISATION
Autorisé par : [Nom du responsable client]
Méthode      : ☐ Verbal  ☐ Email  ☐ Teams  ☐ Billet CW

VALIDATION POST-RESTAURATION
[ ] Fichier ouvert et contenu vérifié par [utilisateur]
[ ] Données intègres confirmées
[ ] Billet CW complété avec résultats
═══════════════════════════════════════════════
```


---
<!-- SOURCE: CHECKLIST_BACKUP_DR-Readiness_V1 -->
## CHECKLIST — DR Readiness

# CHECKLIST_BACKUP_DR-Readiness_V1
**Agent :** IT-BackupDRMaster, IT-MaintenanceMaster
**Usage :** Vérification mensuelle de la disponibilité du plan de relève
**Mis à jour :** 2026-03-20

---

## BACKUPS — ÉTAT COURANT

### Datto BCDR
- [ ] Tous les agents : dernier backup Success ou Warning acceptable
- [ ] Screenshot de vérification présent pour les VMs critiques
- [ ] Stockage local Datto : espace libre > 20%
- [ ] Stockage cloud : synchronisation OK (pas d'erreur > 24h)
- [ ] Rétention configurée selon la politique client (Hudu → Agreements)

### Veeam
- [ ] Jobs en cours : Success ou Warning acceptable
- [ ] Repository : espace libre > 20%
- [ ] Dernière vérification d'intégrité (SureBackup ou Instant Recovery test) < 30 jours
- [ ] Veeam Cloud Connect (si applicable) : synchronisation OK

### Keepit (M365)
- [ ] Connecteur Microsoft 365 : Connected (pas Disconnected)
- [ ] Dernière synchronisation Exchange : OK
- [ ] Dernière synchronisation SharePoint/OneDrive : OK
- [ ] Nombre d'utilisateurs protégés = nombre d'utilisateurs actifs

---

## PLAN DE RELÈVE — VALIDITÉ

- [ ] Document DR à jour dans Hudu pour ce client (date < 6 mois)
- [ ] Contacts d'urgence à jour (responsable client, MSP on-call)
- [ ] RTO et RPO documentés et connus de l'équipe
- [ ] Ordre de démarrage des systèmes documenté
- [ ] Accès aux ressources de reprise validé (accès Datto portal, VPN, credentials Passportal)

---

## TESTS DR

- [ ] Dernier test d'intégrité backup : _______ (date)
  - Résultat : ☐ Pass  ☐ Fail → Actions correctives : _______
- [ ] Dernier test Instant Virtualization : _______ (date)
  - RTO mesuré : _______ min / Objectif : _______ min
- [ ] Prochain test planifié : _______

---

## VÉRIFICATION ANNUELLE

- [ ] Test complet DR (Tabletop ou Functional) effectué cette année : ☐ Oui  ☐ Non
- [ ] Rapport de test archivé dans CW/Hudu : ☐ Oui
- [ ] Écarts identifiés et corrigés : ☐ Oui  ☐ En cours : _______

---

## RÉSULTAT

☐ **DR READY** — Tous les items validés
☐ **ACTIONS REQUISES** — Items en attente : _______
☐ **NON READY** — Problème critique : escalade IT-BackupDRMaster immédiatement
