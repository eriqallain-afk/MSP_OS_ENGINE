# assets/images — Visuels EA|IA

Placer ici tous les visuels de marque avant de pousser sur GitHub.

---

## Fichiers attendus

### Logo
| Fichier | Format | Usage |
|---|---|---|
| `logo-ea-ia.png` | PNG transparent · min 500×500 | Logo isolé — partout |
| `logo-ea-ia-white.png` | PNG transparent · sur fond sombre | Version claire |
| `logo-ea-ia-square.png` | PNG carré 1:1 · 1000×1000 | Profil réseaux sociaux |

### Open Graph — CRITIQUE
| Fichier | Dimensions | Usage |
|---|---|---|
| `og-image.png` | **1200×630 px** | Preview Facebook · LinkedIn · iMessage |

> **Hint :** Prendre le bandeau `FACEBOOK-Bandeau-2.png` (roi d'échecs),
> recadrer à 1200×630 centré sur le logo EA|IA. C'est ce que voient
> les gens quand tu partages le lien. Impact direct sur les clics.

### Bandeaux Facebook
| Fichier | Dimensions | Variante |
|---|---|---|
| `bandeau-globe.png` | 1640×624 px | Globe tech |
| `bandeau-echecs.png` | 1640×624 px | Roi d'échecs — recommandé comme cover |
| `bandeau-profil-ia.png` | 1640×624 px | Profil IA cityscape |

### Posts sociaux
| Fichier | Dimensions | Usage |
|---|---|---|
| `post-lancement-1080.png` | 1080×1080 px | Publication carré |
| `story-lancement-1920.png` | 1080×1920 px | Story / Reels |

### Backgrounds
| Fichier | Source | Usage |
|---|---|---|
| `bg-noc.png` | batch_1 — Centre NOC | Section FACTORY / MSP |
| `bg-cloud.png` | batch_2 — Cloud IA | Section armées |
| `bg-agents.png` | batch_3 — Agents IA | Hero alternatif |

---

## Balises OG à ajouter dans index.html

Insérer dans le `<head>` **avant** de pousser :

```html
<meta property="og:title" content="EA|IA — Intelligence artificielle opérationnelle">
<meta property="og:description" content="La prochaine étape de l'IA n'est pas une conversation. C'est une armée. 6 armées déployées. 130+ agents actifs.">
<meta property="og:image" content="https://eaia.ca/assets/images/og-image.png">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:url" content="https://eaia.ca">
<meta property="og:type" content="website">
<meta property="og:locale" content="fr_CA">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="EA|IA — Intelligence artificielle opérationnelle">
<meta name="twitter:description" content="Des armées d'agents IA opérationnels. 6 armées. 130+ agents actifs.">
<meta name="twitter:image" content="https://eaia.ca/assets/images/og-image.png">
```

---

## Nommage — Convention

```
[type]-[variante]-[dimensions].[ext]
ex: bandeau-echecs-1640x624.png
    post-lancement-1080x1080.png
    logo-ea-ia-500x500.png
```

Tout en minuscules, tirets, pas d'espaces ni d'accents — URLs propres.

---

*EA|IA Technologies · assets v1.0 · 2026*
