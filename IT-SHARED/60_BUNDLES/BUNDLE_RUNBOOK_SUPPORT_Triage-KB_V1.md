# BUNDLE RUNBOOK SUPPORT Triage-KB V1
**Type :** Bundle Runbook — Assemblage complet
**Agents :** IT-Assistant-N2, IT-Assistant-N3, IT-TicketScribe, IT-KnowledgeKeeper | IT-MaintenanceMaster | IT-SysAdmin
**Description :** Support MSP — Triage N1/N2/N3, Ticket-to-KB, Gestion tickets CW
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
<!-- SOURCE: RUNBOOK__IT_MSP_TICKET_TO_KB -->
## RUNBOOK — Ticket MSP vers KB (Ticket-to-KB)

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
2. **support** → `IT-Assistant-N3`
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

- **Acteur** : `IT-Assistant-N3`

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
<!-- SOURCE: RUNBOOK__IT_MSP_CONNECTWISE_DISPATCH_V1 -->
## RUNBOOK — CW Dispatch (Types et Subtypes)

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
<!-- SOURCE: TEMPLATE_KNOWLEDGE_KB-Article-et-Procedure_V1 -->
## TEMPLATE — Article KB et Nouvelle Procédure

# TEMPLATE_KNOWLEDGE_KB-Article-et-Procedure_V1
**Agent :** IT-KnowledgeKeeper, IT-Assistant-N3
**Usage :** Article KB réutilisable + documentation d'une nouvelle procédure
**Mis à jour :** 2026-03-20

---

## PARTIE 1 — ARTICLE KB

```
═══════════════════════════════════════════════
ARTICLE KB — [TITRE COURT ET DESCRIPTIF]
ID            : KB-[YYYYMMDD]-[NNN]
Catégorie     : [Windows / AD / M365 / Réseau / Backup / Sécurité / Autre]
Système       : [Windows Server 20XX / Exchange Online / etc.]
Niveau tech   : N1 / N2 / N3
Temps estimé  : [X min]
Récurrence    : ☐ Fréquent  ☐ Occasionnel  ☐ Rare
Créé par      : [Technicien]  | Date : [YYYY-MM-DD]
Billet source : #[XXXXXX]
═══════════════════════════════════════════════

SYMPTÔMES OBSERVÉS
• [Ce que le technicien ou l'utilisateur voit — exact et précis]
• [Symptôme 2 si applicable]

CAUSE RACINE IDENTIFIÉE
[La VRAIE cause — pas le symptôme visible.
Ex: Une tâche planifiée GPO lançait gpupdate.exe toutes les 4h,
les processus s'empilaient → CPU 100%]

SOLUTION
Étapes de résolution :
1. [Action 1 — précise et actionnable]
   ✅ Validation : [Ce qu'on doit voir/observer]
2. [Action 2]
   ✅ Validation : [...]
3. [Action 3]

COMMANDES CLÉS
```powershell
# [Description de ce que fait la commande]
[Commande exacte utilisée]
```

POINTS D'ATTENTION
⛔ NE PAS [action à éviter] — Raison : [conséquence]
⚠️ [Point de vigilance — ex: redémarrer ce service peut impacter les sessions RDS actives]

VALIDATIONS FINALES
[ ] [Test de validation 1]
[ ] [Test de validation 2]

TAGS : [windows] [AD] [performance] [gpupdate] [etc.]
═══════════════════════════════════════════════
```

---

## PARTIE 2 — NOUVELLE PROCÉDURE

```
═══════════════════════════════════════════════
PROCÉDURE — [TITRE]
ID            : PROC-[YYYYMMDD]-[NNN]
Catégorie     : [Maintenance / Support / Sécurité / Backup / Réseau]
Applicabilité : [Tous clients / Client spécifique : NOM]
Niveau requis : N1 / N2 / N3
Durée estimée : [X min]
Créé par      : [Technicien] | Date : [YYYY-MM-DD]
Approuvé par  : [Superviseur / Lead]
═══════════════════════════════════════════════

OBJECTIF
[En 1-2 phrases : pourquoi cette procédure existe et quand l'utiliser]

DÉCLENCHEURS
• [Situation 1 qui nécessite cette procédure]
• [Situation 2]

PRÉREQUIS
[ ] [Accès requis / outils requis]
[ ] [Autorisation requise]
[ ] [Autre prérequis]

ÉTAPES
1. [Action précise]
   ✅ Validation : [Ce qu'on doit observer]
   ⛔ NE PAS : [Action interdite dans ce contexte]
2. [Action suivante]
3. [...]

ROLLBACK (si applicable)
[Comment annuler si quelque chose se passe mal]

DOCUMENTATION
[ ] Documenter dans CW : Note interne avec résultats
[ ] Mettre à jour Hudu si applicable
[ ] Créer un KB si nouveau type de problème résolu
═══════════════════════════════════════════════
```


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

