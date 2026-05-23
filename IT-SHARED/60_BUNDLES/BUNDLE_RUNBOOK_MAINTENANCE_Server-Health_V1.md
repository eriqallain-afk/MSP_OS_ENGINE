# BUNDLE RUNBOOK MAINTENANCE Server-Health V1
**Type :** Bundle Runbook — Assemblage complet
**Agents :** IT-MaintenanceMaster, IT-Assistant-N3 | IT-SysAdmin
**Description :** Health Check serveur, DC Pre/Post, SQL Pre/Post, Post-Shutdown électrique
**Mis à jour :** 2026-03-20

> Ce bundle regroupe runbooks + templates + checklists liés à ce domaine.
> Uploader en Knowledge dans les GPTs concernés.


---
<!-- SOURCE: RUNBOOK__Server_Health_Check_V1 -->
## RUNBOOK — Server Health Check

[FICHIER NON TROUVÉ : /tmp/NEW_RUNBOOKS/INFRA/RUNBOOK__Server_Health_Check_V1.md]

---
<!-- SOURCE: RUNBOOK__DC_PrePost_Validation -->
## RUNBOOK — DC Pre/Post Validation (AD/DNS)

# RUNBOOK — Domain Controller (AD DS/DNS) — Precheck/Postcheck

## Services critiques
```powershell
Get-Service NTDS,DNS,Netlogon,KDC,W32Time | Format-Table Name,Status,StartType
net share | findstr /I "SYSVOL NETLOGON"
```

## Réplication AD
```powershell
repadmin /replsummary
repadmin /syncall /AdeP
```

## Santé AD (rapide)
```powershell
# dcdiag peut être long; utiliser /q pour erreurs seulement
$OutDir = "$env:TEMP\\DC_CHECK"; New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$TS = Get-Date -Format "yyyyMMdd_HHmmss"
dcdiag /q | Out-File (Join-Path $OutDir "dcdiag_q_$TS.txt")
"dcdiag_q saved to $OutDir"
```

## DNS (erreurs récentes)
```powershell
$Start=(Get-Date).AddHours(-2)
Get-WinEvent -FilterHashtable @{LogName='DNS Server'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
```

## Postcheck après reboot
- Rejouer services + replsummary.
- Vérifier que SYSVOL/NETLOGON partagés.
- Confirmer qu'aucun nouvel event critique (Directory Service/System).



---
<!-- SOURCE: RUNBOOK__SQL_PrePost_Validation -->
## RUNBOOK — SQL Server Pre/Post Validation

# RUNBOOK — SQL Server — Precheck/Postcheck

## Services
```powershell
Get-Service | Where-Object {$_.Name -match '^MSSQL' -or $_.Name -match '^SQL'} | Sort-Object Name | Format-Table Name,Status,StartType
```

## Connectivité (local)
> Option A : `Invoke-Sqlcmd` si module dispo.

```powershell
if (Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue) {
  Invoke-Sqlcmd -Query "SELECT @@SERVERNAME AS ServerName, @@VERSION AS Version" | Format-Table -Auto
} else {
  "Invoke-Sqlcmd indisponible — fallback .NET"
  $cn = New-Object System.Data.SqlClient.SqlConnection
  $cn.ConnectionString = "Server=localhost;Database=master;Integrated Security=True;Connection Timeout=5"
  $cn.Open();
  $cmd = $cn.CreateCommand();
  $cmd.CommandText = "SELECT @@SERVERNAME AS ServerName";
  $r = $cmd.ExecuteScalar();
  $cn.Close();
  "ServerName=$r"
}
```

## Journaux Windows (SQL-related)
```powershell
$Start=(Get-Date).AddHours(-2)
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} |
  Where-Object { $_.LevelDisplayName -in 'Error','Critical' -and ($_.ProviderName -match 'MSSQL|SQLSERVERAGENT|SQL' -or $_.Message -match 'SQL') } |
  Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
```

## Postcheck après reboot
- Services MSSQL/Agent running.
- Test SELECT OK.
- Vérifier EventLog 1h post.

## Note opérationnelle
- Certains environnements (CU/patch) peuvent nécessiter **2 reboots**. Documenter la raison (pending reboot flags).



---
<!-- SOURCE: RUNBOOK__PrintServer_PrePost_Validation -->
## RUNBOOK — Print Server Pre/Post Validation

# RUNBOOK — Print Server — Precheck/Postcheck

## Spooler + queues
```powershell
Get-Service Spooler | Format-Table Name,Status,StartType

# Requiert module PrintManagement sur serveur / RSAT
try {
  Get-Printer | Select-Object Name,Shared,PrinterStatus | Sort-Object Name | Format-Table -Auto
} catch {
  "Get-Printer indisponible (module PrintManagement manquant)."
}
```

## Event logs PrintService
```powershell
$Start=(Get-Date).AddHours(-6)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-PrintService/Operational'; StartTime=$Start} |
  Where-Object {$_.LevelDisplayName -in 'Error','Critical','Warning'} |
  Select-Object -First 50 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
```

## Postcheck après reboot
- Spooler running.
- Queues visibles.
- Si imprimante intermittente : valider connectivité (ping) + cycle power (débrancher/rebrancher) si requis.



---
<!-- SOURCE: RUNBOOK__Post_Shutdown_Electrical_Validation -->
## RUNBOOK — Post-Shutdown Électrique (Reprise Infra)

# RUNBOOK — Post-Shutdown Électrique (reprise infra) — NOC/MSP

## Objectif
Assurer une reprise **stable** après retour du courant : réseau → stockage → virtualisation → services critiques → monitoring → rapport.

## Ordre de validation (priorité)
1) **Énergie/UPS/PDU** (événements power, batterie)
2) **Réseau** (FW/ISP/VPN/DNS/DHCP/NTP)
3) **Stockage** (SAN/NAS/RAID/SMART)
4) **Virtualisation** (vCenter/hosts/datastores)
5) **Services** (AD/DNS → SQL/IIS/File/RDS → apps)
6) **Backups** (dernier job + pas d'échec post-reprise)
7) **Monitoring** (alertes, ack, retour au vert)

## 1) UPS / Power events
- Vérifier logs UPS (power fail/restore, batteries faibles).
- Si UPS faible : noter le risque + recommander remplacement.

## 2) Réseau baseline (read-only)
```powershell
"=== DNS / Gateway quick checks ==="
ipconfig /all
nslookup google.com
route print | findstr /I "0.0.0.0"

"=== Time sync ==="
w32tm /query /status
w32tm /query /source
```

## 3) Stockage
- Sur SAN/NAS : état contrôleurs, disques, volumes, iSCSI, alertes.
- Vérifier que les datastores sont montés **avant** vCenter/ESXi dépendants.

## 4) Virtualisation (VMware vSphere)
- **Ordre recommandé** : SAN/NAS → ESXi hosts → vCenter.
- Si vCenter est parti avant le SAN :
  - redémarrer vCenter **après** confirmation datastores.
  - au besoin redémarrer les hosts ESXi (1 à la fois) si incohérences.
- Valider : cluster, hosts connected, datastores OK, VMs up.

## 5) Services critiques Windows (par rôle)
- DC: voir `RUNBOOK__DC_PrePost_Validation.md`
- SQL: voir `RUNBOOK__SQL_PrePost_Validation.md`
- Print: voir `RUNBOOK__PrintServer_PrePost_Validation.md`

## 6) Monitoring
- Lister les alertes apparues depuis le retour du courant.
- Distinguer :
  - alertes transitoires (boot) vs. anomalies persistantes
- Normaliser/ack une fois validé.

## 7) Rapport (CW)
- CW_NOTE_INTERNE : timeline + validations + anomalies + suivis.
- CW_DISCUSSION (STAR) : résultat + actions clés.



---
<!-- SOURCE: TEMPLATE_REPORT_Status-et-Technique_V1 -->
## TEMPLATE — Rapport Status et Technique

# TEMPLATE_REPORT_Status-et-Technique_V1
**Agent :** IT-ReportMaster, IT-Assistant-N3
**Usage :** Rapport de statut rapide + rapport technique d'intervention
**Mis à jour :** 2026-03-20

---

## PARTIE 1 — RAPPORT DE STATUT RAPIDE (Status Report)

```
═══════════════════════════════════════════════
RAPPORT DE STATUT
Client      : [NOM CLIENT]
Billet CW   : #[XXXXXX]
Période     : [YYYY-MM-DD HH:MM] → [YYYY-MM-DD HH:MM]
Technicien  : [NOM]
Type        : [Maintenance / Incident / Support / Audit]
═══════════════════════════════════════════════

STATUT GLOBAL : ✅ Complété / ⚠️ Partiel / ❌ En échec / 🔄 En cours

RÉSUMÉ
[2-3 phrases — ce qui a été fait et l'état final]

RÉSULTATS PAR ASSET
| Asset | Action effectuée | Statut | Notes |
|---|---|---|---|
| [NOM] | [Patching / Health check / Fix] | ✅ / ⚠️ / ❌ | [si applicable] |
| [NOM] | [...] | [...] | [...] |

ÉLÉMENTS EN SUSPENS
• [Item 1 — raison + action planifiée]
• [Item 2]

PROCHAINES ACTIONS RECOMMANDÉES
1. [Action — délai recommandé]
2. [Action]
═══════════════════════════════════════════════
```

---

## PARTIE 2 — RAPPORT TECHNIQUE D'INTERVENTION

```
═══════════════════════════════════════════════
RAPPORT TECHNIQUE D'INTERVENTION
Client      : [NOM CLIENT]
Billet CW   : #[XXXXXX]
Date        : [YYYY-MM-DD]
Technicien  : [NOM]
Type        : [Maintenance / Incident / Déploiement]
Durée       : [Xh Ymin]
═══════════════════════════════════════════════

1. CONTEXTE
[Description du besoin ou du problème initial]

2. ENVIRONNEMENT
Assets concernés : [Liste]
OS / Version     : [Windows Server 20XX, etc.]
Hyperviseur      : [VMware / Hyper-V / Vates / N/A]

3. ACTIONS RÉALISÉES
| # | Action | Résultat | Heure |
|---|---|---|---|
| 1 | [Action précise] | [Résultat] | [HH:MM] |
| 2 | [...] | [...] | [...] |

4. RÉSULTAT FINAL
Statut : ✅ Résolu / ⚠️ Partiel / ❌ Non résolu

[Description du résultat — services validés, état post-intervention]

5. RECOMMANDATIONS
• [Recommandation 1 — priorité]
• [Recommandation 2]

6. SUIVI REQUIS
☐ Oui → [Description + délai]
☐ Non
═══════════════════════════════════════════════
```


---
<!-- SOURCE: CHECKLIST_MAINTENANCE_Precheck-Generic_V1 -->
## CHECKLIST — Precheck Générique

# CHECKLIST — PRECHECK (Generic Windows Server)

- [ ] Uptime / last boot
- [ ] Pending reboot (CBS/WU/PendingFileRename/CCM)
- [ ] CPU/RAM (si perf incident)
- [ ] Disques (C: + volumes data) — espace libre
- [ ] Services critiques (selon rôle)
- [ ] Sessions (RDS) si reboot prévu
- [ ] Event Logs: System/Application (Errors/Critical sur 1–2h)
- [ ] Backups : dernier job OK (si maintenance)
- [ ] Monitoring: alertes actives vs baseline



---
<!-- SOURCE: CHECKLIST_MAINTENANCE_Postcheck-Generic_V1 -->
## CHECKLIST — Postcheck Générique

# CHECKLIST — POSTCHECK (Generic Windows Server)

- [ ] Host en ligne (ping/RMM)
- [ ] Services critiques OK
- [ ] Event Logs post-action: Kernel-Power, disk/NTFS, service failures
- [ ] Pending reboot = False (ou expliqué)
- [ ] App/partage/URL test rapide
- [ ] Monitoring back to green / alertes normalisées
- [ ] Backups: pas d'échec post-reprise

