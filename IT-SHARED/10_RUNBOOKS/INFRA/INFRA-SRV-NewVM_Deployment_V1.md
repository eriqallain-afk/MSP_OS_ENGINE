# INFRA-SRV-NewVM_Deployment_V1
**Version :** 1.0 | **Date :** 2026-05-16 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-Commandare-Infra | @IT-Assistant-N3 | @IT-CloudMaster
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__NewVM_Deployment_V1
**Domaine :** INFRA — Provisioning VM (Hyper-V & VMware ESXi)
**Scope :** Déploiement de nouvelles VMs uniquement — pour les opérations courantes, voir INFRA-SRV-HyperV_Operations_V2.md et INFRA-SRV-VMware_Operations_V2.md

> **IMPORTANT :** Ce runbook couvre exclusivement le **provisioning initial** de nouvelles VMs.
> Ne pas utiliser pour snapshots, migrations ou opérations de maintenance.

---

## SOMMAIRE

1. [Vérification des ressources avant provisioning](#1-vérification-des-ressources-avant-provisioning)
2. [Choix de l'emplacement (Placement)](#2-choix-de-lemplacement-placement)
3. [Configuration disques par rôle de serveur](#3-configuration-disques-par-rôle-de-serveur)
4. [Sizing recommandé par rôle](#4-sizing-recommandé-par-rôle)
5. [Checklist pré-déploiement](#5-checklist-pré-déploiement)
6. [Étapes de création de la VM](#6-étapes-de-création-de-la-vm)
7. [Post-déploiement et validation](#7-post-déploiement-et-validation)

---

## 1. Vérification des ressources avant provisioning

Avant toute création de VM, valider que l'hôte cible dispose des ressources suffisantes.
Ne jamais provisionner à l'aveugle — un overcommit excessif dégrade l'ensemble du cluster.

### 1.1 Vérification CPU et RAM — Hyper-V (PowerShell)

```powershell
Start-Transcript -Path "C:\IT_LOGS\AUDIT\PreProvision_HyperV_$(Get-Date -Format 'yyyyMMdd_HHmm').log"

# Ressources hôte : CPU logiques et RAM totale
Get-VMHost | Select-Object Name,
    @{N='CPU_LogicalProc';    E={$_.LogicalProcessorCount}},
    @{N='RAM_Total_GB';       E={[math]::Round($_.MemoryCapacity/1GB,1)}} | Format-List

# RAM disponible sur l'hôte
$os = Get-CimInstance Win32_OperatingSystem
[pscustomobject]@{
    RAM_Total_GB     = [math]::Round($os.TotalVisibleMemorySize/1MB, 1)
    RAM_Free_GB      = [math]::Round($os.FreePhysicalMemory/1MB, 1)
    RAM_Used_GB      = [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory)/1MB, 1)
    RAM_Used_Pct     = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory)/$os.TotalVisibleMemorySize)*100, 1)
} | Format-List

# RAM allouée à toutes les VMs (overcommit check)
$totalAllocated = (Get-VM | Measure-Object -Property MemoryStartup -Sum).Sum / 1GB
$hostRam        = (Get-VMHost).MemoryCapacity / 1GB
$overcommitRatio = [math]::Round($totalAllocated / $hostRam, 2)

Write-Host "RAM totale allouée aux VMs : $([math]::Round($totalAllocated,1)) GB"
Write-Host "RAM hôte : $([math]::Round($hostRam,1)) GB"
Write-Host "Ratio overcommit actuel : $overcommitRatio : 1"
if ($overcommitRatio -gt 1.2) {
    Write-Warning "ATTENTION : Ratio overcommit > 1.2:1 — risque pour workloads de production !"
}

# CPU vCPU alloués vs CPUs physiques
$totalvCPU   = (Get-VM | Measure-Object -Property ProcessorCount -Sum).Sum
$physCPU     = (Get-VMHost).LogicalProcessorCount
Write-Host "vCPU totaux alloués : $totalvCPU | CPUs physiques logiques : $physCPU"
Write-Host "Ratio vCPU/pCPU : $([math]::Round($totalvCPU/$physCPU,2)):1"

Stop-Transcript
```

### 1.2 Espace disque disponible — Hyper-V (PowerShell)

```powershell
# Volumes sur l'hôte Hyper-V
Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Used -gt 0 } |
    Select-Object Name,
        @{N='Total_GB';    E={[math]::Round(($_.Used + $_.Free)/1GB, 1)}},
        @{N='Used_GB';     E={[math]::Round($_.Used/1GB, 1)}},
        @{N='Free_GB';     E={[math]::Round($_.Free/1GB, 1)}},
        @{N='Free_Pct';    E={[math]::Round($_.Free/($_.Used+$_.Free)*100, 1)}} |
    Format-Table -AutoSize

# Espace par dossier de stockage VHD/VHDX
Get-VMHost | Select-Object -ExpandProperty VirtualHardDiskPath
Get-ChildItem "V:\VMs\*" -Recurse -Include "*.vhdx","*.vhd" |
    Measure-Object -Property Length -Sum |
    Select-Object @{N='Total_VHDX_GB'; E={[math]::Round($_.Sum/1GB,1)}}
```

### 1.3 Vérification CPU, RAM et datastores — VMware ESXi (PowerCLI)

```powershell
# Connexion vCenter
Connect-VIServer -Server "vcenter.client.local" -Credential (Get-Credential)

# CPU et RAM par hôte ESXi
Get-VMHost | Select-Object Name,
    @{N='CPU_Total_GHz';   E={[math]::Round($_.CpuTotalMhz/1000, 1)}},
    @{N='CPU_Used_GHz';    E={[math]::Round($_.CpuUsageMhz/1000, 1)}},
    @{N='CPU_Free_GHz';    E={[math]::Round(($_.CpuTotalMhz - $_.CpuUsageMhz)/1000, 1)}},
    @{N='RAM_Total_GB';    E={[math]::Round($_.MemoryTotalGB, 1)}},
    @{N='RAM_Used_GB';     E={[math]::Round($_.MemoryUsageGB, 1)}},
    @{N='RAM_Free_GB';     E={[math]::Round($_.MemoryTotalGB - $_.MemoryUsageGB, 1)}},
    @{N='RAM_Used_Pct';    E={[math]::Round($_.MemoryUsageGB/$_.MemoryTotalGB*100, 1)}} |
    Format-Table -AutoSize

# Ratio overcommit RAM par hôte
Get-VMHost | ForEach-Object {
    $host = $_
    $vmsOnHost   = Get-VM -Location $host
    $allocatedGB = ($vmsOnHost | Measure-Object -Property MemoryGB -Sum).Sum
    $physGB      = $host.MemoryTotalGB
    $ratio       = [math]::Round($allocatedGB / $physGB, 2)
    [pscustomobject]@{
        Host            = $host.Name
        Allocated_GB    = [math]::Round($allocatedGB, 1)
        Physical_GB     = [math]::Round($physGB, 1)
        Overcommit      = "$ratio : 1"
        Status          = if ($ratio -gt 1.2) { "RISQUE PROD" } else { "OK" }
    }
} | Format-Table -AutoSize

# Datastores disponibles
Get-Datastore | Select-Object Name,
    @{N='Total_GB';        E={[math]::Round($_.CapacityGB, 1)}},
    @{N='Free_GB';         E={[math]::Round($_.FreeSpaceGB, 1)}},
    @{N='Used_GB';         E={[math]::Round($_.CapacityGB - $_.FreeSpaceGB, 1)}},
    @{N='Free_Pct';        E={[math]::Round($_.FreeSpaceGB/$_.CapacityGB*100, 1)}},
    @{N='Alerte';          E={if ($_.FreeSpaceGB/$_.CapacityGB -lt 0.10) {"CRITIQUE"} elseif ($_.FreeSpaceGB/$_.CapacityGB -lt 0.20) {"ALERTE"} else {"OK"}}} |
    Sort-Object Free_Pct | Format-Table -AutoSize
```

### 1.4 Seuils de décision

| Ressource | Seuil acceptable | Seuil alerte | Seuil bloquant |
|---|---|---|---|
| RAM overcommit (prod) | <= 1.0:1 | 1.1:1 | > 1.2:1 |
| RAM overcommit (dev/test) | <= 1.4:1 | 1.6:1 | > 2.0:1 |
| CPU vCPU/pCPU ratio | <= 4:1 | 6:1 | > 8:1 |
| Datastore espace libre | >= 30% | < 20% | < 10% |
| Volume Hyper-V espace libre | >= 25% | < 20% | < 10% |

> **Règle prod :** Si l'overcommit RAM dépasse 1.2:1, **ne pas provisionner** sans validation de @IT-Commandare-Infra. Documenter dans le ticket.

### 1.5 Limites physiques obligatoires (règles non négociables)

#### vCPU — Réserve hyperviseur
- **Maximum 80% des cores physiques logiques** peuvent être alloués en vCPU total sur un hôte
- Les **20% restants sont réservés** à l'hyperviseur (scheduling, I/O, gestion VMs, overhead)
- Si l'allocation totale dépasse 80% → **bloquer, ne pas provisionner**

```powershell
# Hyper-V — vérifier la limite 80%
$physCPU   = (Get-VMHost).LogicalProcessorCount
$totalvCPU = (Get-VM | Measure-Object -Property ProcessorCount -Sum).Sum
$limite80  = [math]::Floor($physCPU * 0.80)
$dispo     = $limite80 - $totalvCPU

Write-Host "Cores physiques logiques : $physCPU"
Write-Host "Limite 80% allouable     : $limite80 vCPU"
Write-Host "vCPU actuellement alloués: $totalvCPU"
if ($dispo -le 0) {
    Write-Warning "BLOQUANT — Limite 80% atteinte. Ne pas ajouter de vCPU sur cet hôte."
} else {
    Write-Host "Disponible pour nouvelles VMs : $dispo vCPU" -ForegroundColor Green
}
```

#### Disques — Ratio backup
- **Ratio minimum 1:2** — pour chaque 1 TB de données, prévoir 2 TB d'espace backup
- Ce ratio absorbe la rétention (30 jours minimum), la déduplication et les chaînes de restauration
- Pour un **repository Veeam sur le même hôte** : réserver un volume/datastore dédié, jamais sur le même volume que les VMs

| Données totales | Espace backup minimum | Recommandé (rétention 60j) |
|---|---|---|
| 500 GB | 1 TB | 1.5 TB |
| 1 TB | 2 TB | 3 TB |
| 2 TB | 4 TB | 6 TB |
| 5 TB | 10 TB | 15 TB |

> ⚠️ Si les ressources physiques (vCPU > 80% ou espace backup insuffisant) ne permettent pas le déploiement, **escalader à @IT-Commandare-Infra avant de continuer**.

---

## 2. Choix de l'emplacement (Placement)

### 2.1 Règles d'anti-affinité obligatoires

> Ces règles sont **non négociables** pour les environnements de production MSP.

| Règle | Description | Action si violation |
|---|---|---|
| **RULE-01** | DC et DC02 JAMAIS sur le même hôte physique ESXi ou Hyper-V | Bloquer — escalader @IT-Commandare-Infra |
| **RULE-02** | SQL + FS + RDS sur le même hôte physique = risque latence I/O | Documenter dans le ticket, alerter le client, valider avec @IT-Commandare-Infra |
| **RULE-03** | Veeam Proxy/Repository sur hôte séparé des VMs protégées si possible | Recommandé — documenter si impossible |
| **RULE-04** | PAW (Privileged Access Workstation) sur VLAN admin dédié, hôte documenté | Obligatoire |

### 2.2 Vérifier la répartition actuelle des VMs par hôte — Hyper-V

```powershell
# Liste VMs par statut et hôte (dans un cluster Hyper-V)
Get-VM | Select-Object Name, State,
    @{N='RAM_GB';    E={[math]::Round($_.MemoryStartup/1GB,1)}},
    @{N='vCPU';      E={$_.ProcessorCount}},
    ComputerName |
    Sort-Object ComputerName, Name | Format-Table -AutoSize

# Identifier les DCs présents sur cet hôte
Get-VM | Where-Object { $_.Name -match "DC|CTRL|DOM" } |
    Select-Object Name, State, ComputerName | Format-Table -AutoSize
```

### 2.3 Vérifier la répartition actuelle des VMs par hôte — VMware PowerCLI

```powershell
# VMs par hôte ESXi avec ressources
Get-VMHost | ForEach-Object {
    $h = $_
    Get-VM -Location $h | Select-Object Name,
        PowerState,
        NumCpu,
        @{N='RAM_GB';    E={$_.MemoryGB}},
        @{N='ESXi_Host'; E={$h.Name}}
} | Sort-Object ESXi_Host, Name | Format-Table -AutoSize

# Identifier les DCs par hôte (critique : anti-affinité DC/DC02)
Get-VMHost | ForEach-Object {
    $h = $_
    $dcs = Get-VM -Location $h | Where-Object { $_.Name -match "DC|CTRL|DOM" }
    if ($dcs) {
        Write-Host "Hôte : $($h.Name)" -ForegroundColor Yellow
        $dcs | Select-Object Name, PowerState | Format-Table
    }
}
```

### 2.4 Règles DRS anti-affinité VMware (si vCenter disponible)

Si le client dispose de vCenter avec DRS activé, configurer des règles d'anti-affinité :

```powershell
# Créer une règle anti-affinité DC/DC02 (les deux ne doivent jamais être sur le même hôte)
$cluster = Get-Cluster -Name "Cluster-Production"
$dc1     = Get-VM -Name "SRV-DC01"
$dc2     = Get-VM -Name "SRV-DC02"

New-DrsVMAntiAffinityRule -Cluster $cluster `
    -Name "AntiAffinity-DC01-DC02" `
    -VM $dc1,$dc2 `
    -Enabled $true

# Vérifier les règles DRS existantes
Get-DrsRule -Cluster $cluster | Format-Table Name, Type, Enabled, VMIds
```

> **Interface vCenter :** Menu → Hôtes et clusters → [Cluster] → Configurer → Configuration VM/Hôte → Règles VM → Ajouter → Type : "Séparer les machines virtuelles"

---

## 3. Configuration disques par rôle de serveur

### 3.1 Tableau récapitulatif

| Rôle | Nb disques | Disque | Taille recommandée | Système de fichiers | Taille allocation | Notes |
|---|---|---|---|---|---|---|
| **AD/DC** | 2 | C: OS + SYSVOL | 80 GB | NTFS | 4 KB | Boot/OS séparé des logs AD |
| **AD/DC** | 2 | D: NTDS + Logs AD | 40–80 GB | NTFS | 4 KB | `%SystemRoot%\NTDS` et journaux AD |
| **File Server** | 2 | C: OS | 80 GB | NTFS | 4 KB | OS uniquement |
| **File Server** | 2 | D: Data | Selon client | ReFS | Auto | ReFS recommandé pour intégrité données |
| **SQL Server** | 5 | C: OS | 100 GB | NTFS | 4 KB | OS + SQL binaires |
| **SQL Server** | 5 | D: SQL Data (.mdf) | Selon DB | NTFS | **64 KB** | Performances I/O critiques |
| **SQL Server** | 5 | E: SQL Logs (.ldf) | 30–50% de D: | NTFS | **64 KB** | Journaux de transactions |
| **SQL Server** | 5 | F: TempDB | 20–40 GB | NTFS | **64 KB** | Fichiers TempDB — SSD si possible |
| **SQL Server** | 5 | G: Backups SQL | Selon rétention | NTFS | 4 KB | Sauvegardes locales SQL |
| **RDS/Terminal Server** | 2 | C: OS | 100 GB | NTFS | 4 KB | OS + applications |
| **RDS/Terminal Server** | 2 | D: Profiles/Data | 100–200 GB | NTFS | 4 KB | Profils utilisateurs, FSLogix |
| **Veeam Repository** | 1+ | Repo | Selon rétention | **ReFS (Windows)** ou **XFS (Linux)** | Auto | JAMAIS NTFS — déduplication/compression |
| **PAW** | 1–2 | C: OS | 128 GB | NTFS + BitLocker | 4 KB | VM isolée, VLAN admin, pas de snapshots fréquents |

### 3.2 Détail AD/DC

- **Disque 1 (C:)** : OS Windows Server, SYSVOL, NETLOGON. NTFS 4 KB.
- **Disque 2 (D:)** : Base NTDS (`C:\Windows\NTDS` → déplacer vers D:), journaux AD. NTFS 4 KB.
- Déplacer NTDS après promotion : `ntdsutil` → `activate instance ntds` → `files` → `move db to D:\NTDS`
- Ne jamais mettre NTDS sur le même disque que le fichier de page Windows.

### 3.3 Détail SQL Server — allocation 64 KB obligatoire

> L'allocation d'unité 64 KB pour les volumes SQL Data, Logs et TempDB est une **best practice Microsoft** critique pour les performances I/O SQL Server. Ne pas utiliser la valeur par défaut 4 KB.

```powershell
# Formater un disque SQL avec allocation 64 KB (PowerShell — avant initialisation)
# Exemple pour le disque SQL Data (D:)
$disk = Get-Disk | Where-Object { $_.OperationalStatus -eq "Offline" -and $_.Size -gt 50GB } | Select-Object -First 1
$disk | Initialize-Disk -PartitionStyle GPT -PassThru |
    New-Partition -AssignDriveLetter -UseMaximumSize |
    Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel "SQL_DATA" -Confirm:$false

# Répéter pour E: (SQL_LOGS), F: (SQL_TEMPDB) avec AllocationUnitSize 65536
# Pour G: (SQL_BACKUPS) : AllocationUnitSize 4096 (standard)
```

### 3.4 Détail Veeam Backup Repository

> **JAMAIS NTFS pour un repository Veeam.** NTFS ne supporte pas la déduplication et compression block-level efficacement.

- **Windows Repository** : ReFS (Windows Server 2016+) — active la Fast Clone et la déduplication Veeam
- **Linux Repository** : XFS avec `-m reflink=1` pour Fast Clone, ou ext4 en fallback
- **Si Veeam en VM** : utiliser un disque en **passthrough** (Hyper-V) ou **RDM Raw Device Mapping** (VMware) pour les performances maximales — éviter les VHDX/VMDK imbriqués pour le repository principal

```powershell
# Formater un disque en ReFS pour Veeam Repository (Windows)
$disk = Get-Disk | Where-Object { $_.OperationalStatus -eq "Offline" } | Select-Object -First 1
$disk | Initialize-Disk -PartitionStyle GPT -PassThru |
    New-Partition -AssignDriveLetter -UseMaximumSize |
    Format-Volume -FileSystem ReFS -NewFileSystemLabel "VEEAM_REPO" -Confirm:$false
```

### 3.5 Détail PAW (Privileged Access Workstation)

- VM isolée sur **VLAN Admin dédié** (ex. VLAN 999 ou VLAN selon standard client)
- **Pas d'accès Internet** direct — proxy strict si nécessaire
- **BitLocker** activé sur le disque OS (C:)
- **Snapshots fréquents déconseillés** — un snapshot peut capturer des credentials en mémoire
- Accès restreint : seuls les comptes admin de niveau 0 peuvent se connecter
- Documenter dans CMDB (IT-AssetMaster) avec niveau de criticité élevé

---

## 4. Sizing recommandé par rôle

| Rôle | vCPU min | vCPU recommandé | RAM min | RAM recommandée | OS Disk | Notes |
|---|---|---|---|---|---|---|
| **AD/DC** (< 500 users) | 2 | 4 | 4 GB | 8 GB | 80 GB | Redondant DC02 obligatoire |
| **AD/DC** (500–2000 users) | 4 | 4–8 | 8 GB | 16 GB | 80 GB | |
| **File Server** | 2 | 4 | 4 GB | 8 GB | 80 GB | Data séparé |
| **SQL Server** (small) | 4 | 4–8 | 8 GB | 16–32 GB | 100 GB | +4 disques |
| **SQL Server** (medium) | 8 | 8–16 | 32 GB | 64 GB | 100 GB | SSD pour TempDB |
| **RDS** (< 20 users) | 4 | 4 | 8 GB | 16 GB | 100 GB | +4 GB/5 users |
| **RDS** (20–50 users) | 8 | 8 | 16 GB | 32 GB | 100 GB | |
| **Veeam Proxy** | 4 | 4–8 | 8 GB | 16 GB | 100 GB | Réseau 10 GbE recommandé |
| **Veeam Repository** | 4 | 4 | 8 GB | 16 GB | 80 GB | Disques data séparés |
| **PAW** | 2 | 2 | 4 GB | 8 GB | 128 GB | Pas de surprovisioning |
| **Print Server** | 2 | 2 | 4 GB | 4 GB | 80 GB | |
| **WSUS/MDT** | 4 | 4 | 8 GB | 8 GB | 500 GB | Grand disque pour patches |

> **Règle générale :** Toujours provisionner avec la valeur "recommandée" pour les VMs de production. La valeur "min" est réservée aux environnements de dev/test.

---

## 5. Checklist pré-déploiement

Compléter **intégralement** avant de créer la VM. Copier dans le ticket client.

### 5.1 Identification de la VM

- [ ] **Nom de la VM** conforme à la convention de nommage client (ex. `CLI-SRV-DC02`, `CLI-SRV-SQL01`)
  - Format recommandé : `[CODE_CLIENT]-SRV-[ROLE][NUMERO]`
  - Pas d'espaces, pas de caractères spéciaux, max 15 caractères (limite NetBIOS)
- [ ] Nom DNS vérifié et disponible (pas de conflit dans AD)
- [ ] **Rôle du serveur** documenté dans le ticket
- [ ] **Client et site** identifiés (site principal / DC02 / site secondaire)
- [ ] OS cible sélectionné (Windows Server 2022 Standard / Datacenter / Core)

### 5.2 Réseau

- [ ] **IP statique** réservée dans le DNS/DHCP ou IPAM (ne pas utiliser DHCP pour les serveurs)
- [ ] **VLAN correct** identifié et validé avec @IT-NetworkMaster si nécessaire
  - Servers VLAN : ___
  - Admin/PAW VLAN : ___ (si applicable)
- [ ] Passerelle par défaut confirmée
- [ ] DNS primaire et secondaire configurés (pointent vers les DCs internes)
- [ ] Règles firewall/ACL vérifiées si VLAN segmenté

### 5.3 Ressources et placement

- [ ] Hôte cible sélectionné (vérification section 1 complétée)
- [ ] Overcommit RAM <= 1.2:1 après ajout de cette VM
- [ ] **Règle anti-affinité RULE-01 vérifiée** (DC et DC02 sur hôtes différents)
- [ ] Datastore/Volume cible sélectionné avec >= 30% d'espace libre après déploiement
- [ ] Configuration disques validée selon le rôle (section 3)

### 5.4 Backup et sécurité

- [ ] **Backup policy planifiée** avant mise en production (Veeam job existant ou à créer)
- [ ] Veeam job configuré — fréquence : ___ | rétention : ___ jours
- [ ] **Antivirus exclusions** planifiées selon le rôle :
  - SQL Server : exclure les dossiers `.mdf`, `.ldf`, `.ndf`, `TempDB`
  - AD/DC : exclure `%SystemRoot%\NTDS`, `SYSVOL`
  - Veeam : exclure le dossier repository
- [ ] Compte de service ou admin local documenté dans le gestionnaire de mots de passe MSP
- [ ] BitLocker prévu si PAW ou données sensibles

### 5.5 Validation finale

- [ ] Ticket client créé/mis à jour avec toutes les infos ci-dessus
- [ ] Fenêtre de maintenance convenue avec le client si impact possible
- [ ] Validation @IT-Commandare-Infra si overcommit borderline ou règle anti-affinité à documenter

---

## 6. Étapes de création de la VM

### 6.1 Création VM — Hyper-V (PowerShell)

```powershell
# ============================================================
# VARIABLES — adapter selon le client et le rôle
# ============================================================
$VMName       = "CLI-SRV-DC02"
$VMPath       = "V:\VMs"           # Chemin de stockage des VMs
$VHDPath      = "V:\VHDs"          # Chemin des disques VHDX
$SwitchName   = "vSwitch-LAN"      # Switch virtuel Hyper-V
$Generation   = 2                  # Gen2 pour Windows Server 2016+
$RAM_GB       = 8
$vCPU         = 4
$OSDisk_GB    = 80
$DataDisk_GB  = 60                 # Disque D: — adapter selon rôle
$ISOPath      = "D:\ISO\WS2022.iso"

# ============================================================
# ÉTAPE 1 — Créer la VM
# ============================================================
New-VM -Name $VMName `
       -Path $VMPath `
       -Generation $Generation `
       -MemoryStartupBytes ($RAM_GB * 1GB) `
       -SwitchName $SwitchName `
       -NoVHD

# ============================================================
# ÉTAPE 2 — Configurer CPU
# ============================================================
Set-VMProcessor -VMName $VMName -Count $vCPU

# ============================================================
# ÉTAPE 3 — Désactiver la mémoire dynamique pour production
# ============================================================
Set-VMMemory -VMName $VMName `
             -DynamicMemoryEnabled $false `
             -StartupBytes ($RAM_GB * 1GB)

# ============================================================
# ÉTAPE 4 — Créer et attacher le disque OS (C:)
# ============================================================
$OSDiskPath = "$VHDPath\$VMName\$VMName`_C_OS.vhdx"
New-Item -ItemType Directory -Path "$VHDPath\$VMName" -Force | Out-Null
New-VHD -Path $OSDiskPath -SizeBytes ($OSDisk_GB * 1GB) -Dynamic
Add-VMHardDiskDrive -VMName $VMName -Path $OSDiskPath -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 0

# ============================================================
# ÉTAPE 5 — Créer et attacher le disque Data (D:)
# ============================================================
$DataDiskPath = "$VHDPath\$VMName\$VMName`_D_DATA.vhdx"
New-VHD -Path $DataDiskPath -SizeBytes ($DataDisk_GB * 1GB) -Dynamic
Add-VMHardDiskDrive -VMName $VMName -Path $DataDiskPath -ControllerType SCSI -ControllerNumber 0 -ControllerLocation 1

# ============================================================
# ÉTAPE 6 — Attacher l'ISO d'installation
# ============================================================
Add-VMDvdDrive -VMName $VMName
Set-VMDvdDrive -VMName $VMName -Path $ISOPath

# ============================================================
# ÉTAPE 7 — Configurer le boot order (DVD en premier)
# ============================================================
$DVDDrive  = Get-VMDvdDrive -VMName $VMName
$HardDrive = Get-VMHardDiskDrive -VMName $VMName | Select-Object -First 1
Set-VMFirmware -VMName $VMName -BootOrder $DVDDrive, $HardDrive

# ============================================================
# ÉTAPE 8 — Activer Secure Boot (Gen2 uniquement)
# ============================================================
Set-VMFirmware -VMName $VMName -EnableSecureBoot On -SecureBootTemplate "MicrosoftWindows"

# ============================================================
# ÉTAPE 9 — Démarrer la VM
# ============================================================
Start-VM -Name $VMName
Write-Host "VM $VMName démarrée — connexion via Hyper-V Manager ou vmconnect.exe" -ForegroundColor Green
```

> **Pour les disques SQL supplémentaires (E:, F:, G:)**, répéter l'ÉTAPE 5 avec les tailles et labels appropriés, puis formater depuis Windows avec AllocationUnitSize 65536 (section 3.3).

### 6.2 Création VM — VMware ESXi (Interface vCenter)

```
1. vSphere Client → Menu → Hôtes et clusters
2. Clic droit sur l'hôte cible → Nouvelle machine virtuelle → Créer une nouvelle VM
3. Sélectionner le dossier de destination → Suivant
4. Sélectionner l'hôte ESXi cible (vérifier anti-affinité)
5. Sélectionner le datastore (vérifier espace libre >= 30%)
6. Compatibilité : ESXi 7.0 (ou version hôte) → Suivant
7. Système d'exploitation invité : Windows Server 2022
8. Matériel virtuel :
   - CPU : [valeur selon sizing section 4]
   - RAM : [valeur] GB — décocher "Réserver toute la mémoire" SAUF prod critique
   - Disque dur : [taille OS] GB — Thin provisioning (dev) ou Thick eager-zeroed (prod SQL/DC)
   - Contrôleur SCSI : VMware Paravirtual (PVSCSI) — meilleures performances
   - Adaptateur réseau : VMXNET3 — sélectionner le port group VLAN correct
9. Ajouter des disques supplémentaires : Ajouter un périphérique → Disque dur → [taille]
   - Répéter pour chaque disque (D:, E:, F:, G: selon rôle)
10. CD/DVD : ISO dans datastore — cocher "Connecter au démarrage"
11. Terminer → Mettre sous tension la VM
```

### 6.3 Création VM — VMware ESXi (PowerCLI)

```powershell
# ============================================================
# VARIABLES
# ============================================================
$VIServer     = "vcenter.client.local"
$VMName       = "CLI-SRV-DC02"
$ESXiHost     = "esxi02.client.local"   # Hôte cible (anti-affinité DC01 sur esxi01)
$Datastore    = "DS-SSD-PROD-02"
$Network      = "PG-VLAN10-Servers"    # Port group vSphere
$Template     = $null                   # Null = création from scratch
$NumCPU       = 4
$MemGB        = 8
$OSDiskGB     = 80
$DataDiskGB   = 60

Connect-VIServer -Server $VIServer -Credential (Get-Credential)

# ============================================================
# ÉTAPE 1 — Créer la VM
# ============================================================
$vmHost    = Get-VMHost -Name $ESXiHost
$ds        = Get-Datastore -Name $Datastore
$portGroup = Get-VirtualPortGroup -Name $Network -VMHost $vmHost

$newVM = New-VM -Name $VMName `
                -VMHost $vmHost `
                -Datastore $ds `
                -NumCpu $NumCPU `
                -MemoryGB $MemGB `
                -DiskGB $OSDiskGB `
                -DiskStorageFormat EagerZeroedThick `
                -NetworkName $portGroup.Name `
                -GuestId "windows2019srvNext_64Guest" `
                -CD

# ============================================================
# ÉTAPE 2 — Ajouter disque Data (D:)
# ============================================================
New-HardDisk -VM $newVM `
             -CapacityGB $DataDiskGB `
             -StorageFormat EagerZeroedThick `
             -Datastore $ds

# ============================================================
# ÉTAPE 3 — Changer contrôleur SCSI en PVSCSI
# ============================================================
$scsiCtrl = Get-ScsiController -VM $newVM
Set-ScsiController -ScsiController $scsiCtrl -Type ParaVirtual

# ============================================================
# ÉTAPE 4 — Attacher ISO et démarrer
# ============================================================
$isoDS   = Get-Datastore -Name "DS-ISO"
$cdDrive = Get-CDDrive -VM $newVM
Set-CDDrive -CD $cdDrive `
            -IsoPath "[$($isoDS.Name)] ISOs/WS2022.iso" `
            -StartConnected $true `
            -Confirm:$false

Start-VM -VM $newVM
Write-Host "VM $VMName démarrée sur $ESXiHost" -ForegroundColor Green

Disconnect-VIServer -Server $VIServer -Confirm:$false
```

---

## 7. Post-déploiement et validation

### 7.1 Configuration OS de base (après installation Windows)

```powershell
# Renommer le serveur (si pas fait pendant l'installation)
Rename-Computer -NewName "CLI-SRV-DC02" -Restart

# Configurer l'IP statique (adapter selon le client)
$InterfaceAlias = (Get-NetAdapter | Where-Object { $_.Status -eq "Up" }).Name
New-NetIPAddress -InterfaceAlias $InterfaceAlias `
                 -IPAddress "192.168.10.12" `
                 -PrefixLength 24 `
                 -DefaultGateway "192.168.10.1"
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias `
                           -ServerAddresses ("192.168.10.10","192.168.10.11")

# Initialiser et formater les disques supplémentaires
# (répéter pour chaque disque selon les lettres et rôles définis section 3)
$disks = Get-Disk | Where-Object { $_.PartitionStyle -eq "RAW" }
foreach ($disk in $disks) {
    $disk | Initialize-Disk -PartitionStyle GPT -PassThru |
            New-Partition -AssignDriveLetter -UseMaximumSize |
            Format-Volume -FileSystem NTFS -AllocationUnitSize 4096 -Confirm:$false
    Write-Host "Disque $($disk.Number) initialisé et formaté"
}
# RAPPEL : Pour SQL Data/Logs/TempDB — utiliser AllocationUnitSize 65536 (section 3.3)
```

### 7.2 Jonction au domaine Active Directory

```powershell
# Joindre au domaine
$credential = Get-Credential -Message "Entrer les credentials admin du domaine"
Add-Computer -DomainName "client.local" `
             -Credential $credential `
             -OUPath "OU=Servers,OU=CLI,DC=client,DC=local" `
             -Restart -Force

# Vérifier après redémarrage
(Get-WmiObject Win32_ComputerSystem).Domain
```

### 7.3 Configuration monitoring RMM

```
1. Déployer l'agent RMM sur la VM (procédure selon plateforme MSP)
   - Connectrix / N-central : installer l'agent MSI via GPO ou déploiement manuel
   - Datto RMM / Atera / Syncro : suivre la procédure d'onboarding agent propre au client
2. Vérifier que la VM apparaît dans la console RMM du client sous le bon site
3. Appliquer le profil de monitoring standard selon le rôle :
   - DC : surveiller services AD, DNS, SYSVOL, DFSR, temps Kerberos
   - SQL : surveiller services SQL Agent, SQL Server, espace disques, backups
   - FS : surveiller espace disques D:, sessions DFS si applicable
   - RDS : surveiller sessions actives, CPU, mémoire, espace profils
4. Configurer les seuils d'alerte selon les standards MSP (CPU > 90%, RAM > 85%, disk < 15%)
5. Vérifier la remontée des alertes dans la console MSP
```

### 7.4 Validation du backup J+1

```
1. Vérifier que la VM est incluse dans un job Veeam Backup & Replication
   - Job existant avec inclusion automatique du cluster → confirmer la détection
   - Nouveau job si nécessaire → créer avant la mise en production
2. Lancer un backup manuel ad-hoc immédiatement après déploiement :
   Veeam Console → Jobs → [Job client] → Démarrer → Attendre la fin
3. Vérifier le rapport de backup : statut SUCCESS, taille cohérente
4. J+1 : vérifier le backup automatique planifié → statut SUCCESS dans les rapports Veeam
5. Tester la restaurabilité (recommandé) :
   - Veeam SureBackup si disponible, ou
   - Instant VM Recovery sur un réseau isolé → vérifier démarrage OS → supprimer la VM de test
6. Documenter dans le ticket : date premier backup, job associé, rétention
```

### 7.5 Checklist de validation finale

- [ ] VM démarre correctement et répond au ping depuis un autre serveur du réseau
- [ ] Jonction domaine confirmée (`echo %USERDOMAIN%` depuis une session admin)
- [ ] IP statique configurée et DNS résout le nom de la VM
- [ ] Tous les disques supplémentaires visibles et formatés avec la bonne lettre de lecteur
- [ ] Monitoring RMM actif — VM visible dans la console client
- [ ] Backup J+1 confirmé avec statut SUCCESS
- [ ] Antivirus installé et exclusions configurées selon le rôle
- [ ] Ticket client mis à jour avec toutes les informations de la VM (IP, hôte ESXi/HyperV, datastore, disques)
- [ ] CMDB mise à jour dans IT-AssetMaster (nom, rôle, IP, hôte, client, site)
- [ ] Validation client obtenue si déploiement en production

---

## RÉFÉRENCES ET RUNBOOKS ASSOCIÉS

| Runbook | Usage |
|---|---|
| `INFRA-SRV-HyperV_Operations_V2.md` | Snapshots, migration, opérations courantes Hyper-V |
| `INFRA-SRV-VMware_Operations_V2.md` | Opérations courantes VMware/vCenter |
| `INFRA-AD-DC_Operations_V3.md` | Promotion DC, gestion Active Directory |
| `INFRA-SRV-SQL_PrePost_Validation_V2.md` | Validation pré/post pour serveurs SQL |
| `INFRA-BACKUP-Veeam_Operations_V2.md` | Configuration jobs Veeam, restauration |
| `INFRA-SRV-RDS_Operations_V2.md` | Déploiement et gestion RDS/Terminal Server |

---

*INFRA-SRV-NewVM_Deployment_V1 — Version 1.0 — 2026-05-16 — MSP Intelligence AI*
