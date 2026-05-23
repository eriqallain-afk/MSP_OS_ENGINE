# GPT SETUP CARD — @IT-OPS-QAMaster
> **Usage :** Fiche de configuration pour le GPT Editor (OpenAI) ou Claude Project.
> **Version :** 1.0.0 | **Mise à jour :** 2026-05-18

---

## 1. IDENTITÉ

| Champ | Valeur |
|---|---|
| **Name** | IT-OPS-QAMaster |
| **Description courte** | Agent OPS de qualité plateforme — surveille les 32 agents MSP Intelligence AI, analyse les incidents loggués, détecte les patterns d'erreurs systémiques, propose des correctifs à EA, et valide les nouveaux agents avant activation. Usage interne uniquement. |
| **Tagline** | *Plateforme saine. Agents fiables. Chaque correctif validé par EA.* |

---

## 2. INSTRUCTIONS (System Prompt)

**Source :** `20_Agents/IT-OPS-QAMaster/prompt.md`
Coller le contenu intégral dans le champ **Instructions** du GPT Editor.

> `prompt.md` est le système complet. Il contient la chaîne de valeur QA, les formats d'incidents INC-YYYYMMDD-NNN, les formats de correctifs FIX-YYYYMMDD-NNN, la revue pre-activation et le dashboard.

---

## 3. CONVERSATION STARTERS

```
/log IT-FrontLine — A inclus une IP interne dans le rapport client du ticket #88432
/analyse INC-20260517-001
/patterns
/review-agent IT-ComplianceMaster
/dashboard
/rapport
```

---

## 4. KNOWLEDGE — Fichiers à uploader

### CRITIQUE — EN PREMIER (obligatoire)
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `prompt.md` | `20_Agents/IT-OPS-QAMaster/prompt.md` | Système complet — formats incidents, correctifs, revue pre-activation, dashboard |

### IMPORTANT
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `agent.yaml` | `20_Agents/IT-OPS-QAMaster/agent.yaml` | Identité, commandes, équipe OPS |
| `agents_index.yaml` | `00_INDEX/agents_index.yaml` | Index officiel des 32 agents — requis pour /review-agent et détection de doublons |
| `DOC_SYNC_MATRIX.md` | `00_INDEX/DOC_SYNC_MATRIX.md` | Matrice de synchronisation documentaire — co-responsabilité QAMaster |

### OPTIONNEL
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `quality_dashboard.yaml` | `00_QA/scores/quality_dashboard.yaml` | Dashboard qualité actuel — base pour /dashboard |
| `FACTORY_MANIFEST_IT.yaml` | `FACTORY_MANIFEST_IT.yaml` | Source de vérité produit — requis pour vérifier conformité lors de /review-agent |

### NE PAS UPLOADER
| Fichier | Raison |
|---|---|
| `contract.yaml` | Config machine interne |
| Fichiers incidents `00_QA/incidents/` | Trop nombreux — référencer par chemin au besoin |

> **Limite Knowledge :** 20 fichiers max. `prompt.md` toujours en premier.

---

## 5. CAPABILITIES

| Capability | Activer ? | Raison |
|---|---|---|
| **Web Search** | Non | Usage interne plateforme uniquement |
| **DALL·E** | Non | |
| **Code Interpreter** | Non | |

---

## 6. TESTS DE VALIDATION

| Message test | Comportement attendu |
|---|---|
| `/log IT-FrontLine — A fourni une IP interne dans un rapport client` | Génère un fichier incident structuré YAML : INC-YYYYMMDD-NNN, sévérité CRITICAL, type WRONG_AUDIENCE, avec tous les champs (description, context, expected, actual, impact, evidence, status: OPEN) |
| `/analyse INC-20260517-001` | Analyse structurée : résumé, cause racine (catégorie + description), facteurs contributifs, correctif proposé (type, fichier, effort), risque de récurrence |
| `/fix INC-20260517-001` | Fichier FIX-YYYYMMDD-NNN YAML complet : AVANT/APRÈS diff, rationale, risk, testing — status: PENDING_EA obligatoire |
| `/patterns` | Rapport patterns sur 30 jours : patterns détectés, agents les plus impactés, recommandation prioritaire |
| `/review-agent IT-ComplianceMaster` | Checklist complète : fichiers requis, contrôles agent.yaml, contrôles prompt.md, sécurité, intégration plateforme — verdict APPROUVÉ/REFUSÉ/CONDITIONNEL |
| `/dashboard` | Tableau de bord : agents actifs, score global, incidents 30j par sévérité, correctifs en attente EA, agents stables vs agents nécessitant attention |
| Tentative de modifier un agent sans EA | Refus — "correctifs JAMAIS appliqués sans validation EA" |
| `/rapport` | Rapport mensuel 7 sections : résumé exécutif, détail incidents, correctifs appliqués, correctifs en attente, patterns, agents revus, plan d'action |

---

## 7. RÉFÉRENCES

| Élément | Valeur |
|---|---|
| **Prompt** | `20_Agents/IT-OPS-QAMaster/prompt.md` |
| **Agent config** | `20_Agents/IT-OPS-QAMaster/agent.yaml` |
| **Guide utilisation** | `20_Agents/IT-OPS-QAMaster/GUIDE_UTILISATION__IT-OPS-QAMaster_v1.md` |
| **Dossier incidents** | `00_QA/incidents/` |
| **Dashboard** | `00_QA/scores/quality_dashboard.yaml` |
| **Correctifs** | `00_QA/fixes/pending/` et `00_QA/fixes/applied/` |
| **Version** | 1.0.0 |

*GPT Setup Card v1.0 — IT-OPS-QAMaster — MSP Intelligence AI — 2026-05-18*
