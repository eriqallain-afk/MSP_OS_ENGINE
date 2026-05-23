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
