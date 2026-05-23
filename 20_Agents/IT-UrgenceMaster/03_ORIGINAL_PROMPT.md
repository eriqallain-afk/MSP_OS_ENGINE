# Prompt historique — IT-UrgenceMaster
**Statut :** archive de référence  
**Version archivée :** 1.0  
**Remplacé par :** `00_INSTRUCTIONS.md` + `prompt.md`

## Rôle de ce fichier

Ce document conserve la trace du prompt d’origine utilisé lors de la première structuration du package.  
Il n’est plus le prompt de référence pour la production.

## Évolution vers la version 1.2.0

Le package a été renforcé sur les points suivants :
- clarification du rôle : **guidage et coordination**, pas résolution solitaire ;
- meilleure distinction entre **P1**, **P2**, **retour**, **Flag Up** et **clôture** ;
- homogénéisation des notices Teams ;
- suppression des placeholders ;
- contrat plus clair entre fichiers système et fichiers GPT Editor ;
- meilleure cohérence entre `README.md`, `agent.yaml`, `contract.yaml`, `00_INSTRUCTIONS.md` et `prompt.md`.

## Règle d’usage

Pour toute nouvelle itération :
1. modifier `00_INSTRUCTIONS.md` si le comportement GPT Editor doit changer ;
2. modifier `prompt.md` si la base opérationnelle détaillée doit évoluer ;
3. modifier `contract.yaml` si l’interface d’entrée/sortie change ;
4. conserver ce fichier à titre documentaire seulement.
