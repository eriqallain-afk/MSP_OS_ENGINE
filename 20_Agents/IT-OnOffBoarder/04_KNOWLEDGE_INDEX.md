# IT-OnOffBoarder — Knowledge Index v1.0

## Sources de connaissance actives

| Source | Chemin | Usage |
|---|---|---|
| RUNBOOK__SERVER_ROLE_DISCOVERY | `IT-SHARED/10_RUNBOOKS/RUNBOOKS_MD/RUNBOOK__SERVER_ROLE_DISCOVERY.md` | Phase 1 — identifier rôles serveurs |
| RUNBOOK__DC_PATCHING_PRECHECK | `IT-SHARED/10_RUNBOOKS/RUNBOOKS_MD/RUNBOOK__DC_PATCHING_PRECHECK.md` | Phase 1 — DC présent |
| INFRA-AD-GPO_Management_V1 | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-GPO_Management_V1.md` | Phase 1 — audit GPO |
| INFRA-AD-FolderSecurity_V1 | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-FolderSecurity_V1.md` | Phase 1 — audit partages NTFS/AGDLP |
| INFRA-SRV-NewVM_Deployment_V1 | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-NewVM_Deployment_V1.md` | Phase 4 — déploiement VM si requis |
| MASTER_DISPATCH_INDEX_V2 | `IT-SHARED/00_INDEX/MASTER_DISPATCH_INDEX_V2.yaml` | Routing intents vers runbooks |
| GUARDRAILS__IT_AGENTS_MASTER | `IT-SHARED/GUARDRAILS__IT_AGENTS_MASTER.md` | Règles absolues transversales |

## Agents collaborateurs

| Agent | Quand l'appeler |
|---|---|
| @IT-ClientDocMaster | Après Phase 1 — créer toutes les fiches Hudu |
| @IT-ReportMaster | Phase 3 (rapport client mise à niveau) + Phase 6 (rapport clôture) |
| @IT-TicketScribe | Clôture CW — notes et discussions |
| @IT-SecurityMaster | Faille critique découverte en Phase 1 |
| @IT-BackupDRMaster | Backup absent ou non testé |
| @IT-NetworkMaster | Réseau complexe (multi-sites, SD-WAN) |
| @IT-CloudMaster | M365 complexe (hybride, Entra issues) |
| @IT-VoIPMaster | VoIP complexe |
| @IT-UrgenceMaster | Incident actif pendant onboarding |
