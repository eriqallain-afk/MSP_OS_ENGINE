# RUNBOOK — IT MSP: Dispatch ConnectWise (Type/Sub-type) + NOC Cells (OPS Ready)
Generated: 2026-01-06

## Objectif
Standardiser le dispatch des tickets ConnectWise en se basant sur les champs :
- Type
- Sub-type
- Source (Client vs Outil: Auvik/RMM/BackupRadar/etc.)
et sur votre organisation :
- Support = Tech 1/2/3 (T1/T2/T3)
- Départements Admin (Network/Infra/Cloud/Security/VoIP/Backup/DevOps)
- NOC = Monitoring / Maintenance / Backup (pour les alertes outillées)

⚠️ Ce runbook est **documentaire** : il ne modifie pas ConnectWise et ne change pas le routage OPS.
Il complète le playbook existant `IT_MSP_TICKET_TO_KB`.

## Rattachement (existant)
- Playbook existant: `IT_MSP_TICKET_TO_KB` (scribe → support → comms → kb)
- Routage HUB: intents IT → default_playbook_id = `IT_MSP_TICKET_TO_KB`

## Étape 2 (à insérer conceptuellement entre Scribe et Support)
### Décision 1 — Source
- Si Source = outil (Auvik/RMM/Monitoring) => NOC / Monitoring (triage) puis dispatch admin si nécessaire
- Si Source = BackupRadar => NOC / Backup + BackupDR
- Si Source = maintenance planifiée => NOC / Maintenance
- Sinon => Support (T1/T2/T3) owner initial

### Décision 2 — Type
- Incident:
  - owner initial = Support (T1/T2/T3), sauf si Source=outil => NOC d’abord
- Demande de service:
  - user-facing => Support
  - modification de services => Admin concerné (Infra/Cloud/Network/VoIP/Security/Backup) avec Support en assistance si besoin
- Task:
  - exécution interne (assigné à l’équipe qui exécute)
- Rencontre/meeting:
  - orchestration + CR (Support/Orchestrator) selon votre pratique

### Décision 3 — Sub-type (table de dispatch)
Voir `dispatch_matrix.yaml`.

## Collaboration bidirectionnelle (Support ↔ Admin)
- Un Admin peut créer une tâche “Support Assist” (exécution terrain, tests user-side, collecte)
- Un Tech Support escalade vers Admin si action admin requise / complexité élevée

## Templates de notes ConnectWise
Voir `cw_note_templates.md`.