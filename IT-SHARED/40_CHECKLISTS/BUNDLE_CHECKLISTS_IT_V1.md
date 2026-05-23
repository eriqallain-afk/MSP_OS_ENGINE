# BUNDLE — CHECKLISTS IT MSP
**ID :** BUNDLE_CHECKLISTS_IT_V1
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Assistant-N2 | @IT-Assistant-N3 | @IT-FrontLine | @IT-BackupDRMaster | @IT-SecurityMaster | @IT-Commandare-NOCDispatcher | @IT-ReportMaster
**Version :** 1.0 | **Date :** 2026-04-08

---


---
## CHECKLIST_BACKUP_DR-Readiness_V1
**Source :** `40_CHECKLISTS/CHECKLIST_BACKUP_DR-Readiness_V1.md`

**Agent :** IT-BackupDRMaster, IT-MaintenanceMaster | IT-SysAdmin
**Usage :** Vérification mensuelle de la disponibilité du plan de relève
**Mis à jour :** 2026-03-20

---

## BACKUPS — ÉTAT COURANT

### Datto BCDR
- [ ] Tous les agents : dernier backup Success ou Warning acceptable
- [ ] Screenshot de vérification présent pour les VMs critiques
- [ ] Stockage local Datto : espace libre > 20%
- [ ] Stockage cloud : synchronisation OK (pas d'erreur > 24h)
- [ ] Rétention configurée selon la politique client (Hudu → Agreements)

### Veeam
- [ ] Jobs en cours : Success ou Warning acceptable
- [ ] Repository : espace libre > 20%
- [ ] Dernière vérification d'intégrité (SureBackup ou Instant Recovery test) < 30 jours
- [ ] Veeam Cloud Connect (si applicable) : synchronisation OK

### Keepit (M365)
- [ ] Connecteur Microsoft 365 : Connected (pas Disconnected)
- [ ] Dernière synchronisation Exchange : OK
- [ ] Dernière synchronisation SharePoint/OneDrive : OK
- [ ] Nombre d'utilisateurs protégés = nombre d'utilisateurs actifs

---

## PLAN DE RELÈVE — VALIDITÉ

- [ ] Document DR à jour dans Hudu pour ce client (date < 6 mois)
- [ ] Contacts d'urgence à jour (responsable client, MSP on-call)
- [ ] RTO et RPO documentés et connus de l'équipe
- [ ] Ordre de démarrage des systèmes documenté
- [ ] Accès aux ressources de reprise validé (accès Datto portal, VPN, credentials Passportal)

---

## TESTS DR

- [ ] Dernier test d'intégrité backup : _______ (date)
  - Résultat : ☐ Pass  ☐ Fail → Actions correctives : _______
- [ ] Dernier test Instant Virtualization : _______ (date)
  - RTO mesuré : _______ min / Objectif : _______ min
- [ ] Prochain test planifié : _______

---

## VÉRIFICATION ANNUELLE

- [ ] Test complet DR (Tabletop ou Functional) effectué cette année : ☐ Oui  ☐ Non
- [ ] Rapport de test archivé dans CW/Hudu : ☐ Oui
- [ ] Écarts identifiés et corrigés : ☐ Oui  ☐ En cours : _______

---

## RÉSULTAT

☐ **DR READY** — Tous les items validés
☐ **ACTIONS REQUISES** — Items en attente : _______
☐ **NON READY** — Problème critique : escalade IT-BackupDRMaster immédiatement

---
## CHECKLIST — CLOSEOUT (ConnectWise)
**Source :** `40_CHECKLISTS/CHECKLIST_CW_Closeout_V1.md`

- [ ] CW_NOTE_INTERNE : timeline + commandes + outputs + décisions + suivis
- [ ] CW_DISCUSSION (STAR) : facturable, concis, sans IP
- [ ] Email client : clair + résultat + suivi
- [ ] Teams : début/fin
- [ ] KB draft (si récurrent)

---
## CHECKLIST — KICKOFF (Ticket MSP)
**Source :** `40_CHECKLISTS/CHECKLIST_CW_Kickoff-Ticket_V1.md`

Copier-coller et remplir au début :

- Ticket: #
- Client: 
- Type: NOC | Support | Change | Maintenance
- Fenêtre: (Début–Fin + TZ)
- Urgence/SLA: 
- Scope (serveurs/services): 
- Contraintes: (prod, VIP, no-touch, 1 serveur critique à la fois, etc.)
- Risques connus: 
- Objectif (succès): 
- Outils: (RMM/VPN/Portal)

---
## CHECKLIST - Déploiement Azure VM
**Source :** `40_CHECKLISTS/CHECKLIST_INFRA_Azure-VM-Deployment_V1.md`

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

---
## CHECKLIST: Microsoft 365 Configuration Best Practices
**Source :** `40_CHECKLISTS/CHECKLIST_INFRA_M365-Configuration_V1.md`

## Métadonnées
- **Version:** 1.0
- **Dernière mise à jour:** Février 2026
- **Applicable à:** Microsoft 365 (E3/E5, Business Premium)
- **Durée estimation:** 2-3 heures (audit complet)

---

## 🔐 1. SÉCURITÉ & IDENTITÉ

### Azure Active Directory

#### Configuration de base
- [ ] **Noms de domaine personnalisés** configurés et vérifiés
- [ ] **Licences AAD Premium P1/P2** assignées si nécessaire
- [ ] **Self-service password reset** activé pour tous utilisateurs
- [ ] **Password protection** activé (bannir mots de passe faibles)
- [ ] **Smart Lockout** configuré (seuil: 10 tentatives, durée: 60 sec)

#### Authentification multi-facteurs (MFA)
- [ ] **MFA activé** pour tous les administrateurs (100% requis)
- [ ] **MFA encouragé** pour tous les utilisateurs (cible: 95%+)
- [ ] **Méthodes MFA** configurées: Microsoft Authenticator (recommandé), SMS backup
- [ ] **Trusted IPs** définis pour bypass conditionnel
- [ ] **App passwords** désactivés (sauf exceptions documentées)

#### Conditional Access
- [ ] **Politique 1:** Bloquer legacy authentication pour tous utilisateurs
- [ ] **Politique 2:** Exiger MFA pour tous les admins
- [ ] **Politique 3:** Exiger MFA pour accès Azure Management
- [ ] **Politique 4:** Exiger devices compliant pour accès données sensibles
- [ ] **Politique 5:** Bloquer accès depuis pays non-autorisés
- [ ] **Politique 6:** Exiger MFA pour accès à partir d'unknown locations
- [ ] **Mode Report-Only** testé avant activation
- [ ] **Break-glass account** exclu des politiques CA (documenté)

#### Comptes privilégiés
- [ ] **Global Admins:** Maximum 5 comptes (moins c'est mieux)
- [ ] **Break-glass accounts:** 2 comptes cloud-only avec MFA TOTP
- [ ] **Admin roles:** Assignés selon principe moindre privilège
- [ ] **PIM (Privileged Identity Management):** Activé pour rôles sensibles (E5 requis)
- [ ] **Admin accounts:** Noms standardisés (ex: admin-jtremblay@domain.com)
- [ ] **Monitoring alertes:** Configuré pour changements admin

### Microsoft Defender

#### Microsoft Defender for Office 365 (Plan 1/2)
- [ ] **Safe Links** activé pour emails et Teams
- [ ] **Safe Attachments** activé avec action "Block"
- [ ] **Anti-phishing policies** configurées (detect impersonation)
- [ ] **Spoof intelligence** activé
- [ ] **Quarantine policies** définies
- [ ] **Zero-hour auto purge (ZAP)** activé pour spam et phishing
- [ ] **Mail flow rules** pour bloquer file types dangereux (.exe, .js, .vbs, etc.)

#### Microsoft Defender for Endpoint (si applicable)
- [ ] **Onboarding** complété pour tous devices
- [ ] **Attack Surface Reduction (ASR)** rules activées
- [ ] **Controlled Folder Access** configuré
- [ ] **Alerts** routées vers Security Operations

#### Security Baselines
- [ ] **Microsoft 365 Security Baseline** appliqué via Intune
- [ ] **Windows Security Baseline** appliqué pour devices Windows
- [ ] **Deviation reports** générés mensuellement

---

## 📧 2. EXCHANGE ONLINE

### Configuration globale
- [ ] **Accepted domains** ajoutés et validés
- [ ] **Mail flow (connectors)** configurés si hybrid ou tierce partie
- [ ] **SPF record** publié (v=spf1 include:spf.protection.outlook.com -all)
- [ ] **DKIM signing** activé pour tous domaines
- [ ] **DMARC record** publié (p=quarantine minimum, p=reject recommandé)
- [ ] **MX records** pointent vers Exchange Online (.mail.protection.outlook.com)

### Protection anti-spam et malware
- [ ] **Anti-spam policies:** Configured (default + custom si besoin)
- [ ] **Anti-malware policies:** Action = Delete, notifications activées
- [ ] **Outbound spam filter:** Alertes configurées pour compromission compte
- [ ] **Quarantine notifications:** Envoyées aux utilisateurs (digest quotidien)

### Retention et compliance
- [ ] **Retention policies** définies (minimum: 7 ans pour emails conformité)
- [ ] **Litigation hold** activé pour utilisateurs clés si requis
- [ ] **Archive mailboxes** activés pour tous (ou selon licence)
- [ ] **Auto-expanding archive** activé si croissance prévue
- [ ] **Journaling** configuré si requis par compliance

### Délégation et partage
- [ ] **Shared mailboxes:** Permissions déléguées, pas de licences assignées
- [ ] **Calendar sharing policies:** Limitées (default = Limited Details only)
- [ ] **External sharing:** Contrôlé (pas de sharing automatique)
- [ ] **Distribution groups:** Ownership défini, moderation activée si public

### Quotas et limites
- [ ] **Mailbox quotas:** IssueWarning=45GB, ProhibitSend=48GB, ProhibitReceive=50GB
- [ ] **Send/Receive limits:** Defaults acceptables (150MB attachments)
- [ ] **Recipient limits:** 500/jour par utilisateur (default)

---

## 👥 3. SHAREPOINT ONLINE & ONEDRIVE

### Administration et gouvernance
- [ ] **Sharing settings:**
  - [ ] External sharing = "Only people in organization" (ou "New and existing guests" si nécessaire)
  - [ ] Default link type = "Specific people"
  - [ ] Default permission = "View"
- [ ] **Access control:** Require sign-in pour accès externe
- [ ] **Idle session timeout:** Configuré (recommandé: 1 heure)
- [ ] **Legacy authentication:** Bloquée

### OneDrive
- [ ] **Storage quota:** Défini par utilisateur (1TB default avec E3)
- [ ] **Sync restrictions:** Limiter à devices corporate (AAD joined/Hybrid)
- [ ] **Known Folder Move:** Déployé via GPO (Desktop, Documents, Pictures)
- [ ] **Files On-Demand:** Activé par défaut
- [ ] **Retention for deleted users:** 365 jours minimum

### Sites et Hub Sites
- [ ] **Site creation:** Contrôlé (approval required ou self-service géré)
- [ ] **Hub sites:** Structure définie (max 3 niveaux)
- [ ] **Site owners:** Minimum 2 par site
- [ ] **Inactive sites:** Politique de cleanup définie (ex: archiver après 180 jours inactifs)

### DLP et Information Protection
- [ ] **DLP policies:** Actives pour SharePoint/OneDrive
  - [ ] Bloquer partage CCN, SIN, données santé
  - [ ] Alertes configurées pour violations
- [ ] **Sensitivity labels:** Publiées et utilisées
  - [ ] Public, Internal, Confidential, Highly Confidential
  - [ ] Auto-labeling configuré si E5
- [ ] **Versioning:** Activé (500 versions par défaut)
- [ ] **Recycle bin:** 93 jours rétention (default)

---

## 💬 4. MICROSOFT TEAMS

### Configuration organisation
- [ ] **External access (federation):** Configuré selon politiques
  - [ ] Domaines autorisés/bloqués listés
  - [ ] Skype for Business federation si requis
- [ ] **Guest access:** Activé avec restrictions appropriées
  - [ ] Require MFA pour guests
  - [ ] Limiter fonctionnalités guests (pas de apps par défaut)
- [ ] **Teams creation:** Contrôlé (approval ou groupes autorisés)
- [ ] **Naming policy:** Appliquée (préfixes/suffixes, blocked words)

### Sécurité et compliance
- [ ] **Retention policies:** Configurées pour Teams messages et files
- [ ] **DLP policies:** Actives pour Teams conversations
- [ ] **Meeting policies:**
  - [ ] Lobby pour external participants
  - [ ] Recording = disabled par défaut (ou controlled)
  - [ ] Transcription selon besoins compliance
- [ ] **Chat permissions:** Restrict Giphy, memes si nécessaire
- [ ] **External apps:** Catalog contrôlé (block by default, allow liste)

### Voice et Calling (si applicable)
- [ ] **Calling policies:** Définies par groupe d'utilisateurs
- [ ] **Emergency addresses:** Configurées pour tous sites
- [ ] **Call routing:** Dial plans et routes configurés
- [ ] **Auto attendants:** Configurés avec fallback

### Usage et adoption
- [ ] **Teams analytics:** Monitoring activé
- [ ] **Usage reports:** Consultés mensuellement
- [ ] **Inactive teams:** Archivage automatique configuré (180+ jours)
- [ ] **Training resources:** Disponibles pour utilisateurs

---

## 🛡️ 5. SÉCURITÉ & COMPLIANCE CENTER

### Data Loss Prevention (DLP)
- [ ] **DLP policies actives:**
  - [ ] Exchange (email)
  - [ ] SharePoint/OneDrive (documents)
  - [ ] Teams (conversations)
  - [ ] Endpoints (si Defender for Endpoint)
- [ ] **Sensitive info types:** Customisés pour organisation
  - [ ] Numéros assurance sociale (SIN)
  - [ ] Numéros cartes crédit
  - [ ] Données spécifiques industrie
- [ ] **Policy tips:** Activés pour éduquer utilisateurs
- [ ] **Incident reports:** Envoyés à admins DLP

### Information Protection
- [ ] **Sensitivity labels:** Créées et publiées
- [ ] **Label policies:** Assignées aux bons groupes
- [ ] **Auto-labeling:** Configuré si E5 (basé sur sensitive info types)
- [ ] **Encryption:** Configurée pour labels "Confidential" et "Highly Confidential"
- [ ] **Visual markings:** Headers/footers/watermarks configurés

### Retention Policies
- [ ] **Retention policies:**
  - [ ] Email: 7 ans minimum
  - [ ] SharePoint/OneDrive: 7 ans minimum
  - [ ] Teams: Selon besoins légaux
- [ ] **Disposition review:** Processus défini pour fin de rétention
- [ ] **Preservation lock:** Appliqué aux politiques légales

### Audit et Monitoring
- [ ] **Unified Audit Logging:** Activé (obligatoire)
- [ ] **Audit retention:** 90 jours (E3) ou 1 an (E5/add-on)
- [ ] **Alert policies:** Configurées pour activités critiques
  - [ ] Création de forwarding rules
  - [ ] Mass download SharePoint
  - [ ] Elevation to admin
  - [ ] External sharing
- [ ] **Compliance Manager:** Score > 80% (cible)

### eDiscovery
- [ ] **eDiscovery cases:** Process défini
- [ ] **Custodians:** Formation fournie à legal team
- [ ] **Advanced eDiscovery:** Configuré si E5

---

## 📱 6. DEVICE MANAGEMENT (INTUNE)

### Enrollment et configuration
- [ ] **Auto-enrollment:** Configuré pour devices AAD joined
- [ ] **Device categories:** Définies (Corporate, BYOD, Kiosk, etc.)
- [ ] **Compliance policies:** Créées par plateforme (Windows, iOS, Android)
  - [ ] Require encryption
  - [ ] Minimum OS version
  - [ ] Require antivirus
  - [ ] Screen lock settings
- [ ] **Configuration profiles:** Déployés
  - [ ] Wi-Fi settings
  - [ ] VPN settings  
  - [ ] Email profiles
  - [ ] Certificates

### Application Management
- [ ] **App protection policies:** Configurées (Managed Apps)
- [ ] **Required apps:** Déployées via Intune
  - [ ] Microsoft 365 Apps
  - [ ] Company Portal
  - [ ] Authenticator
- [ ] **App configuration:** Settings poussés automatiquement
- [ ] **MAM (Mobile Application Management):** Activé pour BYOD

### Security Baselines
- [ ] **Windows 10/11 baseline:** Appliquée
- [ ] **Microsoft Edge baseline:** Appliquée
- [ ] **Microsoft 365 Apps baseline:** Appliquée
- [ ] **Deviation reports:** Monitoring mensuel

---

## 💰 7. LICENSES & COST OPTIMIZATION

### License Management
- [ ] **License assignments:** Basées sur groups (pas utilisateur par utilisateur)
- [ ] **Unused licenses:** Audit mensuel et réaffectation
- [ ] **Over-licensing:** Identifier users avec features non-utilisées
- [ ] **Under-licensing:** Users sans features nécessaires identifiés

### Usage Analytics
- [ ] **Microsoft 365 usage reports:** Consultés mensuellement
- [ ] **Adoption score:** Monitoring et amélioration
- [ ] **Inactive users:** Processus de désactivation (60 jours inactifs)
- [ ] **License optimization:** Analysis trimestrielle

---

## 📊 8. MONITORING & REPORTING

### Service Health
- [ ] **Service health dashboard:** Consulté quotidiennement
- [ ] **Maintenance notifications:** Routées vers équipe IT
- [ ] **Incident subscriptions:** Configurées pour services critiques

### Reports configurés
- [ ] **Security & Compliance reports:** Générés mensuellement
- [ ] **Usage reports:** Par service (Exchange, Teams, SharePoint)
- [ ] **DLP incident reports:** Hebdomadaires
- [ ] **Sign-in reports:** Anomalies reviewées hebdomadairement

### Alerting
- [ ] **Azure Monitor:** Intégré si infrastructure hybrid
- [ ] **Security alerts:** Routées vers SOC/équipe sécurité
- [ ] **Thresholds:** Définis pour métriques clés

---

## 🔄 9. BACKUP & DISASTER RECOVERY

### Backups
- [ ] **Third-party backup:** Configuré (Veeam, AvePoint, etc.)
  - [ ] Exchange mailboxes
  - [ ] SharePoint sites
  - [ ] OneDrive
  - [ ] Teams data
- [ ] **Backup testing:** Restore testé trimestriellement
- [ ] **Retention:** Selon politiques compliance

### Business Continuity
- [ ] **DR plan:** Documenté et testé annuellement
- [ ] **RTO/RPO:** Définis pour chaque service
- [ ] **Failover procedures:** Documentées
- [ ] **Communication plan:** Défini pour outages

---

## 📚 10. GOVERNANCE & DOCUMENTATION

### Policies et Standards
- [ ] **Acceptable Use Policy:** Publié et accepté par users
- [ ] **Data Classification Policy:** Défini et communiqué
- [ ] **Retention Policy:** Documenté
- [ ] **Security Standards:** Basés sur CIS Benchmarks ou équivalent

### Documentation technique
- [ ] **Architecture diagrams:** À jour
- [ ] **Network topology:** Documentée (si hybrid)
- [ ] **Runbooks:** Créés pour tâches récurrentes
- [ ] **Contacts et escalation:** Liste à jour

### Training et awareness
- [ ] **Admin training:** Formation continue planifiée
- [ ] **User training:** Onboarding et refreshers annuels
- [ ] **Security awareness:** Phishing simulations trimestrielles
- [ ] **Knowledge base:** Accessible et maintenue

---

## ✅ VALIDATION FINALE

### Secure Score Targets
- [ ] **Microsoft Secure Score:** > 85%
- [ ] **Compliance Score:** > 80%
- [ ] **Identity Secure Score:** > 80%

### Audit externe
- [ ] **Last audit date:** [Date]
- [ ] **Audit findings:** Tous résolus ou avec plan mitigation
- [ ] **Next audit:** [Date planifiée]

### Sign-off
- [ ] **IT Manager:** [Nom] - [Date]
- [ ] **Security Lead:** [Nom] - [Date]
- [ ] **Compliance Officer:** [Nom] - [Date]

---

## 📝 NOTES

**Date de la revue:** ___________  
**Révisé par:** ___________  
**Score de conformité:** _____ / 100  
**Prochaine revue:** ___________

**Actions prioritaires identifiées:**
1. ___________________________________________
2. ___________________________________________
3. ___________________________________________

---

*Checklist version 1.0 - IT-CloudMaster*  
*Basée sur Microsoft 365 Best Practices et CIS Benchmarks*

---
## CHECKLIST — POSTCHECK (Generic Windows Server)
**Source :** `40_CHECKLISTS/CHECKLIST_MAINTENANCE_Postcheck-Generic_V1.md`

- [ ] Host en ligne (ping/RMM)
- [ ] Services critiques OK
- [ ] Event Logs post-action: Kernel-Power, disk/NTFS, service failures
- [ ] Pending reboot = False (ou expliqué)
- [ ] App/partage/URL test rapide
- [ ] Monitoring back to green / alertes normalisées
- [ ] Backups: pas d'échec post-reprise

---
## CHECKLIST_MAINTENANCE_Pre-Maintenance_V1
**Source :** `40_CHECKLISTS/CHECKLIST_MAINTENANCE_Pre-Maintenance_V1.md`

**Agent :** IT-MaintenanceMaster, IT-Assistant-N3
**Usage :** Avant toute maintenance planifiée (patching, redémarrage, déploiement)
**Mis à jour :** 2026-03-20

---

## PRÉ-MAINTENANCE — À compléter AVANT de commencer

### Contexte et autorisation
- [ ] Billet CW ouvert : #_______
- [ ] Fenêtre de maintenance confirmée : _______ à _______ (heure locale)
- [ ] Approbation reboots obtenue : ☐ Oui  ☐ Non requis
- [ ] Client informé (email/Teams J-48h) : ☐ Fait  ☐ Non requis
- [ ] Équipe IT briefée : ☐ Fait  ☐ Solo

### Backup et snapshots
- [ ] Backup récent confirmé (< 24h) pour chaque serveur critique
- [ ] Snapshot créé sur VMs critiques (avec nom conforme : @[Ticket]_Preboot_[VM]_SNAP_[Date])
- [ ] Point de restauration Datto validé (screenshot présent)
- [ ] Dernière restauration testée (mensuel) : ☐ OK  ☐ Non vérifié

### Vérifications système (par serveur)
- [ ] Espace disque > 10% libre sur C: et volumes data
- [ ] Services critiques démarrés et stables
- [ ] Pending reboot = False (ou reboot planifié dans cette fenêtre)
- [ ] Event Log : aucune erreur critique récente non résolue
- [ ] Sessions RDS actives vérifiées (si reboot prévu : utilisateurs avertis)

### Monitoring et accès
- [ ] Mode maintenance activé dans RMM (Datto RMM / N-able / CW RMM)
- [ ] Accès admin validé (RDP / RMM / Console)
- [ ] VPN connecté si intervention à distance
- [ ] Numéro de contact client d'urgence noté : _______

### Ordre d'intervention (pour plusieurs serveurs)
```
Ordre recommandé (critiques en dernier) :
1. Serveurs non-critiques / secondaires
2. Serveurs applicatifs (ERP, web, app)
3. Serveurs SQL / bases de données
4. Serveurs de fichiers
5. RDS / accès distant
6. Domain Controllers (en dernier — un seul à la fois)
```

### GO / NO-GO
- [ ] Toutes les cases ci-dessus validées → **GO**
- [ ] Au moins un item bloquant non résolu → **NO-GO — documenter dans CW et reprogrammer**

---
## CHECKLIST — PRECHECK (Generic Windows Server)
**Source :** `40_CHECKLISTS/CHECKLIST_MAINTENANCE_Precheck-Generic_V1.md`

- [ ] Uptime / last boot
- [ ] Pending reboot (CBS/WU/PendingFileRename/CCM)
- [ ] CPU/RAM (si perf incident)
- [ ] Disques (C: + volumes data) — espace libre
- [ ] Services critiques (selon rôle)
- [ ] Sessions (RDS) si reboot prévu
- [ ] Event Logs: System/Application (Errors/Critical sur 1–2h)
- [ ] Backups : dernier job OK (si maintenance)
- [ ] Monitoring: alertes actives vs baseline

---
## CHECKLIST_MASTER_Compliance-et-BestPractices_V1
**Source :** `40_CHECKLISTS/CHECKLIST_MASTER_Compliance-et-BestPractices_V1.md`

**Agent :** IT-MaintenanceMaster, IT-SecurityMaster
**Usage :** Vérification trimestrielle de la conformité MSP et des bonnes pratiques
**Mis à jour :** 2026-03-20

---

## DOCUMENTATION CLIENT (Hudu / edocs)

- [ ] Fiche de chaque serveur critique à jour (OS, rôle, IP de gestion → Passportal)
- [ ] Fiche de chaque solution backup configurée
- [ ] Fiche des équipements réseau (firewall, switches) à jour
- [ ] Contacts d'urgence à jour (responsable IT, décideur pour DR)
- [ ] Plan de relève documenté et à jour (< 6 mois)
- [ ] Aucun champ `[À COMPLÉTER]` publié sans valeur

---

## GESTION DES ACCÈS

- [ ] Tous les credentials dans Passportal (zéro MDP dans CW, Hudu, emails)
- [ ] Comptes de service documentés avec leur usage et leur rotation planifiée
- [ ] Accès client révoqués pour les techniciens qui ont quitté l'équipe
- [ ] MFA actif sur tous les portails MSP (CW, Datto, N-able, M365 admin)

---

## TICKETS ET PROCESSUS

- [ ] Aucun ticket P1/P2 ouvert sans technicien assigné
- [ ] Billets > 14 jours sans activité identifiés et traités
- [ ] Notes internes sur tous les billets actifs (pas de billets sans contexte)
- [ ] Closures CW : toutes avec Note Interne + Discussion client-safe

---

## COMMUNICATION CLIENT

- [ ] Rapport mensuel envoyé pour les clients sous contrat (< 5 jours après fin de mois)
- [ ] QBR planifié pour les clients stratégiques (trimestriel)
- [ ] Aucun incident P1 non documenté avec postmortem

---

## OUTILS ET MONITORING

- [ ] Agents RMM déployés sur 100% des serveurs et postes gérés
- [ ] Alertes critiques configurées : CPU, RAM, disque, service critique, offline
- [ ] Mode maintenance RMM utilisé systématiquement lors des interventions
- [ ] Seuils d'alerte révisés (pas les valeurs par défaut génériques)

---

## SÉCURITÉ OPÉRATIONNELLE

- [ ] Logs firewall activés sur tous les sites
- [ ] Rapport EDR vérifié (alertes ouvertes / fermées)
- [ ] Patchs critiques (CVSS ≥ 7.0) appliqués dans les 30 jours sur tous les serveurs
- [ ] Aucun RDP exposé directement sur Internet

---

## RÉSULTAT

**Conformité globale :** _______ / _______ items
**Effectué par :** _______ | **Date :** _______ | **Prochain audit :** _______
**Actions prioritaires :**
1. _______
2. _______

---
## CHECKLIST LIBRARY — IT-Assistant-N3 (MASTER)
**Source :** `40_CHECKLISTS/CHECKLIST_MASTER_Library-IT_V1.md`

**Version :** 1.0 | **Date :** 2026-03-15 | **Agent :** IT-AssistanTI-N3, IT-AssistanTI-N2, IT-UrgenceMaster, IT-MaintenanceMaster, IT-BackupMaster, IT-AssistantFrontline
**Source :** 18 fichiers analysés → 9 stubs exclus → 6 checklists uniques

---

## TABLE DES MATIÈRES

| # | Catégorie | Checklist | Usage |
|---|-----------|-----------|-------|
| 1.1 | Intervention | KICKOFF Ticket | Début de chaque billet MSP |
| 1.2 | Intervention | PRECHECK Generic Windows | Avant toute action sur serveur |
| 1.3 | Intervention | POSTCHECK Generic Windows | Après toute action sur serveur |
| 1.4 | Intervention | CLOSEOUT ConnectWise | Fermeture billet CW |
| 1.5 | Intervention | Intevention live | Intervention du début à la fin |
| 2.1 | Cloud | M365 Configuration Best Practices | Audit/config Microsoft 365 |
| 2.2 | Cloud | Azure VM Deployment | Déploiement VM Azure |
| 3.1 | Report| Report KPIs MSP Mesuel | Report KPIs MSP CW et RMM |
| 4.1 | BackUp| Veeam - Datto - Keepit - DR | Vérification mensuelle de la disponibilité du plan de relève |


---

---
# SECTION 1 — INTERVENTION MSP
---

## 1.1 — KICKOFF TICKET (Remplir au début de chaque intervention)

# CHECKLIST — KICKOFF (Ticket MSP)

Copier-coller et remplir au début :

- Ticket: #
- Client: 
- Type: NOC | Support | Change | Maintenance
- Fenêtre: (Début–Fin + TZ)
- Urgence/SLA: 
- Scope (serveurs/services): 
- Contraintes: (prod, VIP, no-touch, 1 serveur critique à la fois, etc.)
- Risques connus: 
- Objectif (succès): 
- Outils: (RMM/VPN/Portal)


---

## 1.2 — PRECHECK GENERIC (Windows Server — avant toute action)

# CHECKLIST — PRECHECK (Generic Windows Server)

- [ ] Uptime / last boot
- [ ] Pending reboot (CBS/WU/PendingFileRename/CCM)
- [ ] CPU/RAM (si perf incident)
- [ ] Disques (C: + volumes data) — espace libre
- [ ] Services critiques (selon rôle)
- [ ] Sessions (RDS) si reboot prévu
- [ ] Event Logs: System/Application (Errors/Critical sur 1–2h)
- [ ] Backups : dernier job OK (si maintenance)
- [ ] Monitoring: alertes actives vs baseline


---

## 1.3 — POSTCHECK GENERIC (Windows Server — après toute action)

# CHECKLIST — POSTCHECK (Generic Windows Server)

- [ ] Host en ligne (ping/RMM)
- [ ] Services critiques OK
- [ ] Event Logs post-action: Kernel-Power, disk/NTFS, service failures
- [ ] Pending reboot = False (ou expliqué)
- [ ] App/partage/URL test rapide
- [ ] Monitoring back to green / alertes normalisées
- [ ] Backups: pas d'échec post-reprise


---

## 1.4 — CLOSEOUT CONNECTWISE (Fermeture billet)

# CHECKLIST — CLOSEOUT (ConnectWise)

- [ ] CW_NOTE_INTERNE : timeline + commandes + outputs + décisions + suivis
- [ ] CW_DISCUSSION (STAR) : facturable, concis, sans IP
- [ ] Email client : clair + résultat + suivi
- [ ] Teams : début/fin
- [ ] KB draft (si récurrent)


---
## 1.5 CHECKLIST_MAINTENANCE_Pre-Maintenance_V1
**Agent :** IT-MaintenanceMaster, IT-Assistant-N3
**Usage :** Avant toute maintenance planifiée (patching, redémarrage, déploiement)
**Mis à jour :** 2026-03-20


---

## PRÉ-MAINTENANCE — À compléter AVANT de commencer

### Contexte et autorisation
- [ ] Billet CW ouvert : #_______
- [ ] Fenêtre de maintenance confirmée : _______ à _______ (heure locale)
- [ ] Approbation reboots obtenue : ☐ Oui  ☐ Non requis
- [ ] Client informé (email/Teams J-48h) : ☐ Fait  ☐ Non requis
- [ ] Équipe IT briefée : ☐ Fait  ☐ Solo

### Backup et snapshots
- [ ] Backup récent confirmé (< 24h) pour chaque serveur critique
- [ ] Snapshot créé sur VMs critiques (avec nom conforme : @[Ticket]_Preboot_[VM]_SNAP_[Date])
- [ ] Point de restauration Datto validé (screenshot présent)
- [ ] Dernière restauration testée (mensuel) : ☐ OK  ☐ Non vérifié

### Vérifications système (par serveur)
- [ ] Espace disque > 10% libre sur C: et volumes data
- [ ] Services critiques démarrés et stables
- [ ] Pending reboot = False (ou reboot planifié dans cette fenêtre)
- [ ] Event Log : aucune erreur critique récente non résolue
- [ ] Sessions RDS actives vérifiées (si reboot prévu : utilisateurs avertis)

### Monitoring et accès
- [ ] Mode maintenance activé dans RMM (Datto RMM / N-able / CW RMM)
- [ ] Accès admin validé (RDP / RMM / Console)
- [ ] VPN connecté si intervention à distance
- [ ] Numéro de contact client d'urgence noté : _______

### Ordre d'intervention (pour plusieurs serveurs)
```
Ordre recommandé (critiques en dernier) :
1. Serveurs non-critiques / secondaires
2. Serveurs applicatifs (ERP, web, app)
3. Serveurs SQL / bases de données
4. Serveurs de fichiers
5. RDS / accès distant
6. Domain Controllers (en dernier — un seul à la fois)
```

### GO / NO-GO
- [ ] Toutes les cases ci-dessus validées → **GO**
- [ ] Au moins un item bloquant non résolu → **NO-GO — documenter dans CW et reprogrammer**


---

# SECTION 2 — CLOUD
---

## 2.1 — M365 CONFIGURATION BEST PRACTICES (Audit complet Microsoft 365)

# CHECKLIST: Microsoft 365 Configuration Best Practices

## Métadonnées
- **Version:** 1.0
- **Dernière mise à jour:** Février 2026
- **Applicable à:** Microsoft 365 (E3/E5, Business Premium)
- **Durée estimation:** 2-3 heures (audit complet)

---

## 🔐 1. SÉCURITÉ & IDENTITÉ

### Azure Active Directory

#### Configuration de base
- [ ] **Noms de domaine personnalisés** configurés et vérifiés
- [ ] **Licences AAD Premium P1/P2** assignées si nécessaire
- [ ] **Self-service password reset** activé pour tous utilisateurs
- [ ] **Password protection** activé (bannir mots de passe faibles)
- [ ] **Smart Lockout** configuré (seuil: 10 tentatives, durée: 60 sec)

#### Authentification multi-facteurs (MFA)
- [ ] **MFA activé** pour tous les administrateurs (100% requis)
- [ ] **MFA encouragé** pour tous les utilisateurs (cible: 95%+)
- [ ] **Méthodes MFA** configurées: Microsoft Authenticator (recommandé), SMS backup
- [ ] **Trusted IPs** définis pour bypass conditionnel
- [ ] **App passwords** désactivés (sauf exceptions documentées)

#### Conditional Access
- [ ] **Politique 1:** Bloquer legacy authentication pour tous utilisateurs
- [ ] **Politique 2:** Exiger MFA pour tous les admins
- [ ] **Politique 3:** Exiger MFA pour accès Azure Management
- [ ] **Politique 4:** Exiger devices compliant pour accès données sensibles
- [ ] **Politique 5:** Bloquer accès depuis pays non-autorisés
- [ ] **Politique 6:** Exiger MFA pour accès à partir d'unknown locations
- [ ] **Mode Report-Only** testé avant activation
- [ ] **Break-glass account** exclu des politiques CA (documenté)

#### Comptes privilégiés
- [ ] **Global Admins:** Maximum 5 comptes (moins c'est mieux)
- [ ] **Break-glass accounts:** 2 comptes cloud-only avec MFA TOTP
- [ ] **Admin roles:** Assignés selon principe moindre privilège
- [ ] **PIM (Privileged Identity Management):** Activé pour rôles sensibles (E5 requis)
- [ ] **Admin accounts:** Noms standardisés (ex: admin-jtremblay@domain.com)
- [ ] **Monitoring alertes:** Configuré pour changements admin

### Microsoft Defender

#### Microsoft Defender for Office 365 (Plan 1/2)
- [ ] **Safe Links** activé pour emails et Teams
- [ ] **Safe Attachments** activé avec action "Block"
- [ ] **Anti-phishing policies** configurées (detect impersonation)
- [ ] **Spoof intelligence** activé
- [ ] **Quarantine policies** définies
- [ ] **Zero-hour auto purge (ZAP)** activé pour spam et phishing
- [ ] **Mail flow rules** pour bloquer file types dangereux (.exe, .js, .vbs, etc.)

#### Microsoft Defender for Endpoint (si applicable)
- [ ] **Onboarding** complété pour tous devices
- [ ] **Attack Surface Reduction (ASR)** rules activées
- [ ] **Controlled Folder Access** configuré
- [ ] **Alerts** routées vers Security Operations

#### Security Baselines
- [ ] **Microsoft 365 Security Baseline** appliqué via Intune
- [ ] **Windows Security Baseline** appliqué pour devices Windows
- [ ] **Deviation reports** générés mensuellement

---

## 📧 2. EXCHANGE ONLINE

### Configuration globale
- [ ] **Accepted domains** ajoutés et validés
- [ ] **Mail flow (connectors)** configurés si hybrid ou tierce partie
- [ ] **SPF record** publié (v=spf1 include:spf.protection.outlook.com -all)
- [ ] **DKIM signing** activé pour tous domaines
- [ ] **DMARC record** publié (p=quarantine minimum, p=reject recommandé)
- [ ] **MX records** pointent vers Exchange Online (.mail.protection.outlook.com)

### Protection anti-spam et malware
- [ ] **Anti-spam policies:** Configured (default + custom si besoin)
- [ ] **Anti-malware policies:** Action = Delete, notifications activées
- [ ] **Outbound spam filter:** Alertes configurées pour compromission compte
- [ ] **Quarantine notifications:** Envoyées aux utilisateurs (digest quotidien)

### Retention et compliance
- [ ] **Retention policies** définies (minimum: 7 ans pour emails conformité)
- [ ] **Litigation hold** activé pour utilisateurs clés si requis
- [ ] **Archive mailboxes** activés pour tous (ou selon licence)
- [ ] **Auto-expanding archive** activé si croissance prévue
- [ ] **Journaling** configuré si requis par compliance

### Délégation et partage
- [ ] **Shared mailboxes:** Permissions déléguées, pas de licences assignées
- [ ] **Calendar sharing policies:** Limitées (default = Limited Details only)
- [ ] **External sharing:** Contrôlé (pas de sharing automatique)
- [ ] **Distribution groups:** Ownership défini, moderation activée si public

### Quotas et limites
- [ ] **Mailbox quotas:** IssueWarning=45GB, ProhibitSend=48GB, ProhibitReceive=50GB
- [ ] **Send/Receive limits:** Defaults acceptables (150MB attachments)
- [ ] **Recipient limits:** 500/jour par utilisateur (default)

---

## 👥 3. SHAREPOINT ONLINE & ONEDRIVE

### Administration et gouvernance
- [ ] **Sharing settings:**
  - [ ] External sharing = "Only people in organization" (ou "New and existing guests" si nécessaire)
  - [ ] Default link type = "Specific people"
  - [ ] Default permission = "View"
- [ ] **Access control:** Require sign-in pour accès externe
- [ ] **Idle session timeout:** Configuré (recommandé: 1 heure)
- [ ] **Legacy authentication:** Bloquée

### OneDrive
- [ ] **Storage quota:** Défini par utilisateur (1TB default avec E3)
- [ ] **Sync restrictions:** Limiter à devices corporate (AAD joined/Hybrid)
- [ ] **Known Folder Move:** Déployé via GPO (Desktop, Documents, Pictures)
- [ ] **Files On-Demand:** Activé par défaut
- [ ] **Retention for deleted users:** 365 jours minimum

### Sites et Hub Sites
- [ ] **Site creation:** Contrôlé (approval required ou self-service géré)
- [ ] **Hub sites:** Structure définie (max 3 niveaux)
- [ ] **Site owners:** Minimum 2 par site
- [ ] **Inactive sites:** Politique de cleanup définie (ex: archiver après 180 jours inactifs)

### DLP et Information Protection
- [ ] **DLP policies:** Actives pour SharePoint/OneDrive
  - [ ] Bloquer partage CCN, SIN, données santé
  - [ ] Alertes configurées pour violations
- [ ] **Sensitivity labels:** Publiées et utilisées
  - [ ] Public, Internal, Confidential, Highly Confidential
  - [ ] Auto-labeling configuré si E5
- [ ] **Versioning:** Activé (500 versions par défaut)
- [ ] **Recycle bin:** 93 jours rétention (default)

---

## 💬 4. MICROSOFT TEAMS

### Configuration organisation
- [ ] **External access (federation):** Configuré selon politiques
  - [ ] Domaines autorisés/bloqués listés
  - [ ] Skype for Business federation si requis
- [ ] **Guest access:** Activé avec restrictions appropriées
  - [ ] Require MFA pour guests
  - [ ] Limiter fonctionnalités guests (pas de apps par défaut)
- [ ] **Teams creation:** Contrôlé (approval ou groupes autorisés)
- [ ] **Naming policy:** Appliquée (préfixes/suffixes, blocked words)

### Sécurité et compliance
- [ ] **Retention policies:** Configurées pour Teams messages et files
- [ ] **DLP policies:** Actives pour Teams conversations
- [ ] **Meeting policies:**
  - [ ] Lobby pour external participants
  - [ ] Recording = disabled par défaut (ou controlled)
  - [ ] Transcription selon besoins compliance
- [ ] **Chat permissions:** Restrict Giphy, memes si nécessaire
- [ ] **External apps:** Catalog contrôlé (block by default, allow liste)

### Voice et Calling (si applicable)
- [ ] **Calling policies:** Définies par groupe d'utilisateurs
- [ ] **Emergency addresses:** Configurées pour tous sites
- [ ] **Call routing:** Dial plans et routes configurés
- [ ] **Auto attendants:** Configurés avec fallback

### Usage et adoption
- [ ] **Teams analytics:** Monitoring activé
- [ ] **Usage reports:** Consultés mensuellement
- [ ] **Inactive teams:** Archivage automatique configuré (180+ jours)
- [ ] **Training resources:** Disponibles pour utilisateurs

---

## 🛡️ 5. SÉCURITÉ & COMPLIANCE CENTER

### Data Loss Prevention (DLP)
- [ ] **DLP policies actives:**
  - [ ] Exchange (email)
  - [ ] SharePoint/OneDrive (documents)
  - [ ] Teams (conversations)
  - [ ] Endpoints (si Defender for Endpoint)
- [ ] **Sensitive info types:** Customisés pour organisation
  - [ ] Numéros assurance sociale (SIN)
  - [ ] Numéros cartes crédit
  - [ ] Données spécifiques industrie
- [ ] **Policy tips:** Activés pour éduquer utilisateurs
- [ ] **Incident reports:** Envoyés à admins DLP

### Information Protection
- [ ] **Sensitivity labels:** Créées et publiées
- [ ] **Label policies:** Assignées aux bons groupes
- [ ] **Auto-labeling:** Configuré si E5 (basé sur sensitive info types)
- [ ] **Encryption:** Configurée pour labels "Confidential" et "Highly Confidential"
- [ ] **Visual markings:** Headers/footers/watermarks configurés

### Retention Policies
- [ ] **Retention policies:**
  - [ ] Email: 7 ans minimum
  - [ ] SharePoint/OneDrive: 7 ans minimum
  - [ ] Teams: Selon besoins légaux
- [ ] **Disposition review:** Processus défini pour fin de rétention
- [ ] **Preservation lock:** Appliqué aux politiques légales

### Audit et Monitoring
- [ ] **Unified Audit Logging:** Activé (obligatoire)
- [ ] **Audit retention:** 90 jours (E3) ou 1 an (E5/add-on)
- [ ] **Alert policies:** Configurées pour activités critiques
  - [ ] Création de forwarding rules
  - [ ] Mass download SharePoint
  - [ ] Elevation to admin
  - [ ] External sharing
- [ ] **Compliance Manager:** Score > 80% (cible)

### eDiscovery
- [ ] **eDiscovery cases:** Process défini
- [ ] **Custodians:** Formation fournie à legal team
- [ ] **Advanced eDiscovery:** Configuré si E5

---

## 📱 6. DEVICE MANAGEMENT (INTUNE)

### Enrollment et configuration
- [ ] **Auto-enrollment:** Configuré pour devices AAD joined
- [ ] **Device categories:** Définies (Corporate, BYOD, Kiosk, etc.)
- [ ] **Compliance policies:** Créées par plateforme (Windows, iOS, Android)
  - [ ] Require encryption
  - [ ] Minimum OS version
  - [ ] Require antivirus
  - [ ] Screen lock settings
- [ ] **Configuration profiles:** Déployés
  - [ ] Wi-Fi settings
  - [ ] VPN settings  
  - [ ] Email profiles
  - [ ] Certificates

### Application Management
- [ ] **App protection policies:** Configurées (Managed Apps)
- [ ] **Required apps:** Déployées via Intune
  - [ ] Microsoft 365 Apps
  - [ ] Company Portal
  - [ ] Authenticator
- [ ] **App configuration:** Settings poussés automatiquement
- [ ] **MAM (Mobile Application Management):** Activé pour BYOD

### Security Baselines
- [ ] **Windows 10/11 baseline:** Appliquée
- [ ] **Microsoft Edge baseline:** Appliquée
- [ ] **Microsoft 365 Apps baseline:** Appliquée
- [ ] **Deviation reports:** Monitoring mensuel

---

## 💰 7. LICENSES & COST OPTIMIZATION

### License Management
- [ ] **License assignments:** Basées sur groups (pas utilisateur par utilisateur)
- [ ] **Unused licenses:** Audit mensuel et réaffectation
- [ ] **Over-licensing:** Identifier users avec features non-utilisées
- [ ] **Under-licensing:** Users sans features nécessaires identifiés

### Usage Analytics
- [ ] **Microsoft 365 usage reports:** Consultés mensuellement
- [ ] **Adoption score:** Monitoring et amélioration
- [ ] **Inactive users:** Processus de désactivation (60 jours inactifs)
- [ ] **License optimization:** Analysis trimestrielle

---

## 📊 8. MONITORING & REPORTING

### Service Health
- [ ] **Service health dashboard:** Consulté quotidiennement
- [ ] **Maintenance notifications:** Routées vers équipe IT
- [ ] **Incident subscriptions:** Configurées pour services critiques

### Reports configurés
- [ ] **Security & Compliance reports:** Générés mensuellement
- [ ] **Usage reports:** Par service (Exchange, Teams, SharePoint)
- [ ] **DLP incident reports:** Hebdomadaires
- [ ] **Sign-in reports:** Anomalies reviewées hebdomadairement

### Alerting
- [ ] **Azure Monitor:** Intégré si infrastructure hybrid
- [ ] **Security alerts:** Routées vers SOC/équipe sécurité
- [ ] **Thresholds:** Définis pour métriques clés

---

## 🔄 9. BACKUP & DISASTER RECOVERY

### Backups
- [ ] **Third-party backup:** Configuré (Veeam, AvePoint, etc.)
  - [ ] Exchange mailboxes
  - [ ] SharePoint sites
  - [ ] OneDrive
  - [ ] Teams data
- [ ] **Backup testing:** Restore testé trimestriellement
- [ ] **Retention:** Selon politiques compliance

### Business Continuity
- [ ] **DR plan:** Documenté et testé annuellement
- [ ] **RTO/RPO:** Définis pour chaque service
- [ ] **Failover procedures:** Documentées
- [ ] **Communication plan:** Défini pour outages

---

## 📚 10. GOVERNANCE & DOCUMENTATION

### Policies et Standards
- [ ] **Acceptable Use Policy:** Publié et accepté par users
- [ ] **Data Classification Policy:** Défini et communiqué
- [ ] **Retention Policy:** Documenté
- [ ] **Security Standards:** Basés sur CIS Benchmarks ou équivalent

### Documentation technique
- [ ] **Architecture diagrams:** À jour
- [ ] **Network topology:** Documentée (si hybrid)
- [ ] **Runbooks:** Créés pour tâches récurrentes
- [ ] **Contacts et escalation:** Liste à jour

### Training et awareness
- [ ] **Admin training:** Formation continue planifiée
- [ ] **User training:** Onboarding et refreshers annuels
- [ ] **Security awareness:** Phishing simulations trimestrielles
- [ ] **Knowledge base:** Accessible et maintenue

---

## ✅ VALIDATION FINALE

### Secure Score Targets
- [ ] **Microsoft Secure Score:** > 85%
- [ ] **Compliance Score:** > 80%
- [ ] **Identity Secure Score:** > 80%

### Audit externe
- [ ] **Last audit date:** [Date]
- [ ] **Audit findings:** Tous résolus ou avec plan mitigation
- [ ] **Next audit:** [Date planifiée]

### Sign-off
- [ ] **IT Manager:** [Nom] - [Date]
- [ ] **Security Lead:** [Nom] - [Date]
- [ ] **Compliance Officer:** [Nom] - [Date]

---

## 📝 NOTES

**Date de la revue:** ___________  
**Révisé par:** ___________  
**Score de conformité:** _____ / 100  
**Prochaine revue:** ___________

**Actions prioritaires identifiées:**
1. ___________________________________________
2. ___________________________________________
3. ___________________________________________

---

*Checklist version 1.0 - IT-CloudMaster*  
*Basée sur Microsoft 365 Best Practices et CIS Benchmarks*


---

## 2.2 — AZURE VM DEPLOYMENT (Déploiement complet)

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


---

# SECTION 3 — BackUp (NOC)
---

## 3.1 — — CHECKLIST_BACKUP_DR-Readiness_V1 
**Agent :** IT-BackupDRMaster, IT-MaintenanceMaster
**Usage :** Vérification mensuelle de la disponibilité du plan de relève
**Mis à jour :** 2026-03-20

---

## BACKUPS — ÉTAT COURANT

### Datto BCDR
- [ ] Tous les agents : dernier backup Success ou Warning acceptable
- [ ] Screenshot de vérification présent pour les VMs critiques
- [ ] Stockage local Datto : espace libre > 20%
- [ ] Stockage cloud : synchronisation OK (pas d'erreur > 24h)
- [ ] Rétention configurée selon la politique client (Hudu → Agreements)

### Veeam
- [ ] Jobs en cours : Success ou Warning acceptable
- [ ] Repository : espace libre > 20%
- [ ] Dernière vérification d'intégrité (SureBackup ou Instant Recovery test) < 30 jours
- [ ] Veeam Cloud Connect (si applicable) : synchronisation OK

### Keepit (M365)
- [ ] Connecteur Microsoft 365 : Connected (pas Disconnected)
- [ ] Dernière synchronisation Exchange : OK
- [ ] Dernière synchronisation SharePoint/OneDrive : OK
- [ ] Nombre d'utilisateurs protégés = nombre d'utilisateurs actifs

---

## PLAN DE RELÈVE — VALIDITÉ

- [ ] Document DR à jour dans Hudu pour ce client (date < 6 mois)
- [ ] Contacts d'urgence à jour (responsable client, MSP on-call)
- [ ] RTO et RPO documentés et connus de l'équipe
- [ ] Ordre de démarrage des systèmes documenté
- [ ] Accès aux ressources de reprise validé (accès Datto portal, VPN, credentials Passportal)

---

## TESTS DR

- [ ] Dernier test d'intégrité backup : _______ (date)
  - Résultat : ☐ Pass  ☐ Fail → Actions correctives : _______
- [ ] Dernier test Instant Virtualization : _______ (date)
  - RTO mesuré : _______ min / Objectif : _______ min
- [ ] Prochain test planifié : _______

---

## VÉRIFICATION ANNUELLE

- [ ] Test complet DR (Tabletop ou Functional) effectué cette année : ☐ Oui  ☐ Non
- [ ] Rapport de test archivé dans CW/Hudu : ☐ Oui
- [ ] Écarts identifiés et corrigés : ☐ Oui  ☐ En cours : _______

---

## RÉSULTAT

☐ **DR READY** — Tous les items validés
☐ **ACTIONS REQUISES** — Items en attente : _______
☐ **NON READY** — Problème critique : escalade IT-BackupDRMaster immédiatement


---

# SECTION 4 — OPR
---

## 4.1 — CHECKLIST_REPORT_KPIs-MSP-Mensuels_V1
**Agent :** IT-ReportMaster
**Usage :** Collecte et validation des KPIs mensuels pour le rapport client
**Mis à jour :** 2026-04-04

---

## DONNÉES À COLLECTER (source : CW Manage + RMM)

### Tickets
- [ ] Nombre total de tickets ouverts dans le mois : _______
- [ ] Tickets P1 : _______ | P2 : _______ | P3 : _______ | P4 : _______
- [ ] MTTR (temps moyen résolution) P1 : _______ h | P2 : _______ h
- [ ] Taux de réouverture (reopen rate) : _______ %
- [ ] Tickets fermés dans le SLA : _______ %

### Disponibilité et performance
- [ ] Disponibilité infrastructure (uptime) — via RMM : _______ %
- [ ] Alertes critiques reçues : _______ | Traitées dans le SLA : _______ %
- [ ] Incidents P1/P2 ce mois : _______ | Avec postmortem : _______

### Sécurité
- [ ] Alertes EDR traitées : _______ | Incidents confirmés : _______
- [ ] Patchs critiques appliqués dans les 30 jours : _______ %
- [ ] Secure Score M365 ce mois : _______ (tendance ↑ ↓ =)

### Backup
- [ ] Taux de succès backup Datto/Veeam/Keepit : _______ %
- [ ] Tests DR effectués ce mois : ☐ Oui  ☐ Non | Résultat : _______
- [ ] Incidents backup P2+ : _______

---

## VALIDATION AVANT ENVOI DU RAPPORT

- [ ] Toutes les données collectées et vérifiées
- [ ] Incidents P1/P2 avec postmortem joints si applicable
- [ ] Recommandations du mois rédigées (3 max, actionnables)
- [ ] Rapport relu pour ne pas inclure : IPs internes, noms de serveurs sensibles, CVE détaillés
- [ ] Rapport envoyé au contact client dans les 5 jours ouvrables après fin de mois

---

## SEUILS D'ALERTE (à signaler dans le rapport)

| KPI | Seuil normal | Seuil alerte |
|---|---|---|
| Disponibilité infra | > 99.5% | < 99% |
| Tickets dans le SLA | > 95% | < 90% |
| Taux succès backup | > 98% | < 95% |
| Patchs critiques | 100% dans 30j | < 90% |
| Secure Score | > 60% | < 40% |



## NOTES DE CONSOLIDATION

| Statistique | Valeur |
|-------------|--------|
| Fichiers source analysés | 15 |
| Stubs génériques exclus | 9 (boilerplate vide) |
| Doublons exacts | 0 |
| Checklists uniques retenues | 6 |

**Stubs exclus :** CHECKLIST__Best_Practices, CHECKLIST__Compliance, CHECKLIST__Configuration,
CHECKLIST__DR_Readiness, CHECKLIST__Intervention_Steps, CHECKLIST__KPIs,
CHECKLIST__Pre_Maintenance, CHECKLIST__Security, CHECKLIST__Shift_Handover

---
## CHECKLIST_NOC_Shift-Handover_V1
**Source :** `40_CHECKLISTS/CHECKLIST_NOC_Shift-Handover_V1.md`

**Agent :** IT-Commandare-NOCDispatcher, IT-Commandare-NOC
**Usage :** Passation de quart entre techniciens NOC
**Mis à jour :** 2026-03-20

---

## PASSATION DE QUART — TECHNICIEN SORTANT

**Date/Heure :** _______ | **Technicien sortant :** _______ | **Entrant :** _______

### Incidents actifs en cours

| Billet CW | Client | Priorité | Statut | Prochaine action | ETA |
|---|---|---|---|---|---|
| #_______ | _______ | P___ | _______ | _______ | _______ |
| #_______ | _______ | P___ | _______ | _______ | _______ |

### Alertes RMM non acquittées

- [ ] Vérifier dans Datto RMM / N-able / CW RMM les alertes actives non traitées
- [ ] Alertes acquittées et documentées : ☐ Oui
- [ ] Alertes laissées en attente (avec raison) : _______

### Maintenances en cours ou prévues dans le quart suivant

| Client | Type | Fenêtre | Billet CW | Technicien assigné |
|---|---|---|---|---|
| _______ | _______ | _______ à _______ | #_______ | _______ |

### Points d'attention pour le quart suivant

- [ ] Client en surveillance renforcée : _______
- [ ] Serveur instable à surveiller : _______
- [ ] Backup en attente de validation : _______
- [ ] Fenêtre de maintenance à déclencher : _______
- [ ] Escalade prévue : _______

### Vérifications de fin de quart

- [ ] Tous les billets P1/P2 actifs ont un technicien assigné pour le quart suivant
- [ ] Mode maintenance RMM désactivé sur tous les assets (sauf si maintenance en cours documentée)
- [ ] Notes de passation écrites dans CW sur les billets concernés
- [ ] Technicien entrant briefé verbalement sur les points critiques

---

## RÉCEPTION DE QUART — TECHNICIEN ENTRANT

- [ ] Lu et compris les incidents actifs ci-dessus
- [ ] Vérifié les alertes RMM (dashboard NOC)
- [ ] Confirmé les maintenances prévues dans mon quart
- [ ] Questions posées au technicien sortant : ☐ Aucune  ☐ Répondues

**Signature (entrée de quart) :** _______ à _______

---
## CHECKLIST_REPORT_KPIs-MSP-Mensuels_V1
**Source :** `40_CHECKLISTS/CHECKLIST_REPORT_KPIs-MSP-Mensuels_V1.md`

**Agent :** IT-ReportMaster
**Usage :** Collecte et validation des KPIs mensuels pour le rapport client
**Mis à jour :** 2026-03-20

---

## DONNÉES À COLLECTER (source : CW Manage + RMM)

### Tickets
- [ ] Nombre total de tickets ouverts dans le mois : _______
- [ ] Tickets P1 : _______ | P2 : _______ | P3 : _______ | P4 : _______
- [ ] MTTR (temps moyen résolution) P1 : _______ h | P2 : _______ h
- [ ] Taux de réouverture (reopen rate) : _______ %
- [ ] Tickets fermés dans le SLA : _______ %

### Disponibilité et performance
- [ ] Disponibilité infrastructure (uptime) — via RMM : _______ %
- [ ] Alertes critiques reçues : _______ | Traitées dans le SLA : _______ %
- [ ] Incidents P1/P2 ce mois : _______ | Avec postmortem : _______

### Sécurité
- [ ] Alertes EDR traitées : _______ | Incidents confirmés : _______
- [ ] Patchs critiques appliqués dans les 30 jours : _______ %
- [ ] Secure Score M365 ce mois : _______ (tendance ↑ ↓ =)

### Backup
- [ ] Taux de succès backup Datto/Veeam/Keepit : _______ %
- [ ] Tests DR effectués ce mois : ☐ Oui  ☐ Non | Résultat : _______
- [ ] Incidents backup P2+ : _______

---

## VALIDATION AVANT ENVOI DU RAPPORT

- [ ] Toutes les données collectées et vérifiées
- [ ] Incidents P1/P2 avec postmortem joints si applicable
- [ ] Recommandations du mois rédigées (3 max, actionnables)
- [ ] Rapport relu pour ne pas inclure : IPs internes, noms de serveurs sensibles, CVE détaillés
- [ ] Rapport envoyé au contact client dans les 5 jours ouvrables après fin de mois

---

## SEUILS D'ALERTE (à signaler dans le rapport)

| KPI | Seuil normal | Seuil alerte |
|---|---|---|
| Disponibilité infra | > 99.5% | < 99% |
| Tickets dans le SLA | > 95% | < 90% |
| Taux succès backup | > 98% | < 95% |
| Patchs critiques | 100% dans 30j | < 90% |
| Secure Score | > 60% | < 40% |

---
## CHECKLIST_SECURITY_Hardening-et-Audit_V1
**Source :** `40_CHECKLISTS/CHECKLIST_SECURITY_Hardening-et-Audit_V1.md`

**Agent :** IT-SecurityMaster, IT-Assistant-N3
**Usage :** Audit de sécurité périodique et vérification du hardening
**Mis à jour :** 2026-03-20

---

## IDENTITÉ ET ACCÈS (EntraID / AD)

- [ ] MFA activé pour tous les utilisateurs (minimum tous les admins)
- [ ] Accès conditionnel configuré (bloquer auth legacy, géo-restriction si applicable)
- [ ] Comptes admin dédiés : distinct des comptes utilisateurs quotidiens
- [ ] Comptes inactifs depuis > 90 jours désactivés
- [ ] Revue des membres Domain Admins / Global Administrators (< 5 personnes)
- [ ] Aucun compte de service avec MDP sans expiration non documenté
- [ ] Passportal à jour pour tous les comptes de service

---

## MESSAGERIE ET M365

- [ ] Defender for Office 365 actif (anti-phishing, anti-malware, Safe Links)
- [ ] Authentification basique (Legacy Auth) désactivée
- [ ] Règles de transport suspectes : aucune
- [ ] Transferts automatiques vers l'externe : aucun (ou documentés)
- [ ] Audit log M365 activé (Unified Audit Log)
- [ ] DKIM / DMARC / SPF configurés sur le domaine email
- [ ] Secure Score M365 vérifié : score actuel _______ / recommandé _______

---

## ENDPOINTS ET SERVEURS

- [ ] EDR déployé sur tous les serveurs et postes (SentinelOne / CrowdStrike / Defender XDR)
- [ ] Windows Update : patchs critiques < 30 jours sur tous les serveurs
- [ ] RDP exposé directement sur Internet : aucun (accès via VPN uniquement)
- [ ] Ports non utilisés fermés sur le firewall
- [ ] Comptes administrateurs locaux : mots de passe uniques par machine (LAPS si applicable)
- [ ] Firewall Windows activé sur tous les endpoints

---

## RÉSEAU ET PÉRIMÈTRE

- [ ] Firmware firewall à jour (WatchGuard / Fortinet / SonicWall / Meraki)
- [ ] Licences UTM/IPS actives (pas expirées)
- [ ] Certificats SSL VPN : expiration > 30 jours
- [ ] VLAN correctement segmentés (serveurs / utilisateurs / IoT séparés)
- [ ] Logs firewall activés et conservés > 90 jours
- [ ] Aucune règle "Any → Any Accept" non documentée

---

## BACKUP ET RÉSILIENCE

- [ ] Backups testés (voir CHECKLIST_BACKUP_DR-Readiness)
- [ ] Au moins 1 copie hors site (Datto cloud / Veeam Cloud / Keepit)
- [ ] Accès Passportal aux backups : restreint aux techniciens autorisés

---

## RÉSULTAT

| Zone | Status | Actions requises |
|---|---|---|
| Identité et accès | ☐ OK / ☐ Actions | |
| Messagerie M365 | ☐ OK / ☐ Actions | |
| Endpoints et serveurs | ☐ OK / ☐ Actions | |
| Réseau et périmètre | ☐ OK / ☐ Actions | |
| Backup et résilience | ☐ OK / ☐ Actions | |

**Score global :** _______ / 30 items
**Audit effectué par :** _______ | **Date :** _______ | **Billet CW :** #_______

---
## CHECKLIST_SUPPORT_Intervention-Steps_V1
**Source :** `40_CHECKLISTS/CHECKLIST_SUPPORT_Intervention-Steps_V1.md`

**Agent :** IT-Assistant-N2, IT-Assistant-N3, IT-MaintenanceMaster
**Usage :** Déroulement standard d'une intervention MSP de bout en bout
**Mis à jour :** 2026-03-20

---

## PHASE 1 — KICKOFF (5 min)

- [ ] Lire le billet CW complet (ne pas sauter cette étape)
- [ ] Identifier : client, type, priorité P[1/2/3/4], assets concernés
- [ ] Consulter la documentation client dans Hudu (fiche objet IT si applicable)
- [ ] Vérifier les notes précédentes sur le billet
- [ ] Confirmer la fenêtre de maintenance et les approbations si applicable

## PHASE 2 — PRECHECK (lecture seule)

- [ ] Ping / RMM : asset accessible ?
- [ ] Resources : CPU, RAM, espace disque
- [ ] Services critiques démarrés
- [ ] Pending reboot
- [ ] Event Logs : erreurs récentes (2-48h selon le contexte)
- [ ] Backups : dernier job OK ?
- [ ] Snapshot créé si action risquée

## PHASE 3 — INTERVENTION

- [ ] **Une action à la fois** — documenter chaque action dans le journal CW au fil de l'eau
- [ ] Valider le résultat de chaque action avant de passer à la suivante
- [ ] Tagger **[À CONFIRMER]** toute action sans preuve immédiate
- [ ] Si la situation se dégrade → réévaluer la priorité → escalader si P2→P1
- [ ] Ne pas improviser hors scope sans documenter et obtenir validation

## PHASE 4 — POSTCHECK (validation)

- [ ] Services critiques : OK
- [ ] Connectivité / accès utilisateurs : OK
- [ ] Application ou service cible : fonctionnel et testé
- [ ] Event Logs post-action : aucune nouvelle erreur critique
- [ ] Monitoring : retour au vert (aucune alerte active anormale)
- [ ] Backups : pas d'impact sur les jobs planifiés
- [ ] Snapshot supprimé (si créé en PRECHECK et intervention validée)

## PHASE 5 — CLOSEOUT

- [ ] CW Note Interne : timeline + actions + preuves + validations
- [ ] CW Discussion : client-safe, facturable, sans IP ni détail sensible
- [ ] Email client (si requis) : résultat fonctionnel + prochaine étape
- [ ] Teams : annonce fin de maintenance (si applicable)
- [ ] Mode maintenance RMM désactivé
- [ ] KB créé ou mis à jour (si incident récurrent ou nouvelle procédure)
- [ ] Billet CW fermé avec statut correct

---
## CHECKLIST_BACKUP_DR-Readiness_V1
**Source :** `40_CHECKLISTS/CHECKLIST__DR_Readiness.md`

**Agent :** IT-BackupDRMaster, IT-MaintenanceMaster
**Usage :** Vérification mensuelle de la disponibilité du plan de relève
**Mis à jour :** 2026-03-20

---

## BACKUPS — ÉTAT COURANT

### Datto BCDR
- [ ] Tous les agents : dernier backup Success ou Warning acceptable
- [ ] Screenshot de vérification présent pour les VMs critiques
- [ ] Stockage local Datto : espace libre > 20%
- [ ] Stockage cloud : synchronisation OK (pas d'erreur > 24h)
- [ ] Rétention configurée selon la politique client (Hudu → Agreements)

### Veeam
- [ ] Jobs en cours : Success ou Warning acceptable
- [ ] Repository : espace libre > 20%
- [ ] Dernière vérification d'intégrité (SureBackup ou Instant Recovery test) < 30 jours
- [ ] Veeam Cloud Connect (si applicable) : synchronisation OK

### Keepit (M365)
- [ ] Connecteur Microsoft 365 : Connected (pas Disconnected)
- [ ] Dernière synchronisation Exchange : OK
- [ ] Dernière synchronisation SharePoint/OneDrive : OK
- [ ] Nombre d'utilisateurs protégés = nombre d'utilisateurs actifs

---

## PLAN DE RELÈVE — VALIDITÉ

- [ ] Document DR à jour dans Hudu pour ce client (date < 6 mois)
- [ ] Contacts d'urgence à jour (responsable client, MSP on-call)
- [ ] RTO et RPO documentés et connus de l'équipe
- [ ] Ordre de démarrage des systèmes documenté
- [ ] Accès aux ressources de reprise validé (accès Datto portal, VPN, credentials Passportal)

---

## TESTS DR

- [ ] Dernier test d'intégrité backup : _______ (date)
  - Résultat : ☐ Pass  ☐ Fail → Actions correctives : _______
- [ ] Dernier test Instant Virtualization : _______ (date)
  - RTO mesuré : _______ min / Objectif : _______ min
- [ ] Prochain test planifié : _______

---

## VÉRIFICATION ANNUELLE

- [ ] Test complet DR (Tabletop ou Functional) effectué cette année : ☐ Oui  ☐ Non
- [ ] Rapport de test archivé dans CW/Hudu : ☐ Oui
- [ ] Écarts identifiés et corrigés : ☐ Oui  ☐ En cours : _______

---

## RÉSULTAT

☐ **DR READY** — Tous les items validés
☐ **ACTIONS REQUISES** — Items en attente : _______
☐ **NON READY** — Problème critique : escalade IT-BackupDRMaster immédiatement

---
## CHECKLIST — KICKOFF (Ticket MSP)
**Source :** `40_CHECKLISTS/CHECKLIST__KICKOFF_TICKET.md`

Copier-coller et remplir au début :

- Ticket: #
- Client: 
- Type: NOC | Support | Change | Maintenance
- Fenêtre: (Début–Fin + TZ)
- Urgence/SLA: 
- Scope (serveurs/services): 
- Contraintes: (prod, VIP, no-touch, 1 serveur critique à la fois, etc.)
- Risques connus: 
- Objectif (succès): 
- Outils: (RMM/VPN/Portal)

---
## CHECKLIST — POSTCHECK (Generic Windows Server)
**Source :** `40_CHECKLISTS/CHECKLIST__POSTCHECK_GENERIC.md`

- [ ] Host en ligne (ping/RMM)
- [ ] Services critiques OK
- [ ] Event Logs post-action: Kernel-Power, disk/NTFS, service failures
- [ ] Pending reboot = False (ou expliqué)
- [ ] App/partage/URL test rapide
- [ ] Monitoring back to green / alertes normalisées
- [ ] Backups: pas d'échec post-reprise

---
## CHECKLIST — PRECHECK (Generic Windows Server)
**Source :** `40_CHECKLISTS/CHECKLIST__PRECHECK_GENERIC.md`

- [ ] Uptime / last boot
- [ ] Pending reboot (CBS/WU/PendingFileRename/CCM)
- [ ] CPU/RAM (si perf incident)
- [ ] Disques (C: + volumes data) — espace libre
- [ ] Services critiques (selon rôle)
- [ ] Sessions (RDS) si reboot prévu
- [ ] Event Logs: System/Application (Errors/Critical sur 1–2h)
- [ ] Backups : dernier job OK (si maintenance)
- [ ] Monitoring: alertes actives vs baseline

---
## CHECKLIST_SECURITY_Hardening-et-Audit_V1
**Source :** `40_CHECKLISTS/CHECKLIST__Security.md`

**Agent :** IT-SecurityMaster, IT-Assistant-N3
**Usage :** Audit de sécurité périodique et vérification du hardening
**Mis à jour :** 2026-03-20

---

## IDENTITÉ ET ACCÈS (EntraID / AD)

- [ ] MFA activé pour tous les utilisateurs (minimum tous les admins)
- [ ] Accès conditionnel configuré (bloquer auth legacy, géo-restriction si applicable)
- [ ] Comptes admin dédiés : distinct des comptes utilisateurs quotidiens
- [ ] Comptes inactifs depuis > 90 jours désactivés
- [ ] Revue des membres Domain Admins / Global Administrators (< 5 personnes)
- [ ] Aucun compte de service avec MDP sans expiration non documenté
- [ ] Passportal à jour pour tous les comptes de service

---

## MESSAGERIE ET M365

- [ ] Defender for Office 365 actif (anti-phishing, anti-malware, Safe Links)
- [ ] Authentification basique (Legacy Auth) désactivée
- [ ] Règles de transport suspectes : aucune
- [ ] Transferts automatiques vers l'externe : aucun (ou documentés)
- [ ] Audit log M365 activé (Unified Audit Log)
- [ ] DKIM / DMARC / SPF configurés sur le domaine email
- [ ] Secure Score M365 vérifié : score actuel _______ / recommandé _______

---

## ENDPOINTS ET SERVEURS

- [ ] EDR déployé sur tous les serveurs et postes (SentinelOne / CrowdStrike / Defender XDR)
- [ ] Windows Update : patchs critiques < 30 jours sur tous les serveurs
- [ ] RDP exposé directement sur Internet : aucun (accès via VPN uniquement)
- [ ] Ports non utilisés fermés sur le firewall
- [ ] Comptes administrateurs locaux : mots de passe uniques par machine (LAPS si applicable)
- [ ] Firewall Windows activé sur tous les endpoints

---

## RÉSEAU ET PÉRIMÈTRE

- [ ] Firmware firewall à jour (WatchGuard / Fortinet / SonicWall / Meraki)
- [ ] Licences UTM/IPS actives (pas expirées)
- [ ] Certificats SSL VPN : expiration > 30 jours
- [ ] VLAN correctement segmentés (serveurs / utilisateurs / IoT séparés)
- [ ] Logs firewall activés et conservés > 90 jours
- [ ] Aucune règle "Any → Any Accept" non documentée

---

## BACKUP ET RÉSILIENCE

- [ ] Backups testés (voir CHECKLIST_BACKUP_DR-Readiness)
- [ ] Au moins 1 copie hors site (Datto cloud / Veeam Cloud / Keepit)
- [ ] Accès Passportal aux backups : restreint aux techniciens autorisés

---

## RÉSULTAT

| Zone | Status | Actions requises |
|---|---|---|
| Identité et accès | ☐ OK / ☐ Actions | |
| Messagerie M365 | ☐ OK / ☐ Actions | |
| Endpoints et serveurs | ☐ OK / ☐ Actions | |
| Réseau et périmètre | ☐ OK / ☐ Actions | |
| Backup et résilience | ☐ OK / ☐ Actions | |

**Score global :** _______ / 30 items
**Audit effectué par :** _______ | **Date :** _______ | **Billet CW :** #_______
