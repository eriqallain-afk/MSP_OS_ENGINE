# RUNBOOK — IT_CW_INTERVENTION_LIVE_CLOSE
_Généré le 2026-01-24T17:16:43Z_

## 1) Objectif

Piloter une **intervention MSP ConnectWise** du début à la fin :
- **MODE=LIVE** : journaliser l’intervention en temps réel (actions + statuts + preuves) et guider via checklists.
- **MODE=CLOSE** : produire les livrables ConnectWise de clôture :
  - **CW NOTE INTERNE** (complet, interne)
  - **CW DISCUSSION** (client-safe, facturable)
  - **EMAIL CLIENT** (optionnel, si demandé)
- **KB** : si pertinent, pousser une synthèse vers la base de connaissance (via `IT-KnowledgeKeeper`).
éférence complète : `90_KNOWLEDGE/IT/CW_TEMPLATE_LIBRARY__INTERVENTION_COPILOT.md`

### NOC
- /template NOC.UPDATE_SERVER
- /template NOC.REBOOT
- /template NOC.BACKUP_FAIL

### SOC
- /template SOC.EDR_ALERT
- /template SOC.FW_RULE_CHANGE
- /template SOC.FW_UNBLOCK

### SUPPORT
- /template SUPPORT.M365_USER_ADD
- /template SUPPORT.EXCHANGE_TASK
- /template SUPPORT.IDENTITY_MFA

### OTHER
- /template OTHER.GENERAL
---

## 2) Déclencheur

Lancer ce runbook quand :
- Un ticket ConnectWise arrive et nécessite une intervention (NOC/SOC/Support/Autre).
- Un tech veut **suivre** ses actions en direct avec un journal propre + preuves.
- On veut standardiser la **clôture** (notes internes + discussion client-safe).

Commande de clôture :
- `/close` ou texte : **FIN** / **CLOSE TICKET**

---

## 3) Scope

### Inclus
- Incidents NOC (infra, serveurs, réseau, monitoring).
- Alertes SOC (sécurité, triage, containment, IOC).
- Support (utilisateur, applicatif, configuration).

### Exclus
- Changements majeurs (projets) sans ticket d’intervention.
- Actions non autorisées (ex : hors fenêtre sans approbation).

---

## 4) Owner / Acteurs

- **Owner (suggestion)** : Lead MSP / Service Delivery Manager
- **Exécutant** : Technicien assigné au ticket (NOC/SOC/Support)
- **Copilote live** : `@IT-SysAdmin`
- **Closeout CW** : `@IT-TicketScribe`
- **KB (si applicable)** : `IT-KnowledgeKeeper`

---

## 5) SLA cible (suggestion)

- **P1** : 15 min prise en charge / 60 min 1er plan d’action
- **P2** : 30 min prise en charge / 4 h plan d’action
- **P3** : 4 h ouvrées prise en charge / 1 j ouvré plan d’action
- **P4** : 1 j ouvré prise en charge

> Ajuster selon vos SLA contractuels.

---

## 6) Règles non négociables (copilote)

1) **Ne jamais inventer** une action réalisée.
   - Si non confirmé : tagger **[À CONFIRMER]**.
2) Première ligne de **CW NOTE INTERNE** :
   - « Prendre connaissance de la demande et connexion à la documentation de l'entreprise. »
3) **Client-safe** (CW DISCUSSION + EMAIL) :
   - pas d’IP internes, pas de comptes, pas de chemins sensibles, pas de logs bruts.
   - masquer/remplacer par `[MASQUÉ]` + expliquer dans un bloc interne `redactions`.
4) Captures d’écran :
   - résumer ce qui est lisible ; sinon écrire **[ILLISIBLE]**.

---

## 7) Inputs attendus

Minimum (au démarrage) :
- `client`
- `ticket_id`
- `briefs` (1 ou plusieurs)
- `ticket_type` : NOC | SOC | Support | Autre (si connu)
- `assets` (si connus : serveurs, équipements, config items)

Optionnels utiles :
- fenêtre maintenance (`window`)
- `after_hours` (oui/non)
- `approval_required` (oui/non)
- contraintes d’accès / outils (`constraints`)
- preuves déjà reçues (`evidence`)

---

## 8) Outputs attendus

### MODE=LIVE
- `memory` (état du ticket)
- `journal` (timeline numérotée)
- `checklist` (statuts)
- `next_actions` (prochaines étapes)

### MODE=CLOSE
En plus :
- `cw_internal_notes` (complet)
- `cw_discussion` (client-safe)
- `email_client` (si demandé)

---

## 9) Statuts standards

Statuts autorisés (journal + checklist) :
- **À FAIRE**
- **FAIT**
- **SKIP**
- **KO**
- **À SUIVRE**

Règle :
- Toute action **FAIT** doit idéalement avoir une **preuve** (au minimum un résumé).
- Si preuve absente : ajouter tag **[À CONFIRMER]**.

---

## 10) Procédure (exécution)

### Étape 1 — Initialiser le ticket (MODE=LIVE)

**Acteur** : `@IT-SysAdmin`  
**Action** : envoyer un payload de démarrage.

Exemple minimal :
```yaml
mode: LIVE
client: "ACME"
ticket_id: "CW-123456"
ticket_type: "Support"
assets: ["SRV-APP-01"]
briefs:
  - "Erreur 500 sur l’application depuis 9h."
```

**Contrôle qualité**
- `client` et `ticket_id` présents.
- `ticket_type` si possible (sinon `Autre` + question).

---

### Étape 2 — Injecter les checklists (/template)

Toujours injecter :
1) `/template start_standard`
2) `/template evidence_capture`
3) Checklist selon type :
   - NOC : `/template noc_baseline`
   - SOC : `/template soc_baseline`
   - Support : `/template support_baseline`
4) `/template closeout_validations`

**Contrôle qualité**
- La checklist contient des items “vérifications” + “validation finale”.

---

### Étape 3 — Exécuter et journaliser en temps réel

À chaque action (ou décision) :
1) Ajouter une entrée au **journal** :
   - action (verbe clair)
   - statut
   - preuve (résumé ou référence)
   - tags : `[À CONFIRMER]` si besoin
2) Mettre à jour la **checklist** (item → statut).

**Règles d’écriture**
- 1 entrée = 1 action = 1 résultat.
- Pas de flou (“gérer”, “voir”, “checker”) → écrire l’action précise.

---

### Étape 4 — Contrôle de fin d’intervention (pré-close)

Avant de clôturer :
- Confirmer service/app “OK” ou documenter ce qui reste “À SUIVRE”.
- Compléter les validations :
  - services OK
  - monitoring OK
  - backups OK (si applicable)
  - validation utilisateur (si applicable)

---

### Étape 5 — Clôturer (MODE=CLOSE)

Déclencher :
- `/close` (ou “FIN/CLOSE TICKET”)

Le copilote génère :
- **CW NOTE INTERNE** (complet, interne)
- **CW DISCUSSION** (client-safe)
- **EMAIL CLIENT** (si demandé)

**Contrôle qualité**
- La Note interne inclut la phrase obligatoire en 1re ligne.
- Le client-safe ne contient aucun détail sensible.

---

### Étape 6 — Knowledge Base (si applicable)

**Acteur** : `IT-KnowledgeKeeper`  
**Action** : transformer la résolution en note KB réutilisable (symptôme → cause → fix → prévention).

**Quand**
- Incident récurrent
- Nouveau correctif / procédure
- Le ticket a impliqué plusieurs étapes non triviales

---

## 11) Checklists prêtes à injecter (contenu)

### /template start_standard
- Reformuler la demande + impact.
- Identifier type (NOC/SOC/Support).
- Collecter infos manquantes (accès, scope, fenêtre, approbations).
- Définir plan d’action + critères de succès.
- Définir point de communication (quand informer le client).

### /template evidence_capture
- Pour chaque action : preuve attendue (capture/résultat/commande résumée).
- Noter ce qui est **[À CONFIRMER]**.

### /template noc_baseline
- Vérifier services critiques (selon client).
- Vérifier alertes monitoring (actuelles + 24h).
- Vérifier capacité (CPU/RAM/Disk) si pertinent.
- Vérifier connectivité (VPN/LAN/WAN) si pertinent.
- Préparer rollback / mitigation.
- Validation finale : services OK + monitoring OK.

### /template soc_baseline
- Triage alerte : source, horodatage, criticité.
- Définir périmètre (assets, comptes).
- Containment (isoler si nécessaire) **[À CONFIRMER]**.
- Collecte IOC (interne seulement).
- Escalade sécurité si suspicion confirmée.
- Validation finale : risque réduit + actions de suivi.

### /template support_baseline
- Confirmer symptôme + impact.
- Reproduire / collecter preuves.
- Hypothèse cause + test.
- Appliquer correctif + preuve.
- Validation utilisateur.
- Prévention (si applicable).

### /template closeout_validations
- Services : OK/KO/[À CONFIRMER]
- Monitoring : OK/KO/[À CONFIRMER]
- Backups (si applicable) : OK/KO/[À CONFIRMER]
- Validation utilisateur (si applicable) : OK/KO/[À CONFIRMER]
- Prochaines étapes : aucune / suivi / action client

---

## 12) Templates de livrables (copiables)

### A) CW NOTE INTERNE (interne, complet)
```text
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

Contexte
- Ticket: <ticket_id>
- Client: <client>
- Type: <NOC/SOC/Support/Autre>
- Actifs: <assets>
- Fenêtre / After-hours / Approvals: <...>

Symptômes / Impact
- <...>

Timeline (journal)
1) <action> — <FAIT/À FAIRE/...> — Preuve: <...> <[À CONFIRMER] si besoin>
2) ...

Diagnostic
- <constats + cause probable> <[À CONFIRMER] si besoin>

Actions réalisées
- <liste>

Résultat
- <ce qui est revenu à la normale / ce qui reste>

Validations
- Services: OK/KO/[À CONFIRMER]
- Monitoring: OK/KO/[À CONFIRMER]
- Backups (si applicable): OK/KO/[À CONFIRMER]
- Validation utilisateur (si applicable): OK/KO/[À CONFIRMER]

Prochaines étapes
- <...>
```

### B) CW DISCUSSION (client-safe, facturable, court)
```text
- Analyse de la demande et vérifications de l’environnement.
- Correctif appliqué (détails techniques internes masqués).
- Contrôles de bon fonctionnement effectués.
- Prochaine étape : <aucune action requise / surveillance / action client>.
```

### C) EMAIL CLIENT (optionnel, client-safe)
```text
Bonjour,

Nous avons pris en charge votre demande (<ticket_id>) et effectué les vérifications nécessaires.
Le correctif a été appliqué et le service fonctionne normalement.

Résumé :
- Action : correctif appliqué (détails techniques internes masqués)
- Résultat : retour à la normale confirmé
- Prochaine étape : <aucune / surveillance / action client>

N’hésitez pas à répondre à cet email si vous observez encore un comportement anormal.

Cordialement,
<Signature MSP>
```

---

## 13) Exceptions & escalade

### A) Pas d’accès / accès bloqué
- Reconnaître : VPN/RMM indisponible, creds manquants, MFA bloqué.
- Faire :
  - journaliser en **KO** + preuve (message d’erreur résumé)
  - demander l’accès manquant (open_questions)
- Escalader : NOC Lead / Service Desk Lead.

### B) Hors heures + approbation requise non obtenue
- Reconnaître : after_hours=oui ET approval_required=oui ET pas d’approbation.
- Faire : stop action intrusive → statut **SKIP** / **À SUIVRE**, demander approbation.
- Escalader : Owner MSP / on-call manager.

### C) Suspicion sécurité (SOC)
- Reconnaître : indicateurs compromission, exfil, compte suspect.
- Faire : containment minimal (si autorisé) + escalade immédiate.
- Escalader : SOC Lead / Security Incident Manager.

### D) Scope creep (le client ajoute des demandes)
- Reconnaître : nouvelles demandes non liées au symptôme initial.
- Faire : noter “hors scope” + proposer nouveau ticket.
- Escalader : CSM / Service Delivery Manager.

---

## 14) Contrôles qualité (DoD)

Le ticket est “Done” si :
- Le journal couvre toutes les actions majeures (pas de trous).
- Chaque action **FAIT** a une preuve ou **[À CONFIRMER]**.
- CW NOTE INTERNE : phrase obligatoire en 1re ligne + timeline + validations.
- CW DISCUSSION : 100% client-safe.
- Prochaine étape claire (ou “aucune action requise”).
- Si utile : KB créée / mise à jour.

---

## 15) KPIs & boucle d’amélioration (suggestion)

KPIs (3–7 max) :
- % tickets avec CW NOTE INTERNE complète (checklist closeout OK)
- % tickets avec preuve pour actions critiques
- Taux de réouverture (reopen rate)
- MTTR (temps moyen de résolution)
- Temps de 1re réponse
- % discussions client-safe sans redaction manuelle
- CSAT (si mesuré)

Boucle de feedback :
- Qui : Lead MSP + 1 tech NOC + 1 tech Support + 1 SOC (si applicable)
- Fréquence : hebdo 15 min
- Où : un doc “Runbook feedback” + changelog
- Action : améliorer templates + items checklist + règles de redaction

---

## 16) Points à clarifier (à compléter)

- Règles exactes de facturation CW_DISCUSSION (format, temps, catégories).
- Liste des champs ConnectWise à standardiser (Board/Type/Subtype/Item, Config IDs, Site).
- SLA contractuels officiels (P1..P4) à remplacer dans ce runbook.
