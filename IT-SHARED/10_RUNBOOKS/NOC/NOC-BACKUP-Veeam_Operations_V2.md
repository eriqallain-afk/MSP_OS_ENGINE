# NOC-BACKUP-Veeam_Operations_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-BackupDRMaster | @IT-Commandare-NOC | @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** NOC | **Domaine :** BACKUP (Veeam)
**Veeam Version :** v13 (13.0.1+) | **Durée estimée :** 15–60 min selon opération

---

## OBJECTIF

Procédures opérationnelles Veeam Backup & Replication v13 pour les opérations quotidiennes MSP :
triage des jobs échoués, restaurations, vérification DR, réponse ransomware.

---

## PRÉ-REQUIS

| Élément | Requis |
|---|---|
| Accès | Veeam Backup Administrator ou Veeam One |
| Console | VBR Console (Windows) ou Web UI (v13) |
| Alertes | Veeam ONE configuré avec alertes email |
| Immutabilité | Vérifier que le repository hardened est actif |
| CW Ticket | Ouvert avant toute intervention |

---

## SECTION 1 — TRIAGE QUOTIDIEN DES JOBS

### 1A — Ouverture de session et vue d'ensemble

```
VBR Console → Home → Jobs
  → Filtrer par : Status = Failed | Warning
  → Dashboard → "Data Resilience Summary" (v13 — nouveau)

Veeam ONE → Alarm Management → Active Alarms
  → Priorité : Critical → High → Warning
```

**Statuts et actions :**
| Statut | Signification | Action |
|---|---|---|
| Success | Job OK | Aucune |
| Warning | Complété avec avertissements | Investiguer les avertissements |
| Failed | Job échoué | Identifier cause → relancer ou escalader |
| Running | En cours | Surveiller — timeout si > durée attendue × 1.5 |

### 1B — Analyse d'un job échoué

```
1. VBR Console → Jobs → Cliquer sur le job échoué
2. → Statistics → voir les VM/workloads en erreur
3. → Logs → identifier le message d'erreur exact
4. → Retry immédiat si erreur transitoire (réseau, lock fichier)

# Via PowerShell Veeam
Add-PSSnapin VeeamPSSnapIn -ErrorAction SilentlyContinue
Get-VBRJob -Name "NOM_DU_JOB" | Get-VBRJobObject | 
    Where-Object { $_.LastResult -ne "Success" } |
    Select-Object Name, LastResult, LastError
```

**Erreurs fréquentes et résolutions :**

| Erreur | Cause probable | Action |
|---|---|---|
| `VSSControl: error` | VSS writer en erreur | Redémarrer services VSS sur l'hôte |
| `Agent is not running` | Service Veeam Agent arrêté | Redémarrer l'agent sur la VM |
| `Network error. Lost connection` | Réseau instable | Vérifier bande passante + relancer |
| `Backup file is locked` | Job précédent non terminé | Attendre ou forcer arrêt du job |
| `No space left on device` | Repository plein | Libérer espace ou augmenter capacité |
| `Failed to create VSS snapshot` | Application en cours | Fermer transactions, relancer |
| `The process cannot access the file` | Fichier en cours d'écriture | Configurer quiescence application |

### 1C — Vérification des repositories

```powershell
# État des repositories
Get-VBRBackupRepository | Select-Object Name, Type, FriendlyPath,
    @{N='TotalGB';E={[math]::Round($_.GetContainer().CachedTotalSpace.InGigabytes,1)}},
    @{N='FreeGB';E={[math]::Round($_.GetContainer().CachedFreeSpace.InGigabytes,1)}},
    @{N='UsedPct';E={[math]::Round(100-($_.GetContainer().CachedFreeSpace.InGigabytes/
        $_.GetContainer().CachedTotalSpace.InGigabytes*100),1)}} |
    Format-Table -AutoSize
```

**Seuil d'alerte :** > 80% utilisé → ⚠️ Alerte | > 90% → 🔴 P2

---

## SECTION 2 — RESTAURATION

### 2A — Restauration de fichiers (File-Level Recovery)

```
VBR Console → Home → Backups → Clic droit sur la VM cible
→ Restore → Guest Files → Windows
→ Sélectionner le restore point (date/heure)
→ Browse les fichiers → Clic droit → Restore to original location / Copy to

Validation :
□ Fichier présent dans le dossier destination
□ Taille correcte
□ Contenu intact (ouvrir le fichier)
□ Permissions conservées
```

### 2B — Restauration complète de VM (Instant VM Recovery)

```
VBR Console → Home → Backups → Clic droit sur la VM
→ Restore → Instant VM Recovery

Configuration :
□ Destination : hôte de production ou hôte DR
□ Réseau : choisir si même réseau (prod) ou réseau isolé (test)
□ Reason : documenter dans CW

# Surveiller la restauration
Get-VBRInstantRecovery | Select-Object VMName, Status, Progress, StartTime
```

**⚠️ Important :** L'Instant Recovery monte la VM depuis le backup. Pour finaliser, utiliser "Quick Migration" pour déplacer vers le stockage production.

### 2C — SureBackup — Test automatique de restauration

```
VBR Console → Home → SureBackup Jobs
→ Vérifier : Last Run, Result, Duration

# Créer un test de restauration ad hoc
Start-VBRSureBackupJob -Job (Get-VBRSureBackupJob -Name "NOM_JOB")

# Résultats
Get-VBRSureBackupSession -Last | Select-Object Name, Result, IsCompleted
```

---

## SECTION 3 — RUNBOOK DR (Disaster Recovery)

### 3A — Matrice de priorité de restauration

> **Principe :** Toujours restaurer selon la priorité définie par le client — PAS selon qui appelle le plus fort.

| Priorité | Type de système | RTO cible | RPO cible |
|---|---|---|---|
| P1 | DC / DNS / Authentification | 1h | 4h |
| P1 | ERP / Système critique métier | 2h | 4h |
| P2 | Serveurs de fichiers partagés | 4h | 8h |
| P2 | SQL Server / Bases de données | 2h | 4h |
| P3 | Applications secondaires | 8h | 24h |
| P4 | Postes de travail | 24h | 48h |

### 3B — Procédure Failover (site DR)

```
VBR Console → Home → Replicas → Ready

1. Identifier les VMs à basculer
2. Clic droit → Planned Failover (maintenance planifiée)
   OU Clic droit → Failover Now (urgence)

3. Options Failover :
   □ Restore Point : choisir le plus récent avant l'incident
   □ Reason : documenter précisément

4. Post-failover :
   □ Tester les applications → confirmer avec le client
   □ Mettre à jour le DNS si nécessaire
   □ Notifier les utilisateurs (via IT-TicketScribe)

# Surveiller
Get-VBRFailoverPlan | Get-VBRFailoverPlanObject | 
    Select-Object VMName, Status, PoweredOn
```

### 3C — Undo Failover (retour en production)

```
VBR Console → Home → Replicas → Failed Over
→ Clic droit → Undo Failover

⚠️  Attention : toutes les modifications faites sur le site DR seront perdues
□ Confirmer avec le client AVANT d'initier l'Undo Failover
□ Documenter les changements effectués côté DR si applicable
```

---

## SECTION 4 — RÉPONSE RANSOMWARE

> **⚠️ CRITIQUE :** La restauration N'EST PAS la première étape en cas de ransomware. L'isolation l'est.

### 4A — Étapes immédiates (premières 30 minutes)

```
ÉTAPE 1 — ISOLATION (NE PAS REDÉMARRER LES SYSTÈMES INFECTÉS)
□ Isoler les systèmes au niveau du switch/firewall — PAS en éteignant
□ Couper l'accès réseau à la console VBR si signes de compromission
□ Ne PAS monter de backup sur le réseau de production
□ Alerter IT-SecurityMaster + IT-Commandare-NOC — P1 immédiat

ÉTAPE 2 — VÉRIFIER L'INTÉGRITÉ DES BACKUPS
□ SSH sur le Hardened Repository
□ Confirmer que le service account Veeam n'a PAS été modifié
□ Vérifier les flags d'immutabilité sur les fichiers de backup :
   ls -la /backup_path/*.vbk | grep -v "^-rw"
□ Veeam ONE → Alarms → Malware Detection → Vérifier alertes 72h avant

ÉTAPE 3 — DOCUMENTER L'ÉTENDUE
□ Lister toutes les VMs chiffrées
□ Identifier le vecteur d'entrée (RDP, phishing, VPN, etc.)
□ Documenter le dernier backup propre connu (avant infection)
□ Récupérer la liste des alarmes Veeam ONE des 72h précédentes
```

### 4B — Restauration sécurisée post-ransomware

```
1. Restaurer dans un RÉSEAU ISOLÉ d'abord — jamais directement en production

2. Utiliser Secure Restore (v13) — scan antivirus avant montage
   VBR Console → Restore → Instant Recovery → ☑ Scan with antivirus

3. Vérifier que le vecteur est fermé avant de remettre en production :
   □ VPN vulnérable patché
   □ Compte compromis réinitialisé + MFA
   □ RDP exposé fermé / déplacé

4. Remettre en production en ordre de priorité (Section 3A)

5. Réinitialiser le compte krbtgt (2 fois, 10 min entre les deux) :
   Invoke-Command -ComputerName DC-PRIMARY -ScriptBlock {
       Set-ADAccountPassword -Identity krbtgt -Reset `
           -NewPassword (Read-Host -AsSecureString "Nouveau MDP krbtgt")
   }
   # Attendre 10 min pour réplication
   # Réinitialiser une 2e fois
```

---

## SECTION 5 — CHECKLIST VÉRIFICATION MENSUELLE

```
□ Tous les jobs backup : Last Run < 24h, Result = Success/Warning
□ Capacité repositories : < 80% utilisé
□ SureBackup : au moins 1 test réussi dans les 30 derniers jours
□ Hardened Repository : immutabilité vérifiée
□ Veeam ONE : 0 alarmes critiques non acquittées
□ Catalogue backup : disponible et à jour
□ Offsite/Cloud : dernier transfert < 24h
□ Plan DR : documenté et validé par le client
□ Contacts d'urgence : à jour dans Hudu
□ Rapport mensuel : généré et envoyé au client
```

---

## SECTION 6 — ESCALADE ET DOCUMENTATION

| Situation | Action | Délai max |
|---|---|---|
| Job échoué > 2 retries | Ticket escalade @IT-BackupDRMaster | 2h |
| Repository > 90% | Ticket urgent @IT-SysAdmin | 1h |
| SureBackup échoué 2x | Ticket @IT-BackupDRMaster + client | 4h |
| Ransomware détecté | P1 — @IT-SecurityMaster + @IT-Commandare-NOC | Immédiat |
| RTO dépassé | Escalade client + @IT-Commandare-NOC | Immédiat |

**Documentation obligatoire dans CW (T8 — HUDU_UPDATE) :**
- Fiche BACKUP : mise à jour après chaque modification de job/rétention
- Fiche PROCÉDURE DR : mise à jour après chaque test
- Log de restauration : horodatage, opérateur, restore point, résultat

---

## RÉFÉRENCES

- Veeam Backup & Replication v13 Help Center : helpcenter.veeam.com
- Veeam Community — DR Runbooks v13 : community.veeam.com
- CVE 2026-21669 / 21671 : Patcher VBR 13.0.1+ immédiatement si < 13.0.1
- Veeam ONE : Scheduled reports → Protected VMs, Failed Job History, SureBackup Results

---
*NOC-BACKUP-Veeam_Operations_V2 — IT MSP Intelligence Platform — 2026-04-22*
