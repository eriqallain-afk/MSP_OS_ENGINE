# BUNDLE_KP_ScriptMaster_V1
**Agent :** @IT-ScriptMaster | **Mis à jour :** 2026-03-29 | IT-MaintenanceMaster | IT-SysAdmin

## RÈGLE RMM — ANTI-ERREUR CRITIQUE
```powershell
# ✅ SEUL format accepté pour les paramètres string :
param(
    [AllowEmptyString()][string]$Serveur = "",
    [AllowEmptyString()][string]$Client = ""
)
# ❌ JAMAIS : param([string]$Serveur) → le RMM peut passer une chaîne vide = erreur
```

## HEADER OBLIGATOIRE
```powershell
#Requires -Version 5.1
<#
.SYNOPSIS    [Description courte]
.DESCRIPTION [Description détaillée]
.PARAMETER   [Nom] [Description]
.EXAMPLE     [Exemple d'utilisation]
.NOTES
    Auteur  : [Nom]
    Date    : [YYYY-MM-DD]
    Billet  : #TXXXXXXX
    Version : 1.0
#>
```

## STRUCTURE OBLIGATOIRE
```powershell
# 1. param() en LIGNE 1 ABSOLUE (pas de commentaire avant)
param(...)

# 2. Header .SYNOPSIS après param
<#...#>

# 3. Variables et configuration
$ErrorActionPreference = "Stop"
$LogPath = "C:\IT_LOGS\SCRIPT_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
Start-Transcript -Path $LogPath

# 4. Fonctions
function Do-Something { ... }

# 5. Exécution principale
try { ... } catch { ... } finally { Stop-Transcript }
```

## SNIPPETS FRÉQUENTS
```powershell
# Logging universel
function Write-Log { param([string]$Msg,[string]$Level="INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$ts] [$Level] $Msg"
}

# Check admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Write-Log "ERREUR : Exécuter en tant qu'administrateur" "ERROR"; exit 1
}

# Dry-run gate
if ($DryRun) { Write-Log "MODE DRY-RUN — aucune modification" "WARN"; return }
```

## CONVENTIONS NOMMAGE SCRIPTS
```
[CATÉGORIE]__[Description]_v[N].ps1
Exemples :
  DIAG__Pending_Reboot_Check_v1.ps1
  MAINT__Windows_Update_Apply_v1.ps1
  AUDIT__Local_Admins_v1.ps1
  SECU__Disable_Compromised_Account_v1.ps1
```

---
*BUNDLE_KP_ScriptMaster_V1 — Version 1.0*
