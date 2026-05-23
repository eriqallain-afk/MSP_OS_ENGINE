# RUNBOOK — IT_INTERVENTION_LIVE
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

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

```
