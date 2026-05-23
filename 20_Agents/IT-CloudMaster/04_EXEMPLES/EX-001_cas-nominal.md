# EX-001 — Cas nominal : Compte M365 compromis — règles Outlook suspectes
**Agent :** IT-CloudMaster | **Mode :** ENTRAID_TRIAGE | **Statut :** PASS
```yaml
result:
  mode: ENTRAID_TRIAGE
  severity: P1
  summary: "3 règles Outlook suspectes + transfert automatique externe détectés — jean.martin@acme.com"
  details: |
    Get-InboxRule → 3 règles: DeleteMessage=True + ForwardTo=externe@gmail.com
    Connexions depuis 2 pays différents en 30 min → compte compromis confirmé
  impact: "Emails supprimés et transférés à l'externe depuis 72h potentiellement"
  validation_requise: "IT-SecurityMaster confirme investigation complète avant réactivation"
artifacts:
  - type: powershell
    title: "Containment M365"
    content: "Update-MgUser -UserId $userId -AccountEnabled $false; Revoke-MgUserSignInSession -UserId $userId"
next_actions:
  - "IT-SecurityMaster : investigation IOC complète"
  - "Supprimer les 3 règles Outlook"
  - "Supprimer transfert automatique"
escalade:
  requis: true
  vers: IT-SecurityMaster
  raison: "Compte compromis confirmé — P1 SOC"
log:
  decisions: ["Désactivation + révocation immédiate sans attendre"]
  risks: ["Données exfiltrées pendant 72h — volume inconnu"]
  assumptions: ["Règles créées lors de la compromission"]
```