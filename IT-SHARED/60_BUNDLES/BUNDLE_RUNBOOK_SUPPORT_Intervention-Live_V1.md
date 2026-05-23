# BUNDLE RUNBOOK SUPPORT Intervention-Live V1
**Type :** Bundle Runbook — Assemblage complet
**Agents :** IT-Assistant-N3, IT-Assistant-N2, IT-MaintenanceMaster | IT-SysAdmin
**Description :** Intervention live ConnectWise — Triage + Live + Close
**Mis à jour :** 2026-03-20

> Ce bundle regroupe runbooks + templates + checklists liés à ce domaine.
> Uploader en Knowledge dans les GPTs concernés.


---
<!-- SOURCE: RUNBOOK__IT_SUPPORT_TRIAGE_N1N2N3_V1 -->
## RUNBOOK — Triage Support N1/N2/N3

# RUNBOOK — Triage Support TI N1/N2/N3 MSP
**ID :** RUNBOOK__IT_SUPPORT_TRIAGE_N1N2N3_V1
**Version :** 3.0 | **Agent :** IT-Assistant-N3
**Applicable :** Tout ticket support entrant (NOC / SOC / Support / Autre)
**Mis à jour :** 2026-03-20

---

## RÈGLE D'ESCALADE — À LIRE EN PREMIER

> Quand une escalade est nécessaire, l'agent indique au technicien
> **quel département humain contacter** — pas un autre GPT.
>
> **Format systématique :**
> ```
> ⚠️ [ESCALADE REQUISE]
> Confirme l'escalade du billet avec ton coach d'équipe.
> Ensuite, escalade le billet dans ConnectWise vers le bon département :
> → [Nom du département]
> ```

### Correspondance départements
| Département CW | Responsable | Couverture |
|---|---|---|
| **NOC** | IT-Commandare-NOC | Alertes RMM, réseau, backup, monitoring, infra critique |
| **SOC** | IT-Commandare-SOC | Incidents sécurité, ransomware, breach, EDR |
| **Infra** | IT-Commandare-Infra | Serveurs, virtualisation, DC/AD, Azure, stockage |
| **Tech** | IT-Commandare-TECH | Support senior N3, RCA, escalades techniques complexes |
| **OPR** | IT-Commandare-OPR | Clôture formelle, communication client, rapports |

---

## ARBRE DE DÉCISION INITIAL

```
TICKET ENTRANT (via CW / email / téléphone)
│
├─ Sécurité (virus, ransomware, phishing, accès non autorisé)
│   └─ → P1/P2 → [ESCALADE → département SOC]
│
├─ Infrastructure critique down (DC, réseau principal, backup)
│   └─ → P1/P2 → [ESCALADE → département NOC]
│
├─ Cloud/M365 inaccessible (Exchange, SharePoint, Teams)
│   └─ → P2 → [ESCALADE → département Infra]
│
├─ Réseau (connectivité site, VPN, WiFi)
│   └─ → P2/P3 → [ESCALADE → département NOC]
│
├─ Serveur non critique (lent, service arrêté)
│   └─ → P2/P3 → [ESCALADE → département Infra]
│
├─ Backup en échec
│   └─ → P2/P3 → [ESCALADE → département NOC]
│
├─ Téléphonie (VoIP coupure)
│   └─ → P2/P3 → [ESCALADE → département NOC]
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
6. Si > 30 min non résolu → escalader N2

### 1.3 Problème imprimante
Checklist N1 :
1. Câble/WiFi connecté ? PC voit l'imprimante ?
2. Redémarrer spooler : `Restart-Service Spooler`
3. File d'attente : supprimer jobs bloqués
4. Réinstaller driver si nécessaire
5. Si imprimante réseau : tester connectivité réseau

### 1.4 Outlook / email ne fonctionne pas
1. Tester webmail (OWA / outlook.com) — isole client vs serveur
2. Outlook en mode Safe (`outlook.exe /safe`)
3. Rebuild profil Outlook si corrompu
4. Si tous les utilisateurs affectés → P2 → [ESCALADE → département Infra]

---

## NIVEAU 2 — RÉSEAU LOCAL & SERVEURS NON CRITIQUES

### 2.1 Connectivité réseau partielle
```powershell
# Tests de base (ne pas inclure les IPs dans les livrables clients)
Test-NetConnection -ComputerName "8.8.8.8" -InformationLevel Detailed
ipconfig /all
Resolve-DnsName google.com
```
Si persistant → [ESCALADE → département NOC]

### 2.2 Service Windows arrêté
```powershell
Get-Service -Name "ServiceName" | Select-Object Name, Status, StartType
Start-Service -Name "ServiceName"
Get-EventLog -LogName System -Source "*ServiceName*" -Newest 20
```

### 2.3 Espace disque critique
```powershell
Get-ChildItem -Path "C:\" -Recurse -ErrorAction SilentlyContinue |
    Sort-Object Length -Descending |
    Select-Object -First 20 FullName, @{N='SizeMB';E={[math]::Round($_.Length/1MB,2)}}
```

---

## NIVEAU 3 — INFRASTRUCTURE CRITIQUE

**Toujours via le département Tech (coach d'équipe / senior).**

Checklist N3 minimum avant escalade :
- [ ] Symptôme précis documenté
- [ ] Heure de début
- [ ] Assets affectés listés
- [ ] Actions N1/N2 déjà tentées documentées
- [ ] Impact business évalué

---

## PROCÉDURE D'ESCALADE — TEXTE À AFFICHER AU TECHNICIEN

```
⚠️ [ESCALADE REQUISE — département [NOC / SOC / Infra / Tech]]

Confirme l'escalade du billet avec ton coach d'équipe.
Ensuite, escalade le billet dans ConnectWise vers le bon département.

Informations à transmettre :
- Ticket : #[XXXXX]
- Client : [Nom]
- Priorité : P[1/2]
- Symptôme : [Description précise]
- Actions déjà tentées : [Liste]
- Assets affectés : [Liste]
```

---

## SLA CIBLES MSP

| Priorité | Temps réponse | Temps résolution | Escalade auto |
|----------|--------------|-----------------|---------------|
| P1 | 15 min | 4h | 30 min → coach d'équipe |
| P2 | 30 min | 8h | 2h → coach d'équipe |
| P3 | 2h | 24h | 4h → N2 |
| P4 | 4h | 72h | 24h → N2 |


---
<!-- SOURCE: RUNBOOK__IT_CW_INTERVENTION_LIVE_CLOSE -->
## RUNBOOK — Intervention Live (MODE=LIVE/CLOSE)

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
Référence complète : `IT-SHARED/20_TEMPLATES/05_TEMPLATES_INTERVENTION/CW_TEMPLATE_LIBRARY__INTERVENTION_COPILOT.md`

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
- Le technicien veut des scripts Powershell pour obtenir rapidement des informations sur les serveurs ou postes clients.
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
- **Copilote** : `@IT-Assistant-N3, IT-MaintenanceMaster`
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
2) Première ligne de **CW NOTE INTERNE** et **Discussion** :
   - « Prendre connaissance de la demande et consultation de documentation du client. »
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

**Acteur** : `@IT-MaintenanceMaster, IT-Assistant-N3`  
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
<!-- SOURCE: RUNBOOK__IT_MSP_CONNECTWISE_DISPATCH_V1 -->
## RUNBOOK — CW Dispatch (Types/Subtypes)

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
<!-- SOURCE: TEMPLATE_CW_Note-Interne_V1 -->
## TEMPLATE — CW Note Interne

# TEMPLATE: CW_NOTE_INTERNE (Note technique - Base de connaissance)

## Objectif
Générer une note technique détaillée UNIQUEMENT visible par les techniciens. Sert de:
- ✅ Documentation technique complète
- ✅ Base de connaissance pour interventions futures
- ✅ Référence pour troubleshooting similaires
- ✅ Traçabilité des actions techniques

## Format

```
═══════════════════════════════════════════════════════════════
INTERVENTION TECHNIQUE - [TYPE]
═══════════════════════════════════════════════════════════════

INFORMATIONS GÉNÉRALES
----------------------
Date/Heure: [YYYY-MM-DD HH:MM - HH:MM]
Technicien: [Nom complet]
Client: [Nom client]
Ticket CW: [CW-123456]
Serveurs/Équipements: [Liste]
Type intervention: [Maintenance/Troubleshooting/Urgence/Audit]

CONTEXTE INITIAL
----------------
[Description situation initiale]
[Pourquoi cette intervention était nécessaire]
[Symptômes observés / Demande initiale]

ENVIRONNEMENT TECHNIQUE
-----------------------
Serveurs concernés:
  • [Serveur 1]: [OS, rôle, version, IP]
  • [Serveur 2]: [OS, rôle, version, IP]
  • [...]

Hyperviseur:
  • Plateforme: [VMware ESXi 7.0 / Hyper-V Server 2022 / ...]
  • Version: [X.X.X]
  • Host: [Nom]

Réseau:
  • Pare-feu: [Watchguard M370 / Fortinet FG-100F / ...]
  • Firmware: [Version]
  • Switches: [Modèles]

Backup:
  • Solution: [VEEAM Backup & Replication 12 / Datto SIRIS / ...]
  • Version: [X.X]
  • Repo: [Localisation]

DIAGNOSTIC / ANALYSE
--------------------
[Étapes de diagnostic effectuées]

Erreurs observées:
  • Event Log: [ID événement, source, description]
  • Messages système: [Détails]
  • Codes erreur: [Si applicable]

Causes identifiées:
  • [Cause 1]
  • [Cause 2]

ACTIONS TECHNIQUES DÉTAILLÉES
------------------------------
[Chronologie des actions avec commandes exactes]

1. [Action 1]
   Commande exécutée:
   ```powershell
   [Commande PowerShell exacte]
   ```
   Résultat: [Output ou résultat]
   
2. [Action 2]
   Commande exécutée:
   ```powershell
   [Commande PowerShell exacte]
   ```
   Résultat: [Output ou résultat]

3. [...]

CONFIGURATIONS MODIFIÉES
-------------------------
[Tout changement de configuration]

Avant:
  • [Paramètre]: [Valeur avant]

Après:
  • [Paramètre]: [Valeur après]

Raison: [Justification du changement]

TESTS DE VALIDATION
--------------------
[Tests effectués pour confirmer résolution]

✓ Test 1: [Description] - SUCCÈS
✓ Test 2: [Description] - SUCCÈS
✓ Test 3: [Description] - SUCCÈS

RÉSULTAT FINAL
--------------
État: [RÉSOLU / PARTIELLEMENT RÉSOLU / EN COURS]

Services vérifiés:
  ✓ [Service 1]: Opérationnel
  ✓ [Service 2]: Opérationnel
  ✓ [Service 3]: Opérationnel

NOTES IMPORTANTES
-----------------
• [Information importante 1]
• [Information importante 2]
• [Particularités de cet environnement]

RECOMMANDATIONS TECHNIQUES
--------------------------
Court terme (< 1 mois):
  • [Recommandation 1]
  • [Recommandation 2]

Moyen terme (1-3 mois):
  • [Recommandation 1]

Long terme (> 3 mois):
  • [Recommandation 1]

SUIVI REQUIS
------------
□ Surveillance dans 24h: [Quoi surveiller]
□ Surveillance dans 1 semaine: [Quoi surveiller]
□ Tâche planifiée: [Description, échéance]

RÉFÉRENCES / LIENS UTILES
--------------------------
• KB Article: [Lien interne si applicable]
• Documentation vendor: [Lien]
• Ticket lié: [CW-XXXXX]

TEMPS INTERVENTION
------------------
Temps total: [X heures Y minutes]
  - Diagnostic: [X min]
  - Résolution: [X min]
  - Tests: [X min]
  - Documentation: [X min]

═══════════════════════════════════════════════════════════════
```

## Exemples par type d'intervention

### Exemple 1: Patching Windows Server

```
═══════════════════════════════════════════════════════════════
INTERVENTION TECHNIQUE - PATCHING WINDOWS SERVER
═══════════════════════════════════════════════════════════════

INFORMATIONS GÉNÉRALES
----------------------
Date/Heure: 2026-02-10 20:00 - 23:15
Technicien: Eric Archambault
Client: Otto Inc Inc.
Ticket CW: CW-789456
Serveurs/Équipements: SRV-DC01, SRV-APP01, SRV-SQL01, SRV-FILE01, SRV-WEB01
Type intervention: Maintenance préventive (patching mensuel)

CONTEXTE INITIAL
----------------
Fenêtre de maintenance mensuelle approuvée pour application des mises à jour
de sécurité Microsoft (Patch Tuesday - Février 2026).
Objectif: Mettre à jour 5 serveurs Windows Server 2022 avec les KB de février.
Tous les utilisateurs notifiés, backup pré-maintenance complété.

ENVIRONNEMENT TECHNIQUE
-----------------------
Serveurs concernés:
  • SRV-DC01: Windows Server 2022 DC, [IP_CLIENTE], vCPU:4 RAM:16GB
  • SRV-APP01: Windows Server 2022 Std, [IP_CLIENTE], vCPU:4 RAM:32GB
  • SRV-SQL01: Windows Server 2022 + SQL 2022, [IP_CLIENTE], vCPU:8 RAM:64GB
  • SRV-FILE01: Windows Server 2022 Std, [IP_CLIENTE], vCPU:2 RAM:16GB
  • SRV-WEB01: Windows Server 2022 + IIS, [IP_CLIENTE], vCPU:4 RAM:16GB

Hyperviseur:
  • Plateforme: VMware ESXi 8.0 U2
  • Version: 8.0.2 (build 22380479)
  • Host: esx-lab.otto-inc.local

DIAGNOSTIC / ANALYSE
--------------------
État pré-maintenance vérifié:

```powershell
# Vérification espace disque
Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | 
    Select-Object DeviceID, @{N="FreeGB";E={[math]::Round($_.FreeSpace/1GB,2)}}
```

Tous serveurs: > 20GB disponible sur C: ✓

Mises à jour disponibles identifiées:
```powershell
Get-WindowsUpdate -ComputerName SRV-DC01,SRV-APP01,SRV-SQL01,SRV-FILE01,SRV-WEB01
```

Total: 15 KB de sécurité + 3 KB optionnels

ACTIONS TECHNIQUES DÉTAILLÉES
------------------------------

1. Installation updates sur SRV-FILE01 (non-critique en premier)
   Commande exécutée:
   ```powershell
   Install-WindowsUpdate -ComputerName SRV-FILE01 -AcceptAll -AutoReboot -Verbose
   ```
   Résultat: 15 KB installés, reboot à 20:45, services UP à 20:52 ✓

2. Installation updates sur SRV-WEB01
   Commande exécutée:
   ```powershell
   Install-WindowsUpdate -ComputerName SRV-WEB01 -AcceptAll -AutoReboot -Verbose
   ```
   Résultat: 15 KB installés, reboot à 21:10, IIS démarré automatiquement ✓

3. Installation updates sur SRV-APP01
   Commande exécutée:
   ```powershell
   Install-WindowsUpdate -ComputerName SRV-APP01 -AcceptAll -AutoReboot -Verbose
   ```
   Résultat: 15 KB installés, reboot à 21:35, tous services applicatifs redémarrés ✓

4. Installation updates sur SRV-SQL01
   Commande exécutée:
   ```powershell
   Install-WindowsUpdate -ComputerName SRV-SQL01 -AcceptAll -AutoReboot -Verbose
   ```
   Résultat: 15 KB installés, reboot à 22:05
   
   Vérification SQL Server post-reboot:
   ```powershell
   Get-Service -ComputerName SRV-SQL01 -Name MSSQLSERVER,SQLSERVERAGENT
   ```
   État: Running ✓
   
   Test connexion DB:
   ```powershell
   Test-DbaConnection -SqlInstance SRV-SQL01 -Database master
   ```
   Résultat: Success ✓

5. Installation updates sur SRV-DC01 (DC en dernier)
   Commande exécutée:
   ```powershell
   Install-WindowsUpdate -ComputerName SRV-DC01 -AcceptAll -AutoReboot -Verbose
   ```
   Résultat: 15 KB installés, reboot à 22:40
   
   Vérification réplication AD:
   ```powershell
   repadmin /replsummary
   repadmin /showrepl
   ```
   État: Réplication OK, aucun échec ✓

CONFIGURATIONS MODIFIÉES
-------------------------
Aucune configuration modifiée. Installation patches uniquement.

TESTS DE VALIDATION
--------------------
✓ Test 1: Ping de tous serveurs - SUCCÈS
✓ Test 2: Accès RDP à tous serveurs - SUCCÈS
✓ Test 3: Services critiques (AD, SQL, IIS, partages fichiers) - SUCCÈS
✓ Test 4: Accès applications métier depuis poste test - SUCCÈS
✓ Test 5: Vérification Event Logs (pas d'erreurs critiques) - SUCCÈS

Commande validation finale:
```powershell
$servers = @("SRV-DC01","SRV-APP01","SRV-SQL01","SRV-FILE01","SRV-WEB01")
$servers | ForEach-Object {
    Test-Connection $_ -Count 2 -Quiet
    Get-Service -ComputerName $_ | Where-Object {$_.Status -ne 'Running' -and $_.StartType -eq 'Automatic'}
}
```
Résultat: Tous serveurs accessibles, aucun service automatique arrêté ✓

RÉSULTAT FINAL
--------------
État: RÉSOLU AVEC SUCCÈS

Services vérifiés:
  ✓ Active Directory: Opérationnel (SRV-DC01)
  ✓ SQL Server: Opérationnel (SRV-SQL01)
  ✓ IIS Web Server: Opérationnel (SRV-WEB01)
  ✓ Partages fichiers: Accessibles (SRV-FILE01)
  ✓ Applications métier: Fonctionnelles (SRV-APP01)

Tous serveurs: Niveau patch février 2026 appliqué ✓

NOTES IMPORTANTES
-----------------
• SRV-SQL01: Reboot a pris 8 minutes (normal pour SQL Server avec DBs importantes)
• SRV-DC01: Réplication AD vérifiée - aucun problème
• Aucune erreur critique dans Event Logs post-patching
• Snapshots VMware conservés 72h par précaution

RECOMMANDATIONS TECHNIQUES
--------------------------
Court terme (< 1 mois):
  • Supprimer snapshots VMware après validation (dans 3 jours)
  • Surveiller performance SRV-SQL01 (monitoring habituel)

Moyen terme (1-3 mois):
  • Prochaine fenêtre patching: Mars 2026 (2e mardi du mois)

SUIVI REQUIS
------------
□ Surveillance dans 24h: Event Logs tous serveurs
□ Surveillance dans 1 semaine: Performance applications
□ Tâche planifiée: Suppression snapshots (2026-02-13)

TEMPS INTERVENTION
------------------
Temps total: 3 heures 15 minutes
  - Préparation: 15 min
  - Patching: 2h 40 min
  - Tests validation: 15 min
  - Documentation: 5 min

═══════════════════════════════════════════════════════════════
```

### Exemple 2: Troubleshooting VEEAM

```
═══════════════════════════════════════════════════════════════
INTERVENTION TECHNIQUE - TROUBLESHOOTING BACKUP VEEAM
═══════════════════════════════════════════════════════════════

INFORMATIONS GÉNÉRALES
----------------------
Date/Heure: 2026-02-10 09:30 - 11:15
Technicien: Eric Archambault
Client: Otto Inc Inc.
Ticket CW: CW-789457
Serveurs/Équipements: SRV-FILE01, VEEAM-SRV
Type intervention: Troubleshooting urgent (backup failed)

CONTEXTE INITIAL
----------------
Alerte VEEAM reçue: Job "Daily Backup - File Servers" a échoué cette nuit.
Erreur: "Insufficient disk space on backup repository"
Impact: Backup SRV-FILE01 non complété depuis 24h

ENVIRONNEMENT TECHNIQUE
-----------------------
Serveurs concernés:
  • SRV-FILE01: Windows Server 2022, [IP_CLIENTE], 2TB données
  • VEEAM-SRV: Windows Server 2022, [IP_CLIENTE]

Backup:
  • Solution: VEEAM Backup & Replication 12.1.2
  • Job: "Daily Backup - File Servers"
  • Repository: "Backup-Repo-01" (NAS Synology)
  • Rétention: 14 jours

DIAGNOSTIC / ANALYSE
--------------------
Vérification status job VEEAM:
```powershell
Get-VBRJob -Name "Daily Backup - File Servers" | Get-VBRJobSession | Select -Last 5
```

Résultat: Derniers 2 runs = Failed

Vérification espace repository:
```powershell
Get-VBRBackupRepository -Name "Backup-Repo-01" | Select Name, FreeSpace, Capacity
```

Résultat:
  • Capacity: 10TB
  • FreeSpace: 45GB (0.45% libre) ⚠️
  • Threshold: 50GB minimum recommandé

Erreurs observées:
  • Event Log VEEAM: ID 190, "Insufficient disk space"
  • Job log: "Cannot write to backup file, disk full"

Causes identifiées:
  • Repository presque plein (99.55% utilisé)
  • Anciens backups pas supprimés automatiquement
  • GFS policy pas appliquée correctement

ACTIONS TECHNIQUES DÉTAILLÉES
------------------------------

1. Vérification retention policy
   ```powershell
   Get-VBRJob -Name "Daily Backup - File Servers" | Select RetentionPolicy
   ```
   Résultat: 14 restore points (correct)

2. Identification backup points à supprimer
   ```powershell
   Get-VBRBackup | Where-Object {$_.JobName -eq "Daily Backup - File Servers"} | 
       Get-VBRRestorePoint | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-14)}
   ```
   Résultat: 8 restore points > 14 jours trouvés

3. Suppression manuelle anciens restore points
   ```powershell
   $oldPoints = Get-VBRBackup | Where-Object {$_.JobName -eq "Daily Backup - File Servers"} | 
       Get-VBRRestorePoint | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-14)}
   
   $oldPoints | ForEach-Object { Remove-VBRRestorePoint -RestorePoint $_ -Confirm:$false }
   ```
   Résultat: 8 restore points supprimés, 1.2TB libéré ✓

4. Vérification espace post-cleanup
   ```powershell
   Get-VBRBackupRepository -Name "Backup-Repo-01" | Select FreeSpace
   ```
   Résultat: FreeSpace = 1.25TB (12.5% libre) ✓

5. Relance job backup manuellement
   ```powershell
   Start-VBRJob -Job (Get-VBRJob -Name "Daily Backup - File Servers")
   ```
   Résultat: Job démarré

6. Surveillance job en cours
   ```powershell
   Get-VBRJob -Name "Daily Backup - File Servers" | Get-VBRJobSession -Last | 
       Select State, Progress, @{N="Duration";E={(Get-Date) - $_.CreationTime}}
   ```
   Monitoring: Job complété après 45 minutes ✓

CONFIGURATIONS MODIFIÉES
-------------------------
Correction automation retention:

Avant:
  • Compact full backup file: Disabled

Après:
  • Compact full backup file: Enabled
  • Run immediately: Yes

Raison: Assurer suppression automatique anciens points

TESTS DE VALIDATION
--------------------
✓ Test 1: Job backup complété sans erreur - SUCCÈS
✓ Test 2: Espace repository > 10% - SUCCÈS (12.5%)
✓ Test 3: Restore point créé - SUCCÈS
✓ Test 4: Test restore 1 fichier - SUCCÈS

RÉSULTAT FINAL
--------------
État: RÉSOLU

Services vérifiés:
  ✓ VEEAM Backup Service: Running
  ✓ Repository accessible: OK
  ✓ Job planifié prochaine exécution: 2026-02-11 00:00

NOTES IMPORTANTES
-----------------
• Problème causé par échec automatic cleanup
• Compact full backup désactivé (?)
• Repository à surveiller mensuellement
• Envisager augmentation capacité dans 6 mois

RECOMMANDATIONS TECHNIQUES
--------------------------
Court terme (< 1 mois):
  • Surveiller espace repository hebdomadairement
  • Vérifier que compact runs correctement

Moyen terme (1-3 mois):
  • Review retention policy (peut-être réduire à 10 jours?)

Long terme (> 3 mois):
  • Planifier expansion repository (actuel 10TB → 15TB)
  • Considérer archivage vieux backups sur stockage froid

SUIVI REQUIS
------------
□ Surveillance dans 24h: Vérifier job ce soir
□ Surveillance dans 1 semaine: Espace repository
□ Tâche planifiée: Review capacity (2026-08-01)

RÉFÉRENCES / LIENS UTILES
--------------------------
• KB VEEAM: https://www.veeam.com/kb2197
• Ticket lié: CW-789450 (Installation VEEAM initiale)

TEMPS INTERVENTION
------------------
Temps total: 1 heure 45 minutes
  - Diagnostic: 20 min
  - Résolution: 60 min (cleanup + backup run)
  - Tests: 15 min
  - Documentation: 10 min

═══════════════════════════════════════════════════════════════
```

## Règles importantes

### ✅ À INCLURE
- Commandes PowerShell EXACTES utilisées
- Outputs/résultats des commandes
- Codes erreur Event Log avec ID et source
- IPs, credentials (si nécessaire pour reproduction)
- Tous détails techniques pertinents
- Screenshots d'erreurs si applicable

### ❌ À ÉVITER
- Langage vague ou générique
- Omettre commandes critiques
- Oublier détails environnement
- Ne pas documenter tests validation

## Utilisation comme base de connaissance

Cette note doit permettre à un autre technicien de:
1. Comprendre exactement ce qui a été fait
2. Reproduire l'intervention si nécessaire
3. Troubleshooter problèmes similaires
4. Apprendre de l'expérience

---

*Template version 1.0 - IT-MaintenanceMaster*


---
<!-- SOURCE: TEMPLATE_CW_Discussion-STAR_V1 -->
## TEMPLATE — CW Discussion STAR

# TEMPLATE: CW_DISCUSSION (Note ConnectWise - Facturable)

## Objectif
Générer un résumé en bullet points qui apparaîtra sur la facture client. Doit être:
- ✅ Format STAR
- ✅ Clair et concis
- ✅ Sans informations sensibles (mots de passe, IPs internes, détails sécurité)
- ✅ Orienté valeur/résultats

## Format

```
INTERVENTION: [Type d'intervention]
DATE: [Date]
TECHNICIEN: [Nom ou initiales]

TRAVAUX EFFECTUÉS:
• [Action 1 - résultat client-visible]
• [Action 2 - résultat client-visible]
• [Action 3 - résultat client-visible]
• [Action 4 - résultat client-visible]

RÉSULTAT:
• [Impact positif pour le client]
• [Confirmation de bon fonctionnement]

[Optionnel] RECOMMANDATION:
• [Suggestion pour le client]
```

## Exemples par type d'intervention

### Exemple 1: Patching de serveurs

```
INTERVENTION: Maintenance serveurs (mises à jour sécurité)
DATE: 2026-02-10
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Vérification pré-déploiement
• Vérification de l'état des dernières sauvegardes, prise de Snapshot
• Vérification de l'état général des serveurs, services en cours et fichiers journaux
• Installation des mises à jour de sécurité Microsoft sur 5 serveurs
• Redémarrages planifiés et supervisés hors heures d'affaires
• Vérification du bon démarrage de tous les services critiques
• Tests de connectivité et accessibilité des applications

RÉSULTAT:
• Tous les serveurs à jour avec les derniers correctifs de sécurité
• Aucun impact sur les opérations de l'entreprise
• Services opérationnels confirmés

RECOMMANDATION:
• Prochaine fenêtre de maintenance recommandée: Mars 2026
```

### Exemple 2: Troubleshooting backup

```
INTERVENTION: Résolution problème de sauvegarde
DATE: 2026-02-10
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Prise de connaissance de la demande et connexion à la documentation
• Connexion au serveur de sauvegarde
• Diagnostic de l'échec de sauvegarde du serveur SRV-FILE01
• Résolution du problème d'espace disque sur le dépôt de backup
• Lancement manuel de la sauvegarde et vérification de la réussite
• Mise en place d'alertes pour prévenir futures occurrences

RÉSULTAT:
• Sauvegarde fonctionnelle et complétée avec succès
• Espace libéré sur le dépôt (ancien backups archivés)
• Alertes configurées pour prévenir le problème

RECOMMANDATION:
• Envisager augmentation capacité stockage backup d'ici 3 mois
```

### Exemple 3: Maintenance réseau

```
INTERVENTION: Mise à jour équipements réseau
DATE: 2026-02-10
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Prise de connaissance de la demande et connexion à la documentation
• Mise à jour firmware du pare-feu Watchguard
• Application des correctifs de sécurité recommandés
• Vérification de la configuration post-mise à jour
• Tests de connectivité Internet et VPN

RÉSULTAT:
• Pare-feu mis à jour avec dernières protections de sécurité
• Connectivité confirmée (Internet, VPN, accès distant)
• Aucune interruption de service observée
```

### Exemple 4: Audit/Vérification

```
INTERVENTION: Audit de l'infrastructure serveurs
DATE: 2026-02-10
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Vérification de l'état de santé de 8 serveurs
• Contrôle de l'espace disque disponible
• Analyse des journaux d'événements (30 derniers jours)
• Vérification du statut des services critiques

RÉSULTAT:
• Infrastructure en bon état général
• Quelques alertes mineures identifiées et résolues
• Aucun problème critique détecté

RECOMMANDATION:
• Prévoir nettoyage fichiers temporaires sur SRV-APP01 (espace 85%)
```

### Exemple 5: Intervention d'urgence

```
INTERVENTION: Intervention urgente - Serveur inaccessible
DATE: 2026-02-10
TECHNICIEN: EA

TRAVAUX EFFECTUÉS:
• Diagnostic du serveur SRV-APP01 non accessible
• Redémarrage du serveur via console hyperviseur
• Vérification et correction de l'erreur de démarrage du service
• Restauration complète de l'accessibilité

RÉSULTAT:
• Serveur restauré et fonctionnel
• Services applicatifs redémarrés avec succès
• Utilisateurs peuvent accéder à nouveau aux applications

RECOMMANDATION:
• Surveillance renforcée du serveur sur 48h
• Analyse approfondie planifiée pour identifier cause racine
```

## Règles importantes

### ✅ À FAIRE
- Utiliser langage simple et compréhensible
- Mentionner résultats concrets
- Indiquer impacts positifs pour le client
- Être factuel et précis
- Inclure recommandations si pertinent

### ❌ À ÉVITER
- Jargon technique excessif
- Détails d'implémentation (ports, IPs, commandes)
- Informations sensibles (credentials, vulnérabilités)
- Blâmer ou critiquer
- Promesses non vérifiées

## Variables à personnaliser

```yaml
type_intervention: "[Maintenance/Troubleshooting/Audit/Urgence/...]"
date: "[YYYY-MM-DD]"
technicien: "[Initiales ou nom]"
travaux: "[Liste bullet points 3-6 items]"
resultat: "[Impact client 1-3 points]"
recommandation: "[Optionnel - 1-2 points]"
```

## Longueur recommandée
- **Minimum:** 4-5 bullet points
- **Idéal:** 6-8 bullet points
- **Maximum:** 10 bullet points

**Note:** Le client VOIT cette note sur sa facture. Elle doit démontrer la valeur du travail effectué tout en restant professionnelle et appropriée.

---

*Template version 1.0 - IT-MaintenanceMaster*


---
<!-- SOURCE: TEMPLATE_CW_Email-Client_V1 -->
## TEMPLATE — Email Client

# TEMPLATE: EMAIL_CLIENT (Notification client)

## Objectif
Générer un email professionnel pour notifier le client après une intervention. Doit être:
- ✅ Professionnel et rassurant
- ✅ Clair sur ce qui a été fait et le résultat
- ✅ Client-friendly (non-technique sauf si demandé)
- ✅ Inclure prochaines étapes si applicable

## Format

```
Objet: [Type intervention] - [Résultat] - [Système/Serveur]

Bonjour [Prénom],

[Paragraphe d'introduction - contexte]

[Paragraphe résumé travaux]

[Paragraphe résultat/statut]

[Optionnel: Paragraphe recommandations]

[Paragraphe conclusion]

Cordialement,
[Nom]
[Titre]
[Entreprise]
[Téléphone]
```

## Exemples par type d'intervention

### Exemple 1: Maintenance planifiée réussie

```
Objet: Maintenance serveurs complétée avec succès - Otto Inc

Bonjour Marie,

Je vous confirme que la maintenance planifiée de vos serveurs s'est déroulée 
sans incident cette nuit, de 20h00 à 23h15.

Nous avons installé les mises à jour de sécurité Microsoft de février 2026 
sur vos 5 serveurs (DC, App, SQL, File, Web). Chaque serveur a été redémarré 
et tous les services ont été vérifiés. Les applications métier ont été testées 
et sont pleinement fonctionnelles.

Résultat: Vos serveurs sont maintenant à jour avec les derniers correctifs de 
sécurité. Aucun problème n'a été rencontré et vos opérations peuvent continuer 
normalement ce matin.

La prochaine fenêtre de maintenance est prévue pour mars 2026. Nous vous 
contacterons 2 semaines à l'avance pour planifier la date exacte.

N'hésitez pas si vous avez des questions ou si vous constatez quoi que ce soit 
d'inhabituel.

Cordialement,
Eric Archambault
Technicien sénior
MSP TechServices
(514) 555-0100
```

### Exemple 2: Troubleshooting réussi

```
Objet: Problème de sauvegarde résolu - SRV-FILE01

Bonjour Pierre,

Suite à l'alerte de ce matin concernant l'échec de sauvegarde du serveur 
SRV-FILE01, je vous confirme que le problème a été identifié et résolu.

Le problème était causé par un manque d'espace sur le système de sauvegarde. 
Nous avons nettoyé les anciennes sauvegardes selon la politique de rétention 
et relancé la sauvegarde manuellement. Celle-ci s'est complétée avec succès.

Résultat: Votre serveur de fichiers est maintenant sauvegardé correctement et 
nous avons mis en place des alertes pour prévenir ce type de situation à l'avenir.

Recommandation: L'espace de stockage pour les sauvegardes approche sa capacité 
maximale (87% utilisé). Nous recommandons de planifier une expansion du stockage 
d'ici 3-4 mois pour assurer la continuité des sauvegardes.

Je reste disponible si vous souhaitez discuter de cette recommandation ou si 
vous avez des questions.

Cordialement,
Eric Archambault
Technicien sénior
MSP TechServices
(514) 555-0100
```

### Exemple 3: Intervention d'urgence

```
Objet: Intervention urgente complétée - SRV-APP01 restauré

Bonjour Sophie,

Je vous confirme que le serveur SRV-APP01 qui était inaccessible depuis 14h30 
a été restauré et est maintenant pleinement opérationnel.

Nous avons diagnostiqué un problème de service critique qui ne démarrait plus 
automatiquement. Le serveur a été redémarré et le service a été reconfiguré 
pour assurer un démarrage fiable. Nous avons testé l'accès à vos applications 
et tout fonctionne normalement.

Résultat: Le serveur est opérationnel depuis 15:45. Vos utilisateurs peuvent 
accéder à nouveau aux applications sans restriction.

Pour prévenir une récurrence, nous allons surveiller ce serveur de près pendant 
48 heures et effectuer une analyse approfondie pour identifier la cause racine 
du problème. Je vous tiendrai informée des résultats.

Merci de votre patience durant cette interruption. N'hésitez pas à nous contacter 
si vous constatez quelque chose d'anormal.

Cordialement,
Eric Archambault
Technicien sénior
MSP TechServices
(514) 555-0100
```

### Exemple 4: Mise à jour équipement réseau

```
Objet: Mise à jour pare-feu complétée - Watchguard

Bonjour Marc,

La mise à jour de votre pare-feu Watchguard prévue pour ce soir s'est déroulée 
avec succès, sans interruption de vos opérations.

Nous avons installé la dernière version du firmware qui inclut d'importantes 
améliorations de sécurité et corrections de vulnérabilités. Les règles de 
pare-feu, la configuration VPN et tous vos accès distants ont été vérifiés et 
fonctionnent correctement.

Résultat: Votre pare-feu est maintenant à jour avec les dernières protections. 
Aucun changement n'affecte vos utilisateurs - tout fonctionne exactement comme 
avant, mais de façon plus sécurisée.

Cette mise à jour renforce la sécurité de votre réseau contre les menaces 
récemment découvertes. Aucune action n'est requise de votre part.

Si vous ou vos utilisateurs constatez quelque chose d'inhabituel dans les 
prochains jours, n'hésitez pas à nous contacter immédiatement.

Cordialement,
Eric Archambault
Technicien sénior
MSP TechServices
(514) 555-0100
```

### Exemple 5: Audit/Vérification

```
Objet: Audit infrastructure complété - Otto Inc

Bonjour Christine,

Tel que prévu, nous avons effectué un audit de santé de votre infrastructure 
serveurs ce matin.

Nous avons vérifié l'état de vos 8 serveurs, analysé l'utilisation des 
ressources (CPU, mémoire, espace disque), examiné les journaux d'événements 
des 30 derniers jours et contrôlé le statut de tous les services critiques.

Résultat: Votre infrastructure est en bon état général. Nous avons identifié 
et corrigé quelques alertes mineures. Aucun problème critique n'a été détecté.

Recommandation: Le serveur SRV-APP01 utilise 85% de son espace disque. Nous 
recommandons un nettoyage des fichiers temporaires dans les prochaines 2 semaines 
pour éviter tout problème d'espace. Nous pouvons effectuer cette opération lors 
de votre prochaine fenêtre de maintenance.

Je vous enverrai le rapport détaillé d'audit par email séparé d'ici demain 
en fin de journée.

N'hésitez pas si vous avez des questions sur les résultats de cet audit.

Cordialement,
Eric Archambault
Technicien sénior
MSP TechServices
(514) 555-0100
```

### Exemple 6: Maintenance avec impacts mineurs

```
Objet: Maintenance SQL Server complétée - Redémarrage plus long que prévu

Bonjour Daniel,

La maintenance de votre serveur SQL (SRV-SQL01) prévue hier soir s'est bien 
déroulée, bien que le redémarrage ait pris un peu plus de temps que prévu.

Nous avons installé les mises à jour critiques SQL Server 2022. Le redémarrage 
a duré environ 12 minutes au lieu des 5 minutes habituelles, en raison de la 
taille de vos bases de données. C'est parfaitement normal pour un serveur SQL 
de cette envergure.

Résultat: SQL Server est maintenant à jour et fonctionne normalement. Toutes 
vos bases de données sont en ligne et accessibles. Nous avons testé les 
connexions et les performances sont excellentes.

Le temps de redémarrage prolongé n'a pas d'impact sur vos opérations car 
l'intervention était planifiée hors heures d'affaires. Tout est rentré dans 
l'ordre ce matin comme prévu.

Merci de votre confiance. N'hésitez pas si vous avez des questions.

Cordialement,
Eric Archambault
Technicien sénior
MSP TechServices
(514) 555-0100
```

### Exemple 7: Problème partiellement résolu

```
Objet: Intervention en cours - Problème backup partiellement résolu

Bonjour Nathalie,

Suite au problème de sauvegarde signalé ce matin, je voulais vous donner une 
mise à jour sur l'avancement.

Nous avons identifié la cause du problème (espace disque insuffisant sur le 
système de backup) et libéré de l'espace. La sauvegarde fonctionne maintenant 
pour la plupart de vos serveurs. Toutefois, nous continuons à investiguer un 
problème spécifique sur le serveur SRV-APP02.

Statut actuel:
• SRV-FILE01: Backup fonctionnel ✓
• SRV-SQL01: Backup fonctionnel ✓
• SRV-DC01: Backup fonctionnel ✓
• SRV-APP02: En cours d'investigation (erreur différente)

Nous travaillons activement sur SRV-APP02 et prévoyons résoudre le problème 
d'ici la fin de journée. Je vous tiendrai informée dès que tout sera résolu.

Vos données critiques sur les 3 autres serveurs sont maintenant protégées. 
Le problème restant n'affecte pas vos opérations quotidiennes.

Je vous recontacte dès que l'intervention est complétée.

Cordialement,
Eric Archambault
Technicien sénior
MSP TechServices
(514) 555-0100
```

## Règles importantes

### ✅ À FAIRE
- Utiliser prénom du contact (personnalisé)
- Commencer par contexte clair
- Expliquer ce qui a été fait (vulgarisé)
- Indiquer résultat/impact
- Mentionner prochaines étapes si applicable
- Ton professionnel mais accessible
- Offrir disponibilité pour questions

### ❌ À ÉVITER
- Jargon technique excessif
- Détails trop techniques non sollicités
- Blâmer ou critiquer
- Créer inquiétude inutile
- Promesses non réalistes
- Ton trop décontracté

## Variantes de ton selon situation

**Maintenance réussie:** ✅ Ton rassurant et positif
**Problème résolu:** ✅ Ton professionnel et confiant
**Urgence résolue:** ✅ Ton empathique et transparent
**Problème en cours:** ⚠️ Ton honnête mais rassurant
**Recommandation importante:** 💡 Ton consultatif

## Variables à personnaliser

```yaml
destinataire_prenom: "[Prénom]"
type_intervention: "[Maintenance/Troubleshooting/Audit/Urgence]"
systemes_concernes: "[Serveurs/Équipements]"
resume_travaux: "[Ce qui a été fait]"
resultat: "[Statut actuel]"
recommandations: "[Si applicable]"
prochaines_etapes: "[Si applicable]"
signature_nom: "[Nom complet]"
signature_titre: "[Titre/Rôle]"
signature_entreprise: "[Nom entreprise]"
signature_telephone: "[(XXX) XXX-XXXX]"
```

## Longueur recommandée
- **Minimum:** 3 paragraphes
- **Idéal:** 4-5 paragraphes
- **Maximum:** 6 paragraphes

**Note:** Email doit être lu en < 2 minutes. Aller droit au but tout en étant complet.

---

*Template version 1.0 - IT-MaintenanceMaster*


---
<!-- SOURCE: TEMPLATE_SUPPORT_Escalade-et-Service-Restaure_V1 -->
## TEMPLATE — Blocs Escalade et Service Restauré

# TEMPLATE_SUPPORT_Escalade-et-Service-Restaure_V1
**Agent :** IT-Assistant-N2, IT-Assistant-N3
**Usage :** Blocs CW à coller avant transfert d'un billet + confirmation service rétabli
**Mis à jour :** 2026-03-20

---

## PARTIE 1 — BLOC ESCALADE NOC (à coller dans CW avant transfert)

```
═══════════════════════════════════════════════
TRANSFERT → DÉPARTEMENT NOC
Billet : #[XXXXXX] | Priorité : P[1/2]
Technicien : [NOM] | [YYYY-MM-DD HH:MM]
═══════════════════════════════════════════════

SYMPTÔME
[Description précise]

IMPACT IMMÉDIAT
• Utilisateurs affectés : [Nombre / Qui]
• Services impactés    : [Liste]
• Heure de début       : [HH:MM]

RISQUES À VENIR SI NON TRAITÉ
• [Risque 1]
• [Risque 2]

ASSETS AFFECTÉS
• [Asset 1]
• [Asset 2]

ACTIONS DÉJÀ TENTÉES (N2/N3)
1. [Action — résultat]
2. [Action — résultat]
═══════════════════════════════════════════════
```

---

## PARTIE 2 — BLOC ESCALADE SOC

```
═══════════════════════════════════════════════
TRANSFERT → DÉPARTEMENT SOC
Billet : #[XXXXXX] | Priorité : P[1/2]
Technicien : [NOM] | [YYYY-MM-DD HH:MM]
═══════════════════════════════════════════════

TYPE : ☐ Phishing/Compromission  ☐ Ransomware  ☐ Breach  ☐ Autre

COMPTE/ASSET AFFECTÉ
• [Utilisateur / Asset — voir Passportal pour credentials]
• Heure de détection : [HH:MM]

SYMPTÔMES OBSERVÉS
• [Symptôme 1]
• [Symptôme 2]

ACTIONS IMMÉDIATES EFFECTUÉES (N2/N3)
☐ Compte désactivé
☐ Sessions révoquées
☐ MDP réinitialisé (voir Passportal)

VÉRIFICATIONS À COMPLÉTER PAR LE SOC
☐ Règles Outlook suspectes
☐ Transferts automatiques
☐ Activité connexion 7 derniers jours
☐ Propagation — autres comptes
═══════════════════════════════════════════════
```

---

## PARTIE 3 — BLOC ESCALADE TECH (Senior/RCA)

```
═══════════════════════════════════════════════
TRANSFERT → DÉPARTEMENT TECH (Support N3+)
Billet : #[XXXXXX] | Priorité : P[1/2/3]
Technicien N2 : [NOM] | [YYYY-MM-DD HH:MM]
Durée intervention N2 : [X min]
═══════════════════════════════════════════════

PROBLÉMATIQUE
[Description complète]

CE QUI A ÉTÉ TENTÉ
1. [Action — résultat]
2. [Action — résultat]
3. [Action — résultat]

HYPOTHÈSE ACTUELLE
[Ce que le technicien pense être la cause]

CLIENT EN ATTENTE : ☐ Oui  ☐ Non
SLA À RISQUE      : ☐ Oui  ☐ Non
═══════════════════════════════════════════════
```

---

## PARTIE 4 — CONFIRMATION SERVICE RÉTABLI (CW Discussion + Teams)

### CW Discussion (client-safe)
```
RÉSOLUTION : [Type de service] rétabli
DATE : [YYYY-MM-DD] | TECHNICIEN : [Initiales]

TRAVAUX EFFECTUÉS :
• Analyse du service et vérifications de l'environnement
• [Action corrective 1 — description fonctionnelle sans détails techniques sensibles]
• [Action corrective 2]
• Contrôles de bon fonctionnement effectués

RÉSULTAT :
• [Service X] : pleinement opérationnel depuis [HH:MM]
• Monitoring confirmé — aucune alerte active

RECOMMANDATION :
• [Si applicable — ex: planifier une mise à jour de prévention]
```

### Annonce Teams
```
✅ Service rétabli — [Nom du service] | [DATE] [HH:MM]
Billet #[XXXXXX] — [Technicien]
[Description 1 ligne de la résolution]
```


---
<!-- SOURCE: TEMPLATE_INCIDENT_Log-et-Critique_V1 -->
## TEMPLATE — Journal Incident et Fiche Critique P1

# TEMPLATE_INCIDENT_Log-et-Critique_V1
**Agent :** IT-Assistant-N3, IT-MaintenanceMaster, IT-Commandare-NOC
**Usage :** Journal d'incident temps réel (P1/P2) + fiche incident critique
**Mis à jour :** 2026-03-20

---

## PARTIE 1 — JOURNAL D'INCIDENT (TIMELINE)

```
═══════════════════════════════════════════════
JOURNAL D'INCIDENT — TEMPS RÉEL
Billet CW   : #[XXXXXX]
Client      : [NOM]
Type        : [NOC / SOC / SUPPORT]
Priorité    : P[1/2]
Technicien  : [NOM]
Débuté à    : [YYYY-MM-DD HH:MM]
═══════════════════════════════════════════════

SYMPTÔME INITIAL
[Description précise — ce que l'utilisateur/monitoring a signalé]

ASSETS AFFECTÉS
→ [Serveur/équipement 1]
→ [Serveur/équipement 2]

IMPACT
Utilisateurs affectés : [Nombre / qui]
Services indisponibles : [Liste]

─────────────────────────────────────────────
TIMELINE

[HH:MM] — [FAIT] — [Description action + résultat]
[HH:MM] — [FAIT] — [Description action + résultat]
[HH:MM] — [SUGGESTION] — [Description action à valider]
[HH:MM] — [À CONFIRMER] — [Information manquante]
[HH:MM] — [ESCALADE] — Département [NOC/SOC/INFRA/TECH] notifié

─────────────────────────────────────────────
VALIDATIONS FINALES

Services critiques    : ✅ OK / ❌ KO / [À CONFIRMER]
Monitoring           : ✅ OK / ❌ KO / [À CONFIRMER]
Backups (si applicable) : ✅ OK / ❌ KO / [À CONFIRMER]
Validation utilisateur  : ✅ OK / ❌ KO / [À CONFIRMER]

STATUT FINAL : [RÉSOLU / PARTIEL / ESCALADÉ]
Résolu à    : [HH:MM]
Durée totale : [X heures Y min]
═══════════════════════════════════════════════
```

---

## PARTIE 2 — FICHE INCIDENT CRITIQUE (P1)

```
═══════════════════════════════════════════════
INCIDENT CRITIQUE — P1
Billet CW      : #[XXXXXX]
Client         : [NOM]
Date/Heure     : [YYYY-MM-DD HH:MM]
Technicien N2/N3 : [NOM]
Département notifié : [NOC / SOC / INFRA / TECH]
═══════════════════════════════════════════════

DESCRIPTION
[Ce qui s'est passé — 2-3 phrases claires]

INDICATEURS DE CRITICITÉ
☐ Ransomware / chiffrement actif
☐ Breach / compromission compte admin
☐ DC / AD inaccessible
☐ Réseau site entier down
☐ Perte de données en cours
☐ > 20 utilisateurs impactés
☐ Autre : [préciser]

ACTIONS IMMÉDIATES EFFECTUÉES
1. [Action — résultat]
2. [Action — résultat]

ÉTAT ACTUEL
[Description de la situation au moment du transfert]

RISQUES SI NON TRAITÉ IMMÉDIATEMENT
→ [Risque 1]
→ [Risque 2]
═══════════════════════════════════════════════
```


---
<!-- SOURCE: CHECKLIST_CW_Kickoff-Ticket_V1 -->
## CHECKLIST — Kickoff Ticket

# CHECKLIST — KICKOFF (Ticket MSP)

Copier-coller et remplir au début :

- Ticket: #
- Client: 
- Type: NOC | Support | Change | Maintenance
- Fenêtre: (Début–Fin + TZ)
- Urgence/SLA: 
- Scope (serveurs/services): 
- Contraintes: (prod, VIP, no-touch, 1 serveur critique à la fois, etc.)
- Risques connus: 
- Objectif (succès): 
- Outils: (RMM/VPN/Portal)



---
<!-- SOURCE: CHECKLIST_CW_Closeout_V1 -->
## CHECKLIST — Closeout CW

# CHECKLIST — CLOSEOUT (ConnectWise)

- [ ] CW_NOTE_INTERNE : timeline + commandes + outputs + décisions + suivis
- [ ] CW_DISCUSSION (STAR) : facturable, concis, sans IP
- [ ] Email client : clair + résultat + suivi
- [ ] Teams : début/fin
- [ ] KB draft (si récurrent)



---
<!-- SOURCE: CHECKLIST_SUPPORT_Intervention-Steps_V1 -->
## CHECKLIST — Étapes Intervention

# CHECKLIST_SUPPORT_Intervention-Steps_V1
**Agent :** IT-Assistant-N2, IT-Assistant-N3, IT-MaintenanceMaster
**Usage :** Déroulement standard d'une intervention MSP de bout en bout
**Mis à jour :** 2026-03-20

---

## PHASE 1 — KICKOFF (5 min)

- [ ] Lire le billet CW complet (ne pas sauter cette étape)
- [ ] Identifier : client, type, priorité P[1/2/3/4], assets concernés
- [ ] Consulter la documentation client dans Hudu (fiche objet IT si applicable)
- [ ] Vérifier les notes précédentes sur le billet
- [ ] Confirmer la fenêtre de maintenance et les approbations si applicable

## PHASE 2 — PRECHECK (lecture seule)

- [ ] Ping / RMM : asset accessible ?
- [ ] Resources : CPU, RAM, espace disque
- [ ] Services critiques démarrés
- [ ] Pending reboot
- [ ] Event Logs : erreurs récentes (2-48h selon le contexte)
- [ ] Backups : dernier job OK ?
- [ ] Snapshot créé si action risquée

## PHASE 3 — INTERVENTION

- [ ] **Une action à la fois** — documenter chaque action dans le journal CW au fil de l'eau
- [ ] Valider le résultat de chaque action avant de passer à la suivante
- [ ] Tagger **[À CONFIRMER]** toute action sans preuve immédiate
- [ ] Si la situation se dégrade → réévaluer la priorité → escalader si P2→P1
- [ ] Ne pas improviser hors scope sans documenter et obtenir validation

## PHASE 4 — POSTCHECK (validation)

- [ ] Services critiques : OK
- [ ] Connectivité / accès utilisateurs : OK
- [ ] Application ou service cible : fonctionnel et testé
- [ ] Event Logs post-action : aucune nouvelle erreur critique
- [ ] Monitoring : retour au vert (aucune alerte active anormale)
- [ ] Backups : pas d'impact sur les jobs planifiés
- [ ] Snapshot supprimé (si créé en PRECHECK et intervention validée)

## PHASE 5 — CLOSEOUT

- [ ] CW Note Interne : timeline + actions + preuves + validations
- [ ] CW Discussion : client-safe, facturable, sans IP ni détail sensible
- [ ] Email client (si requis) : résultat fonctionnel + prochaine étape
- [ ] Teams : annonce fin de maintenance (si applicable)
- [ ] Mode maintenance RMM désactivé
- [ ] KB créé ou mis à jour (si incident récurrent ou nouvelle procédure)
- [ ] Billet CW fermé avec statut correct
