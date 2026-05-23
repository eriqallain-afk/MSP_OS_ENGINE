# BUNDLE — IT Core MSP
**ID :** BUNDLE__IT_CORE_MSP  
**Version :** 1.0 | **Usage :** Agents principaux MSP  
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Agents consommateurs :** IT-OrchestratorMSP, IT-SupportMaster, IT-TicketScribe, IT-TicketScribe, IT-DirecteurGeneral

---

## CONTENU DU BUNDLE

### 1. MATRICE DE SÉVÉRITÉ UNIVERSELLE

| Priorité | Définition | Délai réponse | Délai résolution | Exemples |
|----------|-----------|---------------|-----------------|---------|
| P1 | Service critique hors ligne, impact majeur business | 15 min | 4h | DC down, ransomware, réseau site complet |
| P2 | Service dégradé, contournement possible | 30 min | 8h | Email lent, backup en échec, VPN partiel |
| P3 | Problème utilisateur, impact limité | 2h | 24h | PC lent, imprimante, password reset |
| P4 | Demande de service, amélioration | 4h | 72h | Nouvelle installation, question, formation |

---

### 2. ROUTING MSP — AGENTS PAR DOMAINE

| Domaine | Agent primaire | Agent secondaire |
|---------|----------------|-----------------|
| Incident P1/P2 | IT-Commandare-NOC | IT-CTOMaster |
| Sécurité | IT-SecurityMaster | IT-Commandare-NOC |
| Cloud/M365/Azure | IT-CloudMaster | IT-CTOMaster |
| Réseau | IT-NetworkMaster | IT-Commandare-Infra |
| Serveurs/VM | IT-Commandare-Infra | IT-Commandare-TECH |
| Backup/DR | IT-BackupDRMaster | IT-Commandare-Infra |
| Maintenance/Patching | IT-MaintenanceMaster | IT-ScriptMaster |
| Support N1/N2 | IT-SupportMaster | IT-Technicien |
| Intervention live | IT-MSPLiveAssistant | IT-InterventionCopilot |
| VoIP/UC | IT-VoIPMaster | IT-NetworkMaster |
| Sécurité cyber | IT-SecurityMaster | IT-Commandare-NOC |
| DevOps/CI-CD | IT-DevOpsMaster | IT-ScriptMaster |
| Licences/SAM | IT-SoftwMaster | IT-AssetMaster |
| Scripts | IT-ScriptMaster | IT-MaintenanceMaster |
| Rapports | IT-ReportMaster | IT-KnowledgeKeeper |
| Tickets CW | IT-TicketScribe | IT-TicketScribe |

---

### 3. STANDARDS COMMUNICATION CLIENT MSP

#### Règles universelles :
- **Zéro adresse IP** dans les livrables externes
- **Zéro jargon technique** non expliqué vers client non-technique
- **Toujours confirmer** impact résolu pour l'utilisateur
- **Langue** : français par défaut (québécois), anglais si demandé
- **Délai réponse** : accusé de réception dans les délais SLA même si pas de résolution

#### Formules d'ouverture email client :
- Incident ouvert : "Suite à votre signalement..."
- Maintenance planifiée : "Dans le cadre de la maintenance planifiée du [DATE]..."
- Résolution : "Nous avons le plaisir de vous informer que..."
- Escalade : "Nous avons escaladé votre dossier à notre équipe spécialisée..."

---

### 4. CHECKLIST KICKOFF TICKET STANDARD

```
□ Numéro de ticket CW créé/assigné
□ Priorité correctement assignée (P1/P2/P3/P4)
□ Client notifié (accusé de réception)
□ Asset/utilisateur affecté documenté
□ Description symptômes précise (pas d'interprétation)
□ Heure de début incident notée
□ Agent/technicien assigné
□ SLA calculé et suivi activé
```

---

### 5. GLOSSAIRE MSP ESSENTIEL

| Terme | Définition |
|-------|-----------|
| RMM | Remote Monitoring & Management (N-able, ConnectWise RMM) |
| PSA | Professional Services Automation (ConnectWise Manage) |
| NOC | Network Operations Center — surveillance continue |
| SOC | Security Operations Center — surveillance sécurité |
| CMDB | Configuration Management Database — inventaire actifs |
| SLA | Service Level Agreement — engagements de service |
| MTTD | Mean Time To Detect |
| MTTR | Mean Time To Resolve |
| RTO | Recovery Time Objective — délai max remise en service |
| RPO | Recovery Point Objective — perte de données max acceptable |
| EOL | End of Life — fin de vie produit |
| EOS | End of Support — fin du support fabricant |
| MOS | Mean Opinion Score — qualité audio VoIP (1-5) |
| QBR | Quarterly Business Review |
| KB | Knowledge Base |
| IR | Incident Response |
| IOC | Indicator of Compromise |

---

### 6. INTÉGRATIONS ACTIVES

| Intégration | Usage | Agents concernés |
|-------------|-------|-----------------|
| ConnectWise Manage | PSA, tickets, facturation | Tous |
| N-able / CW RMM | Monitoring, patching, accès distant | IT-MaintenanceMaster, IT-MonitoringMaster |
| Azure AD / Entra ID | IAM, MFA, Conditional Access | IT-CloudMaster, IT-SecurityMaster |
| Microsoft 365 | Email, Teams, SharePoint, OneDrive | IT-CloudMaster |
| Veeam / Datto | Backup & DR | IT-BackupDRMaster |
