# INFRA-BACKUP-Veeam_Operations_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

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
