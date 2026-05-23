# RUNBOOK_CATALOG_GUIDEDOPS

**Produit :** IT MSP Intelligence / MSP GuidedOps AI  
**Version :** 0.1 — tri initial  
**Date :** 2026-05-09  
**Statut :** DRAFT_VALIDATION  
**Owner suggéré :** TEAM__IT / Lead MSP / Service Delivery  

---

## Objectif

Ce catalogue sert de source de vérité initiale pour classer, dédupliquer et router les runbooks de la plateforme **IT MSP Intelligence**. Il ne remplace pas les runbooks; il les référence, les qualifie et indique leur statut de tri.

Le principe d’architecture est le suivant :

```text
1 runbook = source opérationnelle canonique
1 script = outil contrôlé classé par risque
1 template = format de sortie
1 checklist = contrôle qualité
1 bundle = assemblage contrôlé
1 Knowledge Pack = livraison à un agent
1 agent = cockpit ou rôle consommateur
```

---

## Règles de normalisation

- Un runbook canonique doit être conservé **sans suffixe** `(1)`, `(2)`, etc.
- Les variantes doivent être comparées, puis archivées dans `99_ARCHIVE_LEGACY/`.
- Les bundles doivent référencer les runbooks, pas les recopier intégralement.
- Toute action à risque doit référer à `GUARDRAILS__IT_AGENTS_MASTER`.
- Les runbooks `ENRICH` ou `ENRICH_DRAFT` ne doivent pas être inclus tels quels dans une offre commerciale sans validation.
- Les runbooks `MERGE_REFERENCE` ne doivent pas créer une deuxième source concurrente.

---

## Légende

### Statuts

| Statut | Signification |
|---|---|
| `CANONICAL_REVIEWED` | Runbook prêt à recevoir une runbook card et à être relié aux bundles. |
| `CANONICAL_AFTER_COMPARE` | Runbook probablement canonique, mais variantes à comparer avant gel officiel. |
| `DUPLICATE_CANDIDATE` | Variante ou doublon à comparer puis archiver. |
| `RENAME_CANONICAL` | Seule version détectée porte un suffixe; renommer sans suffixe avant gel. |
| `MERGE_REFERENCE` | Runbook utile, mais à fusionner ou référencer vers une source maître. |
| `CANONICAL_SPLIT_LATER` | Acceptable maintenant; à découper en modules plus propres plus tard. |
| `ENRICH` | Structure utile mais procédure terrain à compléter. |
| `ENRICH_DRAFT` | Squelette ou contenu trop mince pour production. |

### Risques

| Niveau | Sens |
|---|---|
| `0` | Lecture seule / inventaire / diagnostic non intrusif. |
| `0-1` | Lecture seule avec possibilité de correction légère. |
| `1-2` | Support ou diagnostic avec actions limitées possibles. |
| `2` | Changement contrôlé, approbation ou fenêtre souvent requise. |
| `2-3` | Infrastructure critique / firewall / DC / virtualisation / DR. |
| `1-3` | Risque variable selon l’action choisie dans le runbook. |
| `REVIEW` | Risque à confirmer lors de la runbook card. |

---

## Résumé du catalogue

- **Runbooks inventoriés :** 88
- **Familles produit :** 15
- **À comparer / archiver / enrichir :** 55

### Comptage par famille

| Famille | Nombre |
|---|---:|
| ServerOps / MaintOps | 18 |
| CloudOps / M365Ops | 11 |
| SupportOps | 8 |
| TicketOps / SupportOps | 8 |
| BackupDROps | 8 |
| InfraOps / DirectoryOps | 7 |
| NetworkOps / FirewallOps | 7 |
| NOCOps | 6 |
| SecOps / Governance | 4 |
| InfraOps / VirtualizationOps | 3 |
| OPROps | 3 |
| InfraOps / ServerRoleOps | 2 |
| DiscoveryOps / QuickStart | 3 |
| VoIPOps | 1 |

### Comptage par statut

| Statut | Nombre |
|---|---:|
| `CANONICAL_REVIEWED` | 33 |
| `DUPLICATE_CANDIDATE` | 18 |
| `CANONICAL_AFTER_COMPARE` | 16 |
| `RENAME_CANONICAL` | 14 |
| `ENRICH_DRAFT` | 4 |
| `ENRICH` | 2 |
| `MERGE_REFERENCE` | 1 |

### Comptage par niveau commercial

| Niveau | Nombre |
|---|---:|
| Pro+ | 41 |
| MSP Suite | 24 |
| Starter+ | 16 |
| Enterprise | 7 |

---

# Catalogue détaillé

## TicketOps / SupportOps

| filename | class | risk | status | tier | action |
| --- | --- | --- | --- | --- | --- |
| OPR-CW-TicketQualityAudit_V1.md | OPR / QUALITYOPS | 0-1 | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| SUP-N1N2-SupportTriage_V2.md | ROUTE / TRIAGEOPS | 1-2 | CANONICAL_REVIEWED | Starter+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| SUP-OPS-CW_Dispatch_V2.md | ROUTE / DISPATCHOPS | 0-1 | CANONICAL_REVIEWED | Starter+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| SUP-OPS-CW_InterventionLive_Close_V2(1).md | CORE / TICKETOPS_CLOSE | REVIEW | RENAME_CANONICAL | Pro+ | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| SUP-OPS-CW_InterventionLive_Close_V2(2).md | CORE / TICKETOPS_CLOSE | REVIEW | RENAME_CANONICAL | Pro+ | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| SUP-OPS-CommandareOPR_V1.md | OPR / CLOSEOPS | REVIEW | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| SUP-OPS-CommandareTech_V1.md | OPR / TECH_ESCALATION | REVIEW | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| SUP-OPS-TicketToKB_V2.md | CORE / KNOWLEDGEOPS | REVIEW | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |

## SupportOps

| filename | class | risk | status | tier | action |
| --- | --- | --- | --- | --- | --- |
| SUP-M365-OneDrive_SharePoint_Sync_V2(1).md | SUP / SYNCOPS | 1-2 | DUPLICATE_CANDIDATE | Starter+ | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| SUP-M365-OneDrive_SharePoint_Sync_V2(2).md | SUP / SYNCOPS | 1-2 | DUPLICATE_CANDIDATE | Starter+ | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| SUP-M365-OneDrive_SharePoint_Sync_V2.md | SUP / SYNCOPS | 1-2 | CANONICAL_AFTER_COMPARE | Starter+ | Confirmer comme source canonique après comparaison des variantes. |
| SUP-N2-Support_V2(1).md | SUP / SUPPORTOPS_INDEX | 1-2 | DUPLICATE_CANDIDATE | Starter+ | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| SUP-N2-Support_V2.md | SUP / SUPPORTOPS_INDEX | 1-2 | CANONICAL_AFTER_COMPARE | Starter+ | Confirmer comme source canonique après comparaison des variantes. |
| SUP-NET-VPN_Troubleshooting_V2(1).md | SUP / VPNOPS | 1-2 | DUPLICATE_CANDIDATE | Starter+ | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| SUP-NET-VPN_Troubleshooting_V2(2).md | SUP / VPNOPS | 1-2 | DUPLICATE_CANDIDATE | Starter+ | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| SUP-NET-VPN_Troubleshooting_V2.md | SUP / VPNOPS | 1-2 | CANONICAL_AFTER_COMPARE | Starter+ | Confirmer comme source canonique après comparaison des variantes. |

## ServerOps / MaintOps

| filename | class | risk | status | tier | action |
| --- | --- | --- | --- | --- | --- |
| INFRA-SRV-HealthCheck_Template_V1.md | DISCOVERY / REPORT_TEMPLATE | 0-1 | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| MAINT-OPS-CMDB_AssetAudit_V1.md | AUDIT / CMDBOPS | REVIEW | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| MAINT-SRV-AuditTrimestriel_V2(1).md | AUDIT / QUARTERLYOPS | REVIEW | RENAME_CANONICAL | MSP Suite | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| MAINT-SRV-AuditTrimestriel_V2(2).md | AUDIT / QUARTERLYOPS | REVIEW | RENAME_CANONICAL | MSP Suite | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| MAINT-SRV-HealthCheck_V2(1).md | DISCOVERY / HEALTHOPS | 0-1 | DUPLICATE_CANDIDATE | Starter+ | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| MAINT-SRV-HealthCheck_V2.md | DISCOVERY / HEALTHOPS | 0-1 | CANONICAL_AFTER_COMPARE | Starter+ | Confirmer comme source canonique après comparaison des variantes. |
| MAINT-SRV-PostShutdown_Electrical_V2(1).md | RECOVERY / POWEROPS | 2 | DUPLICATE_CANDIDATE | MSP Suite | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| MAINT-SRV-PostShutdown_Electrical_V2.md | RECOVERY / POWEROPS | 2 | CANONICAL_AFTER_COMPARE | MSP Suite | Confirmer comme source canonique après comparaison des variantes. |
| MAINT-SRV-PrintServer_PrePost_V1(1).md | MAINT / PRINTOPS | 1-2 | DUPLICATE_CANDIDATE | Pro+ | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| MAINT-SRV-PrintServer_PrePost_V1.md | MAINT / PRINTOPS | 1-2 | CANONICAL_AFTER_COMPARE | Pro+ | Confirmer comme source canonique après comparaison des variantes. |
| MAINT-WIN-Patching_CW-RMM_V3(1).md | MAINT / PATCHOPS_EXECUTION | 2 | DUPLICATE_CANDIDATE | Pro+ | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| MAINT-WIN-Patching_CW-RMM_V3.md | MAINT / PATCHOPS_EXECUTION | 2 | CANONICAL_AFTER_COMPARE | Pro+ | Confirmer comme source canonique après comparaison des variantes. |
| MAINT-WIN-Patching_Complet_V3(1).md | MAINT / PATCHOPS_MASTER | 2 | DUPLICATE_CANDIDATE | MSP Suite | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| MAINT-WIN-Patching_Complet_V3.md | MAINT / PATCHOPS_MASTER | 2 | CANONICAL_AFTER_COMPARE | MSP Suite | Confirmer comme source canonique après comparaison des variantes. |
| MAINT-WIN-PendingReboot_V2(1).md | MAINT / REBOOTOPS | 2 | DUPLICATE_CANDIDATE | Pro+ | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| MAINT-WIN-PendingReboot_V2.md | MAINT / REBOOTOPS | 2 | CANONICAL_AFTER_COMPARE | Pro+ | Confirmer comme source canonique après comparaison des variantes. |
| MAINT-WIN-WSUS_Maintenance_V2.md | MAINT / WSUSOPS | 2 | CANONICAL_REVIEWED | MSP Suite | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| RUNBOOK__DC_PATCHING_PRECHECK(1).md | INFRA / DC_PATCHOPS | 2-3 | RENAME_CANONICAL | Pro+ | Renommer sans suffixe (1)/(2), puis créer la runbook card. |

## InfraOps / DirectoryOps

| filename | class | risk | status | tier | action |
| --- | --- | --- | --- | --- | --- |
| INFRA-AD-DC_Operations_V3(1).md | INFRA / DIRECTORYOPS_CRITICAL | 2-3 | DUPLICATE_CANDIDATE | MSP Suite | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| INFRA-AD-DC_Operations_V3.md | INFRA / DIRECTORYOPS_CRITICAL | 2-3 | CANONICAL_AFTER_COMPARE | MSP Suite | Confirmer comme source canonique après comparaison des variantes. |
| INFRA-AD-DC_PrePost_Validation_V2.md | INFRA / DC_PREPOST | REVIEW | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| INFRA-AD-EntraID_Operations_V2(1).md | IDENTITY / ENTRAOPS | 2 | DUPLICATE_CANDIDATE | Pro+ | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| INFRA-AD-EntraID_Operations_V2.md | IDENTITY / ENTRAOPS | 2 | CANONICAL_AFTER_COMPARE | Pro+ | Confirmer comme source canonique après comparaison des variantes. |
| INFRA-AD-UserManagement_V2(1).md | IDENTITY / USEROPS | 2 | DUPLICATE_CANDIDATE | Pro+ | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| INFRA-AD-UserManagement_V2.md | IDENTITY / USEROPS | 2 | CANONICAL_AFTER_COMPARE | Pro+ | Confirmer comme source canonique après comparaison des variantes. |
| INFRA-AD-GPO_Management_V1.md | INFRA / GPOOPS | 2-3 | CANONICAL_REVIEWED | Pro+ | Gestion GPO — audit, nommage, héritage, diagnostic, rollback. |
| INFRA-AD-FolderSecurity_V1.md | INFRA / FOLDEROPS | 2 | CANONICAL_REVIEWED | Pro+ | Sécurité dossiers NTFS via groupes AD — AGDLP, héritage, break inheritance. |

## InfraOps / ServerRoleOps

| filename | class | risk | status | tier | action |
| --- | --- | --- | --- | --- | --- |
| INFRA-SRV-RDS_Operations_V2.md | INFRA / RDSOPS | 2 | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| INFRA-SRV-SQL_PrePost_Validation_V2.md | INFRA / SQL_PREPOST | 2 | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |

## InfraOps / VirtualizationOps

| filename | class | risk | status | tier | action |
| --- | --- | --- | --- | --- | --- |
| INFRA-SRV-NewVM_Deployment_V1.md | INFRA / VM_PROVISIONING | 2-3 | CANONICAL_REVIEWED | MSP Suite | Déploiement nouvelle VM — ressources, placement, disques par rôle, Hyper-V + VMware. |
| INFRA-SRV-HyperV_Operations_V2.md | INFRA / HYPERVOPS | 2-3 | CANONICAL_REVIEWED | MSP Suite | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| INFRA-SRV-VMware_Operations_V2.md | INFRA / VMWAREOPS | 2-3 | CANONICAL_REVIEWED | MSP Suite | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| INFRA-SRV-XCPng_Operations_V1.md | INFRA / XCPNGOPS | 2-3 | CANONICAL_REVIEWED | MSP Suite | Créer/compléter la runbook card et mapper bundles/scripts/templates. |

## CloudOps / M365Ops

| filename | class | risk | status | tier | action |
| --- | --- | --- | --- | --- | --- |
| INFRA-CLOUD-Architecture_Review_V2.md | CLOUD / ARCHREVIEWOPS | 2-3 | CANONICAL_REVIEWED | Enterprise | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| INFRA-M365-Exchange_Online_V2(1).md | M365 / MAILOPS | 2 | DUPLICATE_CANDIDATE | Pro+ | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| INFRA-M365-Exchange_Online_V2.md | M365 / MAILOPS | 2 | CANONICAL_AFTER_COMPARE | Pro+ | Confirmer comme source canonique après comparaison des variantes. |
| INFRA-M365-Intune_Devices_V2.md | M365 / INTUNEOPS | 2 | CANONICAL_REVIEWED | MSP Suite | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| INFRA-M365-Teams_SharePoint_OneDrive_V2(1).md | M365 / COLLABOPS | 1-2 | DUPLICATE_CANDIDATE | Starter+ | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| INFRA-M365-Teams_SharePoint_OneDrive_V2.md | M365 / COLLABOPS | 1-2 | CANONICAL_AFTER_COMPARE | Starter+ | Confirmer comme source canonique après comparaison des variantes. |
| INFRA-M365-UserManagement_V2(1).md | IDENTITY / USEROPS | 2 | DUPLICATE_CANDIDATE | Pro+ | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| INFRA-M365-UserManagement_V2.md | IDENTITY / USEROPS | 2 | CANONICAL_AFTER_COMPARE | Pro+ | Confirmer comme source canonique après comparaison des variantes. |
| INFRA-M365-UserOnboarding_V2(1).md | M365 / ONBOARDINGOPS | 2 | DUPLICATE_CANDIDATE | Pro+ | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| INFRA-M365-UserOnboarding_V2.md | M365 / ONBOARDINGOPS | 2 | CANONICAL_AFTER_COMPARE | Pro+ | Confirmer comme source canonique après comparaison des variantes. |
| SEC-M365-Compliance_Purview_V2.md | SEC / COMPLIANCEOPS | REVIEW | CANONICAL_REVIEWED | Enterprise | Créer/compléter la runbook card et mapper bundles/scripts/templates. |

## NetworkOps / FirewallOps

| filename | class | risk | status | tier | action |
| --- | --- | --- | --- | --- | --- |
| INFRA-NET-Fortinet_Operations_V2(1).md | NET / FIREWALLOPS_FORTINET | 2-3 | RENAME_CANONICAL | MSP Suite | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| INFRA-NET-Meraki_Operations_V2(1).md | NET / CLOUDNETWORKOPS_MERAKI | 2-3 | RENAME_CANONICAL | MSP Suite | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| INFRA-NET-NetworkDiagnostic_V2(1).md | NET / DIAGNOSTICOPS | 0-1 | RENAME_CANONICAL | Starter+ | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| INFRA-NET-NetworkSetup_V1(1).md | NET / SETUPOPS | 2-3 | RENAME_CANONICAL | MSP Suite | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| INFRA-NET-SonicWall_Operations_V2(1).md | NET / FIREWALLOPS_SONICWALL | 2-3 | RENAME_CANONICAL | MSP Suite | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| INFRA-NET-Unifi_Mikrotik_Operations_V1(1).md | NET / LAN_WIFI_ROUTEROPS | 2-3 | RENAME_CANONICAL | MSP Suite | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| INFRA-NET-WatchGuard_Operations_V2(1).md | NET / FIREWALLOPS_WATCHGUARD | 2-3 | RENAME_CANONICAL | MSP Suite | Renommer sans suffixe (1)/(2), puis créer la runbook card. |

## VoIPOps

| filename | class | risk | status | tier | action |
| --- | --- | --- | --- | --- | --- |
| INFRA-VOIP-Diagnostic_V2(1).md | VOIP / DIAGNOSTICOPS | 1-2 | RENAME_CANONICAL | Pro+ | Renommer sans suffixe (1)/(2), puis créer la runbook card. |

## NOCOps

| filename | class | risk | status | tier | action |
| --- | --- | --- | --- | --- | --- |
| NOC-OPS-CommandCenter_V2.md | NOC / COMMANDCENTER | 0-1 | CANONICAL_REVIEWED | MSP Suite | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| NOC-OPS-Dispatch_V2.md | NOC / DISPATCHOPS | 0-1 | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| NOC-OPS-FrontDoor_V2.md | NOC / FRONTDOOR | 0-1 | CANONICAL_REVIEWED | MSP Suite | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| NOC-OPS-IncidentCommand_V2.md | NOC / INCIDENTCOMMAND | REVIEW | ENRICH | Pro+ | Compléter la procédure terrain avant productisation. |
| NOC-RMM-CWRMM_Auvik_Operations_V2.md | NOC / MONITORINGOPS_CW_AUVIK | REVIEW | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| NOC-RMM-NAble_Operations_V2.md | NOC / MONITORINGOPS_NABLE | REVIEW | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |

## BackupDROps

| filename | class | risk | status | tier | action |
| --- | --- | --- | --- | --- | --- |
| INFRA-BACKUP-Veeam_Operations_V2.md | BACKUPDR / VEEAMOPS | 1-3 | MERGE_REFERENCE | MSP Suite | Fusionner/référencer vers la source maître BackupDROps; éviter deux VeeamOps concurrents. |
| NOC-BACKUP-Backup_Configuration_V2.md | BACKUPDR / CONFIGOPS | 1-3 | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| NOC-BACKUP-DR_Plan_Validation_V2.md | BACKUPDR / DRPLANOPS | 2-3 | CANONICAL_REVIEWED | Enterprise | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| NOC-BACKUP-DR_Test_V2.md | BACKUPDR / DRTESTOPS | 1-3 | ENRICH | Pro+ | Compléter la procédure terrain avant productisation. |
| NOC-BACKUP-Datto_Operations_V2.md | BACKUPDR / DATTOOPS | 1-3 | CANONICAL_REVIEWED | MSP Suite | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| NOC-BACKUP-Keepit_Operations_V2.md | BACKUPDR / KEEPITOPS | 1-3 | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| NOC-BACKUP-Veeam_Cloud_V2.md | BACKUPDR / VEEAMCLOUDOPS | 2-3 | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| NOC-BACKUP-Veeam_Operations_V2.md | BACKUPDR / VEEAMOPS | 1-3 | CANONICAL_REVIEWED | MSP Suite | Créer/compléter la runbook card et mapper bundles/scripts/templates. |

## SecOps / Governance

| filename | class | risk | status | tier | action |
| --- | --- | --- | --- | --- | --- |
| OPR-PostIncident-Review-P1P2_V1.md | OPR / PIROPS | 0-1 | ENRICH_DRAFT | Enterprise | Enrichir : objectifs, déclencheurs, inputs, procédure, DoD, escalade, guardrails. |
| SEC-SECU-AlertResponse_V2.md | SEC / ALERTOPS | REVIEW | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| SEC-SECU-IncidentResponse_V3.md | SEC / IROPS_CRITICAL | 2-3 | CANONICAL_REVIEWED | Enterprise | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| SEC-SECU-SecurityAudit_V2.md | SEC / SECURITYAUDITOPS | 2-3 | CANONICAL_REVIEWED | Enterprise | Créer/compléter la runbook card et mapper bundles/scripts/templates. |

## OPROps

| filename | class | risk | status | tier | action |
| --- | --- | --- | --- | --- | --- |
| OPR-ClientCommunication-Cadence_V1.md | OPR / CLIENTCOMMS | 0-1 | ENRICH_DRAFT | Pro+ | Enrichir : objectifs, déclencheurs, inputs, procédure, DoD, escalade, guardrails. |
| OPR-ProblemManagement-CAPA_V1.md | OPR / CAPAOPS | 0-1 | ENRICH_DRAFT | Enterprise | Enrichir : objectifs, déclencheurs, inputs, procédure, DoD, escalade, guardrails. |
| OPR-SLA-BreachPrevention_V1.md | OPR / SLAOPS | 0-1 | ENRICH_DRAFT | Pro+ | Enrichir : objectifs, déclencheurs, inputs, procédure, DoD, escalade, guardrails. |

## UNCLASSIFIED

| filename | class | risk | status | tier | action |
| --- | --- | --- | --- | --- | --- |
| INFRA-OPS-QuickStart_V1.md | INFRA / QUICKSTARTOPS | REVIEW | CANONICAL_REVIEWED | Pro+ | Créer/compléter la runbook card et mapper bundles/scripts/templates. |
| RUNBOOK__SERVER_ROLE_DISCOVERY(2).md | DISCOVERY / ROLEOPS | 0-1 | RENAME_CANONICAL | Starter+ | Renommer vers `RUNBOOK__SERVER_ROLE_DISCOVERY.md`, puis créer la runbook card. |

---

# Liste prioritaire de nettoyage

Cette section regroupe les éléments à traiter avant de déclarer le catalogue `PRODUCTION_READY`.

| filename | target_file | product_family | status | action |
| --- | --- | --- | --- | --- |
| SUP-OPS-CW_InterventionLive_Close_V2(1).md | SUP-OPS-CW_InterventionLive_Close_V2.md | TicketOps / SupportOps | RENAME_CANONICAL | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| SUP-OPS-CW_InterventionLive_Close_V2(2).md | SUP-OPS-CW_InterventionLive_Close_V2.md | TicketOps / SupportOps | RENAME_CANONICAL | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| SUP-M365-OneDrive_SharePoint_Sync_V2(1).md | SUP-M365-OneDrive_SharePoint_Sync_V2.md | SupportOps | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| SUP-M365-OneDrive_SharePoint_Sync_V2(2).md | SUP-M365-OneDrive_SharePoint_Sync_V2.md | SupportOps | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| SUP-M365-OneDrive_SharePoint_Sync_V2.md | SUP-M365-OneDrive_SharePoint_Sync_V2.md | SupportOps | CANONICAL_AFTER_COMPARE | Confirmer comme source canonique après comparaison des variantes. |
| SUP-N2-Support_V2(1).md | SUP-N2-Support_V2.md | SupportOps | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| SUP-N2-Support_V2.md | SUP-N2-Support_V2.md | SupportOps | CANONICAL_AFTER_COMPARE | Confirmer comme source canonique après comparaison des variantes. |
| SUP-NET-VPN_Troubleshooting_V2(1).md | SUP-NET-VPN_Troubleshooting_V2.md | SupportOps | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| SUP-NET-VPN_Troubleshooting_V2(2).md | SUP-NET-VPN_Troubleshooting_V2.md | SupportOps | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| SUP-NET-VPN_Troubleshooting_V2.md | SUP-NET-VPN_Troubleshooting_V2.md | SupportOps | CANONICAL_AFTER_COMPARE | Confirmer comme source canonique après comparaison des variantes. |
| MAINT-SRV-AuditTrimestriel_V2(1).md | MAINT-SRV-AuditTrimestriel_V2.md | ServerOps / MaintOps | RENAME_CANONICAL | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| MAINT-SRV-AuditTrimestriel_V2(2).md | MAINT-SRV-AuditTrimestriel_V2.md | ServerOps / MaintOps | RENAME_CANONICAL | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| MAINT-SRV-HealthCheck_V2(1).md | MAINT-SRV-HealthCheck_V2.md | ServerOps / MaintOps | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| MAINT-SRV-HealthCheck_V2.md | MAINT-SRV-HealthCheck_V2.md | ServerOps / MaintOps | CANONICAL_AFTER_COMPARE | Confirmer comme source canonique après comparaison des variantes. |
| MAINT-SRV-PostShutdown_Electrical_V2(1).md | MAINT-SRV-PostShutdown_Electrical_V2.md | ServerOps / MaintOps | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| MAINT-SRV-PostShutdown_Electrical_V2.md | MAINT-SRV-PostShutdown_Electrical_V2.md | ServerOps / MaintOps | CANONICAL_AFTER_COMPARE | Confirmer comme source canonique après comparaison des variantes. |
| MAINT-SRV-PrintServer_PrePost_V1(1).md | MAINT-SRV-PrintServer_PrePost_V1.md | ServerOps / MaintOps | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| MAINT-SRV-PrintServer_PrePost_V1.md | MAINT-SRV-PrintServer_PrePost_V1.md | ServerOps / MaintOps | CANONICAL_AFTER_COMPARE | Confirmer comme source canonique après comparaison des variantes. |
| MAINT-WIN-Patching_CW-RMM_V3(1).md | MAINT-WIN-Patching_CW-RMM_V3.md | ServerOps / MaintOps | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| MAINT-WIN-Patching_CW-RMM_V3.md | MAINT-WIN-Patching_CW-RMM_V3.md | ServerOps / MaintOps | CANONICAL_AFTER_COMPARE | Confirmer comme source canonique après comparaison des variantes. |
| MAINT-WIN-Patching_Complet_V3(1).md | MAINT-WIN-Patching_Complet_V3.md | ServerOps / MaintOps | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| MAINT-WIN-Patching_Complet_V3.md | MAINT-WIN-Patching_Complet_V3.md | ServerOps / MaintOps | CANONICAL_AFTER_COMPARE | Confirmer comme source canonique après comparaison des variantes. |
| MAINT-WIN-PendingReboot_V2(1).md | MAINT-WIN-PendingReboot_V2.md | ServerOps / MaintOps | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| MAINT-WIN-PendingReboot_V2.md | MAINT-WIN-PendingReboot_V2.md | ServerOps / MaintOps | CANONICAL_AFTER_COMPARE | Confirmer comme source canonique après comparaison des variantes. |
| RUNBOOK__DC_PATCHING_PRECHECK(1).md | RUNBOOK__DC_PATCHING_PRECHECK.md | ServerOps / MaintOps | RENAME_CANONICAL | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| INFRA-AD-DC_Operations_V3(1).md | INFRA-AD-DC_Operations_V3.md | InfraOps / DirectoryOps | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| INFRA-AD-DC_Operations_V3.md | INFRA-AD-DC_Operations_V3.md | InfraOps / DirectoryOps | CANONICAL_AFTER_COMPARE | Confirmer comme source canonique après comparaison des variantes. |
| INFRA-AD-EntraID_Operations_V2(1).md | INFRA-AD-EntraID_Operations_V2.md | InfraOps / DirectoryOps | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| INFRA-AD-EntraID_Operations_V2.md | INFRA-AD-EntraID_Operations_V2.md | InfraOps / DirectoryOps | CANONICAL_AFTER_COMPARE | Confirmer comme source canonique après comparaison des variantes. |
| INFRA-AD-UserManagement_V2(1).md | INFRA-AD-UserManagement_V2.md | InfraOps / DirectoryOps | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| INFRA-AD-UserManagement_V2.md | INFRA-AD-UserManagement_V2.md | InfraOps / DirectoryOps | CANONICAL_AFTER_COMPARE | Confirmer comme source canonique après comparaison des variantes. |
| INFRA-M365-Exchange_Online_V2(1).md | INFRA-M365-Exchange_Online_V2.md | CloudOps / M365Ops | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| INFRA-M365-Exchange_Online_V2.md | INFRA-M365-Exchange_Online_V2.md | CloudOps / M365Ops | CANONICAL_AFTER_COMPARE | Confirmer comme source canonique après comparaison des variantes. |
| INFRA-M365-Teams_SharePoint_OneDrive_V2(1).md | INFRA-M365-Teams_SharePoint_OneDrive_V2.md | CloudOps / M365Ops | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| INFRA-M365-Teams_SharePoint_OneDrive_V2.md | INFRA-M365-Teams_SharePoint_OneDrive_V2.md | CloudOps / M365Ops | CANONICAL_AFTER_COMPARE | Confirmer comme source canonique après comparaison des variantes. |
| INFRA-M365-UserManagement_V2(1).md | INFRA-M365-UserManagement_V2.md | CloudOps / M365Ops | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| INFRA-M365-UserManagement_V2.md | INFRA-M365-UserManagement_V2.md | CloudOps / M365Ops | CANONICAL_AFTER_COMPARE | Confirmer comme source canonique après comparaison des variantes. |
| INFRA-M365-UserOnboarding_V2(1).md | INFRA-M365-UserOnboarding_V2.md | CloudOps / M365Ops | DUPLICATE_CANDIDATE | Comparer hash/contenu puis archiver sous 99_ARCHIVE_LEGACY. |
| INFRA-M365-UserOnboarding_V2.md | INFRA-M365-UserOnboarding_V2.md | CloudOps / M365Ops | CANONICAL_AFTER_COMPARE | Confirmer comme source canonique après comparaison des variantes. |
| INFRA-NET-Fortinet_Operations_V2(1).md | INFRA-NET-Fortinet_Operations_V2.md | NetworkOps / FirewallOps | RENAME_CANONICAL | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| INFRA-NET-Meraki_Operations_V2(1).md | INFRA-NET-Meraki_Operations_V2.md | NetworkOps / FirewallOps | RENAME_CANONICAL | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| INFRA-NET-NetworkDiagnostic_V2(1).md | INFRA-NET-NetworkDiagnostic_V2.md | NetworkOps / FirewallOps | RENAME_CANONICAL | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| INFRA-NET-NetworkSetup_V1(1).md | INFRA-NET-NetworkSetup_V1.md | NetworkOps / FirewallOps | RENAME_CANONICAL | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| INFRA-NET-SonicWall_Operations_V2(1).md | INFRA-NET-SonicWall_Operations_V2.md | NetworkOps / FirewallOps | RENAME_CANONICAL | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| INFRA-NET-Unifi_Mikrotik_Operations_V1(1).md | INFRA-NET-Unifi_Mikrotik_Operations_V1.md | NetworkOps / FirewallOps | RENAME_CANONICAL | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| INFRA-NET-WatchGuard_Operations_V2(1).md | INFRA-NET-WatchGuard_Operations_V2.md | NetworkOps / FirewallOps | RENAME_CANONICAL | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| INFRA-VOIP-Diagnostic_V2(1).md | INFRA-VOIP-Diagnostic_V2.md | VoIPOps | RENAME_CANONICAL | Renommer sans suffixe (1)/(2), puis créer la runbook card. |
| NOC-OPS-IncidentCommand_V2.md | NOC-OPS-IncidentCommand_V2.md | NOCOps | ENRICH | Compléter la procédure terrain avant productisation. |
| INFRA-BACKUP-Veeam_Operations_V2.md | INFRA-BACKUP-Veeam_Operations_V2.md | BackupDROps | MERGE_REFERENCE | Fusionner/référencer vers la source maître BackupDROps; éviter deux VeeamOps concurrents. |
| NOC-BACKUP-DR_Test_V2.md | NOC-BACKUP-DR_Test_V2.md | BackupDROps | ENRICH | Compléter la procédure terrain avant productisation. |
| OPR-PostIncident-Review-P1P2_V1.md | OPR-PostIncident-Review-P1P2_V1.md | SecOps / Governance | ENRICH_DRAFT | Enrichir : objectifs, déclencheurs, inputs, procédure, DoD, escalade, guardrails. |
| OPR-ClientCommunication-Cadence_V1.md | OPR-ClientCommunication-Cadence_V1.md | OPROps | ENRICH_DRAFT | Enrichir : objectifs, déclencheurs, inputs, procédure, DoD, escalade, guardrails. |
| OPR-ProblemManagement-CAPA_V1.md | OPR-ProblemManagement-CAPA_V1.md | OPROps | ENRICH_DRAFT | Enrichir : objectifs, déclencheurs, inputs, procédure, DoD, escalade, guardrails. |
| OPR-SLA-BreachPrevention_V1.md | OPR-SLA-BreachPrevention_V1.md | OPROps | ENRICH_DRAFT | Enrichir : objectifs, déclencheurs, inputs, procédure, DoD, escalade, guardrails. |
| RUNBOOK__SERVER_ROLE_DISCOVERY(2).md | RUNBOOK__SERVER_ROLE_DISCOVERY.md | UNCLASSIFIED | RENAME_CANONICAL | Renommer sans suffixe (1)/(2), puis créer la runbook card. |

---

# Bundles commerciaux cibles

| Bundle | Objectif | Familles principales |
|---|---|---|
| `BUNDLE_STARTER_TicketOps` | Triage, diagnostic de base, notes CW, support N1/N2. | TicketOps, SupportOps, Discovery, NetworkDiagnostic, HealthCheck |
| `BUNDLE_PRO_GuidedOps` | Interventions fréquentes guidées avec scripts, preuves et postchecks. | TicketOps, SupportOps, ServerOps, M365 UserOps, AD UserOps, Exchange, RDS, SQL PrePost |
| `BUNDLE_MSP_SUITE` | Suite complète MSP pour NOC, infra, cloud, réseau, backup et maintenance. | ServerOps, InfraOps, CloudOps, NetworkOps, NOCOps, BackupDROps |
| `BUNDLE_ENTERPRISE_SecOps_Governance` | Sécurité, conformité, DR, incident response, PIR, CAPA, gouvernance. | SecOps, BackupDROps, OPROps, CloudReview, IncidentResponse |

---

# Prochaines actions

1. Comparer les variantes `(1)`, `(2)` et geler la version canonique.
2. Créer une `RUNBOOK_CARD` pour chaque runbook `CANONICAL_*`.
3. Convertir les bundles existants en manifestes de références.
4. Mapper chaque runbook aux scripts, templates, checklists et Knowledge Packs.
5. Créer `GUIDEDOPS_ROUTING_MATRIX.md`, `RUNBOOK_BUNDLE_MATRIX.md` et `RISK_AND_GUARDRAIL_MATRIX.md`.

---

## Notes de maintenance

- Ce fichier est une première consolidation. Les statuts `CANONICAL_AFTER_COMPARE` et `DUPLICATE_CANDIDATE` exigent une comparaison réelle de contenu avant suppression.
- Les familles commerciales peuvent être ajustées lors de la création des bundles Starter / Pro / MSP Suite / Enterprise.
- Les fichiers issus des ZIP de scripts/templates/checklists/références seront reliés dans une phase de mapping distincte.
