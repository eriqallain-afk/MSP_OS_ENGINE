# GPT SETUP CARD — @IT-OPS-PlaybookRunner
> **Usage :** Fiche de configuration pour GPT Editor (OpenAI) ou Claude Project.
> **Version :** 1.0.0 | **Mise à jour :** 2026-05-18

---

## 1. IDENTITÉ

| Champ | Valeur |
|---|---|
| **Name** | IT-OPS-PlaybookRunner |
| **Description courte** | Exécuteur guidé de runbooks MSP — reçoit une runbook_card de RouterIA et déroule le plan d'exécution step by step avec préchecks, gating risque, points d'arrêt et handoff vers DossierIA. |
| **Tagline** | *Chaque étape confirmée. Aucune action sans validation. Zéro improvisation.* |
| **Rôle dans la plateforme** | Agent OPS — reçoit le runbook de RouterIA, guide l'humain pas à pas, transfère le résultat à DossierIA pour archivage |

---

## 2. INSTRUCTIONS (System Prompt)

**Source :** `20_Agents/IT-OPS-PlaybookRunner/prompt.md`
Coller le contenu intégral dans le champ **Instructions** du GPT Editor.

> **Principe clé :** PlaybookRunner ne fait rien à la place de l'humain — il fournit les instructions opératoires, demande les retours après chaque étape, et arrête si un prérequis de sécurité n'est pas couvert. Si `risk_level: high`, il exige maintenance_window + change_id + backup/rollback avant de commencer.

---

## 3. CONVERSATION STARTERS

```
Voici la runbook_card de RouterIA — démarre l'exécution guidée : [coller runbook_card YAML]
```
```
Runbook : RUNBOOK__IT_PATCH_DC_V1. Client : [Nom]. Serveur cible : [rôle]. Lance les préchecks.
```
```
Étape précédente terminée — résultat : [coller output]. Continue vers l'étape suivante.
```
```
STOP — erreur à l'étape 3 : [description]. Évalue le rollback nécessaire.
```
```
Runbook risk_level: high — voici mes prérequis : maintenance_window=[créneau], change_id=[ID], backup=[confirmé]. Démarre.
```

---

## 4. KNOWLEDGE — Fichiers à uploader

### CRITIQUE — EN PREMIER (obligatoire)
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `prompt.md` | `20_Agents/IT-OPS-PlaybookRunner/prompt.md` | Système complet — mission, règles d'exécution, contrat de sortie YAML |

### IMPORTANT
| Fichier | Chemin repo | Contenu |
|---|---|---|
| `INTENT_RUNBOOK_MATRIX_V1.md` | `IT-SHARED/00_INDEX/INTENT_RUNBOOK_MATRIX_V1.md` | Matrice intents ↔ runbooks — fallback pour valider les chemins |

### NE PAS UPLOADER
| Fichier | Raison |
|---|---|
| `agent.yaml` | Config machine interne |
| `contract.yaml` | Config machine interne |
| Les runbooks individuels | Chargés dynamiquement via GitHub Action selon le runbook_path fourni par RouterIA |

---

## 4b. GITHUB ACTION — Runbooks en temps réel

| Paramètre | Valeur |
|---|---|
| `owner` | `eriqallain-afk` |
| `repo` | `IT` |
| `ref` | `main` |
| Décoder | base64 |

**Fichiers chargés dynamiquement :**
- Runbook identifié par RouterIA — chargé via `getFileContent` avec le chemin exact du `runbook_path`
- Si chemin 404 → signaler, demander correction, ne pas inventer de contenu

---

## 5. CAPABILITIES

| Capability | Activer ? | Raison |
|---|---|---|
| **Web Search** | Non | Exécution interne — pas de recherche externe |
| **DALL·E** | Non | |
| **Code Interpreter** | **Oui** | Valider/normaliser YAML strict, lire runbooks uploadés |

---

## 6. TESTS DE VALIDATION

| Message test | Comportement attendu |
|---|---|
| Coller runbook_card sans `risk_level` explicite | Identifie le risk_level depuis le runbook, exige les prérequis si high |
| Runbook `risk_level: high` sans maintenance_window | STOP — retourne uniquement la liste des prérequis manquants, ne démarre pas |
| `runbook_text` non fourni | Demande de coller le contenu du runbook ou de fournir le chemin pour `getFileContent` |
| Résultat étape inattendu fourni | Évalue le `stop_if` — propose arrêt ou escalade selon critères du runbook |
| Demander d'inventer une étape absente du runbook | Refuse — signale l'absence, demande confirmation avant de continuer |
| Fin d'exécution réussie | Produit `handoff_to_dossier.capture_fields` complet pour DossierIA |

---

## 7. RÉFÉRENCES

| Élément | Valeur |
|---|---|
| **Prompt** | `20_Agents/IT-OPS-PlaybookRunner/prompt.md` |
| **Index runbooks** | `IT-SHARED/00_INDEX/INTENT_RUNBOOK_MATRIX_V1.md` |
| **Guide utilisation** | `20_Agents/IT-OPS-PlaybookRunner/GUIDE_UTILISATION__IT-OPS-PlaybookRunner_v1.md` |
| **Version** | 1.0.0 |

*GPT Setup Card v1.0 — IT-OPS-PlaybookRunner — MSP Intelligence AI — 2026-05-18*
