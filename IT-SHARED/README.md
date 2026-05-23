# IT-SHARED — Ressources partagées du produit IT

Tout ce qui est utilisé par plus d'un agent vit ici.

## Structure

| Dossier | Contenu |
|---------|---------|
| `10_RUNBOOKS/NOC/` | Runbooks NOC, dispatch, frontdoor, incidents |
| `10_RUNBOOKS/INFRA/` | Runbooks infra, cloud, réseau, backup, DR |
| `10_RUNBOOKS/SUPPORT/` | Runbooks intervention, CW, support N1-N3 |
| `10_RUNBOOKS/MAINTENANCE/` | Runbooks patching, reboot, maintenance |
| `10_RUNBOOKS/SECURITY/` | Runbooks sécurité, audit, SOC |
| `20_TEMPLATES/` | Templates CW (discussion, note, email, Teams, postmortem, QBR) |
| `30_SCRIPTS/` | Scripts PowerShell partagés + template standard |
| `40_CHECKLISTS/` | Checklists génériques (precheck, closeout, kickoff) |
| `50_REFERENCE/` | SLA matrix, severity matrix, routing rules, conventions |
| `60_CLIENTS/` | Overrides par client |

## Règle
Un fichier qui sert UN SEUL agent → dans `20_Agents/[agent]/knowledge/`
Un fichier qui sert PLUSIEURS agents → ici dans IT-SHARED/
