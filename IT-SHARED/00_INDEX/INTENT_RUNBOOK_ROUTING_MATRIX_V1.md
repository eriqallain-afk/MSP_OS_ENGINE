# INTENT_RUNBOOK_ROUTING_MATRIX_V1

Status: DRAFT
Scope: intent-to-runbook mapping shared by all agents.
Owner: IT-SHARED
Purpose: select exact GitHub runbook_path from ticket title, alert text, source, asset type and severity.

## Rules
- This file maps intents to runbooks, not agents.
- Multiple agents may consume the same intent result and call the same runbook.
- IT-OPS-RouterIA must load this file before selecting a runbook.
- If confidence is low, use fallback triage instead of guessing.

## Schema
intent_id | signals | exclusions | runbook_path | confidence_min | fallback_path | notes

## INTENTS
_TBD_
