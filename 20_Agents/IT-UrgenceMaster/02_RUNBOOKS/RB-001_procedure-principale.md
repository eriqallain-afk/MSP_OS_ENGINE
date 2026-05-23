# RB-001 — Procédures Urgences P1/P2 — IT-UrgenceMaster
**Agent :** @IT-UrgenceMaster | **Version :** 1.1 | **Date :** 2026-03-24

---

## FLUX GÉNÉRAL — TOUTE URGENCE

```
Alerte reçue
    ↓
/panne ou /urgence [description]
    ↓
Classification + Notice Teams immédiate (#billet obligatoire)
    ↓
Surveillance / diagnostic
    ↓
Retour / services → /retour → GO/NO-GO
    ↓
GO → /close (clôture CW complète)
NO-GO → Correctif ou /flagup (passation structurée)
```

**Principe fondamental :** Tu guides — tu ne résous pas seul.
P1 → escalade immédiate. Notice Teams à chaque étape clé.

---

## PROCÉDURE 1 — PANNE ÉLECTRIQUE (HQ OU LOCALE)

### Phase 1 — Réception alerte (0-5 min)

```
1. Billet CW créé et pris en charge (owner assigné)

2. Notice Teams IMMÉDIATE :
   Titre : ⚠️ Panne en cours — Billet : #[XXXXX]
   Contenu :
     Panne électrique en cours chez [Client]
     Tâche principale : Validation HQ et surveillance retour courant
     Impact : Serveur(s) indisponible(s) — surveillance active

3. Vérifier portail Hydro-Québec : hydroquebec.com/pannes
   → Panne confirmée ? ETA rétablissement ?
   → Si non confirmée → investiguer cause locale (UPS, génératrice, réseau)

4. Identifier assets critiques offline dans RMM :
   □ DC / AD   □ Hyperviseur   □ Firewall/Routeur
   □ Serveurs  □ NAS/Backup    □ Téléphonie

5. Mettre assets en mode maintenance RMM (éviter alert fatigue)
```

### Phase 2 — Surveillance panne (toutes les 30 min)

```
□ HQ : suivre ETA rétablissement — mise à jour si changement
□ UPS : vérifier état des batteries si applicable
□ Vérifier si clients internes affectés (VPN, téléphonie)

Si panne > 30 min → mise à jour Teams :
  Titre : ⚠️ Panne en cours — Billet : #[XXXXX]
  Contenu :
    Panne HQ active chez [Client] — ETA : [HH:MM]
    Tâche principale : Surveillance — retour prévu [HH:MM]
    Impact : Serveur(s) indisponible(s) depuis [HH:MM]
```

### Phase 3 — Retour courant détecté

```
1. Notice Teams immédiate :
   Titre : 🔄 Retour en cours — Billet : #[XXXXX]
   Contenu :
     Retour courant détecté chez [Client]
     Tâche principale : Validation post-panne des systèmes
     Impact : Systèmes en cours de vérification

2. Attendre 5-10 min (stabilisation alimentation) avant le post-check

3. → /retour (validation GO/NO-GO)
```

---

## PROCÉDURE 2 — URGENCE P1/P2 (RÉSEAU / SERVEUR / MULTI-SERVICES)

### Classification immédiate

| Symptôme | Priorité | Escalade |
|---|---|---|
| Réseau / site entier inaccessible | P1 | @IT-Commandare-NOC — immédiat |
| Serveur critique / DC inaccessible | P1 | @IT-Commandare-Infra — immédiat |
| Ransomware / breach / sécurité | P1 | @IT-SecurityMaster — immédiat |
| Backup / perte données active | P1 | @IT-BackupDRMaster — immédiat |
| 5+ users impactés / service dégradé | P2 | @IT-Commandare-NOC — < 10 min |
| Téléphonie down | P2 | @IT-VoIPMaster — immédiat |
| M365 / Azure dégradé | P2 | @IT-CloudMaster — immédiat |

### Flux P1 — Escalade obligatoire

```
1. Classer P1 → notice Teams immédiate :
   Titre : ⚠️ Urgence P1 en cours — Billet : #[XXXXX]
   Contenu :
     [Symptôme fonctionnel court] chez [Client]
     Tâche principale : Escalade et coordination [équipe]
     Impact : [Services / utilisateurs affectés]

2. /escalade [domaine] → bloc CW de transfert

3. Informer le client :
   "Notre équipe est mobilisée — mise à jour dans 15 min"

4. NE PAS tenter de résoudre seul
5. Suivre et documenter — mettre à jour Teams toutes les 30 min
```

### Flux P2 — Résolution guidée

```
1. Notice Teams immédiate (même format)

2. Collecte lecture seule d'abord :
   □ Périmètre exact — nb users affectés ?
   □ Services impactés — lesquels fonctionnent encore ?
   □ Depuis quand — changements récents ?

3. Diagnostic par domaine (voir ci-dessous)

4. GO/NO-GO avant toute remédiation risquée

5. Si > 30 min sans progrès → P1 → /escalade

6. /teams à chaque étape clé

7. /close si résolu | /flagup si partielle
```

---

## PROCÉDURE 3 — VALIDATION GO/NO-GO (`/retour`)

### PRECHECK PowerShell — collecte lecture seule

```powershell
param(
    [string]$Serveur = $env:COMPUTERNAME,
    [string]$Billet  = "T[XXXXX]"
)
#Requires -Version 5.1
# ============================================================
# Script  : URGENT_PostRetour_Validation_v1.ps1
# Usage   : Lecture seule — valider retour post-urgence
# ============================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8

function Log {
    param([AllowEmptyString()][string]$Text = "", [string]$Color = "White")
    Write-Host $(if ([string]::IsNullOrEmpty($Text)) { " " } else { $Text }) -ForegroundColor $Color
}

Log "=== POST-URGENCE VALIDATION — $Serveur — Billet $Billet ===" "Cyan"

# Uptime
$os = Get-CimInstance Win32_OperatingSystem
$uptime = (Get-Date) - $os.LastBootUpTime
Log ("Uptime : {0:dd}j {0:hh}h{0:mm}m — LastBoot : {1}" -f $uptime, $os.LastBootUpTime.ToString("yyyy-MM-dd HH:mm")) "Yellow"

# Pending Reboot
$pr = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') -or
      (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending')
Log "Pending Reboot : $pr" $(if ($pr) { "Red" } else { "Green" })

# Disque C
$disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$pct = [math]::Round(($disk.FreeSpace / $disk.Size) * 100, 0)
Log ("Disque C: {0} GB libres ({1}%)" -f [math]::Round($disk.FreeSpace/1GB,1), $pct) $(if ($pct -lt 10) { "Red" } elseif ($pct -lt 15) { "Yellow" } else { "Green" })

# Services critiques
Log " "
Log "=== SERVICES CRITIQUES ===" "Cyan"
$svcCheck = @("wuauserv","bits","ADWS","DNS","Netlogon","NTDS","DFSR","W32Time","WinRM")
foreach ($svc in $svcCheck) {
    $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($s) {
        $color = if ($s.Status -eq "Running") { "Green" } else { "Red" }
        Log (" {0,-20} {1}" -f $svc, $s.Status) $color
    }
}

# EventLogs — indicateurs panne
Log " "
Log "=== ÉVÉNEMENTS POST-RETOUR (IDs panne) ===" "Cyan"
$panneIDs = @(41, 6008, 6005, 6006, 1074)
$evts = Get-WinEvent -FilterHashtable @{LogName="System"; Id=$panneIDs; StartTime=(Get-Date).AddHours(-3)} -ErrorAction SilentlyContinue
if ($evts) {
    $evts | Select-Object TimeCreated,Id,Message | Format-Table -AutoSize | Out-String | ForEach-Object { Log $_ "Yellow" }
} else {
    Log " Aucun événement de panne détecté (3 dernières heures)" "Green"
}

# Réseau
Log " "
Log "=== RÉSEAU ===" "Cyan"
$gw = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue | Select-Object -First 1).NextHop
if ($gw) {
    $pingGW = Test-Connection $gw -Count 2 -Quiet
    Log ("GW ($gw) : {0}" -f $(if ($pingGW) { "OK" } else { "KO" })) $(if ($pingGW) { "Green" } else { "Red" })
}
$pingDNS = Test-Connection "8.8.8.8" -Count 2 -Quiet
Log ("DNS externe (8.8.8.8) : {0}" -f $(if ($pingDNS) { "OK" } else { "KO" })) $(if ($pingDNS) { "Green" } else { "Red" })

Log " "
Log "=== FIN VALIDATION ===" "Cyan"
```

### Critères GO / NO-GO

**GO (tous requis) :**
- ✅ Serveur accessible (ping / RMM / RDP)
- ✅ Uptime > 10 min (alimentation stabilisée)
- ✅ Pending reboot : acceptable si documenté et planifié
- ✅ Services critiques Running (AD/DNS/SQL/Netlogon selon rôle)
- ✅ Disque C: > 10% libre
- ✅ Pas d'erreurs EventLog critiques inexpliquées (IDs 41/6008)
- ✅ Réseau : GW + DNS externe OK
- ✅ DC : réplication OK + SYSVOL/NETLOGON OK

**NO-GO (un seul suffit) :**
- ❌ Service critique arrêté (AD/SQL/DNS/Netlogon)
- ❌ EventLog erreurs répétées (storage, AD, NIC)
- ❌ Disque plein / corruption
- ❌ Réseau instable
- ❌ Réplication AD en échec / SYSVOL absent

### Actions NO-GO immédiates

| Problème | Action | Si hors scope |
|---|---|---|
| Service critique arrêté | Démarrer + confirmer | @IT-Commandare-Infra |
| Pending reboot DC | Planifier reboot contrôlé | 1 DC à la fois — post-check AD obligatoire |
| Réplication AD KO | Diagnostic repadmin | @IT-Commandare-Infra |
| Disque plein | Nettoyage temp / logs | @IT-Commandare-Infra si RAID/stockage |
| Réseau instable | Vérifier GW/firewall | @IT-NetworkMaster |
| Backup KO post-retour | Job test + logs Veeam | @IT-BackupDRMaster |
| Comportement suspect | NE PAS toucher | @IT-SecurityMaster — IMMÉDIAT |
| Hors scope | /flagup | Passation structurée |

---

## PROCÉDURE 4 — FLAG UP (`/flagup`)

Utiliser quand : diagnostic complet mais correctif appartient à une autre équipe,
fenêtre de maintenance requise, accès non disponible, ou risque trop élevé.

```
Ce n'est pas un échec — c'est une passation structurée avec dossier complet.

/flagup génère :
1. CW Note Interne Flag Up (cause, preuves, actions requises, délai)
2. Notice Teams 🚩
```

**Routing Flag Up :**

| Cause | Équipe cible |
|---|---|
| Probe RMM / monitoring | @IT-MonitoringMaster |
| Config réseau / firewall | @IT-NetworkMaster |
| Infra serveur / VM / DC | @IT-Commandare-Infra |
| Backup / Veeam | @IT-BackupDRMaster |
| Sécurité | @IT-SecurityMaster |
| M365 / Azure | @IT-CloudMaster |
| Patching / Windows Update | @IT-NOCDispatcher → RMM |

---

## SLA URGENCES

| Priorité | Notice Teams | Escalade | Résolution cible |
|---|---|---|---|
| P1 | Immédiate | < 5 min | 4h |
| P2 | Immédiate | < 10 min si > 5 users | 8h |
| P2 bloqué > 30 min | Mise à jour Teams | → P1 | — |

---

## ESCALADES PAR DOMAINE

| Symptôme | Agent | Délai |
|---|---|---|
| Réseau / site / WAN down | @IT-Commandare-NOC | Immédiat |
| Serveur / VM / hyperviseur | @IT-Commandare-Infra | Immédiat |
| Sécurité / breach / ransomware | @IT-SecurityMaster | Immédiat |
| Backup / perte données | @IT-BackupDRMaster | Immédiat |
| Cloud M365 / Azure | @IT-CloudMaster | Immédiat |
| Téléphonie | @IT-VoIPMaster | Immédiat |
| Réseau / firewall complexe | @IT-NetworkMaster | Immédiat |
| Monitoring / RMM | @IT-MonitoringMaster | < 30 min |
| RCA / N3 technique | @IT-Commandare-TECH | Selon besoin |
| Clôture formelle / comms | @IT-Commandare-OPR | Post-résolution |
