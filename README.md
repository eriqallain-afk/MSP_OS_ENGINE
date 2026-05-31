# MSP_OS_ENGINE — site MSP autonome

Site extrait des pages MSP EAIA pour isoler le lancement **MSP Intelligence IT / MSP OS Engine**.

## Contenu

- `index.html` — landing MSP autonome
- `msp-preview.html` — alias produit MSP
- `pages/msp-demos.html` — index des casepages MSP
- `pages/*.html` — casepages MSP extraites et anonymisées
- `assets/images/`, `img/`, `og-image*.png` — visuels nécessaires

## État d’anonymisation

Un scan automatique a été exécuté après extraction. Aucun motif de billet réel `17xxxxx`, `#17xxxxx`, `T17xxxxx`, `Billet #17xxxxx`, `Ticket #17xxxxx`, `Service Ticket #17xxxxx` ne doit rester.

## Déploiement dans le repo

```powershell
Copy-Item -Recurse -Force .\MSP_OS_ENGINE\* C:\CHEMIN\VERS\MSP_OS_ENGINEcd C:\CHEMIN\VERS\MSP_OS_ENGINE
git status
git add .
git commit -m "extract standalone MSP launch site"
git push
```

## Règle

Ne plus repartir d’une branche EAIA ancienne. Source propre : `MSP_OS_ENGINE/main` après scan anonymisation.
