# RUNBOOK — Domain Controller (AD DS/DNS) — Precheck/Postcheck

## Services critiques
```powershell
Get-Service NTDS,DNS,Netlogon,KDC,W32Time | Format-Table Name,Status,StartType
net share | findstr /I "SYSVOL NETLOGON"
```

## Réplication AD
```powershell
repadmin /replsummary
repadmin /syncall /AdeP
```

## Santé AD (rapide)
```powershell
# dcdiag peut être long; utiliser /q pour erreurs seulement
$OutDir = "$env:TEMP\\DC_CHECK"; New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$TS = Get-Date -Format "yyyyMMdd_HHmmss"
dcdiag /q | Out-File (Join-Path $OutDir "dcdiag_q_$TS.txt")
"dcdiag_q saved to $OutDir"
```

## DNS (erreurs récentes)
```powershell
$Start=(Get-Date).AddHours(-2)
Get-WinEvent -FilterHashtable @{LogName='DNS Server'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
```

## Postcheck après reboot
- Rejouer services + replsummary.
- Vérifier que SYSVOL/NETLOGON partagés.
- Confirmer qu'aucun nouvel event critique (Directory Service/System).

