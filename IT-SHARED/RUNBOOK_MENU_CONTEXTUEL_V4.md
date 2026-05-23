# RUNBOOK_MENU_CONTEXTUEL — IT MSP Intelligence Platform
# Version 4.0 | 2026-04-13
# FICHIER KNOWLEDGE — uploader dans chaque GPT Editor (1 fichier pour tous les agents).
# Les Instructions contiennent uniquement les numéros + menu du rôle.
# Ce fichier résout numéro → chemin GitHub exact.
# Repo : eriqallain-afk/IT — chemins directs depuis la racine du repo.

---

## RÈGLE D'UTILISATION

Sur `/runbook [numéro ou mot-clé]` → lire le chemin dans la MAP ci-dessous,
appeler `getFileContent` avec le chemin, décoder base64, livrer le contenu.
Si `/runbook` seul → afficher le menu du rôle (section MENUS), puis ⛔ STOP — attendre.

> **Convention :** numéros `B##` = bundles thématiques (couvrent plusieurs runbooks).
> Numéros simples = runbooks individuels. Préférer les bundles quand disponibles.

---

## MAP COMPLÈTE — Numéro → Commande → Chemin

---

### 🖥️ INFRA — Bundles (B01–B09)

| # | Commande | Contenu | Chemin |
|---|---|---|---|
| B01 | `b-infra` | Mega-bundle INFRA complet | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOKS_IT_INFRA.md` |
| B02 | `b-cloud` | Mega-bundle Cloud (M365, Azure, AWS, GCP) | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOKS_IT_CLOUD.md` |
| B03 | `b-reseau-voip` | Réseau + VoIP combinés | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOKS_IT_RESEAU_VOIP.md` |
| B04 | `b-virtualiz` | Virtualisation — Hyper-V + VMware + XCP-ng | `IT-SHARED/60_BUNDLES/BUNDLE_INFRA_VIRTUALISATION.md` |
| B05 | `b-ad` | AD opérations — DC, users, GPO, réplication | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOK_INFRA_AD-Operations_V1.md` |
| B06 | `b-hyperv` | Hyperviseurs — Hyper-V, VMware, XCP-ng détaillé | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOK_INFRA_Hyperviseurs_V1.md` |
| B07 | `b-m365` | M365 complet — Exchange, Intune, Teams, Entra | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOK_INFRA_M365_V1.md` |
| B08 | `b-rds` | RDS — sessions, services, profils, licences | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOK_INFRA_RDS-Operations_V1.md` |
| B09 | `b-fw-vpn` | Firewalls + VPN — Fortinet, WatchGuard, SonicWall, Meraki | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOK_INFRA_Firewall-VPN_V1.md` |

### 🖥️ INFRA — Runbooks individuels (01–19c)

| # | Commande | Alias | Chemin |
|---|---|---|---|
| 01 | `dc` | | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA__RUNBOOK__DC_PrePost_Validation` |
| 02 | `sql` | | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-SQL_PrePost_Validation_V2.md` |
| 03 | `srv` | serveur | `IT-SHARED/60_BUNDLES/BUNDLE_INFRA_SERVER.md` |
| 04 | `rds` | | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-RDS_Operations_V2.md` |
| 05 | `ad-dc` | | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-DC_Operations_V3.md` |
| 06 | `ad-user` | | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-UserManagement_V2.md` |
| 06b | `ad-gpo` | gpo, stratégie groupe | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-GPO_Management_V1.md` |
| 06c | `ad-folder` | folder, dossier, ntfs, permissions | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-FolderSecurity_V1.md` |
| 07 | `hyperv` | | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-HyperV_Operations_V2.md` |
| 08 | `vmware` | | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-VMware_Operations_V2.md` |
| 09 | `xcpng` | virtualiz | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-XCPng_Operations_V1.md` |
| 09b | `new-vm` | nouvelle vm, provisioning, déploiement vm | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-NewVM_Deployment_V1.md` |
| 10 | `fw` | firewall | `IT-SHARED/60_BUNDLES/BUNDLE_INFRA_FIREWALL.md` |
| 10b | `net-cfg` | firewall | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-NET-NetworkSetup_V1.md` |
| 10c | `net-diag` | network | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-NET-NetworkDiagnostic_V2.md` |
| 11 | `dns` | | `IT-SHARED/60_BUNDLES/BUNDLE_INFRA_DNS_Domains_V1.md` |
| 12 | `linux` | | `IT-SHARED/60_BUNDLES/BUNDLE_INFRA_LINUX_V1.md` |
| 13 | `azure` | entraid | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-EntraID_Operations_V2.md` |
| 14 | `m365` | 365 | `IT-SHARED/60_BUNDLES/BUNDLE_INFRA_365.md` |
| 15 | `m365-exchange` | | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-M365-Exchange_Online_V2.md` |
| 16 | `m365-intune` | | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-M365-Intune_Devices_V2.md` |
| 17 | `m365-teams` | teams, sharepoint, onedrive | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-M365-Teams_SharePoint_OneDrive_V2.md` |
| 18 | `m365-user` | | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-M365-UserManagement_V2.md` |
| 19 | `m365-onboard` | | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-M365-UserOnboarding_V2.md` |
| 19b | `aws` | | `IT-SHARED/60_BUNDLES/BUNDLE_INFRA_CLOUD_AWS_V1.md` |
| 19c | `gcp` | | `IT-SHARED/60_BUNDLES/BUNDLE_INFRA_CLOUD_GCP_GoogleWorkspace_V1.md` |

---

### 🔄 MAINTENANCE — Bundles (B20–B21)

| # | Commande | Contenu | Chemin |
|---|---|---|---|
| B20 | `b-patching` | Patching Windows complet — tous scénarios | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOK_MAINTENANCE_Patching-Windows_V1.md` |
| B21 | `b-health` | Santé serveurs — health check + monitoring | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOK_MAINTENANCE_Server-Health_V1.md` |

### 🔄 MAINTENANCE — Runbooks individuels (20–27)

| # | Commande | Alias | Chemin |
|---|---|---|---|
| 20 | `windows-patching` | patching | `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-WIN-Patching_Complet_V3.md` |
| 21 | `patching-cwrmm` | | `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-WIN-Patching_CW-RMM_V3.md` |
| 22 | `pending-reboot` | | `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-WIN-PendingReboot_V2.md` |
| 23 | `server-health` | | `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-SRV-HealthCheck_V2.md` |
| 24 | `wsus` | | `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-WIN-WSUS_Maintenance_V2.md` |
| 25 | `audit-trim` | | `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-SRV-AuditTrimestriel_V2.md` |
| 26 | `post-panne` | post-elec | `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-SRV-PostShutdown_Electrical_V2.md` |
| 27 | `print` | print-prepost | `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-SRV-PrintServer_PrePost_V1.md` |
| 28 | `asset` | inventaire-asset | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-OPS-AssetLifecycle_V1.md` |
| 28a | `audit-license` | asset-inventaire | `IT-SHARED/10_RUNBOOKS/SECURITY/SEC-OPS-LicenseAudit_V2.md` |
| 28b | `audit-cmdb` | asset-audit | `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-OPS-CMDB_AssetAudit_V1.md` |
| 28c| `audit_trimestriel` | asset-audit | `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-SRV-AuditTrimestriel_V2.md` |
---

### 💾 NOC / BACKUP — Bundles (B30–B34)

| # | Commande | Contenu | Chemin |
|---|---|---|---|
| B30 | `b-noc` | Mega-bundle NOC + Urgence | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOKS_IT_NOC_URGENCE.md` |
| B31 | `b-backup-dr` | Backup + DR — Veeam, Datto, Keepit, DR plan | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOKS_IT_BACKUP_DR.md` |
| B32 | `b-veeam` | Veeam opérations détaillées | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOK_BACKUP_Veeam-Operations_V1.md` |
| B33 | `b-datto-keepit` | Datto BCDR + Keepit M365 + DR plan | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOK_BACKUP_Datto-Keepit-DR_V1.md` |
| B34 | `b-rmm` | RMM monitoring — N-able + CW RMM + Auvik | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOK_NOC_RMM-Monitoring_V1.md` |
| B35 | `b-noc-int` | NOC intervention live — procédures et escalade | `IT-SHARED/60_BUNDLES/BUNDLE_NOC_Intervention_V1.md` |


### 💾 NOC / BACKUP — Runbooks individuels (30–39)

| # | Commande | Alias | Chemin |
|---|---|---|---|
| 30 | `incident-command` | | `IT-SHARED/10_RUNBOOKS/NOC/NOC-OPS-IncidentCommand_V2.md` |
| 31 | `frontdoor` | | `IT-SHARED/10_RUNBOOKS/NOC/NOC-OPS-FrontDoor_V2.md` |
| 32 | `veeam` | | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOK_BACKUP_Veeam-Operations_V1.md` |
| 32c | `veeam-opr` | | `IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Veeam_Operations_V2.md` |
| 32b | `bckup-cfg` | | `IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Backup_Configuration_V2.md` |
| 33 | `datto` | | `IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Datto_Operations_V2.md` |
| 34 | `keepit` | | `IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Keepit_Operations_V2.md` |
| 35 | `dr-plan` | | `IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-DR_Plan_Validation_V2.md` |
| 36 | `backup-dr` | backup | `IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-DR_Test_V2.md` |
| 37 | `nable` | | `IT-SHARED/10_RUNBOOKS/NOC/NOC-RMM-NAble_Operations_V2.md` |
| 38 | `cwrmm-auvik` | | `IT-SHARED/10_RUNBOOKS/NOC/NOC-RMM-CWRMM_Auvik_Operations_V2.md` |
| 39 | `bckup` | | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOK_BACKUP_Datto-Keepit-DR_V1.md` |
| 39a | `backup-status` | Validation statut sauvegardes — radar backup NOC | `IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Validation_Statut_Sauvegardes_V1.md` |
| 39b | `restore-trim` | Test de restauration trimestriel — RTO/RPO, scénarios rotation, conformité | `IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Restore_Test_Trimestriel_V1.md` |

---

### 🛡️ SÉCURITÉ — Bundles (B40–B42)

| # | Commande | Contenu | Chemin |
|---|---|---|---|
| B40 | `b-secu` | Mega-bundle sécurité MSP complet | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOKS_IT_SECURITE.md` |
| B41 | `b-ir` | Incident Response détaillé — IR + postmortem | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOK_SECURITY_Incident-Response_V1.md` |
| B42 | `b-soc-siem` | SOC/SIEM — ransomware, threat hunting, SIEM | `IT-SHARED/60_BUNDLES/BUNDLE_SECURITY_Securite_V1.md` |

### 🛡️ SÉCURITÉ — Runbooks individuels (40–44)

| # | Commande | Alias | Chemin |
|---|---|---|---|
| 40 | `securite-ir` | | `IT-SHARED/10_RUNBOOKS/SECURITY/SEC-SECU-IncidentResponse_V3.md` |
| 41 | `alert-response` | | `IT-SHARED/10_RUNBOOKS/SECURITY/SEC-SECU-AlertResponse_V2.md` |
| 42 | `ransomware` | soc-triage, threat-hunting | `IT-SHARED/60_BUNDLES/BUNDLE_NOC_SOC_SIEM_V1.md` |
| 43 | `security-audit` | | `IT-SHARED/10_RUNBOOKS/SECURITY/SEC-SECU-SecurityAudit_V2.md` |
| 44 | `m365-compliance` | | `IT-SHARED/10_RUNBOOKS/SECURITY/SEC-M365-Compliance_Purview_V2.md` |

---

### 🎧 SUPPORT — Bundles (B50–B53)

| # | Commande | Contenu | Chemin |
|---|---|---|---|
| B50 | `b-support` | Mega-bundle support MSP complet | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOKS_IT_SUPPORT.md` |
| B51 | `b-n1` | Support N1/N2 — MDP, comptes, WiFi, logiciels | `IT-SHARED/60_BUNDLES/BUNDLE_SUPPORT_N1_UserSupport_V1.md` |
| B52 | `b-live` | Intervention live — CW close, dispatch, KB | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOK_SUPPORT_Intervention-Live_V1.md` |
| B53 | `b-triage-kb` | Triage N1/N2/N3 + création KB | `IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOK_SUPPORT_Triage-KB_V1.md` |

### 🎧 SUPPORT — Runbooks individuels (50–62b)

| # | Commande | Alias | Chemin |
|---|---|---|---|
| 50 | `triage-support` | triage | `IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-N1N2-SupportTriage_V2.md` |
| 51 | `support-n2` | mdp, compte, wifi, logiciel, application | `IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-N2-Support_V2.md` |
| 53 | `imprimante` | print-diag | `IT-SHARED/60_BUNDLES/BUNDLE_SUPPORT_Print_Diag_V1.md` |
| 55 | `vpn` | | `IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-NET-VPN_Troubleshooting_V2.md` |
| 58 | `srv-ad` | serveur-opr | `IT-SHARED/60_BUNDLES/BUNDLE_SUPPORT_SERVER-AD.md` |
| 59 | `onedrive-sync` | M365-sync | `IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-M365-OneDrive_SharePoint_Sync_V2.md` |
| 60 | `intervention` | | `IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-OPS-CW_InterventionLive_Close_V2.md` |
| 61 | `close-cw` | | `IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-OPS-CW_InterventionLive_Close_V2.md` |
| 62 | `dispatch` | | `IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-OPS-CW_Dispatch_V2.md` |
| 62b | `ticket-to-kb` | | `IT-SHARED/10_RUNBOOKS/SUPPORT/SUP-OPS-TicketToKB_V2.md` |

### 💻 POSTES DE TRAVAIL (WKS) — Runbooks N2 / FrontLine (52a–52k)

| # | Commande | Alias | Chemin |
|---|---|---|---|
| 52a | `wks-lent` | poste-lent, lent, rame, cpu, ram, slow | `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Poste_Lent_V1.md` |
| 52b | `wks-login` | connexion, mdp-windows, compte-bloque, locked | `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Login_V1.md` |
| 52c | `wks-outlook` | outlook, email-client, profil-outlook, ost | `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Outlook_V1.md` |
| 52d | `wks-teams` | teams, audio, video, camera, micro, reunion | `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Teams_AV_V1.md` |
| 52e | `wks-print` | imprimante-client, print-wks, spooler | `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Imprimante_V1.md` |
| 52f | `wks-partage` | lecteur-reseau, partage, smb, unc, P-drive | `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Partage_Reseau_V1.md` |
| 52g | `wks-vpn` | vpn-client, tunnel, acces-distant | `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-VPN_Client_V1.md` |
| 52h | `wks-av` | alerte-av, antivirus, virus, suspect, malware | `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Alerte_AV_V1.md` |
| 52i | `wks-profil` | profil-corrompu, profil-temporaire, ntuser | `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Profil_Corrompu_V1.md` |
| 52j | `wks-onboard` | onboarding-poste, nouveau-poste, deploiement-wks | `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Onboarding_Poste_V1.md` |
| 52k | `wks-offboard` | offboarding, depart-employe, wipe, wks-decommission | `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/SUP-WKS-Offboarding_V1.md` |

---

### 📋 TEMPLATES (80–89f)

| # | Commande | Alias | Chemin |
|---|---|---|---|
| 80 | `tpl-cw` | | `IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW/TEMPLATE_BUNDLE_CW_CLOSE.md` |
| 81 | `tpl-note` | | `IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW/TEMPLATE__CW_NOTE_INTERNE.md` |
| 82 | `tpl-discussion` | | `IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW/TEMPLATE__CW_DISCUSSION.md` |
| 83 | `tpl-email` | | `IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW/TEMPLATE__EMAIL_CLIENT.md` |
| 84 | `tpl-teams` | | `IT-SHARED/20_TEMPLATES/02_TEMPLATE_COM/TEMPLATE_COM_Teams-Incident-Actif_V1.md` |
| 85 | `tpl-flagup` | | `IT-SHARED/20_TEMPLATES/02_TEMPLATE_COM/TEMPLATE__FLAG_UP_AVERTISSEMENT.md` |
| 86 | `tpl-postmortem` | | `IT-SHARED/20_TEMPLATES/08_TEMPLATE_REPORTS/TEMPLATE_REPORT_Postmortem_V2.md` |
| 87 | `tpl-qbr` | | `IT-SHARED/20_TEMPLATES/08_TEMPLATE_REPORTS/TEMPLATE_REPORT_QBR_V1.md` |
| 88 | `tpl-mensuel` | | `IT-SHARED/20_TEMPLATES/08_TEMPLATE_REPORTS/TEMPLATE_REPORT_Mensuel_V1.md` |
| 89 | `tpl-hudu` | edocs | `IT-SHARED/20_TEMPLATES/09_TEMPLATE_HUDU/TEMPLATE__EDOCS_FICHE_OBJET_IT.md` |
| 89b | `tpl-kb` | | `IT-SHARED/20_TEMPLATES/05_TEMPLATE_KNOWLEDGE/TEMPLATE_KNOWLEDGE_KB-Article-et-Procedure_V1.md` |
| 89c | `tpl-incident` | | `IT-SHARED/20_TEMPLATES/06_TEMPLATE _INCIDENT/TEMPLATE__INCIDENT_CRITIQUE.md` |
| 89d | `tpl-dr-test` | | `IT-SHARED/20_TEMPLATES/07_TEMPLATE_BACKUP/TEMPLATE_BACKUP_DR-Test-et-Restore_V1.md` |
| 89e | `tpl-post-panne` | | `IT-SHARED/20_TEMPLATES/12_TEMPLATE_DIAG/TEMPLATE_DIAG_PostPanneHQ.md` |
| 89f | `tpl-naming` | | `IT-SHARED/20_TEMPLATES/13_NAMING_STANDARDS/NAMING_STANDARDS_v1.md` |
| 89g | `tpl-intervention` | Compte rendu intervention standard — chronologie + raison étapes | `IT-SHARED/20_TEMPLATES/06_TEMPLATE _INCIDENT/TEMPLATE_INTERVENTION_Standard_V1.md` |
| 89h | `tpl-p1` | Rapport incident majeur P1 — post-mortem, RCA, actions correctives | `IT-SHARED/20_TEMPLATES/06_TEMPLATE _INCIDENT/TEMPLATE_INTERVENTION_P1_PostMortem_V1.md` |
| 89i | `tpl-compact` | Intervention courte <30 min — traçabilité minimale | `IT-SHARED/20_TEMPLATES/06_TEMPLATE _INCIDENT/TEMPLATE_INTERVENTION_Compact_V1.md` |

### 📜 SCRIPTS (63–68)

| # | Commande | Chemin |
|---|---|---|
| 63 | `/script lib` | `IT-SHARED/30_SCRIPTS/LIBRARY_PS_PowerShell-Snippets_V1.md` |
| 63b | `/script lib-bash` | `IT-SHARED/30_SCRIPTS/LIBRARY_BASH_Bash-Snippets_V1.md` |
| 63c | `/script lib-events` | `IT-SHARED/30_SCRIPTS/LIBRARY_DIAG_EventLog-Analysis_V1.md` |
| 64 | `/script precheck-dc` | `IT-SHARED/30_SCRIPTS/SCRIPT_PRECHECK_DC_V3.ps1` |
| 64b | `/script precheck-dc-dns` | `IT-SHARED/30_SCRIPTS/SCRIPT_DIAG_Precheck-DC-DNS_V1.ps1` |
| 64c | `/script precheck-hyperv` | `IT-SHARED/30_SCRIPTS/SCRIPT_DIAG_Precheck-HyperV_V1.ps1` |
| 65 | `/script pending-reboot` | `IT-SHARED/30_SCRIPTS/SCRIPT_DIAG_Pending-Reboot_V1.ps1` |
| 66 | `/script precheck-srv` | `IT-SHARED/30_SCRIPTS/SCRIPT_DIAG_Precheck-Server-Generic_V1.ps1` |
| 67 | `/script health-updates` | `IT-SHARED/30_SCRIPTS/SCRIPT_DIAG_Health-and-Updates_V1.ps1` |
| 67b | `/script health-check` | `IT-SHARED/30_SCRIPTS/SCRIPT_AUDIT_HealthCheck-Server_V1.ps1` |
| 67c | `/script slow-srv` | `IT-SHARED/30_SCRIPTS/SCRIPT_DIAG_SLOW_SRV_V1.ps1` |
| 67d | `/script veeam-jobs` | `IT-SHARED/30_SCRIPTS/SCRIPT_BACKUP_Veeam-JobStatus_V1.ps1` |
| 67e | `/script m365-compromis` | `IT-SHARED/30_SCRIPTS/SCRIPT_SECU_M365-CompteCompromis_V1.ps1` |
| 67f | `/script post-panne-hq` | `IT-SHARED/30_SCRIPTS/SCRIPT_PostCheck_PanneHQ.ps1` |
| 68 | `/script template` | `IT-SHARED/30_SCRIPTS/SCRIPT_TEMPLATE_PS-Standard_V1.ps1` |

### ✅ CHECKLISTS (70–79)

| # | Commande | Chemin |
|---|---|---|
| 70 | `/checklist precheck` | `IT-SHARED/40_CHECKLISTS/CHECKLIST_MAINTENANCE_Precheck-Generic_V1.md` |
| 71 | `/checklist postcheck` | `IT-SHARED/40_CHECKLISTS/CHECKLIST_MAINTENANCE_Postcheck-Generic_V1.md` |
| 72 | `/checklist pre-maintenance` | `IT-SHARED/40_CHECKLISTS/CHECKLIST_MAINTENANCE_Pre-Maintenance_V1.md` |
| 73 | `/checklist dr` | `IT-SHARED/40_CHECKLISTS/CHECKLIST_BACKUP_DR-Readiness_V1.md` |
| 74 | `/checklist kickoff` | `IT-SHARED/40_CHECKLISTS/CHECKLIST_CW_Kickoff-Ticket_V1.md` |
| 75 | `/checklist closeout` | `IT-SHARED/40_CHECKLISTS/CHECKLIST_CW_Closeout_V1.md` |
| 76 | `/checklist m365` | `IT-SHARED/40_CHECKLISTS/CHECKLIST_INFRA_M365-Configuration_V1.md` |
| 77 | `/checklist security` | `IT-SHARED/40_CHECKLISTS/CHECKLIST_SECURITY_Hardening-et-Audit_V1.md` |
| 78 | `/checklist noc-handover` | `IT-SHARED/40_CHECKLISTS/CHECKLIST_NOC_Shift-Handover_V1.md` |
| 79 | `/checklist intervention` | `IT-SHARED/40_CHECKLISTS/CHECKLIST_SUPPORT_Intervention-Steps_V1.md` |

### 📖 RÉFÉRENCE (90–96)

| # | Commande | Chemin |
|---|---|---|
| 90 | `/ref sla` | `IT-SHARED/50_REFERENCE/REF__REFERENCE_MASTER_SLA-Matrix_V1.md` |
| 91 | `/ref severity` | `IT-SHARED/50_REFERENCE/REF__REFERENCE_MASTER_Severity-Matrix_V1.md` |
| 92 | `/ref portails` | `IT-SHARED/50_REFERENCE/REF__REFERENCE_INFRA_Cloud-Admin-Portals_V1.md` |
| 93 | `/ref commandes` | `IT-SHARED/50_REFERENCE/REF__REFERENCE_INFRA_Commandes-Reseau-et-Systeme_V1.md` |
| 94 | `/ref naming` | `IT-SHARED/50_REFERENCE/REFERENCE_MASTER_Naming-Standards_V1.md` |
| 95 | `/ref azure` | `IT-SHARED/50_REFERENCE/REF__GUIDE_INFRA_Azure-Troubleshooting_V1.md` |
| 96 | `/ref edocs` | `IT-SHARED/50_REFERENCE/REF__REFERENCE_HUDU_Edocs-Standard_V1.md` |


### 📊 OPR — Opérations / Gouvernance / Rapports (100–110)

| # | Commande | Alias | Chemin |
|---|---|---|---|
| 100 | `ticket-quality` | dod, close-audit, qa-ticket | `IT-SHARED/10_RUNBOOKS/OPR/OPR-CW-TicketQualityAudit_V1.md` |
| 101 | `sla-risk` | breach, sla, escalade-sla | `IT-SHARED/10_RUNBOOKS/OPR/OPR-SLA-BreachPrevention_V1.md` |
| 102 | `client-comms` | cadence, update-client, suivi-client | `IT-SHARED/10_RUNBOOKS/OPR/OPR-ClientCommunication-Cadence_V1.md` |
| 103 | `problem-capa` | problem, recurring, rca, capa | `IT-SHARED/10_RUNBOOKS/OPR/OPR-ProblemManagement-CAPA_V1.md` |
| 104 | `post-incident` | postmortem, p1, p2, pir | `IT-SHARED/10_RUNBOOKS/OPR/OPR-PostIncident-Review-P1P2_V1.md` |
| 105 | `cmdb-reconcile` | cmdb, hudu, rmm, asset-sync | `IT-SHARED/10_RUNBOOKS/OPR/OPR-CMDB-Reconciliation-CW-Hudu-RMM_V1.md` |
| 106 | `eol-risk` | eos, lifecycle, risk-register | `IT-SHARED/10_RUNBOOKS/OPR/OPR-EOL-EOS-RiskRegister_V1.md` |
| 107 | `monthly-opspack` | rapport-mensuel, monthly, opspack | `IT-SHARED/10_RUNBOOKS/OPR/OPR-Monthly-Client-OpsPack_V1.md` |
| 108 | `qbr-prep` | qbr, business-review, data-collection | `IT-SHARED/10_RUNBOOKS/OPR/OPR-QBR-DataCollection_V1.md` |
| 109 | `ops-review` | weekly, revue-ops, handoff | `IT-SHARED/10_RUNBOOKS/OPR/OPR-Weekly-OpsReview_V1.md` |
| 110 | `handoff` | shift, passation, transfert | `IT-SHARED/10_RUNBOOKS/OPR/OPR-Handoff-ShiftChange_V1.md` |
---

## MENUS PAR RÔLE

### MENU — IT-SysAdmin / IT-MaintenanceMaster
```
📂 RUNBOOKS — Tape le numéro ou le mot-clé
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 BUNDLES   [B01]b-infra [B04]b-virtualiz [B05]b-ad [B06]b-hyperv [B07]b-m365 [B08]b-rds [B20]b-patching [B21]b-health
🖥️ INFRA     [01]dc [02]sql [03]srv [04]rds [05]ad-dc [06]ad-user [06b]ad-gpo [06c]ad-folder [07]hyperv [08]vmware [09]xcpng [09b]new-vm [12]linux
🔄 MAINT     [20]windows-patching [22]pending-reboot [23]server-health [24]wsus [25]audit-trim [26]post-panne [27]print
💾 BACKUP    [32]veeam [33]datto [34]keepit [32b]bckup-cfg [35]dr-plan [36]backup-dr [39]bckup [39a]backup-status [39b]restore-trim
☁️ CLOUD     [14]m365 [15]m365-exchange [16]m365-intune [17]m365-teams [13]azure [19b]aws [19c]gcp
🌐 RÉSEAU    [10]fw [10b]net-cfg [10c]net-diag [11]dns
📜 SCRIPTS   [63]lib [64]precheck-dc [66]precheck-srv [67]health-updates [67c]slow-srv [68]template
✅ CHECKS    [70]precheck [71]postcheck [72]pre-maintenance
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### MENU — IT-AssistanTI_N3
```
📂 RUNBOOKS — Tape le numéro ou le mot-clé
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 BUNDLES   [B05]b-ad [B06]b-hyperv [B07]b-m365 [B08]b-rds [B09]b-fw-vpn
🖥️ INFRA     [01]dc [02]sql [04]rds [05]ad-dc [06]ad-user [06b]ad-gpo [06c]ad-folder [07]hyperv [08]vmware [09]xcpng [09b]new-vm
🌐 RÉSEAU    [10]fw [10b]net-cfg [11]dns
💾 BACKUP    [32]veeam [33]datto [34]keepit [32b]bckup-cfg [35]dr-plan [36]backup-dr [39]bckup [39a]backup-status [39b]restore-trim
☁️ M365      [13]azure [15]m365-exchange [16]m365-intune [17]m365-teams [18]m365-user [19]m365-onboard [44]m365-compliance
🛡️ SÉCU      [40]securite-ir [41]alert-response
🎧 SUPPORT   [50]triage [55]vpn [60]intervention [61]close-cw
📜 SCRIPTS   [63]lib [63c]lib-events [64]precheck-dc [64c]precheck-hyperv [66]precheck-srv
✅ CHECKS    [70]precheck [71]postcheck
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### MENU — IT-AssistanTI_N2 / IT-AssistanTI_FrontLine
```
📂 RUNBOOKS — Tape le numéro ou le mot-clé
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 BUNDLES   [B51]b-n1 [B53]b-triage-kb
👤 SUPPORT   [51]support-n2 (mdp/compte/wifi/logiciel/app) [53]imprimante [55]vpn [59]onedrive-sync
💻 WKS       [52a]wks-lent [52b]wks-login [52c]wks-outlook [52d]wks-teams [52e]wks-print
             [52f]wks-partage [52g]wks-vpn [52h]wks-av [52i]wks-profil [52j]wks-onboard [52k]wks-offboard
🖥️ AD/SRV    [58]srv-ad [05]ad-dc [06]ad-user
☁️ M365      [18]m365-user [19]m365-onboard
🎧 OPS       [50]triage [62]dispatch [60]intervention [61]close-cw [74]kickoff
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### MENU — IT-BackupDRMaster
```
📂 RUNBOOKS — Tape le numéro ou le mot-clé
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 BUNDLES   [B31]b-backup-dr [B32]b-veeam [B33]b-datto-keepit
💾 BACKUP    [32]veeam [32b]veeam-diag [32c]veeam-opr [33]datto [34]keepit [32b]bckup-cfg [35]dr-plan [36]backup-dr [39]bckup [39a]backup-status [39b]restore-trim
⚡ URGENCE   [30]incident-command
📜 SCRIPTS   [67d]veeam-jobs
✅ CHECKS    [73]dr
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### MENU — IT-SecurityMaster
```
📂 RUNBOOKS — Tape le numéro ou le mot-clé
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 BUNDLES   [B40]b-secu [B41]b-ir [B42]b-soc-siem
🛡️ SÉCU      [40]securite-ir [41]alert-response [42]ransomware [43]security-audit [44]m365-compliance
⚡ URGENCE   [30]incident-command
📜 SCRIPTS   [67e]m365-compromis
✅ CHECKS    [77]security
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### MENU — IT-UrgenceMaster / IT-Commandare-NOC
```
📂 RUNBOOKS — Tape le numéro ou le mot-clé
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 BUNDLES   [B30]b-noc [B31]b-backup-dr [B35]b-noc-int
⚡ URGENCE   [30]incident-command [31]frontdoor [37]nable [38]cwrmm-auvik [26]post-panne
💾 BACKUP    [32]veeam [33]datto [34]keepit [32b]bckup-cfg [35]dr-plan [36]backup-dr [39]bckup [39a]backup-status [39b]restore-trim
✅ CHECKS    [78]noc-handover
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
### MENU — IT-AssetMaster
```
📂 RUNBOOKS — /runbook [n° ou mot-clé]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 ASSET    Aucun runbook spécifique — appeler via /runbook [sujet] si besoin
📖 REF      [28]asset  [28a]audit-license  [28b]audit-cmdb [28c]audit_trimestriel  [90]sla  [94]naming  

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
### MENU — IT-ClientDocMaster
```
📂 RUNBOOKS — /runbook [n° ou mot-clé]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧭 DOC/HUDU [96]edocs [94]naming
🗂️ AUDIT [28]asset [28a]audit-license [28b]audit-cmdb [28c]audit_trimestriel
🖥️ INFRA [03]srv [07]hyperv [08]vmware [09]xcpng [10]fw [10b]net-cfg [11]dns
💾 BACKUP [32]veeam [33]datto [34]keepit [35]dr-plan [36]backup-dr [39b]restore-trim
☁️ CLOUD [13]azure [14]m365 [15]m365-exchange [16]m365-intune [17]m365-teams
📦 BUNDLES [B04]b-virtualiz [B06]b-hyperv [B07]b-m365 [B09]b-fw-vpn [B31]b-backup-dr
📖 REF [90]sla [92]portails [95]azure
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### MENU — IT-CloudMaster
```
📂 RUNBOOKS — Tape le numéro ou le mot-clé
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 BUNDLES   [B02]b-cloud [B07]b-m365
☁️ M365      [14]m365 [15]m365-exchange [16]m365-intune [17]m365-teams [13]azure [44]m365-compliance [34]keepit
🟠 AWS/GCP   [19b]aws [19c]gcp
🌐 DNS       [11]dns
📖 REF       [92]portails [95]azure
✅ CHECKS    [76]m365
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## BLOC INSTRUCTIONS — À coller dans 00_INSTRUCTIONS.md

```
## RUNBOOKS GITHUB
getFileContent — repo eriqallain-afk/IT — ref main — décoder base64.
Résoudre numéro→chemin dans RUNBOOK_MENU_CONTEXTUEL_V4.md (Knowledge).

Sur /runbook seul → afficher menu ci-dessous puis ⛔ STOP.
Sur /runbook [n° ou mot-clé] → charger directement.
Numéros B## = bundles (préférer aux runbooks individuels).

[COLLER LE MENU DU RÔLE ICI]
```

---

## PLATEFORME — Cycle de vie agent

| # | Commande | Contenu | Chemin |
|---|---|---|---|
| pl1 | `agent-lifecycle` | Runbook ajout/modification/activation/archivage agent | `IT-SHARED/10_RUNBOOKS/00_POLICIES/RUNBOOK__AGENT_LIFECYCLE_V1.md` |
| pl2 | `doc-sync` | Matrice DOC_SYNC — quels fichiers mettre à jour selon type de changement | `00_INDEX/DOC_SYNC_MATRIX.md` |
| pl3 | `guardrails` | Guardrails agents MSP — périmètre, sécurité, refus | `IT-SHARED/10_RUNBOOKS/00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md` |
| pl4 | `prompt-framework` | Framework de prompting MSP Intelligence — 4 couches, Output Policy, gabarits par intent, exemples | `IT-SHARED/10_RUNBOOKS/00_POLICIES/PROMPT_FRAMEWORK_MSP_Intelligence_V1.md` |
| pl5 | `arch-decisions` | Architecture Decision Log — ADRs, conventions, raisons des choix plateforme | `00_DOCS/ARCHITECTURE_DECISION_LOG.md` |

---

## MODULE PROJETS (staging — activation EA requise)

```
📦 MODULE PROJETS (staging — activation EA requise)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💼 PROJET   [p1]sow-process  [p2]sow-template  [p3]pipeline-rapport
📋 CW       [p4]cw-projet-sow
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

| # | Commande | Chemin |
|---|---|---|
| p1 | `sow-process` | `IT-SHARED/10_RUNBOOKS/PROJET/PROJET-SOW_Process_V1.md` |
| p2 | `sow-template` | `IT-SHARED/20_TEMPLATES/16_TEMPLATE_PROJET/TEMPLATE_SOW_CLIENT_V1.md` |
| p3 | `pipeline-rapport` | `IT-SHARED/20_TEMPLATES/08_TEMPLATE_REPORTS/TEMPLATE_RAPPORT_PIPELINE_PROJETS_V1.md` |
| p4 | `cw-projet-sow` | `IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW/TEMPLATE_CW_PROJET_SOW_V1.md` |

*RUNBOOK_MENU_CONTEXTUEL V4 — IT MSP Intelligence Platform — 2026-04-13*
