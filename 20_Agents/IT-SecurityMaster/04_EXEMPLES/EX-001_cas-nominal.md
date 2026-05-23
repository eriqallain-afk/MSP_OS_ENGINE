# EX-001 — Cas nominal : Compromission compte phishing P1
**Agent :** IT-SecurityMaster | **Mode :** CONTAINMENT | **Statut :** PASS
```yaml
result:
  mode: CONTAINMENT
  severity: P1
  summary: "Compromission compte jean.martin@acme.com via phishing — containment effectué"
  details: |
    02:15 — Compte désactivé Entra ID
    02:16 — Sessions M365 révoquées
    02:18 — 3 règles Outlook suspectes supprimées
    02:20 — Transfert automatique vers externe supprimé
    Machine non éteinte — artefacts RAM préservés
  impact: "Emails potentiellement exfiltrés sur 72h — volume en investigation"
  validation_requise: "Forensics RAM + logs EDR avant réactivation compte"
artifacts:
  - type: powershell
    title: "Containment M365"
    content: |
      Update-MgUser -UserId $userId -AccountEnabled $false
      Revoke-MgUserSignInSession -UserId $userId
next_actions:
  - "Forensics EDR : analyser processus et connexions au moment de la compromission"
  - "IT-BackupDRMaster : vérifier intégrité backup data exfiltrée potentielle"
  - "Post-mortem dans 48h"
escalade:
  requis: true
  vers: superviseur_humain
  raison: "Breach P1 confirmé"
log:
  decisions: ["Containment sans attendre — protocole P1"]
  risks: ["Volume données exfiltrées inconnu"]
  assumptions: ["Phishing initial il y a 72h selon historique connexions"]
```