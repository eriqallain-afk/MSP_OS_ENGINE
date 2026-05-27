# Guide d'utilisation — @IT-OPS-RouterIA (v1.0)
> **Pour :** Techniciens N1/N2/N3 et agents OPS
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-OPS-RouterIA ?

**IT-OPS-RouterIA est le point d'entrée de la plateforme.**

Tu lui donnes un ticket, une alerte RMM ou un message en texte libre — il identifie l'intent, charge le bon runbook depuis `MASTER_DISPATCH_INDEX_V2.yaml`, et te livre une fiche actionnable avec les préchecks et questions de gouvernance nécessaires.

**Règle d'or — Discovery-first :**
Si le rôle du serveur n'est pas confirmé, RouterIA demande d'abord d'exécuter le script de discovery avant de proposer tout runbook. Cela évite d'appliquer le mauvais runbook sur un serveur critique.

```
Ticket entrant (texte libre)
        ↓
IT-OPS-RouterIA
        ↓
Intent identifié → Runbook chargé → Runbook card + Questions
        ↓
IT-OPS-PlaybookRunner (exécution guidée)
        ↓
IT-OPS-DossierIA (archivage)
```

---

## Quand l'utiliser ?

- Tu reçois un ticket ou alerte que tu ne sais pas comment classifier
- Tu veux savoir quel runbook appliquer pour un incident
- Tu veux les questions de gouvernance à poser avant une intervention risquée
- Un agent ou script t'a fourni un `role_profile` et tu veux la route spécifique

---

## Les commandes / usages principaux

### Usage de base — Ticket texte libre

Colle simplement le contenu du ticket ou de l'alerte.

**Exemple :**
```
Voici un ticket : "Windows update missing sur DCsrv01, reboot required depuis 3 jours.
Client : ABC Corp. Serveur : SRV-DC01."
```

**Ce que tu obtiens :**
```yaml
result:
  route:
    intent_id: it.discovery.server_role
    risk_level: high
    runbook_path: IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__SERVER_ROLE_DISCOVERY.md
    actor_id: IT-OPS-PlaybookRunner
  runbook_card:
    - Exécuter SCRIPT_Analyse_Serveur_TicketOps_V1.ps1 sur SRV-DC01
    - Coller le role_profile résultant pour routing spécifique
  questions:
    - Rôle confirmé de SRV-DC01 ? (DC, SQL, RDS, FS ?)
    - Nombre de DCs dans le domaine ?
```

---

### Usage avec role_profile — Routing direct

Si tu as déjà exécuté le script de discovery et obtenu un `role_profile`, colle-le directement.

**Exemple :**
```
[Coller le role_profile YAML]
role_profile:
  server_name: SRV-DC01
  detected_roles: [DC, GC]
  os: Windows Server 2022
  ...
```

**Ce que tu obtiens :** Route directe vers le runbook DC avec préchecks et questions de gouvernance spécifiques (fenêtre de maintenance, change_id, méthode patching, backup confirmé).

---

### Usage avec alerte RMM

**Exemple :**
```
Alerte N-able : CPU 95% depuis 20 min sur SRV-SQL01. Processus sqlservr.exe dominant.
```

**Ce que tu obtiens :** Intent SQL Performance, runbook_card diagnostique (DMVs, wait stats, plan de requête), questions (impact client ?, fenêtre possible ?).

---

### Usage avec ticketops_hint

Si IT-TicketOpr a analysé le ticket et fourni un `ticketops_hint`, RouterIA l'utilise directement pour un routing instantané sans analyse manuelle.

**Exemple :**
```
ticketops_hint:
  router_intent: it.patching.dc.windows_updates_missing
  server_name: SRV-DC01
  risk: high
```

---

## Principe Discovery-first — Pourquoi c'est important

RouterIA applique la règle **Discovery-first** :

> Si le rôle du serveur n'est pas confirmé → exécuter `RUNBOOK__SERVER_ROLE_DISCOVERY.md` en premier.

**Pourquoi :** Appliquer le runbook de patching standard sur un DC, un SQL Server ou un RDS sans le savoir peut provoquer une panne. Le script de discovery s'exécute en lecture seule en 2 minutes et confirme le rôle avant toute action.

```
Ticket → RouterIA → Rôle non confirmé → DISCOVERY → role_profile → Route correcte
                 ↓
         Rôle confirmé → Route directe
```

---

## Niveaux de risque et gouvernance

| risk_level | Ce que RouterIA exige avant d'aller plus loin |
|---|---|
| `low` | Aucun prérequis particulier |
| `medium` | Confirmation du contexte client |
| `high` | maintenance_window + change_id/approval + backup confirmé |
| `critical` | Tout ce que `high` exige + escalade Commandare |

**Exemples de runbooks `high` :** DC patching, Hyper-V migration, SAN, Firewall reconfiguration, Exchange hybride.

---

## Format de sortie

RouterIA livre toujours du YAML structuré :

```yaml
result:
  route:
    intent_id: "it.patching.dc.windows_updates_missing"
    risk_level: high
    runbook_path: "IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__DC_PrePost_Validation.md"
    actor_id: IT-OPS-PlaybookRunner
  runbook_card:
    - "1. Precheck : réplication AD (repadmin /replsummary)"
    - "2. Precheck : confirmer nb DCs online"
    - "3. Patch via WSUS/RMM — 1 DC à la fois"
    - "4. Postcheck : DCDIAG + repadmin après chaque DC"
    - "5. Stop condition : si réplication KO → rollback + escalade"
  questions:
    - "Fenêtre de maintenance confirmée ?"
    - "Change_id approuvé ?"
    - "Backup DC récent (snapshot ou BMR) ?"
    - "Nombre de DCs dans le domaine ?"
    - "Méthode de patching : WSUS, SCCM ou RMM ?"
```

---

## Flux de travail complet

```
1. Ticket / alerte reçu
        ↓
2. Coller dans IT-OPS-RouterIA
        ↓
3a. Rôle non confirmé → Discovery script → Coller role_profile → Retour étape 2
3b. Route identifiée → Runbook card + Questions
        ↓
4. Répondre aux questions (fenêtre, change_id, backup, etc.)
        ↓
5. Passer à IT-OPS-PlaybookRunner avec la runbook_card
        ↓
6. IT-OPS-DossierIA archive le run
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| Ne jamais sauter le Discovery si le rôle n'est pas sûr | 2 min de script > 4h de rollback |
| Toujours répondre aux questions de gouvernance avant d'agir | risk_level: high = prérequis non négociables |
| RouterIA ne génère pas de runbooks — il les charge depuis l'index | Zéro invention de chemin ou de procédure |
| Si intent non reconnu → demander plus de contexte, jamais improviser | L'index couvre 87+ intents — si absent, proposer l'ajout |

---

## Questions fréquentes

**Q : Quelle différence entre RouterIA et IT-OPS-PlaybookRunner ?**
RouterIA identifie le bon runbook et pose les questions. PlaybookRunner exécute le runbook étape par étape.

**Q : Est-ce que je dois toujours passer par RouterIA ?**
Pour les incidents non classifiés, oui. Si tu sais déjà quel runbook utiliser et que le rôle est confirmé, tu peux aller directement à PlaybookRunner avec le bon runbook.

**Q : Qu'est-ce que MASTER_DISPATCH_INDEX_V2.yaml ?**
L'index central qui mappe chaque type de problème (intent) vers les ressources appropriées (runbook, template, script, checklist). 87+ intents couverts. Chargé au démarrage de la session.

**Q : Que se passe-t-il si RouterIA ne reconnaît pas l'intent ?**
Il demande plus de contexte et liste les informations manquantes. Il ne propose jamais un runbook inventé.

**Q : Comment ajouter un nouvel intent à l'index ?**
Via `/suggest-intent` dans IT-KnowledgeKeeper → IT-OPS-QAMaster → validation EA → MASTER_DISPATCH_INDEX_V2.yaml mis à jour.

---

*GUIDE_UTILISATION — IT-OPS-RouterIA v1.0 — MSP Intelligence AI — 2026-05-18*
