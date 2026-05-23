# 80_EXEMPLES — Exemples de sorties réelles
> **Usage :** Référence qualité pour les agents — ce dossier contient des **outputs réels** produits lors d'interventions MSP. Les agents s'en inspirent pour calibrer le niveau de qualité attendu.
> **Mis à jour :** 2026-05-18

---

## À quoi sert ce dossier ?

`80_EXEMPLES` contient des **exemples concrets de livrables produits** — pas des templates vides, pas des articles KB. Ce sont des interventions réelles (anonymisées si nécessaire) qui montrent à quoi ressemble un output de qualité.

> **Règle simple :** si tu peux l'utiliser mot pour mot dans une prochaine intervention similaire en changeant juste les variables → c'est un **template** (`20_TEMPLATES/`). Si c'est un exemple documenté d'une vraie intervention → c'est ici.

---

## Ce qui va ICI

| Type | Exemple | Format |
|---|---|---|
| Fermetures CW réelles | CW Discussion + Note Interne d'une vraie intervention | `.md` |
| Transcripts agent complets | Conversation complète agent → résolution | `.md` ou `.yaml` |
| Exemples de dossiers IA | Output IT-OPS-DossierIA sur un vrai ticket | `.yaml` ou `.md` |
| Exemples KB briefs | Brief structuré d'une vraie entrée KB | `.yaml` |

## Ce qui NE va PAS ici

| Type | Aller plutôt dans |
|---|---|
| Templates réutilisables (CW, email, Teams) | `20_TEMPLATES/` |
| Articles KB de référence technique | `90_KB/` |
| Runbooks d'intervention | `10_RUNBOOKS/` |
| Scripts PowerShell/Bash | `30_SCRIPTS/` |

---

## Fichiers actuels

| Fichier | Type | Contenu |
|---|---|---|
| `EXEMPLES_CLOSE_CW_REELS.md` | Exemples réels | 2 fermetures CW complètes (Veeam ESXi + DC Windows Update) |
| `EXEMPLE_kb_brief_1683171.yaml` | Exemple KB brief | Transcript intervention Pending Reboot — Otto |
| `KB-DATTO-001_Probe-RMM-VMware.md` | Référence KB | Datto RMM + VMware probe — à migrer vers `90_KB/` |
| `TEMPLATE_PENDINGREBOOT.md` | Exemple intervention | Transcript complet Pending Reboot avec clôture CW |

---

## Comment ajouter un exemple

1. L'intervention est résolue et le livrable est de qualité
2. Anonymiser si nécessaire (remplacer noms clients par `[CLIENT]` si souhaité — optionnel pour usage interne)
3. Nommer le fichier : `EXEMPLE_[TYPE]_[SUJET-COURT].md` ou `EXEMPLE_[TYPE]_[TICKET#].yaml`
4. Ajouter une ligne dans le tableau ci-dessus

---

*README — IT-SHARED/80_EXEMPLES — MSP Intelligence AI — 2026-05-18*
