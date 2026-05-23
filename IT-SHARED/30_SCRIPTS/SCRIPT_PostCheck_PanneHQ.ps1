<# 
CW RMM - POST-PANNE (Hydro/UPS) - Validation retour serveur
Sortie: GO/NO-GO + Transcript log (preuve) + ExitCode (0/1)

Basé sur le pattern PRE/POSTCHECK (uptime, pending reboot, disks, services auto, eventlogs):contentReference[oaicite:3]{index=3}
Inclut checks DC optionnels (services AD/DNS + SYSVOL/NETLOGON + replsummary):contentReference[oaicite:4]{index=4}
#>

[CmdletBinding()]
param(
  [string]$OutDir = "$env:TEMP\CW_PowerReturn",
  [int]$LookbackHours = 3,
  [int]$MinUptimeMinutes = 10,
  [string[]]$CriticalServices = @(),   # Optionnel: ex. @("MSSQLSERVER","SQLSERVERAGENT","W3SVC")
  [switch]$IncludeDCChecks = $true,
  [switch]$IncludeNetworkTests = $true
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$TS = Get-Date -Format "yyyyMMdd_HHmmss"
$LogPath = Join-Path $OutDir ("POST-PANNE_{0}.log" -f $TS)
Start-Transcript -Path $LogPath -Append | Out-Null

$Issues = New-Object System.Collections.Generic.List[string]
$Warnings = New-Object System.Collections.Generic.List[string]

function Add-Issue([string]$msg){ $Issues.Add($msg) | Out-Null }
function Add-Warn([string]$msg){ $Warnings.Add($msg) | Out-Null }

function Test-PendingReboot {
  # Pattern CBS/WU/FileRename/CCM:contentReference[oaicite:5]{index=5}
  $CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
  $WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
  $PFR = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
  $CCM = Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootPending'
  [pscustomobject]@{
    CBS_RebootPending            = $CBS
    WU_RebootRequired            = $WU
    PendingFileRenameOperations  = $PFR
    CCMClientRebootPending       = $CCM
    PendingReboot                = ($CBS -or $WU -or $PFR -or $CCM)
  }
}

function Get-DefaultGateway {
  try {
    $r = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction Stop |
      Sort-Object RouteMetric, ifIndex | Select-Object -First 1
    return $r.NextHop
  } catch {
    try {
      $rt = Get-CimInstance Win32_IP4RouteTable |
        Where-Object { $_.Destination -eq "0.0.0.0" -and $_.Mask -eq "0.0.0.0" } |
        Sort-Object Metric1 | Select-Object -First 1
      return $rt.NextHop
    } catch { return $null }
  }
}

function Test-DnsResolve([string]$Name){
  try {
    Resolve-DnsName -Name $Name -Type A -ErrorAction Stop | Out-Null
    return $true
  } catch {
    try {
      [System.Net.Dns]::GetHostAddresses($Name) | Out-Null
      return $true
    } catch { return $false }
  }
}

try {
  "=== HOST ==="
  hostname
  "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

  "=== OS / UPTIME ==="
  $os = Get-CimInstance Win32_OperatingSystem
  $lastBoot = $os.LastBootUpTime
  $uptime = (Get-Date) - $lastBoot
  [pscustomobject]@{
    CSName = $os.CSName
    Caption = $os.Caption
    Version = $os.Version
    LastBootUpTime = $lastBoot
    Uptime = ("{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes)
  } | Format-List

  if ($uptime.TotalMinutes -lt $MinUptimeMinutes) {
    Add-Warn "Uptime < ${MinUptimeMinutes} min (serveur vient de revenir). Re-run dans 10-15 min pour GO final."
  }

  "=== PENDING REBOOT (CBS/WU/FILE RENAME/CCM) ==="
  $pr = Test-PendingReboot
  $pr | Format-List
  if ($pr.PendingReboot) { Add-Issue "Pending reboot détecté (CBS/WU/FileRename/CCM)." }

  "=== DISKS (alert <10% free) ==="
  $drives = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
    Select-Object DeviceID, VolumeName,
      @{N="SizeGB";E={[math]::Round($_.Size/1GB,2)}},
      @{N="FreeGB";E={[math]::Round($_.FreeSpace/1GB,2)}},
      @{N="Free%";E={ if($_.Size -gt 0){ [math]::Round(($_.FreeSpace/$_.Size)*100,2) } else { 0 } }}
  $drives | Sort-Object DeviceID | Format-Table -Auto

  $low = $drives | Where-Object { $_.'Free%' -lt 10 }
  if ($low) { Add-Issue ("Espace disque faible (<10%) : {0}" -f (($low | ForEach-Object {"$($_.DeviceID)=$($_.'Free%')%"} ) -join ", ")) }

  "=== SERVICES (AUTO + NOT RUNNING) ==="
  $ignoreAutoStopped = @("gupdate","gupdatem","edgeupdate","edgeupdatem","GoogleUpdaterInternalService","GoogleUpdaterService")
  $autoStopped = Get-Service | Where-Object {
    $_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' -and ($ignoreAutoStopped -notcontains $_.Name)
  } | Select-Object Name,DisplayName,Status,StartType
  if ($autoStopped) {
    $autoStopped | Format-Table -Auto -Wrap
    Add-Issue ("Services auto arrêtés: {0}" -f (($autoStopped | Select-Object -First 20 | ForEach-Object {$_.Name}) -join ", "))
  } else {
    "OK: aucun service 'Automatic' arrêté (hors exceptions)."
  }

  # Critical services list (auto-detect if none provided)
  $crit = New-Object System.Collections.Generic.List[string]
  if ($CriticalServices -and $CriticalServices.Count -gt 0) {
    $CriticalServices | ForEach-Object { $crit.Add($_) | Out-Null }
  } else {
    if (Get-Service -Name NTDS -ErrorAction SilentlyContinue) { @("NTDS","DNS","Netlogon","KDC","W32Time") | ForEach-Object { $crit.Add($_) | Out-Null } }
    if (Get-Service -Name MSSQLSERVER -ErrorAction SilentlyContinue) { @("MSSQLSERVER","SQLSERVERAGENT") | ForEach-Object { $crit.Add($_) | Out-Null } }
    if (Get-Service -Name W3SVC -ErrorAction SilentlyContinue) { $crit.Add("W3SVC") | Out-Null }
    if (Get-Service -Name LanmanServer -ErrorAction SilentlyContinue) { $crit.Add("LanmanServer") | Out-Null }
  }

  if ($crit.Count -gt 0) {
    "=== SERVICES CRITIQUES (liste) ==="
    $crit | Sort-Object -Unique | ForEach-Object {
      $s = Get-Service -Name $_ -ErrorAction SilentlyContinue
      if ($null -eq $s) {
        Add-Warn "Service critique '$_' introuvable (peut être OK si rôle absent)."
      } elseif ($s.Status -ne "Running") {
        Add-Issue "Service critique NON RUNNING: $($_) (Status=$($s.Status))"
      } else {
        "OK: $_ = Running"
      }
    }
  }

  "=== EVENTLOG (System/Application) last ${LookbackHours}h OR since boot (Error/Critical) ==="
  $start = (Get-Date).AddHours(-$LookbackHours)
  if ($lastBoot -gt $start) { $start = $lastBoot }

  $sys = Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$start} |
    Where-Object { $_.LevelDisplayName -in 'Error','Critical' } |
    Select-Object -First 30 TimeCreated,Id,ProviderName,LevelDisplayName,Message
  $app = Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$start} |
    Where-Object { $_.LevelDisplayName -in 'Error','Critical' } |
    Select-Object -First 30 TimeCreated,Id,ProviderName,LevelDisplayName,Message

  "---- System (Top 30) ----"
  if ($sys) { $sys | Format-Table -Wrap } else { "OK: aucune erreur/critique System sur la fenêtre." }

  "---- Application (Top 30) ----"
  if ($app) { $app | Format-Table -Wrap } else { "OK: aucune erreur/critique Application sur la fenêtre." }

  # Filtre "problèmes post-retour" (exclure indicateurs de perte power attendus)
  $expectedAfterOutage = @(41,6008,6005,6006,1074)
  $badSys = @()
  if ($sys) { $badSys = $sys | Where-Object { $expectedAfterOutage -notcontains $_.Id } }
  if ($badSys -and $badSys.Count -gt 0) {
    Add-Issue ("Erreurs System non liées directement au power-loss (IDs hors {0})." -f ($expectedAfterOutage -join ","))
  }

  "=== OUTAGE INDICATORS (last 24h): 41/6008/6005/6006/1074 ==="
  $outageEvents = Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=(Get-Date).AddHours(-24); Id=@(41,6008,6005,6006,1074)} -ErrorAction SilentlyContinue |
    Select-Object -First 15 TimeCreated,Id,ProviderName,Message
  if ($outageEvents) { $outageEvents | Format-Table -Wrap } else { "Info: aucun event 'power/shutdown' trouvé sur 24h." }

  if ($IncludeNetworkTests) {
    "=== NETWORK TESTS ==="
    $gw = Get-DefaultGateway
    "DefaultGateway: $gw"
    if ($gw) {
      $gwPing = Test-Connection -ComputerName $gw -Count 2 -Quiet -ErrorAction SilentlyContinue
      "Ping GW: $gwPing"
      if (-not $gwPing) { Add-Issue "Gateway non joignable (ping KO) : $gw" }
    } else {
      Add-Warn "Default gateway non détecté."
    }

    $dnsOk = Test-DnsResolve "microsoft.com"
    "DNS Resolve microsoft.com: $dnsOk"
    if (-not $dnsOk) { Add-Issue "Résolution DNS externe KO (microsoft.com)." }
  }

  if ($IncludeDCChecks -and (Get-Service -Name NTDS -ErrorAction SilentlyContinue)) {
    "=== DC CHECKS (AD DS/DNS) ==="
    "Services critiques DC (NTDS/DNS/Netlogon/KDC/W32Time):contentReference[oaicite:6]{index=6}"
    Get-Service NTDS,DNS,Netlogon,KDC,W32Time | Format-Table Name,Status,StartType -Auto
    $dcBad = Get-Service NTDS,DNS,Netlogon,KDC,W32Time | Where-Object { $_.Status -ne "Running" }
    if ($dcBad) { Add-Issue ("DC service(s) non running: {0}" -f (($dcBad | ForEach-Object {$_.Name}) -join ", ")) }

    "Shares SYSVOL/NETLOGON:contentReference[oaicite:7]{index=7}"
    $shares = cmd /c 'net share' 2>$null
    $hasSysvol = $shares -match "SYSVOL"
    $hasNetlogon = $shares -match "NETLOGON"
    "SYSVOL share: $hasSysvol"
    "NETLOGON share: $hasNetlogon"
    if (-not $hasSysvol -or -not $hasNetlogon) { Add-Issue "SYSVOL/NETLOGON share manquant (AD pas pleinement prêt)." }

    "Replication summary (repadmin /replsummary):contentReference[oaicite:8]{index=8}"
    try {
      $rep = cmd /c 'repadmin /replsummary' 2>&1
      $rep
      if ($rep -match "Fails:\s*[1-9]") { Add-Issue "repadmin /replsummary indique des échecs." }
    } catch {
      Add-Warn "repadmin indisponible (pas DC ou droits/outils manquants)."
    }

    "DNS Server log last ${LookbackHours}h (Error/Critical):contentReference[oaicite:9]{index=9}"
    try {
      $dnsErr = Get-WinEvent -FilterHashtable @{LogName='DNS Server'; StartTime=$start} |
        Where-Object { $_.LevelDisplayName -in 'Error','Critical' } |
        Select-Object -First 20 TimeCreated,Id,ProviderName,Message
      if ($dnsErr) {
        $dnsErr | Format-Table -Wrap
        Add-Issue "Erreurs DNS Server détectées sur la fenêtre."
      } else { "OK: aucune erreur DNS Server sur la fenêtre." }
    } catch {
      Add-Warn "Log 'DNS Server' non accessible (role DNS absent?)."
    }
  }

  "=== SUMMARY ==="
  if ($Warnings.Count -gt 0) {
    "WARNINGS:"
    $Warnings | ForEach-Object { " - $_" }
  }
  if ($Issues.Count -gt 0) {
    "NO-GO"
    "ISSUES:"
    $Issues | ForEach-Object { " - $_" }
    "Proof log: $LogPath"
    Stop-Transcript | Out-Null
    exit 1
  } else {
    "GO"
    "Aucun indicateur bloquant détecté."
    "Proof log: $LogPath"
    Stop-Transcript | Out-Null
    exit 0
  }
}
catch {
  "=== SCRIPT ERROR ==="
  $_ | Format-List * -Force
  "Proof log (partial): $LogPath"
  try { Stop-Transcript | Out-Null } catch {}
  exit 1
}