# RUNBOOK — ARCHITECTURE CLOUD MSP
**Agents :** @IT-CloudMaster, IT-MaintenanceMaster, IT-SysAdmin
**Scope :** M365, Azure, AWS, GCP — architecture et gouvernance

---

## 1. M365 — ARCHITECTURE DE BASE

**Composants standard MSP :**
- Exchange Online (mail, calendrier, contacts)
- SharePoint Online (intranet, documents partages)
- OneDrive (fichiers personnels synchronises)
- Microsoft Teams (communication, collaboration)
- Intune (MDM/MAM — appareils manages)
- Entra ID (identite, MFA, Conditional Access)

**Standards MSP obligatoires :**
- [ ] MFA active pour TOUS les comptes
- [ ] Conditional Access configure (bloquer hors pays si applicable)
- [ ] Licences Business Premium minimum (Intune + Defender inclus)
- [ ] Backup M365 configure (Keepit, Datto SaaS ou Veeam)
- [ ] DMARC/DKIM/SPF configures sur le domaine

---

## 2. AZURE — COMPOSANTS TYPIQUES

```powershell
Connect-AzAccount
Get-AzSubscription | Select-Object Name, State, SubscriptionId
Get-AzResourceGroup | Select-Object ResourceGroupName, Location, ProvisioningState
Get-AzVM | Select-Object Name, PowerState, Location | Format-Table
```

**Ressources communes :**
- Azure Virtual Machines (IaaS serveurs)
- Entra ID (identite hybride On-Prem + Cloud)
- Azure Backup (backup VMs et fichiers)
- Azure Monitor + Log Analytics (supervision)
- Microsoft Defender for Cloud (securite posture)

---

## 3. GOUVERNANCE CLOUD

- [ ] Resource Groups organises par environnement (Prod/Dev/Test)
- [ ] Tags appliques (Client, Environnement, Owner, CostCenter)
- [ ] Budget Alerts configurees dans Azure Cost Management
- [ ] Acces RBAC configure (Least Privilege)
- [ ] Audit Logs actives (Entra ID + Azure Activity Log)
- [ ] Backup policy appliquee a toutes les VMs critiques
