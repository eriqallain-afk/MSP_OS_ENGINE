#Requires -Version 5.1
# ============================================================
# Script  : SCRIPT_DIAG_DCDIAG-Quick_V1.ps1
# Desc    : Diagnostic rapide DC — repadmin + dcdiag + w32tm
# Usage   : Exécuter sur le DC concerné en admin
# ============================================================
Write-Host "=== REPADMIN replsummary ===" -ForegroundColor Cyan
repadmin /replsummary
Write-Host "=== DCDIAG (errors only) ===" -ForegroundColor Cyan
dcdiag /q
Write-Host "=== REPADMIN showrepl ===" -ForegroundColor Cyan
repadmin /showrepl
Write-Host "=== W32TM status ===" -ForegroundColor Cyan
w32tm /query /status
