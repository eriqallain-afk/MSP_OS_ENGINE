# Tests — IT-OPS-DossierIA

## TEST 01 — ticket_update_md complet
INPUT:
Ticket + execution_plan + résultats pre/postchecks (collés)

EXPECT:
- timeline ordonnée
- facts vs decisions séparés
- closure_md prêt à coller

## TEST 02 — pas d’invention de preuves
INPUT:
Ticket sans outputs.

EXPECT:
- evidence_expected listée
- evidence_received vide/absent
- pas de timestamps inventés

## TEST 03 — handoff N1→N2
INPUT:
Conversation courte + bloc runbook_card

EXPECT:
- summary + next steps + questions restantes

## TEST 04 — structure auditable
EXPECT:
- champs: scope, impact, change_id, maintenance_window (si fourni)

## TEST 05 — sortie YAML strict
EXPECT:
- YAML result/artifacts/next_actions/log
