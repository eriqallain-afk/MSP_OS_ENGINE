# TEMPLATE — CAPA (Corrective and Preventive Actions)
**ID :** TEMPLATE_CAPA_V1
**Version :** 1.0 | **Date :** 2026-05-14
**Agent producteur :** IT-Commandare-OPR | IT-SecurityMaster
**Niveau :** Enterprise
**Déclencheur :** Tout incident P1/P2 récurrent ou problème systémique identifié
**Audience :** Coordonnateur MSP / Direction technique client | **Délai :** ≤ 10 jours ouvrables post-résolution

---

# PLAN CAPA — [TITRE PROBLÈME]

**Référence CAPA :** CAPA-[ANNÉE]-[NN]
**Billet(s) lié(s) :** [#T12345, #T12346]
**Client :** [NOM CLIENT]
**Date d'ouverture :** [YYYY-MM-DD]
**Responsable :** [Technicien / Agent / Coordonnateur]
**Statut :** 🔴 Ouvert / 🟡 En cours / ✅ Fermé

---

## 1. DESCRIPTION DU PROBLÈME

**Symptôme observé :**
[Description factuelle du problème — ce qui s'est passé, combien de fois, depuis quand]

**Impact :**
- Utilisateurs touchés : [N ou description]
- Services affectés : [Liste]
- Fréquence : [Ex : 3 occurrences en 6 semaines]
- Coût estimé : [Temps technicien, interruption client si applicable]

---

## 2. ANALYSE CAUSE RACINE (RCA)

**Méthode utilisée :** ☐ 5 Pourquoi  ☐ Arbre de causes  ☐ Ishikawa  ☐ Autre : [_____]

**Chronologie des faits :**
| Heure | Événement |
|---|---|
| [HH:MM] | [Événement] |
| [HH:MM] | [Événement] |

**Cause immédiate :**
[Ce qui a directement provoqué le problème]

**Cause profonde :**
[La vraie raison systémique — ex : absence de monitoring, processus manquant, matériel en fin de vie]

**Facteurs contributifs :**
- [Facteur 1 — ex : aucune alerte configurée sur ce service]
- [Facteur 2]

---

## 3. ACTIONS CORRECTIVES (Corrective — traiter le symptôme)

> Actions immédiates déjà appliquées ou à appliquer pour arrêter le problème actuel.

| # | Action | Responsable | Échéance | Statut |
|---|---|---|---|---|
| C1 | [Description action corrective] | [Nom] | [YYYY-MM-DD] | ☐ À faire / ✅ Fait |
| C2 | [Description] | [Nom] | [YYYY-MM-DD] | ☐ À faire / ✅ Fait |

---

## 4. ACTIONS PRÉVENTIVES (Preventive — éviter la récurrence)

> Actions structurelles pour que le problème ne se reproduise pas.

| # | Action | Responsable | Échéance | Statut |
|---|---|---|---|---|
| P1 | [Description action préventive — ex : Configurer alerte RMM sur X] | [Nom] | [YYYY-MM-DD] | ☐ À faire |
| P2 | [Description — ex : Ajouter vérification dans runbook de maintenance] | [Nom] | [YYYY-MM-DD] | ☐ À faire |
| P3 | [Description — ex : Planifier remplacement matériel X avant fin de vie] | [Nom] | [DATE] | ☐ À faire |

---

## 5. VALIDATION DE L'EFFICACITÉ

**Critères de succès :**
- [ ] [Critère 1 — ex : Zéro récurrence de l'incident pendant 90 jours]
- [ ] [Critère 2 — ex : Alerte configurée et testée]
- [ ] [Critère 3]

**Date de vérification prévue :** [YYYY-MM-DD]
**Validé par :** [Coordonnateur / Responsable technique]

---

## 6. COMMUNICATION

| Destinataire | Format | Date prévue | Fait |
|---|---|---|---|
| Client [NOM] | [Verbal / Courriel / Rapport] | [DATE] | ☐ |
| Équipe interne | [Teams / Réunion] | [DATE] | ☐ |

---

## 7. CLÔTURE

**Date de clôture :** [YYYY-MM-DD]
**Résumé de clôture :**
[Confirmation que les actions ont été appliquées et que la cause racine est traitée]

**Leçon retenue (pour KB) :**
[1-2 phrases — qu'est-ce qu'on a appris, à documenter dans la base de connaissance]

---

*CAPA-[ANNÉE]-[NN] — [CLIENT] — Émis le [DATE] — Révisé le [DATE]*
