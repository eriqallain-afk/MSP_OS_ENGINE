# NOC-BACKUP-Restore_Test_Trimestriel_V1
**Version :** 1.0 | **Date :** 2026-05-21 | **Statut :** ACTIF
**Agents :** @IT-BackupDRMaster | @IT-MaintenanceMaster | @IT-Commandare-NOC
**Département :** NOC-BACKUP | **Source :** IT MSP Intelligence Platform

---

## 1. OBJECTIF ET CADRE

### 1.1 Ce que ce test valide

| Dimension | Ce qui est mesuré |
|---|---|
| **Intégrité** | Les données sauvegardées sont lisibles et non corrompues |
| **RTO** | Le délai réel de restauration vs l'objectif documenté |
| **RPO** | La perte de données maximale acceptable vs le delta réel entre dernier backup et incident simulé |
| **Procédure** | Le runbook est applicable tel quel sans improvisation |
| **Compétence** | Le technicien peut exécuter le test sans escalade non planifiée |
| **Dépendances** | Les systèmes adjacents (DNS, AD, SQL) sont fonctionnels après restauration |

### 1.2 Conformité réglementaire

| Cadre | Exigence couverte |
|---|---|
| **ISO 27001** | A.12.3.1 — Tests de restauration documentés et périodiques |
| **SOC 2 Type II** | CC9.1 — Procédures de continuité testées régulièrement |
| **PCI-DSS v4** | Req. 12.3.4 — Environnements restaurés et validés |
| **Loi 25 Québec** | Art. 10 — Mesures de protection des renseignements personnels, incluant la récupérabilité |

### 1.3 Fréquence recommandée par criticité

| Niveau | Criticité | Fréquence minimale |
|---|---|---|
| CRITIQUE | Données financières, données personnelles, AD, SQL production | Trimestriel (ce runbook) |
| ÉLEVÉE | Serveurs applicatifs, fichiers partagés | Semestriel |
| STANDARD | Postes de travail, données non sensibles | Annuel |

---

## 2. PLANIFICATION TRIMESTRIELLE

### 2.1 Règles absolues de planification

- **Jamais en production** — environnement de test isolé obligatoire
- Planifier hors fenêtre de backup (vérifier le scheduler avant de bloquer le créneau)
- Notifier le client minimum 5 jours ouvrables avant
- Créer un billet ConnectWise dédié (type : Maintenance planifiée)
- Durée estimée par test : **2 à 4 heures** selon scénario

### 2.2 Calendrier annuel — rotation des scénarios

| Trimestre | Période cible | Scénario | Outils principaux |
|---|---|---|---|
| Q1 | Janvier–Mars | Restauration fichiers/dossiers | Veeam / Datto / Keepit |
| Q2 | Avril–Juin | Restauration VM complète | Datto Instant Virtualization / Veeam VM Restore |
| Q3 | Juillet–Septembre | Restauration base SQL | Veeam SQL Restore / SQL native backup |
| Q4 | Octobre–Décembre | Bare Metal Recovery / P2V test | Veeam BMR / Datto BMR |

### 2.3 Fenêtres recommandées

- Mardi ou mercredi, entre 8h00 et 14h00 (éviter lundi/vendredi)
- Hors fin de mois (clôtures comptables), hors période de paie, hors audits planifiés

---

## 3. SCÉNARIOS EN ROTATION — DÉTAIL

| Q | Scénario | Description | Critère de succès |
|---|---|---|---|
| Q1 | **Restauration fichiers/dossiers** | Restaurer un dossier de données (ex. `\\SRV-FICHIERS\Partage\Finance\2025\`) vers un chemin de test | Fichiers accessibles, intégrité hash validée, ACL préservées |
| Q2 | **Restauration VM complète** | Démarrer la VM restaurée en environnement isolé, valider les services | VM démarrée, ping OK, services critiques UP, accès applicatif confirmé |
| Q3 | **Restauration base SQL** | Restaurer une base SQL (ex. `ClientDB_PROD`) vers instance SQL test | Base attachée, requêtes SELECT exécutées, données cohérentes |
| Q4 | **Bare Metal Recovery / P2V** | Restaurer un serveur physique ou convertir P2V sur hyperviseur test | Système démarré, rôles Windows actifs, accès réseau confiré |

---

## 4. PRECHECK — AVANT LE TEST

### 4.1 Script PowerShell de validation pré-test

```powershell
# ============================================================
# PRECHECK - Test de restauration trimestriel
# Exécuter sur le serveur de sauvegarde ou la console RMM
# ============================================================

$TestStart = Get-Date
Write-Output "=== PRECHECK DÉMARRÉ : $TestStart ==="

# --- 1. Dernier backup récent (<24h) ---
# Adapter $BackupJobName selon l'outil (Veeam / Datto / Keepit)
$BackupJobName = "BACKUP_JOB_NOM_CLIENT"   # À adapter
$MaxAgeHours = 24

# Veeam — vérifier dernier job complété
# (Exécuter sur le serveur Veeam Backup & Replication)
try {
    Add-PSSnapin VeeamPSSnapIn -ErrorAction SilentlyContinue
    $LastSession = Get-VBRBackupSession | Where-Object { $_.JobName -eq $BackupJobName } |
        Sort-Object EndTime -Descending | Select-Object -First 1
    $AgeHours = ((Get-Date) - $LastSession.EndTime).TotalHours
    $LastBackupStatus = $LastSession.Result

    Write-Output ("Dernier backup : {0} | Age : {1:N1}h | Statut : {2}" -f $LastSession.EndTime, $AgeHours, $LastBackupStatus) | Out-String -Width 300 | Write-Output

    if ($AgeHours -gt $MaxAgeHours) {
        Write-Output "ALERTE : Dernier backup > $MaxAgeHours heures — VÉRIFIER AVANT DE CONTINUER" | Out-String -Width 300 | Write-Output
    } elseif ($LastBackupStatus -ne "Success") {
        Write-Output "ALERTE : Dernier backup non en succès ($LastBackupStatus) — VÉRIFIER AVANT DE CONTINUER" | Out-String -Width 300 | Write-Output
    } else {
        Write-Output "OK : Backup récent et en succès." | Out-String -Width 300 | Write-Output
    }
} catch {
    Write-Output "INFO : Snapin Veeam non disponible sur ce serveur — vérifier manuellement dans la console Veeam." | Out-String -Width 300 | Write-Output
}

# --- 2. Espace disque disponible sur l'environnement de test ---
$TestDrive = "D:"   # À adapter selon l'env de test
$Disk = Get-PSDrive -Name ($TestDrive -replace ':','') -ErrorAction SilentlyContinue
if ($Disk) {
    $FreeGB = [math]::Round($Disk.Free / 1GB, 2)
    Write-Output ("Espace libre sur {0} : {1} GB" -f $TestDrive, $FreeGB) | Out-String -Width 300 | Write-Output
    if ($FreeGB -lt 50) {
        Write-Output "ALERTE : Espace < 50 GB — risque d'échec de restauration." | Out-String -Width 300 | Write-Output
    } else {
        Write-Output "OK : Espace suffisant." | Out-String -Width 300 | Write-Output
    }
} else {
    Write-Output "INFO : Lecteur $TestDrive non trouvé — vérifier manuellement." | Out-String -Width 300 | Write-Output
}

# --- 3. Vérifier qu'aucun job backup n'est en cours ---
try {
    $RunningJobs = Get-VBRRunningJob
    if ($RunningJobs) {
        Write-Output "ALERTE : Jobs backup en cours — ne pas démarrer le test maintenant :" | Out-String -Width 300 | Write-Output
        $RunningJobs | Select-Object Name, Progress | Out-String -Width 300 | Write-Output
    } else {
        Write-Output "OK : Aucun job backup en cours." | Out-String -Width 300 | Write-Output
    }
} catch {
    Write-Output "INFO : Vérification jobs Veeam non disponible — valider dans la console." | Out-String -Width 300 | Write-Output
}

# --- 4. Confirmer que le point de restauration existe ---
Write-Output "MANUEL REQUIS : Confirmer dans la console backup que le point de restauration cible est bien présent." | Out-String -Width 300 | Write-Output
Write-Output "Point cible : [INDIQUER DATE/HEURE DU POINT DE RESTAURATION]" | Out-String -Width 300 | Write-Output

Write-Output ""
Write-Output "=== PRECHECK TERMINÉ — Chronomètre initialisé : $TestStart ===" | Out-String -Width 300 | Write-Output
Write-Output "Conserver cette valeur : TestStart = $TestStart" | Out-String -Width 300 | Write-Output
```

### 4.2 Checklist manuelle pré-test

- [ ] Billet ConnectWise créé et ouvert
- [ ] Client notifié (confirmation reçue)
- [ ] Environnement de test isolé confirmé (pas de VLAN prod)
- [ ] Point de restauration cible identifié et documenté (date/heure)
- [ ] Espace disque env. de test suffisant (>50 GB libre minimum)
- [ ] Aucun job de backup en cours
- [ ] Fenêtre de maintenance validée

---

## 5. EXÉCUTION PAR SCÉNARIO

### 5.1 Q1 — Restauration fichiers/dossiers

#### Veeam — Restauration fichiers (File-Level Restore)

1. Ouvrir la console Veeam Backup & Replication
2. Cliquer **Home** → **Backups** → sélectionner le job du client
3. Clic droit sur la sauvegarde → **Restore guest files** → **Microsoft Windows**
4. Choisir le point de restauration (date/heure ciblé)
5. Dans le **Backup Browser**, naviguer vers le dossier cible
6. Clic droit → **Restore** → **Keep** (ne pas écraser — restaurer vers chemin de test)
7. Chemin de destination : `D:\RestoreTest\Q1-YYYY-MM-DD\`
8. Lancer la restauration et attendre la fin (noter l'heure de fin)

#### Datto — Restauration fichiers

1. Se connecter au portail Datto Partner : `https://partner.dattobackup.com`
2. Sélectionner le device client → **Restore** → **File/Folder Restore**
3. Choisir le snapshot cible (date/heure)
4. Naviguer vers le dossier → cocher les éléments → **Restore to...**
5. Choisir **Restore to alternate location** → spécifier chemin de test sur le device Datto ou serveur de test
6. Confirmer et attendre la fin de l'opération

#### Keepit — Restauration fichiers

1. Se connecter au portail Keepit : `https://app.keepit.com`
2. Sélectionner le compte client → **Restore**
3. Naviguer vers la source (SharePoint, OneDrive, etc.)
4. Sélectionner le point dans le temps (date/heure)
5. Choisir les fichiers → **Restore** → **Download** ou **Restore to alternate location**
6. Vérifier la notification de fin de restauration

#### Validation Q1

```powershell
# Validation post-restauration fichiers
$RestorePath = "D:\RestoreTest\Q1-YYYY-MM-DD"   # Adapter

# Vérifier que des fichiers sont présents
$FileCount = (Get-ChildItem -Path $RestorePath -Recurse -File).Count
Write-Output ("Fichiers restaurés : {0}" -f $FileCount) | Out-String -Width 300 | Write-Output

# Vérifier l'accessibilité (lecture)
$SampleFile = Get-ChildItem -Path $RestorePath -Recurse -File | Select-Object -First 1
if ($SampleFile) {
    try {
        $Content = [System.IO.File]::ReadAllBytes($SampleFile.FullName)
        Write-Output ("OK : Fichier lisible — {0} ({1} bytes)" -f $SampleFile.Name, $Content.Length) | Out-String -Width 300 | Write-Output
    } catch {
        Write-Output ("ÉCHEC : Fichier illisible — {0}" -f $SampleFile.FullName) | Out-String -Width 300 | Write-Output
    }
}

# Hash check sur un fichier de référence (si hash original documenté)
# $OriginalHash = "HASH_ORIGINAL"
# $RestoredHash = (Get-FileHash -Path $SampleFile.FullName -Algorithm SHA256).Hash
# if ($RestoredHash -eq $OriginalHash) { Write-Output "INTÉGRITÉ CONFIRMÉE" } else { Write-Output "ALERTE : HASH DIFFÉRENT" }
```

---

### 5.2 Q2 — Restauration VM complète

#### Veeam — VM Restore (environnement isolé)

1. Console Veeam → **Home** → **Backups** → sélectionner la VM
2. Clic droit → **Restore entire VM** → **Restore to a new location, or with different settings**
3. Sélectionner le point de restauration cible
4. Choisir un datastore/hôte d'**environnement de test isolé** (pas de connexion prod)
5. Renommer la VM restaurée : `VM-NOM_RESTORE_TEST_YYYYMMDD`
6. Désactiver la connexion réseau prod dans les paramètres de la VM avant démarrage
7. Démarrer la VM restaurée
8. Se connecter via console VMware/Hyper-V (pas via réseau prod)

#### Datto — Instant Virtualization

1. Portail Datto → device client → **Restore** → **Instant Virtualization**
2. Sélectionner le snapshot cible
3. Choisir **Isolated network** (ne jamais choisir le réseau de production)
4. Démarrer la VM virtualisée sur le Datto
5. Se connecter via le portail Datto → **Virtual Machine Console**

#### Validation Q2

```powershell
# Validation post-restauration VM (exécuter depuis la VM restaurée en isolé)
$VMName = "VM-NOM_RESTORE_TEST_YYYYMMDD"

# Test connectivité interne (loopback uniquement en isolé)
$PingLocal = Test-Connection -ComputerName "127.0.0.1" -Count 2 -Quiet
Write-Output ("Ping loopback : {0}" -f $(if ($PingLocal) {"OK"} else {"ÉCHEC"})) | Out-String -Width 300 | Write-Output

# Services critiques
$CriticalServices = @("wuauserv", "Winmgmt", "EventLog", "W32Time")
foreach ($svc in $CriticalServices) {
    $ServiceStatus = (Get-Service -Name $svc -ErrorAction SilentlyContinue).Status
    Write-Output ("{0} : {1}" -f $svc, $ServiceStatus) | Out-String -Width 300 | Write-Output
}

# Vérifier les rôles Windows installés
Get-WindowsFeature | Where-Object { $_.InstallState -eq "Installed" } |
    Select-Object Name, DisplayName |
    Out-String -Width 300 | Write-Output

# Vérifier les journaux d'événements (erreurs critiques au démarrage)
Get-EventLog -LogName System -EntryType Error -Newest 10 |
    Select-Object TimeGenerated, Source, Message |
    Out-String -Width 300 | Write-Output
```

---

### 5.3 Q3 — Restauration base SQL

#### Veeam — SQL Application-Aware Restore

1. Console Veeam → **Backups** → sélectionner la VM SQL
2. Clic droit → **Restore application items** → **Microsoft SQL Server databases**
3. Sélectionner le point de restauration
4. Choisir la base de données cible (ex. `ClientDB_PROD`)
5. Sélectionner **Restore to another server** → instance SQL de test (ex. `SRV-SQL-TEST\SQLTEST`)
6. Renommer la base restaurée : `ClientDB_RESTORE_TEST_YYYYMMDD`
7. Lancer la restauration

#### SQL Native Backup (si backup .bak disponible)

```powershell
# Restauration SQL native depuis fichier .bak
$SqlInstance = "SRV-SQL-TEST\SQLTEST"    # Instance de test
$DatabaseName = "ClientDB_RESTORE_TEST_YYYYMMDD"
$BackupFile = "\\SRV-BACKUP\Backups\ClientDB_PROD_YYYYMMDD.bak"  # Adapter le chemin
$DataPath = "D:\SQLData"
$LogPath = "D:\SQLLogs"

$RestoreQuery = @"
RESTORE DATABASE [$DatabaseName]
FROM DISK = N'$BackupFile'
WITH
    MOVE N'ClientDB_PROD' TO N'$DataPath\$DatabaseName.mdf',
    MOVE N'ClientDB_PROD_log' TO N'$LogPath\${DatabaseName}_log.ldf',
    STATS = 10,
    RECOVERY,
    REPLACE;
"@

Invoke-Sqlcmd -ServerInstance $SqlInstance -Query $RestoreQuery -QueryTimeout 3600 -Verbose |
    Out-String -Width 300 | Write-Output
Write-Output "Restauration SQL terminée." | Out-String -Width 300 | Write-Output
```

#### Validation Q3

```powershell
# Validation post-restauration SQL
$SqlInstance = "SRV-SQL-TEST\SQLTEST"
$DatabaseName = "ClientDB_RESTORE_TEST_YYYYMMDD"

# Vérifier que la base est en ligne
$DbStatus = Invoke-Sqlcmd -ServerInstance $SqlInstance `
    -Query "SELECT name, state_desc FROM sys.databases WHERE name = '$DatabaseName'" |
    Out-String -Width 300 | Write-Output

# Requête de validation des données (adapter la table selon le client)
$RowCount = Invoke-Sqlcmd -ServerInstance $SqlInstance `
    -Database $DatabaseName `
    -Query "SELECT COUNT(*) AS NbLignes FROM INFORMATION_SCHEMA.TABLES" |
    Out-String -Width 300 | Write-Output

Write-Output "Tables dans la base restaurée :" | Out-String -Width 300 | Write-Output
$RowCount

# Vérifier l'intégrité de la base
Invoke-Sqlcmd -ServerInstance $SqlInstance `
    -Query "DBCC CHECKDB ('$DatabaseName') WITH NO_INFOMSGS, ALL_ERRORMSGS" |
    Out-String -Width 300 | Write-Output
Write-Output "DBCC CHECKDB terminé." | Out-String -Width 300 | Write-Output
```

---

### 5.4 Q4 — Bare Metal Recovery / P2V test

#### Veeam — Bare Metal Recovery

1. Démarrer l'environnement de test avec le **Veeam Recovery Media** (ISO booté)
2. Choisir **Bare Metal Recovery**
3. Sélectionner la source : **Network storage** → pointer vers le repo Veeam
4. Choisir la sauvegarde et le point de restauration
5. Mapper les disques vers les disques de test
6. Lancer la restauration et attendre la fin
7. Démarrer le système restauré en environnement isolé

#### Datto — BMR

1. Portail Datto → device → **Restore** → **Bare Metal Restore**
2. Suivre l'assistant : sélectionner snapshot, sélectionner cible de test
3. Lancer la restauration (durée variable selon taille)
4. Démarrer le système restauré sur matériel de test ou hyperviseur isolé

#### Validation Q4

```powershell
# Validation post-BMR (exécuter depuis le système restauré)

# État général du système
$OS = Get-WmiObject -Class Win32_OperatingSystem
Write-Output ("OS : {0} — Build : {1} — Installé le : {2}" -f $OS.Caption, $OS.BuildNumber, $OS.InstallDate) | Out-String -Width 300 | Write-Output

# Vérifier les disques
Get-Disk | Select-Object Number, FriendlyName, Size, OperationalStatus |
    Out-String -Width 300 | Write-Output

# Vérifier les volumes
Get-Volume | Select-Object DriveLetter, FileSystemLabel, SizeRemaining, Size, HealthStatus |
    Out-String -Width 300 | Write-Output

# Services critiques
$Services = Get-Service | Where-Object { $_.StartType -eq "Automatic" -and $_.Status -ne "Running" } |
    Select-Object Name, DisplayName, Status
if ($Services) {
    Write-Output "ALERTE : Services auto non démarrés :" | Out-String -Width 300 | Write-Output
    $Services | Out-String -Width 300 | Write-Output
} else {
    Write-Output "OK : Tous les services automatiques sont démarrés." | Out-String -Width 300 | Write-Output
}

# Rôles Windows actifs
Get-WindowsFeature | Where-Object { $_.InstallState -eq "Installed" } |
    Select-Object Name, DisplayName |
    Out-String -Width 300 | Write-Output
```

---

## 6. VALIDATION POST-RESTAURATION — SCRIPT UNIVERSEL

```powershell
# ============================================================
# VALIDATION UNIVERSELLE — Post-restauration
# À exécuter après chaque scénario
# ============================================================

param(
    [string]$TestTarget = "127.0.0.1",   # IP ou hostname de la VM/serveur restauré (isolé)
    [datetime]$TestStart = (Get-Date)    # Récupérer la valeur du PRECHECK
)

Write-Output "=== VALIDATION POST-RESTAURATION ===" | Out-String -Width 300 | Write-Output
Write-Output ("Date/heure : {0}" -f (Get-Date)) | Out-String -Width 300 | Write-Output

# --- 1. Connectivité ---
$PingResult = Test-Connection -ComputerName $TestTarget -Count 4 -ErrorAction SilentlyContinue
if ($PingResult) {
    $AvgLatency = ($PingResult | Measure-Object -Property ResponseTime -Average).Average
    Write-Output ("Ping {0} : OK — Latence moyenne : {1:N1} ms" -f $TestTarget, $AvgLatency) | Out-String -Width 300 | Write-Output
} else {
    Write-Output ("Ping {0} : ÉCHEC" -f $TestTarget) | Out-String -Width 300 | Write-Output
}

# --- 2. Services critiques ---
$ServicesToCheck = @("wuauserv", "Winmgmt", "EventLog", "LanmanServer", "LanmanWorkstation")
foreach ($svc in $ServicesToCheck) {
    $S = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($S) {
        Write-Output ("{0} : {1}" -f $svc, $S.Status) | Out-String -Width 300 | Write-Output
    } else {
        Write-Output ("{0} : NON TROUVÉ (vérifier)" -f $svc) | Out-String -Width 300 | Write-Output
    }
}

# --- 3. Mesure RTO ---
$TestEnd = Get-Date
$RTO = $TestEnd - $TestStart
Write-Output ("=== RTO MESURÉ : {0}h {1}m {2}s ===" -f [int]$RTO.TotalHours, $RTO.Minutes, $RTO.Seconds) | Out-String -Width 300 | Write-Output

# --- 4. Évaluation RPO ---
# RPO = delta entre dernier backup et l'heure de l'incident simulé
# $LastBackupTime = [datetime]"2026-05-21 02:00:00"   # À remplir depuis les logs
# $IncidentSimulatedTime = [datetime]"2026-05-22 08:00:00"   # À remplir
# $RPO = $IncidentSimulatedTime - $LastBackupTime
# Write-Output ("RPO MESURÉ : {0}h {1}m" -f [int]$RPO.TotalHours, $RPO.Minutes) | Out-String -Width 300 | Write-Output
Write-Output "RPO : Calculer manuellement — voir section 8 de ce runbook." | Out-String -Width 300 | Write-Output

Write-Output "=== VALIDATION TERMINÉE ===" | Out-String -Width 300 | Write-Output
```

---

## 7. MESURE RTO / RPO

### 7.1 Formules de calcul

```
RTO réel = Heure de fin de restauration et validation − Heure de début du test ($TestStart)

RPO réel = Heure de l'incident simulé − Horodatage du dernier backup utilisé
```

### 7.2 Comparaison aux objectifs documentés

| Métrique | Source des objectifs | Où trouver la valeur client |
|---|---|---|
| RTO cible | Contrat SLA client ou plan de DR | Hudu → fiche client → DR Plan |
| RPO cible | Contrat SLA client ou plan de DR | Hudu → fiche client → DR Plan |

### 7.3 Seuils d'alerte et actions

| Résultat | Action requise |
|---|---|
| RTO réel ≤ RTO cible | Succès — documenter dans le rapport |
| RTO réel entre 100% et 120% du RTO cible | Succès partiel — analyser les causes et planifier optimisation |
| RTO réel > 120% du RTO cible | Échec RTO — escalader à @IT-BackupDRMaster, plan correctif requis |
| RPO réel ≤ RPO cible | Succès — documenter dans le rapport |
| RPO réel > RPO cible | Analyser la fréquence des backups — ajuster la politique si nécessaire |

---

## 8. NETTOYAGE POST-TEST

### 8.1 Checklist de nettoyage

- [ ] Arrêter la VM de test / éteindre l'environnement virtualisé
- [ ] Supprimer la VM de test de l'hyperviseur (ne pas laisser de VM orpheline)
- [ ] Supprimer les fichiers restaurés sur le chemin de test (`D:\RestoreTest\...`)
- [ ] Détacher / supprimer la base SQL de test de l'instance test
- [ ] Confirmer que le réseau isolé est désactivé / aucune connexion prod n'a été établie
- [ ] Vérifier que les jobs de backup normaux reprennent normalement après le test

### 8.2 Script de nettoyage fichiers

```powershell
# Nettoyage du chemin de restauration test
$RestorePath = "D:\RestoreTest"   # Adapter si nécessaire

if (Test-Path $RestorePath) {
    $SizeGB = [math]::Round((Get-ChildItem -Path $RestorePath -Recurse | Measure-Object -Property Length -Sum).Sum / 1GB, 2)
    Write-Output ("Suppression de {0} GB dans {1}" -f $SizeGB, $RestorePath) | Out-String -Width 300 | Write-Output
    Remove-Item -Path $RestorePath -Recurse -Force
    Write-Output "Nettoyage terminé." | Out-String -Width 300 | Write-Output
} else {
    Write-Output ("Chemin {0} non trouvé — rien à supprimer." -f $RestorePath) | Out-String -Width 300 | Write-Output
}
```

---

## 9. RAPPORT ET CLÔTURE

### 9.1 Template de rapport

Utiliser le template : `IT-SHARED/20_TEMPLATES/07_TEMPLATE_BACKUP/TEMPLATE_BACKUP_Restore_Trimestriel_V1.md`

Remplir toutes les sections avant de clore le billet ConnectWise.

### 9.2 Critères de succès

| Critère | Définition |
|---|---|
| **SUCCÈS** | Toutes les validations OK, RTO ≤ objectif, RPO ≤ objectif, aucune donnée corrompue |
| **SUCCÈS PARTIEL** | Restauration fonctionnelle mais RTO ou RPO dépassé de moins de 20%, ou écart mineur documenté |
| **ÉCHEC** | Restauration impossible, données corrompues, RTO > 120% de l'objectif, ou interruption non planifiée |

### 9.3 Si le test échoue

1. **Ne pas paniquer** — c'est l'objectif du test de détecter les problèmes avant une vraie crise
2. Documenter l'échec avec précision dans le rapport (étape exacte, message d'erreur complet)
3. Escalader à @IT-BackupDRMaster et @IT-Commandare-NOC immédiatement
4. Ouvrir un ticket correctif séparé dans ConnectWise (type : Incident Qualité Backup)
5. Planifier un re-test dans les 30 jours après correction
6. Notifier le client selon les termes du contrat SLA
7. Logger un incident dans `00_QA/incidents/IT-BackupDRMaster/YYYY-MM-DD_echec-restore-test.md`

### 9.4 Archivage

- Rapport complété → archiver dans Hudu (fiche client → section Rapports → Backup & DR)
- Copier le rapport dans le billet ConnectWise (note interne)
- Conserver les captures d'écran/logs de validation (joindre au billet CW ou à Hudu)
- Mettre à jour le dashboard qualité : `00_QA/scores/quality_dashboard.yaml` (via @IT-OPS-QAMaster)

---

*Runbook NOC-BACKUP-Restore_Test_Trimestriel_V1 — Version 1.0 — IT MSP Intelligence Platform*
