# Guide d'utilisation — @IT-OPS-QAMaster (v1.0)
> **Pour :** Techniciens N1/N2/N3 MSP + Équipe OPS
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-OPS-QAMaster ?

**IT-OPS-QAMaster est l'agent de qualité interne de la plateforme MSP Intelligence AI.**

Il ne travaille pas sur les clients — il travaille sur les **agents eux-mêmes**.
Son rôle : détecter les erreurs, analyser les causes, proposer des correctifs, et valider les nouveaux agents avant activation.

| Outil | Ce qu'il gère | Exemple |
|---|---|---|
| Tout autre agent | Le problème client (tickets, infra, compliance…) | « IT-FrontLine a résolu le ticket #88432 » |
| **QAMaster** | **La qualité de l'agent qui a traité le problème** | « IT-FrontLine a mis une IP dans le rapport client — incident loggué, correctif en attente EA » |

> **Tout technicien peut logguer un incident.** Tu n'as pas besoin d'être dans l'équipe OPS pour utiliser `/log`.
> **Tous les correctifs sont validés par EA avant application.** QAMaster propose — EA décide.

---

## Quand l'utiliser ?

- Un agent a produit un output incorrect, dangereux ou de mauvaise qualité → `/log`
- Un agent n'a pas escaladé un P1 qui aurait dû l'être → `/log`
- Un agent a inclus des IPs, credentials ou CVE dans un livrable client → `/log` en CRITICAL
- Tu veux comprendre pourquoi un incident s'est produit → `/analyse`
- Tu veux voir si un même problème revient souvent → `/patterns`
- Un nouvel agent est prêt — valider avant activation → `/review-agent`
- Tu veux l'état de santé global de la plateforme → `/dashboard`

---

## Les commandes principales

### `/log [agent] [description]` — Logguer un incident

La commande la plus utilisée. Accessible à **tout technicien** — pas besoin d'être QA pour signaler un problème.

**Usage :**
```
/log IT-FrontLine — A inclus une IP interne (10.0.0.15) dans le rapport client du ticket #88432
/log IT-AssistantN2 — N'a pas escaladé vers IT-UrgenceMaster malgré un P1 déclaré dans le ticket
/log IT-ComplianceMaster — A inventé un chiffre de conformité sans source citée (ticket #91203)
/log IT-ReportMaster — Template CW_NOTE_INTERNE utilisé à la place de CW_DISCUSSION pour un client
```

**Ce que tu obtiens :**
Un fichier incident structuré YAML à sauvegarder dans `00_QA/incidents/[agent-id]/` :

```
incident_id: INC-20260518-001
date: 2026-05-18
severity: CRITICAL | HIGH | MEDIUM | LOW
type: WRONG_OUTPUT | MISSED_ESCALADE | WRONG_ROUTING | SECURITY_BYPASS | ...
description: [Ce qui s'est passé]
expected: [Ce qui aurait dû se passer]
actual: [Ce qui s'est réellement passé]
impact: [Conséquence]
status: OPEN
```

**Niveaux de sévérité :**
| Sévérité | Quand l'utiliser | Exemple |
|---|---|---|
| `CRITICAL` | Impact client direct — sécurité ou données | IP interne dans rapport client, credentials exposés |
| `HIGH` | Escalade manquée, mauvais diagnostic dangereux | P1 non escaladé, action destructive sans validation |
| `MEDIUM` | Output incorrect sans impact immédiat | Mauvais template, mauvaise audience |
| `LOW` | Qualité sous-optimale, amélioration possible | Format approximatif, commande incomplète |

---

### `/analyse [incident-id]` — Analyser un incident

Après avoir loggué un incident (ou pour analyser un incident existant), cette commande identifie la cause racine et propose un correctif.

**Usage :**
```
/analyse INC-20260518-001
```

**Ce que tu obtiens :**
```
CAUSE RACINE IDENTIFIÉE
Catégorie  : PROMPT | RUNBOOK_MANQUANT | GUARDRAIL_ABSENT | ESCALADE_MANQUANTE | ...
Description : [Pourquoi l'agent a eu ce comportement]

FACTEURS CONTRIBUTIFS
• [Facteur 1]
• [Facteur 2]

CORRECTIF PROPOSÉ
Type    : PROMPT_UPDATE | NEW_GUARDRAIL | NEW_RUNBOOK | ...
Fichier : [Chemin du fichier à modifier]
Effort  : Faible | Moyen | Élevé
```

---

### `/fix [incident-id]` — Générer un correctif

Produit le fichier de correctif structuré à soumettre à EA pour validation.

**Usage :**
```
/fix INC-20260518-001
```

**Ce que tu obtiens :**
Un fichier `FIX-YYYYMMDD-NNN.md` à déposer dans `00_QA/fixes/pending/` :

```yaml
fix_id: FIX-20260518-001
status: PENDING_EA           ← toujours PENDING_EA — jamais modifier avant EA approval

change_proposed: |
  AVANT :
  [Extrait exact du texte actuel]

  APRÈS :
  [Texte proposé en remplacement]

rationale: [Pourquoi ce changement résout le problème]
risk: [Risque potentiel du changement]
testing: [Comment vérifier que le correctif fonctionne]
```

> Aucun fichier d'agent n'est touché tant que `ea_validation.approved: true` n'est pas confirmé par EA.

---

### `/patterns` — Détecter les récurrences systémiques

Analyse tous les incidents ouverts (ou des 30 derniers jours) pour identifier les problèmes qui reviennent.

**Usage :**
```
/patterns
```

**Ce que tu obtiens :**
```
PATTERNS DÉTECTÉS
🔴 Pattern 1 — [Description]
   Agents affectés : [Liste]
   Incidents liés  : [INC-001, INC-003, INC-007]
   Fréquence       : [N fois en X jours]
   Cause commune   : [Description]
   Fix suggéré     : [Type de correctif]

AGENTS LES PLUS IMPACTÉS (30j)
| Agent | Incidents | Sévérité dominante | Tendance |
...

RECOMMANDATION PRIORITAIRE
[Correctif systémique qui résoudrait le plus d'incidents]
```

---

### `/review-agent [agent-id]` — Revue pre-activation

Checklist exhaustive avant d'activer un nouvel agent. **Obligatoire pour tout nouvel agent.**

**Usage :**
```
/review-agent IT-ComplianceMaster
/review-agent IT-OnOffBoarder
```

**Ce que tu obtiens :**
Une checklist complète couvrant :
- Fichiers requis (agent.yaml, prompt.md, contract.yaml, 04_KNOWLEDGE_INDEX.md)
- Contrôles agent.yaml : format ID, version, status, description, intents, escalades, guardrails
- Contrôles prompt.md : header, RÔLE, COMMANDES, GARDES-FOUS, CONFIDENTIALITÉ, ESCALADES, chemins GitHub
- Sécurité : guardrails IP/credentials, confidentialité instructions, auto_activation
- Intégration : enregistré dans agents_index.yaml, FACTORY_MANIFEST_IT.yaml, CLAUDE.md — pas de doublon

Verdict final : **APPROUVÉ / REFUSÉ / CONDITIONNEL**

> La revue est soumise à EA. L'activation finale reste la prérogative d'EA — jamais automatique.

---

### `/dashboard` — Tableau de bord qualité plateforme

Vue d'ensemble de l'état de santé de tous les agents.

**Usage :**
```
/dashboard
```

**Ce que tu obtiens :**
```
PLATEFORME
Agents actifs       : [N/32]
Score qualité global: [N/100]

INCIDENTS (30 DERNIERS JOURS)
CRITICAL : [N] | HIGH : [N] | MEDIUM : [N] | LOW : [N]
Total    : [N] | Résolus : [N] | Ouverts : [N]

CORRECTIFS
En attente EA  : [N]
Appliqués (30j): [N]

AGENTS LES PLUS STABLES (0 incident 30j)
[Liste]

AGENTS NÉCESSITANT ATTENTION
[Agent] — [N incidents] — [Pattern dominant]
```

---

### `/rapport` — Rapport QA mensuel pour EA

Rapport complet mensuel sur l'état de la plateforme — destiné à EA.

**Usage :**
```
/rapport
```

**Ce que tu obtiens :**
7 sections : résumé exécutif, détail incidents du mois, correctifs appliqués (AVANT/APRÈS), correctifs en attente EA, patterns détectés, agents revus, plan d'action mois prochain.

---

## Flux de travail recommandé

### Signaler et corriger un incident

```
1. Tu observes un comportement problématique d'un agent
        ↓
2. /log [agent] [description précise + ticket# si applicable]
   Choisir la sévérité : CRITICAL si données client exposées, sinon HIGH/MEDIUM/LOW
        ↓
3. Sauvegarder le fichier dans 00_QA/incidents/[agent-id]/[YYYY-MM-DD]_[type].md
        ↓
4. /analyse [INC-id]
   Identifier la cause racine
        ↓
5. /fix [INC-id]
   Générer le correctif structuré
        ↓
6. Sauvegarder dans 00_QA/fixes/pending/FIX-[YYYYMMDD]-[NNN].md
        ↓
7. EA valide → correctif déplacé dans 00_QA/fixes/applied/
   Agent cible mis à jour (version incrémentée)
```

### Validation pre-activation d'un nouvel agent

```
1. Nouvel agent déposé dans 99_STAGING/
        ↓
2. /review-agent [agent-id]
   Checklist exhaustive — aucun raccourci
        ↓
3. Si CONDITIONNEL → corrections demandées à l'auteur
   Si REFUSÉ → liste des points bloquants communiquée
   Si APPROUVÉ → soumis à EA pour activation
        ↓
4. EA active l'agent → status: staging → active dans agent.yaml
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| Correctifs JAMAIS appliqués sans validation EA | Modification d'agent = changement de comportement pour tous les techniciens |
| Incidents = faits documentés, pas d'accusations | QA est objectif — décrire ce qui s'est passé, pas juger qui |
| auto_activation: false pour tout agent | Aucun agent n'est activé sans décision explicite d'EA |
| Ne jamais modifier les fichiers d'agents directement | QAMaster propose seulement — EA décide et applique |
| Tout technicien peut logguer un incident | Baisser la barrière = plus d'incidents capturés = meilleure qualité |

---

## Questions fréquentes

**Q : Je suis technicien N1 — est-ce que je peux utiliser /log ?**
Oui, absolument. `/log` est la commande accessible à tous. Si tu as observé quelque chose d'incorrect dans l'output d'un agent, tu dois le signaler. La qualité de la plateforme dépend de ces signalements.

**Q : Quelle différence entre un incident CRITICAL et HIGH ?**
CRITICAL = impact client direct, données exposées ou sécurité compromise (ex: IP interne dans rapport client). HIGH = problème grave mais sans impact client immédiat (ex: escalade P1 manquée, mauvais diagnostic). En cas de doute, utiliser HIGH — EA peut requalifier.

**Q : Que se passe-t-il avec un correctif en PENDING_EA depuis longtemps ?**
Le `/dashboard` et le `/rapport` mensuel le signalent. EA est informé. Si le correctif est bloquant, le signaler explicitement dans le rapport mensuel avec son impact estimé.

**Q : /review-agent — peut-il être fait avant que l'agent soit dans 99_STAGING ?**
Non. L'agent doit avoir au minimum agent.yaml et prompt.md pour que la revue soit significative. Faire la revue sur un agent incomplet donnerait un verdict REFUSÉ automatique sur des lacunes qui n'existent pas encore.

**Q : Est-ce que QAMaster peut directement améliorer un prompt.md qu'il juge défaillant ?**
Non. QAMaster *propose* la modification via `/fix` — il génère le diff AVANT/APRÈS. C'est EA qui applique. Cette séparation est intentionnelle : elle garantit qu'aucun agent ne se modifie lui-même sans supervision humaine.

---

*GUIDE_UTILISATION — IT-OPS-QAMaster v1.0 — MSP Intelligence AI — 2026-05-18*
