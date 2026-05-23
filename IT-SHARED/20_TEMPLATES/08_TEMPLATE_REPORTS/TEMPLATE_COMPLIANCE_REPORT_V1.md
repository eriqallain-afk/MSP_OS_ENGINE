# TEMPLATE — Rapport de Conformité IT
**ID :** TEMPLATE_COMPLIANCE_REPORT_V1
**Version :** 1.0 | **Date :** 2026-05-14
**Agent producteur :** IT-SecurityMaster | IT-Commandare-OPR
**Niveau :** Enterprise
**Audience :** Direction / Responsable conformité client | **Fréquence :** Trimestrielle ou sur demande
**Délai :** ≤ 10 jours ouvrables après fin de période

---

# RAPPORT DE CONFORMITÉ IT — [PÉRIODE] [ANNÉE]

**Client :** [NOM CLIENT]
**Préparé par :** [MSP NAME]
**Période couverte :** [DATE DÉBUT] — [DATE FIN]
**Référence :** COMPLIANCE-[ANNÉE]-[NN]
**Envoyé à :** [PRÉNOM NOM — rôle]

---

## 1. RÉSUMÉ EXÉCUTIF

> *3-4 phrases. Niveau de conformité global, points critiques, tendance vs période précédente.*

[RÉSUMÉ EXÉCUTIF]

**Niveau de conformité global :** 🟢 Conforme / 🟡 Partiellement conforme / 🔴 Non conforme

---

## 2. PÉRIMÈTRE D'ÉVALUATION

| Domaine | Inclus | Remarque |
|---|---|---|
| Postes de travail | ☐ Oui / ☐ Non | [N postes] |
| Serveurs | ☐ Oui / ☐ Non | [N serveurs] |
| Réseau / Pare-feu | ☐ Oui / ☐ Non | [Description] |
| Microsoft 365 / Entra ID | ☐ Oui / ☐ Non | [N licences] |
| Sauvegardes | ☐ Oui / ☐ Non | [Solutions] |
| Accès distant / VPN | ☐ Oui / ☐ Non | [Description] |

**Cadre de référence :** ☐ CIS Controls v8  ☐ NIST  ☐ ISO 27001  ☐ PIPEDA  ☐ Politique interne client  ☐ Autre : [_____]

---

## 3. TABLEAU DE BORD — CONFORMITÉ PAR DOMAINE

| Domaine | Contrôles évalués | Conformes | Partiels | Non conformes | Score |
|---|---|---|---|---|---|
| Gestion des identités / accès | [N] | [N] | [N] | [N] | [X%] |
| Protection des postes (EDR/AV) | [N] | [N] | [N] | [N] | [X%] |
| Gestion des correctifs | [N] | [N] | [N] | [N] | [X%] |
| Sauvegardes & restauration | [N] | [N] | [N] | [N] | [X%] |
| Sécurité réseau | [N] | [N] | [N] | [N] | [X%] |
| Journalisation & surveillance | [N] | [N] | [N] | [N] | [X%] |
| Sensibilisation utilisateurs | [N] | [N] | [N] | [N] | [X%] |
| **TOTAL** | **[N]** | **[N]** | **[N]** | **[N]** | **[X%]** |

---

## 4. NON-CONFORMITÉS CRITIQUES

> *Éléments à adresser en priorité — risque élevé ou exigence réglementaire.*

| # | Domaine | Description | Risque | Échéance recommandée |
|---|---|---|---|---|
| NC-01 | [Domaine] | [Description de la non-conformité] | 🔴 Critique / 🟡 Élevé | [DATE] |
| NC-02 | [Domaine] | [Description] | 🟡 Élevé | [DATE] |
| NC-03 | [Domaine] | [Description] | 🟠 Modéré | [DATE] |

---

## 5. DÉTAIL DES CONTRÔLES

### 5.1 Gestion des identités et des accès

| Contrôle | Statut | Observation |
|---|---|---|
| MFA activé pour tous les comptes admin | ✅ / ⚠️ / ❌ | [Observation] |
| MFA activé pour tous les utilisateurs | ✅ / ⚠️ / ❌ | [Observation] |
| Revue des accès privilégiés | ✅ / ⚠️ / ❌ | [Dernière revue : DATE] |
| Comptes inactifs désactivés (>90 jours) | ✅ / ⚠️ / ❌ | [N comptes concernés] |
| Politique de mot de passe conforme | ✅ / ⚠️ / ❌ | [Observation] |

### 5.2 Protection des postes

| Contrôle | Statut | Observation |
|---|---|---|
| EDR/AV déployé sur tous les postes | ✅ / ⚠️ / ❌ | [X/X postes] |
| Signatures à jour (< 24h) | ✅ / ⚠️ / ❌ | [Observation] |
| Chiffrement disque (BitLocker/FileVault) | ✅ / ⚠️ / ❌ | [X/X postes] |
| Pare-feu local activé | ✅ / ⚠️ / ❌ | [Observation] |

### 5.3 Gestion des correctifs

| Contrôle | Statut | Observation |
|---|---|---|
| Postes — correctifs critiques ≤ 30 jours | ✅ / ⚠️ / ❌ | [X% conformes] |
| Serveurs — correctifs critiques ≤ 30 jours | ✅ / ⚠️ / ❌ | [X% conformes] |
| Systèmes en fin de support identifiés | ✅ / ⚠️ / ❌ | [Liste si applicable] |

### 5.4 Sauvegardes

| Contrôle | Statut | Observation |
|---|---|---|
| Sauvegardes quotidiennes configurées | ✅ / ⚠️ / ❌ | [Observation] |
| Test de restauration effectué | ✅ / ⚠️ / ❌ | [Dernière date : DATE] |
| Copie hors site / immuable | ✅ / ⚠️ / ❌ | [Observation] |
| RTO/RPO documentés | ✅ / ⚠️ / ❌ | [RTO: Xh / RPO: Xh] |

---

## 6. PLAN DE REMÉDIATION

| # | Non-conformité | Action recommandée | Responsable | Échéance | Statut |
|---|---|---|---|---|---|
| NC-01 | [Ref] | [Action] | [MSP / Client] | [DATE] | ☐ À faire |
| NC-02 | [Ref] | [Action] | [MSP / Client] | [DATE] | ☐ À faire |

---

## 7. ÉVOLUTION VS PÉRIODE PRÉCÉDENTE

| Domaine | Score précédent | Score actuel | Tendance |
|---|---|---|---|
| [Domaine] | [X%] | [X%] | ↑ Amélioration / → Stable / ↓ Dégradation |

---

## 8. RECOMMANDATIONS PRIORITAIRES

1. [Recommandation 1 — action concrète avec impact]
2. [Recommandation 2]
3. [Recommandation 3]

---

*Rapport de conformité préparé par [MSP NAME] — [DATE]*
*Référence : COMPLIANCE-[ANNÉE]-[NN] — Pour toute question : [courriel support MSP]*
