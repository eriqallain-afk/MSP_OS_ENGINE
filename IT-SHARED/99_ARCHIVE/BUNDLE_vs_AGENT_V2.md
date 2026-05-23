# BUNDLE_vs_AGENT — IT MSP Intelligence Platform
# Version 2.0 | 2026-04-13
# Source de vérité pour l'assignation des Bundles Knowledge aux agents GPT.
# Tous les fichiers sont dans IT-SHARED/60_BUNDLES/ sauf indication contraire.
# STRATÉGIE : Bundles en Knowledge (statique) — Runbooks via GitHub (temps réel).

---

## BUNDLES RUNBOOKS THÉMATIQUES
# Gros fichiers consolidés — via GitHub Action (modification = propagation auto à tous)

| Bundle | Taille | Agents PRIMARY | Agents SECONDARY |
|---|---|---|---|
| `BUNDLE_RUNBOOKS_IT_INFRA.md` | 33KB | IT-MaintenanceMaster, IT-AssistanTI_N3, IT-Commandare-Infra | IT-SysAdmin, IT-UrgenceMaster |
| `BUNDLE_RUNBOOKS_IT_NOC_URGENCE.md` | 19KB | IT-UrgenceMaster, IT-Commandare-NOC, IT-NOCDispatcher | IT-BackupDRMaster |
| `BUNDLE_RUNBOOKS_IT_BACKUP_DR.md` | 8.5KB | IT-BackupDRMaster, IT-UrgenceMaster | IT-Commandare-Infra |
| `BUNDLE_RUNBOOKS_IT_SUPPORT.md` | 40KB | IT-AssistanTI_N2, IT-AssistanTI_FrontLine, IT-AssistanTI_N3 | IT-NOCDispatcher, IT-TicketScribe |
| `BUNDLE_RUNBOOKS_IT_RESEAU_VOIP.md` | 16KB | IT-NetworkMaster, IT-VoIPMaster | IT-UrgenceMaster |
| `BUNDLE_RUNBOOKS_IT_SECURITE.md` | 24KB | IT-SecurityMaster, IT-Commandare-TECH | IT-NOCDispatcher |
| `BUNDLE_RUNBOOKS_IT_CLOUD.md` | 17KB | IT-CloudMaster, IT-Commandare-Infra | IT-AssetMaster |

## BUNDLES RUNBOOKS DÉTAILLÉS (par domaine)
# Recommandés pour agents spécialisés — via GitHub Action

| Bundle | Taille | Agents PRIMARY |
|---|---|---|
| `BUNDLE_RUNBOOK_INFRA_AD-Operations_V1.md` | 17KB | IT-MaintenanceMaster, IT-AssistanTI_N3 |
| `BUNDLE_RUNBOOK_INFRA_Hyperviseurs_V1.md` | 25KB | IT-MaintenanceMaster, IT-AssistanTI_N3 |
| `BUNDLE_RUNBOOK_INFRA_M365_V1.md` | 50KB | IT-CloudMaster, IT-AssistanTI_N3 |
| `BUNDLE_RUNBOOK_INFRA_RDS-Operations_V1.md` | 16KB | IT-MaintenanceMaster, IT-AssistanTI_N3 |
| `BUNDLE_RUNBOOK_INFRA_Firewall-VPN_V1.md` | 36KB | IT-NetworkMaster |
| `BUNDLE_RUNBOOK_BACKUP_Veeam-Operations_V1.md` | 22KB | IT-BackupDRMaster |
| `BUNDLE_RUNBOOK_BACKUP_Datto-Keepit-DR_V1.md` | 23KB | IT-BackupDRMaster |
| `BUNDLE_RUNBOOK_MAINTENANCE_Patching-Windows_V1.md` | 29KB | IT-MaintenanceMaster, IT-SysAdmin |
| `BUNDLE_RUNBOOK_MAINTENANCE_Server-Health_V1.md` | 10KB | IT-MaintenanceMaster, IT-SysAdmin |
| `BUNDLE_RUNBOOK_NOC_RMM-Monitoring_V1.md` | 22KB | IT-MonitoringMaster, IT-NOCDispatcher |
| `BUNDLE_RUNBOOK_SECURITY_Incident-Response_V1.md` | 35KB | IT-SecurityMaster |
| `BUNDLE_RUNBOOK_SUPPORT_Intervention-Live_V1.md` | 62KB | IT-AssistanTI_N2, IT-TicketScribe, IT-Commandare-OPR |
| `BUNDLE_RUNBOOK_SUPPORT_Triage-KB_V1.md` | 20KB | IT-AssistanTI_N2, IT-AssistanTI_FrontLine |

---

## BUNDLES INFRA (thématiques)
# Recommandés en Knowledge pour agents à large périmètre (SysAdmin, N3)

| Bundle | Taille | Agents PRIMARY |
|---|---|---|
| `BUNDLE_INFRA_SERVER.md` | 31KB | IT-SysAdmin, IT-MaintenanceMaster, IT-AssistanTI_N3 |
| `BUNDLE_INFRA_FIREWALL.md` | 27KB | IT-NetworkMaster |
| `BUNDLE_INFRA_365.md` | 25KB | IT-CloudMaster, IT-AssistanTI_N3 |
| `BUNDLE_INFRA_VIRTUALISATION.md` | 19KB | IT-MaintenanceMaster, IT-AssistanTI_N3 |
| `BUNDLE_INFRA_DNS_Domains_V1.md` | 6.5KB | IT-NetworkMaster, IT-CloudMaster |
| `BUNDLE_INFRA_LINUX_V1.md` | 3.8KB | IT-SysAdmin, IT-AssistanTI_N3 |
| `BUNDLE_INFRA_CLOUD_AWS_V1.md` | 4.4KB | IT-CloudMaster |
| `BUNDLE_INFRA_CLOUD_GCP_GoogleWorkspace_V1.md` | 3.8KB | IT-CloudMaster |

---

## BUNDLES SUPPORT N1/N2

| Bundle | Taille | Agents PRIMARY |
|---|---|---|
| `BUNDLE_SUPPORT_N1_UserSupport_V1.md` | 9KB | IT-AssistanTI_N2, IT-AssistanTI_FrontLine |
| `BUNDLE_SUPPORT_Print_Diag_V1.md` | 5KB | IT-AssistanTI_N2, IT-AssistanTI_FrontLine |
| `BUNDLE_SUPPORT_SERVER-AD.md` | 31KB | IT-AssistanTI_N2, IT-AssistanTI_N3 |
| `BUNDLE_NOC_SOC_SIEM_V1.md` | 10KB | IT-SecurityMaster, IT-Commandare-TECH |
| `BUNDLE_NOC_Intervention_V1.md` | 4.4KB | IT-Commandare-NOC, IT-NOCDispatcher |

---

## BUNDLES KNOWLEDGE PACK (KP) — par agent
# Toujours en Knowledge — spécifiques à l'agent, petits, stables

| Bundle | Taille | Agent exclusif |
|---|---|---|
| `BUNDLE_KP_SysAdmin_V1.md` | 6.3KB | IT-SysAdmin |
| `BUNDLE_KP_MaintenanceMaster_V1.md` | 6.4KB | IT-MaintenanceMaster |
| `BUNDLE_KP_AssistanTI-N2_V1.md` | 12KB | IT-Assistant-N2 |
| `BUNDLE_KP_AssistanTI-N3_V1.md` | 8KB | IT-Assistant-N3 |
| `BUNDLE_KP_AssistanTI-FrontLine_V1.md` | 12KB | IT-FrontLine |
| `BUNDLE_KP_BackupDRMaster_V1.md` | 5.7KB | IT-BackupDRMaster |
| `BUNDLE_KP_CloudMaster_V1.md` | 2.2KB | IT-CloudMaster |
| `BUNDLE_KP_NetworkMaster_V1.md` | 6KB | IT-NetworkMaster |
| `BUNDLE_KP_SecurityMaster_V1.md` | 6KB | IT-SecurityMaster |
| `BUNDLE_KP_Commandare-Infra_V1.md` | 6.9KB | IT-Commandare-Infra |
| `BUNDLE_KP_Commandare-NOC_V1.md` | 8.4KB | IT-Commandare-NOC |
| `BUNDLE_KP_Commandare-OPR_V1.md` | 7.4KB | IT-Commandare-OPR |
| `BUNDLE_KP_Commandare-TECH_V1.md` | 6.8KB | IT-Commandare-TECH |
| `BUNDLE_KP_UrgenceMaster_V1.md` | 9.4KB | IT-UrgenceMaster |
| `BUNDLE_KP_MonitoringMaster_V1.md` | 2.1KB | IT-MonitoringMaster |
| `BUNDLE_KP_NOCDispatcher_V1.md` | 1.7KB | IT-NOCDispatcher |
| `BUNDLE_KP_ReportMaster_V1.md` | 1.4KB | IT-ReportMaster |
| `BUNDLE_KP_ScriptMaster_V1.md` | 2KB | IT-ScriptMaster |
| `BUNDLE_KP_TicketScribe_V1.md` | 1.5KB | IT-TicketScribe |
| `BUNDLE_KP_KnowledgeKeeper_V1.md` | 1.4KB | IT-KnowledgeKeeper |
| `BUNDLE_KP_AssetMaster_V1.md` | 1.8KB | IT-AssetMaster |
| `BUNDLE_KP_VoIPMaster_V1.md` | 2KB | IT-VoIPMaster |

---

## BUNDLES MASTER / GOUVERNANCE

| Bundle | Taille | Usage |
|---|---|---|
| `BUNDLE_MASTER_Core-MSP_V1.md` | 4.5KB | Standards MSP — tous agents |
| `BUNDLE_MASTER_Gouvernance_V1.md` | 4.9KB | Gouvernance — agents senior |

*BUNDLE_vs_AGENT V2 — IT MSP Intelligence Platform — 2026-04-13*
