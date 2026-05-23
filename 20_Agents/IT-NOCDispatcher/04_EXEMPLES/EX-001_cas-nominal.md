# EX-001 — Cas nominal : Alerte RMM Disk Critical SRV-FILE01
**Agent :** IT-NOCDispatcher | **Mode :** DISPATCH | **Statut :** PASS

---

## INPUT
```yaml
mode: DISPATCH
ticket_id: "alerte-RMM-20260322-1447"
alerte: "DISK_CRITICAL — SRV-FILE01 — C: 3% libre"
client: "Acme Corp"
```

## OUTPUT
```yaml
result:
  mode: DISPATCH
  ticket_id: "alerte-RMM-20260322-1447"
  severity: P2
  domaine: infra
  owner_assigne: "@IT-MaintenanceMaster"
  summary: "Espace disque critique sur SRV-FILE01 — C: à 3% libre. Serveur de fichiers principal Acme Corp. Impact potentiel sur 45 utilisateurs."
  actions_immediates:
    - "Créer billet CW P2 — Acme Corp — DISK_CRITICAL SRV-FILE01"
    - "Assigner à IT-MaintenanceMaster pour health check et nettoyage"
    - "Activer mode maintenance RMM sur SRV-FILE01"
  sla:
    reponse_avant: "15:17"
    resolution_avant: "23:47"
  communication_client:
    requise: false
    message: "P2 — notification à 30 min si non résolu"

next_actions:
  - "IT-MaintenanceMaster : health check + nettoyage dossiers temporaires"
  - "Si < 1% libre atteint avant intervention : escalade P1 → IT-Commandare-Infra"
  - "Post-résolution : ajuster seuil alerte RMM à 15% (attention) / 10% (critique)"

log:
  decisions:
    - "P2 retenu : service dégradé possible mais pas encore de panne — workaround possible"
    - "IT-MaintenanceMaster assigné : nettoyage disque dans son scope"
  risks:
    - "Si nettoyage insuffisant → escalade infra pour extension volume"
  assumptions:
    - "SRV-FILE01 = serveur de fichiers principal selon Hudu"
```
