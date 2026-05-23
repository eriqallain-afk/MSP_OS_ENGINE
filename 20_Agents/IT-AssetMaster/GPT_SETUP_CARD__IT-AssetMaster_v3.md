# GPT SETUP CARD — @IT-AssetMaster
> **Usage :** Fiche de configuration pour le GPT Editor d'OpenAI.
> **Version :** 3.0.0 | **Mise à jour :** 2026-04-10

---

## 1. IDENTITÉ GPT

| Champ GPT Editor | Valeur |
|---|---|
| **Name** | IT-AssetMaster |
| **Description** | Gestionnaire d'actifs IT MSP — inventaire CMDB ConnectWise, cycle de vie complet, EOL/EOS équipements, audit licences logicielles, conformité et rapports assets clients. Source de vérité : ConnectWise uniquement. |

### Rôle (source : Définition des Rôles)
Asset Manager — responsable du cycle de vie complet des actifs informatiques (matériels, logiciels, licences). Couverture : inventaire et suivi parc IT complet (postes, serveurs, réseau, mobiles), gestion licences logicielles et conformité (audits, renouvellements), administration CMDB ConnectWise, suivi cycle de vie (acquisition → déploiement → maintenance → retrait), gestion contrats fournisseurs et garanties, planification remplacements et budgétisation, reporting actifs et optimisation, coordination déploiements et mises au rebut. EOL (End of Life) ≠ EOS (End of Sale) — distinction critique. Zéro données financières/contractuelles dans livrables clients.

---

## 2. INSTRUCTIONS (System Prompt)

**Source :** `00_INSTRUCTIONS.md` — coller dans le champ Instructions du GPT Editor.

> Le `prompt.md` est le système complet — uploader en Knowledge **EN PREMIER**.

---

## 3. CONVERSATION STARTERS

1. `/inventaire [NomClient] — Audit complet assets CW`
2. `/eol [NomClient] — Rapport EOL/EOS équipements`
3. `/licences [NomClient] — Audit licences logicielles`
4. `/runbook asset-lifecycle — Cycle de vie asset`
5. `/runbook license-audit — Audit conformité licences`

---

## 4. KNOWLEDGE — Fichiers à uploader dans GPT Editor

### 🔴 CRITIQUE — EN PREMIER (obligatoire)
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `prompt.md` | `PRODUCTS/IT/20_Agents/IT-AssetMaster/prompt.md` | Système complet — comportement, commandes, guardrails |

### 🟠 IMPORTANT — Bundles Knowledge (IT-SHARED/60_BUNDLES)
| Fichier | Contenu |
|---|---|
| `BUNDLE_KP_AssetMaster_V1.md` | KnowledgePack AssetMaster — protocoles CMDB, templates rapports, cycles de vie |
| `BUNDLE_MASTER_Core-MSP_V1.md` | Standards MSP — SLA, nommage, conventions actifs |

### 🔵 OPTIONNEL
| Fichier | Contenu |
|---|---|
| `BUNDLE_MASTER_Gouvernance_V1.md` | Gouvernance — standards, processus, conformité |

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
| `/runbook asset-lifecycle` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/INFRA/RUNBOOK__IT_ASSET_LIFECYCLE_V1.md` |
| `/runbook license-audit` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/SECURITY/RUNBOOK__IT_SOFTWARE_LICENSE_AUDIT_V1.md` |
| `/runbook cmdb-audit` | `PRODUCTS/IT/IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINTENANCE__RUNBOOK__CMDB_Asset_Audit_V1.md` |

---

## 5. CAPABILITIES

| Capability | Activer ? | Raison |
|---|---|---|
| **Web Search** | Non | Source de vérité = ConnectWise — web non nécessaire |
| **DALL·E** | Non | |
| **Code Interpreter** | Non | |

---

## 6. TESTS DE VALIDATION

| Message test | Comportement attendu |
|---|---|
| `/inventaire ClientABC` | Structure rapport inventaire CMDB CW — catégories, champs [À CONFIRMER] si non fournis |
| `/eol ClientABC — serveurs Windows 2012` | Rapport EOL/EOS avec dates, risques, recommandations remplacement |
| `/licences ClientABC — Microsoft 365` | Audit licences — assignées vs actives vs disponibles |
| `/runbook asset-lifecycle` | Charge RUNBOOK__IT_ASSET_LIFECYCLE_V1.md via GitHub |
| `/runbook cmdb-audit` | Charge MAINTENANCE__RUNBOOK__CMDB_Asset_Audit_V1.md |
| Asset inventé sans source CW | Refus — [À CONFIRMER] obligatoire, jamais d'invention |
| Données financières dans livrable client | Refus — ZÉRO données contractuelles dans outputs clients |
| EOL confondu avec EOS | Correction explicite — distinction signalée |
| `/close` | Menu ⛔ STOP affiché — ATTENDRE le choix |

---

## 7. RÉFÉRENCES

| Élément | Valeur |
|---|---|
| **Prompt** | `PRODUCTS/IT/20_Agents/IT-AssetMaster/prompt.md` |
| **Instructions** | `PRODUCTS/IT/20_Agents/IT-AssetMaster/00_INSTRUCTIONS.md` |
| **Bundle KP** | `PRODUCTS/IT/IT-SHARED/60_BUNDLES/BUNDLE_KP_AssetMaster_V1.md` |
| **Version** | 3.0.0 |

*GPT Setup Card v3.0 — IT-AssetMaster — IT MSP Intelligence Platform — 2026-04-10*
