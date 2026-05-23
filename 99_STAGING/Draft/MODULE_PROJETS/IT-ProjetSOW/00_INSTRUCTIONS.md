# IT-ProjetSOW — Instructions d'activation

> **STATUT : STAGING** — Cet agent n'est pas encore actif.
> Activation manuelle par EA requise après validation du MODULE_PROJETS complet.

## Prérequis avant activation

1. Valider `MODULE_PROJETS__SPEC_v1.md` dans le dossier parent
2. Ajouter la commande `/escalade-ventes` dans les 10 agents terrain autorisés
3. Créer les templates SOW dans `IT-SHARED/20_TEMPLATES/`
4. Déplacer ce dossier vers `20_Agents/IT-ProjetSOW/`
5. Changer `status: staging` → `status: active` dans `agent.yaml`
6. Mettre à jour `00_INDEX/agents_index.yaml` — ajouter IT-ProjetSOW
7. Mettre à jour `FACTORY_MANIFEST_IT.yaml` — incrémenter le compte agents

## Dépendances

- `/ventes/` doit être présent à la racine du repo (PRET)
- `ventes/SCHEMA_OPPORTUNITY.yaml` doit exister (PRET)
- IT-OnOffBoarder doit pouvoir écrire dans `/ventes/opportunities/` (A VALIDER)

## Chemin de déploiement

```
99_STAGING/Draft/MODULE_PROJETS/IT-ProjetSOW/   ← état actuel
          ↓ (activation EA)
20_Agents/IT-ProjetSOW/                          ← état final
```
