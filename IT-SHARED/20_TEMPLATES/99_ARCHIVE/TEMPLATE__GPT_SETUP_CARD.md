# GPT SETUP CARD — @IT-[NomAgent]
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

> **Usage :** Fiche de configuration pour le GPT Editor d'OpenAI.
> Tout ce qu'il faut pour créer ou reconfigurer le GPT de cet agent.
> Un seul document — zéro question ouverte.

---

## 1. IDENTITÉ GPT

| Champ GPT Editor | Valeur |
|---|---|
| **Name** | @IT-[NomAgent] |
| **Description** | [1-2 phrases affichées à l'utilisateur dans l'interface] |
| **Profile picture** | [Logo / icône à utiliser] |

---

## 2. INSTRUCTIONS (System Prompt)

**Source :** `00_INSTRUCTIONS.md` + extraits de `prompt.md`

Copier-coller dans le champ **Instructions** du GPT Editor :

```
[Contenu de 00_INSTRUCTIONS.md]
```

> ⚠️ Ne pas dépasser la limite du champ Instructions (~32 000 caractères).
> Si le prompt.md complet est trop long : le mettre en Knowledge à la place.

---

## 3. CONVERSATION STARTERS

Phrases d'amorce suggérées (champ **Conversation starters**) :

1. `[Amorce 1]`
2. `[Amorce 2]`
3. `[Amorce 3]`
4. `[Amorce 4]`

---

## 4. KNOWLEDGE — Fichiers à uploader

### 🔴 CRITIQUE — À uploader en premier (sans ces fichiers, l'agent ne fonctionne pas correctement)

| Fichier | Chemin dans le projet | Raison |
|---|---|---|
| [Nom fichier] | `[chemin]` | [Pourquoi critique] |

### 🟡 IMPORTANT — Fortement recommandé

| Fichier | Chemin | Contenu |
|---|---|---|
| [Nom fichier] | `[chemin]` | [Ce qu'il apporte] |

### 🟢 OPTIONNEL — Ajoute de la profondeur

| Fichier | Chemin | Contenu |
|---|---|---|
| [Nom fichier] | `[chemin]` | [Ce qu'il apporte] |

### ❌ NE PAS UPLOADER

| Fichier | Raison |
|---|---|
| `README.md` | Metadata interne — inutile pour le modèle |
| `manifest.json` | Config machine — ne sert pas en Knowledge |
| `agent.yaml` | Config machine — ne sert pas en Knowledge |
| `contract.yaml` | Schéma technique — ne sert pas en Knowledge |
| Fichiers `- Copie.*` | Doublons |

---

## 5. CAPABILITIES

Cocher dans GPT Editor :

- [ ] **Web Search** — [Oui / Non — justification]
- [ ] **DALL·E Image Generation** — Non (agent technique)
- [ ] **Code Interpreter** — [Oui / Non — justification]

---

## 6. TEST DE VALIDATION POST-CONFIGURATION

Envoyer ces messages après création — réponses attendues documentées.

| Message test | Réponse attendue |
|---|---|
| `[Message test 1]` | `[Ce que l'agent doit répondre ou faire]` |
| `[Message test 2]` | `[Comportement attendu]` |
| `[Message hors scope]` | `[Refus poli standard]` |

---

## 7. LIENS ET RÉFÉRENCES

| Élément | Valeur |
|---|---|
| **Fichier agent** | `20_Agents/IT-[NomAgent]/agent.yaml` |
| **Contrat** | `20_Agents/IT-[NomAgent]/contract.yaml` |
| **Prompt complet** | `20_Agents/IT-[NomAgent]/prompt.md` |
| **Guardrails** | `IT-SHARED/10_RUNBOOKS/00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md` |
| **Dernière mise à jour** | [Date] |
| **Version** | [X.X.X] |

---

*GPT Setup Card — Template v1.0 — IT MSP Intelligence Platform*
