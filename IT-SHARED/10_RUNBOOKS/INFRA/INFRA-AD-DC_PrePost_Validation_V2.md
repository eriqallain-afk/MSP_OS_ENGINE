# INFRA-AD-DC_PrePost_Validation_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**Agents :** IT-MaintenanceMaster | IT-SysAdmin

## Uptime / Last restart — OBLIGATOIRE (précheck et postcheck)

```powershell
Get-CimInstance Win32_OperatingSystem |
    Select-Object CSName, Caption, Version,
        @{N='LastBoot';E={$_.LastBootUpTime}},
        @{N='UptimeDays';E={[math]::Round(((Get-Date)-$_.LastBootUpTime).TotalDays,2)}},
        @{N='UptimeHours';E={[math]::Round(((Get-Date)-$_.LastBootUpTime).TotalHours,2)}} |
    Out-String -Width 300 | Write-Output
```

**Précheck :** noter l'uptime avant redémarrage + noter le last restart / last boot.
**Postcheck :** confirmer que `LastBoot` correspond au redémarrage effectué + confirmer que l'`Uptime` est revenu à une valeur faible / récente.

---

## Services critiques
```powershell
Get-Service NTDS,DNS,Netlogon,KDC,W32Time | Out-String -Width 300 | Write-Output
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
Get-WinEvent -FilterHashtable @{LogName='DNS Server'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Out-String -Width 300 | Write-Output
```

## Postcheck après reboot
- Rejouer services + replsummary.
- Vérifier que SYSVOL/NETLOGON partagés.
- Confirmer qu'aucun nouvel event critique (Directory Service/System).
- **Uptime / Last restart** — relancer la commande de la section Uptime ci-dessus et documenter :
  - `LastBoot` correspond au redémarrage effectué ✓
  - `UptimeDays` proche de 0 (reboot confirmé) ✓
