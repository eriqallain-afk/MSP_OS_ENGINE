# REFERENCE LIBRARY — IT-Assistant-N3 (MASTER)
**Version :** 1.0 | **Date :** 2026-03-15 | **Agent :** IT-Assistant-N3
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Source :** 19 fichiers analysés → 11 stubs exclus → 8 références uniques

---

## TABLE DES MATIÈRES

| # | Catégorie | Document | Contenu |
|---|-----------|----------|---------|
| 1.1 | Mémoire opérationnelle | MEM Reference OnePager | Ownership, routing, escalade résumé |
| 1.2 | Mémoire opérationnelle | MEM Routing Rules | Règles de routage événements |
| 1.3 | Mémoire opérationnelle | MEM Severity Matrix | Définitions S0–S4, cadence |
| 1.4 | Mémoire opérationnelle | MEM Conventions | Conventions timezone, nommage |
| 1.5 | Mémoire opérationnelle | MEM Comms Templates | Templates communication incidents |
| 2.1 | Cloud & Portails | Cloud Admin Portals | Tous les portails Azure/M365/AWS/GCP |
| 2.2 | Cloud & Portails | Common Cloud Commands | Azure CLI, AzureAD, Exchange PS |
| 3.1 | Dépannage | Azure Troubleshooting | Guide diagnostic Azure complet |

---

---
# SECTION 1 — MÉMOIRE OPÉRATIONNELLE (MEM)
---

## 1.1 — REFERENCE ONEPAGER (Ownership & Routing résumé)

# MEM-IT-REFERENCE-ONEPAGER — v1.0
meta:
  doc_id: MEM-IT-REFERENCE-ONEPAGER
  version: v1.0
  status: normative
  updated_on: 2026-01-22
  owners:
    primary: CMD-OPR
    co_owners: [CMD-NOC, CMD-INFRA, CMD-TECH, SEC-X]

## A) Ownership & routing (résumé)
- Monitoring/alerts → CMD-NOC (esc: INFRA/TECH/SEC-X)
- Réseau/core infra → CMD-INFRA (esc: NOC + ISP/Vendor + SEC-X si suspicion)
- Endpoint/M365/apps → CMD-TECH (esc: NOC si majeur + SEC-X si compromission)
- SLA/coordination/change → CMD-OPR (esc: Management + validation client si besoin)
- Sécurité (phishing/EDR/IAM/anomalie/exfil) → SEC-X (IR lead)

## B) Severity & update cadence
- S0: 15 min
- S1: 30 min
- S2: 2 h
- S3: 1×/jour ouvré
- S4: selon ticket

## C) Formats obligatoires
- Incident: INC-ID + sev + impact + owner + timeline + next update time
- Change: RFC-Light (objectif/scope/risque/test/rollback/fenêtre/owner/validation)
- S0/S1: Postmortem PM-INC_ID + CAPA (owner/date/success criteria)

## D) Comms minimum
- Interne: [INCIDENT][Sx] INC-ID impact owner next update
- Client: incident détecté + impact + prochaine update + résolution

## E) CMDB / KB
- CMDB CI: ci_id, client_code, type, owner, criticality, dependencies, SoT, last_updated
- Post-change: MAJ CMDB/KB ≤ 48h
- S0/S1 ou récurrence: KB obligatoire

## F) Definition of Done (DoD)
- RUN: owner+sev+updates+log+close summary
- CHANGE: validation+test+rollback+comms+CMDB/KB update
- PM: RCA+CAPA+dates+preuves+KB/CMDB

## G) Gouvernance
- Propriétaire doc: CMD-OPR | Co-owners: CMD-NOC, CMD-INFRA, CMD-TECH, SEC-X
- Versioning: v1 → v1.1 → v2 (voir MEM-IT-Versioning-Policy)


---

## 1.2 — ROUTING RULES (Règles de routage événements)

# MEM-IT-Routing-Rules — v1.0
meta:
  doc_id: MEM-IT-Routing-Rules
  version: v1.0
  status: normative
  updated_on: 2026-01-22
  owners:
    primary: CMD-OPR
    co_owners: [CMD-NOC, CMD-INFRA, CMD-TECH, SEC-X]

## 1) But
Router un événement vers le bon owner, préciser l’escalade et les artefacts attendus.

## 2) Routing (événement → owner → escalade → artefacts)
### A) RUN — Incidents
1) Monitoring/alerting (CPU/RAM/disque/service down/latence/erreurs)
- Owner: CMD-NOC
- Escalade: CMD-INFRA (infra), CMD-TECH (apps/outils), SEC-X (si suspicion)
- Format attendu: INC + status updates + actions log

2) Réseau (WAN/LAN/VPN/Firewall/DNS)
- Owner: CMD-INFRA
- Escalade: CMD-NOC (coord), Vendor/ISP, SEC-X (si sécurité)
- Format attendu: INC + diag + mitigation

3) Endpoint / MDM / M365 / apps support
- Owner: CMD-TECH
- Escalade: CMD-NOC si majeur, Vendor si SaaS, SEC-X si compromission
- Format attendu: TICKET (mineur) ou INC (majeur)

4) SLA / escalade client / coordination multi-équipes
- Owner: CMD-OPR
- Escalade: Management + CMD-* concernés
- Format attendu: situation report + décisions + risques + actions

### B) SEC — Sécurité
Suspicion phishing/malware/EDR alert/IAM anomalie/exfil
- Owner: SEC-X (IR lead)
- Escalade: CMD-NOC (war room), CMD-INFRA (containment), CMD-TECH (endpoints), Management, Client (selon matrice)
- Format attendu: SEC-INC + preuves + mesures containment

### C) CHANGE — RFC
1) Standard (faible risque, répétitif, pré-approuvé)
- Owner: CMD-OPR
- Escalade: CMD-INFRA/CMD-TECH selon scope
- Format attendu: RFC-Light

2) Majeur (prod, downtime, sécurité, réseau core)
- Owner: CMD-OPR (gouvernance) + Tech Lead: CMD-INFRA/CMD-TECH
- Escalade: SEC-X (si impact sécu) + validation client
- Format attendu: RFC-Light + test + rollback + fenêtre

### D) PROB — Problem Management
Récurrence incidents / dette technique / capacity
- Owner: CMD-OPR (Problem Manager)
- Escalade: CMD-INFRA/CMD-TECH + Management
- Format attendu: Problem Record + CAPA + suivi

## 3) Règles d’escalade “blocage”
- Blocage technique > 15 min (S0/S1): escalade immédiate L2/L3
- Dépendance vendor: ouvrir ticket vendor + capturer ID + ETA
- Risque sécurité: SEC-X propriétaire, containment prioritaire

## 4) Artefacts minimum
- INC: ID, sévérité, impact, scope, owner, timeline, actions, ETA, next update time, clôture (RCA rapide)
- RFC: objectif, scope, risques, tests, rollback, fenêtre, owner, validation
- SEC-INC: + preuves, containment, notifications si nécessaire


---

## 1.3 — SEVERITY MATRIX (S0–S4 + cadence updates)

# MEM-IT-Severity-Matrix — v1.0
meta:
  doc_id: MEM-IT-Severity-Matrix
  version: v1.0
  status: normative
  updated_on: 2026-01-22
  owners:
    primary: CMD-OPR
    co_owners: [CMD-NOC, SEC-X]

## 1) Définitions S0–S4 + cadence d’updates
### S0 — Critique / Sécurité majeure / Panne totale
- Impact: indisponibilité globale, données à risque, ransomware/exfil, core network down
- Cadence updates: 15 min (ou à chaque changement majeur)
- Exemples: AD/SSO down, firewall core KO, ransomware confirmé, fuite potentielle de données

### S1 — Majeur
- Impact: service essentiel indispo/dégradé (multi-utilisateurs / site principal / >20%)
- Cadence updates: 30 min
- Exemples: VPN intermittent large, incident M365 large, lien WAN fortement dégradé

### S2 — Modéré
- Impact: périmètre limité, workaround possible
- Cadence updates: 2 h (ou à jalons)
- Exemples: impression site B, appli secondaire lente, batch en échec

### S3 — Mineur
- Impact: 1–2 utilisateurs, non urgent
- Cadence updates: 1×/jour ouvré (ou selon SLA)
- Exemples: poste lent, reset MFA, accès appli pour un user

### S4 — Demande / Info / Planned work
- Impact: aucun incident
- Cadence updates: selon ticket / planning
- Exemples: ajout compte, demande d’info, changement mineur planifié

## 2) Règles de recalibrage
- Extension impact (plus de sites/users): monter la sévérité
- Suspicion sécurité: consulter SEC-X, reclasser si nécessaire
- Workaround stable + impact contenu: baisser la sévérité

## 3) Contenu minimum de chaque update
- Horodatage, état, impact, actions depuis dernière update, next steps, ETA/risques, prochaine heure d’update


---

## 1.4 — CONVENTIONS (Timezone, nommage, standards)

# MEM-IT-Conventions — v1.0
meta:
  doc_id: MEM-IT-Conventions
  version: v1.0
  status: normative
  timezone: America/Montreal
  updated_on: 2026-01-22
  owners:
    primary: CMD-OPR
    co_owners: [CMD-NOC, CMD-INFRA, CMD-TECH, SEC-X]

## 1) Objectif
Standardiser le nommage, les IDs, les rôles (owners), les escalades et les artefacts pour RUN/CHANGE/SEC dans un contexte MSP.

## 2) Préfixes & IDs
- Blocs mémoire: `MEM-IT-<Bloc>`
- Incidents: `INC-YYYYMMDD-<ClientCode>-<ShortSlug>`
- Changements: `RFC-YYYYMMDD-<ClientCode>-<ShortSlug>`
- Postmortems: `PM-<INC_ID>`

## 3) Rôles (Commandare)
- CMD-NOC: supervision, triage, coordination incident
- CMD-INFRA: réseau, serveurs, cloud, capacity
- CMD-TECH: endpoints, M365/apps/outils, support L2/L3
- CMD-OPR: process, change, SLA, reporting, gouvernance
- SEC-X: transverse sécurité (IAM, vuln, IR, compliance)

## 4) Niveaux d’escalade (standard)
`L1 → L2 → L3 → Vendor/Provider → Management → Client`

## 5) Formats attendus (minimum)
- Incident update: horodatage, état, impact, actions depuis dernière update, next steps, ETA/risques, prochaine update
- RFC-Light: objectif, scope, risque, test, rollback, fenêtre, owner, validation
- Postmortem: timeline, RCA, CAPA (owner/date/success criteria)

## 6) Definition of Done (DoD) — checklists rapides
### RUN (incident)
- [ ] Owner assigné + back-up nommé
- [ ] Sévérité (S0–S4) définie + timestamps (détection/début)
- [ ] Canal incident interne + log actions
- [ ] Comms client selon matrice (si applicable)
- [ ] Clôture: résumé + next steps
- [ ] S0/S1: postmortem planifiée et produite

### CHANGE (RFC)
- [ ] CI impactés listés
- [ ] Test + rollback écrits
- [ ] Fenêtre confirmée + validations obtenues
- [ ] Comms prêtes (interne/client)
- [ ] Post-change: MAJ CMDB/KB sous 48h

### POSTMORTEM (S0/S1)
- [ ] Timeline complète
- [ ] RCA (cause racine) + facteurs contributifs
- [ ] CAPA avec owners + dates + critères de succès
- [ ] KB/CMDB/monitoring mis à jour


---

## 1.5 — COMMS TEMPLATES (Communication incidents interne/externe)

# MEM-IT-Comms-Templates — v1.0
meta:
  doc_id: MEM-IT-Comms-Templates
  version: v1.0
  status: normative
  updated_on: 2026-01-22
  owners:
    primary: CMD-OPR
    co_owners: [CMD-NOC, SEC-X]

## 1) Interne (Teams/Slack)
### A) Incident start
[INCIDENT][Sx] <INC_ID> — <ClientCode> — <Service>
- Impact:
- Scope:
- Owner:
- War room / canal:
- Hypothèse initiale:
- Actions en cours:
- Prochaine update: HH:MM

### B) Update
[UPDATE][Sx] <INC_ID>
- État: investigation / mitigation / monitoring / resolved
- Changements depuis dernière update:
- Impact actuel:
- Next steps:
- ETA (si possible):
- Prochaine update: HH:MM

### C) Resolved
[RESOLVED][Sx] <INC_ID>
- Résolution:
- Durée:
- Cause probable (RCA rapide):
- Actions follow-up:
- Postmortem: oui/non (date)

## 2) Client (email)
### A) Initial notification
Objet: Incident [Sx] — <Service> — <ClientName> — <INC_ID>
Bonjour,
Nous avons détecté un incident impactant <service> depuis <HH:MM TZ>.
- Impact observé:
- Périmètre:
Nos équipes sont mobilisées. Prochaine mise à jour à <HH:MM TZ>.
Cordialement,
<MSP NOC>

### B) Update
Objet: Mise à jour — Incident [Sx] — <INC_ID>
- Statut:
- Impact actuel:
- Actions en cours:
- Prochaine mise à jour: <HH:MM TZ>

### C) Resolution
Objet: Résolution — Incident [Sx] — <INC_ID>
L’incident est résolu depuis <HH:MM TZ>.
- Résumé:
- Mesure corrective immédiate:
- Actions de prévention (si applicable):
Si un postmortem est prévu (S0/S1), nous partagerons un compte-rendu.

## Checklist Comms
- [ ] Ton factuel (pas de spéculation)
- [ ] Prochaine heure d’update indiquée
- [ ] Validation SEC-X si incident/suspicion sécurité
- [ ] IDs (INC/RFC/PM) présents partout


---
# SECTION 2 — CLOUD & PORTAILS
---

## 2.1 — PORTAILS ADMINISTRATION CLOUD (Azure / M365 / AWS / GCP)

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


---

## 2.2 — COMMANDES CLOUD COURANTES (Azure CLI / PowerShell / AWS CLI)

# REFERENCE - Commandes Cloud Courantes

## Azure CLI (az)

### Authentification
```bash
# Login interactif
az login

# Login avec Service Principal
az login --service-principal -u APP_ID -p PASSWORD --tenant TENANT_ID

# Sélectionner subscription
az account set --subscription "SUBSCRIPTION_NAME"

# Lister subscriptions
az account list --output table
```

### Resource Groups
```bash
# Créer RG
az group create --name rg-prod-001 --location canadacentral

# Lister RGs
az group list --output table

# Supprimer RG (avec confirmation)
az group delete --name rg-dev-001 --yes --no-wait

# Verrouiller RG
az lock create --name DeleteLock --lock-type CanNotDelete --resource-group rg-prod-001
```

### Virtual Machines
```bash
# Lister VMs
az vm list --output table

# Démarrer VM
az vm start --resource-group rg-prod-001 --name vm-app-001

# Arrêter VM (deallocate pour arrêter facturation)
az vm deallocate --resource-group rg-prod-001 --name vm-app-001

# Resize VM
az vm resize --resource-group rg-prod-001 --name vm-app-001 --size Standard_D4s_v3

# Obtenir IP publique
az vm list-ip-addresses --resource-group rg-prod-001 --name vm-app-001 --output table
```

### Storage
```bash
# Créer Storage Account
az storage account create   --name stprod001   --resource-group rg-prod-001   --location canadacentral   --sku Standard_LRS

# Obtenir connection string
az storage account show-connection-string   --name stprod001   --resource-group rg-prod-001

# Créer container blob
az storage container create   --name backups   --account-name stprod001
```

### Networking
```bash
# Créer VNet
az network vnet create   --resource-group rg-prod-001   --name vnet-prod-001   --address-prefix [IP_CLIENTE]/16   --subnet-name subnet-app   --subnet-prefix [IP_CLIENTE]/24

# Créer NSG
az network nsg create   --resource-group rg-prod-001   --name nsg-app-001

# Ajouter NSG rule
az network nsg rule create   --resource-group rg-prod-001   --nsg-name nsg-app-001   --name AllowHTTPS   --priority 100   --source-address-prefixes '*'   --destination-port-ranges 443   --access Allow   --protocol Tcp
```

## Microsoft 365 (PowerShell)

### Exchange Online
```powershell
# Connexion
Connect-ExchangeOnline

# Lister mailboxes
Get-Mailbox -ResultSize Unlimited | Select DisplayName,PrimarySmtpAddress,@{N="Size";E={(Get-MailboxStatistics $_.Identity).TotalItemSize}}

# Créer mailbox partagée
New-Mailbox -Shared -Name "Support IT" -DisplayName "Support IT" -Alias supportit

# Ajouter permissions
Add-MailboxPermission -Identity "Support IT" -User user@domain.com -AccessRights FullAccess -InheritanceType All
Add-RecipientPermission -Identity "Support IT" -Trustee user@domain.com -AccessRights SendAs

# Mail flow rules
New-TransportRule -Name "Block Executable Attachments"   -AttachmentExtensionMatchesWords @("exe","bat","cmd","com","pif","scr","vbs")   -RejectMessageReasonText "Executable attachments blocked by policy"

# Recherche message
Get-MessageTrace -SenderAddress sender@external.com -RecipientAddress user@domain.com -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date)
```

### SharePoint Online
```powershell
# Connexion
Connect-SPOService -Url https://tenant-admin.sharepoint.com

# Lister sites
Get-SPOSite | Select Url,Owner,StorageUsageCurrent,StorageQuota

# Créer site
New-SPOSite -Url https://tenant.sharepoint.com/sites/IT-Team   -Owner admin@domain.com   -StorageQuota 26214400   -Template "STS#3"

# Permissions
Set-SPOUser -Site https://tenant.sharepoint.com/sites/IT-Team   -LoginName user@domain.com   -Group "IT-Team Members"
```

### Teams
```powershell
# Connexion
Connect-MicrosoftTeams

# Lister équipes
Get-Team

# Créer équipe
New-Team -DisplayName "IT Support" -Description "Équipe support IT" -Visibility Private

# Ajouter membres
Add-TeamUser -GroupId <team-id> -User user@domain.com -Role Member

# Créer channel
New-TeamChannel -GroupId <team-id> -DisplayName "Incidents" -Description "Gestion incidents"
```

### Azure AD (Graph)
```powershell
# Connexion
Connect-MgGraph -Scopes "User.ReadWrite.All","Group.ReadWrite.All"

# Lister utilisateurs
Get-MgUser -All | Select DisplayName,UserPrincipalName,AccountEnabled

# Créer utilisateur
$PasswordProfile = @{
    Password = "<TEMP_PASSWORD>!"
    ForceChangePasswordNextSignIn = $true
}

New-MgUser -DisplayName "Jean Tremblay"   -UserPrincipalName "jean.tremblay@domain.com"   -AccountEnabled   -PasswordProfile $PasswordProfile   -MailNickname "jean.tremblay"

# Réinitialiser MFA
Reset-MgUserAuthenticationMethodPassword -UserId user@domain.com
```

## AWS CLI

### Authentification
```bash
# Configurer credentials
aws configure

# Utiliser profil spécifique
aws s3 ls --profile prod

# Lister profils
aws configure list-profiles
```

### EC2
```bash
# Lister instances
aws ec2 describe-instances --output table

# Démarrer instance
aws ec2 start-instances --instance-ids i-1234567890abcdef0

# Arrêter instance
aws ec2 stop-instances --instance-ids i-1234567890abcdef0

# Créer AMI
aws ec2 create-image --instance-id i-1234567890abcdef0 --name "Backup-$(date +%Y%m%d)"
```

### S3
```bash
# Lister buckets
aws s3 ls

# Copier fichiers
aws s3 cp file.txt s3://bucket-name/

# Sync directory
aws s3 sync ./local-folder s3://bucket-name/remote-folder

# Lifecycle policy
aws s3api put-bucket-lifecycle-configuration --bucket bucket-name --lifecycle-configuration file://lifecycle.json
```

## Google Workspace (gam)

### Utilisateurs
```bash
# Créer utilisateur
gam create user jean.tremblay@domain.com firstname Jean lastname Tremblay password <TEMP_PASSWORD>! changepassword on

# Lister utilisateurs
gam print users

# Suspendre utilisateur
gam update user jean.tremblay@domain.com suspended on

# Reset password
gam update user jean.tremblay@domain.com password NewP@ss123! changepassword on
```

### Groupes
```bash
# Créer groupe
gam create group it-team@domain.com name "IT Team" description "Équipe IT"

# Ajouter membre
gam update group it-team@domain.com add member jean.tremblay@domain.com

# Lister membres
gam print group-members group it-team@domain.com
```

### Gmail
```bash
# Créer alias
gam user jean.tremblay@domain.com add alias jtremblay@domain.com

# Délégation
gam user jean.tremblay@domain.com delegate to admin@domain.com

# Signature
gam user jean.tremblay@domain.com signature file signature.html
```

## Références rapides

### Codes de sortie communs
- 0: Succès
- 1: Erreur générale
- 2: Syntaxe invalide
- 126: Commande non exécutable
- 127: Commande non trouvée
- 130: Terminé par Ctrl+C

### Variables d'environnement utiles
```bash
# Azure
export AZURE_SUBSCRIPTION_ID="xxx"
export AZURE_RESOURCE_GROUP="rg-prod-001"

# AWS
export AWS_DEFAULT_REGION="ca-central-1"
export AWS_PROFILE="production"

# Proxies
export HTTP_PROXY="http://<PROXY_HOST>:8080"
export HTTPS_PROXY="http://<PROXY_HOST>:8080"
```


---
# SECTION 3 — DÉPANNAGE
---

## 3.1 — AZURE TROUBLESHOOTING (Guide diagnostic complet)

# GUIDE - Azure Troubleshooting

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


---

## NOTES DE CONSOLIDATION

| Statistique | Valeur |
|-------------|--------|
| Fichiers source analysés | 19 |
| Stubs génériques exclus | 11 (boilerplate vide) |
| Doublons exacts | 0 |
| Références uniques retenues | 8 |

**Stubs exclus :** GUIDE__Best_Practices, GUIDE__Troubleshooting, GUIDE__VEEAM_Best_Practices,
GUIDE__Writing_Standards, REFERENCE__Cisco_Commands, REFERENCE__Commands,
REFERENCE__Common_Commands, REFERENCE__Metrics, REFERENCE__SLA_Matrix,
REFERENCE__Standards, REFERENCE__Template_Library
