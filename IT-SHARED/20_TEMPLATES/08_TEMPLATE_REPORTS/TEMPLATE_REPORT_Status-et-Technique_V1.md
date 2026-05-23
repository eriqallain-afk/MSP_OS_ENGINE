# TEMPLATE_REPORT_Status-et-Technique_V1
**Agent :** IT-ReportMaster, IT-Assistant-N3, IT-SysAdmin, IT-Commandare-OPR, It-MaintenanceMaster
**Usage :** Rapport de statut rapide + rapport technique d'intervention
**Mis à jour :** 2026-03-20

---

## PARTIE 1 — RAPPORT DE STATUT RAPIDE (Status Report)

```
═══════════════════════════════════════════════
RAPPORT DE STATUT
Client      : [NOM CLIENT]
Billet CW   : #[XXXXXX]
Période     : [YYYY-MM-DD HH:MM] → [YYYY-MM-DD HH:MM]
Technicien  : [NOM]
Type        : [Maintenance / Incident / Support / Audit]
═══════════════════════════════════════════════

STATUT GLOBAL : ✅ Complété / ⚠️ Partiel / ❌ En échec / 🔄 En cours

RÉSUMÉ
[2-3 phrases — ce qui a été fait et l'état final]

RÉSULTATS PAR ASSET
| Asset | Action effectuée | Statut | Notes |
|---|---|---|---|
| [NOM] | [Patching / Health check / Fix] | ✅ / ⚠️ / ❌ | [si applicable] |
| [NOM] | [...] | [...] | [...] |

ÉLÉMENTS EN SUSPENS
• [Item 1 — raison + action planifiée]
• [Item 2]

PROCHAINES ACTIONS RECOMMANDÉES
1. [Action — délai recommandé]
2. [Action]
═══════════════════════════════════════════════
```

---

## PARTIE 2 — RAPPORT TECHNIQUE D'INTERVENTION

```
═══════════════════════════════════════════════
RAPPORT TECHNIQUE D'INTERVENTION
Client      : [NOM CLIENT]
Billet CW   : #[XXXXXX]
Date        : [YYYY-MM-DD]
Technicien  : [NOM]
Type        : [Maintenance / Incident / Déploiement]
Durée       : [Xh Ymin]
═══════════════════════════════════════════════

1. CONTEXTE
[Description du besoin ou du problème initial]

2. ENVIRONNEMENT
Assets concernés : [Liste]
OS / Version     : [Windows Server 20XX, etc.]
Hyperviseur      : [VMware / Hyper-V / Vates / N/A]

3. ACTIONS RÉALISÉES
| # | Action | Résultat | Heure |
|---|---|---|---|
| 1 | [Action précise] | [Résultat] | [HH:MM] |
| 2 | [...] | [...] | [...] |

4. RÉSULTAT FINAL
Statut : ✅ Résolu / ⚠️ Partiel / ❌ Non résolu

[Description du résultat — services validés, état post-intervention]

5. RECOMMANDATIONS
• [Recommandation 1 — priorité]
• [Recommandation 2]

6. SUIVI REQUIS
☐ Oui → [Description + délai]
☐ Non
═══════════════════════════════════════════════
```
