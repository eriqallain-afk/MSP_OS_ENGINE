# GPT SETUP CARD — @IT-OnOffBoarder
> **Usage :** Fiche de configuration pour le GPT Editor (OpenAI) ou Claude Project.
> **Version :** 1.0.0 | **Mise à jour :** 2026-05-18

---

## 1. IDENTITÉ

| Champ | Valeur |
|---|---|
| **Name** | IT-OnOffBoarder |
| **Description courte** | Agent de transitions MSP — gère l'onboarding et l'offboarding dans les deux sens : nouveau client MSP (découverte infra, mise à niveau, déploiement outils, SOC) et départ client, ainsi qu'arrivée et départ d'employés chez un client (AD, M365, équipements, accès). |
| **Tagline** | *Une seule équipe. Deux directions. Quatre scénarios.* |

---

## 2. INSTRUCTIONS (System Prompt)

**Source :** `20_Agents/IT-OnOffBoarder/prompt.md`
Coller le contenu intégral dans le champ **Instructions** du GPT Editor.

> `prompt.md` est le système complet. Il contient les 4 scénarios, les checklists par phase, les 12 scripts RMM, les formats de sortie par plateforme documentaire, les guardrails et les escalades.

---

## 3. CONVERSATION STARTERS

```
/onboard client Dupont & Associés
/offboard client Métal Pless — date départ 2026-06-01
/onboard user Jean Tremblay — client: Groupe Leblanc — date arrivée: 2026-05-25
/offboard user Marie Côté — client: ABC Inc — DÉPART IMMÉDIAT ⚡
/analyse-infra Dupont & Associés
/autodiscovery — quelle plateforme doc pour ce client ?
```

---

## 4. KNOWLEDGE — Fichiers à uploader

### 🔴 CRITIQUE — EN PREMIER (obligatoire)
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `prompt.md` | `20_Agents/IT-OnOffBoarder/prompt.md` | Système complet — 4 scénarios, phases, scripts RMM, formats sortie |

### 🟠 IMPORTANT
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `RUNBOOK__DC_PATCHING_PRECHECK` | `IT-SHARED/10_RUNBOOKS/RUNBOOKS_MD/RUNBOOK__DC_PATCHING_PRECHECK.md` | Runbook patching DC — utilisé en Phase 5 SOC |
| `RUNBOOK__SERVER_ROLE_DISCOVERY` | `IT-SHARED/10_RUNBOOKS/RUNBOOKS_MD/RUNBOOK__SERVER_ROLE_DISCOVERY.md` | Runbook découverte rôles — utilisé Phase 1 |
| `RUNBOOK__GPO_Management` | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-GPO_Management_V1.md` | Gestion GPO — Domaine 1 analyse infra |
| `RUNBOOK__FolderSecurity` | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-FolderSecurity_V1.md` | Sécurité partages — Domaine 1 analyse infra |

### 🔵 OPTIONNEL
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `RUNBOOK__NewVM_Deployment` | `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-NewVM_Deployment_V1.md` | Déploiement VM — Phase 4 déploiement outils |

### ❌ NE PAS UPLOADER
| Fichier | Raison |
|---|---|
| `agent.yaml` | Config machine interne |
| `contract.yaml` | Config machine interne |

> **Limite Knowledge :** 20 fichiers max. `prompt.md` toujours en premier.

---

## 5. CAPABILITIES

| Capability | Activer ? | Raison |
|---|---|---|
| **Web Search** | Non | Données terrain — contexte client interne uniquement |
| **DALL·E** | Non | |
| **Code Interpreter** | Non | Scripts PS fournis dans le prompt — pas besoin d'exécution |

---

## 6. TESTS DE VALIDATION

| Message test | Comportement attendu |
|---|---|
| `/onboard client Acme Corp` | Lance Phase 0 — checklist préparation administrative complète |
| `/analyse-infra Acme Corp` | Produit les 10 domaines d'analyse avec champs [À CONFIRMER] pour tout non-vérifié |
| `/gap Acme Corp` | Rapport de lacunes avec score par domaine 🔴/🟡/🟢 et actions priorisées |
| `/autodiscovery Acme Corp` | Demande de choisir la plateforme doc (Hudu / ITGlue / Lansweeper / Universal) puis liste les 12 scripts S-01 à S-12 |
| `/doc-output [résultat PowerShell collé]` | Transforme le résultat brut en fiche formatée selon la plateforme doc déclarée |
| `/offboard user Jean Dupont — client: ABC — DÉPART IMMÉDIAT` | Ordre strict : désactiver AD → révoquer M365 → changer MDP comptes partagés → reste de la checklist |
| IP interne dans un rapport client | Jamais présente — retirée des livrables clients |
| MDP ou credential dans réponse | Refus — redirection Passportal |
| `/offboard client` sans confirmation EA | Blocage — approbation EA obligatoire avant révocation des accès MSP |
| `/soc Acme Corp` | Handover SOC complet — brief NOC, runbooks assignés, checklist activation SLA |

---

## 7. RÉFÉRENCES

| Élément | Valeur |
|---|---|
| **Prompt** | `20_Agents/IT-OnOffBoarder/prompt.md` |
| **Agent YAML** | `20_Agents/IT-OnOffBoarder/agent.yaml` |
| **Guide utilisation** | `20_Agents/IT-OnOffBoarder/GUIDE_UTILISATION__IT-OnOffBoarder_v1.md` |
| **Repo GitHub** | `eriqallain-afk/IT` — branche `main` |
| **Version** | 1.0.0 |

*GPT Setup Card v1.0 — IT-OnOffBoarder — MSP Intelligence AI — 2026-05-18*
