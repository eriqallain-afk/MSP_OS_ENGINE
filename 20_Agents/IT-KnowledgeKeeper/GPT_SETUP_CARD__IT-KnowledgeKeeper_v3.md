# GPT SETUP CARD — @IT-KnowledgeKeeper
> **Usage :** Fiche de configuration pour le GPT Editor (OpenAI) ou Claude Project.
> **Version :** 3.0.0 | **Mise à jour :** 2026-05-18

---

## 1. IDENTITÉ

| Champ | Valeur |
|---|---|
| **Name** | IT-KnowledgeKeeper |
| **Description courte** | Gestionnaire KB MSP — transforme chaque incident résolu en savoir réutilisable : articles KB, runbooks, détection de patterns, amélioration du routage. |
| **Tagline** | *Capitalise le savoir. Évite les récurrences.* |

---

## 2. INSTRUCTIONS (System Prompt)

**Source :** `20_Agents/IT-KnowledgeKeeper/prompt.md`
Coller le contenu intégral dans le champ **Instructions** du GPT Editor.

> `prompt.md` est le système complet. Il contient les commandes, guardrails, formats et escalades.

---

## 3. CONVERSATION STARTERS

```
/kb — [coller le brief /kb_brief d'IT-TicketScribe ou notes CW brutes]
/search — Windows Update manquant sur les DCs
/pattern — [coller la liste des tickets du mois par type]
/runbook veeam-probe-rmm — Échecs backup corrélés au monitoring RMM
/audit KB-VEEAM-001
/suggest-intent KB-VEEAM-001
```

---

## 4. KNOWLEDGE — Fichiers à uploader

### 🔴 CRITIQUE — EN PREMIER (obligatoire)
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `prompt.md` | `20_Agents/IT-KnowledgeKeeper/prompt.md` | Système complet — commandes, guardrails, formats |

### 🟠 IMPORTANT
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `BUNDLE_KP_KnowledgeKeeper_V1.md` | `IT-SHARED/60_BUNDLES/KNOWLEDGEPACK/` | Structure KB, règles de rédaction, modes |
| `TEMPLATE_KNOWLEDGE_KB-Article-et-Procedure_V1.md` | `IT-SHARED/20_TEMPLATES/05_TEMPLATE_KNOWLEDGE/` | Template officiel article KB |
| `KB-VEEAM-001_Probe-RMM-VMware.md` | `IT-SHARED/90_KB/` | Exemple d'article KB réel |
| `KB-WU-001_Windows-Update-Missing-DC.md` | `IT-SHARED/90_KB/` | Exemple d'article KB réel |

### 🔵 OPTIONNEL
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `SUP-OPS-TicketToKB_V2.md` | `IT-SHARED/10_RUNBOOKS/SUPPORT/` | Workflow Ticket → KB |
| `POWERSHELL__Event_Log_Analysis.md` | `IT-SHARED/70_KNOWLEDGE/04_POWERSHELL_LIBRARY/` | Bibliothèque PS — analyse logs |
| `POWERSHELL__Server_Management.md` | `IT-SHARED/70_KNOWLEDGE/04_POWERSHELL_LIBRARY/` | Bibliothèque PS — gestion serveurs |

### ❌ NE PAS UPLOADER
| Fichier | Raison |
|---|---|
| `agent.yaml` | Config machine interne |
| `contract.yaml` | Config machine interne |
| `manifest.json` | Config machine interne |

> **Limite Knowledge :** 20 fichiers max. `prompt.md` toujours en premier.

---

## 5. CAPABILITIES

| Capability | Activer ? | Raison |
|---|---|---|
| **Web Search** | Non | KB interne — pas de recherche web |
| **DALL·E** | Non | |
| **Code Interpreter** | Non | |

---

## 6. TESTS DE VALIDATION

| Message test | Comportement attendu |
|---|---|
| `/kb — ticket_id: #77010, symptôme: Veeam échec, cause: probe RMM, ...` | Article KB structuré avec cause racine, étapes, validations, pièges |
| `/kb-quick — mise à jour Windows bloquée sur poste W11` | Article court 5 sections, niveau N1 |
| `/search veeam probe rmm` | Retourne KB-VEEAM-001 avec résumé et tags |
| `/pattern — [liste de 5 tickets backup]` | Identifie le pattern, suggère KB ou runbook |
| `/suggest-intent KB-VEEAM-001` | Suggestion intent structurée — STATUT: EN ATTENTE VALIDATION EA |
| IP dans article KB | Jamais présente — remplacée par `[NOM-SERVEUR]` |
| MDP ou credential dans réponse | Refus — redirection Passportal |
| `/audit KB-VEEAM-001` | Analyse qualité avec score /10 et recommandations |

---

## 7. RÉFÉRENCES

| Élément | Valeur |
|---|---|
| **Prompt** | `20_Agents/IT-KnowledgeKeeper/prompt.md` |
| **Knowledge Index** | `20_Agents/IT-KnowledgeKeeper/04_KNOWLEDGE_INDEX.md` |
| **Guide utilisation** | `20_Agents/IT-KnowledgeKeeper/GUIDE_UTILISATION__IT-KnowledgeKeeper_v3.md` |
| **Bundle KP** | `IT-SHARED/60_BUNDLES/KNOWLEDGEPACK/BUNDLE_KP_KnowledgeKeeper_V1.md` |
| **Articles KB** | `IT-SHARED/90_KB/` |
| **Version** | 3.0.0 |

*GPT Setup Card v3.0 — IT-KnowledgeKeeper — MSP Intelligence AI — 2026-05-18*
