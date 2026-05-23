# LEGACY_PATH_REGISTRY_RUNBOOK_MENU_V4

**Statut :** DRAFT_MIGRATION  
**Source :** RUNBOOK_MENU_CONTEXTUEL_V4.md  
**But :** conserver la correspondance entre les références actuellement utilisées dans les prompts/menus agents et les anciens chemins GitHub avant toute restructuration.

## Principe

Ce fichier sert de **registre de compatibilité**. Tant que les prompts des agents pointent vers `RUNBOOK_MENU_CONTEXTUEL_V4.md`, les chemins ci-dessous doivent rester valides ou être migrés explicitement.

Règle : **ne jamais renommer ni déplacer un fichier référencé sans inscrire son ancien chemin, son nouveau chemin et le statut de migration.**

## Résumé

- Entrées legacy inventoriées : **101**
- bundle : **36**
- runbook : **50**
- template : **15**

## Colonnes

| Colonne | Description |
|---|---|
| `legacy_ref` | Numéro ou code utilisé par `/runbook`, `/script`, `/checklist`, `/ref`. |
| `legacy_command` | Commande ou mot-clé saisi par le technicien. |
| `legacy_alias_or_content` | Alias, description ou contenu du menu. |
| `legacy_path` | Ancien chemin GitHub exact utilisé par le menu contextuel. |
| `legacy_directory` | Ancien dossier parent. |
| `legacy_filename` | Ancien nom de fichier ou cible. |
| `item_type` | Type détecté : runbook, bundle, template, script, checklist, reference. |
| `new_path_target` | Nouveau chemin à inscrire quand la migration sera décidée. |
| `migration_status` | LEGACY_ACTIVE, MIGRATED, REDIRECT, ARCHIVED, BROKEN. |
| `action_required` | Action de maintenance requise. |

## BUNDLE

| Ref | Commande | Ancien nom | Ancien emplacement | Statut |
|---|---|---|---|---|
| `B01` | `b-infra` | `BUNDLE_RUNBOOKS_IT_INFRA.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B02` | `b-cloud` | `BUNDLE_RUNBOOKS_IT_CLOUD.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B03` | `b-reseau-voip` | `BUNDLE_RUNBOOKS_IT_RESEAU_VOIP.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B04` | `b-virtualiz` | `BUNDLE_INFRA_VIRTUALISATION.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B05` | `b-ad` | `BUNDLE_RUNBOOK_INFRA_AD-Operations_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B06` | `b-hyperv` | `BUNDLE_RUNBOOK_INFRA_Hyperviseurs_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B07` | `b-m365` | `BUNDLE_RUNBOOK_INFRA_M365_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B08` | `b-rds` | `BUNDLE_RUNBOOK_INFRA_RDS-Operations_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B09` | `b-fw-vpn` | `BUNDLE_RUNBOOK_INFRA_Firewall-VPN_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `03` | `srv` | `BUNDLE_INFRA_SERVER.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `10` | `fw` | `BUNDLE_INFRA_FIREWALL.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `11` | `dns` | `BUNDLE_INFRA_DNS_Domains_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `12` | `linux` | `BUNDLE_INFRA_LINUX_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `14` | `m365` | `BUNDLE_INFRA_365.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `19b` | `aws` | `BUNDLE_INFRA_CLOUD_AWS_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `19c` | `gcp` | `BUNDLE_INFRA_CLOUD_GCP_GoogleWorkspace_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B20` | `b-patching` | `BUNDLE_RUNBOOK_MAINTENANCE_Patching-Windows_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B21` | `b-health` | `BUNDLE_RUNBOOK_MAINTENANCE_Server-Health_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B30` | `b-noc` | `BUNDLE_RUNBOOKS_IT_NOC_URGENCE.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B31` | `b-backup-dr` | `BUNDLE_RUNBOOKS_IT_BACKUP_DR.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B32` | `b-veeam` | `BUNDLE_RUNBOOK_BACKUP_Veeam-Operations_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B33` | `b-datto-keepit` | `BUNDLE_RUNBOOK_BACKUP_Datto-Keepit-DR_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B34` | `b-rmm` | `BUNDLE_RUNBOOK_NOC_RMM-Monitoring_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B35` | `b-noc-int` | `BUNDLE_NOC_Intervention_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `32` | `veeam` | `BUNDLE_RUNBOOK_BACKUP_Veeam-Operations_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `39` | `bckup` | `BUNDLE_RUNBOOK_BACKUP_Datto-Keepit-DR_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B40` | `b-secu` | `BUNDLE_RUNBOOKS_IT_SECURITE.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B41` | `b-ir` | `BUNDLE_RUNBOOK_SECURITY_Incident-Response_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B42` | `b-soc-siem` | `BUNDLE_SECURITY_Securite_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `42` | `ransomware` | `BUNDLE_NOC_SOC_SIEM_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B50` | `b-support` | `BUNDLE_RUNBOOKS_IT_SUPPORT.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B51` | `b-n1` | `BUNDLE_SUPPORT_N1_UserSupport_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B52` | `b-live` | `BUNDLE_RUNBOOK_SUPPORT_Intervention-Live_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `B53` | `b-triage-kb` | `BUNDLE_RUNBOOK_SUPPORT_Triage-KB_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `53` | `imprimante` | `BUNDLE_SUPPORT_Print_Diag_V1.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |
| `58` | `srv-ad` | `BUNDLE_SUPPORT_SERVER-AD.md` | `IT-SHARED/60_BUNDLES` | `LEGACY_ACTIVE` |

## RUNBOOK

| Ref | Commande | Ancien nom | Ancien emplacement | Statut |
|---|---|---|---|---|
| `01` | `dc` | `INFRA__RUNBOOK__DC_PrePost_Validation` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `02` | `sql` | `INFRA-SRV-SQL_PrePost_Validation_V2.md` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `04` | `rds` | `INFRA-SRV-RDS_Operations_V2.md` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `05` | `ad-dc` | `INFRA-AD-DC_Operations_V3.md` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `06` | `ad-user` | `INFRA-AD-UserManagement_V2.md` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `07` | `hyperv` | `INFRA-SRV-HyperV_Operations_V2.md` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `08` | `vmware` | `INFRA-SRV-VMware_Operations_V2.md` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `09` | `xcpng` | `INFRA-SRV-XCPng_Operations_V1.md` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `10b` | `net-cfg` | `INFRA-NET-NetworkSetup_V1.md` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `10c` | `net-diag` | `INFRA-NET-NetworkDiagnostic_V2.md` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `13` | `azure` | `INFRA-AD-EntraID_Operations_V2.md` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `15` | `m365-exchange` | `INFRA-M365-Exchange_Online_V2.md` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `16` | `m365-intune` | `INFRA-M365-Intune_Devices_V2.md` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `17` | `m365-teams` | `INFRA-M365-Teams_SharePoint_OneDrive_V2.md` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `18` | `m365-user` | `INFRA-M365-UserManagement_V2.md` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `19` | `m365-onboard` | `INFRA-M365-UserOnboarding_V2.md` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `20` | `windows-patching` | `MAINT-WIN-Patching_Complet_V3.md` | `IT-SHARED/10_RUNBOOKS/MAINTENANCE` | `LEGACY_ACTIVE` |
| `21` | `patching-cwrmm` | `MAINT-WIN-Patching_CW-RMM_V3.md` | `IT-SHARED/10_RUNBOOKS/MAINTENANCE` | `LEGACY_ACTIVE` |
| `22` | `pending-reboot` | `MAINT-WIN-PendingReboot_V2.md` | `IT-SHARED/10_RUNBOOKS/MAINTENANCE` | `LEGACY_ACTIVE` |
| `23` | `server-health` | `MAINT-SRV-HealthCheck_V2.md` | `IT-SHARED/10_RUNBOOKS/MAINTENANCE` | `LEGACY_ACTIVE` |
| `24` | `wsus` | `MAINT-WIN-WSUS_Maintenance_V2.md` | `IT-SHARED/10_RUNBOOKS/MAINTENANCE` | `LEGACY_ACTIVE` |
| `25` | `audit-trim` | `MAINT-SRV-AuditTrimestriel_V2.md` | `IT-SHARED/10_RUNBOOKS/MAINTENANCE` | `LEGACY_ACTIVE` |
| `26` | `post-panne` | `MAINT-SRV-PostShutdown_Electrical_V2.md` | `IT-SHARED/10_RUNBOOKS/MAINTENANCE` | `LEGACY_ACTIVE` |
| `27` | `print` | `MAINT-SRV-PrintServer_PrePost_V1.md` | `IT-SHARED/10_RUNBOOKS/MAINTENANCE` | `LEGACY_ACTIVE` |
| `28` | `asset` | `INFRA-OPS-AssetLifecycle_V1.md` | `IT-SHARED/10_RUNBOOKS/INFRA` | `LEGACY_ACTIVE` |
| `28a` | `audit-license` | `SEC-OPS-LicenseAudit_V2.md` | `IT-SHARED/10_RUNBOOKS/SECURITY` | `LEGACY_ACTIVE` |
| `28b` | `audit-cmdb` | `MAINT-OPS-CMDB_AssetAudit_V1.md` | `IT-SHARED/10_RUNBOOKS/MAINTENANCE` | `LEGACY_ACTIVE` |
| `28c` | `audit_trimestriel` | `MAINT-SRV-AuditTrimestriel_V2.md` | `IT-SHARED/10_RUNBOOKS/MAINTENANCE` | `LEGACY_ACTIVE` |
| `30` | `incident-command` | `NOC-OPS-IncidentCommand_V2.md` | `IT-SHARED/10_RUNBOOKS/NOC` | `LEGACY_ACTIVE` |
| `31` | `frontdoor` | `NOC-OPS-FrontDoor_V2.md` | `IT-SHARED/10_RUNBOOKS/NOC` | `LEGACY_ACTIVE` |
| `32c` | `veeam-opr` | `NOC-BACKUP-Veeam_Operations_V2.md` | `IT-SHARED/10_RUNBOOKS/NOC` | `LEGACY_ACTIVE` |
| `32b` | `bckup-cfg` | `NOC-BACKUP-Backup_Configuration_V2.md` | `IT-SHARED/10_RUNBOOKS/NOC` | `LEGACY_ACTIVE` |
| `33` | `datto` | `NOC-BACKUP-Datto_Operations_V2.md` | `IT-SHARED/10_RUNBOOKS/NOC` | `LEGACY_ACTIVE` |
| `34` | `keepit` | `NOC-BACKUP-Keepit_Operations_V2.md` | `IT-SHARED/10_RUNBOOKS/NOC` | `LEGACY_ACTIVE` |
| `35` | `dr-plan` | `NOC-BACKUP-DR_Plan_Validation_V2.md` | `IT-SHARED/10_RUNBOOKS/NOC` | `LEGACY_ACTIVE` |
| `36` | `backup-dr` | `NOC-BACKUP-DR_Test_V2.md` | `IT-SHARED/10_RUNBOOKS/NOC` | `LEGACY_ACTIVE` |
| `37` | `nable` | `NOC-RMM-NAble_Operations_V2.md` | `IT-SHARED/10_RUNBOOKS/NOC` | `LEGACY_ACTIVE` |
| `38` | `cwrmm-auvik` | `NOC-RMM-CWRMM_Auvik_Operations_V2.md` | `IT-SHARED/10_RUNBOOKS/NOC` | `LEGACY_ACTIVE` |
| `40` | `securite-ir` | `SEC-SECU-IncidentResponse_V3.md` | `IT-SHARED/10_RUNBOOKS/SECURITY` | `LEGACY_ACTIVE` |
| `41` | `alert-response` | `SEC-SECU-AlertResponse_V2.md` | `IT-SHARED/10_RUNBOOKS/SECURITY` | `LEGACY_ACTIVE` |
| `43` | `security-audit` | `SEC-SECU-SecurityAudit_V2.md` | `IT-SHARED/10_RUNBOOKS/SECURITY` | `LEGACY_ACTIVE` |
| `44` | `m365-compliance` | `SEC-M365-Compliance_Purview_V2.md` | `IT-SHARED/10_RUNBOOKS/SECURITY` | `LEGACY_ACTIVE` |
| `50` | `triage-support` | `SUP-N1N2-SupportTriage_V2.md` | `IT-SHARED/10_RUNBOOKS/SUPPORT` | `LEGACY_ACTIVE` |
| `51` | `support-n2` | `SUP-N2-Support_V2.md` | `IT-SHARED/10_RUNBOOKS/SUPPORT` | `LEGACY_ACTIVE` |
| `55` | `vpn` | `SUP-NET-VPN_Troubleshooting_V2.md` | `IT-SHARED/10_RUNBOOKS/SUPPORT` | `LEGACY_ACTIVE` |
| `59` | `onedrive-sync` | `SUP-M365-OneDrive_SharePoint_Sync_V2.md` | `IT-SHARED/10_RUNBOOKS/SUPPORT` | `LEGACY_ACTIVE` |
| `60` | `intervention` | `SUP-OPS-CW_InterventionLive_Close_V2.md` | `IT-SHARED/10_RUNBOOKS/SUPPORT` | `LEGACY_ACTIVE` |
| `61` | `close-cw` | `SUP-OPS-CW_InterventionLive_Close_V2.md` | `IT-SHARED/10_RUNBOOKS/SUPPORT` | `LEGACY_ACTIVE` |
| `62` | `dispatch` | `SUP-OPS-CW_Dispatch_V2.md` | `IT-SHARED/10_RUNBOOKS/SUPPORT` | `LEGACY_ACTIVE` |
| `62b` | `ticket-to-kb` | `SUP-OPS-TicketToKB_V2.md` | `IT-SHARED/10_RUNBOOKS/SUPPORT` | `LEGACY_ACTIVE` |

## TEMPLATE

| Ref | Commande | Ancien nom | Ancien emplacement | Statut |
|---|---|---|---|---|
| `80` | `tpl-cw` | `TEMPLATE_BUNDLE_CW_CLOSE.md` | `IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW` | `LEGACY_ACTIVE` |
| `81` | `tpl-note` | `TEMPLATE__CW_NOTE_INTERNE.md` | `IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW` | `LEGACY_ACTIVE` |
| `82` | `tpl-discussion` | `TEMPLATE__CW_DISCUSSION.md` | `IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW` | `LEGACY_ACTIVE` |
| `83` | `tpl-email` | `TEMPLATE__EMAIL_CLIENT.md` | `IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW` | `LEGACY_ACTIVE` |
| `84` | `tpl-teams` | `TEMPLATE_COM_Teams-Incident-Actif_V1.md` | `IT-SHARED/20_TEMPLATES/02_TEMPLATE_COM` | `LEGACY_ACTIVE` |
| `85` | `tpl-flagup` | `TEMPLATE__FLAG_UP_AVERTISSEMENT.md` | `IT-SHARED/20_TEMPLATES/02_TEMPLATE_COM` | `LEGACY_ACTIVE` |
| `86` | `tpl-postmortem` | `TEMPLATE_REPORT_Postmortem_V2.md` | `IT-SHARED/20_TEMPLATES/08_TEMPLATE_REPORTS` | `LEGACY_ACTIVE` |
| `87` | `tpl-qbr` | `TEMPLATE_REPORT_QBR_V1.md` | `IT-SHARED/20_TEMPLATES/08_TEMPLATE_REPORTS` | `LEGACY_ACTIVE` |
| `88` | `tpl-mensuel` | `TEMPLATE_REPORT_Mensuel_V1.md` | `IT-SHARED/20_TEMPLATES/08_TEMPLATE_REPORTS` | `LEGACY_ACTIVE` |
| `89` | `tpl-hudu` | `TEMPLATE__EDOCS_FICHE_OBJET_IT.md` | `IT-SHARED/20_TEMPLATES/09_TEMPLATE_HUDU` | `LEGACY_ACTIVE` |
| `89b` | `tpl-kb` | `TEMPLATE_KNOWLEDGE_KB-Article-et-Procedure_V1.md` | `IT-SHARED/20_TEMPLATES/05_TEMPLATE_KNOWLEDGE` | `LEGACY_ACTIVE` |
| `89c` | `tpl-incident` | `TEMPLATE__INCIDENT_CRITIQUE.md` | `IT-SHARED/20_TEMPLATES/06_TEMPLATE _INCIDENT` | `LEGACY_ACTIVE` |
| `89d` | `tpl-dr-test` | `TEMPLATE_BACKUP_DR-Test-et-Restore_V1.md` | `IT-SHARED/20_TEMPLATES/07_TEMPLATE_BACKUP` | `LEGACY_ACTIVE` |
| `89e` | `tpl-post-panne` | `TEMPLATE_DIAG_PostPanneHQ.md` | `IT-SHARED/20_TEMPLATES/12_TEMPLATE_DIAG` | `LEGACY_ACTIVE` |
| `89f` | `tpl-naming` | `NAMING_STANDARDS_v1.md` | `IT-SHARED/20_TEMPLATES/13_NAMING_STANDARDS` | `LEGACY_ACTIVE` |

## Workflow de migration recommandé

1. Choisir le fichier canonique dans `RUNBOOK_CATALOG_GUIDEDOPS.md`.
2. Inscrire le nouveau chemin dans `new_path_target`.
3. Mettre `migration_status = MIGRATED` seulement quand le fichier existe au nouvel emplacement.
4. Mettre à jour `RUNBOOK_MENU_CONTEXTUEL_V4.md` ou créer `RUNBOOK_MENU_CONTEXTUEL_V5.md`.
5. Mettre à jour les prompts agents qui référencent le menu contextuel.
6. Conserver une période de compatibilité avec alias ou redirects si possible.

## Statuts de migration

| Statut | Sens |
|---|---|
| `LEGACY_ACTIVE` | Ancien chemin encore utilisé par les prompts/menus. |
| `MIGRATED` | Nouveau chemin officiel appliqué et validé. |
| `REDIRECT` | Ancien chemin maintenu comme pointeur/alias temporaire. |
| `ARCHIVED` | Ancien fichier retiré du flux actif, conservé en archive. |
| `BROKEN` | Référence cassée; correction requise. |