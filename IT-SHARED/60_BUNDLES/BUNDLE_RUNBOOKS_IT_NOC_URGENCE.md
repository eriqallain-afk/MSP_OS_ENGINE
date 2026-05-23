# BUNDLE_RUNBOOKS_IT_NOC_URGENCE
**Bundle Runbooks — IT MSP Intelligence Platform**
**Catégorie :** NOC — Urgences P1/P2, Incident Command, Dispatch, Post-panne HQ
**Agents consommateurs :** @IT-UrgenceMaster | @IT-Commandare-NOC | @IT-Commandare-NOCDispatcher | @IT-Commandare-Infra
**Version :** 1.0 | **Date :** 2026-04-04
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Repo GitHub :** `PRODUCTS/IT/IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOKS_IT_NOC_URGENCE.md`

> Ce bundle regroupe tous les runbooks de la catégorie **NOC — Urgences P1/P2, Incident Command, Dispatch, Post-panne HQ**.
> Uploader en Knowledge dans les GPT agents indiqués.
> Les runbooks sont à jour — source canonique dans GitHub.

---

## RB-NOC-001 — Incident Command — P1/P2 Coordination

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

## RB-NOC-002 — NOC Frontdoor — Premier répondant

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

## RB-NOC-003 — NOC Dispatch — Priorisation et assignation

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

## RB-NOC-004 — NOC Command Center — Procédures opérationnelles

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

## RB-NOC-005 — Post-Shutdown Électrique — Reprise infra complète

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

## RB-NOC-006 — NOC Procedures générales

# RUNBOOK — Procédures NOC : Triage, Corrélation et Réponse aux Alertes
**ID :** RUNBOOK__NOC_Procedures | **Version :** 2.0
**Agent owner :** IT-Commandare-NOC | **Équipe :** TEAM__IT
**Domaine :** NOC — Opérations Centre de surveillance
**Date révision :** 2026-03-13

---

## ⚠️ GARDE-FOUS — OBLIGATOIRES
> Référence : `00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md`

**Scope :** Cet agent traite uniquement les alertes et incidents NOC du billet actif.
Il ne répond pas à des questions générales, personnelles ou hors périmètre IT.

**Données sensibles :**
- ❌ JAMAIS dans les livrables : adresses IP, noms de comptes, credentials
- ❌ Outputs client-safe : aucun chemin UNC, aucun identifiant système interne
- Alerte contenant des credentials → masquer immédiatement, alerter le technicien

**Actions :**
- Isolation réseau → `⚠️ Impact : coupure accès complet` + validation senior
- Arrêt service critique → `⚠️ Impact : interruption service` + validation + dépendances vérifiées

---

## 1. Objectif
Standardiser les procédures NOC pour :
- Réception et qualification des alertes (monitoring / RMM / client)
- Triage et classification (P1-P4)
- Corrélation multi-alertes
- Déclenchement des runbooks spécialisés

---

## 2. Flux de traitement d'une alerte

```
ALERTE ENTRANTE (RMM / Monitoring / Client / Email)
        │
        ▼ Étape 1 — Qualification (< 5 min)
   Est-ce une vraie alerte ou du bruit ?
   └─ Bruit connu → ACK + noter dans CW + surveiller
   └─ Vraie alerte → continuer
        │
        ▼ Étape 2 — Classification (P1/P2/P3/P4)
   Impact business ?  Propagation active ?
        │
        ├─ P1/P2 → Activation Commandare + plan d'action immédiat
        ├─ P3    → Ticket CW + assignation + SLA 4h
        └─ P4    → Ticket CW planifié
        │
        ▼ Étape 3 — Dispatch
   Type d'incident ?
   ├─ Infra/Serveur  → IT-Commandare-Infra
   ├─ Réseau/VPN     → IT-NetworkMaster
   ├─ Backup         → IT-BackupDRMaster
   ├─ Sécurité       → IT-SecurityMaster
   ├─ M365/Cloud     → IT-CloudMaster
   └─ Support user   → IT-Commandare-TECH
        │
        ▼ Étape 4 — Suivi + Clôture
   Résolution confirmée → Documentation CW + ACK monitoring
```

---

## 3. Classification P1-P4

| Priorité | Critères | Exemples | SLA réponse | SLA mitigation |
|----------|---------|---------|-------------|----------------|
| P1 | Service critique down / sécurité active / données à risque | DC down, ransomware actif, réseau principal coupé | 15 min | 60 min |
| P2 | Fonctionnalité clé dégradée / impact large | Email lent, VPN instable, backup en échec > 48h | 30 min | 4h |
| P3 | Incident contournable / impact limité | Imprimante KO, PC utilisateur lent, service mineur arrêté | 4h | 1 jour ouvré |
| P4 | Amélioration / demande planifiée | Ajout logiciel, question technique, documentation | Best effort | 3 jours ouvrés |

---

## 4. Réponse aux alertes courantes

### 4.1 Alerte CPU > 90% (serveur)
```powershell
# Diagnostic (lecture seule — aucun impact)
# Processus consommateurs
Get-Process | Sort-Object CPU -Descending | Select-Object -First 15 Name, Id,
  @{n='CPU_s';e={[math]::Round($_.CPU,0)}},
  @{n='RAM_MB';e={[math]::Round($_.WorkingSet/1MB,0)}} | Format-Table -Auto

# Événements récents (charge anormale)
$Start = (Get-Date).AddHours(-1)
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=$Start} -ErrorAction SilentlyContinue |
  Where-Object {$_.LevelDisplayName -in 'Error','Critical'} |
  Select-Object -First 10 TimeCreated, Id, Message | Format-Table -Wrap
```

### 4.2 Alerte espace disque < 10%
```powershell
# État disques (lecture seule)
Get-PSDrive -PSProvider FileSystem |
  Select-Object Name,
    @{n='Total_GB';e={[math]::Round(($_.Used+$_.Free)/1GB,1)}},
    @{n='Libre_GB';e={[math]::Round($_.Free/1GB,1)}},
    @{n='Libre_%';e={if(($_.Used+$_.Free) -gt 0){[math]::Round($_.Free/($_.Used+$_.Free)*100,1)}else{'N/A'}}} |
  Format-Table -Auto

# Top 10 dossiers les plus volumineux (lecture seule)
Get-ChildItem -Path "C:\" -Directory -ErrorAction SilentlyContinue |
  ForEach-Object {
    [pscustomobject]@{
      Dossier = $_.FullName
      Taille_GB = [math]::Round((Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue |
                   Measure-Object -Property Length -Sum).Sum / 1GB, 2)
    }
  } | Sort-Object Taille_GB -Descending | Select-Object -First 10 | Format-Table -Auto
```

### 4.3 Alerte service Windows arrêté
```powershell
# Vérifier état
Get-Service -Name "[SERVICE]" | Select-Object Name, Status, StartType, DisplayName

# Événements liés
Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=(Get-Date).AddHours(-2)} |
  Where-Object {$_.Message -match "[SERVICE]"} |
  Select-Object -First 10 TimeCreated, Id, LevelDisplayName, Message | Format-Table -Wrap

# ⚠️ Impact : démarrage du service — peut affecter les utilisateurs connectés
# → Confirmer avant : Start-Service -Name "[SERVICE]"
```

### 4.4 Alerte monitoring — Corrélation multi-alertes
```
Règle de corrélation :
- 3+ alertes différentes sur le même client en < 30 min → probable incident infra global
- Alertes sur DC + DNS + DHCP simultanées → incident AD (P1)
- CPU + RAM + Disque simultanés sur même serveur → saturation (P2)
- Alertes réseau + backup en échec → problème connectivité (P2)

Action corrélation :
→ Créer UN ticket parent P1/P2
→ Lier les alertes individuelles comme tickets enfants
→ Activer IT-Commandare-Infra ou IT-Commandare-TECH selon domaine
```

---

## 5. Checklist fermeture alerte/ticket

- [ ] Cause racine identifiée (ou documentée comme `[À CONFIRMER]`)
- [ ] Action corrective appliquée (ou planifiée avec date)
- [ ] Monitoring ACK / alerte résolue dans le système
- [ ] Service / indicateur de retour à la normale confirmé
- [ ] Note CW complète (timeline + actions + résultat)
- [ ] Si récurrent → KB créée ou enrichie via `IT-KnowledgeKeeper`

---

## 6. Livrables CW

### Note interne
```
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

Alerte reçue : [type d'alerte — serveur/service — sans IP]
Classification : P[1/2/3/4]
Heure détection : [HH:MM]
Corrélation : [alerte isolée / liée à : ticket XXX]
Actions NOC :
  1. [action — FAIT / KO / [À CONFIRMER]]
  2. [action — FAIT / KO / [À CONFIRMER]]
Dispatch vers : @[Agent]
Résultat : [service rétabli / escalade en cours / planifié]
Durée d'interruption : [si applicable]
```

### Discussion client (client-safe)
```
- Détection et prise en charge de l'alerte.
- Analyse et identification de la cause.
- Correctif appliqué : [description fonctionnelle sans détails techniques].
- Retour à la normale confirmé.
- Prochaine étape : [surveillance renforcée / aucune action requise].
```

---

## 7. Escalade
- P1 immédiat → `IT-Commandare-NOC` + `IT-[Spécialiste domaine]`
- Incident sécurité → `IT-SecurityMaster` IMMÉDIAT
- 2 interventions sans résolution → `IT-Commandare-TECH`


---
