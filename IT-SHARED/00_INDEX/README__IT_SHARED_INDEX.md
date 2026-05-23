# IT-SHARED — Index des assets (templates/runbooks/checklists/références/scripts)

Ce dossier propose un **index unifié** pour permettre aux agents IT (et au routeur IT-OPS-RouterIA) de retrouver rapidement le bon asset.

## Fichiers

- `IT_SHARED__ASSET_INDEX.yaml` : index principal (source de vérité pour la recherche).
- (Optionnel) `IT_SHARED__ASSET_INDEX.generated.yaml` : version auto-générée par script (si vous choisissez d'automatiser).

## Convention (recommandée)

1) **Chaque asset** (template/runbook/...) contient un petit bloc de métadonnées (front-matter) en tête de fichier, ex:

```yaml
---
asset_id: TPL__M365__NEW_MAILBOX
type: template
title: "Créer une boîte partagée (M365)"
use_cases: ["m365","mailbox","provisioning"]
tags: ["ExchangeOnline","sharedmailbox"]
service_area: ["M365"]
lifecycle: active
owner: IT-M365
---
```

2) Un script `scripts/rebuild_it_shared_asset_index.py` parcourt les dossiers `10_RUNBOOKS/20_TEMPLATES/30_SCRIPTS/40_CHECKLISTS/50_REFERENCE`,
lit les métadonnées et régénère l'index.

## Intégration Router

- Ajouter un intent style `it_asset_lookup` et router vers un petit acteur "AssetFinder" qui:
  - charge `00_INDEX/IT_SHARED__ASSET_INDEX.yaml`
  - filtre par `type` (si précisé)
  - rank par `signals/tags/use_cases/service_area`
  - retourne les **3 meilleurs** assets + un choix recommandé.

