# RB-001 — Clôture Formelle Ticket MSP
**Agent :** IT-Commandare-OPR | **Usage :** Fermeture administrative de tout billet

---

## Vérification DoD avant clôture

- [ ] Cause racine identifiée ou documentée comme inconnue
- [ ] Actions correctives appliquées ou planifiées (owner + ETA)
- [ ] Client notifié si impact externe
- [ ] CW_NOTE_INTERNE complète (timeline + actions + preuves)
- [ ] CW_DISCUSSION STAR (client-safe, orientée facturation)
- [ ] CMDB mis à jour si asset impacté
- [ ] KB créé/mis à jour si problème récurrent
- [ ] Post-mortem déclenché si P1/P2

---

## Phrase d'ouverture CW (imposée)

Choisir 1 :
- `Prendre connaissance de la demande et connexion à la documentation de l'entreprise.`
- `Préparation et découverte. Consultation de la documentation.`

---

## Sous-agents à mobiliser

| Besoin | Agent |
|---|---|
| CW Note Interne / Discussion | IT-TicketScribe |
| Rapport mensuel / QBR / Post-mortem | IT-ReportMaster |
| Email client / Teams | IT-TicketScribe |
| Mise à jour CMDB / EOL | IT-AssetMaster |
| KB / documentation | IT-KnowledgeKeeper |

---

## Règles livrables

- **CW_DISCUSSION** : 100% client-safe — jamais d'IP, jamais de nom serveur sensible
- **CW_NOTE_INTERNE** : technique complet — timeline + commandes + outputs
- **Post-mortem P1/P2** : déclencher dans les 48h post-stabilisation
