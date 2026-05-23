# TEMPLATE: Cloud Health Report

## Informations du rapport

| Champ | Valeur |
|-------|--------|
| **Client** | [Nom du client] |
| **Période couverte** | [Date début] - [Date fin] |
| **Plateformes analysées** | ☐ Azure  ☐ M365  ☐ Google Workspace  ☐ AWS |
| **Date du rapport** | [Date génération] |
| **Préparé par** | IT-CloudMaster |
| **Version** | 1.0 |

---

## 📊 Résumé exécutif

### Vue d'ensemble
[Paragraphe de 3-4 phrases résumant l'état général de l'environnement cloud, les principales découvertes, et les actions recommandées.]

### Indicateurs clés

| Métrique | Valeur | Tendance | Objectif | Statut |
|----------|--------|----------|----------|--------|
| **Score de santé global** | [X]% | [↗/→/↘] | >90% | [🟢/🟡/🔴] |
| **Disponibilité (uptime)** | [X]% | [↗/→/↘] | >99.9% | [🟢/🟡/🔴] |
| **Conformité sécurité** | [X]% | [↗/→/↘] | 100% | [🟢/🟡/🔴] |
| **Utilisation licences** | [X]% | [↗/→/↘] | 85-95% | [🟢/🟡/🔴] |
| **Coût mensuel** | [X]$ | [↗/→/↘] | [Budget] | [🟢/🟡/🔴] |

**Légende:** 🟢 Bon | 🟡 Attention | 🔴 Critique

---

## 1️⃣ Azure

### 1.1 Vue d'ensemble infrastructure

#### Ressources déployées
| Type de ressource | Quantité | Coût mensuel | Variation |
|-------------------|----------|--------------|-----------|
| Virtual Machines | [X] | [X]$ | [±X]% |
| Storage Accounts | [X] | [X]$ | [±X]% |
| SQL Databases | [X] | [X]$ | [±X]% |
| App Services | [X] | [X]$ | [±X]% |
| Virtual Networks | [X] | [X]$ | [±X]% |
| **Total** | **[X]** | **[X]$** | **[±X]%** |

#### Performance et disponibilité
```
🟢 Uptime global: 99.98%
🟢 Temps réponse moyen: 45ms
🟡 Incidents: 2 (Sev 3)
🟢 Changements planifiés: 5 (100% réussis)
```

### 1.2 Sécurité et conformité

#### Azure Security Center - Secure Score
**Score actuel:** [X]/100 (Variation: [±X] points)

**Recommandations critiques:**
1. ⚠️ [Nombre] VMs sans patch récents
2. ⚠️ [Nombre] Storage accounts sans encryption at rest
3. ⚠️ [Nombre] NSG avec règles trop permissives

**Actions correctives:**
- [ ] Activer Update Management sur toutes VMs
- [ ] Forcer HTTPS sur tous Storage Accounts
- [ ] Revoir règles NSG et appliquer principe du moindre privilège

#### Conformité
| Standard | Statut | Score | Écarts |
|----------|--------|-------|--------|
| CIS Azure Benchmark | [🟢/🟡/🔴] | [X]% | [X] |
| ISO 27001 | [🟢/🟡/🔴] | [X]% | [X] |
| SOC 2 | [🟢/🟡/🔴] | [X]% | [X] |

### 1.3 Optimisation des coûts

#### Top 5 ressources par coût
1. **[Resource Name]** - [Type] - [X]$/mois - [Recommandation]
2. **[Resource Name]** - [Type] - [X]$/mois - [Recommandation]
3. **[Resource Name]** - [Type] - [X]$/mois - [Recommandation]
4. **[Resource Name]** - [Type] - [X]$/mois - [Recommandation]
5. **[Resource Name]** - [Type] - [X]$/mois - [Recommandation]

#### Opportunités d'économies
| Opportunité | Économie estimée | Effort | Priorité |
|-------------|------------------|--------|----------|
| Réserver VMs (1 an) | [X]$/mois ([X]%) | Faible | Haute |
| Resize under-utilized VMs | [X]$/mois ([X]%) | Moyen | Moyenne |
| Supprimer snapshots orphelins | [X]$/mois ([X]%) | Faible | Haute |
| Migrer vers Managed Disks | [X]$/mois ([X]%) | Élevé | Faible |

**Économies totales potentielles:** [X]$/mois ([X]% du budget actuel)

---

## 2️⃣ Microsoft 365

### 2.1 Licences et utilisation

#### Distribution des licences
| Type licence | Assignées | Utilisées | Disponibles | Taux d'utilisation |
|--------------|-----------|-----------|-------------|-------------------|
| M365 E3 | [X] | [X] | [X] | [X]% |
| M365 E5 | [X] | [X] | [X] | [X]% |
| M365 Business | [X] | [X] | [X] | [X]% |
| **Total** | **[X]** | **[X]** | **[X]** | **[X]%** |

**💡 Recommandation:** [Analyser si besoin d'acheter plus / réduire / redistribuer licences]

#### Services activés
```
✓ Exchange Online: [X] utilisateurs actifs
✓ SharePoint Online: [X] sites, [X] TB stockés
✓ OneDrive: [X] utilisateurs, [X] TB stockés
✓ Microsoft Teams: [X] équipes actives, [X] réunions/mois
✓ Yammer: [X] utilisateurs actifs
```

### 2.2 Sécurité Microsoft 365

#### Microsoft Secure Score
**Score actuel:** [X]/100 (Variation: [±X] points)

**Top 5 recommandations:**
1. 🔴 [Impact: +X points] - [Description recommandation]
2. 🟡 [Impact: +X points] - [Description recommandation]
3. 🟡 [Impact: +X points] - [Description recommandation]
4. 🟢 [Impact: +X points] - [Description recommandation]
5. 🟢 [Impact: +X points] - [Description recommandation]

#### Authentification et accès
| Métrique | Valeur | Cible |
|----------|--------|-------|
| Utilisateurs avec MFA | [X]% | 100% |
| Conditional Access policies | [X] actives | [X] recommandées |
| Comptes admin protégés | [X]% | 100% |
| Sign-ins risqués bloqués | [X] ce mois | Minimiser |

### 2.3 Conformité et gouvernance

#### Data Loss Prevention (DLP)
```
Politiques actives: [X]
Incidents détectés: [X]
Faux positifs: [X]
Actions automatiques: [X]
```

**Incidents notables:**
- [Date] - [Type] - [Description] - [Action prise]

#### Retention et eDiscovery
```
Politiques de rétention: [X] actives
Holds légaux: [X]
Recherches eDiscovery: [X] ce mois
Volume sous hold: [X] GB
```

### 2.4 Collaboration et productivité

#### Microsoft Teams
| Métrique | Ce mois | Mois précédent | Variation |
|----------|---------|----------------|-----------|
| Équipes actives | [X] | [X] | [±X]% |
| Canaux créés | [X] | [X] | [±X]% |
| Messages envoyés | [X]K | [X]K | [±X]% |
| Réunions tenues | [X] | [X] | [±X]% |
| Participants uniques | [X] | [X] | [±X]% |

**Tendance:** [↗ Adoption croissante / → Stable / ↘ En baisse]

#### SharePoint et OneDrive
```
Sites SharePoint: [X] (+[X] ce mois)
Stockage total: [X] TB / [X] TB ([X]% utilisé)
Fichiers partagés externes: [X] (tendance: [↗/→/↘])
OneDrive actifs: [X] utilisateurs ([X]% de la base)
```

---

## 3️⃣ Google Workspace

### 3.1 Licences et services

#### Distribution des licences
| Plan | Utilisateurs | Coût mensuel | Utilisation |
|------|--------------|--------------|-------------|
| Business Starter | [X] | [X]$ | [X]% |
| Business Standard | [X] | [X]$ | [X]% |
| Business Plus | [X] | [X]$ | [X]% |
| Enterprise | [X] | [X]$ | [X]% |
| **Total** | **[X]** | **[X]$** | **[X]%** |

### 3.2 Sécurité et administration

#### Rapports de sécurité
```
🟢 Validation en 2 étapes: [X]% des utilisateurs
🟡 Applications tierces autorisées: [X]
🟢 Alertes de sécurité: [X] ce mois
🟢 Comptes suspendus: [X]
```

#### Stockage Drive
```
Quota total: [X] TB
Utilisé: [X] TB ([X]%)
Top 5 utilisateurs:
  1. [user@domain] - [X] GB
  2. [user@domain] - [X] GB
  3. [user@domain] - [X] GB
  4. [user@domain] - [X] GB
  5. [user@domain] - [X] GB
```

---

## 4️⃣ AWS

### 4.1 Infrastructure et services

#### Services principaux
| Service | Ressources | Coût mensuel | Utilisation |
|---------|------------|--------------|-------------|
| EC2 | [X] instances | [X]$ | [X]% CPU avg |
| S3 | [X] buckets, [X] TB | [X]$ | [X] TB/mo transfer |
| RDS | [X] instances | [X]$ | [X]% connections |
| Lambda | [X] functions | [X]$ | [X]M invocations |
| **Total** | - | **[X]$** | - |

### 4.2 Sécurité AWS

#### AWS Security Hub
**Score de sécurité:** [X]/100

**Findings critiques:**
- 🔴 [Nombre] High severity findings
- 🟡 [Nombre] Medium severity findings
- 🟢 [Nombre] Low severity findings

**Top issues:**
1. [Description issue] - [Impact] - [Remediation]
2. [Description issue] - [Impact] - [Remediation]
3. [Description issue] - [Impact] - [Remediation]

#### IAM Best Practices
```
✓ Root account MFA: [Activé/Désactivé]
✓ IAM users avec MFA: [X]%
✓ Access keys rotated (<90 jours): [X]%
⚠ Policies trop permissives: [X]
✓ Service roles utilisés: [X]
```

---

## 📈 Tendances et analyses

### Évolution des coûts (6 derniers mois)
```
Mois 1: [X]$
Mois 2: [X]$ ([±X]%)
Mois 3: [X]$ ([±X]%)
Mois 4: [X]$ ([±X]%)
Mois 5: [X]$ ([±X]%)
Mois 6: [X]$ ([±X]%)

Tendance: [↗ Hausse / → Stable / ↘ Baisse]
Projection mois prochain: [X]$
```

### Incidents et disponibilité
```
Incidents totaux: [X]
  - Sev 1 (Critique): [X]
  - Sev 2 (Majeur): [X]
  - Sev 3 (Mineur): [X]

MTTR moyen: [X] heures
Uptime global: [X]%

Causes principales:
  1. [Cause] - [X] incidents
  2. [Cause] - [X] incidents
  3. [Cause] - [X] incidents
```

---

## 🎯 Recommandations prioritaires

### Haute priorité (< 30 jours)
1. **[Titre recommandation]**
   - **Impact:** [Description impact business/sécurité/coût]
   - **Effort:** [Faible/Moyen/Élevé] - [X heures]
   - **Économies/Gains:** [X]$/mois ou [Description bénéfice]
   - **Actions:** 
     - [ ] [Action 1]
     - [ ] [Action 2]
     - [ ] [Action 3]

2. **[Titre recommandation]**
   - **Impact:** [Description]
   - **Effort:** [Niveau]
   - **Économies/Gains:** [Montant]
   - **Actions:** [Liste]

### Moyenne priorité (30-90 jours)
1. **[Titre]** - [Description brève] - Impact: [X]
2. **[Titre]** - [Description brève] - Impact: [X]
3. **[Titre]** - [Description brève] - Impact: [X]

### Basse priorité (> 90 jours)
1. **[Titre]** - [Description brève]
2. **[Titre]** - [Description brève]

---

## 📋 Plan d'action

| # | Action | Responsable | Échéance | Statut | Notes |
|---|--------|-------------|----------|--------|-------|
| 1 | [Action] | [Nom] | [Date] | [⏳/✓/✗] | [Notes] |
| 2 | [Action] | [Nom] | [Date] | [⏳/✓/✗] | [Notes] |
| 3 | [Action] | [Nom] | [Date] | [⏳/✓/✗] | [Notes] |
| 4 | [Action] | [Nom] | [Date] | [⏳/✓/✗] | [Notes] |
| 5 | [Action] | [Nom] | [Date] | [⏳/✓/✗] | [Notes] |

---

## 📎 Annexes

### A. Méthodologie
[Description de la méthodologie utilisée pour collecter les données, analyser l'environnement, et générer les recommandations]

### B. Outils utilisés
- Azure Monitor & Log Analytics
- Microsoft 365 Admin Center & Secure Score
- Google Workspace Admin Reports
- AWS CloudWatch & Security Hub
- Scripts PowerShell / Azure CLI / AWS CLI personnalisés

### C. Glossaire
| Terme | Définition |
|-------|------------|
| MTTR | Mean Time To Resolution - Temps moyen de résolution |
| Secure Score | Score de sécurité Microsoft (0-100) |
| DLP | Data Loss Prevention - Prévention de perte de données |
| NSG | Network Security Group - Groupe de sécurité réseau |
| IAM | Identity and Access Management |

### D. Contacts
| Rôle | Nom | Email | Téléphone |
|------|-----|-------|-----------|
| Cloud Architect | [Nom] | [Email] | [Tél] |
| Security Lead | [Nom] | [Email] | [Tél] |
| Support IT | [Équipe] | [Email] | [Tél] |

---

## 📝 Notes de fin de rapport

**Prochain rapport:** [Date]  
**Fréquence:** [Mensuel/Trimestriel]  
**Feedback:** [Email pour commentaires]

---

*Rapport généré par IT-CloudMaster le [Date]*  
*Version du template: 1.0*  
*Confidentiel - Usage interne uniquement*
