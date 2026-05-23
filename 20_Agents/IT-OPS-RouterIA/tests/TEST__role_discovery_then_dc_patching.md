# TEST — Role discovery puis runbook spécifique (DC patching)

## Input 1 (ticket initial)
Service Ticket #000001 - complex service monitor - Windows update missing on DCsrv01
Le service monitor RMM a détecté que des mises à jour sont manquantes sur DCsrv01 et qu'un redémarrage est nécessaire.

### Expected RouterIA output 1
- RouterIA **ne doit pas** supposer que "DCsrv01" est forcément un DC.
- RouterIA doit livrer **le runbook standard de découverte**:
  - intent_id: `it.discovery.server_role`
  - runbook_doc: `RUNBOOK__SERVER_ROLE_DISCOVERY`
  - demander à l’utilisateur de coller le `role_profile` (JSON/YAML)

---

## Input 2 (retour utilisateur — role_profile)
```json
{
  "role_profile": {
    "server_name": "DCsrv01",
    "os_caption": "Microsoft Windows Server 2022 Standard",
    "os_version": "10.0.20348",
    "domain_joined": true,
    "detected_roles": ["domain_controller","dns"],
    "role_confidence": 0.85,
    "key_signals": ["Service NTDS present","Service DNS present","Feature AD-Domain-Services installed"],
    "notes": ""
  }
}
```

### Expected RouterIA output 2
- RouterIA doit router vers:
  - intent_id: `it.patching.dc.windows_updates_missing`
  - runbook_doc: `RUNBOOK__DC_PATCHING_PRECHECK`
- RouterIA doit inclure:
  - `prechecks` (dcdiag/repadmin + monitoring maintenance mode)
  - `next_questions` (maintenance_window, change_id, autres DCs)
