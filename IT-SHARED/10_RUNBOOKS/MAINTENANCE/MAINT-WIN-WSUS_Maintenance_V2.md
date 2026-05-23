# MAINT-WIN-WSUS_Maintenance_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** MAINT | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__WSUS_Maintenance_V1
**Version :** 1.0 | **Agents :** IT-MaintenanceMaster, IT-Assistant-N3
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Domaine :** MAINTENANCE — Gestion des mises à jour Windows
**Mis à jour :** 2026-03-20

---

## 1. ACCÈS WSUS

| Méthode | Accès |
|---|---|
| **Console WSUS** | Sur le serveur : Applications → Windows Server Update Services |
| **Web UI** | http://[SERVEUR_WSUS]:8530 ou https://[SERVEUR_WSUS]:8531 |
| **PowerShell** | Module UpdateServices (RSAT) |

---

## 2. HEALTH CHECK WSUS

```powershell
# Services WSUS
Get-Service -Name WsusService,W3SVC | Select-Object Name, Status, StartType | Format-Table

# Espace disque sur la partition WSUS
$wsusPath = (Get-WebConfiguration -PSPath "IIS:\Sites\WSUS Administration\*").physicalPath
if (-not $wsusPath) { $wsusPath = "C:\WSUS" }
Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Root -like "$($wsusPath.Substring(0,3))*"} |
    Select-Object Name,
        @{N='Free_GB';E={[math]::Round($_.Free/1GB,1)}},
        @{N='Free%';E={[math]::Round($_.Free/($_.Used+$_.Free)*100,0)}} | Format-Table

# État de la synchronisation
[reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | Out-Null
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer()
$sub = $wsus.GetSubscription()
$sub | Select-Object LastSynchronizationTime, LastSynchronizationResult | Format-List
```

---

## 3. SYNCHRONISATION WSUS

```powershell
# Forcer une synchronisation manuelle
[reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | Out-Null
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer()
$sub = $wsus.GetSubscription()
$sub.StartSynchronization()
Write-Host "Synchronisation démarrée — surveiller dans la console WSUS"

# Vérifier le statut de synchronisation
Start-Sleep -Seconds 30
$sub = $wsus.GetSubscription()
Write-Host "Résultat : $($sub.LastSynchronizationResult)"
Write-Host "Heure : $($sub.LastSynchronizationTime)"
```

---

## 4. APPROBATION DES MISES À JOUR

### Procédure d'approbation
```
Console WSUS → Updates → All Updates
→ Filtrer : Approval = Unapproved, Status = Needed

Catégories à approuver en priorité :
→ Critical Updates : approuver immédiatement
→ Security Updates : approuver dans les 48h
→ Definition Updates (Defender) : auto-approval recommandée
→ Feature Packs : ne PAS approuver automatiquement — nécessite tests

Procédure :
1. Sélectionner les mises à jour à approuver
2. Clic droit → Approve
3. Sélectionner le groupe cible : DEV/TEST d'abord, puis PROD après 7 jours sans incident
4. Deadline : définir une date limite (recommandé : 7-14 jours)
```

```powershell
# Approuver via PowerShell (Security Updates pour tous les groupes)
[reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | Out-Null
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer()

$unapproved = $wsus.GetUpdates() | Where-Object {
    $_.UpdateClassificationTitle -in "Critical Updates","Security Updates" -and
    $_.IsDeclined -eq $false -and
    ($wsus.GetUpdateApprovals($_)).Count -eq 0
}

Write-Host "Mises à jour en attente d'approbation : $($unapproved.Count)"
$unapproved | Select-Object Title, UpdateClassificationTitle | Format-Table -AutoSize
```

---

## 5. NETTOYAGE WSUS (SERVER CLEANUP WIZARD)

```
⚠️ À exécuter mensuellement pour éviter la dégradation des performances
⚠️ Peut prendre 30-120 minutes selon la taille de la base

Console WSUS → Options → Server Cleanup Wizard
→ Cocher toutes les options :
   ✅ Unused updates and update revisions
   ✅ Computers not contacting the server
   ✅ Unneeded update files
   ✅ Expired updates
   ✅ Superseded updates
→ Next → exécuter

Via PowerShell (plus rapide pour les grosses bases) :
```

```powershell
# Cleanup WSUS via PowerShell
[reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | Out-Null
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer()
$cleanupManager = $wsus.GetCleanupManager()
$cleanupScope = New-Object Microsoft.UpdateServices.Administration.CleanupScope

$cleanupScope.DeclineSupersededUpdates   = $true
$cleanupScope.DeclineExpiredUpdates      = $true
$cleanupScope.CleanupObsoleteUpdates     = $true
$cleanupScope.CompressUpdates            = $true
$cleanupScope.CleanupObsoleteComputers   = $true
$cleanupScope.CleanupUnneededContentFiles = $true

Write-Host "Démarrage cleanup WSUS — patience..." -ForegroundColor Cyan
$results = $cleanupManager.PerformCleanup($cleanupScope)
Write-Host "Espace disque libéré : $([math]::Round($results.DiskSpaceFreed/1MB,0)) MB"
Write-Host "Updates déclinées : $($results.UpdatesDeclined)"
Write-Host "Mises à jour supprimées : $($results.UpdatesDeleted)"
```

---

## 6. MAINTENANCE BASE DE DONNÉES WSUS

```powershell
# Réindexation et maintenance SQL WSUS
# À exécuter sur le serveur WSUS (SQL Express ou SQL Server)

$SqlScript = @"
USE SUSDB;
EXEC sp_MSforeachtable 'ALTER INDEX ALL ON ? REBUILD';
EXEC sp_updatestats;
"@

# Si WID (Windows Internal Database)
Invoke-Sqlcmd -ServerInstance "\\.\pipe\Microsoft##WID\tsql\query" -Query $SqlScript
Write-Host "Maintenance base WSUS terminée"

# Si SQL Server standard
# Invoke-Sqlcmd -ServerInstance "SERVEUR\INSTANCE" -Query $SqlScript
```

---

## 7. RAPPORT DE CONFORMITÉ PATCH

```powershell
# Ordinateurs non à jour (patchs manquants)
[reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration") | Out-Null
$wsus = [Microsoft.UpdateServices.Administration.AdminProxy]::GetUpdateServer()

$computers = $wsus.GetComputerTargets()
$report = $computers | ForEach-Object {
    $updates = $wsus.GetUpdates() | Where-Object {
        $_.UpdateClassificationTitle -in "Critical Updates","Security Updates"
    }
    $needed = ($wsus.GetUpdateInstallationInfoForComputerTarget($_) |
        Where-Object {$_.UpdateInstallationState -eq "Needed"}).Count
    [pscustomobject]@{
        Computer = $_.FullDomainName
        LastSync = $_.LastReportedStatusTime
        PatchsMissing = $needed
    }
}
$report | Sort-Object PatchsMissing -Descending | Format-Table -AutoSize
```

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS approuver les Feature Packs ou les Upgrades automatiquement
   → Nécessitent des tests approfondis
⛔ NE JAMAIS forcer un cleanup WSUS si un job de synchronisation est en cours
⛔ NE PAS ignorer la maintenance mensuelle — la base WSUS se dégrade rapidement
⛔ NE JAMAIS déplacer les fichiers de mise à jour WSUS manuellement
   → Utiliser toujours la console ou PowerShell
⛔ NE PAS approuver les mises à jour sur le groupe PROD sans 7 jours de test sur DEV/TEST
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| WSUS ne se synchronise plus depuis > 24h | INFRA | Dans la journée |
| Base WSUS corrompue (erreurs SQL) | INFRA | Dans l'heure |
| Disque WSUS plein | NOC + INFRA | Dans l'heure |
| Mise à jour défectueuse (BSOD/problème post-patch) | NOC + INFRA | Immédiat |
