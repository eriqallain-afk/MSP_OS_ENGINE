# POWERSHELL LIBRARY: Event Log Analysis
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

## Commandes pour analyser Event Logs efficacement

---

## 🔍 ERREURS COURANTES PAR EVENT ID

### Windows System Errors

| Event ID | Source | Description | Action |
|----------|--------|-------------|--------|
| 41 | Kernel-Power | Arrêt inattendu (perte power) | Vérifier UPS/alimentation |
| 1074 | USER32 | Reboot planifié | Info normale |
| 6008 | EventLog | Shutdown imprévu | Investiguer cause |
| 7000 | Service Control Manager | Service failed to start | Vérifier dépendances |
| 7009 | Service Control Manager | Service timeout | Augmenter timeout |
| 7022 | Service Control Manager | Service hung on starting | Restart service |
| 7031 | Service Control Manager | Service terminated | Redémarrer service |
| 10010 | DistributedCOM | DCOM timeout | Permissions DCOM |

### Application Errors

| Event ID | Source | Description | Action |
|----------|--------|-------------|--------|
| 1000 | Application Error | Application crash | Check logs app |
| 1001 | Windows Error Reporting | Error report | Review crash dump |
| 1002 | Application Hang | App not responding | Kill process |

---

## 📊 ANALYSE PAR CATÉGORIE

### Errors critiques dernières 24h
```powershell
# System log
Get-EventLog -LogName System -EntryType Error -After (Get-Date).AddHours(-24) |
    Group-Object Source | Sort-Object Count -Descending |
    Select-Object Count, Name, @{N="FirstOccurrence";E={($_.Group | Sort-Object TimeGenerated)[0].TimeGenerated}}

# Application log  
Get-EventLog -LogName Application -EntryType Error -After (Get-Date).AddHours(-24) |
    Group-Object Source | Sort-Object Count -Descending |
    Select-Object Count, Name
```

### Event ID spécifiques - Troubleshooting

**Event ID 41 - Arrêt inattendu:**
```powershell
Get-EventLog -LogName System -InstanceId 41 -Newest 10 |
    Select-Object TimeGenerated, MachineName, Message | Format-List

# Vérifier si causé par UPS/Power
Get-EventLog -LogName System -Source "Kernel-Power" -Newest 20 |
    Where-Object {$_.EventID -eq 41} |
    Select-Object TimeGenerated, @{N="Reason";E={
        if($_.Message -match "BugcheckCode") {"Blue Screen"}
        elseif($_.Message -match "PowerButtonTimestamp") {"Power Button"}
        else {"Power Loss"}
    }}
```

**Event ID 7000/7001 - Services failed:**
```powershell
Get-EventLog -LogName System -InstanceId 7000,7001 -Newest 50 |
    Select-Object TimeGenerated, 
                  @{N="Service";E={($_.Message -split "service")[0].Trim()}},
                  Message |
    Group-Object Service | Sort-Object Count -Descending
```

**Event ID 1074 - Reboots:**
```powershell
# Historique reboots derniers 30 jours
Get-EventLog -LogName System -InstanceId 1074 -After (Get-Date).AddDays(-30) |
    Select-Object TimeGenerated, 
                  @{N="User";E={($_.ReplacementStrings)[6]}},
                  @{N="Process";E={($_.ReplacementStrings)[0]}},
                  @{N="Reason";E={($_.ReplacementStrings)[2]}} |
    Format-Table -AutoSize
```

---

## 📈 RAPPORTS & STATS

### Résumé santé Event Logs
```powershell
function Get-EventLogHealth {
    param(
        [int]$Hours = 24
    )
    
    $start = (Get-Date).AddHours(-$Hours)
    
    $systemErrors = (Get-EventLog -LogName System -EntryType Error -After $start).Count
    $systemWarnings = (Get-EventLog -LogName System -EntryType Warning -After $start).Count
    $appErrors = (Get-EventLog -LogName Application -EntryType Error -After $start).Count
    $appWarnings = (Get-EventLog -LogName Application -EntryType Warning -After $start).Count
    
    [PSCustomObject]@{
        Period = "Last $Hours hours"
        SystemErrors = $systemErrors
        SystemWarnings = $systemWarnings
        AppErrors = $appErrors
        AppWarnings = $appWarnings
        TotalIssues = $systemErrors + $systemWarnings + $appErrors + $appWarnings
        Status = if(($systemErrors + $appErrors) -eq 0) {"Healthy"} 
                 elseif(($systemErrors + $appErrors) -lt 10) {"Warning"} 
                 else {"Critical"}
    }
}

# Utilisation
Get-EventLogHealth -Hours 24
```

### Top 10 erreurs récurrentes
```powershell
# Dernière semaine
$start = (Get-Date).AddDays(-7)

Get-EventLog -LogName System -EntryType Error -After $start |
    Group-Object EventID |
    Sort-Object Count -Descending |
    Select-Object -First 10 Count, Name, 
        @{N="Source";E={($_.Group[0]).Source}},
        @{N="Example";E={($_.Group[0]).Message.Substring(0,[Math]::Min(100,$_.Group[0].Message.Length))}}
```

---

## 🔎 RECHERCHE AVANCÉE

### Recherche par pattern dans message
```powershell
# Chercher "disk" dans messages erreur
Get-EventLog -LogName System -EntryType Error -Newest 1000 |
    Where-Object {$_.Message -like "*disk*"} |
    Select-Object TimeGenerated, EventID, Source, Message | Format-List
```

### Export pour analyse
```powershell
# Export CSV dernières 24h
Get-EventLog -LogName System -EntryType Error,Warning -After (Get-Date).AddHours(-24) |
    Select-Object TimeGenerated, EntryType, Source, EventID, Message |
    Export-Csv C:\Logs\SystemEvents_$(Get-Date -Format 'yyyyMMdd_HHmm').csv -NoTypeInformation

# Export HTML formaté
Get-EventLog -LogName System -EntryType Error -Newest 100 |
    ConvertTo-Html -Title "System Errors" -PreContent "<h1>System Event Errors - Last 100</h1>" |
    Out-File C:\Logs\SystemErrors.html
```

---

## 🎯 MONITORING PROACTIF

### Script surveillance temps réel
```powershell
# Surveiller nouvelles erreurs (refresh 30 sec)
$lastCheck = Get-Date
while($true) {
    $newErrors = Get-EventLog -LogName System -EntryType Error -After $lastCheck
    
    if($newErrors) {
        Write-Host "$(Get-Date) - $($newErrors.Count) nouvelles erreurs!" -ForegroundColor Red
        $newErrors | Select-Object TimeGenerated, Source, EventID, Message | Format-Table
    }
    
    $lastCheck = Get-Date
    Start-Sleep -Seconds 30
}
```

### Alertes email pour erreurs critiques
```powershell
# Event IDs à surveiller
$criticalEvents = @(41, 6008, 7000, 7031, 1000)

$errors = Get-EventLog -LogName System -EntryType Error -After (Get-Date).AddHours(-1) |
    Where-Object {$criticalEvents -contains $_.EventID}

if($errors) {
    $body = $errors | Select-Object TimeGenerated, Source, EventID, Message | 
        ConvertTo-Html | Out-String
    
    Send-MailMessage -To "<ADMIN_UPN>.com" -From "monitoring@company.com" `
        -Subject "ALERT: Critical Events Detected" -Body $body -BodyAsHtml `
        -SmtpServer "smtp.company.com"
}
```

---

## 📋 CHECKLISTS PAR SCÉNARIO

### Serveur lent/performances
```powershell
# 1. Erreurs disque
Get-EventLog -LogName System -Source "Disk" -Newest 50

# 2. Timeouts services
Get-EventLog -LogName System -InstanceId 7009,7011 -Newest 20

# 3. Application crashes
Get-EventLog -LogName Application -InstanceId 1000,1002 -Newest 20

# 4. Memory issues (si Event ID 2004, 2019)
Get-EventLog -LogName System -Source "Srv" -Newest 50
```

### Post-reboot validation
```powershell
# 1. Raison reboot
Get-EventLog -LogName System -InstanceId 1074 -Newest 1

# 2. Services failed to start
Get-EventLog -LogName System -InstanceId 7000,7001 -After (Get-Date).AddHours(-2)

# 3. Erreurs au démarrage
Get-EventLog -LogName System -EntryType Error -After (Get-Date).AddHours(-2) |
    Select-Object TimeGenerated, Source, EventID, Message
```

### Troubleshoot backup failed
```powershell
# VEEAM errors
Get-EventLog -LogName Application -Source "Veeam*" -EntryType Error -Newest 50

# VSS errors (Volume Shadow Copy)
Get-EventLog -LogName Application -Source "VSS" -Newest 50

# Disk space issues
Get-EventLog -LogName System -Source "Disk" -EntryType Warning,Error -Newest 50
```

---

## 🛠️ NETTOYAGE EVENT LOGS

### Clear event logs (avec backup)
```powershell
# Backup puis clear System log
wevtutil export-log System C:\Logs\System_backup_$(Get-Date -Format 'yyyyMMdd').evtx
wevtutil clear-log System

# Backup puis clear Application log
wevtutil export-log Application C:\Logs\Application_backup_$(Get-Date -Format 'yyyyMMdd').evtx
wevtutil clear-log Application

# Via PowerShell
Get-EventLog -LogName System | Clear-EventLog
```

### Limiter taille logs
```powershell
# Augmenter taille max log (ex: 100MB)
Limit-EventLog -LogName System -MaximumSize 100MB -OverflowAction OverwriteAsNeeded
Limit-EventLog -LogName Application -MaximumSize 100MB -OverflowAction OverwriteAsNeeded
```

---

*Bibliothèque PowerShell Event Logs - IT-MaintenanceMaster v1.0*
