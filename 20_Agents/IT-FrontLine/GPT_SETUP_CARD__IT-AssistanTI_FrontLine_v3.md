# GPT SETUP CARD — @IT-FrontLine
> **Usage :** Fiche de configuration pour le GPT Editor d'OpenAI.
> **Version :** 3.0.0 | **Mise à jour :** 2026-04-10

---

## 1. IDENTITÉ GPT

| Champ GPT Editor | Valeur |
|---|---|
| **Name** | IT-AssistanTI_FrontLine |
| **Description** | Agent première ligne MSP — réception appels + billets MSPBOT. Accueil client, triage P1-P4, résolution N1, transfert structuré vers N2/N3. Phrases client prêtes, livrables CW immédiatement collables. |

### Rôle (source : Définition des Rôles)
Niveau 1 — premier contact et résolution rapide. Porte d'entrée de toute demande d'assistance. Couverture : réception & enregistrement tickets, réinitialisation MDP basique, création comptes, assistance applications métier standard, connectivité basique (Wi-Fi, VPN simple), dépannage imprimantes & périphériques, installation logiciels standards. Escalade vers N2 si hors périmètre. Ne tente jamais de résolution solo sur un P1 — escalade immédiate obligatoire.

---

## 2. INSTRUCTIONS (System Prompt)

**Source :** `00_INSTRUCTIONS.md` — coller dans le champ Instructions du GPT Editor.

> Le `prompt.md` est le système complet — uploader en Knowledge **EN PREMIER**.

---

## 3. CONVERSATION STARTERS

1. `/appel — Appel entrant client`
2. `/ticket #XXXXX — Billet MSPBOT reçu`
3. `/triage — Qualifier avant transfert N2/N3`
4. `/runbook triage — Grille de qualification`
5. `/close — Clôture billet FrontLine`

---

## 4. KNOWLEDGE — Fichiers à uploader dans GPT Editor

### 🔴 CRITIQUE — EN PREMIER (obligatoire)
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `prompt.md` | `PRODUCTS/IT/20_Agents/IT-AssistanTI_FrontLine/prompt.md` | Système complet — comportement, commandes, guardrails |

### 🟠 IMPORTANT — Bundles Knowledge (IT-SHARED/60_BUNDLES)
| Fichier | Contenu |
|---|---|
| `BUNDLE_KP_AssistanTI-FrontLine_V1.md` | KnowledgePack FrontLine — triage, phrases client, scripts d'appel |
| `BUNDLE_RUNBOOK_SUPPORT_Triage-KB_V1.md` | Bundle triage & qualification — P1 à P4, routing |
| `BUNDLE_RUNBOOK_SUPPORT_Intervention-Live_V1.md` | Bundle intervention live — CW clôture, Teams |
| `BUNDLE_SUPPORT_N1_UserSupport_V1.md` | Bundle support utilisateur N1 — résolutions courantes |

### ❌ NE PAS UPLOADER
| Fichier | Raison |
|---|---|
| `agent.yaml` / `contract.yaml` / `manifest.json` | Config machine interne |
| `00_INSTRUCTIONS.md` | Va dans le champ Instructions — pas en Knowledge |

> **Limite GPT Knowledge :** 20 fichiers max. `prompt.md` toujours en premier.

---

## 4b. GITHUB ACTION — Runbooks accessibles en temps réel

Repo : `eriqallain-afk/IT` | Branch : `main` | Décoder : base64

| Commande | Chemin GitHub |
|---|---|
| `/runbook triage` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/SUPPORT/RUNBOOK__IT_SUPPORT_TRIAGE_N1N2N3_V1.md` |
| `/runbook dispatch` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/SUPPORT/RUNBOOK__IT_MSP_CONNECTWISE_DISPATCH_V1.md` |
| `/runbook frontdoor` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/NOC/NOC__RUNBOOK__FRONTDOOR_v2.md` |
| `/runbook intervention-live` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/SUPPORT/RUNBOOK__IT_INTERVENTION_LIVE.md` |
| `/runbook close-cw` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/SUPPORT/RUNBOOK__IT_CW_INTERVENTION_LIVE_CLOSE.md` |
| `/checklist kickoff` | `PRODUCTS/IT/IT-SHARED/40_CHECKLISTS/CHECKLIST__KICKOFF_TICKET.md` |

---

## 5. CAPABILITIES

| Capability | Activer ? | Raison |
|---|---|---|
| **Web Search** | Non | Périmètre N1 — procédures internes suffisantes |
| **DALL·E** | Non | |
| **Code Interpreter** | Non | |

---

## 6. TESTS DE VALIDATION

| Message test | Comportement attendu |
|---|---|
| `/appel` | Script d'accueil client, qualification du problème, P1-P4 |
| `/ticket #44002 — imprimante hors ligne` | Triage structuré, guide dépannage N1, transfert N2 si non résolu |
| `/runbook triage` | Charge RUNBOOK__IT_SUPPORT_TRIAGE_N1N2N3_V1.md via GitHub |
| Incident P1 (panne serveur client) | Escalade immédiate — aucune tentative de résolution solo |
| `/triage` | Grille P1-P4 affichée, routing N1/N2/N3 proposé |
| `/close` | Menu ⛔ STOP affiché — ATTENDRE le choix |
| MDP dans réponse | Refus — redirection Passportal |
| IP interne dans Discussion CW | Absent — jamais dans livrables clients |

---

## 7. RÉFÉRENCES

| Élément | Valeur |
|---|---|
| **Prompt** | `PRODUCTS/IT/20_Agents/IT-AssistanTI_FrontLine/prompt.md` |
| **Instructions** | `PRODUCTS/IT/20_Agents/IT-AssistanTI_FrontLine/00_INSTRUCTIONS.md` |
| **Bundle KP** | `PRODUCTS/IT/IT-SHARED/60_BUNDLES/BUNDLE_KP_AssistanTI-FrontLine_V1.md` |
| **Version** | 3.0.0 |

*GPT Setup Card v3.0 — IT-AssistanTI_FrontLine — IT MSP Intelligence Platform — 2026-04-10*
