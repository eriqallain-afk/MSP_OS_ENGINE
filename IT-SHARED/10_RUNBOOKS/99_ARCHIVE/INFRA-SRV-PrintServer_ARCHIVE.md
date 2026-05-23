# RUNBOOK — Print Server — Precheck/Postcheck

## Spooler + queues
```powershell
Get-Service Spooler | Format-Table Name,Status,StartType

# Requiert module PrintManagement sur serveur / RSAT
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
try {
  Get-Printer | Select-Object Name,Shared,PrinterStatus | Sort-Object Name | Format-Table -Auto
} catch {
  "Get-Printer indisponible (module PrintManagement manquant)."
}
```

## Event logs PrintService
```powershell
$Start=(Get-Date).AddHours(-6)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-PrintService/Operational'; StartTime=$Start} |
  Where-Object {$_.LevelDisplayName -in 'Error','Critical','Warning'} |
  Select-Object -First 50 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
```

## Postcheck après reboot
- Spooler running.
- Queues visibles.
- Si imprimante intermittente : valider connectivité (ping) + cycle power (débrancher/rebrancher) si requis.
