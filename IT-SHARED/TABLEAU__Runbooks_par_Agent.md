# TABLEAU — Runbooks par Agent IT MSP
**Version :** 1.0 | **Date :** 2026-03-20
**Total nouveaux runbooks :** 27

---

## LÉGENDE

| Symbole | Signification |
|---|---|
| 🔵 PRIMARY | Agent principal qui utilise ce runbook |
| 🟢 SECONDARY | Agent qui consulte ce runbook occasionnellement |

---

## INFRA/ — 19 runbooks

| Runbook | IT-AssistanTI_N2 | IT-AssistanTI_N3 | IT-MaintenanceMaster | IT-BackupDRMaster | IT-NetworkMaster | IT-CloudMaster | IT-MonitoringMaster | IT-AssetMaster | IT-SecurityMaster |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `RUNBOOK__AD_User_Management_V1` | 🔵 | 🔵 | — | — | — | — | — | — | — |
| `RUNBOOK__AD_DC_Operations_V1` | — | 🔵 | 🔵 | — | — | — | — | — | — |
| `RUNBOOK__RDS_Operations_V1` | — | 🔵 | 🔵 | — | — | — | — | — | — |
| `RUNBOOK__HyperV_Operations_V1` | — | 🔵 | 🔵 | 🟢 | — | — | — | — | — |
| `RUNBOOK__VMware_vSphere_Operations_V1` | — | 🔵 | 🔵 | 🟢 | — | — | — | — | — |
| `RUNBOOK__Vates_XCPng_Operations_V1` | — | 🔵 | 🔵 | 🟢 | — | — | — | — | — |
| `RUNBOOK__WatchGuard_Operations_V1` | — | 🟢 | — | — | 🔵 | — | — | — | — |
| `RUNBOOK__Fortinet_Operations_V1` | — | 🟢 | — | — | 🔵 | — | — | — | — |
| `RUNBOOK__SonicWall_Operations_V1` | — | 🟢 | — | — | 🔵 | — | — | — | — |
| `RUNBOOK__Meraki_Operations_V1` | — | 🟢 | — | — | 🔵 | — | — | — | — |
| `RUNBOOK__Unifi_Mikrotik_Operations_V1` | — | 🟢 | — | — | 🔵 | — | — | — | — |
| `RUNBOOK__M365_Exchange_Online_V1` | 🔵 | 🔵 | — | — | — | 🟢 | — | — | 🟢 |
| `RUNBOOK__EntraID_Operations_V1` | — | 🔵 | — | — | — | 🔵 | — | — | 🟢 |
| `RUNBOOK__M365_Teams_SharePoint_OneDrive_V1` | 🔵 | 🔵 | — | — | — | 🟢 | — | — | — |
| `RUNBOOK__M365_Intune_Devices_V1` | — | 🔵 | — | — | — | 🔵 | — | — | — |
| `RUNBOOK__M365_Compliance_Purview_V1` | — | — | — | — | — | 🔵 | — | — | 🔵 |
| `RUNBOOK__Datto_Operations_V1` | — | 🟢 | 🟢 | 🔵 | — | — | 🟢 | — | — |
| `RUNBOOK__Keepit_Operations_V1` | — | — | — | 🔵 | — | 🟢 | — | — | — |
| `RUNBOOK__Veeam_Cloud_Operations_V1` | — | 🟢 | 🟢 | 🔵 | — | — | — | — | — |
| `RUNBOOK__DR_Plan_Validation_V1` | — | — | 🔵 | 🔵 | 🟢 | 🟢 | — | — | — |

---

## MAINTENANCE/ — 3 runbooks

| Runbook | IT-AssistanTI_N2 | IT-AssistanTI_N3 | IT-MaintenanceMaster | IT-BackupDRMaster | IT-AssetMaster |
|---|:---:|:---:|:---:|:---:|:---:|
| `RUNBOOK__Server_Health_Check_V1` | — | 🟢 | 🔵 | — | — |
| `RUNBOOK__WSUS_Maintenance_V1` | — | 🟢 | 🔵 | — | — |
| `RUNBOOK__CMDB_Asset_Audit_V1` | — | — | 🟢 | — | 🔵 |

---

## NOC/ — 2 runbooks

| Runbook | IT-NOCDispatcher | IT-MonitoringMaster | IT-AssistanTI_N3 | IT-BackupDRMaster |
|---|:---:|:---:|:---:|:---:|
| `RUNBOOK__NAble_RMM_Operations_V1` | 🟢 | 🔵 | 🟢 | — |
| `RUNBOOK__CWRMM_Auvik_Operations_V1` | 🔵 | 🔵 | 🟢 | — |

---

## SECURITY/ — 1 runbook

| Runbook | IT-SecurityMaster | IT-CloudMaster | IT-AssistanTI_N3 |
|---|:---:|:---:|:---:|
| `RUNBOOK__M365_Compliance_Purview_V1` | 🔵 | 🔵 | 🟢 |

---

## SUPPORT/ — 2 runbooks

| Runbook | IT-AssistanTI_N2 | IT-AssistanTI_N3 | IT-NetworkMaster |
|---|:---:|:---:|:---:|
| `RUNBOOK__VPN_Client_Troubleshooting_V1` | 🔵 | 🔵 | 🟢 |
| `RUNBOOK__OneDrive_SharePoint_Sync_V1` | 🔵 | 🔵 | — |

---

## RÉSUMÉ PAR AGENT

| Agent | Runbooks PRIMARY | Runbooks SECONDARY |
|---|:---:|:---:|
| **IT-AssistanTI_N2** | 6 | 4 |
| **IT-AssistanTI_N3** | 9 | 11 |
| **IT-MaintenanceMaster** | 9 | 3 |
| **IT-BackupDRMaster** | 5 | 4 |
| **IT-NetworkMaster** | 5 | 2 |
| **IT-CloudMaster** | 4 | 4 |
| **IT-MonitoringMaster** | 2 | 1 |
| **IT-AssetMaster** | 1 | 0 |
| **IT-SecurityMaster** | 2 | 3 |
| **IT-NOCDispatcher** | 1 | 1 |

---

## EMPLACEMENT DANS LE PROJET

```
IT/IT-SHARED/10_RUNBOOKS/
├── INFRA/          ← 19 runbooks (INFRA, hyperviseurs, firewalls, M365, backup cloud)
├── MAINTENANCE/    ← 3 runbooks (health check, WSUS, CMDB)
├── NOC/            ← 2 runbooks (N-able, CW RMM + Auvik)
├── SECURITY/       ← 1 runbook (M365 Compliance/Purview)
└── SUPPORT/        ← 2 runbooks (VPN client, OneDrive/SharePoint sync)
```

---

## RUNBOOKS EXISTANTS CONSERVÉS (RÉFÉRENCE)

Ces runbooks existaient déjà et ont été vérifiés/corrigés dans les sessions précédentes :

**SUPPORT/ :** RUNBOOK__IT_CW_INTERVENTION_LIVE_CLOSE, IT_INTERVENTION_LIVE, IT_MSP_CONNECTWISE_DISPATCH_V1, IT_MSP_TICKET_TO_KB, IT_SUPPORT_TRIAGE_N1N2N3_V1, Patching_Process

**MAINTENANCE/ :** Windows_Patching, Windows_Patching_CW_RMM_OneByOne, PendingReboot_OneByOne, Post_Shutdown_Electrical_Validation, PrintServer_PrePost_Validation, SQL_PrePost_Validation

**INFRA/ :** DC_PrePost_Validation, Backup_Configuration, Network_Setup, M365_User_Management, M365_User_Onboarding, IT_VOIP_DIAGNOSTIC_V1, Quick_Start, RUNBOOK__IT_VEEAM_OPERATIONS_V1 (créé session précédente)

**NOC/ :** IT_COMMANDARE_NOC, IT_NOC_DISPATCH, IT_NOC_FRONTDOOR_v2, NOC_Procedures, IT_NOC_COMMAND_CENTER

**SECURITY/ :** IT_SECURITY_INCIDENT_RESPONSE, Security_Audit, Alert_Response
