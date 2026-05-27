# HOW_TO_CREATE_GPT — Procédure de déploiement d'un agent

> **Applicable à :** GPT Editor (OpenAI) et Claude Projects (Anthropic)
> **Mis à jour :** 2026-05-18

---

## Documents requis par agent

Chaque agent du produit MSP Intelligence AI possède les documents suivants dans `20_Agents/[agent-id]/` :

| Document | Usage | Obligatoire |
|---|---|---|
| `prompt.md` | System prompt complet — coller dans Instructions | ✅ |
| `agent.yaml` | Config machine — NE PAS uploader en Knowledge | — |
| `contract.yaml` | Schéma inputs/outputs — NE PAS uploader | — |
| `GPT_SETUP_CARD__[agent-id]_v[N].md` | Fiche de configuration GPT — guide pas à pas | ✅ |
| `GUIDE_UTILISATION__[agent-id]_v[N].md` | Guide technicien — exemples, cas d'usage, flux | ✅ |
| `04_KNOWLEDGE_INDEX.md` | Index des fichiers Knowledge à uploader | ✅ |

---

## Procédure — GPT Editor (OpenAI)

### Étape 1 — Lire la Setup Card
Ouvrir `GPT_SETUP_CARD__[agent-id]_v[N].md`.
Elle contient : Identité, starters, liste Knowledge, Capabilities, tests de validation.

### Étape 2 — Créer le GPT
1. Aller dans [ChatGPT → Explore GPTs → Create](https://chat.openai.com/gpts/editor)
2. Basculer en mode **Configure** (onglet en haut)

### Étape 3 — Remplir l'identité
| Champ GPT Editor | Source |
|---|---|
| **Name** | Section 1 de la Setup Card |
| **Description** | Section 1 de la Setup Card |
| **Instructions** | Contenu intégral de `prompt.md` |
| **Conversation Starters** | Section 3 de la Setup Card |

### Étape 4 — Uploader le Knowledge
1. Télécharger les fichiers listés dans la section 4 (🔴 CRITIQUE en premier)
2. Uploader dans l'ordre : `prompt.md` → bundles → templates → exemples
3. Limite : 20 fichiers max
4. Ne jamais uploader : `agent.yaml`, `contract.yaml`, `manifest.json`

### Étape 5 — Activer les Capabilities
Selon la section 5 de la Setup Card. La plupart des agents n'ont PAS Web Search.
Exception : IT-Assistant-N3 et IT-SecurityMaster ont Web Search activé.

### Étape 6 — Tester
Exécuter chaque test de la section 6 de la Setup Card.
Un agent est prêt seulement quand **tous les tests passent**.

### Étape 7 — Publier
- Garder une version **"dev"** (non publiée) pour itérer
- Publier seulement quand les tests de validation sont tous verts
- Accès : "Only me" (usage interne MSP) ou "Anyone with the link" si partagé avec équipe

---

## Procédure — Claude Project (Anthropic)

### Étape 1 — Créer un Project
1. Aller dans [claude.ai → Projects → New Project](https://claude.ai/projects)
2. Nommer le project : `@IT-[NomAgent]`

### Étape 2 — Configurer les Instructions
Dans **Project Instructions**, coller le contenu intégral de `prompt.md`.

### Étape 3 — Uploader les fichiers Knowledge
Uploader les fichiers listés dans la section 4 de la Setup Card.
Claude Projects supporte jusqu'à 20 fichiers (200 000 tokens max).

### Étape 4 — Tester
Même tests que GPT Editor (section 6 de la Setup Card).

---

## Règles de déploiement

| Règle | Raison |
|---|---|
| `auto_activation: false` toujours | Validation EA obligatoire avant tout déploiement |
| Lire la Setup Card en entier avant de commencer | Éviter les oublis (Capabilities, Knowledge manquant) |
| Ne jamais déployer depuis `99_STAGING/` sans validation EA | Zone de staging = non validé |
| Incrémenter la version dans `agent.yaml` après chaque mise à jour | Traçabilité |
| Vérifier `00_INDEX/DOC_SYNC_MATRIX.md` après déploiement | Maintenir les index à jour |

---

## Agents disponibles et leurs Setup Cards

| Agent | Domaine | Setup Card |
|---|---|---|
| `IT-OPS-RouterIA` | Routage intents | — |
| `IT-OPS-PlaybookRunner` | Exécution playbooks | — |
| `IT-OPS-DossierIA` | Archivage et traçabilité | — |
| `IT-OPS-QAMaster` | Qualité plateforme | — |
| `IT-FrontLine` | Support N1, triage | `GPT_SETUP_CARD__IT-AssistanTI_FrontLine_v3.md` |
| `IT-Assistant-N2` | Support N2 | `GPT_SETUP_CARD__IT-AssistanTI_N2_v3.md` |
| `IT-Assistant-N3` | Support N3, architecture | `GPT_SETUP_CARD__IT-AssistanTI_N3_v3.md` |
| `IT-SysAdmin` | Administration systèmes | `GPT_SETUP_CARD__IT-SysAdmin_v3.md` |
| `IT-MaintenanceMaster` | Maintenance, patching | `GPT_SETUP_CARD__IT-MaintenanceMaster_v3.md` |
| `IT-MonitoringMaster` | Supervision, RMM | `GPT_SETUP_CARD__IT-MonitoringMaster.md` |
| `IT-NetworkMaster` | Réseau, firewall, VPN | `GPT_SETUP_CARD__IT-NetworkMaster.md` |
| `IT-SecurityMaster` | Sécurité, SOC, EDR | `GPT_SETUP_CARD__IT-SecurityMaster.md` |
| `IT-BackupDRMaster` | Backup et DR | `GPT_SETUP_CARD__IT-BackupDRMaster_v3.md` |
| `IT-CloudMaster` | Cloud, M365, Azure | `GPT_SETUP_CARD__IT-CloudMaster.md` |
| `IT-VoIPMaster` | Téléphonie VoIP | `GPT_SETUP_CARD__IT-VoIPMaster.md` |
| `IT-AssetMaster` | CMDB, actifs | `GPT_SETUP_CARD__IT-AssetMaster_v3.md` |
| `IT-ScriptMaster` | Scripts PowerShell/Bash | `GPT_SETUP_CARD__IT-ScriptMaster.md` |
| `IT-TicketOpr` | Triage et traitement tickets | `GPT_SETUP_CARD__IT-TicketOpr.md` |
| `IT-TicketScribe` | Rédaction CW, emails | `GPT_SETUP_CARD__IT-TicketScribe.md` |
| `IT-NOCDispatcher` | Dispatch NOC, escalades | `GPT_SETUP_CARD__IT-NOCDispatcher.md` |
| `IT-UrgenceMaster` | Urgences P1/P2 | `GPT_SETUP_CARD__IT-UrgenceMaster.md` |
| `IT-Commandare-NOC` | Commandement NOC | `GPT_SETUP_CARD__IT-Commandare-NOC.md` |
| `IT-Commandare-TECH` | Commandement technique | `GPT_SETUP_CARD__IT-Commandare-TECH.md` |
| `IT-Commandare-Infra` | Commandement infrastructure | `GPT_SETUP_CARD__IT-Commandare-Infra.md` |
| `IT-Commandare-OPR` | Commandement opérations | `GPT_SETUP_CARD__IT-Commandare-OPR.md` |
| `IT-OnOffBoarder` | Onboarding/Offboarding | — à créer |
| `IT-ComplianceMaster` | Conformité réglementaire | — à créer |
| `IT-ClientDocMaster` | Documentation client Hudu | `GPT_SETUP_CARD__IT-ClientDocMaster_v3.md` |
| `IT-ReportMaster` | Rapports et KPIs | `GPT_SETUP_CARD__IT-ReportMaster.md` |
| `IT-KnowledgeKeeper` | Base de connaissances KB | `GPT_SETUP_CARD__IT-KnowledgeKeeper_v3.md` |
| `IT-SysAdmin` | Sysadmin généraliste | `GPT_SETUP_CARD__IT-SysAdmin_v3.md` |

---

## Structure standard d'une Setup Card

Toute Setup Card doit contenir ces 7 sections :

```
## 1. IDENTITÉ          — Name, Description, Tagline
## 2. INSTRUCTIONS      — Source du prompt.md
## 3. CONVERSATION STARTERS  — 5-6 exemples réels
## 4. KNOWLEDGE         — 🔴 CRITIQUE / 🟠 IMPORTANT / 🔵 OPTIONNEL / ❌ NE PAS UPLOADER
## 5. CAPABILITIES      — Web Search, DALL·E, Code Interpreter
## 6. TESTS DE VALIDATION  — Message test → Comportement attendu
## 7. RÉFÉRENCES        — Chemins repo, version
```

---

## Structure standard d'un Guide d'utilisation

Chaque agent doit avoir un `GUIDE_UTILISATION__[agent-id]_v[N].md` contenant :

```
## À quoi sert cet agent ?     — Positionnement (vs autres agents)
## Quand l'utiliser ?          — Déclencheurs concrets
## Les commandes principales   — Chaque commande avec exemple réel
## Flux de travail recommandé  — Séquence avant/après intervention
## Règles à retenir            — Guardrails en langage technicien
## Questions fréquentes        — FAQ opérationnelle
```

Modèle de référence : `20_Agents/IT-KnowledgeKeeper/GUIDE_UTILISATION__IT-KnowledgeKeeper_v3.md`

---

*HOW_TO_CREATE_GPT v2.0 — MSP Intelligence AI — 2026-05-18*
