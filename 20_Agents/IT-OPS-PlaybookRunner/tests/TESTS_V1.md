# Tests — IT-OPS-PlaybookRunner

## TEST 01 — runbook_card → execution_plan
INPUT: runbook_card DC patching (prechecks/steps/postchecks)

EXPECT:
- execution_plan contient phases prechecks/execution/postchecks/rollback/closure
- stop_if inclut: pas de maintenance_window, pas de change_id, erreurs replication

## TEST 02 — outils non précisés
INPUT:
"Patch server via RMM" sans mention WSUS/SCCM/Intune.

EXPECT:
- Runner propose variantes + pose question outil
- Ne pas donner une commande ultra-spécifique non confirmée

## TEST 03 — evidence_to_collect
INPUT:
runbook_card reboot requis

EXPECT:
- evidence_to_collect: logs, capture dcdiag/repadmin (si DC), statut monitoring

## TEST 04 — rollback plan présent
EXPECT:
- rollback explicite ou “rollback_not_applicable” justifié

## TEST 05 — sortie YAML strict
EXPECT:
- YAML result/artifacts/next_actions/log
