# KB — Windows Update Missing sur Domain Controller
**Référence :** KB-WU-001
**Domaine :** Maintenance / Patching / Windows Server / Domain Controller
**Créé de :** Ticket CW #0001234 — Municipalité De Otto Inc
**Date :** 2026-03-24
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Auteur :** @IT-MaintenanceMaster

---

## Symptôme

Alerte RMM `Windows Update Missing - Server` sur un contrôleur de domaine.
Script monitor output : `No critical or security updates were installed in the last 2 months.`

## Causes fréquentes — ordre de vérification

| Priorité | Cause | Signal |
|---|---|---|
| 1 | **Pending Reboot en attente** | PendingFileRename=True / CBS / WU reboot keys |
| 2 | **AUOptions=1** (notification uniquement) | Registre AU — pas d'install auto |
| 3 | **wuauserv arrêté** | Service Status=Stopped, StartType=Manual |
| 4 | **WSUS injoignable** | WUServer défini mais serveur WSUS inaccessible |
| 5 | **Composants WU corrompus** | Erreurs WindowsUpdateClient dans Event Log |
| 6 | **Espace disque insuffisant** | C: < 10% libre |
| 7 | **Proxy/connectivité** | WinHTTP proxy mal configuré |

## Procédure PRECHECK (lecture seule — DC)

À exécuter AVANT toute action. Fournit cause + diagnostic complet.

```powershell
param(
    [string]$OutDir = "C:\Windows\Temp"
)
# Lecture seule — aucun reboot, aucune installation
# Collecte : OS, disque, services WU, politiques WSUS, pending reboot, derniers HotFix, events WU, santé DC

$stamp = Get-Date -Format "yyyyMMdd_HHmm"
$out   = "$OutDir\DIAG_WU_DC_$($env:COMPUTERNAME)_$stamp.txt"

# Pending Reboot
$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = $null -ne (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' `
       -Name PendingFileRenameOperations -EA SilentlyContinue)
"PendingReboot: CBS=$CBS WU=$WU PFR=$PFR" | Tee-Object $out -Append

# Services WU
"wuauserv","bits","cryptsvc","TrustedInstaller","UsoSvc","WaaSMedicSvc" | ForEach-Object {
    $s = Get-Service $_ -EA SilentlyContinue
    "$_ : $($s.Status) / $($s.StartType)" | Tee-Object $out -Append
}

# Politiques WSUS/AU
Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -EA SilentlyContinue |
    Select-Object AUOptions,NoAutoUpdate,UseWUServer | Tee-Object $out -Append

# Dernier HotFix
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 1 | Tee-Object $out -Append

# Santé DC (lecture seule)
dcdiag /test:replications /test:netlogons /test:fsmocheck /quiet | Tee-Object $out -Append
repadmin /replsummary | Tee-Object $out -Append

Write-Output "Rapport : $out"
```

## Correctifs par cause

### Pending Reboot
```powershell
# Vérifier d'abord la santé DC
dcdiag /test:replications /test:netlogons /test:fsmocheck /quiet
repadmin /replsummary
# Si OK → redémarrage contrôlé (1 DC à la fois, hors fenêtre utilisateurs)
# Post-check obligatoire : repadmin /replsummary + dcdiag + LastBootUpTime
```

### AUOptions=1 (notification — pas d'install auto)
```
→ Escalade NOC : valider politique RMM (le RMM doit forcer l'installation)
→ NE PAS modifier la GPO sans validation de la stratégie client
```

### wuauserv arrêté (si RMM ne gère pas)
```powershell
Start-Service wuauserv
# Puis forcer détection
wuauclt /detectnow
UsoClient StartScan
```

### Composants WU corrompus
```powershell
# Reset SoftwareDistribution (arrêter wuauserv d'abord)
Stop-Service wuauserv -Force
Stop-Service bits -Force
Rename-Item "$env:SystemRoot\SoftwareDistribution" "SoftwareDistribution.old"
Start-Service wuauserv
Start-Service bits
```

## Points d'attention DC spécifiques

- **1 DC à la fois** pour tout reboot — jamais simultané
- **Post-check obligatoire** après reboot : réplication AD + netlogons + FSMO
- **SQL Server sur DC** : si KB SQL apparaît dans les updates → valider si SQL est réellement installé/attendu sur ce DC (architecture non recommandée)
- **AUOptions=1** sur DC géré par RMM est souvent voulu — ne pas modifier sans valider la politique cliente

## Escalade

| Situation | Destination |
|---|---|
| AUOptions / politique RMM | @IT-Commandare-NOCDispatcher → équipe RMM |
| WSUS inaccessible | @IT-MonitoringMaster + INFRA |
| Updates critiques > 60 jours | @IT-Commandare-NOCDispatcher — planification fenêtre |
| Composants WU corrompus | @IT-Assistant-N3 |

## Statut résolution acceptable

Intervention **partielle** acceptable si :
- Pending Reboot corrigé ✅
- Santé DC confirmée ✅
- Patching planifié par NOC/RMM ✅
- Flag Up transmis à l'équipe concernée ✅

---
*KB-WU-001 — v1.0 — 2026-03-24*
