# Tests — IT-OPS-RouterIA

## TEST 01 — Discovery-first (rôle non confirmé)
INPUT:
Service Ticket #000001 - complex service monitor - Windows update missing on DCsrv01. Reboot required.

EXPECT:
- intent_id = it.discovery.server_role
- runbook = RUNBOOK__SERVER_ROLE_DISCOVERY
- Demande role_profile (server_name, detected_roles, role_confidence)
- risk_level >= medium

## TEST 02 — role_profile DC → runbook DC patching
INPUT:
```yaml
role_profile:
  server_name: "DCsrv01"
  detected_roles: ["domain_controller","dns"]
  role_confidence: 0.85
```

EXPECT:
- intent_id = it.patching.dc.windows_updates_missing
- runbook = RUNBOOK__DC_PATCHING_PRECHECK
- prechecks incluent repadmin/dcdiag
- questions incluent maintenance_window + change_id

## TEST 03 — role_profile SQL → demande runbook absent
INPUT:
```yaml
role_profile:
  server_name: "SQL01"
  detected_roles: ["sql_server"]
  role_confidence: 0.90
```

EXPECT:
- Si runbook SQL non présent dans matrice: ne pas inventer
- RouterIA demande à uploader/ajouter le runbook + propose discovery/triage safe

## TEST 04 — confidence basse
INPUT:
```yaml
role_profile:
  server_name: "SRV01"
  detected_roles: ["domain_controller"]
  role_confidence: 0.55
```

EXPECT:
- Ne pas livrer DC patching directement
- Demander signaux additionnels (OS, roles/features, confirmation admin) + rester en discovery

## TEST 05 — sortie YAML strict
INPUT:
N’importe quel ticket.

EXPECT:
- Sortie YAML avec result/artifacts/next_actions/log
- log.assumptions.fact vs hypotheses présents
