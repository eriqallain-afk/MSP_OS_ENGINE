# EX-001 — Cas nominal : Clôture ticket patching mensuel P3
**Agent :** IT-Commandare-OPR | **Statut :** PASS

## INPUT
```yaml
mode: CLOSE
ticket_id: "T1601200"
type: "Maintenance patching mensuel — 4 serveurs"
client: "Acme Corp"
```

## OUTPUT
```yaml
result:
  opr_domain: close
  dod_checklist:
    cause_racine: "N/A — maintenance planifiée"
    actions_correctives: "N/A"
    client_notifie: false
    note_interne: true
    discussion_star: true
    cmdb_mis_a_jour: false
    kb_requis: false
    postmortem: false
  livrables:
    cw_note_interne: |
      Prendre connaissance de la demande et connexion à la documentation de l'entreprise.
      Billet T1601200 — Patching mensuel Acme Corp — 4 serveurs.
      Fenêtre 22:00-00:30. Serveurs traités : SRV-DC01, SRV-FILE01, SRV-APP01, SRV-RDS01.
      Tous les services opérationnels validés à 00:28.
    cw_discussion_star: |
      Application des mises à jour mensuelles planifiées sur les serveurs.
      Tous les services sont opérationnels et les performances sont normales.
    email_client: null
    teams: "Fin de maintenance confirmée à 00:30 — tous les services opérationnels."

next_actions:
  - "IT-TicketScribe : coller les livrables dans CW"
  - "Fermer le billet T1601200"
```
