# PATCH intents.yaml — Ajouter après la section IT-Commandare-TECH
# Insérer ce bloc dans 00_INDEX/intents.yaml

  # ── INFRA / CLOUD ────────────────────────────────────────
  - intent: it_commandare_infra
    actors: [IT-Commandare-Infra]
    playbook: IT_COMMANDARE_INFRA
    description: Lead incident infrastructure et cloud

  - intent: infra_incident
    actors: [IT-Commandare-Infra]
    playbook: IT_COMMANDARE_INFRA

  - intent: infra_alert
    actors: [IT-Commandare-Infra]
    playbook: IT_COMMANDARE_INFRA

  - intent: server_down
    actors: [IT-Commandare-Infra]
    playbook: IT_COMMANDARE_INFRA

  - intent: vm_incident
    actors: [IT-Commandare-Infra]
    playbook: IT_COMMANDARE_INFRA

  - intent: dc_incident
    actors: [IT-Commandare-Infra]
    playbook: IT_COMMANDARE_INFRA

  - intent: cloud_incident
    actors: [IT-Commandare-Infra]
    playbook: IT_COMMANDARE_INFRA

  - intent: azure_incident
    actors: [IT-Commandare-Infra]
    playbook: IT_COMMANDARE_INFRA

  - intent: m365_incident
    actors: [IT-Commandare-Infra]
    playbook: IT_COMMANDARE_INFRA

  - intent: storage_incident
    actors: [IT-Commandare-Infra]
    playbook: IT_COMMANDARE_INFRA

  - intent: dr_incident
    actors: [IT-Commandare-Infra]
    playbook: IT_COMMANDARE_INFRA

  - intent: backup_critical
    actors: [IT-Commandare-Infra]
    playbook: IT_COMMANDARE_INFRA

  - intent: network_infra
    actors: [IT-Commandare-Infra]
    playbook: IT_COMMANDARE_INFRA

  - intent: capacity_critical
    actors: [IT-Commandare-Infra]
    playbook: IT_COMMANDARE_INFRA

  - intent: resource_exhaustion
    actors: [IT-Commandare-Infra]
    playbook: IT_COMMANDARE_INFRA
