# LIBRARY_PS_PowerShell-Snippets_V1
**Agent :** IT-ScriptMaster, IT-MaintenanceMaster, IT-Assistant-N3 | IT-SysAdmin
**Usage :** Snippets PowerShell réutilisables — copier-coller direct en intervention
**Mis à jour :** 2026-03-20

---

## 1. SYSTÈME — INFO DE BASE

```powershell
# Info OS + uptime
$os = Get-CimInstance Win32_OperatingSystem
[pscustomobject]@{
    Hostname   = $env:COMPUTERNAME
    OS         = $os.Caption
    Version    = $os.Version
    LastBoot   = $os.LastBootUpTime.ToString('yyyy-MM-dd HH:mm')
    Uptime_Days= [math]::Round(((Get-Date)-$os.LastBootUpTime).TotalDays,1)
} | Format-List

# CPU
Get-CimInstance Win32_Processor |
    Select-Object Name, NumberOfCores, NumberOfLogicalProcessors,
    @{N='Load%';E={$_.LoadPercentage}} | Format-Table -AutoSize

# RAM
[pscustomobject]@{
    Total_GB = [math]::Round($os.TotalVisibleMemorySize/1MB,1)
    Free_GB  = [math]::Round($os.FreePhysicalMemory/1MB,1)
    Used_PCT = [math]::Round(($os.TotalVisibleMemorySize-$os.FreePhysicalMemory)/$os.TotalVisibleMemorySize*100,0)
} | Format-List

# Disques
Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -gt 0} |
    Select-Object Name,
        @{N='Total_GB';E={[math]::Round(($_.Used+$_.Free)/1GB,1)}},
        @{N='Free_GB';E={[math]::Round($_.Free/1GB,1)}},
        @{N='Free%';E={[math]::Round($_.Free/($_.Used+$_.Free)*100,0)}} |
    Format-Table -AutoSize
```

---

## 2. SERVICES

```powershell
# Services Auto démarrés mais arrêtés (anormal)
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -eq 'Stopped'} |
    Select-Object Name, DisplayName, Status | Format-Table -AutoSize

# Redémarrer un service
Restart-Service -Name "NomService" -Force
Get-Service "NomService" | Select-Object Name, Status

# Services critiques spécifiques
Get-Service NTDS,DNS,Netlogon,KDC,W32Time,MSSQLSERVER,W3SVC,TermService -ErrorAction SilentlyContinue |
    Select-Object Name, Status, StartType | Format-Table -AutoSize
```

---

## 3. RÉSEAU

```powershell
# Interfaces actives
Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} |
    Select-Object Name, Status, LinkSpeed, MacAddress | Format-Table -AutoSize

# Adresses IP
Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object {$_.IPAddress -notmatch '^169|^127'} |
    Select-Object InterfaceAlias, IPAddress, PrefixLength | Format-Table -AutoSize

# Test connectivité rapide
@("8.8.8.8","google.com","domaine.local") | ForEach-Object {
    $r = Test-NetConnection $_ -InformationLevel Quiet -WarningAction SilentlyContinue
    [pscustomobject]@{Cible=$_; Atteint=$r}
} | Format-Table -AutoSize

# Connexions établies (top 20)
netstat -ano | Select-String "ESTABLISHED" | Select-Object -First 20
```

---

## 4. ACTIVE DIRECTORY

```powershell
# Utilisateur AD — info complète
Get-ADUser "prenom.nom" -Properties * |
    Select-Object Name, SamAccountName, Enabled, LockedOut,
    PasswordExpired, LastLogonDate, Department | Format-List

# Compte verrouillé — débloquer
Unlock-ADAccount -Identity "prenom.nom"

# Réinitialiser mot de passe
Set-ADAccountPassword "prenom.nom" -Reset -NewPassword (Read-Host -AsSecureString "Nouveau MDP")
Set-ADUser "prenom.nom" -ChangePasswordAtLogon $true

# Groupes d'un utilisateur
(Get-ADUser "prenom.nom" -Properties MemberOf).MemberOf |
    ForEach-Object { (Get-ADGroup $_).Name } | Sort-Object

# Comptes inactifs depuis 90 jours
Search-ADAccount -AccountInactive -TimeSpan (New-TimeSpan -Days 90) -UsersOnly |
    Where-Object {$_.Enabled} |
    Get-ADUser -Properties LastLogonDate,Department |
    Select-Object Name, SamAccountName, LastLogonDate, Department |
    Sort-Object LastLogonDate | Format-Table -AutoSize
```

---

## 5. WINDOWS UPDATE / PATCH

```powershell
# Patchs installés récemment (30 derniers jours)
Get-HotFix | Where-Object {$_.InstalledOn -gt (Get-Date).AddDays(-30)} |
    Sort-Object InstalledOn -Descending |
    Select-Object Description, HotFixID, InstalledOn | Format-Table

# Pending reboot
$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = $null -ne (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' `
    -Name PendingFileRenameOperations -EA SilentlyContinue)
[pscustomobject]@{CBS=$CBS; WU=$WU; PendingFileRename=$PFR; Pending=($CBS -or $WU -or $PFR)} | Format-List
```

---

## 6. EVENT LOGS

```powershell
# Erreurs System (48h)
$start = (Get-Date).AddHours(-48)
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$start; Level=1,2} -EA SilentlyContinue |
    Select-Object -First 20 TimeCreated, Id, ProviderName,
        @{N='Msg';E={$_.Message.Substring(0,[math]::Min(200,$_.Message.Length))}} |
    Format-Table -Wrap

# Event ID spécifique
Get-WinEvent -FilterHashtable @{LogName='System'; Id=6008} -MaxEvents 5 -EA SilentlyContinue |
    Select-Object TimeCreated, Message | Format-List
```

---

## 7. PROCESSUS ET PERFORMANCE

```powershell
# Top 10 par CPU
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, Id,
    @{N='CPU_s';E={[math]::Round($_.CPU,0)}},
    @{N='RAM_MB';E={[math]::Round($_.WorkingSet/1MB,0)}} | Format-Table -AutoSize

# Top 10 par RAM
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name, Id,
    @{N='RAM_MB';E={[math]::Round($_.WorkingSet/1MB,0)}} | Format-Table -AutoSize

# Tuer un processus (avec confirmation)
$proc = Get-Process -Name "NomProcessus" -ErrorAction SilentlyContinue
if ($proc) { $proc | Stop-Process -Force; Write-Host "Tué : $($proc.Name)" }
else { Write-Host "Processus non trouvé" }
```

---

## 8. FICHIERS ET DISQUE

```powershell
# Top 20 fichiers les plus lourds
Get-ChildItem "C:\" -Recurse -ErrorAction SilentlyContinue |
    Where-Object {-not $_.PSIsContainer} |
    Sort-Object Length -Descending | Select-Object -First 20 FullName,
        @{N='MB';E={[math]::Round($_.Length/1MB,1)}} | Format-Table -AutoSize

# Dossiers temporaires à nettoyer
@("$env:TEMP","C:\Windows\Temp","C:\Windows\SoftwareDistribution\Download") |
    ForEach-Object {
        $size = (Get-ChildItem $_ -Recurse -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum
        [pscustomobject]@{Path=$_; Size_MB=[math]::Round($size/1MB,0)}
    } | Format-Table -AutoSize
```

---

## 9. MASQUAGE IP (OBLIGATOIRE DANS LES LOGS)

```powershell
function Mask-IP {
    param([string]$Text)
    $t = [regex]::Replace($Text, '\b(\d{1,3}\.){3}\d{1,3}\b', '[IP]')
    $t = [regex]::Replace($t,   '\b([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}\b', '[IPV6]')
    return $t
}
# Utilisation : Mask-IP $sortieCommande
```
