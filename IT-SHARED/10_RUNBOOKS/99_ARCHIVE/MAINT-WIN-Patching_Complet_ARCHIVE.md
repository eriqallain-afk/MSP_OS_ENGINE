# RUNBOOK — Windows Server Patching (Complet)
**ID :** RUNBOOK__Windows_Patching_COMPLET_V2
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Assistant-N3
**Scope :** Patching Windows Server — planification, exécution CW RMM (1 serveur à la fois), postcheck, pending reboot, rollback
**Version :** 2.0 | **Date :** 2026-04-08

---

## SECTIONS
1. [Pré-patching (T-7 jours)](#1-pré-patching)
2. [Exécution CW RMM — 1 serveur à la fois](#2-exécution-cw-rmm--1-serveur-à-la-fois) ← **Usage quotidien MSP**
3. [Exécution batch (multi-serveurs)](#3-exécution-batch-multi-serveurs) ← Environnements nombreux
4. [Pending Reboot — Diagnostic et résolution](#4-pending-reboot--diagnostic-et-résolution)
5. [Rollback](#5-rollback)
6. [Reporting et clôture CW](#6-reporting-et-clôture-cw)

---

## 1. PRÉ-PATCHING (T-7 jours)

### 1.1 Inventaire et planification

- [ ] Identifier les serveurs à patcher (par criticité)
- [ ] Vérifier le calendrier de change (blackout windows)
- [ ] Confirmer l'ordre de traitement recommandé :
  ```
  SQL → App/Web → Print → File → DC (en dernier)
  ```
- [ ] Notifier les stakeholders (fenêtre de maintenance, impact)
- [ ] Valider les backups récents (< 24h) sur tous les serveurs cibles
- [ ] Confirmer la réplication AD OK (si DC concerné)

### 1.2 Precheck automatisé (T-7j ou veille)

```powershell
param([string[]]$Servers = @("SRV01","SRV02","SRV03"))

foreach ($Server in $Servers) {
    Write-Host " " 
    Write-Host "=== Validation $Server ===" 
    
    # Espace disque C: (minimum 10 GB libre)
    $Disk = Get-WmiObject Win32_LogicalDisk -ComputerName $Server -Filter "DeviceID='C:'"
    $FreeGB = [math]::Round($Disk.FreeSpace / 1GB, 2)
    Write-Host "Espace libre C: $FreeGB GB"

    # Pending reboot
    $PendingReboot = Invoke-Command -ComputerName $Server -ScriptBlock {
        Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
    }
    Write-Host "Reboot pending: $PendingReboot"

    # Service Windows Update
    $WUService = Get-Service -ComputerName $Server -Name wuauserv
    Write-Host "WU Service: $($WUService.Status)"
    Write-Host " " 
}
```

---

## 2. EXÉCUTION CW RMM — 1 SERVEUR À LA FOIS

> **Usage MSP standard.** Principe non négociable :
> - Lecture seule → patching → reboot (si requis) → postcheck
> - **1 seul serveur critique à la fois** (DC / SQL / RDS / ERP)
> - Aucun script qui redémarre une liste automatiquement

### 2.1 Préparation

```powershell
# Créer le dossier de preuves
$BaseOut = "$env:TEMP\CW_Patching"
New-Item -ItemType Directory -Path $BaseOut -Force | Out-Null
```

### 2.2 PRECHECK (avant patching)

> Exécuter sur **le serveur ciblé** via RMM ou session. Sauvegarder l'output.

```powershell
param([string]$OutDir = "$env:TEMP\CW_Patching")
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$TS = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $OutDir "PRECHECK_$TS.log") -Append

"=== HOST ==="; hostname
"=== OS / UPTIME ==="
Get-CimInstance Win32_OperatingSystem | Select-Object CSName, Caption, Version, LastBootUpTime

"=== PENDING REBOOT (CBS / WU / PendingFileRename / CCM) ==="
$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootPending'
[pscustomobject]@{
    CBS_RebootPending          = $CBS
    WU_RebootRequired          = $WU
    PendingFileRenameOperations = $PFR
    CCMClientRebootPending     = $CCM
    PendingReboot              = ($CBS -or $WU -or $PFR -or $CCM)
}

"=== DISQUES ==="
Get-PSDrive -PSProvider FileSystem | Select-Object Name, Used, Free,
    @{n='FreeGB'; e={[math]::Round($_.Free/1GB, 2)}} | Format-Table -AutoSize

"=== SERVICES AUTO NON DÉMARRÉS ==="
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'} |
    Select-Object Name, Status, StartType | Format-Table -AutoSize

"=== EVENT LOG System/Application — 2 dernières heures — Erreurs/Critique ==="
$Start = (Get-Date).AddHours(-2)
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$Start} |
    Where-Object {$_.LevelDisplayName -in 'Error','Critical'} |
    Select-Object -First 30 TimeCreated, Id, ProviderName, Message | Format-Table -Wrap
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} |
    Where-Object {$_.LevelDisplayName -in 'Error','Critical'} |
    Select-Object -First 30 TimeCreated, Id, ProviderName, Message | Format-Table -Wrap

Stop-Transcript
"PRECHECK log: $OutDir"
```

### 2.3 PATCHING (via CW RMM)

- Déclencher l'installation des updates (CU + sécurité) via **CW RMM**.
- **Ne pas** redémarrer automatiquement un serveur critique sans approbation explicite.

### 2.4 REBOOT (si requis)

Avant de redémarrer :
- [ ] Confirmer les sessions actives (RDS / utilisateurs)
- [ ] Confirmer les dépendances (services dépendants sur d'autres serveurs)
- [ ] Obtenir l'approbation (si prod critique)

```powershell
# Depuis le serveur lui-même
Restart-Computer -Force

# Depuis un poste admin
Restart-Computer -ComputerName "SRV-NOM" -Force
```

### 2.5 POSTCHECK (après reboot ou après patch)

```powershell
param([string]$OutDir = "$env:TEMP\CW_Patching")
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$TS = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $OutDir "POSTCHECK_$TS.log") -Append

"=== HOST ==="; hostname
"=== OS / UPTIME ==="
Get-CimInstance Win32_OperatingSystem | Select-Object CSName, Caption, Version, LastBootUpTime

"=== PENDING REBOOT (CBS / WU / PendingFileRename / CCM) ==="
$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootPending'
[pscustomobject]@{
    CBS_RebootPending          = $CBS
    WU_RebootRequired          = $WU
    PendingFileRenameOperations = $PFR
    CCMClientRebootPending     = $CCM
    PendingReboot              = ($CBS -or $WU -or $PFR -or $CCM)
}

"=== DISQUES ==="
Get-PSDrive -PSProvider FileSystem | Select-Object Name, Used, Free,
    @{n='FreeGB'; e={[math]::Round($_.Free/1GB, 2)}} | Format-Table -AutoSize

"=== SERVICES AUTO NON DÉMARRÉS ==="
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'} |
    Select-Object Name, Status, StartType | Format-Table -AutoSize

"=== EVENT LOG System/Application — 1 dernière heure — Erreurs/Critique ==="
$Start = (Get-Date).AddHours(-1)
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$Start} |
    Where-Object {$_.LevelDisplayName -in 'Error','Critical'} |
    Select-Object -First 30 TimeCreated, Id, ProviderName, Message | Format-Table -Wrap
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} |
    Where-Object {$_.LevelDisplayName -in 'Error','Critical'} |
    Select-Object -First 30 TimeCreated, Id, ProviderName, Message | Format-Table -Wrap

Stop-Transcript
"POSTCHECK log: $OutDir"
```

---

## 3. EXÉCUTION BATCH (MULTI-SERVEURS)

> Pour les environnements avec de nombreux serveurs non-critiques.
> **Ne jamais utiliser sur DC / SQL / RDS sans supervision.**

### 3.1 Snapshot pré-patch (Azure VMs)

```powershell
param([string]$VMName, [string]$ResourceGroup = "RG-PROD")

$VM   = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VMName
$Disk = Get-AzDisk -ResourceGroupName $VM.ResourceGroupName -DiskName $VM.StorageProfile.OsDisk.Name

$SnapshotConfig = New-AzSnapshotConfig `
    -SourceUri $Disk.Id `
    -CreateOption Copy `
    -Location $VM.Location

$SnapshotName = "$VMName-snap-$(Get-Date -Format yyyyMMddHHmm)"
New-AzSnapshot -Snapshot $SnapshotConfig -SnapshotName $SnapshotName -ResourceGroupName $ResourceGroup
Write-Host " " 
Write-Host "Snapshot cree: $SnapshotName"
```

### 3.2 Installation patches (PSWindowsUpdate)

```powershell
param([string[]]$Servers)

foreach ($Server in $Servers) {
    Write-Host " " 
    Write-Host "=== Patching $Server ==="
    Invoke-Command -ComputerName $Server -ScriptBlock {
        Import-Module PSWindowsUpdate
        Get-WindowsUpdate -AcceptAll -Install -Category 'Critical Updates','Security Updates' -AutoReboot:$false -Verbose
    }
}
```

### 3.3 Reboot séquentiel (attendre le retour avant de continuer)

```powershell
param([string[]]$Servers)

foreach ($Server in $Servers) {
    Write-Host "Reboot $Server..."
    Restart-Computer -ComputerName $Server -Force -Wait -For PowerShell -Timeout 600
    Write-Host " " 
    Write-Host "$Server est de retour."
    Start-Sleep -Seconds 120

    # Validation rapide post-reboot
    Invoke-Command -ComputerName $Server -ScriptBlock {
        $Services = @('W32Time','Dnscache','Netlogon')
        foreach ($Svc in $Services) {
            $Status = (Get-Service -Name $Svc -ErrorAction SilentlyContinue).Status
            Write-Host "$Svc : $Status"
        }
        $PR = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
        if ($PR) { Write-Host "ATTENTION : reboot additionnel requis" }
    }
}
```

---

## 4. PENDING REBOOT — DIAGNOSTIC ET RÉSOLUTION

> Cas isolé : un serveur affiche un pending reboot. Identifier la source avant d'agir.

### 4.1 Identifier la source

```powershell
"=== Pending reboot — sources ==="
$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' `
    -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootPending'

[pscustomobject]@{
    CBS_RebootPending          = $CBS
    WU_RebootRequired          = $WU
    PendingFileRenameOperations = $PFR
    CCMClientRebootPending     = $CCM
    PendingReboot              = ($CBS -or $WU -or $PFR -or $CCM)
}

"=== Dernier boot ==="; (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
"=== Sessions actives ==="; query user
"=== Disques ==="; Get-PSDrive -PSProvider FileSystem |
    Select-Object Name, Free, @{n='FreeGB'; e={[math]::Round($_.Free/1GB,2)}} | Format-Table -AutoSize
```

### 4.2 Arbre de décision

| Source | Cause probable | Action |
|---|---|---|
| `CBS = True` | Composant Windows en attente | Reboot contrôlé — si persiste après 2 reboots : escalade |
| `WU = True` | Windows Update installé | Reboot contrôlé |
| `PFR = True` | Fichier en cours de remplacement | Reboot contrôlé |
| `CCM = True` | SCCM/ConfigMgr en attente | Reboot contrôlé |

**Si prod/critique :** valider fenêtre + dépendances + approbation avant reboot.
**Si DC :** exécuter le runbook DC PrePost avant et après.

### 4.3 Reboot contrôlé

```powershell
# Depuis le serveur
Restart-Computer -Force

# Depuis un poste admin
Restart-Computer -ComputerName "SRV-NOM" -Force
```

### 4.4 Si le flag persiste après 2 reboots

Vérifier :
- Windows Update avec patch en attente (re-scan : `wuauclt /detectnow`)
- Installation ou rollback en cours (vérifier `%WINDIR%\WinSxS\pending.xml`)
- Corruption Software Distribution :
```powershell
Stop-Service wuauserv -Force
Rename-Item "$env:SystemRoot\SoftwareDistribution" "SoftwareDistribution.old"
Start-Service wuauserv
```
- Si `CBS` persiste : escalader — peut indiquer une corruption de composant Windows.

---

## 5. ROLLBACK

### 5.1 Azure VM — Restauration depuis snapshot

```powershell
param([string]$SnapshotName, [string]$VMName, [string]$ResourceGroup = "RG-PROD")

$Snapshot = Get-AzSnapshot -SnapshotName $SnapshotName -ResourceGroupName $ResourceGroup
Stop-AzVM -ResourceGroupName $ResourceGroup -Name $VMName -Force

$VM        = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VMName
$DiskConfig = New-AzDiskConfig -Location $VM.Location -CreateOption Copy -SourceResourceId $Snapshot.Id
$NewDisk    = New-AzDisk -Disk $DiskConfig -ResourceGroupName $ResourceGroup -DiskName "$VMName-rollback-osdisk"

Set-AzVMOSDisk -VM $VM -ManagedDiskId $NewDisk.Id -Name $NewDisk.Name
Update-AzVM -ResourceGroupName $ResourceGroup -VM $VM
Start-AzVM -ResourceGroupName $ResourceGroup -Name $VMName
Write-Host " " 
Write-Host "Rollback termine — VM redemarree."
```

### 5.2 On-prem — Restauration depuis backup

1. Boot sur Windows Recovery Environment (WinRE)
2. Restaurer le System State depuis le dernier backup
3. Full BMR si nécessaire (Veeam, Windows Server Backup)

### 5.3 Désinstaller un patch spécifique (dernier recours)

```powershell
# Lister les patches installés récemment
Get-HotFix | Where-Object {$_.InstalledOn -gt (Get-Date).AddDays(-1)} | Format-Table -AutoSize

# Désinstaller un patch spécifique
wusa /uninstall /kb:XXXXXXX /quiet /norestart
```

---

## 6. REPORTING ET CLÔTURE CW

### 6.1 Rapport de conformité patches

```powershell
param([string[]]$Servers)

$Report = foreach ($Server in $Servers) {
    $Session = New-PSSession -ComputerName $Server
    $Result  = Invoke-Command -Session $Session -ScriptBlock {
        $Patches       = Get-HotFix | Where-Object {$_.InstalledOn -gt (Get-Date).AddDays(-30)}
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $SearchResult  = $UpdateSession.CreateUpdateSearcher().Search("IsInstalled=0 and Type='Software'")
        [pscustomobject]@{
            Serveur          = $env:COMPUTERNAME
            PatchesInstalles = $Patches.Count
            PatchesManquants = $SearchResult.Updates.Count
            DernierPatch     = ($Patches | Sort-Object InstalledOn -Descending | Select-Object -First 1).InstalledOn
            Statut           = if ($SearchResult.Updates.Count -eq 0) {'Conforme'} else {'Non-conforme'}
        }
    }
    Remove-PSSession $Session
    $Result
}

$Report | Format-Table -AutoSize
$Report | Export-Csv "PatchReport-$(Get-Date -Format yyyyMMdd).csv" -NoTypeInformation
```

### 6.2 CW Note Interne — Phrase d'ouverture OBLIGATOIRE

```
Prise de connaissance de la demande et consultation de la documentation du client.
```

### 6.3 CW Discussion — Phrases d'ouverture OBLIGATOIRES

```
Préparation et découverte.
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

TRAVAUX EFFECTUÉS :
• Precheck effectué — état initial documenté (services, disques, pending reboot, event logs)
• Patches CU + sécurité installés via CW RMM — [liste des serveurs]
• Reboot contrôlé effectué sur [serveurs redémarrés]
• Postcheck effectué — services opérationnels, aucune erreur critique
• [Résultats supplémentaires si applicable]

RÉSULTAT :
• Environnement patchré et opérationnel — [N] serveur(s) traités
• [Ou : Escalade requise / En attente d'approbation pour reboot]
```

---

## BONNES PRATIQUES

| Aspect | Standard |
|---|---|
| Fenêtre production | 2e dimanche du mois, 2h–6h |
| Dev/Test | 1er mercredi du mois, 20h–22h |
| Éviter | Fin de trimestre, lancement, période des Fêtes |
| Ordre serveurs | SQL → App/Web → Print → File → DC |
| Observation DEV | 48h minimum avant déploiement PROD |
| Backup requis | < 24h avant patching |
| Snapshot Azure | Obligatoire pré-patch |
