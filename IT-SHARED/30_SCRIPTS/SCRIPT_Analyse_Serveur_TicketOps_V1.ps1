#Requires -Version 5.1
# ============================================================
# Script  : SCRIPT_Analyse_Serveur_TicketOps_V1.ps1
# Desc    : Analyse rôle + ressources serveur — lecture seule
#           Produit un role_profile + resource_summary YAML
#           pour @IT-OPS-RouterIA / @IT-TicketOpsAI
# Usage   : .\SCRIPT_Analyse_Serveur_TicketOps_V1.ps1
#           .\SCRIPT_Analyse_Serveur_TicketOps_V1.ps1 -Ticket "12345"
# Output  : Console YAML + log C:\IT_LOGS\TICKETOPS\
# ============================================================
[CmdletBinding()]
param(
    [string]$Ticket  = "00000",
    [string]$OutDir  = "C:\IT_LOGS\TICKETOPS"
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding          = [System.Text.Encoding]::UTF8

$Server  = $env:COMPUTERNAME
$DateTag = Get-Date -Format "yyyyMMdd_HHmm"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
$LogFile = "$OutDir\ANALYSE_${Server}_T${Ticket}_${DateTag}.log"
Start-Transcript -Path $LogFile -Append | Out-Null

# ── Helpers ───────────────────────────────────────────────────
function Get-ServiceStatus($Name) {
    $s = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($null -eq $s) { return "absent" }
    return $s.Status.ToString().ToLower()
}

function Test-PendingReboot {
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired",
        "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations"
    )
    foreach ($p in $paths) {
        if ($p -like "*PendingFileRenameOperations") {
            if ((Get-ItemProperty $p -ErrorAction SilentlyContinue).PendingFileRenameOperations) { return $true }
        } elseif (Test-Path $p) { return $true }
    }
    return $false
}

function Get-PendingUpdates {
    try {
        $session  = New-Object -ComObject Microsoft.Update.Session
        $searcher = $session.CreateUpdateSearcher()
        return $searcher.Search("IsInstalled=0 and Type='Software'").Updates.Count
    } catch { return -1 }
}

# ── OS / Domaine ──────────────────────────────────────────────
$os       = Get-CimInstance Win32_OperatingSystem
$cs       = Get-CimInstance Win32_ComputerSystem
$domain   = $cs.PartOfDomain
$lastBoot = $os.LastBootUpTime
$uptime   = [math]::Round(((Get-Date) - $lastBoot).TotalDays, 1)

# ── CPU ───────────────────────────────────────────────────────
$cpuLoad  = (Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average
$cpuCores = (Get-CimInstance Win32_Processor | Measure-Object NumberOfCores -Sum).Sum

# ── RAM ───────────────────────────────────────────────────────
$ramTotalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$ramFreeGB  = [math]::Round($os.FreePhysicalMemory      / 1MB, 1)
$ramUsedPct = [math]::Round((($ramTotalGB - $ramFreeGB) / $ramTotalGB) * 100, 0)

# ── Disques ───────────────────────────────────────────────────
$disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $freePct = [math]::Round(($_.FreeSpace / $_.Size) * 100, 1)
    [pscustomobject]@{
        letter   = $_.DeviceID
        size_gb  = [math]::Round($_.Size      / 1GB, 1)
        free_gb  = [math]::Round($_.FreeSpace / 1GB, 1)
        free_pct = $freePct
        warning  = $freePct -lt 15
        critical = $freePct -lt 10
    }
}
$diskCritical = @($disks | Where-Object { $_.critical } | ForEach-Object { $_.letter })
$diskWarning  = @($disks | Where-Object { $_.warning  } | ForEach-Object { $_.letter })

# ── Rôles détectés ────────────────────────────────────────────
$detectedRoles = @()
$keySignals    = @()

$svcNTDS    = Get-ServiceStatus "NTDS"
$svcDNS     = Get-ServiceStatus "DNS"
$svcDHCP    = Get-ServiceStatus "DHCPServer"
$svcSQL     = Get-ServiceStatus "MSSQLSERVER"
$svcSQLAlt  = Get-ServiceStatus "MSSQL`$SQLEXPRESS"
$svcIIS     = Get-ServiceStatus "W3SVC"
$svcHyperV  = Get-ServiceStatus "vmms"
$svcRDS     = Get-ServiceStatus "TermService"
$svcRDSLic  = Get-ServiceStatus "TermServLicensing"
$svcVeeam   = Get-ServiceStatus "VeeamBackupSvc"
$svcPrint   = Get-ServiceStatus "Spooler"

if ($svcNTDS -eq "running") { $detectedRoles += "domain_controller"; $keySignals += "Service NTDS running" }
if ($svcDNS  -eq "running") { $detectedRoles += "dns";               $keySignals += "Service DNS running" }
if ($svcDHCP -eq "running") { $detectedRoles += "dhcp";              $keySignals += "Service DHCPServer running" }
if ($svcSQL  -eq "running" -or $svcSQLAlt -eq "running") {
    $detectedRoles += "sql_server"; $keySignals += "Service MSSQL running"
}
if ($svcIIS    -eq "running") { $detectedRoles += "iis";         $keySignals += "Service W3SVC (IIS) running" }
if ($svcHyperV -eq "running") { $detectedRoles += "hyperv";      $keySignals += "Service vmms (Hyper-V) running" }
if ($svcRDS    -eq "running") { $detectedRoles += "rds";         $keySignals += "Service TermService (RDS) running" }
if ($svcRDSLic -eq "running") { $detectedRoles += "rds_licensing"; $keySignals += "Service TermServLicensing running" }
if ($svcVeeam  -eq "running") { $detectedRoles += "veeam_backup"; $keySignals += "Service VeeamBackupSvc running" }
if ($diskCritical.Count -gt 0)  { $keySignals += "Disque(s) critique(s) : $($diskCritical -join ', ')" }
if ($diskWarning.Count  -gt 0)  { $keySignals += "Disque(s) en avertissement : $($diskWarning -join ', ')" }

# ── Alertes ───────────────────────────────────────────────────
$pendingReboot   = Test-PendingReboot
$pendingUpdates  = Get-PendingUpdates
$servicesStopped = @()
$criticalServices = @("NTDS","DNS","DHCPServer","W3SVC","TermService","VeeamBackupSvc","MSSQLSERVER")
foreach ($svc in $criticalServices) {
    $st = Get-ServiceStatus $svc
    if ($st -eq "stopped") { $servicesStopped += $svc }
}
if ($pendingReboot)                 { $keySignals += "Reboot en attente détecté" }
if ($pendingUpdates -gt 0)          { $keySignals += "$pendingUpdates mise(s) à jour en attente" }
if ($servicesStopped.Count -gt 0)   { $keySignals += "Services arrêtés : $($servicesStopped -join ', ')" }

$roleConfidence = if ($detectedRoles.Count -gt 0) { 0.95 } else { 0.3 }
if ($detectedRoles.Count -eq 0) { $detectedRoles += "member_server" }

# ── Suggestion template TicketOps ─────────────────────────────
$templateSuggere = "CLOSE_Postcheck"
if ($diskCritical.Count -gt 0)                  { $templateSuggere = "CLOSE_DisquePlein" }
elseif ($servicesStopped -contains "DHCPServer" -or $servicesStopped -contains "DNS") { $templateSuggere = "CLOSE_DNS-DHCP" }
elseif ($svcRDSLic -eq "stopped" -and "rds" -in $detectedRoles) { $templateSuggere = "CLOSE_RDSLicensing" }
elseif ($pendingUpdates -gt 10)                 { $templateSuggere = "CLOSE_WindowsUpdateMissing" }
elseif ($pendingReboot -and $pendingUpdates -gt 0) { $templateSuggere = "CLOSE_Patching" }
elseif ($pendingReboot)                         { $templateSuggere = "CLOSE_RebootServeur" }

# ── Output YAML ───────────────────────────────────────────────
$yaml = @"
# ── COLLER CE BLOC DANS @IT-TicketOpsAI / @IT-OPS-RouterIA ──
# Ticket : #$Ticket | Généré : $(Get-Date -Format 'yyyy-MM-dd HH:mm') | Lecture seule

role_profile:
  server_name: "$Server"
  os_caption: "$($os.Caption)"
  os_version: "$($os.Version)"
  domain_joined: $($domain.ToString().ToLower())
  uptime_days: $uptime
  last_boot: "$($lastBoot.ToString('yyyy-MM-dd HH:mm'))"
  detected_roles: [$( ($detectedRoles | ForEach-Object { "`"$_`"" }) -join ", " )]
  role_confidence: $roleConfidence
  key_signals:
$(  $keySignals | ForEach-Object { "    - `"$_`"" } | Out-String )
resource_summary:
  cpu:
    cores: $cpuCores
    load_pct: $cpuLoad
  ram:
    total_gb: $ramTotalGB
    free_gb: $ramFreeGB
    used_pct: $ramUsedPct
  disks:
$(  $disks | ForEach-Object {
    "    - letter: `"$($_.letter)`"`n      size_gb: $($_.size_gb)`n      free_gb: $($_.free_gb)`n      free_pct: $($_.free_pct)`n      warning: $($_.warning.ToString().ToLower())`n      critical: $($_.critical.ToString().ToLower())"
  } | Out-String )
alerts:
  pending_reboot: $($pendingReboot.ToString().ToLower())
  pending_updates: $pendingUpdates
  disk_critical: [$( ($diskCritical | ForEach-Object { "`"$_`"" }) -join ", " )]
  disk_warning: [$( ($diskWarning  | ForEach-Object { "`"$_`"" }) -join ", " )]
  services_stopped: [$( ($servicesStopped | ForEach-Object { "`"$_`"" }) -join ", " )]

ticketops_hint:
  template_suggere: "$templateSuggere"
  ticket: "#$Ticket"
"@

Write-Host $yaml -ForegroundColor Green
Stop-Transcript | Out-Null
Write-Host "`n[Log sauvegardé : $LogFile]" -ForegroundColor DarkGray
<#
.SYNOPSIS
    Analyse du serveur pour IT-TicketOpsAI — rôle, ressources, alertes.
.DESCRIPTION
    Collecte en lecture seule le rôle, les ressources et les alertes d'un serveur.
    Produit un bloc YAML (role_profile + ticketops_hint) utilisable directement
    par IT-OPS-RouterIA pour router vers le bon runbook et template de fermeture.
.PARAMETER Ticket
    Numéro du billet CW (ex: "12345")
.PARAMETER OutDir
    Dossier de sortie pour le transcript (défaut: C:\IT_LOGS\TICKETOPS)
.NOTES
    Read-only. Aucune modification système. Aucune élévation requise.
    Version : 1.0 — 2026-05-09
    Agent   : IT-TicketOpsAI (MSP TicketOps AI)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$Ticket = "00000",

    [Parameter(Mandatory=$false)]
    [string]$OutDir = "C:\IT_LOGS\TICKETOPS"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "SilentlyContinue"

# ── Transcript ────────────────────────────────────────────────────────────
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
$TranscriptFile = Join-Path $OutDir ("TICKETOPS_Analyse_{0}_{1}.log" -f $Ticket, (Get-Date -Format "yyyyMMdd_HHmm"))
Start-Transcript -Path $TranscriptFile -Append | Out-Null

$ts = Get-Date -Format "yyyy-MM-dd HH:mm"
Write-Host "=== SCRIPT_Analyse_Serveur_TicketOps_V1 | Billet: #$Ticket | $ts ===" -ForegroundColor Cyan

# ── Système de base ───────────────────────────────────────────────────────
$os        = Get-CimInstance Win32_OperatingSystem
$cs        = Get-CimInstance Win32_ComputerSystem
$serverName = $env:COMPUTERNAME
$osCaption  = $os.Caption
$osVersion  = $os.Version

$domainJoined = if ($cs.PartOfDomain) { "true" } else { "false" }
$domainName   = if ($cs.PartOfDomain) { $cs.Domain } else { "WORKGROUP" }

# Uptime
$bootTime   = $os.LastBootUpTime
$uptime     = [math]::Round((New-TimeSpan -Start $bootTime -End (Get-Date)).TotalHours, 1)

# CPU load
$cpuLoad = (Get-CimInstance Win32_Processor | Measure-Object LoadPercentage -Average).Average

# RAM
$ramTotalGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
$ramFreeGB  = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$ramUsedPct = [math]::Round((($ramTotalGB - $ramFreeGB) / $ramTotalGB) * 100, 1)

# ── Disques ───────────────────────────────────────────────────────────────
$diskDetails = @()
$diskAlerts  = @()
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $freePct  = if ($_.Size -gt 0) { [math]::Round(($_.FreeSpace / $_.Size) * 100, 1) } else { 0 }
    $freeGB   = [math]::Round($_.FreeSpace / 1GB, 2)
    $totalGB  = [math]::Round($_.Size / 1GB, 1)
    $diskDetails += "    - drive: $($_.DeviceID) | total_gb: $totalGB | free_gb: $freeGB | free_pct: $freePct"
    if ($freePct -lt 15) { $diskAlerts += "disk_critical:$($_.DeviceID):${freePct}pct_free" }
    elseif ($freePct -lt 25) { $diskAlerts += "disk_warning:$($_.DeviceID):${freePct}pct_free" }
}

# ── Détection des rôles via services ─────────────────────────────────────
function Get-ServiceStatus([string]$Name) {
    $svc = Get-Service -Name $Name -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq "Running") { return $true }
    return $false
}

$detectedRoles  = @()
$roleConfidence = @{}

if (Get-ServiceStatus "NTDS") {
    $detectedRoles += "domain_controller"
    $roleConfidence["domain_controller"] = "high"
}
if (Get-ServiceStatus "DNS") {
    $detectedRoles += "dns_server"
    $roleConfidence["dns_server"] = "high"
}
if (Get-ServiceStatus "DHCPServer") {
    $detectedRoles += "dhcp_server"
    $roleConfidence["dhcp_server"] = "high"
}
if (Get-ServiceStatus "MSSQLSERVER" -or (Get-Service "MSSQL$*" -ErrorAction SilentlyContinue | Where-Object Status -eq "Running")) {
    $detectedRoles += "sql_server"
    $roleConfidence["sql_server"] = "high"
}
if (Get-ServiceStatus "W3SVC") {
    $detectedRoles += "iis_web"
    $roleConfidence["iis_web"] = "high"
}
if (Get-ServiceStatus "vmms") {
    $detectedRoles += "hyperv_host"
    $roleConfidence["hyperv_host"] = "high"
}
if (Get-ServiceStatus "TermService") {
    $detectedRoles += "rds_host"
    $roleConfidence["rds_host"] = "medium"
}
if (Get-ServiceStatus "TermServLicensing") {
    $detectedRoles += "rds_licensing"
    $roleConfidence["rds_licensing"] = "high"
}
if (Get-ServiceStatus "VeeamBackupSvc") {
    $detectedRoles += "veeam_backup"
    $roleConfidence["veeam_backup"] = "high"
}
if (Get-ServiceStatus "WsusService") {
    $detectedRoles += "wsus_server"
    $roleConfidence["wsus_server"] = "high"
}
if (Get-ServiceStatus "PrintSpooler" -and (Get-Printer -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0) {
    $detectedRoles += "print_server"
    $roleConfidence["print_server"] = "medium"
}

if ($detectedRoles.Count -eq 0) { $detectedRoles += "member_server" }

# ── Alertes ───────────────────────────────────────────────────────────────
$alerts = @()

# Pending reboot
$rebootPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending",
    "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations",
    "HKLM:\SOFTWARE\Microsoft\Updates\UpdateExeVolatile"
)
foreach ($path in $rebootPaths) {
    if (Test-Path $path) {
        $alerts += "pending_reboot"
        break
    }
}

# Windows Update pending
try {
    $updateSession  = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $searchResult   = $updateSearcher.Search("IsInstalled=0 AND IsHidden=0")
    $updateCount    = $searchResult.Updates.Count
    if ($updateCount -gt 0) { $alerts += "pending_updates:$updateCount" }
} catch {}

# Services critiques arrêtés (filtre services Windows essentiels)
$criticalServices = @("Winmgmt","EventLog","RpcSs","LanmanServer")
$stoppedCritical  = @()
foreach ($svcName in $criticalServices) {
    $svc = Get-Service -Name $svcName -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -ne "Running") { $stoppedCritical += $svcName }
}
if ($stoppedCritical.Count -gt 0) { $alerts += "services_stopped:$($stoppedCritical -join ',')" }

# Disque critique
$alerts += $diskAlerts

if ($alerts.Count -eq 0) { $alerts += "none" }

# ── Sélection du template suggéré ─────────────────────────────────────────
$templateSuggere = "CLOSE_Postcheck"

if ($alerts -contains "pending_reboot") {
    $templateSuggere = "CLOSE_RebootServeur"
} elseif ($alerts | Where-Object { $_ -like "pending_updates*" }) {
    $templateSuggere = "CLOSE_WindowsUpdateMissing"
} elseif ($alerts | Where-Object { $_ -like "disk_critical*" }) {
    $templateSuggere = "CLOSE_DisquePlein"
} elseif ($detectedRoles -contains "rds_licensing") {
    $templateSuggere = "CLOSE_RDSLicensing"
} elseif ($detectedRoles -contains "domain_controller") {
    $templateSuggere = "CLOSE_Patching"
} elseif ($detectedRoles -contains "veeam_backup") {
    $templateSuggere = "CLOSE_BackupFailed"
} elseif ($detectedRoles -contains "dns_server" -or $detectedRoles -contains "dhcp_server") {
    $templateSuggere = "CLOSE_DNS-DHCP"
} elseif ($detectedRoles -contains "hyperv_host") {
    $templateSuggere = "CLOSE_SnapshotVMware"
}

# ── Sélection de l'intent RouterIA ────────────────────────────────────────
$routerIntent = "it.discovery.server_role"

if ($alerts -contains "pending_reboot") {
    $routerIntent = "it.maintenance.pending_reboot"
} elseif ($alerts | Where-Object { $_ -like "pending_updates*" }) {
    $routerIntent = "it.maintenance.patching_windows_updates_missing"
} elseif ($alerts | Where-Object { $_ -like "disk_critical*" }) {
    $routerIntent = "it.maintenance.disk_full"
} elseif ($detectedRoles -contains "rds_licensing") {
    $routerIntent = "it.infra.rds_licensing"
} elseif ($detectedRoles -contains "domain_controller") {
    $routerIntent = "it.infra.dc_operations"
} elseif ($detectedRoles -contains "veeam_backup") {
    $routerIntent = "it.backup.veeam_failed"
} elseif ($detectedRoles -contains "dns_server" -or $detectedRoles -contains "dhcp_server") {
    $routerIntent = "it.infra.dns_dhcp"
} elseif ($detectedRoles -contains "hyperv_host") {
    $routerIntent = "it.infra.hyperv"
} elseif ($detectedRoles -contains "sql_server") {
    $routerIntent = "it.infra.sql_server"
} elseif ($detectedRoles -contains "rds_host") {
    $routerIntent = "it.infra.rds_operations"
} else {
    $routerIntent = "it.maintenance.health_check"
}

# ── Sortie YAML ───────────────────────────────────────────────────────────
$rolesYaml         = ($detectedRoles | ForEach-Object { "      - $_" }) -join "`n"
$confYaml          = ($roleConfidence.GetEnumerator() | ForEach-Object { "      $($_.Key): $($_.Value)" }) -join "`n"
$alertsYaml        = ($alerts | ForEach-Object { "      - $_" }) -join "`n"
$diskYaml          = $diskDetails -join "`n"

$yaml = @"
# SCRIPT_Analyse_Serveur_TicketOps_V1 — Output YAML
# Billet  : #$Ticket
# Généré  : $ts
# Usage   : Coller dans IT-OPS-RouterIA ou IT-TicketOpsAI /start

role_profile:
  server_name: "$serverName"
  os: "$osCaption ($osVersion)"
  domain_joined: $domainJoined
  domain: "$domainName"
  uptime_hours: $uptime
  detected_roles:
$rolesYaml
  role_confidence:
$confYaml

resource_summary:
  cpu_load_pct: $cpuLoad
  ram_total_gb: $ramTotalGB
  ram_free_gb: $ramFreeGB
  ram_used_pct: $ramUsedPct
  disks:
$diskYaml

alerts:
$alertsYaml

ticketops_hint:
  ticket: "#$Ticket"
  template_suggere: "$templateSuggere"
  router_intent: "$routerIntent"
  index_path: "IT-SHARED/00_INDEX/MASTER_DISPATCH_INDEX_V2.yaml"
"@

Write-Host "`n$yaml" -ForegroundColor Yellow

# Sauvegarder le YAML dans OutDir
$yamlFile = Join-Path $OutDir ("TICKETOPS_Output_{0}_{1}.yaml" -f $Ticket, (Get-Date -Format "yyyyMMdd_HHmm"))
$yaml | Out-File -FilePath $yamlFile -Encoding UTF8
Write-Host "`n[OK] YAML sauvegardé : $yamlFile" -ForegroundColor Green

Stop-Transcript | Out-Null
