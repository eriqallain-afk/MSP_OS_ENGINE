# SUP-OPS-TicketToKB_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-Assistant-N2 | @IT-FrontLine | @IT-MaintenanceMaster | @IT-SysAdmin
**Département :** SUP | **Source :** IT MSP Intelligence Platform

---

**Agents :** IT-MaintenanceMaster | IT-SysAdmin

## Objectif

Ticket MSP -> diagnostic -> communication -> knowledge

## Déclencheur

- Dès qu’une demande correspond à cet intent dans le routage, ou exécution manuelle.

## Owner

- TEAM__IT (Lead Ops IT)

## SLA cible


Voir la policy : `50_POLICIES/ops/sla.md`

- P1 (critique) : réponse < 15 min, mitigation < 60 min
- P2 (majeur)   : réponse < 1h, mitigation < 4h
- P3 (normal)   : réponse < 4h, mitigation < 2j
- P4 (faible)   : best effort

Règle :
- Si la demande est un **incident IT/OPS**, classifier **P1–P4** (section ci-dessous) et appliquer le SLA correspondant.
- Sinon (requête non-incident), classer **P4** par défaut.

## Logging (OPS) — obligatoire
Référence : `50_POLICIES/ops/logging_schema.md`

Chaque exécution doit produire un log (au minimum) avec :
- request_id
- timestamp
- caller_actor_id
- target_actor_id
- playbook_id
- step_id
- artifacts[]
- log.decisions[]
- log.risks[]
- log.assumptions[]

Règle : le **output final** doit contenir `request_id` et un résumé des décisions/risques.

## Incident severity (P1–P4)
Référence : `50_POLICIES/ops/incident_severity.md`

- P1 : panne totale / données à risque / sécurité
- P2 : fonctionnalité clé KO / impact large
- P3 : bug contournable / impact limité
- P4 : amélioration / dette

Règle : pour tout incident, inclure `incident_severity` dans l’output final + dans le log.

## Inputs attendus
- Demande utilisateur (texte brut) + contexte (dossier/ticket).
- Intent (si déjà détecté) ou signal d’incident (si applicable).
- Contraintes : délais, périmètre, systèmes concernés.

## Outputs attendus
- Résultat final actionnable (résolution / dispatch / KB / décision).
- `request_id` + (si incident) `incident_severity`.
- Artifacts référencés (liens/IDs) + log décisions/risques/assumptions.

## Étapes (alignées `40_RUNBOOKS/playbooks.yaml`)
1. **scribe** → `IT-TicketScribe`
2. **support** → `IT-Assistant-N3`
3. **comms** → `IT-TicketScribe`
4. **kb** → `IT-KnowledgeKeeper`

Règle : si une étape échoue, enregistrer l’échec via le logging OPS et appliquer l’escalade du playbook.

## Prérequis

- Accès aux agents impliqués.
- Dossier/ID de suivi (ticket, dossier client, ou dossier IA).
- Inputs complets (fichiers / texte / consignes).

## Étapes (exécution)

### Étape 1 — scribe

- **Acteur** : `IT-TicketScribe`

- **Action** : lancer l’acteur avec les inputs de l’étape, récupérer la sortie.

- **Sortie attendue** : output conforme au `contract.yaml` de l’acteur.

- **Contrôle qualité** : vérifier champs obligatoires + cohérence (pas de champs vides critiques).


### Étape 2 — support

- **Acteur** : `IT-Assistant-N3`

- **Action** : lancer l’acteur avec les inputs de l’étape, récupérer la sortie.

- **Sortie attendue** : output conforme au `contract.yaml` de l’acteur.

- **Contrôle qualité** : vérifier champs obligatoires + cohérence (pas de champs vides critiques).


### Étape 3 — comms

- **Acteur** : `IT-TicketScribe`

- **Action** : lancer l’acteur avec les inputs de l’étape, récupérer la sortie.

- **Sortie attendue** : output conforme au `contract.yaml` de l’acteur.

- **Contrôle qualité** : vérifier champs obligatoires + cohérence (pas de champs vides critiques).


### Étape 4 — kb

- **Acteur** : `IT-KnowledgeKeeper`

- **Action** : lancer l’acteur avec les inputs de l’étape, récupérer la sortie.

- **Sortie attendue** : output conforme au `contract.yaml` de l’acteur.

- **Contrôle qualité** : vérifier champs obligatoires + cohérence (pas de champs vides critiques).


## Critères de Done

- Toutes les étapes exécutées sans erreur.
- Output final archivé (dossier/ticket mis à jour).
- Si applicable : décision/score final communiqué.

## Exceptions & escalade

- Output incohérent / incomplet → relancer l’étape 1 fois avec inputs clarifiés.
- Blocage persistant → escalader au owner d’équipe + `HUB-AgentMO2-DeputyOrchestrator`.

## Notes / Doc legacy

- Une version legacy existe : `40_RUNBOOKS/LEGACY_MD/01_it_msp_ticket_to_kb.md`
