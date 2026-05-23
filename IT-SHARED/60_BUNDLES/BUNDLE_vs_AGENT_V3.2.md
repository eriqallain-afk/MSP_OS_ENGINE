# BUNDLE_vs_AGENT — Par Agent
# Version 3.0 | 2026-04-13
# Organisation : Agent → fichiers Knowledge (upload GPT Editor) + runbooks GitHub Action
# Tous les bundles sont dans IT-SHARED/60_BUNDLES/ sauf indication contraire.
# Repo GitHub : eriqallain-afk/IT
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

---

## RÈGLE D'ASSIGNATION

| Type | Où | Mise à jour |
|---|---|---|
| `prompt.md` | Knowledge GPT Editor (tous) — **position 1** | Manuel |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | Knowledge GPT Editor (tous) — **position 2** | Manuel si menu change |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | Knowledge GPT Editor (tous) — **position 3** | Manuel si templates changent |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | Knowledge GPT Editor (tous) — **position 4** | Manuel si règles changent |
| `BUNDLE_KP_[Agent]` | Knowledge GPT Editor — **position 5** | Manuel — re-upload si modifié |
| Bundles thématiques | Knowledge GPT Editor OU GitHub Action | GitHub = auto-propagation |
| Runbooks individuels | GitHub Action (`getFileContent`) | Auto — modifie le repo, tous à jour |

---

## @IT-SysAdmin

### Knowledge (uploader dans GPT Editor)
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_SysAdmin_V1.md` | 🟠 Important | 6.3KB |
| `BUNDLE_RUNBOOK_MAINTENANCE_Patching-Windows_V1.md` | 🟠 Important | 30KB |
| `BUNDLE_RUNBOOK_MAINTENANCE_Server-Health_V1.md` | 🟠 Important | 10KB |
| `BUNDLE_RUNBOOK_INFRA_AD-Operations_V1.md` | 🟠 Important | 17KB |
| `BUNDLE_INFRA_SERVER.md` | 🔵 Optionnel | 31KB |

### GitHub Action — Runbooks clés
`[01]dc [02]sql [03]srv [05]ad-dc [06]ad-user [07]hyperv [08]vmware [09]xcpng [20]patching [22]pending-reboot [23]server-health [24]wsus [25]audit-trim [26]post-panne`

---

## @IT-MaintenanceMaster

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_MaintenanceMaster_V1.md` | 🟠 Important | 6.4KB |
| `BUNDLE_RUNBOOK_MAINTENANCE_Patching-Windows_V1.md` | 🟠 Important | 30KB |
| `BUNDLE_RUNBOOK_MAINTENANCE_Server-Health_V1.md` | 🟠 Important | 10KB |

### GitHub Action — Runbooks clés
`[20]patching [21]patching-cwrmm [22]pending-reboot [23]server-health [24]wsus [25]audit-trim [01]dc [02]sql [26]post-panne [27]print`

---

## @IT-Assistant-N2

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_AssistanTI-N2_V1.md` | 🟠 Important | 12KB |
| `BUNDLE_RUNBOOKS_IT_SUPPORT.md` | 🟠 Important | 40KB |
| `BUNDLE_SUPPORT_N1_UserSupport_V1.md` | 🔵 Optionnel | 9KB |

### GitHub Action — Runbooks clés
`[51]support-n2 [53]imprimante [55]vpn [50]triage [62]dispatch [60]intervention [61]close-cw [18]m365-user [19]m365-onboarding`

---

## @IT-Assistant-N3

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_AssistanTI-N3_V1.md` | 🟠 Important | 8KB |
| `BUNDLE_RUNBOOK_INFRA_AD-Operations_V1.md` | 🟠 Important | 17KB |
| `BUNDLE_RUNBOOK_INFRA_Hyperviseurs_V1.md` | 🟠 Important | 25KB |
| `BUNDLE_RUNBOOK_INFRA_M365_V1.md` | 🟠 Important | 50KB |
| `BUNDLE_RUNBOOK_INFRA_RDS-Operations_V1.md` | 🔵 Optionnel | 16KB |

### GitHub Action — Runbooks clés
`[01]dc [02]sql [04]rds [05]ad-dc [06]ad-user [07]hyperv [08]vmware [09]xcpng [13]azure [15]m365-exchange [16]m365-intune [17]m365-teams [40]securite-ir`

---

## @IT-FrontLine

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_AssistanTI-FrontLine_V1.md` | 🟠 Important | 12KB |
| `BUNDLE_RUNBOOK_SUPPORT_Triage-KB_V1.md` | 🟠 Important | 20KB |

### GitHub Action — Runbooks clés
`[51]support-n2 [53]imprimante [55]vpn [50]triage [62]dispatch [60]intervention [61]close-cw [74]kickoff`

---

## @IT-BackupDRMaster

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_BackupDRMaster_V1.md` | 🟠 Important | 5.7KB |
| `BUNDLE_RUNBOOK_BACKUP_Veeam-Operations_V1.md` | 🟠 Important | 22KB |
| `BUNDLE_RUNBOOK_BACKUP_Datto-Keepit-DR_V1.md` | 🟠 Important | 23KB |

### GitHub Action — Runbooks clés
`[32]veeam [33]datto [34]keepit [35]dr-plan [36]backup-dr [30]incident-command [67d]veeam-jobs [73]dr [89d]tpl-dr-test`

---

## @IT-SecurityMaster

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_SecurityMaster_V1.md` | 🟠 Important | 6KB |
| `BUNDLE_RUNBOOK_SECURITY_Incident-Response_V1.md` | 🟠 Important | 35KB |
| `BUNDLE_NOC_SOC_SIEM_V1.md` | 🟠 Important | 10KB |

### GitHub Action — Runbooks clés
`[40]securite-ir [41]alert-response [42]ransomware [43]security-audit [44]m365-compliance [30]incident-command [67e]m365-compromis [77]security`

---

## @IT-UrgenceMaster

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_UrgenceMaster_V1.md` | 🟠 Important | 9.4KB |
| `BUNDLE_RUNBOOKS_IT_NOC_URGENCE.md` | 🟠 Important | 19KB |

### GitHub Action — Runbooks clés
`[30]incident-command [31]frontdoor [26]post-panne [32]veeam [33]datto [35]dr-plan [36]backup-dr [67f]post-panne-hq`

---

## @IT-CloudMaster

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_CloudMaster_V1.md` | 🟠 Important | 2.2KB |
| `BUNDLE_RUNBOOK_INFRA_M365_V1.md` | 🟠 Important | 50KB |
| `BUNDLE_INFRA_365.md` | 🔵 Optionnel | 25KB |

### GitHub Action — Runbooks clés
`[14]m365 [15]m365-exchange [16]m365-intune [17]m365-teams [13]azure [44]m365-compliance [34]keepit [19b]aws [19c]gcp [92]portails [95]azure`

---

## @IT-NetworkMaster

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_NetworkMaster_V1.md` | 🟠 Important | 6KB |
| `BUNDLE_RUNBOOK_INFRA_Firewall-VPN_V1.md` | 🟠 Important | 36KB |
| `BUNDLE_INFRA_FIREWALL.md` | 🔵 Optionnel | 27KB |

### GitHub Action — Runbooks clés
`[10]fw [11]dns [05]ad-dc [01]dc [55]vpn [50]triage [60]intervention [92]portails [93]commandes`

---

## @IT-Commandare-Infra

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_Commandare-Infra_V1.md` | 🟠 Important | 6.9KB |
| `BUNDLE_RUNBOOKS_IT_INFRA.md` | 🟠 Important | 33KB |

### GitHub Action — Runbooks clés
`[01]dc [02]sql [03]srv [05]ad-dc [07]hyperv [08]vmware [09]xcpng [20]patching [23]server-health [25]audit-trim [26]post-panne [32]veeam [35]dr-plan [67f]post-panne-hq`

---

## @IT-Commandare-NOC

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_Commandare-NOC_V1.md` | 🟠 Important | 8.4KB |
| `BUNDLE_RUNBOOKS_IT_NOC_URGENCE.md` | 🟠 Important | 19KB |

### GitHub Action — Runbooks clés
`[30]incident-command [31]frontdoor [38]cwrmm-auvik [32]veeam [33]datto [35]dr-plan [36]backup-dr [50]triage [62]dispatch [78]noc-handover`

---

## @IT-Commandare-OPR

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_Commandare-OPR_V1.md` | 🟠 Important | 7.4KB |
| `BUNDLE_RUNBOOK_SUPPORT_Intervention-Live_V1.md` | 🟠 Important | 62KB |

### GitHub Action — Runbooks clés
`[80]tpl-cw [81]tpl-note [82]tpl-discussion [83]tpl-email [84]tpl-teams [60]intervention [61]close-cw [62b]ticket-to-kb [75]closeout`

---

## @IT-Commandare-TECH

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_Commandare-TECH_V1.md` | 🟠 Important | 6.8KB |
| `BUNDLE_RUNBOOK_SECURITY_Incident-Response_V1.md` | 🟠 Important | 35KB |

### GitHub Action — Runbooks clés
`[01]dc [02]sql [05]ad-dc [07]hyperv [08]vmware [40]securite-ir [41]alert-response [42]ransomware [50]triage [67e]m365-compromis`

---

## @IT-MonitoringMaster

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_MonitoringMaster_V1.md` | 🟠 Important | 2.1KB |
| `BUNDLE_RUNBOOK_NOC_RMM-Monitoring_V1.md` | 🟠 Important | 22KB |

### GitHub Action — Runbooks clés
`[37]nable [38]cwrmm-auvik [30]incident-command [31]frontdoor [32]veeam [36]backup-dr`

---

## @IT-Commandare-NOCDispatcher

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_NOCDispatcher_V1.md` | 🟠 Important | 1.7KB |
| `BUNDLE_NOC_Intervention_V1.md` | 🔵 Optionnel | 4.4KB |

### GitHub Action — Runbooks clés
`[30]incident-command [31]frontdoor [50]triage [62]dispatch [78]noc-handover [74]kickoff`

---

## @IT-AssetMaster

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_AssetMaster_V1.md` | 🟠 Important | 1.8KB |

### GitHub Action — Runbooks clés
`[90]sla [91]severity [94]naming`

---

## @IT-TicketScribe

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_TicketScribe_V1.md` | 🟠 Important | 1.5KB |
| `BUNDLE_RUNBOOK_SUPPORT_Intervention-Live_V1.md` | 🟠 Important | 62KB |

### GitHub Action — Runbooks clés
`[80]tpl-cw [81]tpl-note [82]tpl-discussion [83]tpl-email [89b]tpl-kb [60]intervention [61]close-cw [62b]ticket-to-kb`

---

## @IT-KnowledgeKeeper

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_KnowledgeKeeper_V1.md` | 🟠 Important | 1.4KB |

### GitHub Action — Runbooks clés
`[62b]ticket-to-kb [89b]tpl-kb`

---

## @IT-ReportMaster

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_ReportMaster_V1.md` | 🟠 Important | 1.4KB |

### GitHub Action — Runbooks clés
`[86]tpl-postmortem [87]tpl-qbr [88]tpl-mensuel [80]tpl-cw [81]tpl-note [90]sla [91]severity`

---

## @IT-ScriptMaster

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_ScriptMaster_V1.md` | 🟠 Important | 2KB |
| `BUNDLE_RUNBOOK_MAINTENANCE_Patching-Windows_V1.md` | 🔵 Optionnel | 30KB |

### GitHub Action — Runbooks clés
`[63]lib [63b]lib-bash [63c]lib-events [64]precheck-dc [64b]precheck-dc-dns [64c]precheck-hyperv [65]pending-reboot [66]precheck-srv [67]health-updates [67b]health-check [67c]slow-srv [67d]veeam-jobs [67e]m365-compromis [68]template`

---

## @IT-VoIPMaster

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_VoIPMaster_V1.md` | 🟠 Important | 2KB |
| `BUNDLE_RUNBOOKS_IT_RESEAU_VOIP.md` | 🟠 Important | 16KB |

### GitHub Action — Runbooks clés
`[10]fw [11]dns [60]intervention [61]close-cw [50]triage`

---

## @IT-ClientDocMaster

### Knowledge
| Fichier | Priorité | Taille |
|---|---|---|
| `prompt.md` | 🔴 EN PREMIER | — |
| `RUNBOOK_MENU_CONTEXTUEL_V3.md` | 🔴 Obligatoire | 16KB |
| `TEMPLATE_BUNDLE_CW_CLOSE.md` | 🔴 Obligatoire | 30KB |
| `GUARDRAILS__IT_AGENTS_MASTER.md` | 🔴 Obligatoire | 8.6KB |
| `BUNDLE_KP_Commandare-OPR_V1.md` | 🔵 Optionnel | 7.4KB |

### GitHub Action — Runbooks clés
`[89]tpl-hudu [89b]tpl-kb [96]ref-edocs [62b]ticket-to-kb`

---

## RAPPEL — Limite GPT Editor

- **20 fichiers max** par GPT (Knowledge)
- `prompt.md` toujours en **position 1**
- `RUNBOOK_MENU_CONTEXTUEL_V3.md` toujours en **position 2**
- `TEMPLATE_BUNDLE_CW_CLOSE.md` toujours en **position 3**
- `GUARDRAILS__IT_AGENTS_MASTER.md` toujours en **position 4**
- `BUNDLE_KP_[Agent]` toujours en **position 5**
- Les bundles thématiques peuvent aussi être servis via **GitHub Action** si la limite est atteinte

*BUNDLE_vs_AGENT V3.2 — par agent — IT MSP Intelligence Platform — 2026-04-13*
