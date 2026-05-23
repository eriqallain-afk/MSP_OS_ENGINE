# RB-001 — Intervention N3 : Du Triage à la Clôture CW
**Agent :** IT-AssistanTI_N3 | **Usage :** Guide de référence pour chaque intervention

---

## PHASE 1 — TRIAGE (`/start`)

**Catégories et priorités :**
```
NOC      : alertes RMM, CPU/RAM/Disk critique, services down, réseau
SOC      : EDR alerte, phishing, comportement suspect, accès anormal
SUPPORT  : problème utilisateur, accès, application
MAINTENANCE : patching, mise à jour, redémarrage planifié
SÉCURITÉ : incident sécurité confirmé ou suspecté
CLOUD    : M365, Exchange, Teams, SharePoint, Entra ID
RÉSEAU   : VPN, firewall, connectivité site

P1 : service critique hors ligne / données à risque → réponse < 5 min
P2 : service dégradé, impact large              → réponse < 30 min
P3 : impact limité, workaround possible          → réponse < 2h
P4 : demande de service, aucun impact            → réponse < 4h
```

**Commande de départ :**
```
/start — Billet #T[XXXXX] — Client : [Nom] — [Symptôme en 1 ligne]
```

---

## PHASE 2 — PRECHECK (lecture seule d'abord)

```powershell
# Santé serveur rapide
$os = Get-CimInstance Win32_OperatingSystem
[pscustomobject]@{
    Hostname   = $env:COMPUTERNAME
    Uptime_j   = [math]::Round(((Get-Date)-$os.LastBootUpTime).TotalDays,1)
    RAM_libre  = [math]::Round($os.FreePhysicalMemory/1MB,1)
    Pending_RB = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired')
} | Format-List

Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -gt 0} |
    Select-Object Name, @{N='Free%';E={[math]::Round($_.Free/($_.Used+$_.Free)*100,0)}} | Format-Table

Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -eq 'Stopped'} |
    Select-Object Name, DisplayName | Format-Table

Get-WinEvent -FilterHashtable @{LogName='System';Level=1,2;StartTime=(Get-Date).AddHours(-2)} `
    -EA SilentlyContinue | Select-Object -First 10 TimeCreated,Id,Message | Format-List
```

---

## PHASE 3 — RUNBOOKS DISPONIBLES (`/runbook`)

| Commande | Runbook cible |
|---|---|
| `/runbook veeam` | Jobs en échec, espace repository, restauration |
| `/runbook m365` | Exchange, Entra ID, Teams, SharePoint, Intune |
| `/runbook panne` | Post-shutdown électrique — ordre de reprise |
| `/runbook reseau` | WatchGuard / Fortinet / Meraki / VPN |
| `/runbook securite` | Incident EDR, phishing, compromission |
| `/runbook ad` | DC, réplication, FSMO, utilisateurs AD |
| `/runbook rds` | Session Broker, RemoteApp, profils |
| `/runbook print` | Spooler, file, pilotes, Print Server |
| `/runbook linux` | Diagnostic, services, réseau Linux/XCP-ng |

---

## PHASE 4 — SCRIPTS (`/script`)

**Standards obligatoires sur tout script généré :**
```powershell
#Requires -Version 5.1
# ============================================================
# Script  : [NOM]_V1.ps1
# Billet  : T[XXXXX]
# ⚠️ Impact : [conséquence précise]
# ============================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutDir  = "C:\IT_LOGS\[CATEGORIE]"
$LogFile = "$OutDir\[NOM]_$(Get-Date -Format 'yyyyMMdd_HHmm').log"
if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir -Force | Out-Null }
Start-Transcript -Path $LogFile
try {
    # code ici
} catch {
    Write-Host "[ERREUR] $($_.Exception.Message)" -ForegroundColor Red
} finally {
    Stop-Transcript
}
```

---

## PHASE 5 — CLÔTURE (`/close`)

**4 livrables générés automatiquement :**

```
CW_NOTE_INTERNE
  → Commence TOUJOURS par : "Prise de connaissance de la demande et
    consultation de la documentation du client."
  → Timeline actions + commandes + preuves + validations

CW_DISCUSSION (format STAR, client-safe)
  → Aucune IP, aucun nom de serveur sensible, aucune commande brute

EMAIL_CLIENT (si requis P1/P2)
  → Résultat fonctionnel + prochaine étape

AVIS_TEAMS (si maintenance planifiée)
  → Début / fin / incident selon contexte
```

**Post-clôture automatique :**
- `/kb` proposé si P1/P2 ou nouveau type de problème
- `/db` proposé si P1/P2 ou intervention > 30 min

---

## ESCALADES IMMÉDIATES

| Situation | Agent | Action |
|---|---|---|
| Ransomware / breach / EDR critique | @IT-SecurityMaster | Isoler + ne pas éteindre |
| DC/AD inaccessible | @IT-Commandare-Infra | Vérifier DC secondaire en premier |
| Perte données / DR requis | @IT-BackupDRMaster | Ne pas toucher les données |
| Site réseau down | @IT-NetworkMaster | Vérifier gateway + firewall |
| P1 non résolu > 30 min | @IT-Commandare-NOC | Escalade immédiate |
