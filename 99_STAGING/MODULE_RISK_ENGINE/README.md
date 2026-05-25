# MODULE_RISK_ENGINE — Risk Intelligence Engine

**Statut :** Staging — Phase 1 (Brief & Analyse) complétée  
**Validation EA requise** avant passage en Phase 2

---

## Ce que ce module fait

Couche stratégique au-dessus des agents IT opérationnels. Synthétise la connaissance
accumulée par les agents existants en un **verdict structuré** : scores de risque,
détections d'anomalies, plan d'action 30/60/90.

## Les 5 agents à produire

| Agent | Rôle | Priorité |
|---|---|---|
| `IT-RiskScorer` | Orchestrateur — agrège les scores partiels | P1 |
| `IT-GovernanceAnalyst` | Évalue les contrôles de gouvernance | P1 |
| `IT-ContinuityValidator` | Valide la couverture backup/DR/SPOF | P1 |
| `IT-ExposureMapper` | Cartographie la surface d'exposition | P2 |
| `IT-ExecutiveReporter` | Génère le rapport exécutif livrable | P1 |

## Output type

```
RISK INDEX GLOBAL : 58/100  [HIGH]
├── Lifecycle Risk       : 70/100
├── Governance Integrity : 45/100
├── Continuity Assurance : 65/100
├── Exposure Surface     : 60/100
└── Operational Drift    : 89/100

DÉTECTIONS (7)
  CRITIQUES : Tier-0 x2, RDP exposé WAN
  ÉLEVÉES   : Backup non validé, OS EOL x2, EDR absent
  MOYENNES  : Patch drift, Monitoring lacunaire
```

## Fichiers de référence

- `FACTORY_MANIFEST_MODULE_RISK_ENGINE.yaml` — source de vérité
- `SCORING_MODEL_V1.yaml` — modèle mathématique complet

## Phases de production

```
[x] Phase 1 — Brief & Analyse     (manifest + scoring model)
[ ] Phase 2 — Conception           (profil complet des 5 agents)
[ ] Phase 3 — Production           (prompts opérationnels)
[ ] Phase 4 — Validation staging
[ ] Phase 5 — Activation EA
```

## Note extraction

Si un prospect demande le rapport de risque sans vouloir le produit IT complet,
le module s'extrait dans `eriqallain-afk/msp_os_engine` comme produit autonome.
