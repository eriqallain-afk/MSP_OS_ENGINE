# IT-ProjetSOW — Knowledge Index

> **STATUT AGENT : STAGING** — Activation future par EA.

## Sources de connaissance actives

| # | Fichier | Chemin | Statut |
|---|---|---|---|
| 1 | Schema Opportunité | `ventes/SCHEMA_OPPORTUNITY.yaml` | PRET |
| 2 | Access Control ventes | `ventes/ACCESS_CONTROL.md` | PRET |
| 3 | Guardrails IT Agents | `IT-SHARED/10_RUNBOOKS/00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md` | Existant |
| 4 | Runbook Menu Contextuel | `IT-SHARED/RUNBOOK_MENU_CONTEXTUEL_V4.md` | Existant |
| 5 | Template Bundle CW Close | `IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW/TEMPLATE_BUNDLE_CW_CLOSE.md` | Existant |

## Sources à créer avant activation

| # | Fichier | Chemin cible | Responsable |
|---|---|---|---|
| 6 | Template SOW client | `IT-SHARED/20_TEMPLATES/SOW_TEMPLATE.md` | EA / IT-ProjetSOW |
| 7 | Guide estimation MSP | `IT-SHARED/20_TEMPLATES/ESTIMATION_GUIDE.md` | EA |
| 8 | Email soumission SOW | `IT-SHARED/20_TEMPLATES/EMAIL_SOUMISSION_SOW.md` | EA |

## Intégrations runtime

- Lecture : `ventes/opportunities/{OPP-id}.yaml`
- Écriture : `ventes/estimations/{OPP-id}_SOW.md`
- Écriture : `ventes/approved/{OPP-id}_approved.yaml`
- Handoff entrant : IT-OnOffBoarder (lacunes d'onboarding → opportunités projet)
- Escalade sortante : IT-SysAdmin, IT-SecurityMaster, IT-CloudMaster, IT-NetworkMaster, IT-BackupDRMaster, IT-ReportMaster
