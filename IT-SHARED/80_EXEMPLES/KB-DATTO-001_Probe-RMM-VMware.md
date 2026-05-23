Voici la KB **Datto** structurée **sur le même modèle** que ton exemple Veeam. 

---

# KB — Datto : Échecs Agentless VMware “AgentlessProxyApi initialization timeout / Could not update agent metadata / VMware task still running” — VSS writers + pression mémoire + SentinelOne

**Référence :** KB-DATTO-001
**Domaine :** Backup / Datto SIRIS / VMware ESXi-vCenter / Windows VSS / EDR SentinelOne
**Créé de :** Ticket CW **#0001234** — Otto Inc (Otto / OTTO)
**Date :** 2026-04-02
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Auteur :** @IT-MaintenanceMaster

---

## Symptôme

Sauvegardes Datto (SIRIS) en échec sur une VM Windows en **Agentless VMware**.

Erreurs typiques observées dans les logs Datto :

* `Timeout occurred during AgentlessProxyApi initialization`
* `VMware task still running` (au moment de `Creating snapshot...`)
* `Critical backup failure: Could not update agent metadata`
* “No Result” sur **Screenshot Verification** et **Offsite Backup** (effet domino après échec du point local)

Côté Windows :

* `vssadmin list writers` hang ou writers en `State [9] Failed` / `Timed out`.

---

## Cause racine confirmée

1. **Pression mémoire critique** sur la VM (RAM saturée ~100%) → VSS devient instable (writers qui time-out, vssadmin qui hang) → snapshot VMware quiesced devient lent ou bloqué.
2. **Writers VSS SentinelOne** en `Timed out`, aggravé par un état console **“Pending uninstall”** → empêche la réussite complète du snapshot cohérent.
3. **IIS Config Writer** en timeout (corrigé par restart IIS), contribuant au blocage VSS si rôle IIS actif.

**Conclusion :** Datto Agentless échoue car il dépend d’un **snapshot VMware quiesced** (VMware Tools + VSS). Si VSS/writers sont en échec → la tâche snapshot peut rester “running” indéfiniment puis le job échoue.

---

## Indices diagnostics

### Dans Datto (logs job)

* Blocage à l’étape snapshot :

  * `Creating snapshot...`
  * répétitions : `VMware task still running`
  * puis : `Could not update agent metadata` (souvent après retries)

### Dans Windows (VM)

* RAM très élevée, peu ou pas de mémoire libre.
* `vssadmin list writers` :

  * Writers critiques en `Timed out` (System/SQL/WMI/IIS/Sentinel)
* IIS writer en échec si AppHost/IIS instable.
* Writers SentinelOne présents en `Timed out`, surtout si endpoint “Pending uninstall”.

### Dans vSphere/ESXi

* Tâches snapshot “Create virtual machine snapshot” longues/stuck
* Possibilité de “Needs consolidation” si snapshots s’accumulent

---

## Procédure de diagnostic (PRECHECK)

> À exécuter sur la **VM Windows** (PowerShell Admin).
> Objectif : confirmer pression mémoire + état VSS + services clés.

### 1) CPU/RAM + Top process (15s)

```powershell
# CPU/RAM quick view + top RAM processes
$cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue
$avail = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
$cs = Get-CimInstance Win32_ComputerSystem
$totalGB = [math]::Round($cs.TotalPhysicalMemory/1GB,0)
$usedGB = [math]::Round(($totalGB*1024 - $avail)/1024,2)
$usedPct = [math]::Round(($usedGB/$totalGB)*100,1)

"CPU=% {0} | RAM={1}GB used ({2}%) | Free={3}MB" -f ([math]::Round($cpu,1)),$usedGB,$usedPct,[int]$avail

Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 `
  @{N='Process';E={$_.ProcessName}},Id,
  @{N='WS_GB';E={[math]::Round($_.WorkingSet64/1GB,2)}},
  @{N='Private_GB';E={[math]::Round($_.PrivateMemorySize64/1GB,2)}} | Format-Table -AutoSize
```

**Résultat attendu (sain)** : RAM **< 80%** et plusieurs GB libres.

### 2) VSS Writers

```powershell
vssadmin list writers
```

**Résultat attendu (sain)** : tous `State [1] Stable` / `Last error: No error`.

### 3) Services clés (VSS/SQL/IIS/WMI/VMware Tools)

```powershell
Get-Service VSS,swprv,SQLWriter,Winmgmt,W3SVC,WAS,AppHostSvc,vmtools -ErrorAction SilentlyContinue |
  Select Name,Status,StartType | Format-Table -AutoSize
```

### 4) (Optionnel) Events VSS/Volsnap/SQLWRITER (48h)

```powershell
$start=(Get-Date).AddHours(-48)
Get-WinEvent -FilterHashtable @{LogName='System';StartTime=$start} -EA SilentlyContinue |
  ? {$_.ProviderName -in 'VSS','Volsnap','Service Control Manager'} |
  Select -First 80 TimeCreated,ProviderName,Id,LevelDisplayName,Message | Format-List

Get-WinEvent -FilterHashtable @{LogName='Application';StartTime=$start} -EA SilentlyContinue |
  ? {$_.ProviderName -in 'VSS','SQLWRITER'} |
  Select -First 80 TimeCreated,ProviderName,Id,LevelDisplayName,Message | Format-List
```

---

## Correctif (ce qui a fonctionné)

### Étape A — Corriger la pression mémoire (si RAM saturée)

1. Planifier fenêtre, arrêt propre de la VM (cause documentée).
2. Augmenter RAM **ex : 32GB → 64GB** côté vSphere (VM powered off).
3. Redémarrer et revalider CPU/RAM + VSS.

**Résultat attendu :**

* Mémoire libre redevenue confortable (ex : dizaines de GB libres)
* `vssadmin list writers` ne hang plus

### Étape B — Réparer VSS (reset services)

```powershell
# Reset VSS-related services
$restart = 'SQLWriter','Winmgmt','CryptSvc','COMSysApp','VSS','swprv'
foreach($s in $restart){
  $svc=Get-Service $s -EA SilentlyContinue
  if($svc){
    Restart-Service $s -Force
    Start-Sleep 2
  }
}
Start-Sleep 15
vssadmin list writers
```

**Résultat attendu :** System/SQL/WMI writers repassent `Stable`.

### Étape C — Corriger IIS Config Writer (si en timeout)

```powershell
Restart-Service AppHostSvc -Force -ErrorAction SilentlyContinue
iisreset /restart
Start-Sleep 15
vssadmin list writers
```

**Résultat attendu :** `IIS Config Writer` = `Stable`.

### Étape D — SentinelOne (writers en timeout / pending uninstall)

* Si writers Sentinel en échec **et** pas de passphrase/contrôle SOC : **ne pas forcer**.
* Coordonner avec SOC :

  * compléter/annuler action “Pending uninstall”
  * ou procéder à désinstallation/réinstallation officielle selon policy

**Résultat attendu :** disparition des writers Sentinel ou retour en `Stable`, puis `vssadmin list writers` 100% OK.

---

## Validation post-correctif

### 1) Test snapshot VMware (dans vSphere)

* Take Snapshot

  * Memory **OFF**
  * **Quiesce guest file system ON**
* Doit réussir rapidement (pas de tâche “stuck”).

### 2) Test Datto (backup manuel)

* Lancer **Backup Now**
* Suivre : `Running preflight` → `Transferring` → **Success**

### 3) Contrôles secondaires

* Screenshot Verification : repasse OK (après point local réussi)
* Offsite : reprend (selon file d’attente)

---

## Escalade si persistant après correctifs VSS/RAM

1. vSphere : vérifier “Needs consolidation”, snapshots résiduels, tâches snapshot coincées.
2. Datto : vérifier hypervisor connection (auth/état), logs détaillés de session agentless.
3. En dernier recours : reset CBT / réassignation agentless (si la VM a changé d’identité côté vCenter).

---

## Agents impliqués

| Agent                 | Rôle                                                                          |
| --------------------- | ----------------------------------------------------------------------------- |
| @IT-MaintenanceMaster | Triage, scripts PRECHECK, remédiation Windows (VSS/IIS/RAM), validation Datto |
| SOC / Sécurité        | Actions SentinelOne (passphrase/policy/pending actions), conformité endpoint  |
| Infra VMware          | Support consolidation/snapshot/storage si tâches snapshot bloquées            |

---

## Note opérationnelle

Ce type d’échec Datto **n’est pas un “problème Datto” dans 80% des cas** :
il faut corréler **Datto (snapshot) ⇄ vSphere task ⇄ VSS writers ⇄ ressources (RAM)** avant toute remédiation.

Toujours exécuter **PRECHECK** avant actions à impact, puis valider :

* `vssadmin list writers` = **100% Stable**
* Snapshot VMware quiesced = OK
* Backup Datto manuel = Success

---

*KB-DATTO-001 — v1.0 — 2026-04-02*
