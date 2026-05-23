# RÉFÉRENCE: Portails d'Administration Cloud

## Guide de navigation - Tous les centres d'administration

---

## 🔷 MICROSOFT AZURE

### Portail principal
**Azure Portal:** https://portal.azure.com
- Hub centralisé pour tous les services Azure
- Dashboards personnalisables
- Cloud Shell intégré (PowerShell/Bash)
- Azure Monitor et diagnostics

### Portails spécialisés

**Azure Active Directory Admin Center**  
https://aad.portal.azure.com
- Gestion utilisateurs et groupes
- Conditional Access
- Enterprise Applications
- App Registrations
- Privileged Identity Management (PIM)
- Security (MFA, SSPR, Identity Protection)

**Azure DevOps**  
https://dev.azure.com
- Repos Git
- Pipelines CI/CD
- Boards (Azure Boards)
- Test Plans
- Artifacts

**Azure Cost Management**  
https://portal.azure.com/#view/Microsoft_Azure_CostManagement
- Analyse des coûts
- Budgets et alertes
- Recommandations d'optimisation
- Exportation de données

**Azure Compliance Manager**  
https://portal.azure.com/#view/Microsoft_Azure_Policy
- Politiques Azure
- Blueprints
- Conformité réglementaire
- Security Center

---

## 📧 MICROSOFT 365

### Portails principaux

**Microsoft 365 Admin Center**  
https://admin.microsoft.com
- **Dashboard:** Vue d'ensemble santé services, messages centre
- **Users:** Gestion utilisateurs, licences, groupes
- **Teams & groups:** Microsoft 365 Groups, Teams
- **Settings:** Organisation settings, domains, security & privacy
- **Billing:** Subscriptions, licences, facturation
- **Support:** Créer tickets, knowledge base
- **Health:** Service health, message center, reports

**Exchange Admin Center (EAC)**  
https://admin.exchange.microsoft.com
- **Recipients:** Mailboxes, groups, resources, contacts
- **Mail flow:** Rules, connectors, accepted domains
- **Protection:** Anti-malware, anti-spam, quarantine
- **Organization:** Sharing, retention policies
- **Permissions:** Admin roles, role groups
- **Migration:** Mailbox migrations

**SharePoint Admin Center**  
https://tenant-admin.sharepoint.com
- **Sites:** Active sites, deleted sites
- **Policies:** Sharing, access control, DLP
- **Content:** Content types, term store
- **Migration:** Migration center, SharePoint migration tool
- **Settings:** Notifications, classic features
- **More features:** Search, User profiles, BCS, Records mgmt

**OneDrive Admin Center**  
https://admin.onedrive.com
- Intégré dans SharePoint Admin Center
- **Settings:** Storage, sync, sharing, notifications
- **Device access:** Control access par device
- **Compliance:** Retention policies

**Microsoft Teams Admin Center**  
https://admin.teams.microsoft.com
- **Users:** Manage users, guest access
- **Teams:** Manage teams, policies
- **Meetings:** Meeting policies, conference bridges
- **Voice:** Calling policies, phone numbers
- **Messaging:** Messaging policies
- **Org-wide settings:** External access, guest access, Teams settings
- **Analytics & reports:** Usage reports, call quality

---

## 🛡️ SÉCURITÉ & COMPLIANCE

**Microsoft 365 Defender**  
https://security.microsoft.com
- **Incidents & alerts:** Unified incident queue
- **Hunting:** Advanced hunting (KQL queries)
- **Threat analytics:** Emerging threats
- **Secure Score:** Security posture
- **Email & collaboration:** Policies, investigations
- **Endpoints:** Devices, vulnerability management
- **Cloud apps:** MCAS integration

**Microsoft Purview Compliance Portal**  
https://compliance.microsoft.com
- **Data classification:** Sensitive info types, trainable classifiers
- **Data loss prevention (DLP):** Policies, incidents
- **Information protection:** Sensitivity labels, encryption
- **Records management:** Retention policies, file plans
- **eDiscovery:** Cases, searches, holds
- **Audit:** Audit log search, retention policies
- **Insider risk:** Insider risk management
- **Compliance Manager:** Compliance score, assessments

**Azure Security Center**  
https://portal.azure.com/#view/Microsoft_Azure_Security
- Security posture management
- Threat protection
- Regulatory compliance
- Recommendations

**Microsoft Sentinel (SIEM)**  
https://portal.azure.com/#view/HubsExtension/BrowseResource/resourceType/microsoft.securityinsightsarg%2Fsentinel
- Workspace management
- Data connectors
- Analytics rules
- Hunting queries
- Workbooks

---

## 📱 DEVICE MANAGEMENT

**Microsoft Intune Admin Center**  
https://intune.microsoft.com
- **Dashboard:** Device compliance, enrollment
- **Devices:** All devices, configuration profiles, compliance policies
- **Apps:** App management, app protection policies
- **Users:** User management
- **Groups:** Group management
- **Enrollment:** Windows, iOS, Android, macOS
- **Device compliance:** Policies, notifications
- **Device configuration:** Profiles, scripts
- **Endpoint security:** Antivirus, disk encryption, firewall

**Endpoint Manager (Unified)**  
https://endpoint.microsoft.com
- Combine Intune + Configuration Manager
- Co-management

---

## 🔧 OUTILS D'ADMINISTRATION

**PowerShell Modules à connaître:**
```powershell
# Azure
Install-Module -Name Az
Connect-AzAccount

# Azure AD
Install-Module -Name AzureAD
Connect-AzureAD

# Exchange Online
Install-Module -Name ExchangeOnlineManagement
Connect-ExchangeOnline

# SharePoint Online
Install-Module -Name Microsoft.Online.SharePoint.PowerShell
Connect-SPOService -Url https://tenant-admin.sharepoint.com

# Teams
Install-Module -Name MicrosoftTeams
Connect-MicrosoftTeams

# Security & Compliance
Connect-IPPSSession

# Microsoft Graph
Install-Module -Name Microsoft.Graph
Connect-MgGraph
```

**Azure CLI:**
```bash
# Installation
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login
az login
az account set --subscription "subscription-name"

# Common commands
az vm list
az network vnet list
az storage account list
```

---

## 🌐 GOOGLE WORKSPACE

### Portails principaux

**Google Admin Console**  
https://admin.google.com
- **Dashboard:** Service status, alerts
- **Users:** User management, organizational units
- **Groups:** Group management, settings
- **Apps:** Google Workspace apps, web and mobile apps
- **Devices:** Mobile devices, Chrome management
- **Security:** 2-Step verification, password management, API controls
- **Reporting:** Audit logs, usage reports
- **Billing:** Subscriptions, licenses

**Google Workspace Admin Sections:**

1. **Directory**
   - Users: Add, edit, delete, suspend users
   - Organizational units: Structure organization
   - Groups: Create, manage groups
   - Building and resources: Meeting rooms, resources

2. **Apps → Google Workspace**
   - Gmail: Settings, user settings, compliance
   - Calendar: Sharing settings, resources
   - Drive and Docs: Sharing settings, features
   - Meet: Settings, recording
   - Chat: Settings, history

3. **Security**
   - Overview: Security checkup, security center
   - Authentication: 2-Step verification, password policy
   - Data protection: Data regions, DLP rules
   - Access and data control: API controls, sharing settings

4. **Reporting**
   - Audit log: Admin, drive, login, mobile, token
   - Reports: Aggregate reports, app reports
   - Highlights: Key metrics

5. **Devices**
   - Mobile devices: Manage, approve, block
   - Endpoints: Chrome management, deployment
   - Networks: Printer management

**Google Cloud Console (GCP)**  
https://console.cloud.google.com
- Projets GCP (si utilisé en plus de Workspace)
- IAM & Admin
- Compute Engine, Cloud Storage, etc.
- Billing

---

## ☁️ AMAZON WEB SERVICES (AWS)

### Portails principaux

**AWS Management Console**  
https://console.aws.amazon.com
- Dashboard principal pour tous services AWS

**Sections principales:**

1. **Compute**
   - EC2: Virtual servers
   - Lambda: Serverless functions
   - Elastic Beanstalk: Application deployment
   - Lightsail: VPS

2. **Storage**
   - S3: Object storage
   - EBS: Block storage
   - EFS: File storage
   - Glacier: Archive storage

3. **Database**
   - RDS: Relational databases
   - DynamoDB: NoSQL database
   - ElastiCache: In-memory cache
   - Aurora: MySQL/PostgreSQL compatible

4. **Networking & Content Delivery**
   - VPC: Virtual Private Cloud
   - Route 53: DNS service
   - CloudFront: CDN
   - Direct Connect

5. **Security, Identity & Compliance**
   - IAM: Identity and Access Management
   - Cognito: User authentication
   - Secrets Manager
   - Security Hub
   - GuardDuty: Threat detection
   - Inspector: Security assessments
   - CloudWatch: Monitoring

**AWS-Specific Admin Centers:**

**IAM Console**  
https://console.aws.amazon.com/iam
- Users, groups, roles
- Policies
- Access analyzer
- Credential report

**Security Hub**  
https://console.aws.amazon.com/securityhub
- Security standards (CIS, PCI-DSS)
- Findings aggregation
- Insights

**CloudWatch**  
https://console.aws.amazon.com/cloudwatch
- Metrics
- Alarms
- Logs
- Dashboards

**Cost Explorer**  
https://console.aws.amazon.com/cost-management
- Cost analysis
- Budget management
- Savings plans
- Reserved instances

**AWS CLI:**
```bash
# Installation
pip install awscli --break-system-packages

# Configuration
aws configure

# Common commands
aws ec2 describe-instances
aws s3 ls
aws iam list-users
```

---

## 🔑 AUTHENTIFICATION & ACCÈS

### Best Practices

**Comptes admin séparés:**
- Compte quotidien: user@company.com
- Compte admin Azure/M365: admin-user@company.com
- Compte admin Google: admin.user@company.com
- Compte IAM AWS: admin-user

**MFA obligatoire:**
- ✓ Azure AD: Conditional Access
- ✓ M365: MFA enforcement
- ✓ Google Workspace: 2-Step Verification
- ✓ AWS: Virtual MFA device

**Break-glass accounts:**
- Minimum 2 comptes cloud-only
- MFA via TOTP (pas SMS)
- Credentials dans coffre physique
- Audités mensuellement

---

## 🔍 RECHERCHE RAPIDE

### Où trouver quoi?

**Créer un utilisateur:**
- Azure: admin.microsoft.com → Users → Active users → Add user
- Google: admin.google.com → Directory → Users → Add new user
- AWS IAM: console.aws.amazon.com/iam → Users → Add user

**Vérifier service health:**
- Azure: portal.azure.com → Service Health
- M365: admin.microsoft.com → Health → Service health
- Google: admin.google.com → Dashboard (status indicators)
- AWS: status.aws.amazon.com (public status page)

**Audit logs:**
- Azure: portal.azure.com → Azure AD → Audit logs
- M365: compliance.microsoft.com → Audit → Audit log search
- Google: admin.google.com → Reporting → Audit → Admin log events
- AWS: console.aws.amazon.com/cloudtrail

**Cost management:**
- Azure: portal.azure.com → Cost Management + Billing
- M365: admin.microsoft.com → Billing
- Google: admin.google.com → Billing
- AWS: console.aws.amazon.com/billing

**Security posture:**
- Azure: portal.azure.com → Security Center → Secure Score
- M365: security.microsoft.com → Secure Score
- Google: admin.google.com → Security → Security checkup
- AWS: console.aws.amazon.com/securityhub → Security score

---

## 📱 APPLICATIONS MOBILES

**Microsoft:**
- Microsoft 365 Admin (iOS/Android)
- Azure (iOS/Android)
- Intune Company Portal (iOS/Android)

**Google:**
- Google Admin (iOS/Android)

**AWS:**
- AWS Console (iOS/Android)

---

## 🔄 AUTOMATISATION

### Scripts utiles

**Azure - Lister toutes VMs:**
```powershell
Get-AzVM | Select-Object Name, ResourceGroupName, Location, @{N='Status';E={
    $status = Get-AzVM -ResourceGroupName $_.ResourceGroupName -Name $_.Name -Status
    $status.Statuses[1].DisplayStatus
}}
```

**M365 - Rapport licences:**
```powershell
Get-MsolUser -All | Where-Object {$_.isLicensed -eq $true} | 
    Select-Object DisplayName, UserPrincipalName, @{N='Licenses';E={($_.Licenses.AccountSkuId -join ', ')}}
```

**Google Workspace - Lister utilisateurs:**
```bash
# Via gcloud (nécessite configuration)
gcloud identity groups memberships list --group-email=group@company.com
```

**AWS - Lister instances EC2:**
```bash
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,InstanceType,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table
```

---

## 📞 SUPPORT

**Azure:**
- Portal: "Help + support" dans le menu
- Phone: Selon niveau de support
- Documentation: docs.microsoft.com/azure

**Microsoft 365:**
- Admin Center: Support → New service request
- Phone: Disponible selon plan
- Community: answers.microsoft.com

**Google Workspace:**
- Admin Console: Support → Contact support
- Phone: Disponible Business/Enterprise
- Help Center: support.google.com/a

**AWS:**
- Support Center: console.aws.amazon.com/support
- TAM (Technical Account Manager) si Enterprise
- Documentation: docs.aws.amazon.com

---

*Guide version 1.0 - IT-CloudMaster*  
*Dernière mise à jour: Février 2026*
