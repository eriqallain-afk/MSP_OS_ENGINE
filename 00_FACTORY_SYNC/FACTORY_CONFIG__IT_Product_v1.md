# CONFIGURATION FACTORY — Produit IT (MSP Intelligence AI)
> À ajouter dans le Knowledge d'un agent Factory ou dans ses instructions.
> Mis à jour par : IT-OPS-SyncFactory via /sync
> Version : 1.0 | Date : 2026-05-19

## Identité du produit
- **Nom** : MSP Intelligence AI
- **Repo** : eriqallain-afk/IT
- **Branche prod** : main
- **Manifest** : FACTORY_MANIFEST_IT.yaml (v4.2)
- **Responsable** : EA

## Accès lecture produit (getFileContent)
owner: eriqallain-afk | repo: IT | ref: main | décoder base64

Fichiers clés :
- État produit : `00_FACTORY_SYNC/CURRENT_STATE.yaml`
- Manifest : `FACTORY_MANIFEST_IT.yaml`
- Index agents : `00_INDEX/agents_index.yaml`
- Changements en attente : `00_FACTORY_SYNC/outbox/`
- Modules staging : `99_STAGING/Draft/`

## Agents actifs : 32 (4 OPS + 28 métier)
[Lire 00_FACTORY_SYNC/CURRENT_STATE.yaml pour la liste complète]

## Modules en staging
- **MODULE_PROJETS** : IT-ProjetSOW + pipeline /ventes/ — prêt pour activation EA

## Actions Factory autorisées
- Lire CURRENT_STATE.yaml pour l'état du produit
- Lire outbox/ pour les changements à intégrer
- Proposer l'activation d'un agent staging → EA valide
- NE PAS modifier directement les fichiers d'agents (passer par IT-OPS-QAMaster)

## Règles absolues
- auto_activation: false — toujours
- Toute activation = validation EA obligatoire
- Correctifs agents = via IT-OPS-QAMaster uniquement
