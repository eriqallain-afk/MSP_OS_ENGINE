# CARTE DES DÉPENDANCES INTER-AGENTS — IT MSP
**Version :** 4.0  
**Date :** 2026-03-28  
**Usage :** Avant de modifier un agent, consulter cette carte pour identifier tous les fichiers qui le référencent.

---

## MODE D'EMPLOI

Quand tu modifies un agent (renommage, suppression, changement de périmètre) :
1. Cherche cet agent dans la colonne **"Qui me référence"** ci-dessous
2. Chaque fichier listé doit être vérifié et potentiellement mis à jour
3. Les fichiers système (routing, playbooks, index) sont listés en section 3

---

## 1. MATRICE PAR AGENT — Qui référence qui, et dans quel fichier

### IT-AssistanTI_FrontLine
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-AssistanTI_N2 | agent.yaml | Escalade MDP complexe + clôture CW |
| IT-AssistanTI_N3 | prompt.md, agent.yaml | Escalade N3 complexe |
| IT-BackupDRMaster | prompt.md | Escalade backup |
| IT-CloudMaster | prompt.md, agent.yaml | Escalade Exchange/M365 |
| IT-Commandare-Infra | prompt.md, agent.yaml | Escalade P1 infra |
| IT-Commandare-NOC | prompt.md, agent.yaml | Escalade P1 réseau |
| IT-NOCDispatcher | prompt.md, agent.yaml | Escalade P2 multi-users |
| IT-NetworkMaster | prompt.md, agent.yaml | Escalade VPN/firewall |
| IT-SecurityMaster | prompt.md, agent.yaml | Escalade sécurité |
| IT-VoIPMaster | prompt.md, agent.yaml | Escalade VoIP |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| playbooks.yaml | IT_FRONTLINE_CALL_TO_CLOSE |
| hub_routing.yaml | Route frontline/appel/telephone/helpdesk |

---

### IT-AssistanTI_N2
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-Commandare-NOC | agent.yaml, contract.yaml | Escalade NOC |
| IT-Commandare-TECH | agent.yaml, contract.yaml | Escalade technique |
| IT-MaintenanceMaster | agent.yaml, contract.yaml | Escalade maintenance |
| IT-SecurityMaster | agent.yaml | Escalade sécurité |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssistanTI_FrontLine | agent.yaml (escalade MDP + clôture CW) |
| playbooks.yaml | IT_MSP_TICKET_TO_KB, IT_ASSISTANTI_N2_TICKET |
| hub_routing.yaml | Route N2/helpdesk_n2 |

---

### IT-AssistanTI_N3
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-BackupDRMaster | agent.yaml, contract.yaml | Escalade backup |
| IT-ClientDocMaster | contract.yaml | Post-intervention → doc Hudu |
| IT-Commandare-Infra | agent.yaml, contract.yaml | Escalade infra |
| IT-Commandare-NOC | agent.yaml, contract.yaml | Escalade NOC |
| IT-KnowledgeKeeper | prompt.md, agent.yaml, contract.yaml | Post-intervention → KB |
| IT-NetworkMaster | agent.yaml, contract.yaml | Escalade réseau |
| IT-ReportMaster | contract.yaml | Données pour rapports |
| IT-SecurityMaster | agent.yaml, contract.yaml | Escalade sécurité |
| IT-TicketScribe | contract.yaml | Clôture CW |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssistanTI_FrontLine | prompt.md, agent.yaml (escalade N3) |
| IT-Commandare-Infra | agent.yaml (tickets workstation) |
| IT-KnowledgeKeeper | prompt.md, agent.yaml (source tickets) |
| playbooks.yaml | IT_MSP_TICKET_TO_KB, IT_INCIDENT_TRIAGE, IT_MAINT_PATCH |
| hub_routing.yaml | Route ticket/incident/support |

---

### IT-BackupDRMaster
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-CloudMaster | agent.yaml | Coordination backup cloud |
| IT-Commandare-Infra | agent.yaml | Escalade infra |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssistanTI_FrontLine | prompt.md (escalade backup) |
| IT-AssistanTI_N3 | agent.yaml, contract.yaml |
| IT-Commandare-NOC | prompt.md (sous-agent backup/DR) |
| IT-MaintenanceMaster | agent.yaml, contract.yaml |
| IT-SecurityMaster | agent.yaml |
| IT-UrgenceMaster | prompt.md, contract.yaml |
| hub_routing.yaml | Route backup/dr/disaster_recovery |

---

### IT-ClientDocMaster
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-AssetMaster | agent.yaml | Liaison CMDB ↔ edocs |
| IT-Commandare-OPR | agent.yaml | Gouvernance documentation |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssistanTI_N3 | contract.yaml (post-intervention → Hudu) |
| IT-MaintenanceMaster | contract.yaml |
| IT-TicketScribe | agent.yaml |
| hub_routing.yaml | Route hudu/documentation/edocs |

---

### IT-CloudMaster
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-Commandare-Infra | agent.yaml | Escalade infra cloud |
| IT-SecurityMaster | agent.yaml | Escalade sécurité cloud |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssistanTI_FrontLine | prompt.md, agent.yaml (escalade M365) |
| IT-BackupDRMaster | agent.yaml |
| IT-MaintenanceMaster | agent.yaml |
| IT-SecurityMaster | prompt.md (sécurité Azure/M365) |
| IT-UrgenceMaster | prompt.md, contract.yaml |
| IT-VoIPMaster | prompt.md, agent.yaml |
| hub_routing.yaml | Route cloud/azure/m365/saas |

---

### IT-Commandare-Infra
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-AssistanTI_N3 | agent.yaml | Redirection tickets workstation |
| IT-Commandare-OPR | agent.yaml | Clôture ticket |
| IT-Commandare-TECH | agent.yaml, contract.yaml | Coordination technique |
| IT-SecurityMaster | agent.yaml, contract.yaml | Escalade sécurité infra |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssistanTI_FrontLine | prompt.md, agent.yaml (P1 infra) |
| IT-AssistanTI_N3 | agent.yaml, contract.yaml |
| IT-BackupDRMaster | agent.yaml |
| IT-CloudMaster | agent.yaml |
| IT-Commandare-NOC | prompt.md (sous-agent, agent.yaml corrigé) |
| IT-Commandare-TECH | agent.yaml (escalade infra) |
| IT-MaintenanceMaster | agent.yaml, contract.yaml |
| IT-ScriptMaster | prompt.md, agent.yaml |
| IT-UrgenceMaster | prompt.md, contract.yaml |
| IT-VoIPMaster | prompt.md, agent.yaml |
| playbooks.yaml | IT_INCIDENT_TRIAGE, IT_URGENCE_P1P2 |
| hub_routing.yaml | Route infra_incident/server_down/vm_incident |

---

### IT-Commandare-NOC
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-BackupDRMaster | prompt.md | Sous-agent backup/DR |
| IT-Commandare-Infra | prompt.md | Délimitation périmètre |
| IT-Commandare-OPR | prompt.md, agent.yaml | Fermeture administrative |
| IT-Commandare-TECH | prompt.md, agent.yaml | Tickets support |
| IT-MonitoringMaster | prompt.md | Sous-agent monitoring |
| IT-NetworkMaster | prompt.md | Sous-agent réseau |
| IT-NOCDispatcher | agent.yaml | Dispatch SLA |
| IT-ScriptMaster | prompt.md | Sous-agent scripts |
| IT-SecurityMaster | prompt.md, agent.yaml | Incidents sécurité |
| IT-UrgenceMaster | agent.yaml | Urgence live |
| IT-VoIPMaster | prompt.md | Sous-agent VoIP |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssistanTI_FrontLine | prompt.md, agent.yaml (P1 réseau) |
| IT-AssistanTI_N2 | agent.yaml, contract.yaml |
| IT-AssistanTI_N3 | agent.yaml, contract.yaml |
| IT-Commandare-OPR | agent.yaml |
| IT-Commandare-TECH | agent.yaml |
| IT-MaintenanceMaster | contract.yaml |
| IT-MonitoringMaster | prompt.md (P1/P2 confirmé) |
| IT-NetworkMaster | agent.yaml |
| IT-NOCDispatcher | agent.yaml |
| IT-UrgenceMaster | prompt.md, contract.yaml |
| playbooks.yaml | IT_COMMANDARE_NOC, IT_NOC_DISPATCH, IT_INCIDENT_TRIAGE, IT_NOC_HANDOFF, IT_POST_SHUTDOWN, IT_URGENCE_P1P2 |
| hub_routing.yaml | Route noc_triage/alert_triage/incident |
| product.yaml | fallback_internal |

---

### IT-Commandare-OPR
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-Commandare-NOC | agent.yaml | Source incidents |
| IT-Commandare-TECH | agent.yaml | Source technique |
| IT-MaintenanceMaster | agent.yaml | Source maintenance |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssetMaster | agent.yaml |
| IT-ClientDocMaster | agent.yaml |
| IT-Commandare-Infra | agent.yaml |
| IT-Commandare-NOC | prompt.md, agent.yaml |
| IT-Commandare-TECH | agent.yaml |
| IT-MaintenanceMaster | contract.yaml |
| IT-ReportMaster | agent.yaml |
| IT-UrgenceMaster | contract.yaml |
| playbooks.yaml | IT_COMMANDARE_OPR, IT_CHANGE_EXEC |
| hub_routing.yaml | Route ops_control/process |

---

### IT-Commandare-TECH
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-Commandare-Infra | agent.yaml | Escalade infra |
| IT-Commandare-NOC | agent.yaml | Alertes réseau/VPN/backup |
| IT-Commandare-OPR | agent.yaml | Change request |
| IT-SecurityMaster | agent.yaml | P1 sécurité |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssistanTI_N2 | agent.yaml, contract.yaml |
| IT-Commandare-Infra | agent.yaml, contract.yaml |
| IT-Commandare-NOC | prompt.md, agent.yaml |
| IT-Commandare-OPR | agent.yaml |
| IT-MaintenanceMaster | agent.yaml, contract.yaml |
| IT-SecurityMaster | prompt.md |
| IT-UrgenceMaster | contract.yaml |
| playbooks.yaml | IT_COMMANDARE_TECH, IT_CHANGE_EXEC, IT_INCIDENT_TRIAGE |
| hub_routing.yaml | Route troubleshooting/remediation/change |
| product.yaml | escalation_policy |

---

### IT-KnowledgeKeeper
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-AssistanTI_N3 | prompt.md, agent.yaml | Source tickets résolus |
| IT-MaintenanceMaster | agent.yaml | Source maintenance |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssistanTI_N3 | prompt.md, agent.yaml, contract.yaml |
| IT-MaintenanceMaster | prompt.md, agent.yaml, contract.yaml |
| IT-NOCDispatcher | agent.yaml |
| IT-SecurityMaster | prompt.md |
| IT-TicketScribe | prompt.md, agent.yaml |
| playbooks.yaml | IT_MSP_TICKET_TO_KB, IT_CW_INTERVENTION, IT_FRONTLINE |
| hub_routing.yaml | Route knowledge/kb/runbook |

---

### IT-MaintenanceMaster
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-BackupDRMaster | agent.yaml, contract.yaml | Backup pré-maintenance |
| IT-ClientDocMaster | contract.yaml | Documentation post-maint |
| IT-CloudMaster | agent.yaml | Patching M365/Azure |
| IT-Commandare-Infra | agent.yaml, contract.yaml | Escalade infra |
| IT-Commandare-NOC | contract.yaml | Notification NOC |
| IT-Commandare-OPR | contract.yaml | Clôture administrative |
| IT-Commandare-TECH | agent.yaml, contract.yaml | Coordination technique |
| IT-KnowledgeKeeper | prompt.md, agent.yaml, contract.yaml | Post-maint → KB |
| IT-NetworkMaster | agent.yaml | Patching réseau |
| IT-ReportMaster | contract.yaml | Rapport post-maint |
| IT-SecurityMaster | agent.yaml, contract.yaml | Validation sécurité |
| IT-TicketScribe | contract.yaml | Clôture CW |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssistanTI_N2 | agent.yaml, contract.yaml |
| IT-Commandare-OPR | agent.yaml |
| IT-KnowledgeKeeper | agent.yaml |
| IT-MonitoringMaster | agent.yaml |
| IT-ScriptMaster | prompt.md, agent.yaml |
| playbooks.yaml | IT_MAINT_PATCH_REBOOT, IT_INCIDENT_TRIAGE |
| hub_routing.yaml | Route maintenance/patching/health_check |

---

### IT-MonitoringMaster
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-Commandare-NOC | prompt.md, agent.yaml | P1/P2 confirmé |
| IT-MaintenanceMaster | agent.yaml | Seuils maintenance |
| IT-NOCDispatcher | prompt.md (corrigé) | Alerte à dispatcher |
| IT-ReportMaster | prompt.md | Données rapport mensuel |
| IT-SecurityMaster | agent.yaml | Alertes sécurité |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-Commandare-NOC | prompt.md, agent.yaml (sous-agent monitoring) |
| IT-UrgenceMaster | contract.yaml |
| hub_routing.yaml | Route monitoring/alerting |

---

### IT-NetworkMaster
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-Commandare-NOC | agent.yaml | Escalade NOC |
| IT-SecurityMaster | agent.yaml | Escalade sécurité réseau |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssistanTI_FrontLine | prompt.md, agent.yaml (VPN/firewall) |
| IT-AssistanTI_N3 | agent.yaml, contract.yaml |
| IT-Commandare-NOC | prompt.md, agent.yaml (sous-agent réseau) |
| IT-MaintenanceMaster | agent.yaml |
| IT-SecurityMaster | prompt.md (segmentation, firewall) |
| IT-UrgenceMaster | contract.yaml |
| IT-VoIPMaster | prompt.md, agent.yaml |
| OPS-DossierIA | prompt.md |
| hub_routing.yaml | Route network/firewall/vpn |

---

### IT-NOCDispatcher
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-Commandare-NOC | agent.yaml | Source alertes triées |
| IT-KnowledgeKeeper | agent.yaml | Post-dispatch → KB |
| IT-SecurityMaster | agent.yaml | Alertes sécurité |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssistanTI_FrontLine | prompt.md, agent.yaml (P2 multi-users) |
| IT-Commandare-NOC | agent.yaml (dispatch SLA) |
| IT-MonitoringMaster | prompt.md (corrigé: alerte à dispatcher) |
| playbooks.yaml | IT_NOC_DISPATCH, IT_INCIDENT_TRIAGE, IT_NOC_HANDOFF |
| hub_routing.yaml | Route dispatch/sla/coordination |

---

### IT-ReportMaster
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-Commandare-OPR | agent.yaml | Source données OPR |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssistanTI_N3 | contract.yaml |
| IT-MaintenanceMaster | contract.yaml |
| IT-MonitoringMaster | prompt.md |
| IT-TicketScribe | agent.yaml |
| playbooks.yaml | IT_INCIDENT_TRIAGE, IT_CHANGE_EXEC, IT_NOC_HANDOFF, IT_POST_SHUTDOWN, IT_URGENCE_P1P2 |
| hub_routing.yaml | Route report/kpi/sla |

---

### IT-ScriptMaster
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-Commandare-Infra | prompt.md | Scripts infra |
| IT-MaintenanceMaster | prompt.md, agent.yaml | Scripts maintenance |
| IT-SecurityMaster | prompt.md, agent.yaml | Scripts sécurité |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-Commandare-NOC | prompt.md (sous-agent scripts) |
| hub_routing.yaml | Route script/powershell/automation |

---

### IT-SecurityMaster
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-CloudMaster | prompt.md | Sécurité Azure/M365 |
| IT-Commandare-TECH | prompt.md | Coordination incidents |
| IT-KnowledgeKeeper | prompt.md | KB incidents sécurité |
| IT-NetworkMaster | prompt.md | Segmentation/firewall |
| IT-TicketScribe | prompt.md | Documentation CW |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssistanTI_FrontLine | prompt.md, agent.yaml (escalade sécurité) |
| IT-AssistanTI_N2 | agent.yaml |
| IT-AssistanTI_N3 | agent.yaml, contract.yaml |
| IT-BackupDRMaster | agent.yaml (non listé mais logique) |
| IT-CloudMaster | agent.yaml |
| IT-Commandare-Infra | agent.yaml, contract.yaml |
| IT-Commandare-NOC | prompt.md, agent.yaml |
| IT-Commandare-TECH | agent.yaml |
| IT-MaintenanceMaster | agent.yaml, contract.yaml |
| IT-MonitoringMaster | agent.yaml |
| IT-NOCDispatcher | agent.yaml |
| IT-ScriptMaster | prompt.md, agent.yaml |
| IT-UrgenceMaster | prompt.md, contract.yaml |
| playbooks.yaml | IT_URGENCE_P1P2 |
| hub_routing.yaml | Route security/edr/phishing/ransomware |

---

### IT-TicketScribe
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-ClientDocMaster | agent.yaml | Post-clôture → doc Hudu |
| IT-KnowledgeKeeper | prompt.md, agent.yaml | Post-clôture → KB |
| IT-ReportMaster | agent.yaml | Données pour rapports |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssistanTI_N3 | contract.yaml |
| IT-MaintenanceMaster | contract.yaml |
| IT-SecurityMaster | prompt.md |
| IT-VoIPMaster | prompt.md |
| playbooks.yaml | IT_MSP_TICKET_TO_KB, IT_COMMANDARE_OPR |
| hub_routing.yaml | Route ticket/writing/closeout |

---

### IT-UrgenceMaster
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-BackupDRMaster | prompt.md, contract.yaml | Escalade backup |
| IT-CloudMaster | prompt.md, contract.yaml | Escalade cloud |
| IT-Commandare-Infra | prompt.md, contract.yaml | Escalade infra |
| IT-Commandare-NOC | prompt.md, contract.yaml | Escalade NOC |
| IT-Commandare-OPR | contract.yaml | Clôture/comms |
| IT-Commandare-TECH | contract.yaml | RCA N3 |
| IT-MonitoringMaster | contract.yaml | Monitoring/RMM |
| IT-NetworkMaster | contract.yaml | Firewall/réseau avancé |
| IT-SecurityMaster | prompt.md, contract.yaml | Breach/ransomware |
| IT-VoIPMaster | prompt.md, contract.yaml | Téléphonie |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-Commandare-NOC | agent.yaml (escalade urgence live) |
| playbooks.yaml | IT_URGENCE_P1P2 |
| hub_routing.yaml | Route urgence/panne/panne_hq/p1/p2/flagup |

---

### IT-VoIPMaster
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-CloudMaster | prompt.md, agent.yaml | Intégration Teams Phone |
| IT-Commandare-Infra | prompt.md, agent.yaml | Infra PBX/trunk |
| IT-NetworkMaster | prompt.md, agent.yaml | Réseau voix |
| IT-TicketScribe | prompt.md | Documentation CW |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-AssistanTI_FrontLine | prompt.md, agent.yaml (escalade VoIP) |
| IT-Commandare-NOC | prompt.md, agent.yaml (sous-agent VoIP) |
| IT-UrgenceMaster | prompt.md, contract.yaml |
| hub_routing.yaml | Route voip/uc/telephonie |

---

### IT-AssetMaster
| Je référence | Fichier | Contexte |
|---|---|---|
| IT-Commandare-Infra | agent.yaml | Coordination CMDB ↔ infra |
| IT-Commandare-OPR | agent.yaml | Gouvernance assets |

**Qui me référence :**
| Agent | Fichier |
|---|---|
| IT-ClientDocMaster | agent.yaml (liaison CMDB ↔ edocs) |
| hub_routing.yaml | Route cmdb/assets |

---

## 2. AGENTS LES PLUS RÉFÉRENCÉS (impact maximal si modifiés)

| Agent | Nombre d'agents qui le référencent | Risque de casse |
|---|---|---|
| IT-SecurityMaster | 13 agents + routing + playbooks | 🔴 CRITIQUE |
| IT-Commandare-NOC | 10 agents + routing + playbooks + product.yaml | 🔴 CRITIQUE |
| IT-Commandare-Infra | 10 agents + routing + playbooks | 🔴 CRITIQUE |
| IT-KnowledgeKeeper | 6 agents + routing + playbooks | 🟠 ÉLEVÉ |
| IT-MaintenanceMaster | 6 agents + routing + playbooks | 🟠 ÉLEVÉ |
| IT-Commandare-OPR | 8 agents + routing + playbooks | 🟠 ÉLEVÉ |
| IT-Commandare-TECH | 7 agents + routing + playbooks | 🟠 ÉLEVÉ |
| IT-CloudMaster | 6 agents + routing | 🟡 MOYEN |
| IT-NetworkMaster | 7 agents + routing + OPS-DossierIA | 🟡 MOYEN |
| IT-BackupDRMaster | 6 agents + routing | 🟡 MOYEN |
| IT-AssistanTI_N3 | 4 agents + routing + playbooks | 🟡 MOYEN |
| IT-TicketScribe | 4 agents + routing + playbooks | 🟡 MOYEN |
| IT-NOCDispatcher | 4 agents + routing + playbooks | 🟡 MOYEN |
| IT-ReportMaster | 5 agents + routing + playbooks | 🟡 MOYEN |
| IT-VoIPMaster | 3 agents + routing | 🟢 BAS |
| IT-AssetMaster | 1 agent + routing | 🟢 BAS |
| IT-ClientDocMaster | 3 agents + routing | 🟢 BAS |
| IT-MonitoringMaster | 2 agents + routing | 🟢 BAS |
| IT-ScriptMaster | 1 agent + routing | 🟢 BAS |
| IT-UrgenceMaster | 1 agent + routing + playbooks | 🟢 BAS |
| IT-AssistanTI_N2 | 1 agent + routing + playbooks | 🟢 BAS |
| IT-AssistanTI_FrontLine | 0 agents + routing + playbooks | 🟢 BAS |

---

## 3. FICHIERS SYSTÈME À VÉRIFIER POUR TOUT CHANGEMENT

Pour **tout** ajout, suppression ou renommage d'agent, ces fichiers doivent être mis à jour :

| Fichier | Chemin | Contenu |
|---|---|---|
| agents.yaml | 00_INDEX/agents.yaml | Liste de tous les agents actifs et archivés |
| agents_index.yaml | 00_INDEX/agents_index.yaml | Description, intents, path de chaque agent |
| intents.yaml | 00_INDEX/intents.yaml | Mapping intent → agent(s) |
| gpt_catalog.yaml | 00_INDEX/gpt_catalog.yaml | Paths agent.yaml / contract.yaml / prompt.md |
| KNOWLEDGE_INDEX.yaml | 00_INDEX/KNOWLEDGE_INDEX.yaml | Bundles et knowledge files par agent |
| product.yaml | 00_INDEX/product.yaml | Stats globales (compteurs, dernière mise à jour) |
| hub_routing.yaml | 80_MACHINES/hub_routing.yaml | Table de routage par intents |
| playbooks.yaml | playbooks/playbooks.yaml | Chaînes d'exécution multi-agents |

---

## 4. PLACEHOLDERS DANS LES PROMPTS

Ces chaînes ne sont PAS des références cassées — ce sont des variables dynamiques :

| Chaîne | Trouvée dans | Signification |
|---|---|---|
| `[@IT-Agent]` | FrontLine prompt.md | Variable : sera remplacée par l'agent cible au moment du transfert |
| `<@IT-Agent ou technicien>` | NOCDispatcher prompt.md | Champ de formulaire : nom de l'agent ou technicien assigné |
| `@IT-[Specialist]` | MonitoringMaster prompt.md | Variable : spécialiste selon domaine de l'alerte |

**NE PAS remplacer ces placeholders par des noms d'agents concrets.**

---

*Dernière vérification : 2026-03-28 — 22 agents actifs + 3 OPS*
