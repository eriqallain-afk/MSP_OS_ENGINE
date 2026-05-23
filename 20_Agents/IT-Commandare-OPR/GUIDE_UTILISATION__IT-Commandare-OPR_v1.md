# Guide d'utilisation — @IT-Commandare-OPR (v1.0)
> **Pour :** Techniciens MSP, coordinateurs opérations, responsables de la documentation
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-Commandare-OPR ?

**IT-Commandare-OPR est le commandant des opérations administratives et documentaires MSP.**

Il est le scribe officiel, le gestionnaire des communications clients, le producteur des rapports et le gardien de la clôture formelle. Chaque incident résolu, chaque maintenance terminée, chaque changement appliqué — Commandare-OPR s'assure que tout est documenté, communiqué et formellement clos avant de fermer le ticket.

| Domaine | Ce que gère Commandare-OPR |
|---|---|
| Documentation | Notes CW internes, discussions facturables, post-mortems, KB, SOPs |
| Communications | Emails clients, annonces Teams, rapports de statut |
| Rapports | Rapports mensuels, QBR, rapports post-incident, tableaux SLA |
| Assets / CMDB | Inventaire, cycle de vie, suivi EOL, audits |
| Clôture formelle | DoD (Definition of Done), change management, gouvernance |

**Commandare-OPR ne gère PAS :**
- Diagnostics techniques → IT-Commandare-TECH ou IT-Commandare-Infra
- Triage d'alertes actives → IT-Commandare-NOC
- Interventions live → IT-MaintenanceMaster ou IT-AssistanTI_N3

---

## Quand l'utiliser ?

- L'incident est stabilisé et tu dois générer la Note CW + Discussion facturable
- Tu dois rédiger un email client post-incident ou post-maintenance
- Tu dois créer un post-mortem structuré après un P1/P2
- Tu dois préparer un rapport mensuel ou QBR
- Tu veux vérifier le DoD avant de fermer formellement un billet
- Un asset CMDB doit être mis à jour après une intervention

---

## Les commandes principales

### `/close` — Clôture CW formelle avec DoD

La commande principale. Déclenche le menu de clôture — Commandare-OPR vérifie d'abord le DoD avant de générer les livrables.

**Usage :**
```
/close
```

**Ce que tu obtiens (menu — STOP en attente de ton choix) :**
```
Clôture — Billet #[XXXXX]
[1] CW Note Interne
[2] CW Discussion (facturable client)
[3] Email client
[4] Notice Teams
[A] Tout (1+2+3+4)

Que veux-tu générer ?
```

> Important : Commandare-OPR attend ton choix avant de générer quoi que ce soit.

---

### Note CW Interne — exemple complet

Après avoir choisi `[1]`, tu fournis le contexte et Commandare-OPR génère la note.

**Usage :**
```
/close [1]
Billet #77801
Client : Otto Inc
Type : Remplacement switch core — maintenance planifiée
Début : 22:00 | Fin : 23:45 | Durée : 1h45m
Actions :
  - 22:00 — Backup config ancien switch exportée
  - 22:15 — Déconnexion liens trunk progressivement
  - 22:30 — Installation switch neuf — migration VLAN
  - 23:15 — Tests de connectivité — tous les VLANs OK
  - 23:45 — Validation finale — réseau 100% opérationnel
Résultat : Résolu — aucun impact sur les services pendant la maintenance
```

**Ce que tu obtiens :**
```
Prise de connaissance de la demande et consultation de la documentation du client.

Billet #77801 — Otto Inc — Remplacement switch core
Début : 22:00 | Fin : 23:45 | Durée : 1h45m

22:00 — Backup configuration ancien switch exportée → OK
22:15 — Déconnexion progressive des liens trunk → Procédure complétée
22:30 — Installation switch neuf et migration VLAN → Configuré
23:15 — Tests de connectivité sur tous les VLANs → Tous opérationnels
23:45 — Validation finale réseau → 100% opérationnel

Statut : ✅ Résolu
```

---

### Discussion CW facturable — exemple complet

Après avoir choisi `[2]`, pour le livrable visible sur la facture client.

**Ce que tu obtiens :**
```
Préparation et découverte.
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

INTERVENTION: Remplacement équipement réseau core
DATE: 2026-05-17 | TECHNICIEN: [Initiales]

TRAVAUX EFFECTUÉS:
• Prise en charge de la maintenance planifiée et coordination des équipes
• Préparation et migration de la configuration vers le nouvel équipement
• Validation du retour à la normale sur l'ensemble des segments réseau
• Documentation des changements et fermeture administrative

RÉSULTAT:
• Services réseau pleinement opérationnels
• Aucune interruption de service constatée pendant la maintenance
```

> Règles absolues : JAMAIS d'IP, commandes, noms de serveurs dans la Discussion. Minimum 4 puces. Toujours commencer par la phrase d'ouverture imposée.

---

### Post-mortem P1/P2

Pour les incidents majeurs, Commandare-OPR produit le post-mortem structuré.

**Usage :**
```
/close [postmortem]
Billet #77401 — Otto Transport — Panne réseau P1
Début : 14:32 | Fin : 16:45 | Durée : 2h13m
Cause probable : Défaillance équipement FAI — modem câble
Cause confirmée : Confirmé par FAI le 2026-05-18 — remplacement modem
Impact : 67 utilisateurs sans accès 2h13m
Actions correctives :
  - Lien LTE de secours activé à 14:47
  - Remplacement modem planifié 2026-05-18
Actions préventives :
  - Test automatique lien LTE à valider
  - Monitoring dédié lien principal à ajouter
```

**Ce que tu obtiens :**
- Post-mortem complet avec `cause_probable` vs `cause_confirmée` séparées
- Actions correctives avec owner + ETA
- Actions préventives + runbook_improvements suggérés
- Prêt à partager avec le client et à archiver

---

### Email client

**Usage :**
```
/close [3]
Contexte : Maintenance réseau terminée avec succès. Client à notifier.
Billet #77801 — Otto Inc
Résultat : Réseau 100% opérationnel — aucun impact service
```

**Ce que tu obtiens :**
- Email professionnel prêt à envoyer
- ZÉRO IP, ZÉRO commande technique
- Langage client — non technique, factuel

---

### Vérification DoD avant clôture

Avant de confirmer la fermeture d'un ticket, Commandare-OPR vérifie le DoD.

**Usage :**
```
/close [DoD check]
Billet #77501 — Otto Inc
```

**Ce que tu obtiens (checklist) :**
```
DoD — Billet #77501
[ ] Cause racine identifiée ou documentée avec hypothèses
[ ] Actions correctives appliquées ou planifiées avec owner + ETA
[ ] Client notifié si impact externe
[ ] CW_NOTE_INTERNE complète
[ ] CW_DISCUSSION STAR complète
[ ] CMDB mis à jour si asset impacté
[ ] KB créé si problème récurrent
[ ] Post-mortem déclenché si P1/P2
```

Items manquants → `next_actions` avec owner et deadline.

---

## Flux de travail recommandé

### Clôture post-incident standard

```
1. Incident stabilisé — services confirmés opérationnels
        ↓
2. /close [DoD check] — vérifier que rien ne manque
        ↓
3. /close [1] → Note CW Interne (timeline complète)
        ↓
4. /close [2] → Discussion CW facturable
        ↓
5. /close [3] ou [4] si client à notifier
        ↓
6. Vérifier CMDB si asset impacté → IT-AssetMaster si besoin
        ↓
7. Déclencher KB si problème récurrent → IT-KnowledgeKeeper
        ↓
8. Post-mortem si P1/P2 → /close [postmortem]
```

### Rapport mensuel client

```
1. En fin de mois — rassembler tous les billets du client
        ↓
2. /rapport mensuel [client] [période]
   → Demander à IT-ReportMaster de produire le rapport
        ↓
3. Review Commandare-OPR : SLA respectés, incidents notables, actions préventives
        ↓
4. Envoi client ou préparation QBR
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| DoD vérifié avant toute clôture | Un billet fermé sans cause racine documentée = perte de connaissance |
| Post-mortem obligatoire pour P1/P2 | Traçabilité et apprentissage organisationnel |
| Phrase d'ouverture CW imposée | Cohérence sur toutes les factures — sans exception |
| JAMAIS d'IP dans les livrables clients | Discussion, Email, Teams — toujours génériques |
| JAMAIS de credentials dans aucun livrable | Même en Note Interne — Passportal uniquement |
| trace_id = même UUID que l'incident source | Traçabilité de bout en bout |

---

## Questions fréquentes

**Q : Quelle différence entre Commandare-OPR et IT-TicketScribe ?**
Commandare-OPR coordonne la clôture formelle et les opérations administratives globales. IT-TicketScribe est un sous-agent mobilisé par OPR pour la rédaction précise des notes et discussions CW. Commandare-OPR peut déléguer à TicketScribe pour des livrables CW complexes.

**Q : La phrase d'ouverture CW est vraiment obligatoire à chaque fois ?**
Oui — c'est une règle codée dans le prompt, sans exception. Deux options : `Prendre connaissance de la demande et connexion à la documentation de l'entreprise.` ou `Préparation et découverte. Consultation de la documentation.` L'une ou l'autre, toujours en premier.

**Q : Qui met à jour la CMDB après une intervention ?**
Commandare-OPR le signale dans le DoD. IT-AssetMaster effectue la mise à jour effective. Commandare-OPR peut déléguer directement à IT-AssetMaster via `next_actions`.

**Q : Peut-on fermer un billet sans post-mortem pour un P1 ?**
Non — c'est un garde-fou non négociable. Tout P1/P2 doit avoir un post-mortem avant clôture formelle. C'est une condition du DoD.

**Q : La Discussion CW peut-elle mentionner le nom d'un serveur ?**
Non. La Discussion est visible sur la facture client. ZÉRO IP, ZÉRO nom de serveur, ZÉRO commande technique. Descriptions génériques uniquement : "équipement réseau core", "serveur de base de données", etc.

---

*GUIDE_UTILISATION — IT-Commandare-OPR v1.0 — MSP Intelligence AI — 2026-05-18*
