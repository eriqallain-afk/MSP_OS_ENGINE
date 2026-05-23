# BUNDLE_KP_UrgenceMaster_V1
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Type :** KnowledgePack GPT
**Agent cible :** IT-UrgenceMaster
**Usage :** Uploader en Knowledge dans le GPT IT-UrgenceMaster
**Contenu :** Protocoles urgences + notices Teams + GO/NO-GO + escalades + templates CW
**Mis à jour :** 2026-03-24

---

## COMPORTEMENT FONDAMENTAL

Tu guides — tu ne résous pas seul.
Chaque urgence suit ce flux : **alerte → validation → surveillance → GO/NO-GO → correctif ou Flag Up → clôture**

À chaque étape clé : **notice Teams obligatoire** avec numéro de billet.

---

## FORMAT NOTICES TEAMS — STANDARD NOC

**Titre (police 12) :** `[ICÔNE] [Statut] — Billet : #[XXXXX]`
**Contenu (3 lignes) :**
```
[Situation] chez [Client]
Tâche principale : [Action en cours]
Impact : [Description de l'impact]
```

| Moment | Icône | Exemple titre |
|---|---|---|
| Alerte / panne active | ⚠️ | `⚠️ Panne en cours — Billet : #12345` |
| Diagnostic en cours | 🔍 | `🔍 Diagnostic en cours — Billet : #12345` |
| Retour / validation | 🔄 | `🔄 Retour en cours — Billet : #12345` |
| Flag Up / action requise | 🚩 | `🚩 Avertissement — Billet : #12345` |
| Intervention terminée | ✅ | `✅ Intervention terminée — Billet : #12345` |

---

## PROTOCOLE PANNE HQ — FLUX COMPLET

### Phase 1 — Réception alerte
```
1. Vérifier portail HQ : hydroquebec.com/pannes
2. Billet CW en charge (owner assigné)
3. Notice Teams immédiate :
   Titre : ⚠️ Panne en cours — Billet : #[XXXXX]
   Contenu :
     Panne électrique en cours chez [Client]
     Tâche principale : Validation HQ et surveillance retour courant
     Impact : Serveur(s) indisponible(s) — surveillance active
4. Identifier assets critiques offline dans RMM
5. Mettre actifs en mode maintenance RMM (éviter alert fatigue)
```

### Phase 2 — Surveillance panne
```
□ HQ confirmée → noter ETA rétablissement
□ Vérifier UPS si applicable
□ Mettre actifs critiques en mode maintenance RMM
□ Mise à jour Teams si panne > 30 min :
  Titre : ⚠️ Panne en cours — Billet : #[XXXXX]
  Contenu :
    Panne HQ active chez [Client] — ETA : [HH:MM]
    Tâche principale : Surveillance — retour prévu [HH:MM]
    Impact : Serveur(s) indisponible(s) depuis [HH:MM]
```

### Phase 3 — Retour courant détecté
```
Notice Teams immédiate :
  Titre : 🔄 Retour en cours — Billet : #[XXXXX]
  Contenu :
    Retour courant détecté chez [Client]
    Tâche principale : Validation post-panne des systèmes
    Impact : Systèmes en cours de vérification

Délai avant post-check : attendre 5-10 min (stabilisation alimentation)
```

---

## CHECKLIST GO/NO-GO — PAR SERVEUR

```
Serveur : [NOM] — [Rôle]
━━━━━━━━━━━━━━━━━━━━━━━━━━━
□ Accessible (ping / RMM / RDP)
□ Uptime > 10 min (stabilisé)
□ Pending reboot : [O/N]
□ Services critiques Running :
  □ AD / Netlogon / KDC (si DC)
  □ SQL Server (si SQL)
  □ IIS (si web)
  □ Services métier principaux
□ Disque C: > 10% libre
□ EventLogs critiques post-retour :
  □ Erreur 41 (arrêt inattendu)
  □ Erreur 6008 (arrêt brutal)
  □ Erreurs 6005/6006 (démarrage/arrêt)
□ Réseau : GW ping OK + DNS externe OK
□ DC spécifique :
  □ repadmin /replsummary → OK
  □ dcdiag /test:replications → OK
  □ SYSVOL / NETLOGON partagés → OK

Décision : ✅ GO / ❌ NO-GO
Raison si NO-GO : [description]
```

---

## CRITÈRES NO-GO — ACTIONS IMMÉDIATES

| Problème NO-GO | Action |
|---|---|
| Service critique arrêté | Démarrer manuellement → confirmer → re-tester |
| Pending reboot bloquant | Planifier reboot contrôlé (1 DC à la fois si DC) |
| Réplication AD en échec | @IT-Commandare-Infra |
| Disque plein / corruption | @IT-Commandare-Infra |
| Réseau instable | @IT-NetworkMaster |
| Backup job KO post-retour | @IT-BackupDRMaster |
| Comportement suspect | @IT-SecurityMaster — IMMÉDIAT |
| Hors scope / trop risqué | /flagup → passation structurée |

---

## TEMPLATES CW

### Note Interne — Post-urgence
```
Prise de connaissance de la demande et consultation de la documentation du client.

Billet #[XXXXX] — [Client] — [Type urgence]
Début : [HH:MM] | Fin : [HH:MM] | Durée : [XhYm]

CONTEXTE :
[Description de l'urgence — symptômes initiaux — cause confirmée]

CHRONOLOGIE :
[HH:MM] — Alerte reçue — prise en charge
[HH:MM] — Validation [HQ / cause] → [résultat]
[HH:MM] — Retour [courant / services] détecté
[HH:MM] — Post-check [Serveur] → [GO / NO-GO + raison]
[HH:MM] — [Action corrective si applicable] → [résultat]

VALIDATION FINALE :
□ Services critiques : [liste] → OK
□ Réseau (GW/DNS) : OK
□ Réplication AD (si DC) : OK
□ Sauvegardes : [validées / à planifier]

STATUT : ✅ Résolu / ⚠️ À surveiller / 🚩 Flag Up → [Équipe]
```

### Discussion CW (client-safe — facturable)
```
Préparation et découverte.
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

INTERVENTION: [Type — ex: Post-panne Hydro-Québec]
DATE: [YYYY-MM-DD]
TECHNICIEN: [Initiales]

TRAVAUX EFFECTUÉS:
• Prise en charge de l'alerte et validation de la situation [HQ / réseau / serveur]
• Surveillance du rétablissement et coordination des équipes concernées
• Validation complète des systèmes critiques post-urgence
• [Action spécifique — résultat client-visible]
• Validation des services essentiels et des sauvegardes

RÉSULTAT:
• Systèmes opérationnels — services essentiels confirmés fonctionnels
• [Confirmation ou suivi planifié si applicable]

RECOMMANDATION: (si applicable)
• [Action recommandée — délai — équipe responsable]
```

---

## ESCALADES RAPIDES

| Situation | Agent | Délai |
|---|---|---|
| Réseau / site / WAN down | @IT-Commandare-NOC | Immédiat |
| Serveur / VM / hyperviseur | @IT-Commandare-Infra | Immédiat |
| Sécurité / breach / ransomware | @IT-SecurityMaster | Immédiat |
| Backup / perte données | @IT-BackupDRMaster | Immédiat |
| Cloud M365 / Azure | @IT-CloudMaster | Immédiat |
| Téléphonie | @IT-VoIPMaster | Immédiat |
| Réseau / firewall | @IT-NetworkMaster | Immédiat |
| Monitoring / alertes RMM | @IT-MonitoringMaster | < 30 min |
| RCA / N3 technique | @IT-Commandare-TECH | Selon besoin |
| Clôture formelle / comms client | @IT-Commandare-OPR | Post-résolution |

---

## RÈGLES ABSOLUES

1. **P1 → escalade immédiate** — aucune tentative de résolution solo
2. **Sécurité / ransomware → @IT-SecurityMaster** — NE PAS toucher au système
3. **JAMAIS** d'IP, credentials dans les livrables clients
4. **1 DC à la fois** pour les reboots — post-check AD obligatoire
5. **Notice Teams dès que le type est connu** — numéro de billet obligatoire
6. **Lecture seule avant remédiation** — prouver avant d'agir

---

## DIAGNOSTICS RAPIDES PAR TYPE D'URGENCE

### Réseau down — collecte initiale (lecture seule)

```powershell
param([string]$Billet = "T[XXXXX]", [string]$Serveur = $env:COMPUTERNAME)
ping 8.8.8.8 -n 4
Get-NetAdapter | Select-Object Name,Status,LinkSpeed
Get-NetIPConfiguration | Select-Object InterfaceAlias,IPv4Address,IPv4DefaultGateway
Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object NextHop,InterfaceAlias
```

### Serveur critique — health check express

```powershell
param([string]$Billet = "T[XXXXX]", [string]$Serveur = $env:COMPUTERNAME)
#Requires -Version 5.1
function Log {
    param([AllowEmptyString()][string]$Text = "", [string]$Color = "White")
    Write-Host $(if ([string]::IsNullOrEmpty($Text)) { " " } else { $Text }) -ForegroundColor $Color
}
$os  = Get-CimInstance Win32_OperatingSystem
$up  = (Get-Date) - $os.LastBootUpTime
Log ("Uptime : {0:dd}j {0:hh}h{0:mm}m — Boot : {1}" -f $up, $os.LastBootUpTime.ToString("yyyy-MM-dd HH:mm")) "Yellow"
$pr  = (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired')
Log "Pending Reboot : $pr" $(if ($pr) { "Red" } else { "Green" })
$d   = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
$pct = [math]::Round($d.FreeSpace/$d.Size*100,0)
Log ("C: Libre : {0}GB ({1}%)" -f [math]::Round($d.FreeSpace/1GB,1), $pct) $(if ($pct -lt 10) {"Red"} else {"Green"})
"ADWS","DNS","Netlogon","NTDS","W32Time","WinRM","MSSQLSERVER" | ForEach-Object {
    $s = Get-Service $_ -EA SilentlyContinue
    if ($s) { Log ("  {0,-20} {1}" -f $_, $s.Status) $(if ($s.Status -eq "Running") {"Green"} else {"Red"}) }
}
Get-WinEvent -FilterHashtable @{LogName="System"; Id=@(41,6008); StartTime=(Get-Date).AddHours(-3)} -EA SilentlyContinue |
    Select-Object TimeCreated,Id,Message | Format-Table -AutoSize
```

### DC — validation santé (lecture seule)

```powershell
repadmin /replsummary
dcdiag /test:replications /test:netlogons /test:fsmocheck /quiet
net share | findstr "SYSVOL NETLOGON"
w32tm /query /status
```

---

## RÈGLE ANTI-ERREUR RMM

`Write-Host ""` → toujours `Write-Host " "` (espace)
Fonctions helper → `[AllowEmptyString()]` obligatoire sur `[string]$Text`
`param()` → valeur par défaut non vide obligatoire

---

## RÉFÉRENCES UTILES

| Ressource | URL |
|---|---|
| Portail Hydro-Québec | hydroquebec.com/pannes |
| Statut M365 | admin.microsoft.com → Service Health |
| Statut Azure | status.azure.com |
