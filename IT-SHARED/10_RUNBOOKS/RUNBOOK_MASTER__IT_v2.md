# RUNBOOK_MASTER__IT_v2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster
**Département :**  | **Source :** IT MSP Intelligence Platform

---

# Guide complet pour techniciens N1 → N3 — Support & Maintenance MSP
**Version :** 1.0 | **Date :** 2026-03-15
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Source :** 39 fichiers → 8 stubs exclus → 31 runbooks uniques fusionnés
**Usage :** Ce document est la référence unique pour tous les scénarios d'intervention.
            Charger en knowledge dans IT-Assistant-N3 (GPT Enterprise).

---

## ⚠️ RÈGLES NON NÉGOCIABLES — À LIRE EN PREMIER

```
1. LECTURE SEULE AVANT TOUTE REMÉDIATION
   Toujours collecter et diagnostiquer avant d'agir.

2. VALIDATION EXPLICITE OBLIGATOIRE avant :
   - Tout reboot / redémarrage de service
   - Toute suppression de données ou d'objet
   - Toute isolation réseau
   - Toute modification AD critique

3. 1 SERVEUR CRITIQUE À LA FOIS
   Ne jamais redémarrer une liste automatiquement.
   DC en DERNIER dans tout plan de patching.

4. JAMAIS DANS LES LIVRABLES :
   - Mots de passe, tokens, clés API, codes MFA
   - Adresses IP dans les livrables clients/externes

5. ZERO INVENTION
   Information non confirmée → [À CONFIRMER]
   Une seule question à la fois si bloquant.

6. ESCALADE IMMÉDIATE si :
   - Ransomware / chiffrement actif
   - Breach confirmée ou suspectée
   - DC ou AD compromis
   - Perte de données de production
   → [ESCALADE REQUISE] + notifier senior
```

---

## TABLE DES MATIÈRES

| Section | Contenu | Runbooks |
|---------|---------|---------|
| **1. SUPPORT & TRIAGE** | Premier contact, dispatch CW, N1→N3 | 2 |
| **2. INTERVENTION LIVE** | Guidage temps réel, clôture CW | 2 |
| **3. MAINTENANCE & PATCHING** | Windows, pending reboot, panne électrique | 4 |
| **4. VALIDATION PRE/POST** | DC, SQL, Print Server | 3 |
| **5. NOC & INCIDENTS** | Frontdoor, dispatch, command center, commandare | 8 |
| **6. SÉCURITÉ** | Triage alertes, réponse incident, licences | 3 |
| **7. CLOUD & M365** | Onboarding, gestion utilisateurs, architecture | 3 |
| **8. RÉSEAU & VOIP** | Diagnostic réseau, téléphonie IP | 2 |
| **9. BACKUP & DR** | Test DR, cycle de vie assets | 2 |
| **10. DOCUMENTATION** | Ticket → KB, capitalisation | 1 |
| **11. AD AVANCÉ** | GPO management, sécurité dossiers NTFS | 2 |
| **12. PROVISIONING VM** | Déploiement nouvelle VM (Hyper-V + VMware) | 1 |

**Total : 34 runbooks opérationnels**

---


---
# SECTION 1 — SUPPORT & TRIAGE
> **Pour qui :** Tout technicien recevant un billet. Point d'entrée universel.
> **Quand :** À chaque nouveau ticket — avant toute autre action.
---

## 1.1 — DISPATCH CONNECTWISE (Catégorisation & Routage)

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

## 1.2 — TRIAGE SUPPORT N1 / N2 / N3

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
# SECTION 2 — INTERVENTION LIVE ConnectWise
> **Pour qui :** Technicien en intervention active, billet ouvert dans CW.
> **Quand :** Du début à la clôture d'un billet — guidage pas à pas.
---

## 2.1 — INTERVENTION LIVE (Guidage temps réel)

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

## 2.2 — CLÔTURE CW (Discussion + Note + Email + Teams)

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
# SECTION 3 — MAINTENANCE & PATCHING
> **Pour qui :** Technicien en fenêtre de maintenance planifiée.
> **Quand :** Patching Windows, pending reboot, reprise après panne électrique.
---

## 3.1 — WINDOWS PATCHING (Procédure complète)

# RUNBOOK - Windows Server Patching

## Pré-patching (T-7 jours)

### 1. Inventaire et planification
- [ ] Identifier serveurs à patcher (par criticité)
- [ ] Vérifier change calendrier (blackout windows)
- [ ] Notifier stakeholders (maintenance window)
- [ ] Backup validation récente

### 2. Pre-checks automatisés
```powershell
# Script pre-patch validation
$Servers = @("SRV01", "SRV02", "SRV03")

foreach ($Server in $Servers) {
    Write-Host "=== Validation $Server ==="
    
    # 1. Disk space (minimum 10GB libre)
    $Disk = Get-WmiObject Win32_LogicalDisk -ComputerName $Server -Filter "DeviceID='C:'"
    $FreeGB = [math]::Round($Disk.FreeSpace / 1GB, 2)
    Write-Host "Espace libre C: $FreeGB GB" -ForegroundColor $(if($FreeGB -gt 10){'Green'}else{'Red'})
    
    # 2. Pending reboot check
    $PendingReboot = Invoke-Command -ComputerName $Server -ScriptBlock {
        Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
    }
    Write-Host "Reboot pending: $PendingReboot" -ForegroundColor $(if(!$PendingReboot){'Green'}else{'Yellow'})
    
    # 3. Windows Update service
    $WUService = Get-Service -ComputerName $Server -Name wuauserv
    Write-Host "WU Service: $($WUService.Status)" -ForegroundColor $(if($WUService.Status -eq 'Running'){'Green'}else{'Yellow'})
    
    # 4. Last successful backup
    try {
        $LastBackup = Get-WBSummary -ComputerName $Server | Select -ExpandProperty LastSuccessfulBackupTime
        $DaysSince = (Get-Date) - $LastBackup
        Write-Host "Last backup: $($DaysSince.Days) days ago" -ForegroundColor $(if($DaysSince.Days -le 1){'Green'}else{'Yellow'})
    } catch {
        Write-Host "Backup info unavailable" -ForegroundColor Red
    }
    
    Write-Host ""
}
```

## Maintenance Window (Jour J)

### Phase 1: Snapshot/Backup (T-30min)
```powershell
# Azure VMs: Create snapshot
$VM = Get-AzVM -ResourceGroupName "RG-PROD" -Name "SRV01"
$Disk = Get-AzDisk -ResourceGroupName $VM.ResourceGroupName -DiskName $VM.StorageProfile.OsDisk.Name

$SnapshotConfig = New-AzSnapshotConfig `
    -SourceUri $Disk.Id `
    -CreateOption Copy `
    -Location $VM.Location

$SnapshotName = "$($VM.Name)-snapshot-$(Get-Date -Format yyyyMMddHHmm)"
New-AzSnapshot -Snapshot $SnapshotConfig -SnapshotName $SnapshotName -ResourceGroupName $VM.ResourceGroupName

Write-Host "Snapshot créé: $SnapshotName" -ForegroundColor Green
```

### Phase 2: Installation patches

**Option A: WSUS (recommandé pour domaines)**
```powershell
# Approuver patches dans WSUS
$WSUS = Get-WsusServer -Name "WSUS01" -PortNumber 8530
$TargetGroup = $WSUS.GetComputerTargetGroups() | Where-Object {$_.Name -eq "Production Servers"}

# Approuver tous les patches critiques
$Updates = $WSUS.GetUpdates() | Where-Object {
    $_.UpdateClassificationTitle -eq "Critical Updates" -and
    $_.IsApproved -eq $false -and
    $_.CreationDate -gt (Get-Date).AddDays(-30)
}

foreach ($Update in $Updates) {
    $Update.Approve("Install", $TargetGroup)
    Write-Host "Approved: $($Update.Title)"
}

# Forcer detection sur serveurs cibles
Invoke-Command -ComputerName $Servers -ScriptBlock {
    wuauclt /detectnow /reportnow
}
```

**Option B: PSWindowsUpdate (direct download)**
```powershell
# Installer module si nécessaire
Install-Module -Name PSWindowsUpdate -Force

# Installer patches critiques et de sécurité
foreach ($Server in $Servers) {
    Write-Host "=== Patching $Server ===" -ForegroundColor Cyan
    
    Invoke-Command -ComputerName $Server -ScriptBlock {
        Import-Module PSWindowsUpdate
        
        # Download et install
        Get-WindowsUpdate -AcceptAll -Install -Category 'Critical Updates','Security Updates' -AutoReboot:$false -Verbose
    }
}
```

### Phase 3: Reboot orchestration
```powershell
# Reboot séquentiel (attendre que chaque serveur revienne avant le suivant)
foreach ($Server in $Servers) {
    Write-Host "Reboot $Server..." -ForegroundColor Yellow
    
    # Reboot
    Restart-Computer -ComputerName $Server -Force -Wait -For PowerShell -Timeout 600
    
    Write-Host "$Server is back online" -ForegroundColor Green
    
    # Wait 2 minutes pour services
    Start-Sleep -Seconds 120
    
    # Validation post-reboot
    Invoke-Command -ComputerName $Server -ScriptBlock {
        # Check critical services
        $CriticalServices = @('W32Time', 'Dnscache', 'Netlogon')
        foreach ($Svc in $CriticalServices) {
            $Status = (Get-Service -Name $Svc).Status
            if ($Status -ne 'Running') {
                Write-Warning "$Svc is $Status"
            }
        }
        
        # Check pending reboot
        $PendingReboot = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending"
        if ($PendingReboot) {
            Write-Warning "Additional reboot may be required"
        }
    }
}
```

## Post-patching validation

### 1. Services validation
```powershell
$CriticalServices = @(
    'W32Time',      # Time sync
    'Dnscache',     # DNS
    'Netlogon',     # Domain auth
    'Server',       # File sharing
    'Workstation',  # Network
    'MSSQLSERVER',  # SQL (si applicable)
    'W3SVC'         # IIS (si applicable)
)

foreach ($Server in $Servers) {
    Write-Host "=== $Server Services ===" -ForegroundColor Cyan
    
    Invoke-Command -ComputerName $Server -ScriptBlock {
        param($Services)
        foreach ($Svc in $Services) {
            try {
                $Status = (Get-Service -Name $Svc -ErrorAction SilentlyContinue).Status
                $Color = if($Status -eq 'Running'){'Green'}else{'Red'}
                Write-Host "$Svc : $Status" -ForegroundColor $Color
            } catch {
                Write-Host "$Svc : Not installed" -ForegroundColor Gray
            }
        }
    } -ArgumentList (,$CriticalServices)
}
```

### 2. Event Log review
```powershell
foreach ($Server in $Servers) {
    Write-Host "=== $Server Recent Errors ===" -ForegroundColor Cyan
    
    # System errors in last hour
    $Errors = Get-EventLog -ComputerName $Server -LogName System -EntryType Error -After (Get-Date).AddHours(-1) -ErrorAction SilentlyContinue
    
    if ($Errors) {
        $Errors | Select TimeGenerated, Source, EventID, Message | Format-Table -AutoSize
    } else {
        Write-Host "No errors found" -ForegroundColor Green
    }
}
```

### 3. Patch compliance
```powershell
foreach ($Server in $Servers) {
    Write-Host "=== $Server Patch Status ===" -ForegroundColor Cyan
    
    $Session = New-PSSession -ComputerName $Server
    Invoke-Command -Session $Session -ScriptBlock {
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        
        # Rechercher patches manquants
        $SearchResult = $UpdateSearcher.Search("IsInstalled=0 and Type='Software'")
        
        Write-Host "Patches manquants: $($SearchResult.Updates.Count)" -ForegroundColor $(if($SearchResult.Updates.Count -eq 0){'Green'}else{'Yellow'})
        
        if ($SearchResult.Updates.Count -gt 0) {
            $SearchResult.Updates | Select Title, IsDownloaded | Format-Table -AutoSize
        }
    }
    Remove-PSSession $Session
}
```

### 4. Application smoke tests
```powershell
# Exemple: Test web application
foreach ($Server in @("WEB01", "WEB02")) {
    $URL = "https://$Server/healthcheck"
    
    try {
        $Response = Invoke-WebRequest -Uri $URL -UseBasicParsing -TimeoutSec 10
        if ($Response.StatusCode -eq 200) {
            Write-Host "$Server web app: OK" -ForegroundColor Green
        } else {
            Write-Host "$Server web app: Status $($Response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "$Server web app: FAILED" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

# Exemple: Test SQL connection
foreach ($Server in @("SQL01", "SQL02")) {
    try {
        $Connection = New-Object System.Data.SqlClient.SqlConnection
        $Connection.ConnectionString = "Server=$Server;Database=master;Integrated Security=True;Connection Timeout=5"
        $Connection.Open()
        Write-Host "$Server SQL: OK" -ForegroundColor Green
        $Connection.Close()
    } catch {
        Write-Host "$Server SQL: FAILED" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}
```

## Rollback procedure

### Si problème détecté post-patching

**Azure VM: Restore depuis snapshot**
```powershell
$SnapshotName = "SRV01-snapshot-202401151430"
$Snapshot = Get-AzSnapshot -SnapshotName $SnapshotName -ResourceGroupName "RG-PROD"

# Stop VM
Stop-AzVM -ResourceGroupName "RG-PROD" -Name "SRV01" -Force

# Swap OS disk
$VM = Get-AzVM -ResourceGroupName "RG-PROD" -Name "SRV01"
$DiskConfig = New-AzDiskConfig -Location $VM.Location -CreateOption Copy -SourceResourceId $Snapshot.Id
$NewDisk = New-AzDisk -Disk $DiskConfig -ResourceGroupName "RG-PROD" -DiskName "SRV01-rollback-osdisk"

Set-AzVMOSDisk -VM $VM -ManagedDiskId $NewDisk.Id -Name $NewDisk.Name
Update-AzVM -ResourceGroupName "RG-PROD" -VM $VM

# Start VM
Start-AzVM -ResourceGroupName "RG-PROD" -Name "SRV01"
```

**On-prem: Restore depuis backup**
1. Boot sur Windows Recovery
2. Restore System State depuis dernier backup
3. Ou full BMR si nécessaire

**Uninstall specific patch** (dernier recours)
```powershell
# Lister patches installés récemment
Get-HotFix -ComputerName "SRV01" | Where-Object {$_.InstalledOn -gt (Get-Date).AddDays(-1)} | Format-Table -AutoSize

# Uninstall patch spécifique
wusa /uninstall /kb:5034441 /quiet /norestart
```

## Reporting

### Patch compliance report
```powershell
$Report = foreach ($Server in $Servers) {
    $Session = New-PSSession -ComputerName $Server
    
    $Result = Invoke-Command -Session $Session -ScriptBlock {
        # Get installed patches
        $Patches = Get-HotFix | Where-Object {$_.InstalledOn -gt (Get-Date).AddDays(-30)}
        
        # Check for missing patches
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateUpdateSearcher()
        $SearchResult = $UpdateSearcher.Search("IsInstalled=0 and Type='Software'")
        
        [PSCustomObject]@{
            Server = $env:COMPUTERNAME
            PatchesInstalled = $Patches.Count
            PatchesMissing = $SearchResult.Updates.Count
            LastPatchDate = ($Patches | Sort-Object InstalledOn -Descending | Select-Object -First 1).InstalledOn
            CompliantStatus = if($SearchResult.Updates.Count -eq 0){'Compliant'}else{'Non-Compliant'}
        }
    }
    
    Remove-PSSession $Session
    $Result
}

$Report | Format-Table -AutoSize
$Report | Export-Csv "PatchReport-$(Get-Date -Format yyyyMMdd).csv" -NoTypeInformation
```

### Email notification
```powershell
$Body = @"
<h2>Patching Summary - $(Get-Date -Format "yyyy-MM-dd")</h2>
<h3>Servers Patched</h3>
<table border='1'>
<tr><th>Server</th><th>Patches Installed</th><th>Status</th></tr>
"@

foreach ($Item in $Report) {
    $StatusColor = if($Item.CompliantStatus -eq 'Compliant'){'green'}else{'red'}
    $Body += "<tr><td>$($Item.Server)</td><td>$($Item.PatchesInstalled)</td><td style='color:$StatusColor'>$($Item.CompliantStatus)</td></tr>"
}

$Body += "</table>"

Send-MailMessage `
    -From "noreply@company.com" `
    -To "it-team@company.com" `
    -Subject "Patching Report - $(Get-Date -Format 'yyyy-MM-dd')" `
    -Body $Body `
    -BodyAsHtml `
    -SmtpServer "smtp.company.com"
```

## Best Practices

### Scheduling
- **Production:** 2e dimanche du mois, 2h-6h
- **Dev/Test:** 1er mercredi du mois, 20h-22h
- **Éviter:** Fin de trimestre, lancement produit, période des Fêtes

### Staggering
- **Tier 1:** Dev/Test servers
- **Tier 2:** Non-critical production (wait 24h)
- **Tier 3:** Critical production (wait 48h)

### Testing
- Toujours tester patches en DEV avant PROD
- Minimum 48h observation en DEV
- Application smoke tests automatisés

### Backup verification
- Valider backup succès < 24h
- Test restore mensuel
- Snapshots pré-patch (Azure VMs)

### Change management
- CAB approval pour production
- Rollback plan documenté
- Stakeholder notification 48h avant

### Monitoring
- Alert si services critical down post-reboot
- Performance baseline comparison
- Event log monitoring (System/Application errors)


---

## 3.2 — WINDOWS PATCHING (ConnectWise RMM — 1 serveur à la fois)

# RUNBOOK — Windows Server Patching (ConnectWise RMM) — 1 serveur à la fois

## Principe (non négociable)
- **Lecture seule → patching → reboot (si requis) → postcheck**.
- **Un seul serveur critique à la fois** (DC/SQL/RDS/ERP).
- **Aucun script** qui redémarre une liste automatiquement.

## Préparation
1) Confirmer fenêtre + scope + ordre (recommandé) :
- SQL → App/Web → Print → File → DC
2) Confirmer backups/replication OK (si applicable).
3) Créer un dossier de preuves par serveur :
```powershell
$BaseOut = "$env:TEMP\\CW_Patching"
New-Item -ItemType Directory -Path $BaseOut -Force | Out-Null
```

## PRECHECK (à exécuter AVANT patching)
> Exécuter sur **le serveur ciblé** (RMM script ou session). Sauver l’output dans un fichier.

```powershell
param([string]$OutDir = "$env:TEMP\\CW_Patching")
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$TS = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $OutDir "PRECHECK_$TS.log") -Append

"=== HOST ==="; hostname
"=== OS / UPTIME ==="; (Get-CimInstance Win32_OperatingSystem | Select-Object CSName,Caption,Version,LastBootUpTime)

"=== PENDING REBOOT (CBS/WU/FILE RENAME/CCM) ==="
$CBS = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Component Based Servicing\\RebootPending'
$WU  = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\CCM\\RebootPending'
[pscustomobject]@{CBS_RebootPending=$CBS; WU_RebootRequired=$WU; PendingFileRenameOperations=$PFR; CCMClientRebootPending=$CCM; PendingReboot=($CBS -or $WU -or $PFR -or $CCM)}

"=== DISKS ==="; Get-PSDrive -PSProvider FileSystem | Select-Object Name,Used,Free,@{n='FreeGB';e={[math]::Round($_.Free/1GB,2)}} | Format-Table -Auto

"=== TOP SERVICES (AUTO + NOT RUNNING) ==="
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'} | Select-Object Name,Status,StartType | Format-Table -Auto

"=== EVENTLOG (System/Application) last 2h: Error/Critical ==="
$Start=(Get-Date).AddHours(-2)
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap

Stop-Transcript
"PRECHECK log: $OutDir"
```

## PATCHING (via ConnectWise RMM)
- Déclencher l’installation des updates (CU + sécurité) via **CW RMM**.
- **Ne pas** redémarrer automatiquement si c’est un serveur critique sans avoir le OK.

## REBOOT (si requis)
1) Confirmer : sessions / dépendances / approbation.
2) Redémarrer **le serveur courant** seulement.

## POSTCHECK (après reboot / après patch)
```powershell
param([string]$OutDir = "$env:TEMP\\CW_Patching")
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$TS = Get-Date -Format "yyyyMMdd_HHmmss"
Start-Transcript -Path (Join-Path $OutDir "POSTCHECK_$TS.log") -Append

"=== HOST ==="; hostname
"=== OS / UPTIME ==="; (Get-CimInstance Win32_OperatingSystem | Select-Object CSName,Caption,Version,LastBootUpTime)

"=== PENDING REBOOT (CBS/WU/FILE RENAME/CCM) ==="
$CBS = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Component Based Servicing\\RebootPending'
$WU  = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\CCM\\RebootPending'
[pscustomobject]@{CBS_RebootPending=$CBS; WU_RebootRequired=$WU; PendingFileRenameOperations=$PFR; CCMClientRebootPending=$CCM; PendingReboot=($CBS -or $WU -or $PFR -or $CCM)}

"=== DISKS ==="; Get-PSDrive -PSProvider FileSystem | Select-Object Name,Used,Free,@{n='FreeGB';e={[math]::Round($_.Free/1GB,2)}} | Format-Table -Auto

"=== SERVICES (AUTO + NOT RUNNING) ==="
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'} | Select-Object Name,Status,StartType | Format-Table -Auto

"=== EVENTLOG (System/Application) last 1h: Error/Critical ==="
$Start=(Get-Date).AddHours(-1)
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap

Stop-Transcript
"POSTCHECK log: $OutDir"
```

## Closeout (ConnectWise)
- Utiliser :
  - `01_TEMPLATES_CW/TEMPLATE__CW_NOTE_INTERNE__TIMELINE.md`
  - `01_TEMPLATES_CW/TEMPLATE__CW_DISCUSSION__STAR.md`


---

## 3.3 — PENDING REBOOT (Validation + Résolution séquentielle)

# RUNBOOK — Pending Reboot (Windows) — Validation + reboot 1 serveur à la fois

## Objectif
- Confirmer **pourquoi** le pending reboot est levé (CBS/WU/PendingFileRename/CCM).
- Appliquer un reboot **contrôlé** (si approuvé) et **re-valider**.

## PRECHECK — identifie la source
```powershell
"=== Pending reboot flags ==="
$CBS = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Component Based Servicing\\RebootPending'
$WU  = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\WindowsUpdate\\Auto Update\\RebootRequired'
$PFR = (Get-ItemProperty 'HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue) -ne $null
$CCM = Test-Path 'HKLM:\\SOFTWARE\\Microsoft\\CCM\\RebootPending'
[pscustomobject]@{CBS_RebootPending=$CBS; WU_RebootRequired=$WU; PendingFileRenameOperations=$PFR; CCMClientRebootPending=$CCM; PendingReboot=($CBS -or $WU -or $PFR -or $CCM)}

"=== Last boot ==="; (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
"=== Sessions (RDS) ==="; query user
"=== Disks ==="; Get-PSDrive -PSProvider FileSystem | Select Name,Free,@{n='FreeGB';e={[math]::Round($_.Free/1GB,2)}} | ft -Auto
```

## Décision
- Si **prod/critique** : valider fenêtre + dépendances + approbation.
- Si DC : exécuter le runbook DC avant et après.

## REBOOT (manuel)
> Faire **uniquement** après approbation.

```powershell
# Option 1: depuis le serveur
Restart-Computer -Force

# Option 2: depuis un poste admin
Restart-Computer -ComputerName "SRV-NAME" -Force
```

## POSTCHECK
Rejouer le PRECHECK + valider les services critiques.

## Si pending reboot reste TRUE
- Noter quel flag reste TRUE.
- Vérifier :
  - Windows Update en attente (re-scan / redémarrage additionnel)
  - Installer/rollback en cours
  - Software distribution corruption
- Escalader si 2 reboots n'éteignent pas le flag **CBS**.


---

## 3.4 — POST-PANNE ÉLECTRIQUE (Reprise infrastructure)

# RUNBOOK — Post-Shutdown Électrique (reprise infra) — NOC/MSP

## Objectif
Assurer une reprise **stable** après retour du courant : réseau → stockage → virtualisation → services critiques → monitoring → rapport.

## Ordre de validation (priorité)
1) **Énergie/UPS/PDU** (événements power, batterie)
2) **Réseau** (FW/ISP/VPN/DNS/DHCP/NTP)
3) **Stockage** (SAN/NAS/RAID/SMART)
4) **Virtualisation** (vCenter/hosts/datastores)
5) **Services** (AD/DNS → SQL/IIS/File/RDS → apps)
6) **Backups** (dernier job + pas d'échec post-reprise)
7) **Monitoring** (alertes, ack, retour au vert)

## 1) UPS / Power events
- Vérifier logs UPS (power fail/restore, batteries faibles).
- Si UPS faible : noter le risque + recommander remplacement.

## 2) Réseau baseline (read-only)
```powershell
"=== DNS / Gateway quick checks ==="
ipconfig /all
nslookup google.com
route print | findstr /I "0.0.0.0"

"=== Time sync ==="
w32tm /query /status
w32tm /query /source
```

## 3) Stockage
- Sur SAN/NAS : état contrôleurs, disques, volumes, iSCSI, alertes.
- Vérifier que les datastores sont montés **avant** vCenter/ESXi dépendants.

## 4) Virtualisation (VMware vSphere)
- **Ordre recommandé** : SAN/NAS → ESXi hosts → vCenter.
- Si vCenter est parti avant le SAN :
  - redémarrer vCenter **après** confirmation datastores.
  - au besoin redémarrer les hosts ESXi (1 à la fois) si incohérences.
- Valider : cluster, hosts connected, datastores OK, VMs up.

## 5) Services critiques Windows (par rôle)
- DC: voir `RUNBOOK__DC_PrePost_Validation.md`
- SQL: voir `RUNBOOK__SQL_PrePost_Validation.md`
- Print: voir `RUNBOOK__PrintServer_PrePost_Validation.md`

## 6) Monitoring
- Lister les alertes apparues depuis le retour du courant.
- Distinguer :
  - alertes transitoires (boot) vs. anomalies persistantes
- Normaliser/ack une fois validé.

## 7) Rapport (CW)
- CW_NOTE_INTERNE : timeline + validations + anomalies + suivis.
- CW_DISCUSSION (STAR) : résultat + actions clés.


---
# SECTION 4 — VALIDATIONS PRE/POST (par rôle serveur)
> **Pour qui :** Technicien avant/après toute action sur un serveur spécialisé.
> **Quand :** Avant chaque patch, reboot ou intervention sur DC, SQL, Print Server.
> **Règle :** Toujours faire le PRECHECK avant l'action et le POSTCHECK après.
---

## 4.1 — DOMAIN CONTROLLER / AD / DNS (Precheck & Postcheck)

# RUNBOOK — Domain Controller (AD DS/DNS) — Precheck/Postcheck

## Services critiques
```powershell
Get-Service NTDS,DNS,Netlogon,KDC,W32Time | Format-Table Name,Status,StartType
net share | findstr /I "SYSVOL NETLOGON"
```

## Réplication AD
```powershell
repadmin /replsummary
repadmin /syncall /AdeP
```

## Santé AD (rapide)
```powershell
# dcdiag peut être long; utiliser /q pour erreurs seulement
$OutDir = "$env:TEMP\\DC_CHECK"; New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$TS = Get-Date -Format "yyyyMMdd_HHmmss"
dcdiag /q | Out-File (Join-Path $OutDir "dcdiag_q_$TS.txt")
"dcdiag_q saved to $OutDir"
```

## DNS (erreurs récentes)
```powershell
$Start=(Get-Date).AddHours(-2)
Get-WinEvent -FilterHashtable @{LogName='DNS Server'; StartTime=$Start} | Where-Object {$_.LevelDisplayName -in 'Error','Critical'} | Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
```

## Postcheck après reboot
- Rejouer services + replsummary.
- Vérifier que SYSVOL/NETLOGON partagés.
- Confirmer qu'aucun nouvel event critique (Directory Service/System).


---

## 4.2 — SQL SERVER (Precheck & Postcheck)

# RUNBOOK — SQL Server — Precheck/Postcheck

## Services
```powershell
Get-Service | Where-Object {$_.Name -match '^MSSQL' -or $_.Name -match '^SQL'} | Sort-Object Name | Format-Table Name,Status,StartType
```

## Connectivité (local)
> Option A : `Invoke-Sqlcmd` si module dispo.

```powershell
if (Get-Command Invoke-Sqlcmd -ErrorAction SilentlyContinue) {
  Invoke-Sqlcmd -Query "SELECT @@SERVERNAME AS ServerName, @@VERSION AS Version" | Format-Table -Auto
} else {
  "Invoke-Sqlcmd indisponible — fallback .NET"
  $cn = New-Object System.Data.SqlClient.SqlConnection
  $cn.ConnectionString = "Server=localhost;Database=master;Integrated Security=True;Connection Timeout=5"
  $cn.Open();
  $cmd = $cn.CreateCommand();
  $cmd.CommandText = "SELECT @@SERVERNAME AS ServerName";
  $r = $cmd.ExecuteScalar();
  $cn.Close();
  "ServerName=$r"
}
```

## Journaux Windows (SQL-related)
```powershell
$Start=(Get-Date).AddHours(-2)
Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=$Start} |
  Where-Object { $_.LevelDisplayName -in 'Error','Critical' -and ($_.ProviderName -match 'MSSQL|SQLSERVERAGENT|SQL' -or $_.Message -match 'SQL') } |
  Select-Object -First 30 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
```

## Postcheck après reboot
- Services MSSQL/Agent running.
- Test SELECT OK.
- Vérifier EventLog 1h post.

## Note opérationnelle
- Certains environnements (CU/patch) peuvent nécessiter **2 reboots**. Documenter la raison (pending reboot flags).


---

## 4.3 — PRINT SERVER (Precheck & Postcheck)

# RUNBOOK — Print Server — Precheck/Postcheck

## Spooler + queues
```powershell
Get-Service Spooler | Format-Table Name,Status,StartType

# Requiert module PrintManagement sur serveur / RSAT
try {
  Get-Printer | Select-Object Name,Shared,PrinterStatus | Sort-Object Name | Format-Table -Auto
} catch {
  "Get-Printer indisponible (module PrintManagement manquant)."
}
```

## Event logs PrintService
```powershell
$Start=(Get-Date).AddHours(-6)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-PrintService/Operational'; StartTime=$Start} |
  Where-Object {$_.LevelDisplayName -in 'Error','Critical','Warning'} |
  Select-Object -First 50 TimeCreated,Id,ProviderName,Message | Format-Table -Wrap
```

## Postcheck après reboot
- Spooler running.
- Queues visibles.
- Si imprimante intermittente : valider connectivité (ping) + cycle power (débrancher/rebrancher) si requis.


---
# SECTION 5 — NOC & GESTION D'INCIDENTS
> **Pour qui :** Technicien NOC, dispatcher, commandare.
> **Quand :** Réception d'alertes, triage incidents, escalade, command center.
---

## 5.1 — NOC FRONTDOOR (Réception & Premier triage — v1)

# RUNBOOK — IT_NOC_FRONTDOOR

## Objectif
Traiter un événement NOC de bout en bout :
1) triage & dispatch (NOCDispatcher)
2) lead technique si nécessaire (Commandare-TECH)
3) lead NOC si nécessaire (Commandare-NOC)
4) contrôle ops / ticket / DoD (Commandare-OPR)
5) archivage (OPS-DossierIA)

## Inputs attendus
- Alerte/événement (title/description/raw/source/severity_hint/affected)

## Outputs attendus
- Décision de dispatch, plan d’action, update ticket-ready, checklist fermeture, logs.

## Étapes (order)
1. `dispatch` — IT-Commandare-NOCDispatcher
2. `tech_lead` — IT-Commandare-TECH
3. `noc_lead` — IT-Commandare-NOC
4. `ops_control` — IT-Commandare-OPR
5. `archive` — OPS-DossierIA

## Notes d’exécution (branching logique)
- Si NOCDispatcher classe `monitoring_noise`, Commandare-TECH peut être “no-op”.
- Si c’est un incident technique (P1/P2), TECH est prioritaire et NOC assiste (paging/corrélation).
- OPR finalise toujours si un ticket/incident est ouvert.

## Definition of Done (DoD)
- Classification + justification
- Actions immédiates identifiées (0–15 min)
- Si incident: mitigation plan + next update time
- Si fermeture: critères remplis ou manquants explicités
- Logs complétés


---

## 5.2 — NOC FRONTDOOR (v2.0 — Format enrichi)

# RUNBOOK — IT_NOC_FRONTDOOR (v2.0)
# Mise à jour : ajout IT-Commandare-Infra dans le flux

## Objectif
Traiter un événement NOC de bout en bout avec routage intelligent selon le type d'incident.

## Flux principal (avec branchement par type)

```
Événement entrant
        │
        ▼
Step 1 — IT-Commandare-NOCDispatcher
  → Qualifier, prioriser, SLA, assignation initiale
  → Décision : type d'incident ?
        │
        ├─ Type: INFRA/CLOUD (server/vm/dc/azure/backup/storage)
        │         └─► Step 2A — IT-Commandare-Infra  ← NOUVEAU
        │                   → Lead technique infra, mobilise spécialiste(s)
        │                   → Si P1 multi : parallel tracks + IT-CTOMaster
        │
        ├─ Type: TECHNIQUE GÉNÉRAL (RCA, bug, remédiation complexe non-infra)
        │         └─► Step 2B — IT-Commandare-TECH
        │                   → Diagnostic, hypothèses, plan remédiation
        │
        ├─ Type: ALERTE CORRÉLATION (multiple alertes, impact scope inconnu)
        │         └─► Step 2C — IT-Commandare-NOC
        │                   → Corrélation, scope, paging, coordination
        │
        └─ Type: MONITORING NOISE / P4
                  └─► Clore ou planifier — pas d'escalade Commandare
        │
        ▼
Step 3 — IT-Commandare-OPR  (toujours si ticket ouvert)
  → Vérification DoD, fermeture ticket, standardisation

Step 4 — OPS-DossierIA
  → Archivage, audit trail
```

## Étapes (order — incident INFRA type)
1. `dispatch`     — IT-Commandare-NOCDispatcher
2. `infra_lead`   — IT-Commandare-Infra       ← NOUVEAU
3. `tech_lead`    — IT-Commandare-TECH         (si RCA approfondi requis)
4. `noc_lead`     — IT-Commandare-NOC          (si corrélation multi-alertes)
5. `ops_control`  — IT-Commandare-OPR
6. `archive`      — OPS-DossierIA

## Notes d'exécution (branching logique)

- **IT-Commandare-Infra** prend le lead dès que le domaine est identifié comme infra/cloud.
  - Il mobilise directement `IT-Commandare-Infra`, `IT-CloudMaster`, `IT-BackupDRMaster` ou `IT-NetworkMaster`.
  - `IT-Commandare-TECH` est activé EN PARALLÈLE ou EN SUITE si une RCA générale est requise.
  - `IT-Commandare-NOC` reste en support pour la coordination globale sur les P1.

- Si NOCDispatcher classe `monitoring_noise` → pas d'activation Commandare.
- Si incident P1 INFRA multi-domaines → IT-CTOMaster notifié par IT-Commandare-Infra.
- OPR finalise toujours si un ticket/incident est ouvert.

## Famille Commandare complète (v2)

| Agent | Rôle | Activé quand |
|-------|------|-------------|
| IT-Commandare-NOCDispatcher | 1er contact, triage, SLA | Toujours en premier |
| IT-Commandare-NOC | Corrélation alertes, coordination NOC | Alertes multiples, scope inconnu |
| **IT-Commandare-Infra** | Lead infra/cloud incidents | Domaine = server/vm/dc/azure/backup/storage |
| IT-Commandare-TECH | RCA, remédiation technique | Diagnostic profond, bug, rollback |
| IT-Commandare-OPR | Fermeture, DoD, standardisation | Toujours en fin de ticket |

## Definition of Done (DoD)
- Classification + domaine infra identifié
- Spécialiste(s) mobilisé(s) avec tâches claires
- Actions immédiates documentées (0-15 min)
- Plan de validation post-fix défini
- Logs complétés (trace_id)
- Si fermeture : critères DoD remplis ou manquants explicités


---

## 5.3 — NOC COMMAND CENTER (Vue globale opérations)

# RUNBOOK — IT NOC Command Center

## Objectif
Ce runbook formalise le routage et l’usage des 4 agents IT suivants :
- `IT-Commandare-NOCDispatcher` : dispatch / SLA / escalade
- `IT-Commandare-NOC` : triage NOC / corrélation / sévérité
- `IT-Commandare-TECH` : troubleshooting / RCA / remediation
- `IT-Commandare-OPR` : gouvernance ops / communication / coordination

## Playbooks
- `IT_NOC_DISPATCH` → `IT-Commandare-NOCDispatcher`
- `IT_COMMANDARE_NOC` → `IT-Commandare-NOC`
- `IT_COMMANDARE_TECH` → `IT-Commandare-TECH`
- `IT_COMMANDARE_OPR` → `IT-Commandare-OPR`

## Routage (80_MACHINES/hub_routing.yaml)
Le routage est **déterministe** via intents dédiés :
- `it_noc_dispatch` / `noc_dispatch` / `noc_dispatcher`
- `it_commandare_noc` / `noc_triage`
- `it_commandare_tech` / `tech_escalation`
- `it_commandare_opr` / `ops_control`

Ces routes doivent être **prioritaires** par rapport à la route IT générique (MSP).

## Références
- `CONTEXT__CORE.md`
- `50_POLICIES/POLICIES__INDEX.md`
- `50_POLICIES/ops/incident_severity.md`
- `50_POLICIES/ops/sla.md`
- `50_POLICIES/ops/logging_schema.md`


---

## 5.4 — NOC DISPATCH (Assignation & Suivi)

# RUNBOOK — IT_NOC_DISPATCH

## Objectif

NOC dispatch: prioriser/assigner/escalader et suivre SLA.

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
1. **execute** → `IT-Commandare-NOCDispatcher`

Règle : si une étape échoue, enregistrer l’échec via le logging OPS et appliquer l’escalade du playbook.

## Prérequis

- Accès aux agents impliqués.
- Dossier/ID de suivi (ticket, dossier client, ou dossier IA).
- Inputs complets (fichiers / texte / consignes).

## Étapes (exécution)

### Étape 1 — execute

- **Acteur** : `IT-Commandare-NOCDispatcher`

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

## 5.5 — INCIDENT COMMAND (Gestion incident majeur P1/P2)

# RUNBOOK — IT_INCIDENT_COMMAND_V1
_Généré le 2026-01-17T21:19:45Z_

## 1) Objectif
Incident command (triage NOC -> diagnostic -> plan -> report)

## 2) Owner / Acteurs
- Owner (par défaut) : `IT-Commandare-NOCDispatcher`
- Steps (ordre canon) :
  - **dispatch** → `IT-Commandare-NOCDispatcher`
  - **noc** → `IT-Commandare-NOC`
  - **tech** → `IT-Commandare-TECH`
  - **report** → `IT-ReportMaster`
  - **kb** → `IT-KnowledgeKeeper`

## 3) Inputs attendus
- Contexte : demande + objectifs + contraintes
- Données : liens, docs, extraits (si applicable)
- Format de sortie requis (si applicable)

## 4) Procédure
1. Exécuter les steps dans l’ordre.
2. Documenter les décisions / hypothèses.
3. Produire l’output final + résumé exécutif.

## 5) Contrôles qualité
- Check conformité (policies du domaine)
- Cohérence interne + traçabilité des sources (si applicable)
- Format de sortie respecté

## 6) Erreurs fréquentes / Escalade
- Si informations manquantes : demander les éléments minimaux (but, audience, contraintes).
- Si risque sécurité/conformité : escalader vers `META-GouvernanceEtRisques`.

## 7) Definition of Done
- Output livré + résumé
- Artefacts archivés si nécessaire (ex: `OPS-DossierIA`)


---

## 5.6 — COMMANDARE NOC (Rôles & Responsabilités)

# RUNBOOK — IT_COMMANDARE_NOC

## Objectif

Commandare NOC: triage/diagnostic initial, sévérité, plan de réponse.

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
1. **execute** → `IT-Commandare-NOC`

Règle : si une étape échoue, enregistrer l’échec via le logging OPS et appliquer l’escalade du playbook.

## Prérequis

- Accès aux agents impliqués.
- Dossier/ID de suivi (ticket, dossier client, ou dossier IA).
- Inputs complets (fichiers / texte / consignes).

## Étapes (exécution)

### Étape 1 — execute

- **Acteur** : `IT-Commandare-NOC`

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

## 5.7 — COMMANDARE TECH (Exécution technique)

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

## 5.8 — COMMANDARE OPR (Opérations & Clôture)

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
# SECTION 6 — SÉCURITÉ
> **Pour qui :** Technicien SOC, senior, commandare TECH.
> **Quand :** Alerte sécurité, incident cybersécurité, audit licences.
> **⚠️ ESCALADE IMMÉDIATE si P1 (ransomware, breach, DC compromis)**
---

## 6.1 — TRIAGE ALERTES SÉCURITÉ

# RUNBOOK — IT_SECURITY_ALERT_TRIAGE_V1
_Généré le 2026-01-17T21:19:45Z_

## 1) Objectif
Alerte sécurité (analyse -> containment -> communication -> KB)

## 2) Owner / Acteurs
- Owner (par défaut) : `IT-MonitoringMaster`
- Steps (ordre canon) :
  - **monitor** → `IT-MonitoringMaster`
  - **security** → `IT-SecurityMaster`
  - **comms** → `IT-TicketScribe`
  - **kb** → `IT-KnowledgeKeeper`

## 3) Inputs attendus
- Contexte : demande + objectifs + contraintes
- Données : liens, docs, extraits (si applicable)
- Format de sortie requis (si applicable)

## 4) Procédure
1. Exécuter les steps dans l’ordre.
2. Documenter les décisions / hypothèses.
3. Produire l’output final + résumé exécutif.

## 5) Contrôles qualité
- Check conformité (policies du domaine)
- Cohérence interne + traçabilité des sources (si applicable)
- Format de sortie respecté

## 6) Erreurs fréquentes / Escalade
- Si informations manquantes : demander les éléments minimaux (but, audience, contraintes).
- Si risque sécurité/conformité : escalader vers `META-GouvernanceEtRisques`.

## 7) Definition of Done
- Output livré + résumé
- Artefacts archivés si nécessaire (ex: `OPS-DossierIA`)


---

## 6.2 — RÉPONSE INCIDENT SÉCURITÉ (Phases complètes)

# RUNBOOK — Réponse aux Incidents de Sécurité MSP
**ID :** RUNBOOK__IT_SECURITY_INCIDENT_RESPONSE  
**Version :** 1.0 | **Agent :** IT-SecurityMaster  
**Applicable :** Tout incident cybersécurité P1/P2 (breach, ransomware, phishing actif)

---

## DÉCLENCHEURS
- Alerte EDR/XDR confirmée (SentinelOne, CrowdStrike, Defender XDR)
- Rapport utilisateur : accès non autorisé, chiffrement fichiers, email suspect cliqué
- Alerte NOC : trafic anormal, connexions sortantes suspectes
- Demande d'audit post-incident

---

## PHASE 1 — IDENTIFICATION (0 à 15 min)

### Étape 1.1 — Qualifier l'incident
- [ ] Type confirmé : ransomware / phishing / breach / lateral_movement / autre
- [ ] Asset(s) affecté(s) identifiés
- [ ] Heure de détection vs heure estimée compromission
- [ ] Vecteur d'entrée probable (email / RDP / VPN / supply chain)
- [ ] Propagation active ? (oui/non/inconnu)

### Étape 1.2 — Classier la sévérité
| Indicateur | P1 | P2 | P3 |
|-----------|----|----|-----|
| Chiffrement actif détecté | ✓ | | |
| Credentials admin compromis | ✓ | | |
| DC / AD touché | ✓ | | |
| Single workstation isolée | | | ✓ |
| Email phishing cliqué, no exec | | | ✓ |
| Mouvement latéral confirmé | | ✓ | |
| Data exfiltration suspectée | ✓ | | |

### Étape 1.3 — Notification
- P1 : Notifier IT-Commandare-NOC + IT-CTOMaster **immédiatement**
- P2 : Notifier IT-Commandare-NOC dans les 30 min
- Ouvrir ticket CW avec priorité correcte

---

## PHASE 2 — CONTAINMENT (15 min à 2h)

### 2.1 Isolation réseau (si propagation active)
```powershell
# ⚠️ Impact : isolation réseau complète du poste/serveur
# Validation requise avant exécution
# Sur le poste suspect :
netsh advfirewall set allprofiles state on
netsh advfirewall firewall add rule name="BLOCK_ALL_IR" dir=out action=block
```
- [ ] Poste isolé du réseau (déconnecter NIC ou quarantaine EDR)
- [ ] NE PAS éteindre la machine (préserver artefacts forensics en RAM)
- [ ] Si serveur critique : coordination IT-Commandare-Infra avant isolation

### 2.2 Révoquer accès compromis
- [ ] Désactiver compte AD compromis
- [ ] Révoquer sessions actives Azure AD : `Revoke-AzureADUserAllRefreshToken`
- [ ] Changer mots de passe service accounts affectés
- [ ] Invalider tokens MFA si nécessaire

### 2.3 Bloquer IOCs
- [ ] Ajouter hashes malwares dans EDR exclusions (block)
- [ ] Bloquer IPs/domaines C2 sur firewall
- [ ] Règle email : bloquer domaine expéditeur malveillant

---

## PHASE 3 — INVESTIGATION (parallèle au containment)

### 3.1 Collecte d'artefacts
```powershell
# Capture état système AVANT remédiation
$OutDir = "$env:SystemDrive\IR_ARTIFACTS_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

# Processus actifs
Get-Process | Export-Csv "$OutDir\processes.csv" -NoTypeInformation
# Connexions réseau
netstat -ano > "$OutDir\netstat.txt"
# Logs événements récents (Security, System, Application)
Get-EventLog -LogName Security -Newest 500 | Export-Csv "$OutDir\events_security.csv" -NoTypeInformation
# Tâches planifiées
Get-ScheduledTask | Export-Csv "$OutDir\scheduled_tasks.csv" -NoTypeInformation
# Services
Get-Service | Export-Csv "$OutDir\services.csv" -NoTypeInformation
```
- [ ] Artefacts copiés sur stockage sécurisé (hors réseau compromis)
- [ ] NE PAS supprimer artefacts avant analyse complète

### 3.2 Analyse timeline
- [ ] Corrélation logs EDR + Event Viewer + pare-feu
- [ ] Patient zéro identifié
- [ ] Étendue de la compromission mappée

---

## PHASE 4 — ÉRADICATION

- [ ] Suppression malware (via EDR ou réinstallation OS si nécessaire)
- [ ] Patch vulnérabilité exploitée
- [ ] Nettoyage registre et persistence mécanismes
- [ ] Réinitialisation credentials complets si breach confirmé
- [ ] Vérification intégrité backups (avant restauration)

---

## PHASE 5 — RÉCUPÉRATION

- [ ] Restauration depuis backup sain (date pre-compromission confirmée)
- [ ] Validation intégrité post-restauration
- [ ] Monitoring renforcé 72h (alertes sensibilité maximale)
- [ ] Test accès utilisateurs
- [ ] Communication client (via IT-TicketScribe)

---

## PHASE 6 — POST-INCIDENT

- [ ] Postmortem avec IT-ReportMaster (dans les 5 jours ouvrables)
- [ ] KB article créé par IT-KnowledgeKeeper
- [ ] Ajustements monitoring/seuils via IT-MonitoringMaster
- [ ] Rapport sécurité mensuel mis à jour

---

## COMMUNICATION CLIENT

| Phase | Message | Via |
|-------|---------|-----|
| Détection | "Incident sécurité détecté, investigation en cours" | IT-TicketScribe |
| Containment | "Services [X] affectés temporairement, correction en cours" | IT-TicketScribe |
| Résolution | Rapport postmortem complet | IT-ReportMaster |

---

## CHECKLIST FINALE AVANT FERMETURE TICKET

- [ ] Vecteur d'entrée confirmé et bouché
- [ ] Tous les systèmes affectés traités
- [ ] Credentials compromis tous réinitialisés
- [ ] Monitoring renforcé actif
- [ ] Client notifié
- [ ] KB créé
- [ ] Postmortem documenté


---

## 6.3 — AUDIT LICENCES LOGICIELLES (SAM)

# RUNBOOK — Audit Licences Logicielles (SAM) MSP
**ID :** RUNBOOK__IT_SOFTWARE_LICENSE_AUDIT_V1  
**Version :** 1.0 | **Agent :** IT-SoftwMaster  
**Applicable :** Audit SAM trimestriel ou à la demande client

---

## DÉCLENCHEURS
- Audit SAM trimestriel planifié
- Départ employé / restructuration
- Nouveau client onboardé
- Alerte audit éditeur (Microsoft, Adobe, Oracle)
- Suspicion over-deployment ou shadow IT

---

## ÉTAPE 1 — COLLECTE INVENTAIRE LOGICIEL

### Via RMM (N-able / ConnectWise RMM) :
- Rapport "Installed Software" par client/site
- Filtrer par catégorie : OS, Office, sécurité, métier, utilitaires

### Via PowerShell (manuel si RMM indisponible) :
```powershell
# Inventaire logiciels installés (toutes architectures)
$Software = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Where-Object DisplayName -ne $null

$Software32 = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Where-Object DisplayName -ne $null

$All = ($Software + $Software32) | Sort-Object Publisher, DisplayName -Unique
$All | Export-Csv "C:\TEMP\Software_Inventory_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
```

### Microsoft 365 — via PowerShell :
```powershell
# Licences M365 utilisées vs disponibles
Connect-MsolService
Get-MsolAccountSku | Select-Object AccountSkuId, ActiveUnits, ConsumedUnits, 
    @{N='Available';E={$_.ActiveUnits - $_.ConsumedUnits}} | Format-Table
```

---

## ÉTAPE 2 — ANALYSE CONFORMITÉ

### 2.1 Matrice à compléter par éditeur :

| Logiciel | Licences achetées | Installs détectées | Delta | Statut |
|----------|------------------|--------------------|-------|--------|
| Windows Server | X | X | ±X | ✅/⚠️/🔴 |
| Microsoft 365 | X | X | ±X | ✅/⚠️/🔴 |
| Adobe Creative | X | X | ±X | ✅/⚠️/🔴 |
| Antivirus/EDR | X | X | ±X | ✅/⚠️/🔴 |

**Statut :** ✅ Conforme | ⚠️ Sous-licencié (<10%) | 🔴 Non conforme (>10% over)

### 2.2 Identifier :
- Logiciels sans licence connue → shadow IT → escalade IT-SecurityMaster
- Licences expirées → renouvellement urgent
- Logiciels en EOL non remplacés → risque sécurité

### 2.3 Microsoft specifics :
- Vérifier type licence : M365 Business vs Enterprise, CAL type (Device/User)
- SQL Server : vérifier Core vs CAL licensing
- Remote Desktop : RDS CAL count vs utilisateurs concurrents
- Confirme SA (Software Assurance) si applicable

---

## ÉTAPE 3 — OPTIMISATION

### Récupérer licences inutilisées :
```powershell
# M365 : comptes sans activité depuis 90 jours
$cutoff = (Get-Date).AddDays(-90)
Get-MsolUser -All | Where-Object { $_.LastDirSyncTime -lt $cutoff -and $_.isLicensed } |
    Select-Object UserPrincipalName, LastDirSyncTime, Licenses
```

### Actions optimisation :
1. Désactiver comptes inactifs > 90 jours → libérer licences
2. Désinstaller logiciels non utilisés (usage < 2x/an)
3. Regrouper licences (consolidation éditeur)
4. Négocier volume si croissance prévue

---

## ÉTAPE 4 — RAPPORT ET RECOMMANDATIONS

### Rapport SAM à produire via IT-ReportMaster :
- Tableau conformité par éditeur
- Économies potentielles identifiées (€/$/mois)
- Risques non-conformité (pénalités estimées si audit)
- Plan d'action : 30/60/90 jours

### Livrables CW :
- Note interne : résultats audit complets
- Discussion client : résumé + recommandations (sans données sensibles)
- Créer tickets pour chaque action requise

---

## ÉTAPE 5 — MISE À JOUR CMDB

- [ ] Mettre à jour IT-AssetMaster : licences actualisées
- [ ] Documenter contrats de maintenance et dates de renouvellement
- [ ] Programmer prochaine revue (trimestrielle recommandée)
- [ ] Alertes créées pour renouvellements à venir (60 jours avant)


---
# SECTION 7 — CLOUD & MICROSOFT 365
> **Pour qui :** Technicien cloud, N2/N3.
> **Quand :** Onboarding utilisateur, gestion M365, architecture cloud.
---

## 7.1 — M365 USER ONBOARDING (Nouveau compte complet)

# RUNBOOK: Microsoft 365 User Onboarding

## Métadonnées
- **ID:** RUNBOOK-M365-USER-001
- **Version:** 1.0
- **Dernière mise à jour:** Février 2026
- **Durée estimée:** 20-30 minutes
- **Niveau:** Intermédiaire

## Objectif
Provisionner un utilisateur Microsoft 365 avec tous les services et permissions selon les meilleures pratiques de sécurité.

## Prérequis
- [ ] Accès Global Admin ou User Admin à M365
- [ ] Licences M365 disponibles
- [ ] Formulaire d'onboarding complété
- [ ] Approbation du manager

## Variables requises
```yaml
user_first_name: "Jean"
user_last_name: "Tremblay"
user_upn: "jtremblay@company.com"
job_title: "Analyste IT"
department: "Technologies"
manager_upn: "mlavoie@company.com"
office_location: "Montreal, QC"
license_sku: "SPE_E3"  # Microsoft 365 E3
groups: ["All-Staff", "IT-Department", "VPN-Users"]
```

## Centres d'administration utilisés
- 🔹 Microsoft 365 Admin Center (admin.microsoft.com)
- 🔹 Azure AD Admin Center (aad.portal.azure.com)
- 🔹 Exchange Admin Center (admin.exchange.microsoft.com)
- 🔹 SharePoint Admin Center (tenant-admin.sharepoint.com)
- 🔹 Teams Admin Center (admin.teams.microsoft.com)
- 🔹 Security & Compliance Center (compliance.microsoft.com)

## Étapes d'exécution

### 1. Création du compte utilisateur
**Durée:** 5 minutes  
**Centre:** Microsoft 365 Admin Center

**Actions PowerShell:**
```powershell
# Se connecter à Microsoft 365
Connect-MsolService

# Créer l'utilisateur
$password = Read-Host -AsSecureString "Entrer mot de passe temporaire"
New-MsolUser -UserPrincipalName $user_upn `
    -FirstName $user_first_name `
    -LastName $user_last_name `
    -DisplayName "$user_first_name $user_last_name" `
    -Title $job_title `
    -Department $department `
    -Office $office_location `
    -Password $password `
    -ForceChangePassword $true `
    -UsageLocation "CA"

# Assigner licence
Set-MsolUserLicense -UserPrincipalName $user_upn -AddLicenses "company:$license_sku"

# Définir le manager
Set-AzureADUserManager -ObjectId $user_upn -RefObjectId (Get-AzureADUser -ObjectId $manager_upn).ObjectId
```

**Via portail:**
1. Aller à admin.microsoft.com
2. Users → Active users → Add a user
3. Remplir informations de base
4. Sélectionner licence Microsoft 365 E3
5. Définir profile info (job title, department, manager)
6. Créer avec mot de passe temporaire

**Validation:**
- [ ] Compte créé avec succès
- [ ] Licence assignée
- [ ] Manager défini
- [ ] Mot de passe temporaire généré

### 2. Configuration Exchange Online
**Durée:** 5 minutes  
**Centre:** Exchange Admin Center

**Actions PowerShell:**
```powershell
# Se connecter à Exchange Online
Connect-ExchangeOnline

# Créer boîte aux lettres (auto-créée avec licence)
# Vérifier statut
Get-Mailbox -Identity $user_upn | Select-Object DisplayName, PrimarySmtpAddress

# Configurer quota de boîte
Set-Mailbox -Identity $user_upn `
    -IssueWarningQuota 45GB `
    -ProhibitSendQuota 48GB `
    -ProhibitSendReceiveQuota 50GB

# Activer archive en ligne
Enable-Mailbox -Identity $user_upn -Archive

# Configurer signature automatique (via template)
# Note: Nécessite solution tierce ou GPO

# Ajouter à listes de distribution
Add-DistributionGroupMember -Identity "All-Staff@company.com" -Member $user_upn
Add-DistributionGroupMember -Identity "IT-Department@company.com" -Member $user_upn

# Configurer délégation si nécessaire
# Add-MailboxPermission -Identity "shared@company.com" -User $user_upn -AccessRights FullAccess
```

**Via portail:**
1. Aller à admin.exchange.microsoft.com
2. Recipients → Mailboxes → Vérifier création boîte
3. Ouvrir boîte → Storage → Configurer quotas
4. Archive → Enable archive
5. Groups → Ajouter aux DL appropriées

**Validation:**
- [ ] Boîte aux lettres active
- [ ] Archive activée
- [ ] Quotas configurés
- [ ] Ajouté aux DL requises

### 3. Configuration Azure AD & Sécurité
**Durée:** 5 minutes  
**Centre:** Azure AD Admin Center

**Actions PowerShell:**
```powershell
# Se connecter à Azure AD
Connect-AzureAD

# Ajouter aux groupes de sécurité
foreach ($group in $groups) {
    $groupObj = Get-AzureADGroup -Filter "DisplayName eq '$group'"
    Add-AzureADGroupMember -ObjectId $groupObj.ObjectId -RefObjectId (Get-AzureADUser -ObjectId $user_upn).ObjectId
}

# Activer MFA (si non activé par Conditional Access)
$st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
$st.RelyingParty = "*"
$st.State = "Enabled"
$sta = @($st)
Set-MsolUser -UserPrincipalName $user_upn -StrongAuthenticationRequirements $sta

# Configurer méthodes d'authentification
# Via portail: Security → MFA → User settings
```

**Via portail:**
1. Aller à aad.portal.azure.com
2. Users → Sélectionner utilisateur
3. Groups → Add memberships → Ajouter All-Staff, IT-Department, VPN-Users
4. Authentication methods → Configure MFA
5. Devices → Vérifier Conditional Access policies appliquées

**Validation:**
- [ ] Ajouté à tous les groupes requis
- [ ] MFA activé
- [ ] Conditional Access appliqué
- [ ] Méthodes d'auth configurées

### 4. Configuration Teams & SharePoint
**Durée:** 5 minutes  
**Centre:** Teams Admin Center / SharePoint Admin Center

**Actions PowerShell:**
```powershell
# Se connecter à Teams
Connect-MicrosoftTeams

# Ajouter aux équipes
Add-TeamUser -GroupId "team-id-it-department" -User $user_upn -Role Member

# Configurer politique d'appel
Grant-CsTeamsCallingPolicy -Identity $user_upn -PolicyName "CanadaCallingPolicy"

# Configurer accès SharePoint
# Via SharePoint Admin Center ou site-specific
Connect-PnPOnline -Url "https://company.sharepoint.com/sites/IT-Department"
Add-PnPSiteCollectionAppCatalog
```

**Via portail:**
1. **Teams Admin Center** (admin.teams.microsoft.com):
   - Users → Sélectionner utilisateur
   - Policies → Assigner calling, messaging, meeting policies
   - Groups → Ajouter aux teams appropriées

2. **SharePoint Admin Center** (tenant-admin.sharepoint.com):
   - Active sites → Sélectionner site IT
   - Permissions → Add member
   - Ajouter utilisateur avec permissions appropriées

**Validation:**
- [ ] Ajouté aux Teams requises
- [ ] Policies Teams assignées
- [ ] Accès SharePoint configuré
- [ ] OneDrive provisionné

### 5. Configuration sécurité & compliance
**Durée:** 5 minutes  
**Centre:** Security & Compliance Center

**Actions:**
1. **Data Loss Prevention:**
   - Aller à compliance.microsoft.com
   - Policies → DLP → Vérifier que user est couvert
   
2. **Retention Policies:**
   - Information governance → Retention
   - Vérifier application des politiques de rétention

3. **Sensitivity Labels:**
   - Information protection → Labels
   - Publier labels au user si nécessaire

4. **Audit Logging:**
   - Vérifier que actions sont auditées
   ```powershell
   Search-UnifiedAuditLog -UserIds $user_upn -StartDate (Get-Date).AddDays(-1) -EndDate (Get-Date)
   ```

**Validation:**
- [ ] DLP appliqué
- [ ] Retention policies actives
- [ ] Sensitivity labels disponibles
- [ ] Audit logging fonctionnel

### 6. Configuration complémentaire
**Durée:** 5 minutes

**Actions:**
```powershell
# Configurer langue et timezone
Set-MailboxRegionalConfiguration -Identity $user_upn `
    -Language "fr-CA" `
    -DateFormat "dd/MM/yyyy" `
    -TimeFormat "HH:mm" `
    -TimeZone "Eastern Standard Time"

# Configurer signature email via template
# [Nécessite solution tierce ou script custom]

# Configurer mobile device policy
Set-CASMailbox -Identity $user_upn -ActiveSyncEnabled $true

# Documenter dans CMDB
# [Via script ou manuel]
```

**Validation:**
- [ ] Langue et timezone configurées
- [ ] ActiveSync activé
- [ ] Mobile device policy appliquée

## Post-exécution

### Documentation
- [ ] Mettre à jour CMDB avec informations utilisateur
- [ ] Documenter groups et permissions
- [ ] Créer entrée dans système de tickets
- [ ] Notifier équipe IT

### Communication utilisateur

**Email de bienvenue à envoyer:**
```
Objet: Bienvenue chez [Entreprise] - Vos accès Microsoft 365

Bonjour Jean,

Bienvenue dans l'équipe! Voici vos informations de connexion:

📧 Email: jtremblay@company.com
🔐 Mot de passe temporaire: [fourni séparément]
🌐 Portail: https://portal.office.com

IMPORTANT: À votre première connexion, vous devrez:
1. Changer votre mot de passe
2. Configurer l'authentification multifacteur (MFA)
3. Installer Microsoft Authenticator sur votre téléphone

Applications disponibles:
✓ Outlook (email)
✓ Teams (messagerie, appels, réunions)
✓ SharePoint (documents partagés)
✓ OneDrive (stockage personnel - 1TB)
✓ Office Apps (Word, Excel, PowerPoint)

Ressources:
- Guide de démarrage: [lien intranet]
- Support IT: helpdesk@company.com
- Votre manager: Marie Lavoie (mlavoie@company.com)

Si vous avez des questions, n'hésitez pas à contacter le service IT.

Cordialement,
Équipe IT
```

### Handover au manager
- [ ] Notifier manager que compte est actif
- [ ] Confirmer permissions et groupes
- [ ] Planifier onboarding technique si nécessaire

## Tests de validation

### Checklist finale
```powershell
# Script de validation complet
$user = Get-MsolUser -UserPrincipalName $user_upn

Write-Host "=== VALIDATION COMPTE M365 ===" -ForegroundColor Green
Write-Host "Nom: $($user.DisplayName)"
Write-Host "UPN: $($user.UserPrincipalName)"
Write-Host "Licence: $(if($user.isLicensed){'✓ Assignée'}else{'✗ Manquante'})"
Write-Host "MFA: $(if($user.StrongAuthenticationRequirements){'✓ Activé'}else{'✗ Désactivé'})"

$mailbox = Get-Mailbox -Identity $user_upn
Write-Host "Boîte email: $(if($mailbox){'✓ Créée'}else{'✗ Manquante'})"
Write-Host "Archive: $(if($mailbox.ArchiveStatus -eq 'Active'){'✓ Activée'}else{'✗ Désactivée'})"

$groups = Get-AzureADUserMembership -ObjectId $user_upn
Write-Host "Groupes: $($groups.Count) groupes" -ForegroundColor Cyan
$groups | ForEach-Object { Write-Host "  - $($_.DisplayName)" }
```

**Résultat attendu:**
- ✓ Licence assignée
- ✓ MFA activé
- ✓ Boîte email créée
- ✓ Archive activée
- ✓ Minimum 3 groupes (All-Staff, IT-Department, VPN-Users)

## Rollback

En cas d'erreur ou annulation:

```powershell
# Désactiver le compte (soft delete)
Set-MsolUser -UserPrincipalName $user_upn -BlockCredential $true

# OU supprimer complètement (30 jours retention)
Remove-MsolUser -UserPrincipalName $user_upn -Force

# Récupérer licence
Set-MsolUserLicense -UserPrincipalName $user_upn -RemoveLicenses "company:$license_sku"

# Retirer des groupes
foreach ($group in $groups) {
    $groupObj = Get-AzureADGroup -Filter "DisplayName eq '$group'"
    Remove-AzureADGroupMember -ObjectId $groupObj.ObjectId -MemberId (Get-AzureADUser -ObjectId $user_upn).ObjectId
}
```

## Métriques de succès
- Temps d'onboarding < 30 minutes
- Aucune erreur durant provisionnement
- Utilisateur peut se connecter et utiliser services
- MFA configuré et fonctionnel
- Tous les groupes assignés

## Références
- [M365 User Management Best Practices](https://docs.microsoft.com/microsoft-365/admin/add-users/)
- [Azure AD Security Best Practices](https://docs.microsoft.com/azure/active-directory/fundamentals/identity-secure-score)
- Standards internes: `SHARED/IT-MSP/10_RUN/MEM-IT-Routing-Rules.md`

## Historique des modifications
| Date | Version | Auteur | Changements |
|------|---------|--------|-------------|
| 2026-02-10 | 1.0 | IT-CloudMaster | Création initiale |


---

## 7.2 — M365 USER MANAGEMENT (Opérations courantes)

# RUNBOOK - M365 User Management

## Création nouvel utilisateur M365

### Pré-requis
- [ ] Licence disponible
- [ ] Nom/Email validé par RH
- [ ] Département et manager connus
- [ ] Groupes de sécurité identifiés

### Procédure (Azure AD)

```powershell
# Connexion
Connect-AzureAD
Connect-MsolService

# Créer l'utilisateur
$UserPrincipalName = "prenom.nom@domain.com"
$DisplayName = "Prénom Nom"
$Password = (ConvertTo-SecureString -String "<TEMP_PASSWORD>!" -AsPlainText -Force)

New-AzureADUser `
    -DisplayName $DisplayName `
    -UserPrincipalName $UserPrincipalName `
    -AccountEnabled $true `
    -PasswordProfile @{Password = $Password; ForceChangePasswordNextLogin = $true} `
    -Department "IT" `
    -JobTitle "Titre" `
    -MailNickname "prenom.nom"

# Assigner licence E3
Set-MsolUserLicense -UserPrincipalName $UserPrincipalName `
    -AddLicenses "tenant:ENTERPRISEPACK"

# Ajouter aux groupes
Add-AzureADGroupMember -ObjectId "group-id" -RefObjectId "user-id"
```

### Validation post-création
- [ ] Connexion au portail Office 365
- [ ] Email fonctionnel
- [ ] Accès Teams/SharePoint
- [ ] Licence activée

### Troubleshooting

**Problème:** Licence non disponible
- Vérifier inventaire: `Get-MsolAccountSku`
- Commander licences supplémentaires

**Problème:** Email non livré
- Vérifier MX records
- Valider Mail flow rules
- Tester avec `Test-Mailflow`

## Gestion groupes de distribution

### Créer groupe distribution

```powershell
New-DistributionGroup `
    -Name "Equipe-IT" `
    -DisplayName "Équipe IT" `
    -PrimarySmtpAddress "equipe-it@domain.com" `
    -MemberJoinRestriction "Closed" `
    -MemberDepartRestriction "Closed"

# Ajouter membres
Add-DistributionGroupMember `
    -Identity "Equipe-IT" `
    -Member "user@domain.com"
```

### Convertir en groupe M365

```powershell
Upgrade-DistributionGroup -DlIdentities "Equipe-IT"
```

## Onboarding client nouveau locataire

1. **Configuration initiale**
   - Activer MFA pour admins
   - Configurer Conditional Access policies
   - Établir naming standards
   
2. **Sécurité de base**
   - Bloquer legacy authentication
   - Activer ATP Safe Links
   - Configurer DLP policies

3. **Email flow**
   - Configurer SPF/DKIM/DMARC
   - Mail flow rules anti-spam
   - Transport rules

## Références rapides

### Portails d'administration
- Azure AD: https://portal.azure.com
- M365 Admin: https://admin.microsoft.com
- Exchange Admin: https://admin.exchange.microsoft.com
- Security & Compliance: https://protection.office.com

### Commandes PowerShell essentielles

```powershell
# Connexion modules
Connect-AzureAD
Connect-MsolService  
Connect-ExchangeOnline

# Lister utilisateurs
Get-AzureADUser -All $true | Select UserPrincipalName,DisplayName

# Lister licences
Get-MsolAccountSku

# Reset MFA
Reset-MsolStrongAuthenticationMethodByUpn -UserPrincipalName "user@domain.com"

# Mailbox stats
Get-MailboxStatistics -Identity "user@domain.com"
```


---

## 7.3 — ARCHITECTURE CLOUD

# RUNBOOK — IT_CLOUD_ARCHITECTURE_V1
_Généré le 2026-01-17T21:19:45Z_

## 1) Objectif
Architecture cloud (requirements -> design -> sécurité -> runbook)

## 2) Owner / Acteurs
- Owner (par défaut) : `IT-CTOMaster`
- Steps (ordre canon) :
  - **cto** → `IT-CTOMaster`
  - **cloud** → `IT-CloudMaster`
  - **security** → `IT-SecurityMaster`
  - **kb** → `IT-KnowledgeKeeper`

## 3) Inputs attendus
- Contexte : demande + objectifs + contraintes
- Données : liens, docs, extraits (si applicable)
- Format de sortie requis (si applicable)

## 4) Procédure
1. Exécuter les steps dans l’ordre.
2. Documenter les décisions / hypothèses.
3. Produire l’output final + résumé exécutif.

## 5) Contrôles qualité
- Check conformité (policies du domaine)
- Cohérence interne + traçabilité des sources (si applicable)
- Format de sortie respecté

## 6) Erreurs fréquentes / Escalade
- Si informations manquantes : demander les éléments minimaux (but, audience, contraintes).
- Si risque sécurité/conformité : escalader vers `META-GouvernanceEtRisques`.

## 7) Definition of Done
- Output livré + résumé
- Artefacts archivés si nécessaire (ex: `OPS-DossierIA`)


---
# SECTION 8 — RÉSEAU & VOIP
> **Pour qui :** Technicien réseau, N2/N3.
> **Quand :** Problème connectivité, diagnostic réseau, panne téléphonie.
---

## 8.1 — DIAGNOSTIC RÉSEAU

# RUNBOOK — IT_NETWORK_DIAGNOSTIC_V1
_Généré le 2026-01-17T21:19:45Z_

## 1) Objectif
Diagnostic réseau (symptômes -> hypothèses -> tests -> correctifs)

## 2) Owner / Acteurs
- Owner (par défaut) : `IT-SupportMaster`
- Steps (ordre canon) :
  - **support** → `IT-SupportMaster`
  - **network** → `IT-NetworkMaster`
  - **infra** → `IT-Commandare-Infra`
  - **report** → `IT-ReportMaster`

## 3) Inputs attendus
- Contexte : demande + objectifs + contraintes
- Données : liens, docs, extraits (si applicable)
- Format de sortie requis (si applicable)

## 4) Procédure
1. Exécuter les steps dans l’ordre.
2. Documenter les décisions / hypothèses.
3. Produire l’output final + résumé exécutif.

## 5) Contrôles qualité
- Check conformité (policies du domaine)
- Cohérence interne + traçabilité des sources (si applicable)
- Format de sortie respecté

## 6) Erreurs fréquentes / Escalade
- Si informations manquantes : demander les éléments minimaux (but, audience, contraintes).
- Si risque sécurité/conformité : escalader vers `META-GouvernanceEtRisques`.

## 7) Definition of Done
- Output livré + résumé
- Artefacts archivés si nécessaire (ex: `OPS-DossierIA`)


---

## 8.2 — DIAGNOSTIC TÉLÉPHONIE IP / VOIP

# RUNBOOK — Diagnostic Téléphonie IP & VoIP MSP
**ID :** RUNBOOK__IT_VOIP_DIAGNOSTIC_V1  
**Version :** 1.0 | **Agent :** IT-VoIPMaster  
**Applicable :** Tout incident VoIP/UC (3CX, Teams Phone, SIP trunk, qualité audio)

---

## DÉCLENCHEURS
- Plainte qualité audio (écho, coupures, one-way audio)
- Téléphones ne s'enregistrent plus (registration failure)
- Trunk SIP en échec / pas de tonalité externe
- Teams Phone : appels entrants/sortants impossibles
- Dégradation MOS signalée par utilisateurs

---

## ÉTAPE 1 — QUALIFICATION INITIALE (5 min)

Répondre aux questions :
1. Quel système VoIP ? (3CX / Teams Phone / Cisco CUCM / Mitel / RingCentral / autre)
2. Symptôme précis ? (pas de son / son unidirectionnel / écho / coupures / registration fail)
3. Affecté : 1 poste / un site complet / tous les sites ?
4. Depuis quand ? Changement récent ? (mise à jour, changement réseau, nouveau fournisseur SIP)
5. Appels internes affectés ? Externes ? Les deux ?

**Diagnostic préliminaire :**
- Interne seulement → problème PBX/VLAN/config locale
- Externe seulement → problème trunk SIP / fournisseur
- Interne + externe → problème réseau/QoS ou PBX global

---

## ÉTAPE 2 — TESTS RÉSEAU (10-15 min)

### 2.1 Test latence et jitter vers trunk SIP
```powershell
# Test ping vers IP du trunk SIP (remplacer X.X.X.X)
# ⚠️ Info : lecture seule, aucun impact
Test-NetConnection -ComputerName "sip.provider.com" -Port 5060

# Ping continu pour mesurer jitter
ping -t sip.provider.com | Measure-Object
```

**Seuils :**
- Latence OK : < 80ms | Warning : 80-150ms | Critique : > 150ms
- Packet loss OK : 0% | Warning : 0.5-1% | Critique : > 1%

### 2.2 Vérifier VLAN Voice
```powershell
# Vérifier configuration réseau sur poste VoIP
ipconfig /all | Select-String "IPv4|VLAN"
# Confirmer VLAN Voice séparé du data (bonne pratique)
```

### 2.3 Vérifier QoS
- Confirmer DSCP EF (46) taggé pour flux RTP
- Confirmer politique QoS active sur switch/routeur
- Sur switch Cisco : `show mls qos interface` ou `show policy-map interface`

---

## ÉTAPE 3 — DIAGNOSTIC PAR SYMPTÔME

### Symptôme A : Registration SIP échoue
```
Causes probables :
1. Credentials SIP incorrects (username/password/domain)
2. Firewall bloque UDP 5060 ou TCP 5061
3. NAT traversal mal configuré (STUN/TURN)
4. Serveur SIP inaccessible (résolution DNS)

Tests :
- Depuis PBX : nslookup sip.provider.com
- Wireshark sur port 5060 : capture 401 Unauthorized vs timeout
- Tester depuis hors NAT (connexion directe) pour isoler NAT
```

### Symptôme B : Audio unidirectionnel (one-way audio)
```
Cause quasi-certaine : problème NAT / RTP ports bloqués

Tests :
- Vérifier port range RTP ouvert (typique : UDP 10000-20000)
- Vérifier STUN server configuré dans PBX
- Tester avec softphone sur réseau différent
- Wireshark : flux RTP reçu d'un seul côté
```

### Symptôme C : Écho ou délai
```
Causes probables :
1. Latence WAN > 150ms → écho perceptible
2. AEC (Acoustic Echo Cancellation) désactivé sur téléphone
3. Haut-parleur trop fort côté distant

Tests :
- Mesurer latence vers trunk SIP (voir 2.1)
- Vérifier paramètres AEC dans config téléphone/PBX
- Tester avec casque vs haut-parleur
```

### Symptôme D : Teams Phone ne fonctionne pas
```
Checklist spécifique :
- Licence Phone System attribuée à l'utilisateur ? (Azure AD Admin Center)
- Direct Routing : SBC certifié et certificat valide ?
- Dial plan configuré ? (normalization rules)
- Voice routing policy assignée à l'utilisateur ?

Commandes PowerShell Teams :
# Vérifier licence
Get-MsolUser -UserPrincipalName user@domain.com | Select-Object Licenses
# Vérifier politique voix
Get-CsOnlineUser user@domain.com | Select-Object TeamsUpgradeMode, VoiceRoutingPolicy
```

---

## ÉTAPE 4 — VÉRIFICATIONS 3CX SPÉCIFIQUES

```
Dashboard 3CX :
- Status → Trunks : vérifier statut trunk (Registered/Unregistered)
- Status → Phones : vérifier registrations
- Logs → SIP trace : activer 5 min pour capturer erreurs

Ports à vérifier ouverts vers 3CX :
- TCP 5090 (Tunnel)
- UDP 9000-10999 (RTP media)
- TCP/UDP 5060-5061 (SIP)
- TCP 443, 5000-5001 (Web/Apps)
```

---

## ÉTAPE 5 — RÉSOLUTION ET DOCUMENTATION

### Après résolution :
- [ ] Test appel entrant + sortant validé
- [ ] Test qualité audio (MOS > 3.5 minimum, > 4.0 idéal)
- [ ] Documentation dans CW via IT-TicketScribe
- [ ] KB créé si problème non documenté

### Si non résolu :
- Escalader vers IT-NetworkMaster (problème réseau/QoS confirmé)
- Escalader vers IT-CloudMaster (Teams Phone/M365)
- Contacter fournisseur SIP trunk (si trunk side)


---
# SECTION 9 — BACKUP & DISASTER RECOVERY
> **Pour qui :** Technicien backup, N2/N3.
> **Quand :** Test DR, gestion cycle de vie assets, validation backups.
---

## 9.1 — TEST BACKUP / DR

# RUNBOOK — IT_BACKUP_DR_TEST_V1
_Généré le 2026-01-17T21:19:45Z_

## 1) Objectif
Test Backup/DR (plan -> exécution -> preuves -> rapport)

## 2) Owner / Acteurs
- Owner (par défaut) : `IT-BackupDRMaster`
- Steps (ordre canon) :
  - **backup** → `IT-BackupDRMaster`
  - **report** → `IT-ReportMaster`
  - **kb** → `IT-KnowledgeKeeper`

## 3) Inputs attendus
- Contexte : demande + objectifs + contraintes
- Données : liens, docs, extraits (si applicable)
- Format de sortie requis (si applicable)

## 4) Procédure
1. Exécuter les steps dans l’ordre.
2. Documenter les décisions / hypothèses.
3. Produire l’output final + résumé exécutif.

## 5) Contrôles qualité
- Check conformité (policies du domaine)
- Cohérence interne + traçabilité des sources (si applicable)
- Format de sortie respecté

## 6) Erreurs fréquentes / Escalade
- Si informations manquantes : demander les éléments minimaux (but, audience, contraintes).
- Si risque sécurité/conformité : escalader vers `META-GouvernanceEtRisques`.

## 7) Definition of Done
- Output livré + résumé
- Artefacts archivés si nécessaire (ex: `OPS-DossierIA`)


---

## 9.2 — CYCLE DE VIE ASSETS IT

# RUNBOOK — IT_ASSET_LIFECYCLE_V1
_Généré le 2026-01-17T21:19:45Z_

## 1) Objectif
Gestion du cycle de vie des assets (inventaire -> standard -> plan renouvellement)

## 2) Owner / Acteurs
- Owner (par défaut) : `IT-AssetMaster`
- Steps (ordre canon) :
  - **asset** → `IT-AssetMaster`
  - **softw** → `IT-SoftwMaster`
  - **report** → `IT-ReportMaster`

## 3) Inputs attendus
- Contexte : demande + objectifs + contraintes
- Données : liens, docs, extraits (si applicable)
- Format de sortie requis (si applicable)

## 4) Procédure
1. Exécuter les steps dans l’ordre.
2. Documenter les décisions / hypothèses.
3. Produire l’output final + résumé exécutif.

## 5) Contrôles qualité
- Check conformité (policies du domaine)
- Cohérence interne + traçabilité des sources (si applicable)
- Format de sortie respecté

## 6) Erreurs fréquentes / Escalade
- Si informations manquantes : demander les éléments minimaux (but, audience, contraintes).
- Si risque sécurité/conformité : escalader vers `META-GouvernanceEtRisques`.

## 7) Definition of Done
- Output livré + résumé
- Artefacts archivés si nécessaire (ex: `OPS-DossierIA`)


---
# SECTION 10 — DOCUMENTATION & CAPITALISATION
> **Pour qui :** Tout technicien après résolution d'un incident.
> **Quand :** Transformer un ticket résolu en article KB réutilisable.
> **Règle :** Tout incident P1/P2 et tout nouveau type de problème → KB obligatoire.
---

## 10.1 — TICKET → KB (Capitalisation des connaissances)

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

## GUIDE D'UTILISATION RAPIDE — Pour les nouveaux techniciens

### Je reçois un billet → Section 1 (Dispatch + Triage)
### Je suis en intervention active → Section 2 (Intervention Live)
### Je fais du patching → Section 3 + 4 (Maintenance + Validations)
### J'ai une alerte NOC → Section 5 (NOC & Incidents)
### J'ai une alerte sécurité → Section 6 (Sécurité)
### Problème M365 / cloud → Section 7 (Cloud & M365)
### Problème réseau / téléphonie → Section 8 (Réseau & VoIP)
### Problème backup → Section 9 (Backup & DR)
### J'ai résolu un incident complexe → Section 10 (KB)
### GPO ou permissions dossiers → Section 11 (AD Avancé)
### Déployer une nouvelle VM → Section 12 (Provisioning VM)

---

## SECTION 11 — AD AVANCÉ

### 11.1 — GESTION GPO

> Runbook : `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-GPO_Management_V1.md`
> Mot-clé menu : `ad-gpo`

Couvre : audit des GPO existantes, convention de nommage, identification de paramètres, héritage LSDOU, checklist avant création, liaison GPO à une OU, bonnes pratiques MSP, diagnostic (gpresult, Event IDs 1085/1125/1129), rollback.

### 11.2 — SÉCURITÉ DOSSIERS NTFS VIA GROUPES AD

> Runbook : `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-FolderSecurity_V1.md`
> Mot-clé menu : `ad-folder`

Couvre : règle AGDLP, audit permissions NTFS, héritage parent-enfant, break inheritance, création groupes DL/GG, assignation permissions, convention de nommage des groupes, cas fréquents (accès refusé, héritage non désiré).

---

## SECTION 12 — PROVISIONING VM

### 12.1 — DÉPLOIEMENT NOUVELLE VM

> Runbook : `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-NewVM_Deployment_V1.md`
> Mot-clé menu : `new-vm`

Couvre : vérification ressources hôte (CPU/RAM/disque), limites physiques (vCPU max 80%, ratio backup 1:2), placement anti-affinité (DC jamais sur même ESXi), configuration disques par rôle (AD/DC, FS, SQL 5 disques, RDS, Veeam ReFS, PAW), sizing 11 rôles, checklist pré-déploiement, création Hyper-V (PowerShell) + VMware (vCenter + PowerCLI), post-déploiement (domaine, RMM, backup J+1).

---

## NOTES DE CONSOLIDATION

| Statistique | Valeur |
|-------------|--------|
| Fichiers source analysés | 39 |
| Stubs génériques exclus | 8 |
| Doublons exacts | 0 |
| Runbooks uniques retenus | 34 |
| Sections thématiques | 12 |
| Audience cible | Techniciens N1 → N3, nouveaux techniciens |

```
