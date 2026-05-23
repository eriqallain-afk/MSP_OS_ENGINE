#Requires -Version 5.1
# ============================================================
# Script  : AUDIT_WS_Perf_ReadOnly_v2.ps1
# Billet  : T1706472
# Auteur  : MSP
# Date    : 2026-04-02
# Version : 2.0
# Desc    : Audit lecture seule d'un poste lent (CPU/RAM/Disk/Events/Perf)
# ============================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

[CmdletBinding()]
param(
    [ValidateRange(30,3600)]
    [int]$DurationSeconds = 180,

    [ValidateRange(1,60)]
    [int]$SampleSeconds = 5,

    [ValidateNotNullOrEmpty()]
    [string]$OutputBase = "$env:ProgramData\MSP_Audit\AUDIT_T1706472"
)

$Category = "AUDIT"
$Ticket   = "T1706472"
$HostName = if ([string]::IsNullOrWhiteSpace($env:COMPUTERNAME)) { "UNKNOWN_HOST" } else { $env:COMPUTERNAME }
$Stamp    = Get-Date -Format "yyyyMMdd_HHmmss"
$OutRoot  = Join-Path $OutputBase "${HostName}_WS_PERF_$Stamp"

function New-FolderSafe {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Save-Txt {
    param(
        [Parameter(Mandatory)][string]$Path,
        [AllowNull()]$Content
    )

    $lines = @()
    if ($null -eq $Content) {
        $lines = @("<no output>")
    }
    elseif ($Content -is [string]) {
        $lines = ($Content -split "(`r`n|`n|`r)")
    }
    else {
        $lines = @($Content | ForEach-Object { "$_" })
    }

    $lines = @($lines | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($lines.Count -eq 0) { $lines = @("<no output>") }

    $lines | Out-File -FilePath $Path -Encoding UTF8
}

function Get-PendingRebootState {
    $cbs = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
    $wu  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    $pfr = $null -ne (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue)
    $ccm = Test-Path 'HKLM:\SOFTWARE\Microsoft\CCM\RebootPending'

    [pscustomobject]@{
        CBS_RebootPending            = $cbs
        WU_RebootRequired            = $wu
        PendingFileRenameOperations  = $pfr
        CCMClientRebootPending       = $ccm
        PendingReboot                = ($cbs -or $wu -or $pfr -or $ccm)
    }
}

function Get-CounterValue {
    param(
        [Parameter(Mandatory)]$Samples,
        [Parameter(Mandatory)][string]$Regex,
        [switch]$Sum
    )

    $matches = $Samples | Where-Object { $_.Path -match $Regex }

    if (-not $matches) { return $null }

    if ($Sum) {
        return [double](($matches | Measure-Object -Property CookedValue -Sum).Sum)
    }

    return [double]($matches | Select-Object -First 1 -ExpandProperty CookedValue)
}

New-FolderSafe -Path $OutputBase
New-FolderSafe -Path $OutRoot

$LogDir  = "C:\IT_LOGS\$Category"
$LogFile = Join-Path $LogDir "${Category}_${HostName}_${Ticket}_$Stamp.log"
New-FolderSafe -Path $LogDir

Start-Transcript -Path $LogFile -Append | Out-Null
Write-Host "=== Debut : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" -ForegroundColor Cyan
Write-Host "[INFO] Output : $OutRoot" -ForegroundColor Cyan

try {
    # -----------------------------------------------------------------
    # 01 - BASELINE
    # -----------------------------------------------------------------
    try {
        $os      = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
        $cs      = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
        $cpuInfo = Get-CimInstance Win32_Processor -ErrorAction Stop |
            Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, LoadPercentage

        $pendingReboot = Get-PendingRebootState

        $disks = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" -ErrorAction Stop |
            Select-Object DeviceID,
                VolumeName,
                @{N="SizeGB";E={ if ($_.Size) { [math]::Round($_.Size / 1GB, 1) } else { $null } }},
                @{N="FreeGB";E={ if ($_.FreeSpace -ne $null) { [math]::Round($_.FreeSpace / 1GB, 1) } else { $null } }},
                @{N="FreePct";E={ if ($_.Size) { [math]::Round(($_.FreeSpace / $_.Size) * 100, 0) } else { $null } }}

        $autoServicesNotRunning = Get-Service -ErrorAction SilentlyContinue |
            Where-Object { $_.StartType -eq 'Automatic' -and $_.Status -ne 'Running' } |
            Select-Object Name, DisplayName, Status, StartType

        [pscustomobject]@{
            ComputerName       = $HostName
            OS                 = $os.Caption
            Version            = $os.Version
            BuildNumber        = $os.BuildNumber
            LastBoot           = $os.LastBootUpTime
            UptimeDays         = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalDays, 2)
            MemoryGB_Total     = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
            PendingReboot      = $pendingReboot
            CPU                = $cpuInfo
            Disks              = $disks
            AutoServicesIssue  = $autoServicesNotRunning
        } | ConvertTo-Json -Depth 6 | Out-File (Join-Path $OutRoot "01_Baseline.json") -Encoding UTF8

        $disks | Export-Csv (Join-Path $OutRoot "01_Disks.csv") -NoTypeInformation -Encoding UTF8
        $autoServicesNotRunning | Export-Csv (Join-Path $OutRoot "01_AutoServices_NotRunning.csv") -NoTypeInformation -Encoding UTF8
    }
    catch {
        Save-Txt -Path (Join-Path $OutRoot "01_Baseline_ERROR.txt") -Content $_.Exception.Message
    }

    # -----------------------------------------------------------------
    # 02 - PROCESSUS
    # -----------------------------------------------------------------
    try {
        Get-Process -ErrorAction Stop |
            Sort-Object CPU -Descending |
            Select-Object -First 25 Name, Id,
                @{N="CPU_Seconds";E={ [math]::Round(($_.CPU | ForEach-Object { $_ }) ,2) }},
                @{N="WS_GB";E={ [math]::Round($_.WS / 1GB, 2) }},
                @{N="PM_GB";E={ [math]::Round($_.PM / 1GB, 2) }} |
            Export-Csv (Join-Path $OutRoot "02_TopCPUTime.csv") -NoTypeInformation -Encoding UTF8

        Get-Process -ErrorAction Stop |
            Sort-Object WS -Descending |
            Select-Object -First 25 Name, Id,
                @{N="WS_GB";E={ [math]::Round($_.WS / 1GB, 2) }},
                @{N="PM_GB";E={ [math]::Round($_.PM / 1GB, 2) }},
                CPU |
            Export-Csv (Join-Path $OutRoot "02_TopRAM.csv") -NoTypeInformation -Encoding UTF8

        Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
            Select-Object Name, ProcessId, ParentProcessId, CreationDate, CommandLine |
            Export-Csv (Join-Path $OutRoot "02_ProcessCommandLine.csv") -NoTypeInformation -Encoding UTF8
    }
    catch {
        Save-Txt -Path (Join-Path $OutRoot "02_TopProc_ERROR.txt") -Content $_.Exception.Message
    }

    # -----------------------------------------------------------------
    # 03 - PERF SAMPLING
    # -----------------------------------------------------------------
    $counters = @(
        '\Processor(_Total)\% Processor Time',
        '\System\Processor Queue Length',
        '\Memory\Available MBytes',
        '\Memory\Pages/sec',
        '\LogicalDisk(_Total)\Avg. Disk sec/Read',
        '\LogicalDisk(_Total)\Avg. Disk sec/Write',
        '\LogicalDisk(_Total)\Current Disk Queue Length',
        '\LogicalDisk(_Total)\Disk Transfers/sec',
        '\Network Interface(*)\Bytes Total/sec'
    )

    $rows = New-Object System.Collections.Generic.List[object]
    $iterations = [math]::Max([int]($DurationSeconds / $SampleSeconds), 1)

    for ($i = 1; $i -le $iterations; $i++) {
        try {
            $gc = Get-Counter -Counter $counters -ErrorAction Stop

            $samples = $gc.CounterSamples

            $cpuTotalPct = Get-CounterValue -Samples $samples -Regex '(?i)processor\(_total\)\\% processor time$'
            $cpuQueue    = Get-CounterValue -Samples $samples -Regex '(?i)system\\processor queue length$'
            $memAvailMB  = Get-CounterValue -Samples $samples -Regex '(?i)memory\\available mbytes$'
            $pagesPerSec = Get-CounterValue -Samples $samples -Regex '(?i)memory\\pages/sec$'
            $diskReadSec = Get-CounterValue -Samples $samples -Regex '(?i)logicaldisk\(_total\)\\avg\. disk sec/read$'
            $diskWriteSec= Get-CounterValue -Samples $samples -Regex '(?i)logicaldisk\(_total\)\\avg\. disk sec/write$'
            $diskQueue   = Get-CounterValue -Samples $samples -Regex '(?i)logicaldisk\(_total\)\\current disk queue length$'
            $diskXferSec = Get-CounterValue -Samples $samples -Regex '(?i)logicaldisk\(_total\)\\disk transfers/sec$'
            $netBytesSec = Get-CounterValue -Samples $samples -Regex '(?i)network interface\(.+\)\\bytes total/sec$' -Sum

            $rows.Add([pscustomobject]@{
                TimeStamp       = (Get-Date).ToString("s")
                CPU_TotalPct    = if ($cpuTotalPct -ne $null) { [math]::Round($cpuTotalPct, 2) } else { $null }
                CPU_Queue       = if ($cpuQueue    -ne $null) { [math]::Round($cpuQueue, 2) } else { $null }
                MemAvailMB      = if ($memAvailMB  -ne $null) { [math]::Round($memAvailMB, 0) } else { $null }
                PagesPerSec     = if ($pagesPerSec -ne $null) { [math]::Round($pagesPerSec, 2) } else { $null }
                DiskReadSec     = if ($diskReadSec -ne $null) { [math]::Round($diskReadSec, 4) } else { $null }
                DiskWriteSec    = if ($diskWriteSec -ne $null) { [math]::Round($diskWriteSec, 4) } else { $null }
                DiskQueue       = if ($diskQueue   -ne $null) { [math]::Round($diskQueue, 2) } else { $null }
                DiskXferSec     = if ($diskXferSec -ne $null) { [math]::Round($diskXferSec, 2) } else { $null }
                NetBytesTotalSec= if ($netBytesSec -ne $null) { [math]::Round($netBytesSec, 2) } else { $null }
            }) | Out-Null
        }
        catch {
            Save-Txt -Path (Join-Path $OutRoot "03_PerfSamples_WARN.txt") -Content "Iteration $i failed: $($_.Exception.Message)"
        }

        if ($i -lt $iterations) {
            Start-Sleep -Seconds $SampleSeconds
        }
    }

    $rows | Export-Csv (Join-Path $OutRoot "03_PerfSamples.csv") -NoTypeInformation -Encoding UTF8

    try {
        if ($rows.Count -gt 0) {
            $summary = [pscustomobject]@{
                Samples              = $rows.Count
                AvgCPU_TotalPct      = [math]::Round((($rows | Where-Object { $_.CPU_TotalPct -ne $null } | Measure-Object -Property CPU_TotalPct -Average).Average),2)
                MaxCPU_TotalPct      = [math]::Round((($rows | Where-Object { $_.CPU_TotalPct -ne $null } | Measure-Object -Property CPU_TotalPct -Maximum).Maximum),2)
                MaxCPU_Queue         = [math]::Round((($rows | Where-Object { $_.CPU_Queue -ne $null } | Measure-Object -Property CPU_Queue -Maximum).Maximum),2)
                MinMemAvailMB        = [math]::Round((($rows | Where-Object { $_.MemAvailMB -ne $null } | Measure-Object -Property MemAvailMB -Minimum).Minimum),0)
                AvgPagesPerSec       = [math]::Round((($rows | Where-Object { $_.PagesPerSec -ne $null } | Measure-Object -Property PagesPerSec -Average).Average),2)
                MaxDiskReadMs        = [math]::Round((((($rows | Where-Object { $_.DiskReadSec -ne $null } | Measure-Object -Property DiskReadSec -Maximum).Maximum)) * 1000),2)
                MaxDiskWriteMs       = [math]::Round((((($rows | Where-Object { $_.DiskWriteSec -ne $null } | Measure-Object -Property DiskWriteSec -Maximum).Maximum)) * 1000),2)
                MaxDiskQueue         = [math]::Round((($rows | Where-Object { $_.DiskQueue -ne $null } | Measure-Object -Property DiskQueue -Maximum).Maximum),2)
                MaxDiskXferSec       = [math]::Round((($rows | Where-Object { $_.DiskXferSec -ne $null } | Measure-Object -Property DiskXferSec -Maximum).Maximum),2)
                MaxNetBytesTotalSec  = [math]::Round((($rows | Where-Object { $_.NetBytesTotalSec -ne $null } | Measure-Object -Property NetBytesTotalSec -Maximum).Maximum),2)
            }

            $summary | ConvertTo-Json -Depth 4 | Out-File (Join-Path $OutRoot "03_PerfSummary.json") -Encoding UTF8
        }
    }
    catch {
        Save-Txt -Path (Join-Path $OutRoot "03_PerfSummary_ERROR.txt") -Content $_.Exception.Message
    }

    # -----------------------------------------------------------------
    # 04 - EVENTS DERNIERE HEURE
    # -----------------------------------------------------------------
    try {
        $start = (Get-Date).AddHours(-1)

        $systemEvents = Get-WinEvent -FilterHashtable @{ LogName='System'; StartTime=$start } -ErrorAction SilentlyContinue |
            Where-Object {
                $_.LevelDisplayName -in @('Error','Critical','Warning') -or
                $_.ProviderName -in @('Disk','Ntfs','storahci','stornvme','iaStor','Tcpip','W32Time','Service Control Manager')
            } |
            Select-Object TimeCreated, ProviderName, Id, LevelDisplayName, Message

        $appEvents = Get-WinEvent -FilterHashtable @{ LogName='Application'; StartTime=$start } -ErrorAction SilentlyContinue |
            Where-Object { $_.LevelDisplayName -in @('Error','Critical','Warning') } |
            Select-Object TimeCreated, ProviderName, Id, LevelDisplayName, Message

        $systemEvents | Export-Csv (Join-Path $OutRoot "04_SystemEvents_1h.csv") -NoTypeInformation -Encoding UTF8
        $appEvents    | Export-Csv (Join-Path $OutRoot "04_ApplicationEvents_1h.csv") -NoTypeInformation -Encoding UTF8
    }
    catch {
        Save-Txt -Path (Join-Path $OutRoot "04_Events_ERROR.txt") -Content $_.Exception.Message
    }

    # -----------------------------------------------------------------
    # 05 - TACHES / STARTUP / UPDATE
    # -----------------------------------------------------------------
    try {
        Get-ScheduledTask -ErrorAction SilentlyContinue |
            Select-Object TaskName, TaskPath, State,
                @{N='LastRunTime';E={$_.LastRunTime}},
                @{N='NextRunTime';E={$_.NextRunTime}} |
            Export-Csv (Join-Path $OutRoot "05_ScheduledTasks.csv") -NoTypeInformation -Encoding UTF8
    }
    catch {
        Save-Txt -Path (Join-Path $OutRoot "05_ScheduledTasks_ERROR.txt") -Content $_.Exception.Message
    }

    Save-Txt -Path (Join-Path $OutRoot "00_DONE.txt") -Content "Done: $OutRoot"
    Write-Host "[OK] Done: $OutRoot" -ForegroundColor Green
}
catch {
    Save-Txt -Path (Join-Path $OutRoot "99_FATAL_ERROR.txt") -Content $_.Exception.ToString()
    Write-Host "[ERREUR] Audit fatal: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    Write-Host "=== Fin : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" -ForegroundColor Cyan
    Stop-Transcript | Out-Null
}