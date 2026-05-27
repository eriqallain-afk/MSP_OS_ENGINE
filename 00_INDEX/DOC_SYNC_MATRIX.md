# DOC_SYNC_MATRIX — Matrice de synchronisation documentaire

> **Fichier lu par tout agent qui crée ou modifie quelque chose dans le repo.**
> Quand un changement est effectué, consulter ce fichier pour savoir quels autres
> documents doivent être mis à jour et qui notifier.
>
> Responsable de l'application : **IT-OPS-DossierIA** (après chaque run)
> Responsable de la maintenance : **IT-QAMaster** (si une règle est manquante ou obsolète)

---

## RÈGLE D'OR

> Avant de fermer tout ticket ou run : consulter cette matrice.
> Si un document de la colonne **"Mettre à jour"** n'a pas été mis à jour → ajouter une `next_action`.
> Ne jamais laisser les index désynchronisés.

---

## MATRICE

### Nouvel agent créé

> Procédure complète : `00_DOCS/PROCEDURE_CREATION_AGENT_V1.md`

| Document à mettre à jour | Champ concerné | Responsable |
|---|---|---|
| `20_Agents/[id]/agent.yaml` | Créer avec status: staging | Auteur du changement |
| `20_Agents/[id]/00_INSTRUCTIONS.md` | Guardrails + rôle + commandes + RUNBOOKS GITHUB | Auteur du changement |
| `20_Agents/[id]/GPT_SETUP_CARD__[Nom]_v1.md` | Fiche config GPT Editor — nom, description <300 chars, knowledge files | Auteur du changement |
| `20_Agents/[id]/GUIDE_UTILISATION__[Nom]_v1.md` | Guide technicien — quand utiliser, commandes, périmètre | Auteur du changement |
| `IT-SHARED/60_BUNDLES/KNOWLEDGEPACK/BUNDLE_KP_[Nom]_V1.md` | Bundle KP chargé dans GPT Editor — fallback si GitHub inaccessible | Auteur du changement |
| `00_INDEX/agents_index.yaml` | Ajouter entrée complète | Auteur du changement |
| `FACTORY_MANIFEST_IT.yaml` | Ajouter entrée + incrémenter `stats.total_agents` | Auteur du changement |
| `CLAUDE.md` | Tableau agents section 3 + compteur total | Auteur du changement |
| `00_QA/scores/quality_dashboard.yaml` | Incrémenter `platform.total_agents` | IT-QAMaster |
| `IT-SHARED/00_INDEX/INTENT_RUNBOOK_MATRIX_V1.md` | Ajouter intents selon le rôle de l'agent | Auteur du changement |
| `IT-SHARED/RUNBOOK_MENU_CONTEXTUEL_V4.md` | Ajouter section MENU de l'agent | Auteur du changement |
| `IT-SHARED/00_INDEX/MASTER_DISPATCH_INDEX_V2.yaml` | Ajouter signals[] pour chaque intent | Auteur du changement |

---

### Agent modifié (prompt, guardrails, commandes)

| Document à mettre à jour | Champ concerné | Responsable |
|---|---|---|
| `20_Agents/[id]/agent.yaml` | Incrémenter `version` + `date` | Auteur du changement |
| `20_Agents/[id]/04_KNOWLEDGE_INDEX.md` | Si fichiers de connaissance ajoutés/retirés | Auteur du changement |
| `FACTORY_MANIFEST_IT.yaml` | `completeness` si changement structurel | Auteur du changement |

---

### `00_INSTRUCTIONS.md` créé ou modifié

> Fichier d'instructions GPT par agent (nom, description <300 chars, instructions ~8000 chars).

| Document à mettre à jour | Champ concerné | Responsable |
|---|---|---|
| `FACTORY_MANIFEST_IT.yaml` | Ajouter `00_INSTRUCTIONS.md` dans `required_files` de l'agent | Auteur du changement |
| `00_INDEX/gpt_catalog.yaml` | Ajouter `instructions: 20_Agents/[id]/00_INSTRUCTIONS.md` dans `paths` | Auteur du changement |

> **Si créé pour la première fois :** vérifier que les deux blocs obligatoires sont présents :
> - `## Sécurité & Confidentialité — Non négociable` (texte exact)
> - `## RUNBOOKS GITHUB` avec menu adapté à l'agent

---

### Nouvel agent OPS créé (IT-OPS-*)

> En plus des règles "Nouvel agent créé" ci-dessus :

| Document à mettre à jour | Champ concerné | Responsable |
|---|---|---|
| `FACTORY_MANIFEST_IT.yaml` | Incrémenter `stats.ops_agents` | Auteur du changement |
| `CLAUDE.md` | Section équipe OPS + compteur `ops_agents` | Auteur du changement |

---

### Nouveau runbook créé

| Document à mettre à jour | Champ concerné | Responsable |
|---|---|---|
| `IT-SHARED/10_RUNBOOKS/RUNBOOK_MASTER__IT_v2.md` | Ajouter entrée dans la section appropriée | Auteur du changement |
| `IT-SHARED/10_CATALOG/RUNBOOK_CATALOG_GUIDEDOPS.md` | Ajouter fiche catalogue | Auteur du changement |
| `IT-SHARED/00_INDEX/MASTER_DISPATCH_INDEX_V2.yaml` | Ajouter intent(s) avec signals[] | Auteur du changement |
| `IT-SHARED/00_INDEX/INDEX_MASTER_IT-SHARED_V1.md` | Ajouter chemin dans la liste | Auteur du changement |
| `IT-SHARED/RUNBOOK_MENU_CONTEXTUEL_V4.md` | Ajouter entrée dans le menu si domaine couvert | Auteur du changement |

---

### Runbook modifié

| Document à mettre à jour | Champ concerné | Responsable |
|---|---|---|
| `IT-SHARED/00_INDEX/MASTER_DISPATCH_INDEX_V2.yaml` | Mettre à jour `signals[]` si le contenu a changé | Auteur du changement |
| `IT-SHARED/10_CATALOG/RUNBOOK_CATALOG_GUIDEDOPS.md` | Mettre à jour la description si applicable | Auteur du changement |

---

### Nouveau playbook créé

| Document à mettre à jour | Champ concerné | Responsable |
|---|---|---|
| `playbooks/playbooks.yaml` | Ajouter définition du playbook | Auteur du changement |
| `FACTORY_MANIFEST_IT.yaml` | Incrémenter `stats.active_playbooks` | Auteur du changement |
| `CLAUDE.md` | Mettre à jour le compteur de playbooks (section 7) | Auteur du changement |

---

### Incident qualité loggué (`00_QA/incidents/`)

| Document à mettre à jour | Champ concerné | Responsable |
|---|---|---|
| `00_QA/scores/quality_dashboard.yaml` | Incrémenter compteur incidents par sévérité | IT-QAMaster |

---

### Correctif QA appliqué (`00_QA/fixes/applied/`)

| Document à mettre à jour | Champ concerné | Responsable |
|---|---|---|
| `00_QA/scores/quality_dashboard.yaml` | Déplacer de `pending_ea` → `applied_30d` | IT-QAMaster |
| Fichier cible du correctif | Selon le `fix_type` du correctif | EA (validation) + IT-QAMaster |
| `20_Agents/[id]/agent.yaml` | Incrémenter version si prompt modifié | IT-QAMaster |

---

### Modification des indexes centraux

| Si ce fichier change… | Vérifier aussi… |
|---|---|
| `00_INDEX/agents_index.yaml` | `FACTORY_MANIFEST_IT.yaml` — cohérence stats |
| `FACTORY_MANIFEST_IT.yaml` | `CLAUDE.md` — compteurs section 3 |
| `CLAUDE.md` | Rien d'autre (c'est un fichier terminal) |
| `IT-SHARED/00_INDEX/MASTER_DISPATCH_INDEX_V2.yaml` | `IT-SHARED/RUNBOOK_MENU_CONTEXTUEL_V4.md` — couverture menu |

---

## FORMAT DE NOTIFICATION

Quand un document n'a pas encore été mis à jour, IT-OPS-DossierIA ou tout agent
doit l'indiquer dans sa sortie `next_actions` :

```yaml
next_actions:
  - "[DOC_SYNC] Mettre à jour RUNBOOK_MASTER__IT_v2.md — nouveau runbook INFRA-AD-GPO ajouté"
  - "[DOC_SYNC] Mettre à jour MASTER_DISPATCH_INDEX_V2.yaml — ajouter signals[] pour it.infra.gpo_management"
  - "[DOC_SYNC] Incrémenter stats.total_agents dans FACTORY_MANIFEST_IT.yaml — IT-ComplianceMaster ajouté"
```

Le préfixe `[DOC_SYNC]` permet de les filtrer et prioriser facilement.

---

## MAINTENANCE DE CETTE MATRICE

Si une règle manque ou est obsolète :
- **IT-QAMaster** propose l'ajout via `/fix` → soumis à EA
- Ajouter la règle dans la section appropriée
- Incrémenter la date de mise à jour ci-dessous

*Dernière mise à jour : 2026-05-23 | Maintenu par : IT-QAMaster*
