#Requires -Version 5.1
# ============================================================
# Script  : SCRIPT_SECU_M365-CompteCompromis_V1.ps1
# Desc    : Investigation et containment compte M365 compromis
#           Révoque sessions, vérifie règles Outlook suspectes,
#           transferts automatiques, activité récente
# Usage   : .\SCRIPT_SECU_M365-CompteCompromis_V1.ps1
#           Requiert : ExchangeOnlineManagement + Microsoft.Graph
# ⚠️  LECTURE D'ABORD — actions de containment commentées
# ============================================================
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$UserUPN,       # ex: utilisateur@domaine.com
    [string]$Ticket = "T00000",
    [string]$OutDir = "C:\IT_LOGS\SECU"
)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$DateTag = Get-Date -Format "yyyyMMdd_HHmm"
$LogFile = "$OutDir\SECU_M365Compro_${Ticket}_${DateTag}.log"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
Start-Transcript -Path $LogFile

function Write-Section($t) { Write-Host "`n=== $t ===" -ForegroundColor Cyan }

try {
    Write-Host "INVESTIGATION COMPTE COMPROMIS — $UserUPN — $Ticket" -ForegroundColor Red
    Write-Host "ATTENTION : Valider chaque action avant d'appliquer le containment" -ForegroundColor Yellow

    # ── Connexion ─────────────────────────────────────────
    Write-Section "CONNEXION"
    if (-not (Get-Module ExchangeOnlineManagement -EA SilentlyContinue)) {
        Install-Module ExchangeOnlineManagement -Force -Scope CurrentUser
    }
    Connect-ExchangeOnline -UserPrincipalName $UserUPN -ShowBanner:$false
    Write-Host "Exchange Online : connecté" -ForegroundColor Green

    # ── Règles Outlook suspectes ───────────────────────────
    Write-Section "RÈGLES OUTLOOK"
    $rules = Get-InboxRule -Mailbox $UserUPN |
        Select-Object Name, Enabled, ForwardTo, ForwardAsAttachmentTo,
        RedirectTo, DeleteMessage, MoveToFolder, Description
    if ($rules) {
        $rules | Format-List
        Write-Host "⚠️  Vérifier les règles avec ForwardTo, RedirectTo ou DeleteMessage" -ForegroundColor Yellow
    } else {
        Write-Host "Aucune règle Outlook." -ForegroundColor Green
    }

    # ── Transferts automatiques ────────────────────────────
    Write-Section "TRANSFERT AUTOMATIQUE (ForwardingSmtpAddress)"
    Get-Mailbox $UserUPN |
        Select-Object DisplayName, ForwardingSmtpAddress, ForwardingAddress, DeliverToMailboxAndForward |
        Format-List

    # ── Activité connexion récente ─────────────────────────
    Write-Section "ACTIVITÉ CONNEXION (7 derniers jours)"
    Search-UnifiedAuditLog `
        -StartDate (Get-Date).AddDays(-7) `
        -EndDate (Get-Date) `
        -UserIds $UserUPN `
        -Operations "MailboxLogin","UserLoggedIn" `
        -ResultSize 50 |
        Select-Object CreationDate, Operations,
            @{N='IP';E={([System.Web.Script.Serialization.JavaScriptSerializer]::new().DeserializeObject($_.AuditData))['ClientIP']}} |
        Sort-Object CreationDate -Descending | Format-Table -AutoSize

    # ── Statistiques boîte ────────────────────────────────
    Write-Section "STATISTIQUES BOÎTE"
    Get-MailboxStatistics $UserUPN |
        Select-Object DisplayName, LastLogonTime, LastUserActionTime | Format-List

    Write-Host "`n═══════════════════════════════════" -ForegroundColor Yellow
    Write-Host "ACTIONS DE CONTAINMENT (à valider)" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════" -ForegroundColor Yellow
    Write-Host @"
Si compromission confirmée — décommenter et exécuter :

# 1. Désactiver le compte Entra ID
# Update-MgUser -UserId '$UserUPN' -AccountEnabled `$false

# 2. Révoquer toutes les sessions
# Revoke-MgUserSignInSession -UserId '$UserUPN'

# 3. Supprimer les règles Outlook suspectes
# Remove-InboxRule -Mailbox '$UserUPN' -Identity "NOM_RÈGLE_SUSPECTE"

# 4. Supprimer le transfert automatique
# Set-Mailbox '$UserUPN' -ForwardingSmtpAddress `$null -DeliverToMailboxAndForward `$false

# 5. Réinitialiser le mot de passe (via Passportal)
"@ -ForegroundColor Cyan

    Write-Host "`n[OK] Investigation terminée. Log : $LogFile" -ForegroundColor Green
}
catch {
    Write-Host "[ERREUR] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[STACK] $($_.ScriptStackTrace)" -ForegroundColor DarkRed
}
finally {
    try { Disconnect-ExchangeOnline -Confirm:$false -EA SilentlyContinue } catch {}
    Stop-Transcript
}
