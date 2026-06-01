# CLAUDE.md — MSP OS Engine (Site vitrine)

> Ce fichier est lu automatiquement par Claude Code à chaque session.
> Il décrit l'architecture complète du dépôt pour éviter toute improvisation.
> Format aligné sur le gabarit canonique : `Factory/90_KNOWLEDGE/BUNDLE_PACK__TEAM_TEMPLATE/TEMPLATE__CLAUDE_MD.md`.

---

## 1. IDENTITÉ DU PRODUIT

| Champ | Valeur |
|---|---|
| **Nom** | MSP OS Engine — site vitrine MSP autonome |
| **Code repo** | `eriqallain-afk/MSP_OS_ENGINE` |
| **Nature** | Site web **statique** (HTML/CSS/JS) — GitHub Pages |
| **Produit présenté** | MSP Intelligence AI (repo `eriqallain-afk/IT`) — produit phare EA\|IA |
| **Produit par** | Factory (repo `eriqallain-afk/Factory`) |
| **Responsable** | EA (validation manuelle obligatoire pour toute mise en ligne) |

MSP OS Engine est le **site vitrine public** extrait des pages MSP EA\|IA pour isoler le lancement de **MSP Intelligence IT**. Ce dépôt ne contient **pas d'agents IA** : les agents vivent dans le repo `IT`. Ici on trouve la landing page et les **casepages anonymisées** qui démontrent les interventions du produit.

> ⚠️ **Redondance connue** : ce dépôt et `eriqallain-afk/MSP_OS_ENG_LAUNCH_SITE` partagent la même origine (README identique). Clarifier avec EA lequel est canonique avant toute refonte majeure.

---

## 2. STRUCTURE DU REPO

```
MSP_OS_ENGINE/
├── CLAUDE.md                    ← Ce fichier
├── README.md                    ← Origine, règle d'anonymisation, déploiement
├── index.html                   ← Landing MSP autonome
├── msp-preview.html             ← Alias produit MSP
├── .nojekyll                    ← Désactive Jekyll (GitHub Pages sert le HTML brut)
├── pages/                       ← 41 casepages MSP extraites et anonymisées
│   ├── msp-demos.html           ← Index des casepages
│   └── eaia_case_*.html / msp-case-*.html
├── docs/                        ← Miroir publié + campagne marketing
│   ├── index.html, msp-preview.html, pages/
│   └── campagne/                ← calendrier.md, linkedin.md, slogans.md, x-twitter.md
├── assets/images/, img/         ← Visuels
├── og-image*.png                ← Open Graph (partage social)
├── .github/workflows/           ← 2 workflows de maintenance HTML
│   ├── normalize-casepage-headers.yml
│   └── update-contact-email.yml
└── scan-anonymisation.ps1       ← Scan PowerShell de contrôle d'anonymisation
```

---

## 3. COMPOSANTS DU SITE (pas d'agents)

Ce dépôt est un site statique : **il n'y a pas de couche d'agents OPS/Métier**. Le tableau ci-dessous remplace la section « Agents » du gabarit par les composants réels.

| Composant | Rôle |
|---|---|
| `index.html` | Landing principale — proposition de valeur MSP Intelligence IT |
| `msp-preview.html` | Page preview/alias du produit |
| `pages/msp-demos.html` | Index navigable des 41 casepages |
| `pages/*.html` | Casepages : démonstrations d'interventions réelles **anonymisées** |
| `docs/campagne/` | Contenus de campagne (LinkedIn, X, calendrier, slogans) |
| `.github/workflows/` | Automatisations : normalisation des en-têtes de casepages + mise à jour de l'email de contact |

> Le **fond métier** (les 33 agents qui produisent ces interventions) est dans `eriqallain-afk/IT`. Ce site ne fait que **présenter** le produit.

---

## 4. STRUCTURE D'UNE CASEPAGE

Chaque page de `pages/` est une page HTML autonome démontrant une intervention type :
- En-tête normalisé (titre, contexte, sévérité) — maintenu par `normalize-casepage-headers.yml`
- Corps : symptôme → diagnostic → résolution → preuve
- **Toujours anonymisée** (voir §5)

---

## 5. RÈGLES ABSOLUES

### Anonymisation (règle n°1, non négociable)
Aucun motif de billet réel ne doit subsister dans le HTML publié :
`17xxxxx`, `#17xxxxx`, `T17xxxxx`, `Billet #17xxxxx`, `Ticket #17xxxxx`, `Service Ticket #17xxxxx`.

→ Exécuter `scan-anonymisation.ps1` après toute extraction ou ajout de casepage.
→ Aucun nom de client réel, IP, hostname ou donnée identifiante.

### Avant toute mise en ligne
1. Lancer le scan d'anonymisation — **0 occurrence** attendue
2. Vérifier le rendu local (ouvrir `index.html` + quelques casepages)
3. Ne jamais repartir d'une ancienne branche EA\|IA — source propre : ce repo après scan

### Conventions
- Casepages : `eaia_case_{sujet}.html` ou `msp-case-{sujet}.html`
- Visuels : `og-image*.png` pour le partage social, `img/` et `assets/images/` pour le site
- `.nojekyll` doit rester présent (sinon GitHub Pages ignore certains dossiers)

### Git
- **Branche de développement : `claude/keen-curie-OIgRs`**
- Jamais de push direct sur `main` sans PR + validation EA

---

## 6. DÉPLOIEMENT — GitHub Pages

Site statique servi par GitHub Pages (`.nojekyll` actif).

```
Settings → Pages → Source : branche publiée / racine (ou /docs)
```

Le dossier `docs/` contient un miroir publiable. Vérifier dans les Settings du repo quelle source (racine vs `/docs`) est active avant de modifier.

---

## 7. AUTOMATISATIONS (GitHub Actions)

| Workflow | Rôle |
|---|---|
| `normalize-casepage-headers.yml` | Uniformise les en-têtes de toutes les casepages |
| `update-contact-email.yml` | Met à jour l'email de contact sur l'ensemble du site |

Modifier ces workflows avec prudence : ils réécrivent du HTML en masse.

---

## 8. QUALITÉ ATTENDUE

- **0 donnée identifiante** — l'anonymisation prime sur tout le reste
- Pages directement publiables — pas de placeholder, pas de lien mort
- Cohérence visuelle avec la charte EA\|IA (or `#EDAF45`, fond noir)
- Casepages : preuve > promesse — chaque démo montre un résultat concret

---

*CLAUDE.md v1.0 — MSP OS Engine (site vitrine) — Mis à jour le 2026-06-01*
*Format dérivé de : Factory/90_KNOWLEDGE/BUNDLE_PACK__TEAM_TEMPLATE/TEMPLATE__CLAUDE_MD.md v1.0 (adapté site statique)*
