---
title: "BUNDLE_KP_IT-MaintenanceMaster_V2 — KnowledgePack (Windows)"
type: "KnowledgePack"
target_agent: "IT-MaintenanceMaster"
scope: ["windows", "maintenance", "patching", "backup", "virtualisation", "vulnerability_management"]
version: "2.0"
last_updated: "2026-04-09"
language: "fr"
---

# BUNDLE_KP_IT-MaintenanceMaster_V2 — KnowledgePack (Windows)

> **But** : bibliothèque opérationnelle *copier-coller* pour accélérer les interventions (soir / maintenance) : checklists, mini-runbooks, scripts/commandes utiles, templates de clôture (CW/Teams).
>
> **Important** : ce fichier est conçu pour être **uploadé dans la Knowledge** d’un agent.  
> Le “cerveau” (comportements, garde-fous, formats de sortie) reste dans `00_INSTRUCTIONS.md` + `prompt.md`.

---

## 1) À quoi ça sert (et pourquoi WSUS apparaît parfois)

- **Objectif réel** : accélérer les interventions avec des blocs prêts à l’emploi (pré-maintenance, patching “1 serveur à la fois”, snapshots, closeout ConnectWise).
- **Pourquoi WSUS apparaît** : héritage “MSP générique”. Si vous ne touchez plus WSUS, ça devient du bruit et ça fait dériver les gestes.

---

## 2) Points d’attention (incohérences / risques de dérive)

### A) WSUS trop présent vs réalité terrain
➡️ Action : soit **retirer** WSUS, soit le passer en **ANNEXE “Legacy / si client WSUS”**.

### B) Conventions de nommage snapshots à harmoniser
➡️ Action : adopter une convention unique :
- `@BILLET_PHASE_SERVEUR_SNAP_YYYYMMDD_HHMM`

### C) Closeout ConnectWise : séparer NOTE INTERNE vs DISCUSSION
➡️ Action : imposer des ouvertures **différentes** + contenu **client-safe** pour la Discussion (pas de commandes, pas d’IP, pas de noms serveurs, etc.).

### D) Capabilities : “Web Search” (si applicable dans votre stack)
➡️ Action : trancher et aligner la configuration (si vous en avez besoin pour CVE/statuts cloud/sources officielles, activer avec garde-fous).

### E) Nommage du bundle
➡️ Action : garder un nom stable et prévisible (`BUNDLE_KP_IT-MaintenanceMaster_V2.md`) pour éviter les mauvais uploads/index.

---

## 3) Bundle opérationnel (contenu prêt à coller)

# BUNDLE_KP_IT-MaintenanceMaster_V2
**Type :** KnowledgePack GPT  
**Agent cible :** IT-MaintenanceMaster  
**Usage :** Uploader en Knowledge (après `prompt.md`)  
**Stack terrain (référence) :** ConnectWise RMM • Qualys • Veeam / Datto • VMware / Hyper-V / XCP-ng  
**But :** Interventions de soir : runbooks courts + checklists + templates CW/Teams.

---

## 0) INDEX — “quoi utiliser quand”
- Patching Windows (CW RMM) → Section 1
- Erreur Windows Update / patch qui casse → Section 2
- Backup KO (Veeam) → Section 3
- Backup KO (Datto) → Section 4
- Hyperviseurs / VM perf / datastore / snapshots → Section 5 (et Bundle Virtualisation)
- Performance / capacity / disque → Section 6
- CVE / vuln Qualys → Section 7
- Clôture CW + Notice Teams + brief KB → Section 8

---

## 0.1 CHECKLIST DÉMARRAGE (ticket live — 90 secondes)
```

BILLET CW : #_______ | CLIENT : _______ | FENÊTRE : _______ à _______
IMPACT : ☐ aucun ☐ partiel ☐ majeur | APPROBATION REBOOTS : ☐ Oui ☐ Non/NA

[ ] Identifier le type : patch | backup | perf | CVE | hyperviseur | autre
[ ] Vérifier “backup < 24h” si action risquée sur serveur critique
[ ] Si VM critique : snapshot (SAUF DC) selon convention @BILLET_PHASE_SERVEUR_SNAP_YYYYMMDD_HHMM
[ ] Mode maintenance dans ConnectWise RMM si reboot / services / patch
[ ] 1 serveur critique à la fois (jamais de liste auto)
[ ] Préparer la notice Teams (optionnelle maintenant, sinon à /close)

````

---

## 1) PATCHING WINDOWS — via ConnectWise RMM (1 serveur à la fois)
### Règles
- ⛔ 1 serveur critique à la fois
- ⛔ Pas de “patch all servers” avec reboot auto
- ✅ Toujours PRECHECK + POSTCHECK

### PRECHECK (lecture seule)
```powershell
Get-PSDrive -PSProvider FileSystem | Select-Object Name,
  @{N='Free_GB';E={[math]::Round($_.Free/1GB,1)}},
  @{N='Free%';E={[math]::Round($_.Free/($_.Used+$_.Free)*100,0)}}

query user
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -eq 'Stopped'}

$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = $null -ne (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' `
  -Name PendingFileRenameOperations -EA SilentlyContinue)
"$env:COMPUTERNAME PendingReboot: CBS=$CBS WU=$WU PFR=$PFR"
````

### APPLY PATCHES (CW RMM)

* Déployer les updates via la job/task standard CW RMM du client (Windows Updates / Patch Manager).
* Si une KB échoue : passer Section 2 (Windows Update failure) avant de réessayer.

### REBOOT (si approuvé)

```powershell
Restart-Computer -Force
```

### POSTCHECK

```powershell
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5 HotFixID,InstalledOn
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -eq 'Stopped'}
```

### VALIDATIONS “métier”

* Accès RDP / appli / partage / RDS selon rôle
* Monitoring au vert
* Aucun impact backup (vérifier prochaine exécution si fenêtre proche)

---

## 2) PATCH / WINDOWS UPDATE FAIL — Runbook court

### Symptômes fréquents

* Download/Install stuck
* Code erreur Windows Update
* Servicing stack corrompu / DISM

### Collecte rapide (lecture seule)

```powershell
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=(Get-Date).AddHours(-6)} |
  Where-Object {$_.LevelDisplayName -in 'Error','Critical'} |
  Select-Object TimeCreated, Id, ProviderName, Message -First 25 | Format-List

Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-WindowsUpdateClient/Operational'; StartTime=(Get-Date).AddHours(-24)} |
  Select-Object TimeCreated, Id, Message -First 40 | Format-List
```

### Remédiation standard (⚠️ impact : reset composants WU)

> À exécuter seulement si approuvé (et idéalement hors heures actives).

```powershell
net stop wuauserv
net stop bits
net stop cryptsvc
net stop msiserver

ren C:\Windows\SoftwareDistribution SoftwareDistribution.old
ren C:\Windows\System32\catroot2 catroot2.old

net start msiserver
net start cryptsvc
net start bits
net start wuauserv
```

### Si corruption système suspectée (⚠️ peut prendre du temps)

```powershell
sfc /scannow
DISM /Online /Cleanup-Image /RestoreHealth
```

---

## 3) BACKUP — VEEAM (job failed / repo plein / pas de restore point)

### Triage express

1. Quel job ? quel serveur ? depuis quand ?
2. Dernier succès + dernier restore point OK ?
3. Repo/SOBR : espace libre ?
4. Services Veeam OK ?

### Commandes (si VBR PowerShell dispo)

```powershell
# Indique rapidement état des jobs (sur serveur VBR)
Get-VBRJob | ForEach-Object {
  $s = $_.FindLastSession()
  if ($s) { [pscustomobject]@{Job=$_.Name;Result=$s.Result;End=$s.EndTime} }
} | Sort-Object End -Descending | Select-Object -First 15 | Format-Table

Get-VBRBackupRepository | Select-Object Name,
  @{N='Free_GB';E={[math]::Round($_.Info.CachedFreeSpace/1GB,1)}},
  @{N='Free_%';E={[math]::Round($_.Info.CachedFreeSpace/$_.Info.CachedTotalSpace*100,0)}} |
  Format-Table
```

### Actions typiques

* Repo <10% libre → nettoyage (retention/chain) ou escalade BackupDR
* Job échoue sur VSS / CBT / réseau → corriger cause puis retry
* Pas de restore point récent sur serveur critique → **stopper patching** et escalader

---

## 4) BACKUP — DATTO (backup failed / screenshot / offsite)

### Triage express

* Dernier backup : succès ?
* Screenshot verification : OK ?
* Offsite sync : à jour ?
* Agent/service : online ?

### Actions typiques

* Agent offline → relancer services/agent, vérifier connectivité
* Offsite en retard → vérifier bande passante / queue
* Screenshot failed → corriger boot/driver/storage puis relancer vérif

*(Détails clients / portails : utiliser la doc client + runbook BackupDR si dispo.)*

---

## 5) HYPERVISEURS / VMs — points clés (et lien bundle)

> Utiliser le bundle **BUNDLE_INFRA_VIRTUALISATION** pour VMware/Hyper-V/XCP-ng (health check, snapshots, migrations, host maintenance).

Rappels non négociables :

* ⛔ Snapshot sur DC = éviter (risque AD/USN rollback) — utiliser backup “proper”
* ⛔ Snapshot > 72h = dette technique à supprimer
* ✅ Datastore <10% libre = incident à traiter

---

## 6) PERFORMANCE — runbook court (serveur/VM)

### Collecte rapide

```powershell
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name,Id,CPU,WorkingSet
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name,Id,CPU,WorkingSet

Get-PSDrive -PSProvider FileSystem | Select-Object Name,
  @{N='Free_GB';E={[math]::Round($_.Free/1GB,1)}},
  @{N='Free%';E={[math]::Round($_.Free/($_.Used+$_.Free)*100,0)}}

Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=(Get-Date).AddHours(-2)} |
  Where-Object {$_.LevelDisplayName -in 'Error','Critical'} |
  Select-Object TimeCreated, Id, ProviderName, Message -First 20 | Format-List
```

### Patterns fréquents

* Disque <10% + logs/temp → nettoyage contrôlé
* RAM saturée → identifier service/process + fuite mémoire
* CPU >90% → top process + corrélation tâche planifiée / AV / indexation
* IO datastore → vérifier snapshots, consolidation, storage latency (hyperviseur)

---

## 7) CVE / VULN — Qualys workflow (terrain)

1. Identifier CVE + criticité + “evidence” (Qualys)
2. Scope : quelles machines / quel OS / quel app
3. Mitigation court terme (service/config) si patch pas immédiat
4. Déploiement patch via ConnectWise RMM (fenêtre + approvals)
5. Validation : checks service + rescans Qualys (ou planifier rescan)
6. Documenter : impact, preuve, et prochaine action (si reste des exceptions)

---

## 8) TEMPLATES — TEAMS + CW (conformes aux Instructions)

### Notice Teams (à adapter)

Titre :
`⚠️ [Statut] — Billet : #[XXXXX]`
Contenu :

* Situation chez [Client]
* Tâche principale : [Action]
* Impact : [Description]

### CW NOTE INTERNE (tech)

**Phrase obligatoire :**
`Prise de connaissance de la demande et consultation de la documentation du client.`

Structure :

* Début/Fin
* Timeline horodatée
* Actions + résultats observés
* Validations

### CW DISCUSSION (client-safe)

**Phrases obligatoires :**
`Préparation et découverte.`
`Prendre connaissance de la demande et connexion à la documentation de l'entreprise.`

TRAVAUX EFFECTUÉS (min 4 puces) + RÉSULTAT.
⛔ Jamais : IP / commandes / noms serveurs / CVE

---

## ANNEXE A) WSUS (LEGACY — seulement si client WSUS)

* À garder uniquement si certains clients l’utilisent encore.
* Sinon : retirer cette annexe pour éviter la confusion.

---

## 4) Recos d’implantation (rapide, concret)

1) **Ordre d’upload** : `prompt.md` en premier, puis ce bundle (et les bundles de domaine).
2) **Ne pas uploader dans Knowledge** : `agent.yaml`, `contract.yaml`, `manifest.json` (c’est du “wiring” interne, pas du savoir opérateur).
3) **Éviter la duplication** : si vous avez déjà un bundle “virtualisation” (VMware/Hyper‑V/XCP‑ng), référencez-le au lieu de recopier.
4) **Nettoyage WSUS** : si non utilisé, gardez uniquement l’Annexe Legacy ou supprimez pour réduire le bruit.

---

## 5) Changelog

- **V2.0 (2026-04-09)** : version “alignée terrain” (patching 1 serveur à la fois, WU fail, Veeam/Datto, perf, Qualys, closeout CW, WSUS en annexe).
