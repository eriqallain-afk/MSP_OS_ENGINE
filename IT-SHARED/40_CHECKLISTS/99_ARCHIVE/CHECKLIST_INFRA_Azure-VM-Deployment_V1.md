# CHECKLIST - Déploiement Azure VM

## Phase 1: Planification

### Dimensionnement
- [ ] CPU requis: _____ vCores
- [ ] RAM requise: _____ GB
- [ ] Storage: _____ GB (Type: Standard/Premium SSD)
- [ ] Bande passante réseau: Standard/Accéléré
- [ ] SKU déterminé: _____________

### Réseau
- [ ] VNet identifié: _____________
- [ ] Subnet: _____________
- [ ] IP statique requise: Oui/Non
- [ ] NSG rules définies
- [ ] Load balancer requis: Oui/Non

### Sécurité
- [ ] Managed Identity: System/User
- [ ] Azure AD integration requis
- [ ] Disques chiffrés (BitLocker/DM-Crypt)
- [ ] Backup policy: _____________
- [ ] Accès Just-In-Time activé

### Coûts
- [ ] Estimation mensuelle: _____ $
- [ ] Reserved Instance applicable: Oui/Non
- [ ] Auto-shutdown configuré: ___h-___h
- [ ] Ressource tags appliqués

## Phase 2: Déploiement

### Création VM

```powershell
# Variables
$ResourceGroup = "rg-prod-001"
$VMName = "vm-app-001"
$Location = "canadacentral"
$VMSize = "Standard_D2s_v3"
$VNetName = "vnet-prod-001"
$SubnetName = "subnet-app"

# Créer VM
$VM = New-AzVMConfig -VMName $VMName -VMSize $VMSize

# OS Image
Set-AzVMSourceImage -VM $VM `
    -PublisherName "MicrosoftWindowsServer" `
    -Offer "WindowsServer" `
    -Skus "2022-Datacenter" `
    -Version "latest"

# Network
$Nic = New-AzNetworkInterface `
    -Name "$VMName-nic" `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -SubnetId $SubnetId `
    -NetworkSecurityGroupId $NsgId

# Deploy
New-AzVM `
    -ResourceGroupName $ResourceGroup `
    -Location $Location `
    -VM $VM `
    -Credential $Cred
```

### Configuration post-déploiement
- [ ] VM Extensions installées
  - [ ] Azure Monitor Agent
  - [ ] Azure Security Agent
  - [ ] Custom Script Extension
- [ ] Monitoring activé
  - [ ] Boot diagnostics
  - [ ] Performance counters
  - [ ] Alertes créées
- [ ] Backup configuré
  - [ ] Recovery Services Vault
  - [ ] Backup policy assignée
  - [ ] Test restore effectué

## Phase 3: Hardening

### OS Hardening
- [ ] Windows Updates appliqués
- [ ] Firewall configuré
- [ ] Antivirus/Endpoint protection
- [ ] Local admin password rotation

### Network Security
- [ ] NSG rules minimum nécessaire
- [ ] Private endpoints si applicable
- [ ] Bastion/Jump server pour accès
- [ ] VPN/ExpressRoute configuré

### Compliance
- [ ] Azure Policy appliquées
- [ ] Regulatory compliance validée
- [ ] Logging vers Log Analytics
- [ ] Retention policies configurées

## Phase 4: Documentation

- [ ] Runbook VM créé dans KB
- [ ] Diagramme réseau mis à jour
- [ ] CMDB entry créée/mise à jour
- [ ] Contact/Owner documenté
- [ ] Disaster recovery plan documenté

## Phase 5: Validation

### Tests fonctionnels
- [ ] Application accessible
- [ ] Performance acceptable
- [ ] High availability testé (si applicable)
- [ ] Backup testé (restore partiel)

### Tests sécurité
- [ ] Vulnerability scan passé
- [ ] Accès non-autorisés bloqués
- [ ] Audit logging fonctionnel
- [ ] Conformité validée

## Templates CLI/PowerShell

### Arrêt/Démarrage
```powershell
# Arrêt
Stop-AzVM -ResourceGroupName $ResourceGroup -Name $VMName -Force

# Démarrage
Start-AzVM -ResourceGroupName $ResourceGroup -Name $VMName
```

### Resize
```powershell
$VM = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VMName
$VM.HardwareProfile.VmSize = "Standard_D4s_v3"
Update-AzVM -ResourceGroupName $ResourceGroup -VM $VM
```

### Snapshot disque
```powershell
$Disk = Get-AzDisk -ResourceGroupName $ResourceGroup -DiskName "$VMName-osdisk"
$SnapshotConfig = New-AzSnapshotConfig -SourceUri $Disk.Id -CreateOption Copy -Location $Location
New-AzSnapshot -Snapshot $SnapshotConfig -SnapshotName "$VMName-snapshot-$(Get-Date -Format yyyyMMdd)" -ResourceGroupName $ResourceGroup
```

## Troubleshooting courant

### VM ne démarre pas
1. Vérifier Boot Diagnostics
2. Vérifier Serial Console
3. Vérifier NSG/Firewall rules
4. Restore depuis snapshot au besoin

### Performance
1. Vérifier CPU/Memory metrics
2. Vérifier disk IOPS throttling
3. Considérer resize ou Premium SSD
4. Analyser Performance Diagnostics

### Coûts élevés
1. Vérifier right-sizing
2. Activer auto-shutdown
3. Considérer Reserved Instances
4. Review storage tiers
