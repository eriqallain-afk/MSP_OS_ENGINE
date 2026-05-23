# BUNDLE_RUNBOOKS_IT_SUPPORT
**Bundle Runbooks — IT MSP Intelligence Platform**
**Catégorie :** Support — Triage N1/N2/N3, CW Close, Dispatch tickets
**Agents consommateurs :** @IT-Assistant-N2 | @IT-Assistant-N3 | @IT-FrontLine | @IT-Commandare-NOCDispatcher | @IT-TicketScribe
**Version :** 1.0 | **Date :** 2026-04-04
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Repo GitHub :** `PRODUCTS/IT/IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOKS_IT_SUPPORT.md`

> Ce bundle regroupe tous les runbooks de la catégorie **Support — Triage N1/N2/N3, CW Close, Dispatch tickets**.
> Uploader en Knowledge dans les GPT agents indiqués.
> Les runbooks sont à jour — source canonique dans GitHub.

---

## RB-SUPPORT-001 — Triage N1/N2/N3 — Qualification et escalade

# RUNBOOK — Triage Support TI N1/N2/N3 MSP
**ID :** RUNBOOK__IT_SUPPORT_TRIAGE_N1N2N3_V1  
**Version :** 1.0 | **Agent :** IT-SupportMaster  
**Applicable :** Tout ticket support entrant (NOC / SOC / Support / Autre)

---

## ARBRE DE DÉCISION INITIAL

```
TICKET ENTRANT (via CW / email / téléphone)
│
├─ Sécurité (virus, ransomware, phishing, accès non autorisé)
│   └─ → P1/P2 → @IT-SecurityMaster + @IT-Commandare-NOC
│
├─ Infrastructure critique down (DC, réseau principal, backup)
│   └─ → P1/P2 → @IT-Commandare-NOC → @IT-Commandare-Infra
│
├─ Cloud/M365 inaccessible (Exchange, SharePoint, Teams)
│   └─ → P2 → @IT-CloudMaster
│
├─ Réseau (connectivité site, VPN, WiFi)
│   └─ → P2/P3 → @IT-NetworkMaster
│
├─ Serveur non critique (lent, service arrêté)
│   └─ → P2/P3 → @IT-Commandare-Infra
│
├─ Backup en échec
│   └─ → P2/P3 → @IT-BackupDRMaster
│
├─ Téléphonie (VoIP coupure)
│   └─ → P2/P3 → @IT-VoIPMaster
│
├─ Logiciel métier (ERP, CRM)
│   └─ → P3 → N2 ou fournisseur applicatif
│
└─ Workstation / utilisateur (PC, imprimante, compte)
    └─ → P3/P4 → N1 direct
```

---

## NIVEAU 1 — WORKSTATION & UTILISATEUR

### 1.1 Réinitialisation mot de passe AD
```powershell
# ⚠️ Validation identité utilisateur requise avant exécution
Set-ADAccountPassword -Identity "username" -Reset -NewPassword (Read-Host -AsSecureString "Nouveau MDP")
Set-ADUser -Identity "username" -ChangePasswordAtLogon $true
Unlock-ADAccount -Identity "username"
```

### 1.2 PC lent / gelé
Checklist N1 :
1. Redémarrage simple → résout 40% des cas
2. Task Manager : CPU/RAM usage élevé ? Identifier processus
3. Espace disque < 10% → nettoyer (Disk Cleanup, dossier TEMP)
4. Windows Update en cours silencieusement ?
5. Event Viewer → erreurs récentes Application/System
6. Si > 30 min non résolu : escalader N2

### 1.3 Problème imprimante
Checklist N1 :
1. Câble/WiFi connecté ? PC voit l'imprimante ?
2. Redémarrer spooler : `Restart-Service Spooler`
3. File d'attente : supprimer jobs bloqués
4. Réinstaller driver si nécessaire
5. Si imprimante réseau : ping l'IP de l'imprimante

### 1.4 Outlook / email ne fonctionne pas
1. Tester webmail (OWA / outlook.com) — isole client vs serveur
2. Outlook en mode Safe (`outlook.exe /safe`)
3. Rebuild profil Outlook si corrompu
4. Si tous les utilisateurs affectés → P2 escalade IT-CloudMaster

---

## NIVEAU 2 — RÉSEAU LOCAL & SERVEURS NON CRITIQUES

### 2.1 Connectivité réseau partielle
```powershell
# Tests de base
Test-NetConnection -ComputerName "8.8.8.8" -InformationLevel Detailed
Test-NetConnection -ComputerName "gateway_ip" -Port 80
ipconfig /all
tracert gateway_ip
# DNS
Resolve-DnsName google.com
```

### 2.2 Service Windows arrêté
```powershell
# Vérifier état + redémarrer
Get-Service -Name "ServiceName" | Select-Object Name, Status, StartType
Start-Service -Name "ServiceName"
# Si échec — consulter Event Viewer
Get-EventLog -LogName System -Source "*ServiceName*" -Newest 20
```

### 2.3 Espace disque critique
```powershell
# Identifier les gros fichiers/dossiers
Get-ChildItem -Path "C:\" -Recurse -ErrorAction SilentlyContinue |
    Sort-Object Length -Descending | 
    Select-Object -First 20 FullName, @{N='SizeMB';E={[math]::Round($_.Length/1MB,2)}}
```

---

## NIVEAU 3 — INFRASTRUCTURE CRITIQUE

**Toujours via @IT-Commandare-TECH ou spécialiste dédié.**

Checklist N3 minimum avant escalade :
- [ ] Symptôme précis documenté
- [ ] Heure de début
- [ ] Assets affectés listés
- [ ] Actions N1/N2 déjà tentées documentées
- [ ] Impact business évalué
- [ ] Bloc POUR COPILOT préparé pour @IT-InterventionCopilot

---

## PROCÉDURE ESCALADE

```yaml
# Bloc POUR COPILOT (à transmettre à @IT-InterventionCopilot)
/obs [ticket_id] | [catégorie] | P[1/2/3/4]
/contexte: [description complète]
/fait:
  - [action 1 effectuée]
  - [action 2 effectuée]
/validations:
  - [test 1 à effectuer]
/escalade: @[Agent] — raison: [motif]
```

---

## SLA CIBLES MSP

| Priorité | Temps réponse | Temps résolution | Escalade auto |
|----------|--------------|-----------------|---------------|
| P1 | 15 min | 4h | 30 min → Senior |
| P2 | 30 min | 8h | 2h → Senior |
| P3 | 2h | 24h | 4h → N2 |
| P4 | 4h | 72h | 24h → N2 |


---

## RB-SUPPORT-002 — CW Intervention Live — Clôture complète

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
- **Copilote** : `@IT-InterventionCopilot`
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

**Acteur** : `@IT-InterventionCopilot`  
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


---

## RB-SUPPORT-003 — ConnectWise Dispatch — MSP

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

---

## RB-SUPPORT-004 — Ticket to KB — Capitalisation

# RUNBOOK — IT_MSP_TICKET_TO_KB

## Objectif

Ticket MSP -> diagnostic -> communication -> knowledge

## Déclencheur

- Dès qu’une demande correspond à cet intent dans le routage, ou exécution manuelle.

## Owner

- TEAM__IT (Lead Ops IT)

## SLA cible


Voir la policy : `50_POLICIES/ops/sla.md`

- P1 (critique) : réponse < 15 min, mitigation < 60 min
- P2 (majeur)   : réponse < 1h, mitigation < 4h
- P3 (normal)   : réponse < 4h, mitigation < 2j
- P4 (faible)   : best effort

Règle :
- Si la demande est un **incident IT/OPS**, classifier **P1–P4** (section ci-dessous) et appliquer le SLA correspondant.
- Sinon (requête non-incident), classer **P4** par défaut.

## Logging (OPS) — obligatoire
Référence : `50_POLICIES/ops/logging_schema.md`

Chaque exécution doit produire un log (au minimum) avec :
- request_id
- timestamp
- caller_actor_id
- target_actor_id
- playbook_id
- step_id
- artifacts[]
- log.decisions[]
- log.risks[]
- log.assumptions[]

Règle : le **output final** doit contenir `request_id` et un résumé des décisions/risques.

## Incident severity (P1–P4)
Référence : `50_POLICIES/ops/incident_severity.md`

- P1 : panne totale / données à risque / sécurité
- P2 : fonctionnalité clé KO / impact large
- P3 : bug contournable / impact limité
- P4 : amélioration / dette

Règle : pour tout incident, inclure `incident_severity` dans l’output final + dans le log.

## Inputs attendus
- Demande utilisateur (texte brut) + contexte (dossier/ticket).
- Intent (si déjà détecté) ou signal d’incident (si applicable).
- Contraintes : délais, périmètre, systèmes concernés.

## Outputs attendus
- Résultat final actionnable (résolution / dispatch / KB / décision).
- `request_id` + (si incident) `incident_severity`.
- Artifacts référencés (liens/IDs) + log décisions/risques/assumptions.

## Étapes (alignées `40_RUNBOOKS/playbooks.yaml`)
1. **scribe** → `IT-TicketScribe`
2. **support** → `IT-SupportMaster`
3. **comms** → `IT-TicketScribe`
4. **kb** → `IT-KnowledgeKeeper`

Règle : si une étape échoue, enregistrer l’échec via le logging OPS et appliquer l’escalade du playbook.

## Prérequis

- Accès aux agents impliqués.
- Dossier/ID de suivi (ticket, dossier client, ou dossier IA).
- Inputs complets (fichiers / texte / consignes).

## Étapes (exécution)

### Étape 1 — scribe

- **Acteur** : `IT-TicketScribe`

- **Action** : lancer l’acteur avec les inputs de l’étape, récupérer la sortie.

- **Sortie attendue** : output conforme au `contract.yaml` de l’acteur.

- **Contrôle qualité** : vérifier champs obligatoires + cohérence (pas de champs vides critiques).


### Étape 2 — support

- **Acteur** : `IT-SupportMaster`

- **Action** : lancer l’acteur avec les inputs de l’étape, récupérer la sortie.

- **Sortie attendue** : output conforme au `contract.yaml` de l’acteur.

- **Contrôle qualité** : vérifier champs obligatoires + cohérence (pas de champs vides critiques).


### Étape 3 — comms

- **Acteur** : `IT-TicketScribe`

- **Action** : lancer l’acteur avec les inputs de l’étape, récupérer la sortie.

- **Sortie attendue** : output conforme au `contract.yaml` de l’acteur.

- **Contrôle qualité** : vérifier champs obligatoires + cohérence (pas de champs vides critiques).


### Étape 4 — kb

- **Acteur** : `IT-KnowledgeKeeper`

- **Action** : lancer l’acteur avec les inputs de l’étape, récupérer la sortie.

- **Sortie attendue** : output conforme au `contract.yaml` de l’acteur.

- **Contrôle qualité** : vérifier champs obligatoires + cohérence (pas de champs vides critiques).


## Critères de Done

- Toutes les étapes exécutées sans erreur.
- Output final archivé (dossier/ticket mis à jour).
- Si applicable : décision/score final communiqué.

## Exceptions & escalade

- Output incohérent / incomplet → relancer l’étape 1 fois avec inputs clarifiés.
- Blocage persistant → escalader au owner d’équipe + `HUB-AgentMO2-DeputyOrchestrator`.

## Notes / Doc legacy

- Une version legacy existe : `40_RUNBOOKS/LEGACY_MD/01_it_msp_ticket_to_kb.md`


---

## RB-SUPPORT-005 — Intervention Live — Procédure

# RUNBOOK — IT_INTERVENTION_LIVE

Playbook ID : `IT_INTERVENTION_LIVE`  
Objectif : Suivre en temps réel une intervention MSP (maintenance/incident) et produire les livrables ConnectWise à la fin (Note interne + Discussion client-safe + Email optionnel).

---

## 1) Objectif & scope

### Objectif
Fournir un **copilote d’intervention live** pour les techniciens MSP (NOC/SOC/Support/NightOps) qui :

1. Prend un **brief initial** (ticket, liste de serveurs, infos RMM…).
2. Maintient un **contexte structuré** + un **journal** + une **checklist** pendant toute l’intervention.
3. Suit les actions du technicien (patchs, redémarrages, erreurs, validations).
4. En fin de ticket, génère automatiquement :
   - `CW_INTERNAL_NOTES` (Note interne détaillée),
   - `CW_DISCUSSION` (résumé client-safe),
   - `EMAIL_CLIENT` (si demandé).

### Scope
- Interventions **NOC / maintenance** (patching, reboot, checks).
- Interventions **Support / incident** (troubleshooting, fix).
- Interventions **SOC** (au besoin, même logique journal/checklist).

Ce runbook ne gère pas :
- la planification globale des maintenances,
- la gestion des SLA/incidents majeurs (gérée par d’autres policies/playbooks).

---

## 2) Inputs attendus

### 2.1. Brief initial (obligatoire)

Le premier message doit contenir **au minimum** :

- `ticket_id` ou sujet (ex. `Service Ticket #1600961`).
- Nom du **client / site**.
- **Type** d’intervention si connu (patching, incident, maintenance…).
- Infos de périmètre :
  - liste des serveurs / équipements,
  - éventuellement un export RMM (Device Type, OS, Last Restart, EDR…).

> ⚠️ Le copilote ne doit **pas** te poser 10 questions : il doit inférer un maximum à partir du brief et marquer le reste `[À CONFIRMER]`.

### 2.2. Flux live (pendant l’intervention)

Ensuite, tu peux lui envoyer au fil de l’eau :

- Notes textuelles : _« Patch appliqué sur MPM-SVR-APPS01, reboot OK »_.
- Logs / erreurs : messages d’échec, sorties de commandes.
- Copie de sections RMM (état des updates, Last Restart, alerts).
- Captures d’écran (décrites sommairement si possible).

Chaque nouveau message doit être traité comme une **mise à jour** du ticket, pas comme un nouveau ticket.

### 2.3. Signal de clôture

- `/close`, `FIN TICKET`, `FIN/CLOSE TICKET`, etc.  
→ déclenche le **MODE=CLOSE** et la génération des livrables.

---

## 3) Outputs attendus

### 3.1. En MODE=LIVE (par défaut)

Une réponse typique contient :

- `MODE: LIVE`
- `CONTEXT` : ticket, client, périmètre, infos DR si pertinentes.
- `JOURNAL` : entrées numérotées, statuts (`À FAIRE`, `FAIT`, `SKIP`, `KO`, `À SUIVRE`).
- `CHECKLIST` : items NOC/SOC/Support adaptés, mêmes statuts.
- `PREUVES` : résumés de logs, captures, sorties.
- `VALIDATIONS` : services OK/KO, monitoring, backups, validation utilisateur.
- `INFOS_EN_ATTENTE` : liste courte de points à confirmer.
- Optionnel : `PROCHAINES_ACTIONS` (2–5 actions proposées).

> Les **questions** doivent être **très limitées** (0–2 max) et seulement si bloquantes.

---

### 3.2. Exemple de sortie initiale attendue (sur ton brief MPM)

**Cas réel :** tu envoies :

> Service Ticket #1600961 - Déploiement de cumulatifs de mises à jour  
> Materiaux Pont Masson Inc. Vlfd  
>  
> MPM-SVR-DATA  
> MPM-SVR-RDS02  
> MPM-SVR-TSGW  
> MPM-SVR-RDS01  
> ST550-HV2k19  
> MPM-SVR-INNO  
> MPM-SVR-FSVHDX  
> MPM-SVR-TS  
> MPM-SVR-IMP  
> ST550-HV2k19-RE  
> MPM-SVR-APP  
> MPM-SVR-MGMT  
> MPM-SVR-APPS01  
> MPM-SVR-EMS  
>  
> + tableau RMM (OS / Last Restart / EDR)

**Réponse attendue du copilote :**

```yaml
MODE: LIVE

CONTEXT:
  ticket_id: "1600961"
  client: "Materiaux Pont Masson Inc. Vlfd"
  site: "Main - Valleyfield - Succursal"
  ticket_type: "NOC"
  demande: "Déploiement de cumulatifs de mises à jour (serveurs Windows) + redémarrages si requis."
  fenetre_maintenance:
    after_hours: "[À CONFIRMER]"
    date_heure_debut: "[À CONFIRMER]"
    date_heure_fin: "[À CONFIRMER]"
    fuseau: "America/Montreal"
  approbation_reboots: "[À CONFIRMER]"
  perimetre_actifs:
    - "MPM-SVR-DATA"
    - "MPM-SVR-RDS02"
    - "MPM-SVR-TSGW"
    - "MPM-SVR-RDS01"
    - "ST550-HV2k19"
    - "MPM-SVR-INNO"
    - "MPM-SVR-FSVHDX"
    - "MPM-SVR-TS"
    - "MPM-SVR-IMP"
    - "ST550-HV2k19-RE"
    - "MPM-SVR-APP"
    - "MPM-SVR-MGMT"
    - "MPM-SVR-APPS01"
    - "MPM-SVR-EMS"

INFOS_EN_ATTENTE:
  - "Fenêtre de maintenance exacte (début/fin, heure de Montréal)."
  - "Confirmation explicite des redémarrages pour tous les serveurs listés."

JOURNAL:
  - id: 1
    statut: "À FAIRE"
    zone: "NOC"
    resume: "Préparer le déploiement des cumulatifs sur les 14 serveurs listés (pré-checks, sauvegardes, ordre de reboot)."

CHECKLIST:
  - item: "Vérifier sauvegardes récentes pour chaque serveur critique (RDS, DATA, Hyper-V)."
    statut: "À FAIRE"
  - item: "Définir l'ordre de patch/reboot (APPS/EMS/MGMT -> RDS/TS/TSGW -> DATA/FS -> Hyper-V)."
    statut: "À FAIRE"
  - item: "Mettre les serveurs en maintenance dans le monitoring/EDR si nécessaire."
    statut: "À FAIRE"

PREUVES: []

VALIDATIONS:
  services: "[À CONFIRMER]"
  monitoring: "[À CONFIRMER]"
  backups: "[À CONFIRMER]"
  validation_utilisateur: "[À CONFIRMER]"

COMMENTAIRE:
  - "Je suis en suivi d'intervention. Au fur et à mesure que tu patches/rebootes un serveur ou que tu rencontres des erreurs, envoie-moi les infos/captures et je mettrai à jour le journal + la checklist. À la fin, je générerai les rapports CW (Note interne + Discussion client-safe, et email si tu le demandes)."


---

## RB-SUPPORT-006 — Commandare OPR — Gouvernance opérationnelle

# RUNBOOK — IT_COMMANDARE_OPR

## Objectif

Commandare OPR: gouvernance ops, communication, coordination & contrôle.

## Déclencheur

- Dès qu’une demande correspond à cet intent dans le routage, ou exécution manuelle.

## Owner

- TEAM__IT (Lead Ops IT)

## SLA cible


Voir la policy : `50_POLICIES/ops/sla.md`

- P1 (critique) : réponse < 15 min, mitigation < 60 min
- P2 (majeur)   : réponse < 1h, mitigation < 4h
- P3 (normal)   : réponse < 4h, mitigation < 2j
- P4 (faible)   : best effort

Règle :
- Si la demande est un **incident IT/OPS**, classifier **P1–P4** (section ci-dessous) et appliquer le SLA correspondant.
- Sinon (requête non-incident), classer **P4** par défaut.

## Logging (OPS) — obligatoire
Référence : `50_POLICIES/ops/logging_schema.md`

Chaque exécution doit produire un log (au minimum) avec :
- request_id
- timestamp
- caller_actor_id
- target_actor_id
- playbook_id
- step_id
- artifacts[]
- log.decisions[]
- log.risks[]
- log.assumptions[]

Règle : le **output final** doit contenir `request_id` et un résumé des décisions/risques.

## Incident severity (P1–P4)
Référence : `50_POLICIES/ops/incident_severity.md`

- P1 : panne totale / données à risque / sécurité
- P2 : fonctionnalité clé KO / impact large
- P3 : bug contournable / impact limité
- P4 : amélioration / dette

Règle : pour tout incident, inclure `incident_severity` dans l’output final + dans le log.

## Inputs attendus
- Demande utilisateur (texte brut) + contexte (dossier/ticket).
- Intent (si déjà détecté) ou signal d’incident (si applicable).
- Contraintes : délais, périmètre, systèmes concernés.

## Outputs attendus
- Résultat final actionnable (résolution / dispatch / KB / décision).
- `request_id` + (si incident) `incident_severity`.
- Artifacts référencés (liens/IDs) + log décisions/risques/assumptions.

## Étapes (alignées `40_RUNBOOKS/playbooks.yaml`)
1. **execute** → `IT-Commandare-OPR`

Règle : si une étape échoue, enregistrer l’échec via le logging OPS et appliquer l’escalade du playbook.

## Prérequis

- Accès aux agents impliqués.
- Dossier/ID de suivi (ticket, dossier client, ou dossier IA).
- Inputs complets (fichiers / texte / consignes).

## Étapes (exécution)

### Étape 1 — execute

- **Acteur** : `IT-Commandare-OPR`

- **Action** : lancer l’acteur avec les inputs de l’étape, récupérer la sortie.

- **Sortie attendue** : output conforme au `contract.yaml` de l’acteur.

- **Contrôle qualité** : vérifier champs obligatoires + cohérence (pas de champs vides critiques).


## Critères de Done

- Toutes les étapes exécutées sans erreur.
- Output final archivé (dossier/ticket mis à jour).
- Si applicable : décision/score final communiqué.

## Exceptions & escalade

- Output incohérent / incomplet → relancer l’étape 1 fois avec inputs clarifiés.
- Blocage persistant → escalader au owner d’équipe + `HUB-AgentMO2-DeputyOrchestrator`.

## Notes / Doc legacy

- N/A


---

## RB-SUPPORT-007 — Commandare TECH — Support technique

# RUNBOOK — IT_COMMANDARE_TECH

## Objectif

Commandare TECH: troubleshooting/RCA, plan de remediation, risques.

## Déclencheur

- Dès qu’une demande correspond à cet intent dans le routage, ou exécution manuelle.

## Owner

- TEAM__IT (Lead Ops IT)

## SLA cible


Voir la policy : `50_POLICIES/ops/sla.md`

- P1 (critique) : réponse < 15 min, mitigation < 60 min
- P2 (majeur)   : réponse < 1h, mitigation < 4h
- P3 (normal)   : réponse < 4h, mitigation < 2j
- P4 (faible)   : best effort

Règle :
- Si la demande est un **incident IT/OPS**, classifier **P1–P4** (section ci-dessous) et appliquer le SLA correspondant.
- Sinon (requête non-incident), classer **P4** par défaut.

## Logging (OPS) — obligatoire
Référence : `50_POLICIES/ops/logging_schema.md`

Chaque exécution doit produire un log (au minimum) avec :
- request_id
- timestamp
- caller_actor_id
- target_actor_id
- playbook_id
- step_id
- artifacts[]
- log.decisions[]
- log.risks[]
- log.assumptions[]

Règle : le **output final** doit contenir `request_id` et un résumé des décisions/risques.

## Incident severity (P1–P4)
Référence : `50_POLICIES/ops/incident_severity.md`

- P1 : panne totale / données à risque / sécurité
- P2 : fonctionnalité clé KO / impact large
- P3 : bug contournable / impact limité
- P4 : amélioration / dette

Règle : pour tout incident, inclure `incident_severity` dans l’output final + dans le log.

## Inputs attendus
- Demande utilisateur (texte brut) + contexte (dossier/ticket).
- Intent (si déjà détecté) ou signal d’incident (si applicable).
- Contraintes : délais, périmètre, systèmes concernés.

## Outputs attendus
- Résultat final actionnable (résolution / dispatch / KB / décision).
- `request_id` + (si incident) `incident_severity`.
- Artifacts référencés (liens/IDs) + log décisions/risques/assumptions.

## Étapes (alignées `40_RUNBOOKS/playbooks.yaml`)
1. **execute** → `IT-Commandare-TECH`

Règle : si une étape échoue, enregistrer l’échec via le logging OPS et appliquer l’escalade du playbook.

## Prérequis

- Accès aux agents impliqués.
- Dossier/ID de suivi (ticket, dossier client, ou dossier IA).
- Inputs complets (fichiers / texte / consignes).

## Étapes (exécution)

### Étape 1 — execute

- **Acteur** : `IT-Commandare-TECH`

- **Action** : lancer l’acteur avec les inputs de l’étape, récupérer la sortie.

- **Sortie attendue** : output conforme au `contract.yaml` de l’acteur.

- **Contrôle qualité** : vérifier champs obligatoires + cohérence (pas de champs vides critiques).


## Critères de Done

- Toutes les étapes exécutées sans erreur.
- Output final archivé (dossier/ticket mis à jour).
- Si applicable : décision/score final communiqué.

## Exceptions & escalade

- Output incohérent / incomplet → relancer l’étape 1 fois avec inputs clarifiés.
- Blocage persistant → escalader au owner d’équipe + `HUB-AgentMO2-DeputyOrchestrator`.

## Notes / Doc legacy

- N/A


---

## RB-SUPPORT-008 — Windows Patching — Process support

# RUNBOOK — Communication Patching MSP (Client et Interne)
**ID :** RUNBOOK__Patching_Process | **Version :** 2.0
**Agent owner :** IT-TicketScribe | **Équipe :** TEAM__IT
**Domaine :** SUPPORT — Communications MSP
**Date révision :** 2026-03-13

---

## ⚠️ GARDE-FOUS — OBLIGATOIRES
> Référence : `00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md`

**Scope :** Cet agent rédige uniquement les communications liées au patching du billet actif.
Il ne répond pas aux demandes de rédaction hors contexte IT/MSP.

**Données sensibles dans les communications :**
- ❌ JAMAIS dans les emails/Teams clients : noms de serveurs, IPs, CVE spécifiques
- ❌ JAMAIS : informations qui permettraient d'exploiter des vulnérabilités avant le patch
- Les communications clients sont TOUJOURS en langage fonctionnel (impact et disponibilité)
- Toujours masquer les détails techniques des vulnérabilités corrigées

---

## 1. Objectif
Standardiser toutes les communications liées au cycle de patching :
- Notifications de fenêtre de maintenance aux clients
- Communications internes (équipe NOC/Tech)
- Annonces Teams (début/fin)
- Emails post-intervention (rapport fonctionnel)
- Gestion des escalades communication

---

## 2. Templates de communication par étape

### 2.1 Annonce préventive (J-48h) — Email client
```
Objet : [Entreprise] — Fenêtre de maintenance planifiée — [DATE]

Bonjour [Nom contact],

Nous vous informons qu'une fenêtre de maintenance est planifiée :
📅 Date : [JOUR DATE]
🕐 Heure : [HH:MM] à [HH:MM] ([fuseau horaire])
🎯 Objectif : Application des mises à jour de sécurité et de stabilité

Impact prévu :
- [Service X] : interruption possible de [durée estimée]
- [Service Y] : aucune interruption prévue

Actions requises de votre part :
- [ ] Sauvegarder vos documents ouverts avant [HH:MM]
- [ ] Prévoir une indisponibilité de [X] minutes sur [service]

Pour toute question, contactez : [email support] | [téléphone]

Cordialement,
[Signature MSP]
```

### 2.2 Annonce Teams — Début de maintenance
```
⚠️ MAINTENANCE EN COURS
📅 [DATE] — [HH:MM]
🔧 Application des mises à jour planifiées
⏱️ Durée estimée : [X heures]
📧 Toute interruption sera communiquée ici

Merci de votre compréhension. 🙏
```

### 2.3 Annonce Teams — Fin de maintenance (succès)
```
✅ MAINTENANCE TERMINÉE
📅 [DATE] — [HH:MM]
✔️ Mises à jour appliquées avec succès
🖥️ Tous les services sont opérationnels

En cas d'anomalie, contactez le support : [info contact]
```

### 2.4 Annonce Teams — Fin de maintenance (avec suivi)
```
✅ MAINTENANCE TERMINÉE — ⚠️ Suivi requis
📅 [DATE] — [HH:MM]
✔️ Mises à jour appliquées
⚠️ [Service X] : [état / action en cours]
📞 Notre équipe surveille activement la situation

Prochain point de communication : [HH:MM]
```

### 2.5 Email post-intervention — Rapport client
```
Objet : [Entreprise] — Rapport maintenance du [DATE]

Bonjour [Nom contact],

La fenêtre de maintenance du [DATE] est terminée. Voici le résumé :

✅ Résultat global : [Succès / Succès partiel]

Services mis à jour :
- [Catégorie service 1] : mise à jour appliquée — ✅ Opérationnel
- [Catégorie service 2] : mise à jour appliquée — ✅ Opérationnel

Durée effective : [HH:MM] à [HH:MM] ([X] minutes)

[Si applicable]
⚠️ Point de suivi : [description fonctionnelle — sans détails techniques]
   Action prévue : [description] — Délai : [date]

Prochaine maintenance planifiée : [DATE ou "À confirmer"]

Notre équipe reste disponible pour toute question.

Cordialement,
[Signature MSP]
```

---

## 3. Communication en cas d'incident durant la maintenance

### 3.1 Notification d'incident (délai 15 min max après détection)
```
Objet : [URGENT] [Entreprise] — Incident détecté durant maintenance — [DATE]

Bonjour [Nom contact],

Durant la fenêtre de maintenance, un incident a été détecté sur [catégorie service].

Statut actuel : Notre équipe technique est en train de traiter la situation.
Impact : [Service X] temporairement indisponible
Estimation retour à la normale : [heure estimée ou "sous X heures"]

Prochain point de communication : [heure]

Nous vous tenons informés de l'évolution.

[Signature MSP]
```

### 3.2 Résolution d'incident post-maintenance
```
Objet : [Résolution] [Entreprise] — Retour à la normale — [DATE]

Bonjour [Nom contact],

Bonne nouvelle — la situation est résolue.

✅ [Service X] : pleinement opérationnel depuis [HH:MM]
📋 Rapport détaillé disponible sur demande

Nous nous excusons pour la gêne occasionnée.

[Signature MSP]
```

---

## 4. Communication interne — Équipe technique

### 4.1 Briefing pré-maintenance (canal Teams IT)
```
🔧 MAINTENANCE PLANIFIÉE — BRIEFING
📅 [DATE] [HH:MM]-[HH:MM]
Client : [CLIENT]
Scope  : [description serveurs — sans IPs]
Owner  : @[Technicien assigné]
Backup : @[Technicien backup]
Proc   : [lien runbook ou playbook]
⚠️ Points d'attention : [risques identifiés]
```

### 4.2 Mise à jour état en cours (équipe)
```
⏳ UPDATE MAINTENANCE [CLIENT] — [HH:MM]
[✅/⚠️/❌] [Serveur/Service] : [statut court]
Prochaine étape : [action]
ETA fin : [estimation]
```

---

## 5. Checklist communication complète

- [ ] Annonce J-48h envoyée au client
- [ ] Confirmation réception client (si P1/P2 ou VIP)
- [ ] Briefing équipe IT effectué
- [ ] Annonce Teams début envoyée
- [ ] Updates intermédiaires si maintenance > 2h
- [ ] Annonce Teams fin envoyée
- [ ] Email rapport post-intervention envoyé (sous 24h)
- [ ] Note CW communication complète


---

```
