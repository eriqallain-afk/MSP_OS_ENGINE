# BUNDLE_KP_TicketScribe_V2
**Agent :** @IT-TicketScribe
**Version :** 2.0 | **Date :** 2026-05-15
**Type :** KnowledgePack GPT — Fallback GitHub
**Contenu :** Templates CW enrichis (Note interne, Discussion STAR), emails client, notices Teams, briefs Hudu/KB, meeting notes, validation qualité, règles P1/P3, escalades.

---

## SECTION 1 — RÈGLES FONDAMENTALES

### Règles absolues (TOUTES les communications)
```
JAMAIS dans les livrables externes :
- Mots de passe / tokens / clés API
- Adresses IP internes
- Noms de serveurs internes
- CVE exploitables
- Commandes PowerShell dangereuses
- Données d'un autre client

TOUJOURS :
- Première phrase CW : "Prise en connaissance de la demande et consultation de la documentation du client."
- Minimum 4 puces sous TRAVAUX EFFECTUÉS dans les Discussions CW
- Numéro de billet présent ou [À CONFIRMER]
- Durée d'intervention documentée
- Utiliser [PLACEHOLDER] pour toute variable sensible
```

### Différences P1 vs P3 en documentation
```
BILLET P1 — CRITIQUE :
✔ Timeline HH:MM obligatoire (chaque action)
✔ Notifications envoyées documentées (qui, quand)
✔ Impact utilisateurs chiffré
✔ Cause racine documentée
✔ Actions préventives pour éviter récurrence
✔ Post-mortem si durée > 2h
✔ Email client obligatoire dans les 4h post-résolution

BILLET P2 — HAUTE :
✔ Timeline recommandée
✔ Cause probable documentée
✔ Actions correctives listées
✔ Email client si impact multiple utilisateurs

BILLET P3 — NORMALE :
✔ Description claire de l'action effectuée
✔ Résolution confirmée par l'utilisateur
✔ Email client si demandé

BILLET P4 — FAIBLE :
✔ Note de service minimale
✔ Confirmation livraison
```

---

## SECTION 2 — TEMPLATES CW NOTE INTERNE

### Note Interne — Standard (P2/P3)
```
Prise en connaissance de la demande et consultation de la documentation du client.

## Contexte
Billet : #[XXXXXX] | Client : [NOM CLIENT] | Priorité : P[X]
Description initiale : [Résumé du problème rapporté]

## Timeline
- HH:MM — Prise en charge du billet
- HH:MM — [Action ou diagnostic effectué]
- HH:MM — [Résultat observé]
- HH:MM — Résolution confirmée / escalade effectuée

## Actions effectuées
- [Action 1 — outil/méthode utilisé — résultat]
- [Action 2 — outil/méthode utilisé — résultat]
- [Action 3 — outil/méthode utilisé — résultat]

## Cause identifiée
[Cause racine ou hypothèse principale]

## Résolution
[Résolu / En cours / Escaladé / À planifier]
Méthode : [Description technique de la résolution]

## Validation
- [ ] Fonctionnalité testée et confirmée
- [ ] Utilisateur notifié
- [ ] Aucune régression détectée

## Suivi requis
[Action de suivi ou N/A]
```

### Note Interne — Incident P1 (critique)
```
Prise en connaissance de la demande et consultation de la documentation du client.

## INCIDENT P1 — [TYPE INCIDENT]
Billet : #[XXXXXX] | Client : [NOM CLIENT] | Priorité : P1
Déclaré à : [YYYY-MM-DD HH:MM]
Impact : [Nombre utilisateurs / services affectés]

## CHRONOLOGIE DÉTAILLÉE
- [HH:MM] Alerte reçue — [Source : RMM / Utilisateur / Monitoring]
- [HH:MM] Prise en charge par [NOM TECH]
- [HH:MM] Diagnostic initial — [Observation]
- [HH:MM] [Action prise — résultat]
- [HH:MM] Notification client envoyée
- [HH:MM] [Autre action — résultat]
- [HH:MM] Service rétabli / Escalade → [NOM ÉQUIPE]
- [HH:MM] Validation confirmée

## COMMANDES EXÉCUTÉES
```[Commandes ou scripts utilisés — SANS credentials ni IPs sensibles]```

## CAUSE RACINE
[Cause racine identifiée ou en cours d'investigation]

## RÉSOLUTION APPLIQUÉE
[Description précise de la solution appliquée]

## IMPACT TOTAL
- Durée d'interruption : [HH:MM]
- Services affectés : [Liste]
- Utilisateurs impactés : [Nombre approximatif]

## ACTIONS PRÉVENTIVES
- [ ] [Action 1 pour éviter récurrence]
- [ ] [Action 2]

## SUIVI POST-INCIDENT
- [ ] Email post-mortem client (dans 24h)
- [ ] KB à créer : [Oui/Non]
- [ ] CAPA déclenchée : [Oui/Non]
```

### Note Interne — Maintenance planifiée
```
Prise en connaissance de la demande et consultation de la documentation du client.

## Maintenance planifiée — [TYPE]
Billet : #[XXXXXX] | Client : [NOM CLIENT]
Fenêtre : [YYYY-MM-DD HH:MM à HH:MM]
Approuvée par : [NOM APPROBATEUR]

## Pré-checks
- [ ] Backup vérifié — dernier succès : [Date/Heure]
- [ ] Snapshot créé : [Nom du snapshot]
- [ ] Mode maintenance RMM activé
- [ ] Notification client envoyée

## Travaux effectués
- HH:MM — [Action 1]
- HH:MM — [Action 2]
- HH:MM — [Action 3]

## Post-checks
- [ ] Services opérationnels
- [ ] Aucune erreur event log
- [ ] Fonctionnalité métier testée
- [ ] Monitoring vert
- [ ] Snapshot supprimé : [Oui/N.A.]
- [ ] Mode maintenance RMM désactivé

## Résultat
[Succès / Partiel — détails / Échec — plan B activé]

Durée réelle : [HH:MM] | Durée planifiée : [HH:MM]
```

---

## SECTION 3 — TEMPLATES CW DISCUSSION (client-safe)

### Discussion STAR — Standard
```
Prise en connaissance de la demande et consultation de la documentation du client.

### SITUATION
[Description simple du problème rapporté par le client]

### TÂCHE
[Ce qui devait être résolu ou accompli]

### ACTIONS
- Vérification de l'environnement et de la configuration existante
- [Action principale effectuée en langage client]
- [Action secondaire si applicable]
- [Tests et validations effectués]
- Confirmation du bon fonctionnement auprès de l'utilisateur

### RÉSULTAT
[État final en langage non technique — service fonctionnel, problème résolu, etc.]

Durée : [X]h[XX]min
```

### Discussion STAR — Incident réseau/serveur
```
Prise en connaissance de la demande et consultation de la documentation du client.

### SITUATION
Interruption de service signalée affectant [description impact sans détails techniques].

### TÂCHE
Rétablir le service dans les meilleurs délais et identifier la cause pour éviter la récurrence.

### ACTIONS
- Prise en charge immédiate et évaluation de la situation
- Mise en place d'une solution temporaire pour minimiser l'impact
- Identification et correction de la cause du problème
- Tests de validation pour s'assurer de la stabilité du service
- Surveillance renforcée pendant [durée] suite à la résolution

### RÉSULTAT
Le service [NOM SERVICE] est pleinement fonctionnel depuis [HH:MM]. Aucun impact résiduel détecté.

Durée d'intervention : [X]h[XX]min | Service rétabli : [YYYY-MM-DD HH:MM]
```

### Discussion STAR — Sécurité (client-safe)
```
Prise en connaissance de la demande et consultation de la documentation du client.

### SITUATION
Alertes de sécurité détectées nécessitant une intervention immédiate.

### TÂCHE
Contenir l'incident, sécuriser les accès et évaluer l'impact potentiel.

### ACTIONS
- Analyse immédiate des alertes et évaluation du risque
- Mesures de confinement mises en place pour protéger l'environnement
- Revue et nettoyage des accès compromis ou suspects
- Vérification de l'intégrité des systèmes affectés
- Renforcement des mesures de sécurité en prévention

### RÉSULTAT
L'environnement est sécurisé. [Détails client-safe sur l'état final]. Un suivi préventif est planifié.

Durée : [X]h[XX]min
```

### Discussion STAR — Demande de service (P3/P4)
```
Prise en connaissance de la demande et consultation de la documentation du client.

### SITUATION
Demande de [type de service] pour [utilisateur/groupe] reçue.

### TÂCHE
[Description de ce qui a été demandé]

### ACTIONS
- Validation de la demande et des autorisations requises
- [Action réalisée 1]
- [Action réalisée 2]
- Confirmation de la livraison auprès du demandeur

### RÉSULTAT
[Demande complétée — description du résultat final]

Durée : [X]h[XX]min
```

---

## SECTION 4 — EMAILS CLIENT

### Email — Incident résolu
```
Objet : [RÉSOLU] [Description courte] — Réf. #[XXXXXX]

Bonjour [Prénom],

Nous vous confirmons que le problème signalé concernant [description fonctionnelle simple] a été résolu.

TRAVAUX EFFECTUÉS
- [Action 1 en langage client]
- [Action 2 en langage client]
- [Validation effectuée]

ÉTAT ACTUEL
Le service [NOM] est pleinement fonctionnel depuis le [Date] à [HH:MM].

Si vous constatez tout autre problème, n'hésitez pas à nous contacter en référençant le billet #[XXXXXX].

Cordialement,
[Prénom Nom]
Support technique — [NOM MSP]
[Téléphone]
```

### Email — Incident en cours
```
Objet : [EN COURS] [Description courte] — Réf. #[XXXXXX]

Bonjour [Prénom],

Nous vous contactons au sujet du billet #[XXXXXX] ouvert le [Date].

ÉTAT ACTUEL
Notre équipe est activement en train de résoudre [description du problème en langage client].

CE QUI EST EN COURS
- [Action en cours 1]
- [Action en cours 2]

PROCHAIN POINT DE SUIVI
Nous vous donnerons une mise à jour d'ici [HH:MM] ou dès que la situation sera résolue.

Si la situation se détériore entre-temps, contactez-nous immédiatement.

Cordialement,
[Prénom Nom]
Support technique — [NOM MSP]
[Téléphone]
```

### Email — Escalade / délai supplémentaire
```
Objet : [MISE À JOUR] [Description courte] — Réf. #[XXXXXX]

Bonjour [Prénom],

Nous souhaitons vous tenir informé(e) de l'avancement du billet #[XXXXXX].

SITUATION ACTUELLE
[Description honnête et client-safe de la situation]

CE QUI A ÉTÉ FAIT
- [Action 1]
- [Action 2]

PROCHAIN STATUT
Nous visons une résolution d'ici [Date/Heure]. Nous reviendrons vers vous avec une mise à jour avant [Heure].

Nous nous excusons pour les inconvénients causés et vous remercions de votre patience.

Cordialement,
[Prénom Nom]
Support technique — [NOM MSP]
[Téléphone]
```

---

## SECTION 5 — NOTICES TEAMS

### Notice Teams — Panne en cours
```
🔴 ALERTE — [SERVICE] INDISPONIBLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Client   : [NOM CLIENT]
Billet   : #[XXXXXX]
Statut   : 🔴 En cours d'investigation
Début    : [YYYY-MM-DD HH:MM]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Impact : [Description impact utilisateurs — sans détails techniques]
Notre équipe est activement sur le dossier.

Prochain statut : [HH:MM]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@[Tech assigné] | [Date HH:MM]
```

### Notice Teams — Service rétabli
```
✅ RÉSOLU — [SERVICE] RESTAURÉ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Client   : [NOM CLIENT]
Billet   : #[XXXXXX]
Statut   : ✅ Service rétabli
Résolu   : [YYYY-MM-DD HH:MM]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Le service [NOM] est pleinement fonctionnel.
Durée d'interruption : [HH:MM]

Rapport complet disponible sur demande.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@[Tech assigné] | [Date HH:MM]
```

### Notice Teams — Escalade
```
⚠️ ESCALADE — [SERVICE] — Niveau élevé
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Client   : [NOM CLIENT]
Billet   : #[XXXXXX]
Statut   : ⚠️ Escaladé → [ÉQUIPE/TECHNICIEN]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Situation : [Description client-safe]
Escaladé à : [NOM/ÉQUIPE] — [HH:MM]
Impact estimé : [Description]

Prochain point de contact : [HH:MM]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@[Chef d'équipe] @[Tech] | [Date HH:MM]
```

### Notice Teams — Maintenance planifiée
```
🔧 MAINTENANCE PLANIFIÉE — [SERVICE]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Client   : [NOM CLIENT]
Billet   : #[XXXXXX]
Fenêtre  : [YYYY-MM-DD HH:MM → HH:MM]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Travaux prévus : [Description client-safe]
Impact attendu : [Interruption / Aucun impact / Impact minimal]

Veuillez planifier vos activités en conséquence.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@[Tech assigné] | [Date HH:MM]
```

---

## SECTION 6 — BRIEF HUDU (pour IT-ClientDocMaster)

### Template Brief Hudu — Mise à jour environnement
```
BRIEF HUDU — [NOM CLIENT] — [YYYY-MM-DD]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TYPE DE MISE À JOUR : [Nouveau composant / Modification / Correction]

SECTION HUDU CONCERNÉE
→ Article : [Nom de l'article ou procédure à mettre à jour]
→ Asset : [Si applicable — Serveur/Poste/Appareil]

CHANGEMENT EFFECTUÉ
Avant : [État précédent]
Après : [Nouvel état]

DÉTAILS TECHNIQUES (pour l'article Hudu)
- [Information 1 à documenter]
- [Information 2 à documenter]
- [Configuration mise à jour]

IMPACT SUR LA DOCUMENTATION EXISTANTE
→ [Articles liés à vérifier/mettre à jour]

BILLET CW DE RÉFÉRENCE : #[XXXXXX]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Technicien : [NOM] | Date : [YYYY-MM-DD]
```

---

## SECTION 7 — BRIEF KB (pour IT-KnowledgeKeeper)

### Template Brief KB — Nouvelle procédure
```
BRIEF KB — NOUVELLE PROCÉDURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TITRE SUGGÉRÉ : [Titre de la procédure]
CATÉGORIE : [AD / M365 / Réseau / Sécurité / Backup / RDS / Poste / Autre]
NIVEAU : [N1 / N2 / N3]
FRÉQUENCE D'USAGE ESTIMÉE : [Quotidien / Hebdo / Mensuel / Ponctuel]

DÉCLENCHEUR
→ Situation qui nécessite cette procédure : [Description]

PRÉREQUIS
- [Accès requis]
- [Outil requis]
- [Information préalable]

ÉTAPES PRINCIPALES
1. [Étape 1]
2. [Étape 2]
3. [Étape 3]
4. [Validation]

PIÈGES À ÉVITER
- [Erreur commune 1]
- [Erreur commune 2]

ESCALADE SI
→ [Condition d'escalade]

BILLET CW ORIGINE : #[XXXXXX]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Proposé par : [NOM] | Date : [YYYY-MM-DD]
```

---

## SECTION 8 — MEETING NOTES (réunions techniques)

### Template Meeting Notes
```
RÉUNION TECHNIQUE — [SUJET]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Date     : [YYYY-MM-DD HH:MM]
Client   : [NOM CLIENT]
Billet   : #[XXXXXX] (si applicable)
Présents : [Noms et rôles]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## POINTS DISCUTÉS
1. [Point 1]
   → Décision : [Décision prise]
2. [Point 2]
   → Décision : [Décision prise]
3. [Point 3]
   → Décision : [En attente / À confirmer par [Qui]]

## ACTIONS À PRENDRE
| # | Action | Responsable | Échéance |
|---|---|---|---|
| 1 | [Action] | [Nom] | [Date] |
| 2 | [Action] | [Nom] | [Date] |

## RISQUES IDENTIFIÉS
- [Risque 1 — mitigation proposée]
- [Risque 2 — mitigation proposée]

## PROCHAINE RÉUNION
Date : [YYYY-MM-DD] | Ordre du jour : [Points]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Notes prises par : [NOM] | Approuvées par : [À CONFIRMER]
```

---

## SECTION 9 — VALIDATION QUALITÉ AVANT LIVRAISON

### Checklist qualité avant envoi
```
VALIDATION AVANT LIVRAISON — CW NOTE INTERNE
[ ] Première phrase = "Prise en connaissance de la demande et consultation de la documentation du client."
[ ] Numéro de billet présent
[ ] Timeline documentée (HH:MM pour chaque action)
[ ] Cause identifiée (ou marquée [À CONFIRMER])
[ ] Actions détaillées avec résultats
[ ] Post-checks effectués et documentés
[ ] Suivi requis documenté ou N/A
[ ] Aucune information sensible (IP, MDP, tokens)

VALIDATION AVANT LIVRAISON — CW DISCUSSION
[ ] Première phrase correcte
[ ] Minimum 4 puces sous TRAVAUX EFFECTUÉS
[ ] Zéro IP interne
[ ] Zéro jargon technique excessif
[ ] Résultat final clair pour le client
[ ] Durée documentée

VALIDATION AVANT LIVRAISON — EMAIL CLIENT
[ ] Objet avec statut [RÉSOLU/EN COURS] et numéro de billet
[ ] Ton professionnel et bienveillant
[ ] Explication fonctionnelle (pas technique)
[ ] Prochaine étape mentionnée si applicable
[ ] Coordonnées de contact incluses
[ ] Signature complète

VALIDATION AVANT LIVRAISON — NOTICE TEAMS
[ ] Statut visuel clair (✅/⚠️/🔴)
[ ] Client et numéro de billet présents
[ ] Description impact compréhensible par tous
[ ] Prochain point de contact mentionné
[ ] Technicien responsable identifié
```

---

## SECTION 10 — ESCALADES

| Situation | Destination | Délai | Template |
|---|---|---|---|
| Incident sécurité dans la documentation | IT-SecurityMaster | Immédiat | Note P1 + Notice Teams Escalade |
| Problème technique non documenté | IT-SysAdmin ou IT-Assistant-N3 | Selon priorité | Brief KB + Note Interne |
| Mise à jour doc environnement client | IT-ClientDocMaster | Dans la journée | Brief Hudu |
| Post-mortem incident P1 | Chef d'équipe + IT-TicketOpsAI | Dans 24h | Email client + Note P1 complète |
| Création nouvelle KB | IT-KnowledgeKeeper | Dans la semaine | Brief KB |

---

*BUNDLE_KP_TicketScribe_V2 — Version 2.0 — 2026-05-15 — IT MSP Intelligence Platform*
