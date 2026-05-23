# GPT SETUP CARD — @IT-CloudMaster
> **Usage :** Fiche de configuration pour le GPT Editor d'OpenAI.
> **Version :** 2.2.0 | **Mise à jour :** 2026-04-03

---

## 1. IDENTITÉ GPT

| Champ GPT Editor | Valeur |
|---|---|
| **Name** | IT-CloudMaster |
| **Description** | Expert Cloud/M365 MSP — Exchange Online, Entra ID, Teams, SharePoint, Intune, Azure, Keepit. Diagnostic et administration cloud. |

---

## 2. INSTRUCTIONS (System Prompt)

**Source :** `00_INSTRUCTIONS.md` — coller dans le champ Instructions

> Le `prompt.md` est le système complet — uploader en Knowledge **EN PREMIER**.

---

## 3. CONVERSATION STARTERS

1. `MODE=EXCHANGE_TRIAGE — [symptôme messagerie]`
2. `MODE=ENTRAID_TRIAGE — [compte bloqué / MFA]`
3. `MODE=INTUNE — Conformité appareil [NOM]`
4. `Keepit déconnecté — tenant [NOM]`

---

## 4. KNOWLEDGE — Fichiers à uploader

### 🔴 CRITIQUE (EN PREMIER — obligatoire)
| Fichier | Contenu |
|---|---|
| `prompt.md` | Système complet — commandes, modes, templates, guardrails |

### 🟠 IMPORTANT (si disponible dans IT-SHARED/60_BUNDLES/)
| Fichier | Contenu |
|---|---|
| `BUNDLE_KP_IT-CloudMaster_V1.md` | KnowledgePack — protocoles, templates, exemples |

### ❌ NE PAS UPLOADER
| Fichier | Raison |
|---|---|
| `agent.yaml` | Config machine interne |
| `contract.yaml` | Config machine interne |
| `manifest.json` | Config machine interne |
| `00_INSTRUCTIONS.md` | Va dans le champ Instructions — pas en Knowledge |

> **Limite GPT Knowledge :** 20 fichiers max. `prompt.md` toujours en premier.

---

## 5. CAPABILITIES

| Capability | Activer ? | Raison |
|---|---|---|
| **Web Search** | Non |  |
| **DALL·E** | Non | |
| **Code Interpreter** | Non | |

---

## 6. TESTS DE VALIDATION

| Message test | Comportement attendu |
|---|---|
| Premier message test ci-dessus | Réponse structurée, mode correct |
| `/close` | Menu ⛔ STOP — attendre choix avant de générer |
| MDP dans réponse | Refus — redirection Passportal |
| IP dans Discussion CW | Jamais présente dans livrables clients |

---

## 7. RÉFÉRENCES

| Élément | Valeur |
|---|---|
| **Prompt** | `20_Agents/IT-CloudMaster/prompt.md` |
| **Instructions** | `20_Agents/IT-CloudMaster/00_INSTRUCTIONS.md` |
| **Version** | 2.2.0 |

*GPT Setup Card v2.2 — IT-CloudMaster — IT MSP Intelligence Platform — 2026-04-03*
