# Example — RouterIA response (DC patching)

## Input (user message)
Service Ticket #000001 - complex servcice monitor - Windows update missing on DCsrv01
EA4AI GPT creator agency
Le service monitor RMM a détecté que des mise à jour sont manquantres sur DCsrv01 et qu'un redémarrage est nécessaire

## Expected RouterIA structured output (YAML)
```yaml
result:
  route:
    intent_id: it.patching.dc.windows_updates_missing
    playbook_id: IT_PB__DC_PATCHING
    actor_id: IT-OPS-PlaybookRunner
    confidence: 0.86
    reasons:
      - "Présence de 'Windows update missing' + 'reboot required'"
      - "Cible identifiée comme Domain Controller: 'DCsrv01'"
  runbook_card:
    title: "DC patching — Windows Updates manquantes + reboot requis"
    risk_level: high
    required_inputs:
      - server_name: "DCsrv01"
      - maintenance_window: "<ask>"
      - change_id: "<ask>"
    prechecks:
      - "Mettre le monitoring RMM en maintenance mode"
      - "Vérifier backup/rollback disponible"
      - "dcdiag /v"
      - "repadmin /replsummary"
      - "repadmin /showrepl"
      - "Vérifier logs: System, Directory Service, DNS"
      - "Vérifier services AD DS/DNS/DFSR (si applicable)"
      - "Vérifier espace disque"
    patching_steps:
      - "Installer updates via méthode standard (WSUS/SCCM/RMM/Windows Update)"
      - "Surveiller erreurs/codes + ressources (CPU/RAM/Disk)"
      - "Redémarrer DCsrv01 pendant la fenêtre de maintenance"
    postchecks:
      - "Attendre stabilisation 5–15 min"
      - "dcdiag (essentiels)"
      - "repadmin /replsummary + /showrepl"
      - "Valider SYSVOL/DFSR (si applicable) + DNS"
      - "Sortir monitoring de maintenance, vérifier retour au vert"
    closure_notes:
      - "Documenter heures, KBs, résultats pre/post-checks dans le ticket"
  next_questions:
    - "Quelle est la fenêtre de maintenance autorisée (début/fin, timezone)?"
    - "As-tu un Change ID / CAB approval associé au ticket #000001?"
    - "DCsrv01 est-il seul DC ou y en a-t-il d’autres (multi-site)?"
```
