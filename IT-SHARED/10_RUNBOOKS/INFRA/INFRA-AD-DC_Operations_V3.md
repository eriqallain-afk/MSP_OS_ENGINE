# INFRA-AD-DC_Operations_V3
**Version :** 3.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Domaine :** AD (Active Directory)
**Durée estimée :** 30–90 min selon opération

---

## OBJECTIF

Procédures complètes pour la santé, la maintenance et les opérations des contrôleurs de domaine Windows Server.
Couvre : health check complet, réplication, FSMO, pré/post reboot, et résolution des erreurs courantes.

---

## PRÉ-REQUIS

| Élément | Requis |
|---|---|
| Accès | Administrateur du domaine |
| Outils | PowerShell 5.1+, DCDiag, Repadmin, RSAT |
| Snapshot / Backup | ✅ Obligatoire avant toute opération |
| Fenêtre de maintenance | Confirmée avec le client |
| CW Ticket | Ouvert et en cours |

---

## SECTION 1 — HEALTH CHECK COMPLET

### 1A — Vérification connectivité et services

```powershell
# Lister tous les DC du domaine
Get-ADDomainController -Filter * | Select-Object Name, HostName, Site, IsGlobalCatalog, OperatingSystem

# Tester la connectivité réseau de chaque DC
$DCs = Get-ADDomainController -Filter *
foreach ($DC in $DCs) {
    $ping = Test-Connection -ComputerName $DC.HostName -Count 2 -Quiet
    Write-Host "$($DC.Name): Ping=$ping"
}

# Vérifier les services critiques sur chaque DC
$Services = 'DNS','DFS Replication','Intersite Messaging',
            'Kerberos Key Distribution Center','NetLogon',
            'Active Directory Domain Services','Windows Time'
foreach ($DC in $DCs) {
    Invoke-Command -ComputerName $DC.HostName -ScriptBlock {
        param($services)
        foreach ($svc in $services) {
            $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
            if ($s) { [PSCustomObject]@{DC=$env:COMPUTERNAME; Service=$svc; Status=$s.Status} }
        }
    } -ArgumentList (,$Services)
}
```

**Validation :** Tous les services doivent être en état `Running`. Un service `Stopped` déclenche immédiatement une escalade P2.

### 1B — DCDiag complet

```powershell
# Diagnostic complet sur tous les DC
foreach ($DC in (Get-ADDomainController -Filter *).HostName) {
    Write-Host "`n=== DCDiag sur $DC ===" -ForegroundColor Cyan
    dcdiag /s:$DC /test:Advertising /test:FrsEvent /test:DFSREvent /test:SysVolCheck `
           /test:KccEvent /test:KnowsOfRoleHolders /test:MachineAccount /test:NCSecDesc `
           /test:NetLogons /test:ObjectsReplicated /test:Replications /test:RidManager `
           /test:Services /test:SystemLog /test:VerifyReferences /test:CheckSDRefDom `
           /test:CrossRefValidation /test:LocatorCheck /test:Intersite /test:FSMOCheck
}

# Exporter les résultats
dcdiag /v > "C:\Temp\DCDiag_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"
```

**Tests critiques à surveiller :**
- `Advertising` — Le DC s'annonce correctement sur le réseau
- `Replications` — Réplication sans erreurs
- `FSMOCheck` — Rôles FSMO accessibles
- `KnowsOfRoleHolders` — Connaissance des détenteurs FSMO
- `SysVolCheck` — SYSVOL répliqué correctement

### 1C — Réplication AD

```powershell
# Résumé de réplication (vue rapide)
repadmin /replsummary

# Détail par DC et partenaire
repadmin /showrepl *

# Erreurs de réplication uniquement
repadmin /showrepl * /errorsonly

# Via PowerShell (plus lisible)
Get-ADReplicationFailure -Scope Domain | 
    Select-Object Server, LastError, Partner, FailureCount |
    Format-Table -AutoSize

# Delta de réplication (doit être < 60 min en production)
Get-ADReplicationPartnerMetadata -Target * -Partition * | 
    Select-Object Server, Partner, ConsecutiveReplicationFailures,
                  LastReplicationSuccess, LastReplicationResult |
    Where-Object { $_.ConsecutiveReplicationFailures -gt 0 } |
    Format-Table -AutoSize
```

**Seuils d'alerte :**
- Delta > 60 min → ⚠️ Avertissement
- Delta > 4 heures → 🔴 P2 — Escalade IT-Commandare-NOC
- Erreurs consécutives > 0 → ⚠️ Investiguer immédiatement

### 1D — FSMO Roles

```powershell
# Vérifier les détenteurs FSMO
netdom query fsmo

# Via PowerShell (plus détaillé)
Get-ADForest | Select-Object SchemaMaster, DomainNamingMaster
Get-ADDomain | Select-Object PDCEmulator, RIDMaster, InfrastructureMaster

# Valider l'accessibilité des rôles FSMO
$FsmoHolders = @(
    (Get-ADForest).SchemaMaster,
    (Get-ADForest).DomainNamingMaster,
    (Get-ADDomain).PDCEmulator,
    (Get-ADDomain).RIDMaster,
    (Get-ADDomain).InfrastructureMaster
) | Select-Object -Unique

foreach ($fsmo in $FsmoHolders) {
    $reachable = Test-Connection -ComputerName $fsmo -Count 1 -Quiet
    Write-Host "$fsmo : $( if ($reachable) {'✅ OK'} else {'❌ INACCESSIBLE'} )"
}
```

**Rôles FSMO et impact en cas de perte :**
| Rôle | Impact perte | Urgence |
|---|---|---|
| PDC Emulator | Auth lente, GPO, sync temps | P2 — 4h max |
| RID Master | Impossibilité créer objets AD | P2 — 4h max |
| Infrastructure Master | Références inter-domaines | P3 — 24h |
| Schema Master | Modifications schéma bloquées | P3 — 48h |
| Domain Naming Master | Ajout/suppression domaines | P4 |

### 1E — DNS et SYSVOL

```powershell
# Vérifier DNS sur tous les DC
dcdiag /test:DNS /DnsBasic /DnsForwarders /DnsDelegation /DnsDynamicUpdate /DnsRecordRegistration

# Tester la résolution DNS
foreach ($DC in (Get-ADDomainController -Filter *).HostName) {
    Resolve-DnsName -Name $DC -Server $DC -ErrorAction SilentlyContinue |
        Select-Object @{N='DC';E={$DC}}, Name, IPAddress, Type
}

# Vérifier SYSVOL
foreach ($DC in (Get-ADDomainController -Filter *).HostName) {
    $sysvol = Test-Path "\\$DC\SYSVOL"
    $netlogon = Test-Path "\\$DC\NETLOGON"
    Write-Host "$DC → SYSVOL=$sysvol | NETLOGON=$netlogon"
}
```

### 1F — Synchronisation du temps

```powershell
# Vérifier le temps sur tous les DC (différence < 5 secondes)
foreach ($DC in (Get-ADDomainController -Filter *).HostName) {
    $w32tm = Invoke-Command -ComputerName $DC { 
        w32tm /query /status /verbose 
    }
    Write-Host "`n=== $DC ===" ; $w32tm
}

# Sur le PDC Emulator spécifiquement
$PDC = (Get-ADDomain).PDCEmulator
Invoke-Command -ComputerName $PDC { w32tm /query /source }
```

**Note :** Le PDC Emulator est la source de temps principale du domaine. Les autres DC se synchronisent sur lui. Un décalage > 5 minutes cause des échecs d'authentification Kerberos.

---

## SECTION 2 — PRÉ-REBOOT (avant redémarrage DC)

```powershell
# 2A — Vérifier la réplication est saine AVANT le reboot
repadmin /replsummary
# → Doit afficher 0 failures

# 2B — Transférer les rôles FSMO si ce DC en détient
$DC_Name = $env:COMPUTERNAME
$FsmoDC = Get-ADDomain | Select-Object PDCEmulator, RIDMaster, InfrastructureMaster
$FsmoForest = Get-ADForest | Select-Object SchemaMaster, DomainNamingMaster

# Si ce DC est PDC Emulator, transférer vers un autre DC
if ($FsmoDC.PDCEmulator -match $DC_Name) {
    Write-Host "⚠️  Ce DC est PDC Emulator — transférer avant reboot"
    # Move-ADDirectoryServerOperationMasterRole -Identity "AUTRE-DC" -OperationMasterRole 0,1,2,3,4
}

# 2C — Vérifier les sessions actives
query session /server:$DC_Name
qwinsta /server:$DC_Name

# 2D — Vérifier les partages ouverts
Get-SmbOpenFile -ErrorAction SilentlyContinue | Select-Object ClientUserName, Path, SessionId

# 2E — Snapshot VMware/Hyper-V si applicable
# → Effectuer AVANT d'initier le reboot
# → Veeam: s'assurer qu'aucun job backup n'est en cours

# 2F — Notifier le NOC et le client
Write-Host "🔔 Notification NOC et client avant reboot DC"
```

---

## REBOOT DC — COMMANDE OBLIGATOIRE

> `shutdown /r` enregistre le billet et la raison dans l'**Event ID 1074** du System log.
> ⛔ **Ne jamais utiliser `Restart-Computer -Force` seul sur un DC — pas de traçabilité.**

```powershell
# ── Depuis le DC lui-même ──────────────────────────────────
$ticket = "#XXXXX"
$raison = "Patching mensuel DC / Maintenance planifiée"   # adapter selon contexte
shutdown /r /t 0 /c "Billet $ticket — $raison" /d p:4:1

# ── Depuis un poste admin (remote) ────────────────────────
Invoke-Command -ComputerName "SRV-DC01" -ScriptBlock {
    param($t, $r)
    shutdown /r /t 0 /c "Billet $t — $r" /d p:4:1
} -ArgumentList "#XXXXX", "Patching mensuel DC"
```

> **Codes raison :**
> `p:4:1` = Maintenance planifiée · `p:2:4` = Reconfiguration OS · `p:2:17` = Service Pack

---

## SECTION 3 — POST-REBOOT (après redémarrage DC)

```powershell
# Attendre la disponibilité du DC (max 10 min)
$timeout = 0
while ($timeout -lt 30) {
    if (Test-Connection -ComputerName $env:COMPUTERNAME -Count 1 -Quiet) {
        Write-Host "✅ DC accessible après $($timeout * 20)s"
        break
    }
    Start-Sleep 20; $timeout++
}

# 3A — Services critiques après reboot
$Services = 'DNS','DFS Replication','Intersite Messaging',
            'Kerberos Key Distribution Center','NetLogon',
            'Active Directory Domain Services','Windows Time'
foreach ($svc in $Services) {
    $s = Get-Service -Name $svc
    $status = $s.Status
    Write-Host "$svc : $status $(if ($status -eq 'Running') {'✅'} else {'❌'})"
    if ($status -ne 'Running') { Start-Service -Name $svc }
}

# 3B — DCDiag post-reboot
dcdiag /test:Advertising /test:Replications /test:FSMOCheck /test:Services

# 3C — Réplication post-reboot
repadmin /replsummary
# → 0 failures requis

# 3D — Forcer une réplication si nécessaire
repadmin /syncall /AdeP

# 3E — Vérifier SYSVOL et NETLOGON
Test-Path "\\$env:COMPUTERNAME\SYSVOL"
Test-Path "\\$env:COMPUTERNAME\NETLOGON"

# 3F — Vérifier les journaux événements post-reboot
Get-EventLog -LogName "Directory Service" -EntryType Error,Warning -Newest 20 |
    Select-Object TimeGenerated, EventID, Source, Message |
    Format-Table -AutoSize -Wrap
```

---

## SECTION 4 — RÉSOLUTION DES ERREURS COURANTES

### Erreur : Réplication échouée

```powershell
# Diagnostic
repadmin /showrepl * /errorsonly
repadmin /showchanges * * /statistics

# Forcer la réplication
repadmin /syncall DC-CIBLE /AdeP

# Si objets persistants (lingering objects)
repadmin /removelingeringobjects DC-SOURCE DC-CIBLE "DC=domaine,DC=com"

# Corriger l'autorité de la réplication
repadmin /options DC-CIBLE +IS_GC  # Si DC est GC
```

### Erreur : SYSVOL non partagé

```powershell
# Vérifier l'état DFSR
dfsrmig /getmigrationstate

# Redémarrer DFSR
Restart-Service DFSR

# Vérifier les journaux DFSR
Get-WinEvent -LogName "DFS Replication" -MaxEvents 50 |
    Where-Object {$_.LevelDisplayName -in "Error","Warning"} |
    Select-Object TimeCreated, Id, Message
```

### Erreur : FSMO inaccessible / seizure d'urgence

```powershell
# SEULEMENT si le DC original ne peut PAS être restauré
# Seizure du rôle PDC Emulator
ntdsutil
  roles
  connections
  connect to server NOUVEAU-DC
  quit
  seize PDC
  quit
  quit

# Via PowerShell (Windows Server 2025)
# Move-ADDirectoryServerOperationMasterRole -Identity "NOUVEAU-DC" -OperationMasterRole PDCEmulator -Force
```

---

## SECTION 5 — CHECKLIST GO / NO-GO

### Avant toute intervention sur DC

| Vérification | Commande | ✅ GO | ❌ NO-GO |
|---|---|---|---|
| Réplication OK | `repadmin /replsummary` | 0 failures | > 0 failures → attendre |
| Services actifs | `dcdiag /test:Services` | All PASS | FAIL → corriger d'abord |
| SYSVOL accessible | `Test-Path \DC\SYSVOL` | True | False → corriger |
| 2+ DC disponibles | `Get-ADDomainController -Filter *` | ≥ 2 DC online | 1 seul DC → risque critique |
| Backup récent | Veeam / Datto | < 24h | > 48h → faire backup d'abord |
| Sessions actives | `query session` | 0 sessions | Sessions actives → notifier |

---

## SECTION 6 — ESCALADE

| Situation | Action | Délai |
|---|---|---|
| Réplication bloquée > 4h | Escalade @IT-Commandare-NOC | Immédiat |
| FSMO inaccessible | Escalade @IT-Commandare-Infra | Immédiat |
| Services AD arrêtés | P2 — @IT-Commandare-NOC | 30 min |
| SYSVOL non répliqué | @IT-SysAdmin + @IT-Assistant-N3 | 2h |
| 2 DC ou plus en panne | P1 — toute l'équipe | Immédiat |

---

## RÉFÉRENCES

- Microsoft Learn — AD DS Troubleshooting
- `dcdiag /?` — Liste complète des tests disponibles
- `repadmin /?` — Toutes les options de réplication
- Windows Server 2025 : Domain Functional Level minimum requis = 2016

---
*INFRA-AD-DC_Operations_V3 — IT MSP Intelligence Platform — 2026-04-22*
