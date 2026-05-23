# @IT — Déclaration d'Indépendance Produit

**Version :** 3.0 | **Date :** 2026-02-18

## Statut : AUTONOME ✅

Le produit `@IT MSP Intelligence Platform` est **entièrement indépendant** de la FACTORY et du HUB global.

---

## Équipe OPS Dédiée : TEAM__IT_OPS

| Agent | Rôle | Fichier |
|---|---|---|
| `@IT-OPS-RouterIA` | Routage + sélection acteur/playbook | `agents/OPS-RouterIA/` |
| `@IT-OPS-PlaybookRunner` | Exécution des playbooks IT | `agents/OPS-PlaybookRunner/` |
| `@IT-OPS-DossierIA` | Archivage et packaging livrables | `agents/OPS-DossierIA/` |

---

## Structure Complète du Produit

```
PRODUCTS/IT/
├── 00_INDEX/
│   ├── product.yaml          ← Descripteur produit (standalone: true)
│   ├── agents.yaml           ← Liste agents
│   ├── agents_index.yaml     ← Index détaillé avec intents
│   ├── intents.yaml          ← REGISTRE COMPLET des intents IT ← NEW
│   └── KNOWLEDGE_INDEX.yaml  ← Index de connaissance           ← NEW
├── 80_MACHINES/
│   └── hub_routing.yaml      ← Table de routage IT (fallback interne) ← FIXED
├── agents/
│   ├── OPS-RouterIA/         ← Routeur IT autonome             ← ENRICHI
│   ├── OPS-PlaybookRunner/   ← Runner IT autonome              ← ENRICHI
│   ├── OPS-DossierIA/        ← Archiviste IT autonome          ← ENRICHI
│   └── IT-*/                 ← 21 agents métier IT
├── playbooks/
│   └── playbooks.yaml        ← 9 playbooks IT
└── IT_SHARED/
    └── Knowledge/             ← Base de connaissance partagée
```

---

## Règles d'Indépendance

1. **Fallback interne** : `IT-NOCDispatcher` — jamais `HUB-AgentMO-MasterOrchestrator`
2. **team_id OPS** : `TEAM__IT` — jamais `TEAM__OPS` global
3. **forbidden_actors** définis dans chaque contrat OPS
4. **intents.yaml** : autorité locale — jamais référence au registre global FACTORY
5. **KNOWLEDGE_INDEX.yaml** : index local — chargement autonome

---

## Intents couverts : 65+

Voir `00_INDEX/intents.yaml` pour le registre complet.

## Playbooks disponibles : 9

| ID | Description |
|---|---|
| IT_MSP_TICKET_TO_KB | Ticket → KB |
| IT_INCIDENT_TRIAGE | Incident complet |
| IT_COMMANDARE_NOC | Triage NOC |
| IT_COMMANDARE_TECH | RCA + remediation |
| IT_COMMANDARE_OPR | Gouvernance |
| IT_CHANGE_EXEC | Change management |
| IT_NOC_DISPATCH | Dispatch NOC |
| IT_MSP_LIVE_ASSIST | Live assistance |
| IT_CW_INTERVENTION_LIVE_CLOSE | Intervention + KB |
| IT_URGENCE_P1P2 | Urgence + intervention |
