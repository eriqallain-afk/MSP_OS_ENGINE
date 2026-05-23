#Requires -Version 5.1
# ============================================================
# Script  : SCRIPT_DIAG_RAM-TopProcess_V1.ps1
# Desc    : Top 10 processus par consommation RAM
# ============================================================
Write-Host "=== TOP 10 PROCESSUS PAR RAM ===" -ForegroundColor Cyan
Get-Process | Sort-Object WorkingSet -Descending |
    Select-Object -First 10 Name, Id,
        @{n='WS_MB';e={[math]::Round($_.WorkingSet/1MB,0)}},
        @{n='CPU_sec';e={[math]::Round($_.CPU,1)}} |
    Format-Table -AutoSize
