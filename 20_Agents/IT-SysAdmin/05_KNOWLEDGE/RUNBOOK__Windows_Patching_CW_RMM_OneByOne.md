# RUNBOOK — Windows Server Patching (ConnectWise RMM) — 1 serveur à la fois

## Principe (non négociable)
- **Lecture seule → patching → reboot (si requis) → postcheck**.
- **Un seul serveur critique à la fois** (DC/SQL/RDS/ERP).
- **Aucun script** qui redémarre une liste automatiquement.

## Préparation
1) Confirmer fenêtre + scope + ordre (recommandé) :
- SQL → App/Web → Print → File → DC
2) Confirmer backups/replication OK (si applicable).
3) Créer un dossier de preuves par serveur :
```powershell
$BaseOut = "$env:TEMP\\CW_Patching"
New-Item -ItemType Directory -Path $BaseOut -Force | Out-Null
```

## PRECHECK (à exécuter AVANT patching)
> Exécuter sur **le serveur ciblé** (RMM script ou session). Sauver l’output dans un fichier.

```powershell
param([string]$OutDir = "$env:TEMP\\CW_Patching")
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$TS = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $OutDir "PRECHECK_$TS.log") -Append

"=== HOST ==="; hostname
"=== OS / UPTIME ==="; (Get-CimInstance Win32_OperatingSystem | Select-Object CSName,Caption,Version,LastBootUpTime)

"=== PENDING REBOOT (CBS/WU/FILE RENAME/CCM) ==="
$CBS = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Component Based Servicing\\RebootPending'
$WU  = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\CCM\\RebootPending'
[pscustomobject]@{CBS_RebootPending=$CBS; WU_RebootRequired=$WU; PendingFileRenameOperations=$PFR; CCMClientRebootPending=$CCM; PendingReboot=($CBS -or $WU -or $PFR -or $CCM)}

"=== DISKS ==="; Get-PSDrive -PSProvider FileSystem | Select-Object Name,Used,Free,@{n='FreeGB';e={[math]::Round($_.Free/1GB,2)}} | Format-Table -Auto

"=== TOP SERVICES (AUTO + NOT RUNNING) ==="
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'} | Select-Object Name,Status,StartType | Format-Table -Auto

"=== EVENTLOG (System/Application) last 2h: Error/Critical ==="
$Start=(Get-Date).AddHours(-2)
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap

Stop-Transcript
"PRECHECK log: $OutDir"
```

## PATCHING (via ConnectWise RMM)
- Déclencher l’installation des updates (CU + sécurité) via **CW RMM**.
- **Ne pas** redémarrer automatiquement si c’est un serveur critique sans avoir le OK.

## REBOOT (si requis)
1) Confirmer : sessions / dépendances / approbation.
2) Redémarrer **le serveur courant** seulement.

## POSTCHECK (après reboot / après patch)
```powershell
param([string]$OutDir = "$env:TEMP\\CW_Patching")
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$TS = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $OutDir "POSTCHECK_$TS.log") -Append

"=== HOST ==="; hostname
"=== OS / UPTIME ==="; (Get-CimInstance Win32_OperatingSystem | Select-Object CSName,Caption,Version,LastBootUpTime)

"=== PENDING REBOOT (CBS/WU/FILE RENAME/CCM) ==="
$CBS = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Component Based Servicing\\RebootPending'
$WU  = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\CCM\\RebootPending'
[pscustomobject]@{CBS_RebootPending=$CBS; WU_RebootRequired=$WU; PendingFileRenameOperations=$PFR; CCMClientRebootPending=$CCM; PendingReboot=($CBS -or $WU -or $PFR -or $CCM)}

"=== DISKS ==="; Get-PSDrive -PSProvider FileSystem | Select-Object Name,Used,Free,@{n='FreeGB';e={[math]::Round($_.Free/1GB,2)}} | Format-Table -Auto

"=== SERVICES (AUTO + NOT RUNNING) ==="
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'} | Select-Object Name,Status,StartType | Format-Table -Auto

"=== EVENTLOG (System/Application) last 1h: Error/Critical ==="
$Start=(Get-Date).AddHours(-1)
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap

Stop-Transcript
"POSTCHECK log: $OutDir"
```

## Closeout (ConnectWise)
- Utiliser :
  - `01_TEMPLATES_CW/TEMPLATE__CW_NOTE_INTERNE__TIMELINE.md`
  - `01_TEMPLATES_CW/TEMPLATE__CW_DISCUSSION__STAR.md`

