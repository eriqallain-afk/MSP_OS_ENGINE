# TEMPLATE — Revue d'Architecture Cloud
**ID :** TEMPLATE_CLOUD_ARCHITECTURE_REVIEW_V1
**Version :** 1.0 | **Date :** 2026-05-14
**Agent producteur :** IT-Commandare-OPR | IT-SecurityMaster
**Niveau :** Enterprise
**Audience :** Direction technique / Architecte / Coordonnateur VCIO | **Fréquence :** Annuelle ou lors de changement majeur
**Délai :** À planifier avec le client — minimum 5 jours ouvrables de préparation

---

# REVUE D'ARCHITECTURE CLOUD — [CLIENT] — [ANNÉE]

**Client :** [NOM CLIENT]
**Préparé par :** [MSP NAME — Architecte / Coordonnateur VCIO]
**Date de revue :** [YYYY-MM-DD]
**Référence :** CLOUD-ARCH-[ANNÉE]-[NN]
**Périmètre :** [Microsoft 365 / Azure / AWS / GCP / Hybride / Multi-cloud]

---

## 1. RÉSUMÉ EXÉCUTIF

> *3-4 phrases. État actuel, maturité cloud, risques principaux, recommandations clés.*

[RÉSUMÉ EXÉCUTIF]

**Score de maturité cloud :** [X/5] — [Débutant / En développement / Défini / Géré / Optimisé]

---

## 2. INVENTAIRE DE L'ENVIRONNEMENT CLOUD

### 2.1 Microsoft 365 / Entra ID

| Composant | Déployé | Détail |
|---|---|---|
| Entra ID (Azure AD) | ✅ / ❌ | [Plan : P1 / P2 / Free] |
| Exchange Online | ✅ / ❌ | [N licences] |
| SharePoint Online | ✅ / ❌ | [N sites / usage Go] |
| Teams | ✅ / ❌ | [N utilisateurs actifs] |
| OneDrive Business | ✅ / ❌ | [Quota / usage] |
| Intune (MDM/MAM) | ✅ / ❌ | [N appareils gérés] |
| Defender for Business/M365 | ✅ / ❌ | [Plan] |
| Azure AD Connect / Sync | ✅ / ❌ | [Version / AD on-prem : Oui/Non] |

### 2.2 Azure (si applicable)

| Ressource | Quantité | Région | Coût mensuel estimé |
|---|---|---|---|
| Machines virtuelles | [N] | [Région] | [X$] |
| Stockage (Blob / Files) | [N To] | [Région] | [X$] |
| Azure Backup | ✅ / ❌ | [Coffres : N] | [X$] |
| VPN Gateway / ExpressRoute | ✅ / ❌ | [Type] | [X$] |
| Azure AD Domain Services | ✅ / ❌ | — | [X$] |
| **Total mensuel Azure** | | | **[X$]** |

### 2.3 Autres services cloud

| Service | Fournisseur | Usage | Intégration SSO |
|---|---|---|---|
| [Nom du service] | [Fournisseur] | [Description] | ✅ / ❌ |

---

## 3. SÉCURITÉ ET IDENTITÉ

### 3.1 État des contrôles

| Contrôle | Statut | Observation |
|---|---|---|
| MFA — Comptes administrateurs | ✅ / ⚠️ / ❌ | [X/X admins] |
| MFA — Tous les utilisateurs | ✅ / ⚠️ / ❌ | [X/X users] |
| Accès conditionnel (Conditional Access) | ✅ / ⚠️ / ❌ | [N politiques actives] |
| Privileged Identity Management (PIM) | ✅ / ⚠️ / ❌ | [Observation] |
| SSPR (réinitialisation self-service) | ✅ / ⚠️ / ❌ | [Observation] |
| Rôles Global Admin minimisés | ✅ / ⚠️ / ❌ | [N Global Admins] |
| Secure Score M365 | [X/X pts] | Cible : [≥X%] |

### 3.2 Risques sécurité identifiés

| # | Risque | Sévérité | Recommandation |
|---|---|---|---|
| S-01 | [Description] | 🔴 / 🟡 / 🟠 | [Action] |

---

## 4. SAUVEGARDES ET CONTINUITÉ

| Données | Solution | Fréquence | Rétention | Testé |
|---|---|---|---|---|
| Boîtes courriel Exchange | [Solution] | [Fréquence] | [X jours] | ✅ / ❌ |
| SharePoint / OneDrive | [Solution] | [Fréquence] | [X jours] | ✅ / ❌ |
| Teams (conversations/fichiers) | [Solution] | [Fréquence] | [X jours] | ✅ / ❌ |
| VMs Azure | [Azure Backup / Autre] | [Fréquence] | [X jours] | ✅ / ❌ |

> ⚠️ **Note :** Microsoft 365 n'inclut pas de sauvegarde tier 3 par défaut — une solution tierce est requise.

**RTO cible :** [Xh] | **RPO cible :** [Xh]
**Dernier test de restauration :** [DATE ou Jamais effectué]

---

## 5. PERFORMANCE ET OPTIMISATION DES COÛTS

### 5.1 Licences

| Plan actuel | Utilisateurs | Coût mensuel | Licences inutilisées |
|---|---|---|---|
| [Microsoft 365 Business Premium] | [N] | [X$] | [N] |
| [Plan] | [N] | [X$] | [N] |
| **Total licences** | | **[X$]** | **[N]** |

**Économies potentielles :** [X$ — description des licences redondantes ou sous-utilisées]

### 5.2 Opportunités d'optimisation

- [Ex : X licences non assignées depuis >90 jours — récupération possible]
- [Ex : Plan E3 vs Business Premium — analyse si upgrade justifié]
- [Ex : Stockage Azure — X Go sur tier Premium pourrait migrer vers Standard]

---

## 6. GOUVERNANCE ET CONFORMITÉ

| Politique | Configurée | Observation |
|---|---|---|
| Politique de rétention (Purview) | ✅ / ❌ | [Durées configurées] |
| DLP (Data Loss Prevention) | ✅ / ❌ | [N politiques] |
| Audit logging activé | ✅ / ❌ | [Rétention : X jours] |
| RGPD / PIPEDA — conformité cloud | ✅ / ⚠️ / ❌ | [Observation] |
| Gestion des appareils (Intune) | ✅ / ❌ | [N appareils / politique] |

---

## 7. RECOMMANDATIONS PRIORITAIRES

| # | Recommandation | Impact | Effort | Priorité | Échéance |
|---|---|---|---|---|---|
| R-01 | [Description] | [Sécurité / Coût / Performance] | [Faible / Moyen / Élevé] | 🔴 Haute | [DATE] |
| R-02 | [Description] | [Impact] | [Effort] | 🟡 Moyenne | [DATE] |
| R-03 | [Description] | [Impact] | [Effort] | 🟠 Basse | [DATE] |

---

## 8. FEUILLE DE ROUTE CLOUD — 12 MOIS

| Trimestre | Initiative | Objectif | Budget estimé |
|---|---|---|---|
| Q[N] | [Initiative] | [Objectif] | [X$ ou À définir] |
| Q[N+1] | [Initiative] | [Objectif] | [X$ ou À définir] |
| Q[N+2] | [Initiative] | [Objectif] | [X$ ou À définir] |
| Q[N+3] | [Initiative] | [Objectif] | [X$ ou À définir] |

---

## 9. DÉCISIONS REQUISES

- [ ] [Ex : Approuver déploiement Intune — N appareils — avant [DATE]]
- [ ] [Ex : Confirmer budget pour migration Azure AD P2]
- [ ] [Ex : Valider politique de rétention proposée]

---

*Revue d'architecture cloud préparée par [MSP NAME] — [DATE]*
*Référence : CLOUD-ARCH-[ANNÉE]-[NN]*
*Contact VCIO : [Nom] — [courriel]*
