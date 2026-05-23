# INTENT_RUNBOOK_MATRIX_V1 - IT-SHARED

Source of truth: mapping intent to runbook/playbook for IT-OPS-RouterIA.
Format: Markdown + YAML block.

```yaml
version: 1
owner: IT-SHARED

defaults:
  discovery_intent_id: it.discovery.server_role

  role_profile_schema:
    required_fields: [server_name, detected_roles, role_confidence]
    roles_vocab:
      - domain_controller
      - sql_server
      - iis
      - file_server
      - hyperv
      - rds
      - dns
      - dhcp

roles_to_intents:
  domain_controller: it.patching.dc.windows_updates_missing

matrix:
  - intent_id: it.discovery.server_role
    title: "Server role discovery"
    match_hints:
      - "server"
      - "srv"
      - "hostname"
      - "role"
      - "unknown role"
      - "triage"
      - "precheck"
      - "RMM detected"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/RUNBOOKS_MD/RUNBOOK__SERVER_ROLE_DISCOVERY.md"
    playbook_id: "IT_PB__ROLE_DISCOVERY
    risk_level: low
    required_inputs:
      - server_name
      - access_method
    outputs:
      - role_profile
      - suggested_next_intent_id

  - intent_id: it.patching.dc.windows_updates_missing
    title: "DC patching - Windows Updates missing and reboot required"
    match_hints:
      - "Windows update missing"
      - "updates missing"
      - "patch missing"
      - "reboot required"
      - "domain controller"
      - "RMM"
      - "WSUS"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/RUNBOOKS_MD/RUNBOK__DC_PATCHING_PRECHECK.md"
    playbook_id: "IT_PB__DC_PATCHING"
    risk_level: high
    required_inputs:
      - server_name
      - maintenance_window
      - change_id
    outputs:
      - runbook_card
      - next_questions

  - intent_id: it.backup.status.validation
    title: "NOC backup status validation"
    match_hints:
      - "Valider statut des sauvegardes"
      - "backup status"
      - "Backup Monitor"
      - "Backup Radar"
      - "No Result"
      - "Veeam"
      - "Datto"
      - "Keepit"
      - "SaaS Backup"
    runbook_doc: "IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Validation_Statut_Sauvegardes_V1.md"
    playbook_id: "IT_PB__BACKUP_STATUS_VALIDATION"
    risk_level: medium
    required_inputs:
      - backup_product
      - backup_job_name
      - alert_status
    outputs:
      - runbook_card
      - next_questions
```
