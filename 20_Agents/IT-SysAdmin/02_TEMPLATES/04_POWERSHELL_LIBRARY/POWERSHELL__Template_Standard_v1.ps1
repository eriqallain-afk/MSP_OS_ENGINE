#Requires -Version 5.1
# ============================================================
# Script  : MAINT_Patching_AllServers_v1.ps1
# Billet  : T00000
# Auteur  : [TECHNICIEN]
# Date    : 2026-03-02
# Version : 1.0
# Desc    : <description courte de l'objectif du script>
# ============================================================
# USAGE : Remplacer tous les [PLACEHOLDER] avant exécution.
#         Ne jamais exécuter sans avoir lu les sections ⚠️ Impact.
# ============================================================

# --- Encodage UTF-8 — TOUJOURS EN PREMIER après le header ---
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# --- Variables à ajuster ---
$Categorie = "MAINT"                  # MAINT|DIAG|AUDIT|SECU|BACKUP|REPORT|DEPLOY|CONFIG
$Billet    = "T00000"                 # Numéro CW sans @
$Action    = "Patching"               # Action principale du script
$Cible     = "AllServers"             # Scope / cible

# --- Logging automatique ---
$Serveur = $env:COMPUTERNAME
$Date    = Get-Date -Format "yyyyMMdd_HHmm"
$LogDir  = "C:\IT_LOGS\$Categorie"
$LogFile = "$LogDir\${Categorie}_${Serveur}_${Billet}_${Date}.log"

if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

Start-Transcript -Path $LogFile -Append
Write-Host ("=" * 60) -ForegroundColor DarkCyan
Write-Host "  Script  : ${Categorie}_${Action}_${Cible}_v1.ps1" -ForegroundColor Cyan
Write-Host "  Billet  : $Billet" -ForegroundColor Cyan
Write-Host "  Serveur : $Serveur" -ForegroundColor Cyan
Write-Host "  Debut   : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor DarkCyan

# =============================================================
# SECTION 1 — LECTURE SEULE / VALIDATION PRE-ACTION
# Toujours commencer par la collecte avant toute remédiation.
# =============================================================

Write-Host "`n[SECTION 1] Validation pre-action..." -ForegroundColor Yellow

try {
    # Exemple : vérifier espace disque
    $Disques = Get-PSDrive -PSProvider FileSystem |
        Select-Object Name,
            @{N="UsedGB"; E={[math]::Round($_.Used/1GB,2)}},
            @{N="FreeGB"; E={[math]::Round($_.Free/1GB,2)}},
            @{N="FreePct"; E={[math]::Round(($_.Free/($_.Used+$_.Free))*100,1)}}
    $Disques | Format-Table -AutoSize
    Write-Host "[OK] Espace disque verifie." -ForegroundColor Green
}
catch {
    Write-Host "[ERREUR] Verification espace disque : $_" -ForegroundColor Red
}

try {
    # Exemple : vérifier pending reboot
    $PendingReboot = $false
    $CBSKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
    $WUKey  = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
    if ((Test-Path $CBSKey) -or (Test-Path $WUKey)) { $PendingReboot = $true }
    if ($PendingReboot) {
        Write-Host "[ATTENTION] Pending reboot detecte sur $Serveur." -ForegroundColor Yellow
    } else {
        Write-Host "[OK] Pas de pending reboot." -ForegroundColor Green
    }
}
catch {
    Write-Host "[ERREUR] Verification pending reboot : $_" -ForegroundColor Red
}

# =============================================================
# SECTION 2 — ACTION PRINCIPALE
# ⚠️ Impact : [décrire l'impact ici avant chaque bloc à risque]
# Décommenter et adapter selon le besoin.
# =============================================================

Write-Host "`n[SECTION 2] Action principale..." -ForegroundColor Yellow

# EXEMPLE — Lister les updates disponibles (lecture seule, sans installation)
try {
    if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
        $Updates = Get-WindowsUpdate -ErrorAction Stop
        Write-Host "[INFO] Updates disponibles : $($Updates.Count)" -ForegroundColor Cyan
        $Updates | Select-Object Title, Size, MsrcSeverity | Format-Table -AutoSize
    } else {
        Write-Host "[INFO] Module PSWindowsUpdate non installe. Verification manuelle requise." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "[ERREUR] Recuperation des updates : $_" -ForegroundColor Red
}

# ⚠️ Impact : Installation patches — peut déclencher un reboot si AutoReboot activé.
# ⚠️ Valider explicitement avec le technicien senior avant de décommenter.
# try {
#     Install-WindowsUpdate -AcceptAll -IgnoreReboot -ErrorAction Stop
#     Write-Host "[OK] Patches installes (reboot non automatique)." -ForegroundColor Green
# }
# catch {
#     Write-Host "[ERREUR] Installation patches : $_" -ForegroundColor Red
# }

# =============================================================
# SECTION 3 — VALIDATION POST-ACTION
# =============================================================

Write-Host "`n[SECTION 3] Validation post-action..." -ForegroundColor Yellow

try {
    # Exemple : vérifier services automatiques arrêtés
    $ServicesStopped = Get-Service | Where-Object {
        $_.Status -eq 'Stopped' -and $_.StartType -eq 'Automatic'
    }
    if ($ServicesStopped) {
        Write-Host "[ATTENTION] Services auto arretes :" -ForegroundColor Yellow
        $ServicesStopped | Select-Object Name, DisplayName, Status | Format-Table -AutoSize
    } else {
        Write-Host "[OK] Tous les services automatiques sont actifs." -ForegroundColor Green
    }
}
catch {
    Write-Host "[ERREUR] Verification services : $_" -ForegroundColor Red
}

# =============================================================
# FIN — NE PAS MODIFIER
# =============================================================

Write-Host ("`n" + ("=" * 60)) -ForegroundColor DarkCyan
Write-Host "  Fin     : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "  Log     : $LogFile" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor DarkCyan
Stop-Transcript
