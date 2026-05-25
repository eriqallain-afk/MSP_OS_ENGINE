# ARCHITECTURE_DECISION_LOG
**Version :** 1.0 | **Date :** 2026-05-22 | **Statut :** ACTIF
**Propriétaire :** EA | **Accessible aux agents :** Oui — via getFileContent
**Chemin menu :** [pl5] arch-decisions

---

## OBJECTIF

Ce document enregistre les décisions d'architecture significatives du produit MSP Intelligence AI.

Chaque entrée explique **pourquoi** une décision a été prise, pas seulement **quoi**.
Les agents peuvent le charger pour comprendre les contraintes d'une convention avant de modifier quoi que ce soit.

> Avant de modifier une convention, charger ce document et vérifier si une ADR existante s'applique.

---

## FORMAT D'UNE ENTRÉE

```
ADR-XXX | Date | Statut : ACTIF / REMPLACÉ / DÉPRÉCIÉ
Titre
Contexte : [pourquoi cette décision était nécessaire]
Décision : [ce qui a été choisi]
Raison : [pourquoi cette option plutôt qu'une autre]
Conséquences : [ce que ça implique dans le repo et les agents]
Remplacé par : [ADR-YYY si applicable]
```

---

## ADR-001 | 2026-04-01 | ACTIF
### Séparation IT-SHARED / 20_Agents / playbooks

**Contexte :**
Au démarrage du produit, deux approches possibles : (A) chaque agent embarque ses propres runbooks, ou (B) les runbooks vivent dans un espace partagé que tous les agents consultent.

**Décision :**
Option B — séparation stricte en 3 responsabilités :
- `IT-SHARED/` = ressources opérationnelles communes (runbooks, templates, scripts, checklists)
- `20_Agents/` = définitions des agents (identité, instructions, contrat, knowledge)
- `playbooks/` = workflows d'orchestration multi-agents (YAML)

**Raison :**
Un runbook mis à jour bénéficie automatiquement à tous les agents qui le chargent. Pas de duplication, pas de drift de version entre agents. Un agent peut être modifié sans toucher au contenu opérationnel.

**Conséquences :**
- Tout nouveau runbook va dans `IT-SHARED/`, jamais dans `20_Agents/`
- Les agents référencent les runbooks par chemin GitHub (`getFileContent`) — jamais en copiant le contenu dans leurs instructions
- `playbooks/` reste distinct de `IT-SHARED/` — un playbook orchestre, un runbook documente

---

## ADR-002 | 2026-05-01 | ACTIF
### Out-String -Width 300 | Write-Output comme standard de sortie PowerShell

**Contexte :**
Ticket de production HV01 Shape WLB #1757381 — les outputs `Format-List` et `Format-Table` sont perdus dans les consoles RMM (N-able, CW Automate, ScreenConnect). Les objets PowerShell sont sérialisés différemment selon le pipeline d'exécution du RMM. Les techniciens voient une sortie vide ou tronquée.

**Décision :**
Tout script PowerShell destiné à être exécuté via RMM utilise obligatoirement :
```powershell
| Out-String -Width 300 | Write-Output
```
en remplacement de `| Format-List`, `| Format-Table`, `| Format-Table -AutoSize`.

**Raison :**
`Out-String` force la conversion en chaîne de caractères avant que le RMM capture la sortie. `Write-Output` garantit que la chaîne passe dans le pipeline stdout standard. C'est le seul pattern confirmé fonctionnel sur N-able, CW Automate et ScreenConnect.

**Conséquences :**
- Tous les runbooks existants ont été migrés (vague 2026-05)
- Chaque nouveau script doit inclure en en-tête : `# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)`
- `Format-List` et `Format-Table` sont interdits dans les scripts RMM
- Exception : scripts exécutés directement en console PowerShell locale (hors RMM) — peuvent utiliser Format-*

---

## ADR-003 | 2026-05-01 | ACTIF
### Scripts PRECHECK et POSTCHECK unifiés — un seul bloc par phase

**Contexte :**
Les runbooks initiaux listaient des étapes sous forme de bullet points avec des commandes séparées. En pratique, les techniciens devaient copier-coller 5-8 commandes individuellement dans leur RMM, dans l'ordre, et assembler mentalement les résultats. Source d'erreurs et de perte de temps.

**Décision :**
Chaque runbook a un seul script PRECHECK et un seul script POSTCHECK — blocs PowerShell complets, couvrant toutes les vérifications de la phase en un seul exécutable.

**Raison :**
Un technicien copie-colle une fois, exécute une fois, voit le résultat complet. La logique d'analyse reste dans le script (sections délimitées par `Write-Output "=== SECTION ==="`). Le résultat est structuré et peut être copié tel quel dans la note CW.

**Conséquences :**
- Runbooks migrés vers ce standard : HyperV_V2, SQL_V2, PrintServer_V1, PendingReboot_V2
- Tout nouveau runbook d'infrastructure doit suivre ce pattern
- Les bullet points "à exécuter manuellement" sont interdits dans les sections PRECHECK/POSTCHECK

---

## ADR-004 | 2026-05-10 | ACTIF
### Architecture 2-phases pour MAINT-WIN-PendingReboot

**Contexte :**
Le runbook PendingReboot initial supposait qu'on connaissait le rôle du serveur avant d'intervenir. En production, les techniciens arrivent souvent sur un serveur dont le rôle est inconnu (RMM alerte générique). De plus, un serveur peut cumuler plusieurs rôles (ex: Hyper-V + Veeam simultanément).

**Décision :**
MAINT-WIN-PendingReboot restructuré en 2 phases :
- **Phase 1** : script universel (tous serveurs) — HOST/OS/Uptime/CPU/RAM/Disques/Rôles/Sessions/Services — se termine par une `$routingMap` qui indique quel(s) runbook(s) consulter selon les rôles détectés
- **Phase 2** : routing vers le runbook spécifique au rôle (DC, Hyper-V, SQL, RDS, Print, Veeam)

**Raison :**
Un seul point d'entrée universel, puis routing selon la réalité du serveur. Un serveur multi-rôles reçoit plusieurs entrées dans la routing map — le technicien consulte chaque runbook concerné dans l'ordre.

**Conséquences :**
- La `$routingMap` est la pièce centrale — elle doit être maintenue à jour si de nouveaux rôles sont ajoutés
- Les runbooks de Phase 2 (DC, HyperV, SQL...) sont chargés via getFileContent — ils ne sont pas dupliqués dans PendingReboot
- Le script Phase 1 inclut maintenant CPU (cores + load%) — manquait dans la version originale

---

## ADR-005 | 2026-05-10 | ACTIF
### LastBoot et Uptime obligatoires dans tout PRECHECK et POSTCHECK

**Contexte :**
Les notes CW post-intervention ne documentaient pas systématiquement le LastBoot avant et après. Sans ces données, impossible de prouver qu'un reboot a eu lieu, ni de calculer le temps de mise en service.

**Décision :**
Tout script PRECHECK et POSTCHECK doit inclure LastBoot et Uptime comme premières valeurs de sortie. Obligatoires dans la note CW.

**Raison :**
Traçabilité et preuve de service. Requis pour les SLA et pour les discussions avec le client si un problème survient post-intervention.

**Conséquences :**
- Tous les scripts de precheck/postcheck incluent `$os.LastBootUpTime` et calcul d'Uptime en heures
- La note CW doit toujours mentionner `LastBoot post-intervention : [valeur]`

---

## ADR-006 | 2026-05-15 | ACTIF
### Contenu script toujours inline — jamais un chemin de fichier

**Contexte :**
Plusieurs agents répondaient aux techniciens en donnant le chemin d'un script (`Exécutez SCRIPT_PRECHECK_DC_V3.ps1`) plutôt que le contenu. Le technicien devait ouvrir GitHub, copier le script, puis le coller dans son RMM — 3 étapes supplémentaires, sources d'erreurs de version.

**Décision :**
Quand un technicien demande un script à exécuter, l'agent sort le contenu PowerShell complet inline dans la réponse. Jamais un chemin, jamais un nom de fichier.

**Raison :**
Le technicien copie-colle directement dans son runner RMM (N-able, CW Automate, ScreenConnect) sans ouvrir aucun autre fichier. Réduit le risque d'erreur et le temps d'exécution.

**Conséquences :**
- Règle ajoutée dans les instructions de 5 agents : IT-SysAdmin, IT-MaintenanceMaster, IT-BackupDRMaster, IT-Assistant-N3, IT-TechOPS
- Les scripts GitHub restent la source de vérité — l'agent les charge via getFileContent puis les sort inline
- Pas de dépendance au runtime sur les fichiers GitHub

---

## ADR-007 | 2026-05-15 | ACTIF
### "Raison de l'étape suivante" obligatoire après chaque résultat

**Contexte :**
Les agents produisaient des suites d'étapes sans expliquer pourquoi le résultat de l'étape précédente menait à l'étape suivante. Le technicien exécutait sans comprendre — si un résultat était inattendu, il ne savait pas s'il fallait continuer ou s'arrêter.

**Décision :**
Après chaque résultat de diagnostic ou d'action, l'agent doit expliquer :
- ce qui a été éliminé ou confirmé
- pourquoi ça mène à l'étape suivante
Format obligatoire : `→ Décision suivante : [raison]`

**Raison :**
Forme des techniciens à raisonner plutôt qu'à exécuter mécaniquement. Permet au technicien de s'arrêter intelligemment si le résultat est inattendu.

**Conséquences :**
- Règle ajoutée dans les instructions de tous les agents opérationnels
- Les templates TEMPLATE_INTERVENTION_Standard_V1 et TEMPLATE_INTERVENTION_Compact_V1 structurent ce raisonnement pour les livrables CW

---

## ADR-008 | 2026-05-21 | ACTIF
### Framework de prompting en 4 couches (Output Policy)

**Contexte :**
Les agents produisaient des réponses de format variable selon le contexte. Un même agent pouvait répondre en prose libre pour un diagnostic, puis en liste pour un script, puis en markdown pour une note CW — rendant les livrables non standardisés.

**Décision :**
Adoption du framework 4 couches défini dans `PROMPT_FRAMEWORK_MSP_Intelligence_V1.md` :
1. Rôle de l'agent (identité, périmètre, autonomie)
2. Mode opératoire (lecture seule, 1 action, sources, raison étape)
3. Output Policy — 6 modes fixes : Diagnostic / Script / CW Note / Discussion client / Escalade / Fermeture
4. Gabarits de prompts par intent/domaine

**Raison :**
Des réponses contractuelles — prévisibles, réutilisables, copiables directement dans CW — plutôt que des réponses libres qui varient selon l'humeur du modèle ou du contexte.

**Conséquences :**
- `PROMPT_FRAMEWORK_MSP_Intelligence_V1.md` est la référence normative pour tout nouveau agent
- Chaque agent doit référencer les modes de réponse dans ses instructions
- Les nouveaux agents en staging (`99_STAGING/`) doivent être validés contre ce framework avant activation

---

## ADR-009 | 2026-05-22 | ACTIF
### Runbooks WKS dans SUPPORT/WKS/ — sous-dossier dédié

**Contexte :**
Les runbooks de support N2/FrontLine pour les postes de travail pouvaient aller dans `SUPPORT/` directement (comme les autres runbooks SUPPORT) ou dans un sous-dossier `WKS/`.

**Décision :**
Sous-dossier `IT-SHARED/10_RUNBOOKS/SUPPORT/WKS/` avec convention de nommage `SUP-WKS-{Sujet}_V1.md`.

**Raison :**
Le volume de runbooks WKS (11 au lancement) justifie l'isolation. La convention `SUP-WKS-` permet de filtrer rapidement les runbooks poste de travail vs les runbooks de support opérationnel (CW, dispatch, triage). Les agents IT-FrontLine et IT-Assistant-N2 ont un périmètre clair.

**Conséquences :**
- Menu [52a]-[52k] dans RUNBOOK_MENU_CONTEXTUEL_V4.md
- 11 intents `it.wks.*` dans INTENT_RUNBOOK_MATRIX_V1.md
- Futurs runbooks WKS suivent la même convention et le même dossier

---

## ADR-010 | 2026-05-22 | ACTIF
### Mise à jour INTENT_RUNBOOK_MATRIX et INDEX obligatoire à chaque ajout de runbook

**Contexte :**
La procédure `PROC__RUNBOOK_Ajout_MAJ_Index_Intents_V1` demande de mettre à jour les fichiers d'index après chaque ajout de runbook. La raison n'était pas explicitement documentée.

**Décision :**
La mise à jour de `INTENT_RUNBOOK_MATRIX_V1.md` et des fichiers d'index est **fonctionnelle, pas documentaire** — elle est obligatoire et bloquante.

**Raison :**
C'est le **RouterIA** (`IT-OPS-RouterIA`) qui apporte les runbooks aux agents — il ne les charge pas lui-même. Le RouterIA détecte l'intent entrant, résout le chemin du runbook via `INTENT_RUNBOOK_MATRIX_V1.md` et `MASTER_DISPATCH_INDEX_V2.yaml`, puis apporte le contenu à l'agent métier avant que celui-ci réponde.

Si un runbook n'est pas enregistré dans la matrix → le RouterIA ne le trouve pas → l'agent ne reçoit jamais le runbook → le runbook n'existe pas opérationnellement, même s'il est dans le repo.

**Conséquences :**
- Ajouter un runbook sans mettre à jour la matrix = runbook mort (inaccessible via RouterIA)
- L'ordre de création est : 1. Runbook → 2. Matrix → 3. Menu → 4. Index
- Les mises à jour de menu (`RUNBOOK_MENU_CONTEXTUEL_V4.md`) permettent aux agents de charger manuellement via `/runbook`, mais c'est un fallback — le RouterIA reste le chemin principal
- La procédure `PROC__RUNBOOK_Ajout_MAJ_Index_Intents_V1` est donc une procédure **de mise en service**, pas de documentation

---

## ADR-011 | 2026-05-23 | ACTIF
### Architecture de tiering produit — double axe commercial + compétence + Commandare fusion

**Contexte :**
Avec 33 agents et l'ajout des agents compliance/audit, la question du regroupement pour le lancement commercial devient critique. Deux problèmes simultanés : (1) comment packager les agents par niveau de forfait, (2) comment empêcher un tech junior de se lancer dans des interventions qu'il ne maîtrise pas même s'il a accès à l'agent.

**Décision :**
Architecture à deux axes indépendants :

**Axe 1 — Commercial (ce que le MSP paie) :**
```
Starter     → Agents support quotidien — granulaires, scope limité
Pro         → Support technique complet N2→N3
MSP         → Routing automatique + NOC + rapports clients
Enterprise  → Commandare fusion + compliance/audit + Claude API
```

**Axe 2 — Compétence (ce que le tech est qualifié pour faire) :**
```
N1/FrontLine  → FrontLine, TicketOpsAI, TicketScribe
N2            → + Assistant-N2
N3/Technique  → + Assistant-N3, TechOPS, SysAdmin, MaintenanceMaster...
Architecte    → Commandare agents (vision cross-domaine)
```

**Regroupement agents par forfait :**

| Forfait | Agents inclus | Principe |
|---|---|---|
| Starter | FrontLine, Assistant-N2, TicketOpsAI, TicketScribe | Tickets quotidiens — routing manuel |
| Pro | + Assistant-N3, SysAdmin, TechOPS, MaintenanceMaster, BackupDRMaster, NetworkMaster | Support technique complet |
| MSP | + RouterIA (routing auto), NOCDispatcher, MonitoringMaster, CloudMaster, UrgenceMaster, OnOffBoarder, ReportMaster, AssetMaster, ClientDocMaster | Automatisation + NOC + livrables clients |
| Enterprise | + Commandare-Infra, Commandare-NOC, Commandare-TECH, Commandare-OPR, Commandare-Compliance (nouveau), ComplianceMaster, SecurityMaster, ScriptMaster | Fusion cross-domaine + compliance + Claude API optionnel |

**Vision Commandare fusion (Enterprise) :**

Les Commandare deviennent des agents de synthèse cross-domaine — non pas une concaténation de prompts, mais des agents avec une identité propre (architecte senior) qui chargent dynamiquement les runbooks de leurs domaines via `getFileContent`.

| Commandare | Couvre les domaines de |
|---|---|
| Commandare-Infra | SysAdmin + CloudMaster + NetworkMaster + VoIPMaster |
| Commandare-NOC | MaintenanceMaster + BackupDRMaster + MonitoringMaster + NOCDispatcher + UrgenceMaster |
| Commandare-TECH | FrontLine + N2 + N3 + TechOPS + ScriptMaster |
| Commandare-OPR | ReportMaster + AssetMaster + ClientDocMaster + KnowledgeKeeper + OnOffBoarder + TicketScribe |
| Commandare-Compliance *(à créer)* | ComplianceMaster + SecurityMaster + ReportMaster |

**OPS (RouterIA, PlaybookRunner, DossierIA, QAMaster, SyncFactory) = infrastructure plateforme — jamais exposés directement aux techniciens.**

**Protection compétence — 3 couches :**
1. **Accès** : le MSP partage seulement les GPTs du niveau du tech — un N2 ne voit jamais Commandare-Infra
2. **Déclaration `/start`** : chaque agent évalue la compétence déclarée au démarrage et adapte ce qu'il guide
3. **Garde-fou agent** : les agents avancés détectent un profil junior et bloquent les actions hors compétence avec redirect vers chef d'équipe

**Raison :**
La granularité en bas protège naturellement par scope limité — un agent FrontLine ne peut pas guider une intervention serveur. La polyvalence en haut (Commandare) est réservée aux techs senior qui savent interpréter les résultats cross-domaine. Sans l'axe compétence, un junior avec accès Enterprise pourrait tenter des interventions destructives guidées par un Commandare qui ne sait pas qu'il parle à un N1.

**Conséquences :**
- Le tiering commercial et le tiering compétence sont orthogonaux — un grand MSP peut avoir des N1 (accès Starter) et des architectes (accès Enterprise) simultanément
- Les Commandare actuels (Infra, NOC, TECH, OPR) sont à refactorer en agents fusion lors de la phase Enterprise — pas avant
- Commandare-Compliance est un nouvel agent à créer (ComplianceMaster + SecurityMaster + ReportMaster)
- La contrainte ChatGPT (pas d'inter-agent natif) fait que la fusion est la solution pragmatique aux tiers inférieurs ; Claude API (Enterprise+) permet la vraie orchestration
- Chaque Commandare charge ses runbooks via `getFileContent` dynamiquement — la fusion est au niveau du raisonnement, pas de l'embarquement de contenu

---

## ADR-012 | 2026-05-23 | ACTIF
### Experts chevronnés — niveau Pro/MSP — conditionnel au test RouterIA

**Contexte :**
Le tiering Starter→Pro→MSP→Enterprise nécessite un niveau intermédiaire entre les spécialistes granulaires (Starter) et les futurs Commandare (Enterprise/Claude API). Les Commandare actuels ne fonctionnent pas bien en ChatGPT GPT sans vraie orchestration inter-agents. Il faut un niveau "Pro" qui donne de la puissance sans surcharger le prompt.

**Vision : 6 Experts chevronnés**

| Expert | Domaine | Agents absorbés |
|---|---|---|
| `IT-Expert-Support` | Support avancé N2→N3, tickets complexes | Assistant-N2, N3, FrontLine, TechOPS, ScriptMaster |
| `IT-Expert-Infra` | Serveurs, AD, HyperV, SQL, Azure, M365, réseau, cloud | SysAdmin, CloudMaster, NetworkMaster, VoIPMaster, ScriptMaster |
| `IT-Expert-NOC` | Maintenance, patching, backup/DR, monitoring | MaintenanceMaster, BackupDRMaster, MonitoringMaster, NOCDispatcher, UrgenceMaster, ScriptMaster |
| `IT-Expert-SOC` | Incidents sécurité, forensics, threat hunting, hardening | SecurityMaster, ScriptMaster |
| `IT-Expert-Compliance` | Audit 5 piliers, Entra, Purview, Loi 25, PCI, rapports | ComplianceMaster, ReportMaster |
| `IT-Expert-OPR` | Documentation, assets, knowledge, onboarding/offboarding | AssetMaster, ClientDocMaster, KnowledgeKeeper, OnOffBoarder, TicketScribe, ReportMaster |

ScriptMaster = compétence transversale aux 4 premiers experts — chaque Expert sort des scripts PowerShell inline sans agent séparé.

**Principe de conception :** l'Expert est **léger dans son prompt de base** — il ne charge pas tous les runbooks à l'avance. Il sait *quoi* charger via `getFileContent` selon le contexte. L'expertise est dans le raisonnement cross-domaine, pas dans la mémoire embarquée.

**Condition de déclenchement — VALIDATION ROUTERIA REQUISE AVANT CONSTRUCTION :**

Cette vision est conditionnelle au résultat des tests RouterIA en conditions réelles.

- Si RouterIA route bien → spécialistes légers suffisent, Experts chevronnés moins urgents
- Si RouterIA rate → Experts chevronnés deviennent la solution pragmatique immédiate

**Contexte test :** les tests RouterIA antérieurs au 2026-05-23 étaient sur une version sans les 11 runbooks WKS ni les 4 intents compliance (matrix incomplète). Les tests valides commencent après le merge PR #53 sur main (2026-05-22).

**Gamme produit cible :**
```
Starter     → Spécialistes granulaires (agents actuels)
Pro         → 1 Expert chevronné au choix (ou à la carte)
MSP         → Plusieurs Experts + RouterIA automatique
Enterprise  → Tous Experts + Commandare fusion (Claude API)
```

**Conséquences :**
- Construction des 6 Experts suspendue jusqu'aux résultats des tests RouterIA
- Si RouterIA validé → Pro = spécialistes + RouterIA, Experts optionnels
- Si RouterIA insuffisant → construire les 6 Experts en priorité
- Les Commandare actuels restent en staging — valeur réelle uniquement avec Claude API

---

## DÉCISIONS EN ATTENTE / À DOCUMENTER

| Sujet | Décision requise | Assigné à |
|---|---|---|
| Format des Knowledge Packs agents | Standardiser ou laisser flexible par agent ? | EA |
| Versioning des bundles | Quand bumper la version d'un bundle ? | EA |
| Archivage ADR | Après combien de temps une ADR REMPLACÉE peut-elle être archivée ? | EA |
| Commandare-Compliance | Créer l'agent — périmètre exact et prompt à définir | EA |
| Tiering compétence dans /start | Standardiser le bloc de déclaration compétence pour tous les agents | EA |
| **RouterIA test réel** | **Valider sur 5-10 cas (support, serveur, compliance, backup) — résultat détermine si Experts chevronnés sont prioritaires** | **EA — priorité lancement** |

---

*ARCHITECTURE_DECISION_LOG v1.0 — MSP Intelligence AI — 2026-05-22*
