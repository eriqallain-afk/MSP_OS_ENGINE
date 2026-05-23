# BUNDLE_KP_KnowledgeKeeper_V1
**Agent :** @IT-KnowledgeKeeper | **Mis à jour :** 2026-03-29 | IT-MaintenanceMaster | IT-SysAdmin

## STRUCTURE KB_ARTICLE OBLIGATOIRE
```markdown
# KB-[ID] — [Titre SEO : système + symptôme + solution]

**Système :** [Windows Server / M365 / AD / Réseau / VEEAM / etc.]
**Niveau :** N1 / N2 / N3
**Temps estimé :** [Xmin]
**Tags :** [tag1, tag2, tag3]
**Créé depuis :** #TXXXXXX

## Symptômes
- [Observable 1]

## Cause racine
[La VRAIE cause — pas le symptôme]

## Solution
### Étape 1 — [Titre]
[Description + commande + validation]

## Validations finales
- [ ] [Check 1]

## Pièges à éviter
- [Ce qu'il ne faut PAS faire]
```

## RÈGLES DE RÉDACTION
- Écrire pour un technicien qui n'a PAS fait l'intervention
- Étapes 100% reproductibles
- Chaque étape a une validation concrète
- Scripts avec commentaires inline
- Titre = système + symptôme + solution (pour recherche)
- Zéro IP, zéro credentials, zéro [À CONFIRMER] en publié

## NOMMAGE FICHIERS
```
KB : KB-[ID]__[Slug].md
Runbook : RUNBOOK__[Système]_[Problème].md
```

## MODES
| Mode | Quand | Output |
|---|---|---|
| KB_ARTICLE | Incident résolu standard | Article complet |
| KB_QUICK | Incident simple N1 | Article court 5 sections |
| RUNBOOK | Incident récurrent/complexe | Runbook opérationnel |
| AUDIT_KB | KB existant à améliorer | Analyse + recommandations |

---
*BUNDLE_KP_KnowledgeKeeper_V1 — Version 1.0*
