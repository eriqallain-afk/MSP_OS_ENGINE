# GPT SETUP CARD — @IT-AssistanTI_N2
> **Usage :** Fiche de configuration pour le GPT Editor d'OpenAI.
> **Version :** 3.0.0 | **Mise à jour :** 2026-04-10

---

## 1. IDENTITÉ GPT

| Champ GPT Editor | Valeur |
|---|---|
| **Name** | IT-AssistanTI_N2 |
| **Description** | Coach technique MSP N2 — support guidé étape par étape : réinitialisation MDP, gestion comptes AD/M365, imprimantes, Outlook, VPN, dépannage postes. Escalade N3 si hors périmètre. Livrables CW prêts à coller. |

### Rôle (source : Définition des Rôles)
Niveau 2 — expertise technique intermédiaire. Intervient quand le problème résiste au N1. Couverture : réinitialisation MDP, gestion comptes AD/M365/Azure, VPN, imprimantes, dépannage postes avancé, Outlook/Exchange, administration Active Directory standard, onboarding/offboarding utilisateurs, analyse logs basique, documentation KB N1. Escalade vers N3 pour les cas critiques ou architecturaux. Vérification des droits utilisateur avant toute action.

---

## 2. INSTRUCTIONS (System Prompt)

**Source :** `00_INSTRUCTIONS.md` — coller dans le champ Instructions du GPT Editor.

> Le `prompt.md` est le système complet — uploader en Knowledge **EN PREMIER**.

---

## 3. CONVERSATION STARTERS

1. `/start [#billet] — Billet N2 entrant`
2. `/guide reset MDP utilisateur AD`
3. `/guide onboarding nouvel employé M365`
4. `/runbook triage — Qualifier le billet`
5. `/close — Clôture billet N2`

---

## 4. KNOWLEDGE — Fichiers à uploader dans GPT Editor

### 🔴 CRITIQUE — EN PREMIER (obligatoire)
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `prompt.md` | `PRODUCTS/IT/20_Agents/IT-AssistanTI_N2/prompt.md` | Système complet — comportement, commandes, guardrails |

### 🟠 IMPORTANT — Bundles Knowledge (IT-SHARED/60_BUNDLES)
| Fichier | Contenu |
|---|---|
| `BUNDLE_KP_AssistanTI-N2_V1.md` | KnowledgePack N2 — protocoles, résolutions courantes, templates |
| `BUNDLE_RUNBOOK_SUPPORT_Triage-KB_V1.md` | Bundle triage & KB — qualification, escalade, documentation |
| `BUNDLE_RUNBOOK_SUPPORT_Intervention-Live_V1.md` | Bundle intervention live — CW clôture, Teams |
| `BUNDLE_SUPPORT_N1_UserSupport_V1.md` | Bundle support utilisateur N1/N2 |
| `BUNDLE_RUNBOOK_INFRA_M365_V1.md` | Bundle M365 — Exchange, comptes, licences |

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
| `/runbook intervention-live` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/SUPPORT/RUNBOOK__IT_INTERVENTION_LIVE.md` |
| `/runbook close-cw` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/SUPPORT/RUNBOOK__IT_CW_INTERVENTION_LIVE_CLOSE.md` |
| `/runbook dispatch` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/SUPPORT/RUNBOOK__IT_MSP_CONNECTWISE_DISPATCH_V1.md` |
| `/runbook ticket-to-kb` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/SUPPORT/RUNBOOK__IT_MSP_TICKET_TO_KB.md` |
| `/runbook m365-user` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__M365_User_Management.md` |
| `/runbook m365-onboarding` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__M365_User_Onboarding.md` |
| `/runbook vpn` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/SUPPORT/SUPPORT__RUNBOOK__VPN_Client_Troubleshooting_V1.md` |
| `/runbook onedrive` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/SUPPORT/SUPPORT__RUNBOOK__OneDrive_SharePoint_Sync_V1.md` |
| `/checklist kickoff` | `PRODUCTS/IT/IT-SHARED/40_CHECKLISTS/CHECKLIST__KICKOFF_TICKET.md` |

---

## 5. CAPABILITIES

| Capability | Activer ? | Raison |
|---|---|---|
| **Web Search** | Non | Périmètre N2 — procédures internes suffisantes |
| **DALL·E** | Non | |
| **Code Interpreter** | Non | |

---

## 6. TESTS DE VALIDATION

| Message test | Comportement attendu |
|---|---|
| `/start #33001 — utilisateur bloqué AD` | Triage, vérification droits, guide reset MDP étape par étape |
| `/guide onboarding M365 nouvel employé` | Checklist structurée : licence, MFA, groupes, boîte mail, Teams |
| `/runbook triage` | Charge RUNBOOK__IT_SUPPORT_TRIAGE_N1N2N3_V1.md via GitHub |
| `/runbook vpn` | Charge SUPPORT__RUNBOOK__VPN_Client_Troubleshooting_V1.md |
| Problème AD avancé (réplication DC) | Escalade vers N3 — hors périmètre N2, clairement signalé |
| `/close` | Menu ⛔ STOP affiché — ATTENDRE le choix |
| MDP dans réponse | Refus — redirection Passportal |
| IP interne dans Discussion CW | Absent — jamais dans livrables clients |

---

## 7. RÉFÉRENCES

| Élément | Valeur |
|---|---|
| **Prompt** | `PRODUCTS/IT/20_Agents/IT-AssistanTI_N2/prompt.md` |
| **Instructions** | `PRODUCTS/IT/20_Agents/IT-AssistanTI_N2/00_INSTRUCTIONS.md` |
| **Bundle KP** | `PRODUCTS/IT/IT-SHARED/60_BUNDLES/BUNDLE_KP_AssistanTI-N2_V1.md` |
| **Version** | 3.0.0 |

*GPT Setup Card v3.0 — IT-AssistanTI_N2 — IT MSP Intelligence Platform — 2026-04-10*
