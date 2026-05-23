# TEMPLATE_SCRIPT_Header-PS-Standard_V1
**Agent :** IT-ScriptMaster, IT-MaintenanceMaster | IT-SysAdmin
**Usage :** Header obligatoire pour tout script PowerShell produit par les agents IT
**Mis à jour :** 2026-03-20

---

## HEADER STANDARD OBLIGATOIRE

```powershell
#Requires -Version 5.1
# ============================================================
# Script   : [CATEGORIE]_[ACTION]_[CIBLE]_v[VERSION].ps1
# Billet   : [#XXXXXX ou N/A]
# Client   : [NOM CLIENT]
# Auteur   : [TECHNICIEN]
# Date     : [YYYY-MM-DD]
# Version  : [1.0]
# Desc     : [Description courte — 1 ligne]
# ============================================================
# ⛔ NE JAMAIS inclure : mots de passe, tokens, IPs dans ce script
# ============================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$Category = "[CATEGORIE]"   # MAINT | DIAG | AUDIT | SECU | BACKUP | REPORT | DEPLOY | CONFIG
$Ticket   = "[#XXXXXX]"
$Server   = $env:COMPUTERNAME
$DateTag  = Get-Date -Format "yyyyMMdd_HHmm"
$LogDir   = "C:\IT_LOGS\$Category"
$LogFile  = "$LogDir\${Category}_${Server}_${Ticket}_${DateTag}.log"

if (-not (Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
Start-Transcript -Path $LogFile -Append
Write-Host "=== Début : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" -ForegroundColor Cyan
Write-Host "Ticket=$Ticket | Server=$Server" -ForegroundColor Cyan

# ─────────────────────────────────────────────────────────────
# Fonction : Masquage IP dans les outputs
# ─────────────────────────────────────────────────────────────
function Mask-IP {
    param([Parameter(Mandatory=$true)][string]$Text)
    $t = [regex]::Replace($Text, '\b((25[0-5]|2[0-4]\d|1?\d?\d)\.){3}(25[0-5]|2[0-4]\d|1?\d?\d)\b', '[IP]')
    $t = [regex]::Replace($t,   '\b([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}\b', '[IPV6]')
    return $t
}

try {
    # ─────────────────────────────────────────────────────────
    # CORPS DU SCRIPT — Remplacer ici
    # ─────────────────────────────────────────────────────────

    Write-Host "=== [SECTION 1] ===" -ForegroundColor Yellow
    # [Code ici]

    Write-Host "[OK] Script terminé avec succès." -ForegroundColor Green
}
catch {
    Write-Host "[ERREUR] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[STACK] $($_.ScriptStackTrace)" -ForegroundColor DarkRed
}
finally {
    Write-Host "=== Fin : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') ===" -ForegroundColor Cyan
    Write-Host "Log : $LogFile"
    Stop-Transcript
}
```

---

## CONVENTIONS DE NOMMAGE

```
Nom fichier   : [CATEGORIE]_[ACTION]_[CIBLE]_v[VERSION].ps1
Log           : C:\IT_LOGS\[CATEGORIE]\[CATEGORIE]_[SERVEUR]_[BILLET]_[YYYYMMDD_HHMM].log

Catégories valides :
MAINT   → Maintenance et patching
DIAG    → Diagnostic et collecte d'information
AUDIT   → Audits de conformité
SECU    → Sécurité et hardening
BACKUP  → Sauvegarde et DR
REPORT  → Rapports et états
DEPLOY  → Déploiement et configuration
CONFIG  → Configuration système

Exemples :
MAINT_Patching_AllServers_v1.ps1
DIAG_Precheck_SRV-DC01_v1.ps1
AUDIT_HealthCheck_AllServers_v2.ps1
SECU_Hardening_Workstations_v1.ps1
```

---

## RÈGLES OBLIGATOIRES

```
✅ #Requires -Version 5.1 en ligne 1
✅ Encoding UTF-8 après le header
✅ Start-Transcript vers C:\IT_LOGS\[CATEGORIE]\
✅ Try/Catch sur tout le corps du script
✅ Stop-Transcript dans le bloc Finally
✅ Masquer les IPs avec Mask-IP() dans les outputs

⛔ JAMAIS de mots de passe en dur
⛔ JAMAIS d'IPs en clair dans les logs ou outputs
⛔ JAMAIS de reboot automatique sur une liste
   → Toujours 1 serveur à la fois avec confirmation
⛔ JAMAIS supprimer des fichiers sans -WhatIf d'abord
```
