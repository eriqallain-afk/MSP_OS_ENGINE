# POWERSHELL LIBRARY: Server Management

## Commandes essentielles pour gestion serveurs Windows

---

## 📊 MONITORING & STATUS

### Vérifier état serveur
```powershell
# Status global serveur
Get-ComputerInfo | Select-Object CsName, OsName, OsVersion, OsUptime

# Uptime
(Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime

# Services arrêtés (qui devraient tourner)
Get-Service | Where-Object {$_.Status -eq 'Stopped' -and $_.StartType -eq 'Automatic'}
```

### Espace disque
```powershell
# Tous les disques
Get-PSDrive -PSProvider FileSystem | Select-Object Name, 
    @{N="Used(GB)";E={[math]::Round($_.Used/1GB,2)}},
    @{N="Free(GB)";E={[math]::Round($_.Free/1GB,2)}},
    @{N="%Free";E={[math]::Round(($_.Free/$_.Used+$_.Free)*100,2)}}

# Alerte si < 10% libre
Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | 
    Where-Object {($_.FreeSpace/$_.Size)*100 -lt 10} |
    Select-Object DeviceID, @{N="FreeGB";E={[math]::Round($_.FreeSpace/1GB,2)}}
```

---

## 🔄 PATCHING & UPDATES

### Vérifier updates disponibles
```powershell
# Installer module PSWindowsUpdate
Install-Module PSWindowsUpdate -Force

# Lister updates disponibles
Get-WindowsUpdate

# Updates critiques seulement
Get-WindowsUpdate -Severity Critical
```

### Installer updates
```powershell
# Tous les updates (sans reboot auto)
Install-WindowsUpdate -AcceptAll -IgnoreReboot

# Avec reboot automatique
Install-WindowsUpdate -AcceptAll -AutoReboot

# Sur serveurs distants
Install-WindowsUpdate -ComputerName SRV-01 -AcceptAll -AutoReboot
```

---

## 🔌 SERVICES

### Gestion services
```powershell
# Status service
Get-Service -Name "spooler"

# Démarrer/Arrêter/Redémarrer
Start-Service -Name "spooler"
Stop-Service -Name "spooler" -Force
Restart-Service -Name "spooler" -Force

# Services auto non démarrés
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'}
```

---

## 🔁 REBOOT

### Planifier reboot
```powershell
# Reboot immédiat
Restart-Computer -Force

# Reboot dans 5 minutes
shutdown /r /t 300 /c "Maintenance - Reboot dans 5 min"

# Annuler
shutdown /a
```

---

*Bibliothèque PowerShell - IT-MaintenanceMaster v1.0*
