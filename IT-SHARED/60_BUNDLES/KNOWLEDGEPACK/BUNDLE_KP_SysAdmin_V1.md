# BUNDLE_KP_SysAdmin_V1
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Type :** KnowledgePack GPT
**Agent cible :** IT-MaintenanceMaster
**Usage :** Uploader en Knowledge dans le GPT IT-MaintenanceMaster
**Contenu :** Runbooks + Scripts + Checklists pour la maintenance MSP
**Mis à jour :** 2026-03-20

---

## CHECKLIST PRÉ-MAINTENANCE (copier-coller au démarrage)

```
BILLET CW : #_______ | FENÊTRE : _______ à _______ | CLIENT : _______
APPROBATION REBOOTS : ☐ Oui  ☐ Non requis | CLIENT INFORMÉ : ☐ Fait

PRÉ-REQUIS
[ ] Backup < 24h confirmé pour chaque serveur critique
[ ] Snapshot créé sur VMs critiques (@[Ticket]_Preboot_[VM]_SNAP_[Date])
[ ] Espace disque > 10% libre sur C: et volumes data
[ ] Services critiques démarrés et stables
[ ] Pending Reboot = False (ou prévu dans la fenêtre)
[ ] Mode maintenance RMM activé (Datto RMM / N-able / CW RMM)
[ ] Accès admin validé (RDP / RMM)
[ ] Ordre intervention défini (non-critiques → App → SQL → FileServer → RDS → DC en dernier)

GO ✅ tous validés | NO-GO ❌ documenter dans CW et reprogrammer
```

---

## PROCÉDURE PATCHING WINDOWS — 1 SERVEUR À LA FOIS

```
⛔ RÈGLE NON NÉGOCIABLE : 1 serveur critique à la fois
⛔ AUCUN script qui redémarre une liste automatiquement

ÉTAPE 1 — PRECHECK
Get-PSDrive -PSProvider FileSystem | Select-Object Name,
    @{N='Free_GB';E={[math]::Round($_.Free/1GB,1)}},
    @{N='Free%';E={[math]::Round($_.Free/($_.Used+$_.Free)*100,0)}}
query user          # Sessions actives
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -eq 'Stopped'}

ÉTAPE 2 — PENDING REBOOT PRÉ-PATCH
$CBS = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
$WU  = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
$PFR = $null -ne (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' `
    -Name PendingFileRenameOperations -EA SilentlyContinue)
→ Si True : documenter la cause AVANT de patcher

ÉTAPE 3 — APPLIQUER LES PATCHS
Via CW RMM : lancer le job Windows Update sur le serveur cible
Via WSUS : approuver + déployer sur le groupe du serveur

ÉTAPE 4 — REBOOT (si requis et approuvé)
Vérifier qu'aucune session active → Restart-Computer -ComputerName [NOM] -Force

ÉTAPE 5 — POSTCHECK
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5 HotFixID,InstalledOn
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -eq 'Stopped'}
→ Valider services critiques + accès applicatif
```

---

## HEALTH CHECK SERVEUR (script rapide)

```powershell
$os = Get-CimInstance Win32_OperatingSystem
[pscustomobject]@{
    Hostname    = $env:COMPUTERNAME
    OS          = $os.Caption
    LastBoot    = $os.LastBootUpTime.ToString('yyyy-MM-dd HH:mm')
    Uptime_Days = [math]::Round(((Get-Date)-$os.LastBootUpTime).TotalDays,1)
    RAM_Free_GB = [math]::Round($os.FreePhysicalMemory/1MB,1)
    RAM_Used_PCT= [math]::Round(($os.TotalVisibleMemorySize-$os.FreePhysicalMemory)/$os.TotalVisibleMemorySize*100,0)
} | Format-List
Get-PSDrive -PSProvider FileSystem | Where-Object {$_.Used -gt 0} |
    Select-Object Name,@{N='Free_GB';E={[math]::Round($_.Free/1GB,1)}},
    @{N='Free%';E={[math]::Round($_.Free/($_.Used+$_.Free)*100,0)}} | Format-Table
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -eq 'Stopped'}
```

---

## GESTION SNAPSHOTS (convention de nommage)

```
NOM OBLIGATOIRE : @[Ticket]_[Phase]_[NomVM]_SNAP_[YYYYMMDD_HHMM]
Exemple : @T12345_Preboot_SRV-APP01_SNAP_20260320_2145

RÈGLES :
⛔ NE JAMAIS snapshoter un DC (risque USN rollback → corruption AD)
⛔ NE JAMAIS laisser un snapshot > 72h en production
→ Supprimer APRÈS validation de l'intervention

Hyper-V :
Checkpoint-VM -Name "SRV-APP01" -SnapshotName "@T12345_Preboot_SRV-APP01_SNAP_$(Get-Date -Format 'yyyyMMdd_HHmm')"
Remove-VMSnapshot -VMName "SRV-APP01" -Name "@T12345_Preboot_*"

VMware PowerCLI :
New-Snapshot -VM "SRV-APP01" -Name "@T12345_Preboot_SRV-APP01_SNAP_$(Get-Date -Format 'yyyyMMdd_HHmm')" -Quiesce:$true
Get-VM "SRV-APP01" | Get-Snapshot -Name "@T12345*" | Remove-Snapshot -Confirm:$false
```

---

## WSUS — OPÉRATIONS COURANTES

```
HEALTH CHECK
Get-Service WsusService,W3SVC | Select-Object Name,Status | Format-Table
→ Console WSUS : vérifier Last Synchronization + Updates Unapproved

APPROBATION
Console WSUS → Updates → All Updates → Approval=Unapproved, Status=Needed
→ Critical + Security Updates : approuver → groupe TEST d'abord → PROD après 7 jours

CLEANUP MENSUEL (obligatoire)
Console WSUS → Options → Server Cleanup Wizard → cocher toutes les options
Ou PowerShell : Import-Module UpdateServices → Get-WsusServer → GetCleanupManager → PerformCleanup

⚠️ Maintenance base SQL SUSDB recommandée si WSUS lent :
USE SUSDB; EXEC sp_MSforeachtable 'ALTER INDEX ALL ON ? REBUILD'; EXEC sp_updatestats;

Escalade : INFRA si WSUS ne synchronise plus depuis > 24h
```

---

## SEUILS D'ALERTE ET ACTIONS

| Indicateur | Normal | Attention | Critique | Action |
|---|---|---|---|---|
| CPU | < 70% | 70-90% | > 90% | Identifier processus → escalade NOC |
| RAM libre | > 20% | 10-20% | < 10% | Identifier consommateurs → escalade INFRA |
| Disque libre | > 20% | 10-20% | < 5% | Nettoyage immédiat → escalade INFRA |
| Pending Reboot | False | — | True > 7j | Planifier reboot → informer client |
| Uptime | < 90j | 90-180j | > 180j | Planifier reboot lors prochaine maintenance |

---

## CLOSEOUT — LIVRABLES CW

⛔ NE PAS utiliser ce KP pour générer les livrables CW.

Charger obligatoirement :
getFileContent(path="IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW/TEMPLATE_BUNDLE_CW_CLOSE.md")

Utiliser le template exact du fichier GitHub. Aucune improvisation de structure.