# INTENT_RUNBOOK_MATRIX — IT-SHARED
**Version :** 2.0 | **Généré le :** 2026-05-23 | **Source :** scan automatique des 93 runbooks actifs

> Source de vérité pour IT-OPS-RouterIA. Chaque intent pointe vers un runbook réel dans IT-SHARED/10_RUNBOOKS/.
> Mise à jour requise à chaque ajout/modification de runbook.
> **Note :** 7 runbooks OPR sont en statut DRAFT (squelettes Factory non encore enrichis) — intents inclus avec mention.

---

## DOMAINE : INFRA

### Active Directory

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.infra.ad.dc_operations | Opérations Contrôleurs de Domaine | @IT-SysAdmin | high |
| it.infra.ad.dc_prepost_validation | Validation Pré/Post Reboot DC | @IT-MaintenanceMaster | high |
| it.infra.ad.entraid_operations | Opérations Entra ID / Azure AD | @IT-SysAdmin | high |
| it.infra.ad.folder_security | Sécurité Dossiers Partagés NTFS/AGDLP | @IT-SysAdmin | medium |
| it.infra.ad.gpo_management | Gestion des GPO (Group Policy) | @IT-SysAdmin | high |
| it.infra.ad.user_management | Gestion des Comptes Utilisateurs AD | @IT-SysAdmin | medium |

### Microsoft 365

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.infra.m365.exchange_online | Administration Exchange Online | @IT-SysAdmin | medium |
| it.infra.m365.intune_devices | Gestion des Appareils Intune / MDM | @IT-SysAdmin | medium |
| it.infra.m365.teams_sharepoint_onedrive | Dépannage Teams / SharePoint / OneDrive | @IT-SysAdmin | medium |
| it.infra.m365.user_management | Gestion des Comptes M365 | @IT-SysAdmin | medium |
| it.infra.m365.user_onboarding | Onboarding Utilisateur M365 Complet | @IT-OnOffBoarder | medium |

### Backup Infra

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.infra.backup.veeam_operations | Opérations Veeam Backup (côté infra) | @IT-SysAdmin | high |

### Cloud

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.infra.cloud.architecture_review | Revue Architecture Cloud / M365 / Azure | @IT-CloudMaster | medium |

### Réseau

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.infra.net.fortinet_operations | Opérations Firewall Fortinet / FortiGate | @IT-NetworkMaster | high |
| it.infra.net.meraki_operations | Opérations Réseau Cisco Meraki | @IT-NetworkMaster | high |
| it.infra.net.network_diagnostic | Diagnostic Réseau / Connectivité / DNS | @IT-NetworkMaster | low |
| it.infra.net.network_setup | Configuration Réseau — VLAN / Adressage / Firewall Rules | @IT-NetworkMaster | high |
| it.infra.net.sonicwall_operations | Opérations Firewall SonicWall | @IT-NetworkMaster | high |
| it.infra.net.unifi_mikrotik_operations | Opérations UniFi / MikroTik | @IT-NetworkMaster | medium |
| it.infra.net.watchguard_operations | Opérations Firewall WatchGuard | @IT-NetworkMaster | high |

### Serveurs

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.infra.srv.healthcheck_template | Template Health Check Serveur | @IT-SysAdmin | low |
| it.infra.srv.hyperv_operations | Opérations Hyper-V / Virtualisation | @IT-SysAdmin | high |
| it.infra.srv.newvm_deployment | Déploiement Nouvelle VM | @IT-SysAdmin | high |
| it.infra.srv.rds_operations | Opérations Remote Desktop Services (RDS) | @IT-SysAdmin | high |
| it.infra.srv.sql_prepost_validation | Validation Pré/Post Reboot SQL Server | @IT-MaintenanceMaster | high |
| it.infra.srv.vmware_operations | Opérations VMware vSphere / ESXi | @IT-SysAdmin | high |
| it.infra.srv.xcpng_operations | Opérations XCP-ng / Vates (Hyperviseur Xen) | @IT-SysAdmin | high |

### VoIP

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.infra.voip.diagnostic | Diagnostic VoIP — 3CX / Teams Phone / Mitel | @IT-VoIPMaster | medium |

### OPS QuickStart

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.infra.ops.quickstart | QuickStart Cloud/M365 — Garde-fous et Accès | @IT-CloudMaster | low |

---

## DOMAINE : MAINTENANCE

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.maintenance.cmdb.asset_audit | Audit CMDB / Inventaire Actifs IT | @IT-AssetMaster | low |
| it.maintenance.srv.audit_trimestriel | Audit Trimestriel Serveurs et Infrastructure | @IT-MaintenanceMaster | medium |
| it.maintenance.srv.healthcheck | Health Check Serveur Windows | @IT-MaintenanceMaster | low |
| it.maintenance.srv.post_shutdown_electrical | Reprise après Coupure Électrique | @IT-MaintenanceMaster | high |
| it.maintenance.srv.printserver_prepost | Validation Pré/Post Reboot Serveur d'Impression | @IT-MaintenanceMaster | high |
| it.maintenance.patching.cw_rmm | Patching Windows via CW RMM | @IT-MaintenanceMaster | high |
| it.maintenance.patching.windows_complet | Patching Windows Complet — Phases et Déploiement | @IT-MaintenanceMaster | high |
| it.maintenance.patching.pending_reboot | Détection et Gestion Pending Reboot Serveur | @IT-MaintenanceMaster | medium |
| it.maintenance.patching.wsus_maintenance | Maintenance WSUS — Gestion des Mises à Jour | @IT-MaintenanceMaster | medium |

---

## DOMAINE : NOC

### Backup NOC

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.noc.backup.configuration | Configuration et Validation Jobs de Sauvegarde | @IT-BackupDRMaster | medium |
| it.noc.backup.dr_plan_validation | Validation Plan de Relève / DR | @IT-BackupDRMaster | high |
| it.noc.backup.dr_test | Test DR — Exécution Plan de Reprise | @IT-BackupDRMaster | critical |
| it.noc.backup.datto_operations | Opérations Datto BCDR / SIRIS / ALTO | @IT-BackupDRMaster | high |
| it.noc.backup.keepit_operations | Opérations Keepit — Backup Cloud M365 | @IT-BackupDRMaster | medium |
| it.noc.backup.restore_test_trimestriel | Test de Restauration Trimestriel | @IT-BackupDRMaster | high |
| it.noc.backup.validation_statut_sauvegardes | Validation Statut Sauvegardes Multi-Plateformes | @IT-BackupDRMaster | medium |
| it.noc.backup.veeam_cloud | Opérations Veeam Cloud Connect / DRaaS | @IT-BackupDRMaster | high |
| it.noc.backup.veeam_operations | Opérations Veeam v13 — Triage Quotidien | @IT-BackupDRMaster | high |

### OPS NOC

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.noc.ops.command_center | Command Center NOC — Début de Quart | @IT-Commandare-NOC | medium |
| it.noc.ops.dispatch | Dispatch NOC — Triage et Routage des Billets | @IT-NOCDispatcher | medium |
| it.noc.ops.frontdoor | Front Door NOC — Réception et Qualification Initiale | @IT-FrontLine | low |
| it.noc.ops.incident_command | Commandement Incident — Triage NOC vers Résolution | @IT-Commandare-NOC | high |

### RMM

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.noc.rmm.cwrmm_auvik_operations | Opérations CW RMM et Auvik Monitoring | @IT-MonitoringMaster | medium |
| it.noc.rmm.nable_operations | Opérations N-able / N-sight RMM | @IT-MonitoringMaster | medium |

---

## DOMAINE : OPR

> **Note :** Les runbooks marqués [DRAFT] sont des squelettes en attente d'enrichissement Factory.
> Ils sont inclus dans la matrix avec un intent_id actif pour permettre le routage.

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.opr.cmdb.reconciliation_cw_hudu_rmm | Réconciliation CMDB — CW / Hudu / RMM [DRAFT] | @IT-AssetMaster | medium |
| it.opr.cw.ticket_quality_audit | Audit Qualité Ticket CW avant Clôture [DRAFT] | @IT-TicketOpr | low |
| it.opr.client_communication.cadence | Cadence Communication Client [DRAFT] | @IT-Commandare-OPR | low |
| it.opr.eol_eos.risk_register | Registre Risques EOL/EOS Équipements et Logiciels [DRAFT] | @IT-AssetMaster | medium |
| it.opr.handoff.shift_change | Handoff / Passation de Quart [DRAFT] | @IT-Commandare-OPR | low |
| it.opr.monthly.client_ops_pack | Pack Opérations Client Mensuel [DRAFT] | @IT-ReportMaster | low |
| it.opr.postincident.review_p1p2 | Post-Incident Review P1/P2 | @IT-ReportMaster | medium |
| it.opr.problem_management.capa | Gestion des Problèmes Récurrents — CAPA | @IT-Commandare-OPR | medium |
| it.opr.qbr.data_collection | Collecte de Données QBR [DRAFT] | @IT-ReportMaster | low |
| it.opr.sla.breach_prevention | Prévention Breaches SLA | @IT-Commandare-OPR | medium |
| it.opr.weekly.ops_review | Revue Opérationnelle Hebdomadaire [DRAFT] | @IT-Commandare-OPR | low |

---

## DOMAINE : PROJET

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.projet.sow.process | Processus Projet et SOW MSP — Détection et Escalade Ventes | @IT-Commandare-OPR | low |

---

## DOMAINE : SECURITY

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.security.compliance.5piliers | Framework 5 Piliers — Scoring Maturité Sécurité MSP | @IT-ComplianceMaster | medium |
| it.security.entra.security_compliance | Audit Posture Sécurité Entra ID / MFA / PIM / CA | @IT-ComplianceMaster | high |
| it.security.m365.compliance_purview | Conformité M365 Purview — DLP / Rétention / Defender | @IT-SecurityMaster | high |
| it.security.ops.license_audit | Audit Licences Logiciels et M365 | @IT-SecurityMaster | low |
| it.security.purview.compliance_audit | Audit Conformité Purview — DLP / Labels / Insider Risk | @IT-ComplianceMaster | medium |
| it.security.secu.alert_response | Réponse aux Alertes Monitoring et Sécurité | @IT-MonitoringMaster | high |
| it.security.secu.incident_response | Réponse à Incident Cybersécurité P1/P2 | @IT-SecurityMaster | critical |
| it.security.secu.security_audit | Audit de Sécurité Infrastructure et Conformité | @IT-SecurityMaster | high |

---

## DOMAINE : SUPPORT

### Support Opérations

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.support.ops.cw_dispatch_types | Dispatch ConnectWise — Types / Sub-types / Files | @IT-NOCDispatcher | low |
| it.support.m365.onedrive_sharepoint_sync | Dépannage Sync OneDrive / SharePoint | @IT-Assistant-N2 | low |
| it.support.n1n2.support_triage | Triage Support N1/N2/N3 — Escalade et Routing | @IT-FrontLine | low |
| it.support.n2.support | Support N2 — Poste / Compte / Réseau / VPN / Logiciels | @IT-Assistant-N2 | low |
| it.support.net.vpn_troubleshooting | Dépannage VPN — Firewalls (Fortinet / WatchGuard / SonicWall) | @IT-NetworkMaster | medium |
| it.support.ops.cw_dispatch | Dispatch CW — Standardisation Billets | @IT-NOCDispatcher | low |
| it.support.ops.cw_intervention_live_close | Intervention Live et Clôture Billet ConnectWise | @IT-TechOnsite | medium |
| it.support.ops.commandare_opr | Commandement OPR — Clôture Billet et Templates CW | @IT-Commandare-OPR | low |
| it.support.ops.commandare_tech | Commandement Tech — Réception Incident et Troubleshooting | @IT-Commandare-TECH | medium |
| it.support.ops.ticket_to_kb | Ticket MSP vers Diagnostic → Communication → Knowledge Base | @IT-KnowledgeKeeper | low |

### Support Postes (WKS)

| Intent ID | Title | Agent | Risk |
|---|---|---|---|
| it.support.wks.alerte_av | Triage Alerte Antivirus / Comportement Suspect Poste | @IT-FrontLine | high |
| it.support.wks.imprimante | Dépannage Imprimante Locale / Réseau Poste Client | @IT-TechOnsite | low |
| it.support.wks.login | Problème de Connexion Windows / M365 / Azure AD | @IT-FrontLine | medium |
| it.support.wks.offboarding | Offboarding Employé — Désactivation Compte et Poste | @IT-TechOnsite | high |
| it.support.wks.onboarding_poste | Onboarding Nouveau Poste de Travail | @IT-TechOnsite | medium |
| it.support.wks.outlook | Dépannage Outlook / M365 — Profil / Sync / Plantage | @IT-Assistant-N2 | low |
| it.support.wks.partage_reseau | Dépannage Lecteurs Réseau / Partages SMB | @IT-Assistant-N2 | low |
| it.support.wks.poste_lent | Diagnostic Poste Lent — Matériel / Ressources / Réseau | @IT-TechOnsite | low |
| it.support.wks.profil_corrompu | Réparation Profil Utilisateur Windows Corrompu | @IT-TechOnsite | medium |
| it.support.wks.teams_av | Dépannage Teams Audio/Vidéo — Son / Caméra / Réunions | @IT-Assistant-N2 | low |
| it.support.wks.vpn_client | Dépannage VPN Client — GlobalProtect / AnyConnect / FortiClient | @IT-Assistant-N2 | low |

---

---

## BLOC YAML COMPLET — Pour IT-OPS-RouterIA

```yaml
# INTENT_RUNBOOK_MATRIX V2.0
# Généré le: 2026-05-23
# Source: scan automatique des 93 runbooks actifs
# Usage: IT-OPS-RouterIA — routing intent → runbook

matrix:

  # ============================================================
  # DOMAINE: INFRA — Active Directory
  # ============================================================

  - intent_id: it.infra.ad.dc_operations
    title: "Opérations Contrôleurs de Domaine"
    match_hints:
      - "DC en erreur"
      - "contrôleur de domaine"
      - "réplication AD"
      - "FSMO"
      - "DCDiag erreur"
      - "health check AD"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-DC_Operations_V3.md"
    agent_recommande: "@IT-SysAdmin"
    risk_level: high
    domaine: INFRA

  - intent_id: it.infra.ad.dc_prepost_validation
    title: "Validation Pré/Post Reboot DC"
    match_hints:
      - "précheck DC"
      - "postcheck contrôleur de domaine"
      - "valider avant reboot DC"
      - "uptime DC avant redémarrage"
      - "services AD après reboot"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-DC_PrePost_Validation_V2.md"
    agent_recommande: "@IT-MaintenanceMaster"
    risk_level: high
    domaine: INFRA

  - intent_id: it.infra.ad.entraid_operations
    title: "Opérations Entra ID / Azure AD"
    match_hints:
      - "Entra ID"
      - "Azure AD"
      - "accès conditionnel"
      - "conditional access"
      - "MFA Entra"
      - "Microsoft Graph PowerShell"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-EntraID_Operations_V2.md"
    agent_recommande: "@IT-SysAdmin"
    risk_level: high
    domaine: INFRA

  - intent_id: it.infra.ad.folder_security
    title: "Sécurité Dossiers Partagés NTFS/AGDLP"
    match_hints:
      - "permissions NTFS"
      - "accès refusé dossier"
      - "AGDLP"
      - "groupe AD sur partage"
      - "héritage permissions"
      - "audit permissions dossier"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-FolderSecurity_V1.md"
    agent_recommande: "@IT-SysAdmin"
    risk_level: medium
    domaine: INFRA

  - intent_id: it.infra.ad.gpo_management
    title: "Gestion des GPO (Group Policy)"
    match_hints:
      - "GPO"
      - "group policy"
      - "stratégie de groupe"
      - "gpresult"
      - "politique appliquée poste"
      - "créer modifier GPO"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-GPO_Management_V1.md"
    agent_recommande: "@IT-SysAdmin"
    risk_level: high
    domaine: INFRA

  - intent_id: it.infra.ad.user_management
    title: "Gestion des Comptes Utilisateurs AD"
    match_hints:
      - "créer compte AD"
      - "nouveau utilisateur Active Directory"
      - "désactiver compte AD"
      - "réinitialiser mot de passe AD"
      - "groupe AD utilisateur"
      - "compte AD expiré"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-UserManagement_V2.md"
    agent_recommande: "@IT-SysAdmin"
    risk_level: medium
    domaine: INFRA

  # ============================================================
  # DOMAINE: INFRA — Microsoft 365
  # ============================================================

  - intent_id: it.infra.m365.exchange_online
    title: "Administration Exchange Online"
    match_hints:
      - "Exchange Online"
      - "boîte courriel"
      - "alias email"
      - "shared mailbox"
      - "distribution list"
      - "règle transport Exchange"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-M365-Exchange_Online_V2.md"
    agent_recommande: "@IT-SysAdmin"
    risk_level: medium
    domaine: INFRA

  - intent_id: it.infra.m365.intune_devices
    title: "Gestion des Appareils Intune / MDM"
    match_hints:
      - "Intune"
      - "MDM"
      - "appareil non conforme"
      - "Autopilot"
      - "Company Portal"
      - "politique Intune"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-M365-Intune_Devices_V2.md"
    agent_recommande: "@IT-SysAdmin"
    risk_level: medium
    domaine: INFRA

  - intent_id: it.infra.m365.teams_sharepoint_onedrive
    title: "Dépannage Teams / SharePoint / OneDrive"
    match_hints:
      - "Teams ne fonctionne pas"
      - "SharePoint accès refusé"
      - "OneDrive sync bloqué"
      - "site SharePoint disparu"
      - "Teams erreur connexion"
      - "OneDrive rouge"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-M365-Teams_SharePoint_OneDrive_V2.md"
    agent_recommande: "@IT-SysAdmin"
    risk_level: medium
    domaine: INFRA

  - intent_id: it.infra.m365.user_management
    title: "Gestion des Comptes M365"
    match_hints:
      - "créer compte M365"
      - "licence M365"
      - "supprimer utilisateur M365"
      - "UPN M365"
      - "MFA utilisateur M365"
      - "réinitialiser compte Microsoft 365"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-M365-UserManagement_V2.md"
    agent_recommande: "@IT-SysAdmin"
    risk_level: medium
    domaine: INFRA

  - intent_id: it.infra.m365.user_onboarding
    title: "Onboarding Utilisateur M365 Complet"
    match_hints:
      - "onboarding M365"
      - "nouveau employé M365"
      - "checklist arrivée employé"
      - "configurer poste nouveau usager"
      - "Autopilot onboarding"
      - "préparer accès nouveau technicien"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-M365-UserOnboarding_V2.md"
    agent_recommande: "@IT-OnOffBoarder"
    risk_level: medium
    domaine: INFRA

  # ============================================================
  # DOMAINE: INFRA — Backup
  # ============================================================

  - intent_id: it.infra.backup.veeam_operations
    title: "Opérations Veeam Backup (côté infra)"
    match_hints:
      - "Veeam job failed"
      - "backup échoué Veeam"
      - "vérifier jobs Veeam"
      - "VBR console"
      - "repository plein Veeam"
      - "Veeam warning"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-BACKUP-Veeam_Operations_V2.md"
    agent_recommande: "@IT-SysAdmin"
    risk_level: high
    domaine: INFRA

  # ============================================================
  # DOMAINE: INFRA — Cloud
  # ============================================================

  - intent_id: it.infra.cloud.architecture_review
    title: "Revue Architecture Cloud / M365 / Azure"
    match_hints:
      - "architecture cloud"
      - "revue M365 client"
      - "standards MSP cloud"
      - "DMARC DKIM SPF"
      - "Azure composants"
      - "audit cloud infrastructure"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-CLOUD-Architecture_Review_V2.md"
    agent_recommande: "@IT-CloudMaster"
    risk_level: medium
    domaine: INFRA

  # ============================================================
  # DOMAINE: INFRA — Réseau
  # ============================================================

  - intent_id: it.infra.net.fortinet_operations
    title: "Opérations Firewall Fortinet / FortiGate"
    match_hints:
      - "FortiGate"
      - "Fortinet"
      - "FortiOS"
      - "règle firewall Fortinet"
      - "VPN SSL Fortinet"
      - "FortiCloud"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-NET-Fortinet_Operations_V2.md"
    agent_recommande: "@IT-NetworkMaster"
    risk_level: high
    domaine: INFRA

  - intent_id: it.infra.net.meraki_operations
    title: "Opérations Réseau Cisco Meraki"
    match_hints:
      - "Meraki"
      - "dashboard Meraki"
      - "MX firewall Meraki"
      - "switch MS Meraki"
      - "AP Meraki Wi-Fi"
      - "Meraki dashboard.meraki.com"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-NET-Meraki_Operations_V2.md"
    agent_recommande: "@IT-NetworkMaster"
    risk_level: high
    domaine: INFRA

  - intent_id: it.infra.net.network_diagnostic
    title: "Diagnostic Réseau / Connectivité / DNS"
    match_hints:
      - "pas d'internet"
      - "ping ne fonctionne pas"
      - "DNS ne résout pas"
      - "diagnostic réseau"
      - "Test-NetConnection"
      - "tracert route"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-NET-NetworkDiagnostic_V2.md"
    agent_recommande: "@IT-NetworkMaster"
    risk_level: low
    domaine: INFRA

  - intent_id: it.infra.net.network_setup
    title: "Configuration Réseau — VLAN / Adressage / Firewall Rules"
    match_hints:
      - "configurer VLAN"
      - "plan d'adressage réseau"
      - "nouveau client réseau setup"
      - "firewall règles minimum"
      - "segmentation réseau"
      - "VLAN invités Wi-Fi"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-NET-NetworkSetup_V1.md"
    agent_recommande: "@IT-NetworkMaster"
    risk_level: high
    domaine: INFRA

  - intent_id: it.infra.net.sonicwall_operations
    title: "Opérations Firewall SonicWall"
    match_hints:
      - "SonicWall"
      - "SonicOS"
      - "MySonicWall"
      - "règle firewall SonicWall"
      - "VPN SonicWall"
      - "NSM SonicWall"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-NET-SonicWall_Operations_V2.md"
    agent_recommande: "@IT-NetworkMaster"
    risk_level: high
    domaine: INFRA

  - intent_id: it.infra.net.unifi_mikrotik_operations
    title: "Opérations UniFi / MikroTik"
    match_hints:
      - "UniFi"
      - "Ubiquiti"
      - "MikroTik"
      - "UniFi controller"
      - "AP UniFi en rouge"
      - "switch UniFi hors ligne"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-NET-Unifi_Mikrotik_Operations_V1.md"
    agent_recommande: "@IT-NetworkMaster"
    risk_level: medium
    domaine: INFRA

  - intent_id: it.infra.net.watchguard_operations
    title: "Opérations Firewall WatchGuard"
    match_hints:
      - "WatchGuard"
      - "Firebox"
      - "WatchGuard System Manager"
      - "WSM"
      - "règle firewall WatchGuard"
      - "VPN WatchGuard"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-NET-WatchGuard_Operations_V2.md"
    agent_recommande: "@IT-NetworkMaster"
    risk_level: high
    domaine: INFRA

  # ============================================================
  # DOMAINE: INFRA — Serveurs
  # ============================================================

  - intent_id: it.infra.srv.healthcheck_template
    title: "Template Health Check Serveur"
    match_hints:
      - "health check serveur"
      - "rapport état serveur"
      - "template audit serveur"
      - "vérification serveur Windows"
      - "informations système serveur"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-HealthCheck_Template_V1.md"
    agent_recommande: "@IT-SysAdmin"
    risk_level: low
    domaine: INFRA

  - intent_id: it.infra.srv.hyperv_operations
    title: "Opérations Hyper-V / Virtualisation"
    match_hints:
      - "Hyper-V"
      - "VM Hyper-V"
      - "machine virtuelle Hyper-V"
      - "snapshot Hyper-V"
      - "migration VM Hyper-V"
      - "hôte Hyper-V en erreur"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-HyperV_Operations_V2.md"
    agent_recommande: "@IT-SysAdmin"
    risk_level: high
    domaine: INFRA

  - intent_id: it.infra.srv.newvm_deployment
    title: "Déploiement Nouvelle VM"
    match_hints:
      - "déployer nouvelle VM"
      - "créer machine virtuelle"
      - "provisioning VM"
      - "nouvelle VM serveur"
      - "sizing VM"
      - "nouvelle VM Hyper-V VMware"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-NewVM_Deployment_V1.md"
    agent_recommande: "@IT-SysAdmin"
    risk_level: high
    domaine: INFRA

  - intent_id: it.infra.srv.rds_operations
    title: "Opérations Remote Desktop Services (RDS)"
    match_hints:
      - "RDS"
      - "Remote Desktop"
      - "bureau à distance"
      - "RD Gateway"
      - "RD Session Host"
      - "licence RDS"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-RDS_Operations_V2.md"
    agent_recommande: "@IT-SysAdmin"
    risk_level: high
    domaine: INFRA

  - intent_id: it.infra.srv.sql_prepost_validation
    title: "Validation Pré/Post Reboot SQL Server"
    match_hints:
      - "précheck SQL"
      - "postcheck SQL Server"
      - "valider avant reboot SQL"
      - "SQL Server avant maintenance"
      - "bases de données SQL avant redémarrage"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-SQL_PrePost_Validation_V2.md"
    agent_recommande: "@IT-MaintenanceMaster"
    risk_level: high
    domaine: INFRA

  - intent_id: it.infra.srv.vmware_operations
    title: "Opérations VMware vSphere / ESXi"
    match_hints:
      - "VMware"
      - "ESXi"
      - "vCenter"
      - "vSphere"
      - "datastore plein VMware"
      - "VM VMware en erreur"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-VMware_Operations_V2.md"
    agent_recommande: "@IT-SysAdmin"
    risk_level: high
    domaine: INFRA

  - intent_id: it.infra.srv.xcpng_operations
    title: "Opérations XCP-ng / Vates (Hyperviseur Xen)"
    match_hints:
      - "XCP-ng"
      - "Xen Orchestra"
      - "XO"
      - "Vates hyperviseur"
      - "VM XCP-ng"
      - "Xen Orchestra hôte"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-XCPng_Operations_V1.md"
    agent_recommande: "@IT-SysAdmin"
    risk_level: high
    domaine: INFRA

  # ============================================================
  # DOMAINE: INFRA — VoIP
  # ============================================================

  - intent_id: it.infra.voip.diagnostic
    title: "Diagnostic VoIP — 3CX / Teams Phone / Mitel"
    match_hints:
      - "téléphonie en panne"
      - "VoIP ne fonctionne pas"
      - "3CX"
      - "Teams Phone problème"
      - "qualité appel mauvaise"
      - "SIP trunk en erreur"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-VOIP-Diagnostic_V2.md"
    agent_recommande: "@IT-VoIPMaster"
    risk_level: medium
    domaine: INFRA

  # ============================================================
  # DOMAINE: INFRA — OPS
  # ============================================================

  - intent_id: it.infra.ops.quickstart
    title: "QuickStart Cloud/M365 — Garde-fous et Accès"
    match_hints:
      - "quickstart cloud"
      - "démarrage rapide M365"
      - "garde-fous cloud MSP"
      - "politique accès cloud"
      - "standards cloud M365 MSP"
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/INFRA-OPS-QuickStart_V1.md"
    agent_recommande: "@IT-CloudMaster"
    risk_level: low
    domaine: INFRA

  # ============================================================
  # DOMAINE: MAINTENANCE
  # ============================================================

  - intent_id: it.maintenance.cmdb.asset_audit
    title: "Audit CMDB / Inventaire Actifs IT"
    match_hints:
      - "audit CMDB"
      - "inventaire actifs"
      - "actif manquant CW"
      - "configurations ConnectWise"
      - "CMDB à jour"
      - "liste équipements client"
    runbook_path: "IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-OPS-CMDB_AssetAudit_V1.md"
    agent_recommande: "@IT-AssetMaster"
    risk_level: low
    domaine: MAINTENANCE

  - intent_id: it.maintenance.srv.audit_trimestriel
    title: "Audit Trimestriel Serveurs et Infrastructure"
    match_hints:
      - "audit trimestriel"
      - "Q1 Q2 Q3 Q4 audit"
      - "revue trimestrielle serveurs"
      - "audit infra client tous les 3 mois"
      - "rapport trimestriel MSP"
    runbook_path: "IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-SRV-AuditTrimestriel_V2.md"
    agent_recommande: "@IT-MaintenanceMaster"
    risk_level: medium
    domaine: MAINTENANCE

  - intent_id: it.maintenance.srv.healthcheck
    title: "Health Check Serveur Windows"
    match_hints:
      - "health check serveur"
      - "vérifier santé serveur"
      - "script santé Windows Server"
      - "CPU RAM disque serveur"
      - "état serveur PowerShell"
    runbook_path: "IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-SRV-HealthCheck_V2.md"
    agent_recommande: "@IT-MaintenanceMaster"
    risk_level: low
    domaine: MAINTENANCE

  - intent_id: it.maintenance.srv.post_shutdown_electrical
    title: "Reprise après Coupure Électrique"
    match_hints:
      - "coupure de courant"
      - "reprise après blackout"
      - "retour courant serveurs"
      - "UPS coupure électrique"
      - "rétablissement après panne de courant"
      - "ordre redémarrage après coupure"
    runbook_path: "IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-SRV-PostShutdown_Electrical_V2.md"
    agent_recommande: "@IT-MaintenanceMaster"
    risk_level: high
    domaine: MAINTENANCE

  - intent_id: it.maintenance.srv.printserver_prepost
    title: "Validation Pré/Post Reboot Serveur d'Impression"
    match_hints:
      - "précheck print server"
      - "postcheck serveur impression"
      - "valider avant reboot print"
      - "Print Server avant maintenance"
      - "spooler avant redémarrage"
    runbook_path: "IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-SRV-PrintServer_PrePost_V1.md"
    agent_recommande: "@IT-MaintenanceMaster"
    risk_level: high
    domaine: MAINTENANCE

  - intent_id: it.maintenance.patching.cw_rmm
    title: "Patching Windows via CW RMM"
    match_hints:
      - "patcher via RMM"
      - "patching CW Automate"
      - "déployer patches via ConnectWise RMM"
      - "mise à jour Windows via RMM"
      - "patching serveurs CW"
    runbook_path: "IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-WIN-Patching_CW-RMM_V3.md"
    agent_recommande: "@IT-MaintenanceMaster"
    risk_level: high
    domaine: MAINTENANCE

  - intent_id: it.maintenance.patching.windows_complet
    title: "Patching Windows Complet — Phases et Déploiement"
    match_hints:
      - "patching Windows"
      - "Patch Tuesday"
      - "mise à jour serveurs Windows"
      - "déploiement patches par phases"
      - "CVSS patching priorité"
      - "fenêtre de maintenance patches"
    runbook_path: "IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-WIN-Patching_Complet_V3.md"
    agent_recommande: "@IT-MaintenanceMaster"
    risk_level: high
    domaine: MAINTENANCE

  - intent_id: it.maintenance.patching.pending_reboot
    title: "Détection et Gestion Pending Reboot Serveur"
    match_hints:
      - "pending reboot"
      - "serveur en attente redémarrage"
      - "flag reboot Windows Server"
      - "SCCM reboot pending"
      - "vérifier si reboot nécessaire"
    runbook_path: "IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-WIN-PendingReboot_V2.md"
    agent_recommande: "@IT-MaintenanceMaster"
    risk_level: medium
    domaine: MAINTENANCE

  - intent_id: it.maintenance.patching.wsus_maintenance
    title: "Maintenance WSUS — Gestion des Mises à Jour"
    match_hints:
      - "WSUS"
      - "Windows Server Update Services"
      - "console WSUS"
      - "synchronisation WSUS"
      - "approuver patches WSUS"
      - "nettoyage WSUS"
    runbook_path: "IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-WIN-WSUS_Maintenance_V2.md"
    agent_recommande: "@IT-MaintenanceMaster"
    risk_level: medium
    domaine: MAINTENANCE

  # ============================================================
  # DOMAINE: NOC — Backup
  # ============================================================

  - intent_id: it.noc.backup.configuration
    title: "Configuration et Validation Jobs de Sauvegarde"
    match_hints:
      - "configurer sauvegarde"
      - "setup backup Veeam"
      - "configuration job backup"
      - "retention backup à configurer"
      - "GFS backup"
      - "notification email Veeam"
    runbook_path: "IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Backup_Configuration_V2.md"
    agent_recommande: "@IT-BackupDRMaster"
    risk_level: medium
    domaine: NOC

  - intent_id: it.noc.backup.dr_plan_validation
    title: "Validation Plan de Relève / DR"
    match_hints:
      - "plan de relève"
      - "DR plan"
      - "RPO RTO client"
      - "valider plan disaster recovery"
      - "accord de reprise Hudu"
      - "réviser plan DR"
    runbook_path: "IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-DR_Plan_Validation_V2.md"
    agent_recommande: "@IT-BackupDRMaster"
    risk_level: high
    domaine: NOC

  - intent_id: it.noc.backup.dr_test
    title: "Test DR — Exécution Plan de Reprise"
    match_hints:
      - "test DR"
      - "exécuter test disaster recovery"
      - "simuler sinistre"
      - "test reprise après sinistre"
      - "valider le DR"
      - "preuve test DR"
    runbook_path: "IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-DR_Test_V2.md"
    agent_recommande: "@IT-BackupDRMaster"
    risk_level: critical
    domaine: NOC

  - intent_id: it.noc.backup.datto_operations
    title: "Opérations Datto BCDR / SIRIS / ALTO"
    match_hints:
      - "Datto"
      - "SIRIS"
      - "ALTO Datto"
      - "backup Datto en erreur"
      - "restauration Datto"
      - "portail Datto partenaire"
    runbook_path: "IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Datto_Operations_V2.md"
    agent_recommande: "@IT-BackupDRMaster"
    risk_level: high
    domaine: NOC

  - intent_id: it.noc.backup.keepit_operations
    title: "Opérations Keepit — Backup Cloud M365"
    match_hints:
      - "Keepit"
      - "backup M365 Keepit"
      - "sauvegarde cloud M365"
      - "restaurer depuis Keepit"
      - "Keepit en erreur"
      - "backup Exchange Keepit"
    runbook_path: "IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Keepit_Operations_V2.md"
    agent_recommande: "@IT-BackupDRMaster"
    risk_level: medium
    domaine: NOC

  - intent_id: it.noc.backup.restore_test_trimestriel
    title: "Test de Restauration Trimestriel"
    match_hints:
      - "test restauration trimestriel"
      - "tester restauration backup"
      - "valider restauration"
      - "SureBackup Veeam"
      - "preuve restauration"
      - "RTO mesurer test"
    runbook_path: "IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Restore_Test_Trimestriel_V1.md"
    agent_recommande: "@IT-BackupDRMaster"
    risk_level: high
    domaine: NOC

  - intent_id: it.noc.backup.validation_statut_sauvegardes
    title: "Validation Statut Sauvegardes Multi-Plateformes"
    match_hints:
      - "statut sauvegardes"
      - "backup status"
      - "Backup Radar alerte"
      - "valider statut backup Veeam Datto"
      - "NOC backup ticket"
      - "handover backup status inconnu"
    runbook_path: "IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Validation_Statut_Sauvegardes_V1.md"
    agent_recommande: "@IT-BackupDRMaster"
    risk_level: medium
    domaine: NOC

  - intent_id: it.noc.backup.veeam_cloud
    title: "Opérations Veeam Cloud Connect / DRaaS"
    match_hints:
      - "Veeam Cloud Connect"
      - "sauvegarde cloud Veeam"
      - "DRaaS Veeam"
      - "backup hors-site Veeam"
      - "cloud repository Veeam"
      - "réplication Veeam cloud"
    runbook_path: "IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Veeam_Cloud_V2.md"
    agent_recommande: "@IT-BackupDRMaster"
    risk_level: high
    domaine: NOC

  - intent_id: it.noc.backup.veeam_operations
    title: "Opérations Veeam v13 — Triage Quotidien"
    match_hints:
      - "Veeam job échoué"
      - "triage Veeam quotidien"
      - "Veeam v13"
      - "restauration Veeam"
      - "réponse ransomware Veeam"
      - "vérification DR Veeam"
    runbook_path: "IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Veeam_Operations_V2.md"
    agent_recommande: "@IT-BackupDRMaster"
    risk_level: high
    domaine: NOC

  # ============================================================
  # DOMAINE: NOC — OPS
  # ============================================================

  - intent_id: it.noc.ops.command_center
    title: "Command Center NOC — Début de Quart"
    match_hints:
      - "début de quart NOC"
      - "checklist début shift"
      - "ouvrir quart NOC"
      - "revue alertes matin"
      - "vérification billets priorité NOC"
    runbook_path: "IT-SHARED/10_RUNBOOKS/NOC/NOC-OPS-CommandCenter_V2.md"
    agent_recommande: "@IT-Commandare-NOC"
    risk_level: medium
    domaine: NOC

  - intent_id: it.noc.ops.dispatch
    title: "Dispatch NOC — Triage et Routage des Billets"
    match_hints:
      - "dispatch ticket NOC"
      - "qualifier billet RMM"
      - "triage alerte RMM"
      - "créer billet depuis alerte"
      - "router ticket NOC"
      - "P1 P2 P3 qualifier"
    runbook_path: "IT-SHARED/10_RUNBOOKS/NOC/NOC-OPS-Dispatch_V2.md"
    agent_recommande: "@IT-NOCDispatcher"
    risk_level: medium
    domaine: NOC

  - intent_id: it.noc.ops.frontdoor
    title: "Front Door NOC — Réception et Qualification Initiale"
    match_hints:
      - "appel client urgent"
      - "email critique entrant"
      - "alerte RMM P1"
      - "canal d'entrée NOC"
      - "qualification initiale incident"
      - "premier contact incident"
    runbook_path: "IT-SHARED/10_RUNBOOKS/NOC/NOC-OPS-FrontDoor_V2.md"
    agent_recommande: "@IT-FrontLine"
    risk_level: low
    domaine: NOC

  - intent_id: it.noc.ops.incident_command
    title: "Commandement Incident — Triage NOC vers Résolution"
    match_hints:
      - "incident command"
      - "commandement incident P1"
      - "war room incident"
      - "escalade NOC vers TECH"
      - "coordination incident majeur"
      - "incident report NOC"
    runbook_path: "IT-SHARED/10_RUNBOOKS/NOC/NOC-OPS-IncidentCommand_V2.md"
    agent_recommande: "@IT-Commandare-NOC"
    risk_level: high
    domaine: NOC

  # ============================================================
  # DOMAINE: NOC — RMM
  # ============================================================

  - intent_id: it.noc.rmm.cwrmm_auvik_operations
    title: "Opérations CW RMM et Auvik Monitoring"
    match_hints:
      - "ConnectWise RMM"
      - "CW Automate"
      - "Auvik"
      - "monitoring réseau Auvik"
      - "script RMM"
      - "alerte CW RMM"
    runbook_path: "IT-SHARED/10_RUNBOOKS/NOC/NOC-RMM-CWRMM_Auvik_Operations_V2.md"
    agent_recommande: "@IT-MonitoringMaster"
    risk_level: medium
    domaine: NOC

  - intent_id: it.noc.rmm.nable_operations
    title: "Opérations N-able / N-sight RMM"
    match_hints:
      - "N-able"
      - "N-sight"
      - "RMM N-able"
      - "alerte N-able"
      - "script N-able"
      - "tableau de bord N-able"
    runbook_path: "IT-SHARED/10_RUNBOOKS/NOC/NOC-RMM-NAble_Operations_V2.md"
    agent_recommande: "@IT-MonitoringMaster"
    risk_level: medium
    domaine: NOC

  # ============================================================
  # DOMAINE: OPR
  # ============================================================

  - intent_id: it.opr.cmdb.reconciliation_cw_hudu_rmm
    title: "Réconciliation CMDB — CW / Hudu / RMM"
    match_hints:
      - "réconciliation CMDB"
      - "actif manquant Hudu"
      - "mismatch CW et RMM"
      - "documentation Hudu pas à jour"
      - "gap CMDB monitoring"
      - "actif sans backup"
    runbook_path: "IT-SHARED/10_RUNBOOKS/OPR/OPR-CMDB-Reconciliation-CW-Hudu-RMM_V1.md"
    agent_recommande: "@IT-AssetMaster"
    risk_level: medium
    domaine: OPR
    note: "DRAFT — squelette Factory en attente d'enrichissement"

  - intent_id: it.opr.cw.ticket_quality_audit
    title: "Audit Qualité Ticket CW avant Clôture"
    match_hints:
      - "audit qualité ticket"
      - "clôture ticket CW"
      - "DoD ticket"
      - "vérification avant fermer billet"
      - "note interne manquante"
      - "ticket P1 clôture artefacts"
    runbook_path: "IT-SHARED/10_RUNBOOKS/OPR/OPR-CW-TicketQualityAudit_V1.md"
    agent_recommande: "@IT-TicketOpr"
    risk_level: low
    domaine: OPR
    note: "DRAFT — squelette Factory en attente d'enrichissement"

  - intent_id: it.opr.client_communication.cadence
    title: "Cadence Communication Client — Incidents et Maintenance"
    match_hints:
      - "communication client"
      - "mise à jour client P1"
      - "status update client"
      - "cadence communication incident"
      - "fenêtre maintenance client"
      - "ticket bloqué mise à jour"
    runbook_path: "IT-SHARED/10_RUNBOOKS/OPR/OPR-ClientCommunication-Cadence_V1.md"
    agent_recommande: "@IT-Commandare-OPR"
    risk_level: low
    domaine: OPR
    note: "DRAFT — squelette Factory en attente d'enrichissement"

  - intent_id: it.opr.eol_eos.risk_register
    title: "Registre Risques EOL/EOS Équipements et Logiciels"
    match_hints:
      - "EOL"
      - "end of life"
      - "end of support"
      - "EOS équipement"
      - "matériel obsolète"
      - "registre risques EOL"
    runbook_path: "IT-SHARED/10_RUNBOOKS/OPR/OPR-EOL-EOS-RiskRegister_V1.md"
    agent_recommande: "@IT-AssetMaster"
    risk_level: medium
    domaine: OPR
    note: "DRAFT — squelette Factory en attente d'enrichissement"

  - intent_id: it.opr.handoff.shift_change
    title: "Handoff / Passation de Quart"
    match_hints:
      - "passation de quart"
      - "handoff NOC"
      - "fin de quart"
      - "transfert incidents"
      - "rapport handover"
      - "shift change"
    runbook_path: "IT-SHARED/10_RUNBOOKS/OPR/OPR-Handoff-ShiftChange_V1.md"
    agent_recommande: "@IT-Commandare-OPR"
    risk_level: low
    domaine: OPR
    note: "DRAFT — squelette Factory en attente d'enrichissement"

  - intent_id: it.opr.monthly.client_ops_pack
    title: "Pack Opérations Client Mensuel"
    match_hints:
      - "rapport mensuel client"
      - "ops pack mensuel"
      - "résumé mensuel MSP"
      - "revue mensuelle client"
      - "bilan mensuel opérations"
    runbook_path: "IT-SHARED/10_RUNBOOKS/OPR/OPR-Monthly-Client-OpsPack_V1.md"
    agent_recommande: "@IT-ReportMaster"
    risk_level: low
    domaine: OPR
    note: "DRAFT — squelette Factory en attente d'enrichissement"

  - intent_id: it.opr.postincident.review_p1p2
    title: "Post-Incident Review P1/P2"
    match_hints:
      - "post-incident review"
      - "PIR"
      - "revue post incident"
      - "rapport P1 résolu"
      - "bilan incident majeur"
      - "root cause analysis incident"
    runbook_path: "IT-SHARED/10_RUNBOOKS/OPR/OPR-PostIncident-Review-P1P2_V1.md"
    agent_recommande: "@IT-ReportMaster"
    risk_level: medium
    domaine: OPR

  - intent_id: it.opr.problem_management.capa
    title: "Gestion des Problèmes Récurrents — CAPA"
    match_hints:
      - "problème récurrent"
      - "même incident revient"
      - "CAPA"
      - "RCA analyse cause racine"
      - "dette technique récurrence"
      - "3 incidents même système"
    runbook_path: "IT-SHARED/10_RUNBOOKS/OPR/OPR-ProblemManagement-CAPA_V1.md"
    agent_recommande: "@IT-Commandare-OPR"
    risk_level: medium
    domaine: OPR

  - intent_id: it.opr.qbr.data_collection
    title: "Collecte de Données QBR"
    match_hints:
      - "QBR"
      - "quarterly business review"
      - "revue trimestrielle client"
      - "données pour QBR"
      - "préparation QBR client"
    runbook_path: "IT-SHARED/10_RUNBOOKS/OPR/OPR-QBR-DataCollection_V1.md"
    agent_recommande: "@IT-ReportMaster"
    risk_level: low
    domaine: OPR
    note: "DRAFT — squelette Factory en attente d'enrichissement"

  - intent_id: it.opr.sla.breach_prevention
    title: "Prévention Breaches SLA"
    match_hints:
      - "SLA à risque"
      - "billet en retard"
      - "breach SLA"
      - "ticket overdue"
      - "SLA dépassé"
      - "priorité changée SLA"
    runbook_path: "IT-SHARED/10_RUNBOOKS/OPR/OPR-SLA-BreachPrevention_V1.md"
    agent_recommande: "@IT-Commandare-OPR"
    risk_level: medium
    domaine: OPR

  - intent_id: it.opr.weekly.ops_review
    title: "Revue Opérationnelle Hebdomadaire"
    match_hints:
      - "revue hebdomadaire"
      - "weekly ops review"
      - "réunion OPS semaine"
      - "bilan semaine MSP"
      - "review hebdo incidents"
    runbook_path: "IT-SHARED/10_RUNBOOKS/OPR/OPR-Weekly-OpsReview_V1.md"
    agent_recommande: "@IT-Commandare-OPR"
    risk_level: low
    domaine: OPR
    note: "DRAFT — squelette Factory en attente d'enrichissement"

  # ============================================================
  # DOMAINE: PROJET
  # ============================================================

  - intent_id: it.projet.sow.process
    title: "Processus Projet et SOW MSP — Détection et Escalade Ventes"
    match_hints:
      - "SOW"
      - "devis client"
      - "opportunité ventes"
      - "escalade ventes"
      - "nouveau projet client"
      - "migration infrastructure client"
    runbook_path: "IT-SHARED/10_RUNBOOKS/PROJET/PROJET-SOW_Process_V1.md"
    agent_recommande: "@IT-Commandare-OPR"
    risk_level: low
    domaine: PROJET

  # ============================================================
  # DOMAINE: SECURITY
  # ============================================================

  - intent_id: it.security.compliance.5piliers
    title: "Framework 5 Piliers — Scoring Maturité Sécurité MSP"
    match_hints:
      - "5 piliers sécurité"
      - "score maturité sécurité"
      - "audit initial client"
      - "scoring sécurité MSP"
      - "lifecycle risk governance"
      - "rapport sécurité client exécutif"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SECURITY/SEC-COMPLIANCE-5Piliers_Framework_V1.md"
    agent_recommande: "@IT-ComplianceMaster"
    risk_level: medium
    domaine: SECURITY

  - intent_id: it.security.entra.security_compliance
    title: "Audit Posture Sécurité Entra ID / MFA / PIM / CA"
    match_hints:
      - "audit Entra ID sécurité"
      - "PIM Entra"
      - "Identity Protection"
      - "comptes privilégiés Entra"
      - "Conditional Access audit"
      - "guests Entra ID"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SECURITY/SEC-ENTRA-SecurityCompliance_V1.md"
    agent_recommande: "@IT-ComplianceMaster"
    risk_level: high
    domaine: SECURITY

  - intent_id: it.security.m365.compliance_purview
    title: "Conformité M365 Purview — DLP / Rétention / Defender"
    match_hints:
      - "Microsoft Purview"
      - "DLP"
      - "rétention données M365"
      - "Defender M365"
      - "compliance.microsoft.com"
      - "Secure Score M365"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SECURITY/SEC-M365-Compliance_Purview_V2.md"
    agent_recommande: "@IT-SecurityMaster"
    risk_level: high
    domaine: SECURITY

  - intent_id: it.security.ops.license_audit
    title: "Audit Licences Logiciels et M365"
    match_hints:
      - "audit licences"
      - "inventaire logiciels"
      - "licences M365 utilisées"
      - "logiciel non autorisé"
      - "Software_Inventory"
      - "licences excédentaires"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SECURITY/SEC-OPS-LicenseAudit_V2.md"
    agent_recommande: "@IT-SecurityMaster"
    risk_level: low
    domaine: SECURITY

  - intent_id: it.security.purview.compliance_audit
    title: "Audit Conformité Purview — DLP / Labels / Insider Risk"
    match_hints:
      - "audit Purview"
      - "sensitivity labels"
      - "Insider Risk Management"
      - "compliance manager"
      - "partage externe M365"
      - "étiquettes de confidentialité"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SECURITY/SEC-PURVIEW-ComplianceAudit_V1.md"
    agent_recommande: "@IT-ComplianceMaster"
    risk_level: medium
    domaine: SECURITY

  - intent_id: it.security.secu.alert_response
    title: "Réponse aux Alertes Monitoring et Sécurité"
    match_hints:
      - "alerte sécurité"
      - "alerte RMM suspecte"
      - "alerte monitoring"
      - "faux positif alerte"
      - "désactiver alerte"
      - "IOC indicateur compromission"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SECURITY/SEC-SECU-AlertResponse_V2.md"
    agent_recommande: "@IT-MonitoringMaster"
    risk_level: high
    domaine: SECURITY

  - intent_id: it.security.secu.incident_response
    title: "Réponse à Incident Cybersécurité P1/P2"
    match_hints:
      - "ransomware"
      - "incident sécurité"
      - "breach"
      - "phishing actif"
      - "alerte EDR confirmée"
      - "chiffrement fichiers"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SECURITY/SEC-SECU-IncidentResponse_V3.md"
    agent_recommande: "@IT-SecurityMaster"
    risk_level: critical
    domaine: SECURITY

  - intent_id: it.security.secu.security_audit
    title: "Audit de Sécurité Infrastructure et Conformité"
    match_hints:
      - "audit sécurité"
      - "revue sécurité infrastructure"
      - "rapport sécurité"
      - "analyse posture sécurité"
      - "audit conformité"
      - "revue sécurité annuelle"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SECURITY/SEC-SECU-SecurityAudit_V2.md"
    agent_recommande: "@IT-SecurityMaster"
    risk_level: high
    domaine: SECURITY

  # ============================================================
  # DOMAINE: SUPPORT — OPS
  # ============================================================

  - intent_id: it.support.ops.cw_dispatch_types
    title: "Dispatch ConnectWise — Types / Sub-types / Files"
    match_hints:
      - "type billet ConnectWise"
      - "sub-type CW"
      - "classer billet CW"
      - "file de travail ticket"
      - "dispatch CW type sous-type"
      - "ticket source outil ou client"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/RUNBOOK__IT_MSP_CONNECTWISE_DISPATCH_V1.md"
    agent_recommande: "@IT-NOCDispatcher"
    risk_level: low
    domaine: SUPPORT

  - intent_id: it.support.m365.onedrive_sharepoint_sync
    title: "Dépannage Sync OneDrive / SharePoint"
    match_hints:
      - "OneDrive rouge"
      - "OneDrive ne synchronise pas"
      - "fichier bloqué OneDrive"
      - "SharePoint sync erreur"
      - "conflit fichier OneDrive"
      - "OneDrive icône bleue tournante"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-M365-OneDrive_SharePoint_Sync_V2.md"
    agent_recommande: "@IT-Assistant-N2"
    risk_level: low
    domaine: SUPPORT

  - intent_id: it.support.n1n2.support_triage
    title: "Triage Support N1/N2/N3 — Escalade et Routing"
    match_hints:
      - "triage support"
      - "escalade N2 N3"
      - "qualifier ticket support"
      - "quel département escalader"
      - "niveau 1 2 3"
      - "ticket entrant support"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-N1N2-SupportTriage_V2.md"
    agent_recommande: "@IT-FrontLine"
    risk_level: low
    domaine: SUPPORT

  - intent_id: it.support.n2.support
    title: "Support N2 — Poste / Compte / Réseau / VPN / Logiciels"
    match_hints:
      - "réinitialiser mot de passe"
      - "problème poste utilisateur"
      - "support N2"
      - "dépannage Wi-Fi bureau"
      - "installer logiciel"
      - "compte verrouillé"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-N2-Support_V2.md"
    agent_recommande: "@IT-Assistant-N2"
    risk_level: low
    domaine: SUPPORT

  - intent_id: it.support.net.vpn_troubleshooting
    title: "Dépannage VPN — Firewalls (Fortinet / WatchGuard / SonicWall)"
    match_hints:
      - "VPN site-à-site en panne"
      - "tunnel VPN IPsec"
      - "SSL VPN Fortinet"
      - "WatchGuard VPN"
      - "SonicWall VPN"
      - "dépannage firewall VPN"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-NET-VPN_Troubleshooting_V2.md"
    agent_recommande: "@IT-NetworkMaster"
    risk_level: medium
    domaine: SUPPORT

  - intent_id: it.support.ops.cw_dispatch
    title: "Dispatch CW — Standardisation Billets"
    match_hints:
      - "standardiser dispatch CW"
      - "ticket CW Auvik RMM"
      - "billet source outil"
      - "file NOC maintenance"
      - "ticket backup Backup Radar"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-OPS-CW_Dispatch_V2.md"
    agent_recommande: "@IT-NOCDispatcher"
    risk_level: low
    domaine: SUPPORT

  - intent_id: it.support.ops.cw_intervention_live_close
    title: "Intervention Live et Clôture Billet ConnectWise"
    match_hints:
      - "intervention live CW"
      - "clôture billet"
      - "note interne CW"
      - "CW discussion client"
      - "journal intervention"
      - "fermer billet ConnectWise"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-OPS-CW_InterventionLive_Close_V2.md"
    agent_recommande: "@IT-TechOnsite"
    risk_level: medium
    domaine: SUPPORT

  - intent_id: it.support.ops.commandare_opr
    title: "Commandement OPR — Clôture Billet et Templates CW"
    match_hints:
      - "clôturer billet MSP"
      - "CW note interne format"
      - "CW discussion client facturable"
      - "template clôture"
      - "première ligne note interne CW"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-OPS-CommandareOPR_V1.md"
    agent_recommande: "@IT-Commandare-OPR"
    risk_level: low
    domaine: SUPPORT

  - intent_id: it.support.ops.commandare_tech
    title: "Commandement Tech — Réception Incident et Troubleshooting"
    match_hints:
      - "réception incident technique"
      - "collecter infos incident"
      - "méthode troubleshooting"
      - "commandare tech"
      - "diagnostic technique incident"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-OPS-CommandareTech_V1.md"
    agent_recommande: "@IT-Commandare-TECH"
    risk_level: medium
    domaine: SUPPORT

  - intent_id: it.support.ops.ticket_to_kb
    title: "Ticket MSP vers Diagnostic → Communication → Knowledge Base"
    match_hints:
      - "ticket vers KB"
      - "documentation depuis ticket"
      - "créer article KB depuis billet"
      - "capitaliser incident"
      - "ticket to knowledge"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-OPS-TicketToKB_V2.md"
    agent_recommande: "@IT-KnowledgeKeeper"
    risk_level: low
    domaine: SUPPORT

  # ============================================================
  # DOMAINE: SUPPORT — WKS (Postes de Travail)
  # ============================================================

  - intent_id: it.support.wks.alerte_av
    title: "Triage Alerte Antivirus / Comportement Suspect Poste"
    match_hints:
      - "alerte antivirus"
      - "alerte AV poste"
      - "virus détecté"
      - "comportement suspect poste"
      - "faux positif antivirus"
      - "malware possible"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Alerte_AV_V1.md"
    agent_recommande: "@IT-FrontLine"
    risk_level: high
    domaine: SUPPORT

  - intent_id: it.support.wks.imprimante
    title: "Dépannage Imprimante Locale / Réseau Poste Client"
    match_hints:
      - "imprimante ne fonctionne pas"
      - "imprimante hors ligne"
      - "file impression bloquée"
      - "imprimante non détectée"
      - "impossible d'imprimer"
      - "driver imprimante"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Imprimante_V1.md"
    agent_recommande: "@IT-TechOnsite"
    risk_level: low
    domaine: SUPPORT

  - intent_id: it.support.wks.login
    title: "Problème de Connexion Windows / M365 / Azure AD"
    match_hints:
      - "ne peut pas se connecter"
      - "mot de passe refusé"
      - "compte verrouillé"
      - "erreur connexion Windows"
      - "authentification M365 échoue"
      - "MFA bloque connexion"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Login_V1.md"
    agent_recommande: "@IT-FrontLine"
    risk_level: medium
    domaine: SUPPORT

  - intent_id: it.support.wks.offboarding
    title: "Offboarding Employé — Désactivation Compte et Poste"
    match_hints:
      - "départ employé"
      - "offboarding"
      - "désactiver compte employé"
      - "libérer licence employé qui part"
      - "wipe poste départ"
      - "redirection email employé quitte"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Offboarding_V1.md"
    agent_recommande: "@IT-TechOnsite"
    risk_level: high
    domaine: SUPPORT

  - intent_id: it.support.wks.onboarding_poste
    title: "Onboarding Nouveau Poste de Travail"
    match_hints:
      - "préparer nouveau poste"
      - "onboarding poste"
      - "configurer poste arrivée employé"
      - "joindre domaine nouveau poste"
      - "checklist nouveau ordinateur"
      - "installer apps nouveau poste"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Onboarding_Poste_V1.md"
    agent_recommande: "@IT-TechOnsite"
    risk_level: medium
    domaine: SUPPORT

  - intent_id: it.support.wks.outlook
    title: "Dépannage Outlook / M365 — Profil / Sync / Plantage"
    match_hints:
      - "Outlook ne démarre pas"
      - "Outlook plante"
      - "Outlook invite mot de passe"
      - "courriel ne reçoit pas"
      - "Outlook lent"
      - "recherche Outlook ne fonctionne pas"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Outlook_V1.md"
    agent_recommande: "@IT-Assistant-N2"
    risk_level: low
    domaine: SUPPORT

  - intent_id: it.support.wks.partage_reseau
    title: "Dépannage Lecteurs Réseau / Partages SMB"
    match_hints:
      - "lecteur réseau disparu"
      - "lecteur P Q R ne monte pas"
      - "accès refusé partage réseau"
      - "partage SMB lent"
      - "lecteur réseau erreur"
      - "partage réseau VPN"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Partage_Reseau_V1.md"
    agent_recommande: "@IT-Assistant-N2"
    risk_level: low
    domaine: SUPPORT

  - intent_id: it.support.wks.poste_lent
    title: "Diagnostic Poste Lent — Matériel / Ressources / Réseau"
    match_hints:
      - "poste lent"
      - "ordinateur lent"
      - "PC très lent"
      - "lenteur poste de travail"
      - "tout est lent depuis ce matin"
      - "poste lagge"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Poste_Lent_V1.md"
    agent_recommande: "@IT-TechOnsite"
    risk_level: low
    domaine: SUPPORT

  - intent_id: it.support.wks.profil_corrompu
    title: "Réparation Profil Utilisateur Windows Corrompu"
    match_hints:
      - "profil corrompu"
      - "profil temporaire Windows"
      - "bureau vide après connexion"
      - "profil utilisateur service erreur"
      - "paramètres disparaissent"
      - "profil se réinitialise"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Profil_Corrompu_V1.md"
    agent_recommande: "@IT-TechOnsite"
    risk_level: medium
    domaine: SUPPORT

  - intent_id: it.support.wks.teams_av
    title: "Dépannage Teams Audio/Vidéo — Son / Caméra / Réunions"
    match_hints:
      - "Teams pas de son"
      - "micro Teams ne fonctionne pas"
      - "caméra non détectée Teams"
      - "rejoindre réunion Teams erreur"
      - "Teams audio vidéo problème"
      - "Teams ne démarre pas"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Teams_AV_V1.md"
    agent_recommande: "@IT-Assistant-N2"
    risk_level: low
    domaine: SUPPORT

  - intent_id: it.support.wks.vpn_client
    title: "Dépannage VPN Client — GlobalProtect / AnyConnect / FortiClient"
    match_hints:
      - "VPN ne connecte pas"
      - "GlobalProtect erreur"
      - "AnyConnect"
      - "FortiClient VPN"
      - "VPN déconnecte"
      - "ressources inaccessibles après VPN"
    runbook_path: "IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-VPN_Client_V1.md"
    agent_recommande: "@IT-Assistant-N2"
    risk_level: low
    domaine: SUPPORT
```

---

*Généré automatiquement par scan des 93 runbooks actifs — IT-SHARED/10_RUNBOOKS/*
*Prochain scan recommandé : à chaque ajout ou modification de runbook*
*Responsable mise à jour : IT-OPS-SyncFactory + validation EA*
