# GUIDE - Azure Troubleshooting
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

## Méthodologie générale

### 1. Identifier le scope du problème
- Un seul utilisateur ou multiple?
- Une seule ressource ou service complet?
- Depuis quand le problème existe?
- Y a-t-il eu des changements récents?

### 2. Vérifier Service Health
```bash
# Check Azure Service Health
az rest --method get --url "https://management.azure.com/subscriptions/{subscription-id}/providers/Microsoft.ResourceHealth/events?api-version=2022-10-01"
```

Portal: https://portal.azure.com/#blade/Microsoft_Azure_Health/AzureHealthBrowseBlade/serviceIssues

### 3. Consulter Activity Logs
Portal: Resource → Activity Log
```bash
az monitor activity-log list --resource-group rg-name --start-time 2024-01-01T00:00:00Z
```

### 4. Analyser Metrics & Diagnostics
Portal: Resource → Metrics / Diagnostic settings

---

## VM ne démarre pas

### Symptômes
- VM en statut "Starting" prolongé
- VM bloquée en "Stopping"
- Boot errors dans Serial Console

### Diagnostic

**1. Vérifier Resource Health**
Portal: VM → Help → Resource health

**2. Boot Diagnostics**
Portal: VM → Boot diagnostics
```bash
az vm boot-diagnostics get-boot-log --resource-group rg-name --name vm-name
```

**3. Serial Console**
Portal: VM → Serial console

**4. Vérifier NSG/Firewall**
```bash
# Check NSG effective rules
az network nic show-effective-nsg --resource-group rg-name --name vm-nic-name
```

### Solutions courantes

**Problème: VM agent non responsive**
```powershell
# Restart VM from serial console
shutdown /r /t 0

# Ou force restart
az vm restart --resource-group rg-name --name vm-name --force
```

**Problème: Disk full (OS)**
1. Connecter via Serial Console
2. Nettoyer space:
```bash
# Windows
cleanmgr /d C:

# Linux
sudo apt-get clean
sudo journalctl --vacuum-time=3d
```

**Problème: Boot configuration corrompue**
1. Créer snapshot du OS disk
```bash
az snapshot create --resource-group rg-name --name vm-disk-snapshot --source vm-disk-name
```

2. Attacher le disk à rescue VM
3. Réparer boot config (Windows: bcdedit / Linux: grub)

**Problème: VM bloquée en "Deallocating"**
```bash
# Force stop
az vm stop --resource-group rg-name --name vm-name --skip-shutdown

# Si toujours bloqué, contact Azure Support
```

---

## Problèmes de connectivité réseau

### VM ne répond pas au ping/RDP/SSH

**1. Vérifier VM est démarrée**
```bash
az vm get-instance-view --resource-group rg-name --name vm-name --query instanceView.statuses
```

**2. Vérifier NSG rules**
Portal: VM → Networking → Inbound/Outbound rules

```bash
# Effective security rules
az network nic show-effective-nsg --ids /subscriptions/.../networkInterfaces/vm-nic
```

**3. Tester connectivité**
Portal: VM → Connection troubleshoot

```bash
# Test from Network Watcher
az network watcher test-connectivity   --source-resource vm-source-id   --dest-address [IP_CLIENTE]   --dest-port 3389
```

**4. Vérifier IP/Routes**
```bash
# Effective routes
az network nic show-effective-route-table --ids /subscriptions/.../networkInterfaces/vm-nic
```

### Solutions

**Ouvrir port RDP (3389)**
```bash
az network nsg rule create   --resource-group rg-name   --nsg-name nsg-name   --name AllowRDP   --priority 300   --source-address-prefixes 'X.X.X.X/32'   --destination-port-ranges 3389   --access Allow   --protocol Tcp
```

**Ouvrir port SSH (22)**
```bash
az network nsg rule create   --resource-group rg-name   --nsg-name nsg-name   --name AllowSSH   --priority 300   --source-address-prefixes 'X.X.X.X/32'   --destination-port-ranges 22   --access Allow   --protocol Tcp
```

**Reset network interface**
Portal: VM → Reset password → Reset configuration only

### VPN Site-to-Site ne connecte pas

**1. Vérifier VPN Gateway status**
```bash
az network vnet-gateway list --resource-group rg-name --output table
```

**2. Vérifier Local Network Gateway config**
- Public IP correcte?
- Address spaces correctes?
- BGP settings si applicable

**3. Logs diagnostics**
Portal: VPN Gateway → Diagnostic logs

**4. Shared key mismatch?**
```bash
# Reset shared key
az network vpn-connection shared-key reset   --resource-group rg-name   --connection-name connection-name
```

**5. IKE policy mismatch**
- Vérifier IKE version (v1 vs v2)
- Encryption algorithms compatibles
- DH groups compatibles

---

## Problèmes de performance

### CPU/Memory élevé

**1. Analyser metrics**
Portal: VM → Metrics
- CPU: > 80% sustained
- Memory: > 85% sustained

**2. Identifier processus**
Windows:
```powershell
# Remote PowerShell
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10
Get-Process | Sort-Object WS -Descending | Select-Object -First 10
```

Linux:
```bash
# Via Serial Console ou SSH
top -b -n 1 | head -20
ps aux --sort=-%cpu | head -10
ps aux --sort=-%mem | head -10
```

**3. Performance Diagnostics**
Portal: VM → Performance diagnostics → Run diagnostics

### Solutions

**Resize VM**
```bash
# Lister tailles disponibles
az vm list-sizes --location canadacentral --output table

# Resize (requires VM stop)
az vm deallocate --resource-group rg-name --name vm-name
az vm resize --resource-group rg-name --name vm-name --size Standard_D4s_v3
az vm start --resource-group rg-name --name vm-name
```

**Optimiser processes**
- Désactiver services inutilisés
- Analyser scheduled tasks
- Optimiser applications

### Disk IOPS Throttling

**Symptômes:**
- Disk latency élevée (>30ms)
- IOPS at limit

**1. Vérifier metrics**
Portal: Disk → Metrics
- Read/Write IOPS
- Read/Write latency
- Queue depth

**2. Solutions**

**Upgrade disk tier**
```bash
# Premium SSD → Ultra Disk
az disk update --resource-group rg-name --name disk-name --sku UltraSSD_LRS

# Standard → Premium
az disk update --resource-group rg-name --name disk-name --sku Premium_LRS
```

**Enable bursting (Premium SSD)**
Portal: Disk → Configuration → Enable on-demand bursting

**Augmenter disk size**
```bash
az disk update --resource-group rg-name --name disk-name --size-gb 512
```

---

## Problèmes Storage

### Blob storage lent

**1. Vérifier storage metrics**
Portal: Storage account → Metrics
- Transactions
- Latency (E2E latency, Server latency)

**2. Vérifier tier**
- Hot tier: Accès fréquent, coût stockage ++, coût accès +
- Cool tier: Accès rare, coût stockage +, coût accès ++
- Archive: Accès très rare, coût stockage minimum

**3. Optimisations**

**Enable CDN pour blobs publics**
```bash
az cdn endpoint create   --resource-group rg-name   --profile-name cdn-profile   --name endpoint-name   --origin storage-account.blob.core.windows.net
```

**Lifecycle management (tier automatique)**
```json
{
  "rules": [{
    "name": "MoveToArchive",
    "type": "Lifecycle",
    "definition": {
      "actions": {
        "baseBlob": {
          "tierToArchive": {
            "daysAfterModificationGreaterThan": 90
          }
        }
      },
      "filters": {
        "blobTypes": ["blockBlob"]
      }
    }
  }]
}
```

### File Share disconnections

**1. Vérifier SMB ports ouverts**
- Port 445 doit être ouvert
- Certains ISPs bloquent port 445

**2. Authentication issues**
```powershell
# Test connection
Test-NetConnection -ComputerName storage-account.file.core.windows.net -Port 445

# Mount avec credentials
$connectTestResult = Test-NetConnection -ComputerName storage-account.file.core.windows.net -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    cmd.exe /C "cmdkey /add:`"storage-account.file.core.windows.net`" /user:`"Azure\storage-account`" /pass:`"storage-account-key`""
    New-PSDrive -Name Z -PSProvider FileSystem -Root "\storage-account.file.core.windows.net\share-name" -Persist
}
```

**3. Performance tuning**
```powershell
# Windows: SMB Multichannel (Premium File shares)
Get-SmbClientConfiguration | Select EnableMultiChannel

# Enable si désactivé
Set-SmbClientConfiguration -EnableMultiChannel $true
```

---

## Problèmes d'authentification

### MFA prompts répétés

**1. Vérifier Conditional Access policies**
Portal: Azure AD → Security → Conditional Access

**2. Token lifetime**
Portal: Azure AD → Security → Session control

**3. Browser cache/cookies**
- Clear browser cache
- Try InPrivate/Incognito

**4. Reset user's MFA**
```powershell
Connect-MgGraph -Scopes "UserAuthenticationMethod.ReadWrite.All"

# List current methods
Get-MgUserAuthenticationMethod -UserId user@domain.com

# Remove et re-register
Remove-MgUserAuthenticationMethod -UserId user@domain.com -AuthenticationMethodId <id>
```

### "AADSTS" errors

**AADSTS50058: Silent sign-in failed**
- User needs to sign in interactively
- Solution: Full sign-out puis sign-in

**AADSTS50076: MFA required**
- Conditional Access enforcing MFA
- User must complete MFA enrollment

**AADSTS700016: Application not found**
- App registration missing ou deleted
- Vérifier App registrations dans Azure AD

**AADSTS7000215: Invalid client secret**
- Secret expired
- Créer nouveau secret dans App registration

---

## Coûts inattendus

### Identifier source

**1. Cost Analysis**
Portal: Cost Management → Cost analysis

Grouper par:
- Resource
- Resource type
- Location
- Tag

**2. Alertes budget**
Portal: Cost Management → Budgets
Créer alertes à 50%, 80%, 100%

### Culprits communs

**VMs running 24/7**
```bash
# Identifier VMs avec faible CPU avg
az monitor metrics list   --resource /subscriptions/.../Microsoft.Compute/virtualMachines/vm-name   --metric "Percentage CPU"   --interval PT1H   --start-time 2024-01-01T00:00:00Z   --end-time 2024-01-31T23:59:59Z

# Auto-shutdown si dev/test
az vm auto-shutdown --resource-group rg-name --name vm-name --time 1900
```

**Snapshots/Disks non supprimés**
```bash
# Lister disks unattached
az disk list --query "[?diskState=='Unattached']" --output table

# Lister snapshots anciens
az snapshot list --query "[?timeCreated<'2023-01-01']" --output table
```

**Public IPs non utilisées**
```bash
# Lister IPs non attachées
az network public-ip list --query "[?ipConfiguration==null]" --output table
```

**Bandwidth egress élevé**
- Vérifier si données transfèrent hors région
- Envisager CDN pour contenu statique
- VNet peering au lieu de VPN

---

## Outils de diagnostic

### Azure Monitor
- Metrics Explorer
- Log Analytics (KQL queries)
- Workbooks (dashboards personnalisés)
- Alerts

### Network Watcher
- Connection troubleshoot
- IP flow verify
- Next hop
- NSG diagnostics
- Packet capture
- VPN diagnostics

### Resource Graph Explorer
```kql
// VMs by power state
Resources
| where type =~ 'Microsoft.Compute/virtualMachines'
| extend powerState = tostring(properties.extended.instanceView.powerState.displayStatus)
| summarize count() by powerState

// Unattached disks
Resources
| where type =~ 'Microsoft.Compute/disks'
| where properties.diskState == 'Unattached'
| project name, resourceGroup, location, properties.diskSizeGB
```

### Azure CLI tips

**Set default subscription/RG**
```bash
az account set --subscription "Production"
az configure --defaults group=rg-prod-001 location=canadacentral
```

**Output formats**
```bash
--output table    # Tableau lisible
--output json     # JSON complet
--output tsv      # Tab-separated (pour scripts)
--output jsonc    # JSON coloré
```

**Queries JMESPath**
```bash
az vm list --query "[?powerState=='VM running'].{Name:name, RG:resourceGroup}" --output table
```

---

## Checklist troubleshooting

Avant de contacter Support Azure, vérifier:

- [ ] Service Health pour outages connus
- [ ] Activity logs pour erreurs récentes
- [ ] Resource Health de la ressource
- [ ] NSG/Firewall rules
- [ ] Metrics pour anomalies
- [ ] Diagnostic logs activés et consultés
- [ ] Changements récents (deployments, config changes)
- [ ] Problème reproductible ou intermittent?
- [ ] Scope du problème (1 user, 1 resource, global)

Support ticket doit inclure:
- Subscription ID
- Resource ID ou nom
- Timestamp précis de l'erreur
- Error messages complets
- Screenshots si applicable
- Steps to reproduce
- Impact business (sévérité)
