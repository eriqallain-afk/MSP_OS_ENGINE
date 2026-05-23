# BUNDLE — IT Gouvernance MSP
**ID :** BUNDLE__IT_GOVERNANCE  
**Version :** 1.0 | **Usage :** Direction, CTO, Orchestration  
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Agents consommateurs :** IT-DirecteurGeneral, IT-CTOMaster, IT-OrchestratorMSP, IT-ReportMaster

---

## 1. KPIs OPÉRATIONNELS MSP — DÉFINITIONS ET CIBLES

### KPIs de Service

| KPI | Définition | Cible | Fréquence mesure |
|-----|-----------|-------|-----------------|
| SLA Compliance P1 | % tickets P1 résolus dans délai | ≥ 98% | Mensuelle |
| SLA Compliance P2 | % tickets P2 résolus dans délai | ≥ 95% | Mensuelle |
| SLA Compliance P3/P4 | % tickets P3-P4 résolus dans délai | ≥ 90% | Mensuelle |
| MTTD | Délai moyen détection incident | < 5 min (P1), < 30 min (P2) | Mensuelle |
| MTTR | Délai moyen résolution | < 4h (P1), < 8h (P2) | Mensuelle |
| First Call Resolution | % résolus sans escalade | ≥ 70% | Mensuelle |
| Ticket Reopen Rate | % tickets réouverts | ≤ 5% | Mensuelle |

### KPIs Infrastructure

| KPI | Définition | Cible | Fréquence |
|-----|-----------|-------|----------|
| Uptime infrastructure critique | % disponibilité DC/réseau | ≥ 99.9% | Continue |
| Patch Compliance | % assets patchés dans délai | ≥ 95% | Mensuelle |
| Backup Success Rate | % jobs backup réussis | ≥ 99% | Quotidienne |
| EDR Coverage | % endpoints couverts | 100% | Hebdomadaire |
| License Compliance | % logiciels conformes | ≥ 98% | Trimestrielle |

### KPIs Sécurité

| KPI | Définition | Cible |
|-----|-----------|-------|
| MTTD Security Incident | Délai détection incident sécurité | < 15 min (P1) |
| MFA Coverage | % comptes avec MFA actif | ≥ 98% |
| Vulnérabilités critiques ouvertes | CVEs CVSS ≥ 9.0 non patchées | 0 après 48h |

---

## 2. MATRICE DÉCISIONS DG / CTO

### IT-DirecteurGeneral : Domaine de décision
- Priorisation des budgets IT et investissements
- Approbation des changements majeurs (P1 architecture)
- Communication avec direction client sur incidents majeurs
- Révision SLA et contrats de service
- Go/No-Go pour projets >40h

### IT-CTOMaster : Domaine de décision
- Architectures techniques (cloud, on-prem, hybride)
- Choix de technologies et standards
- Escalade finale sur incidents techniques non résolus
- Validation runbooks et procédures sensibles
- Arbitage technique entre agents spécialistes

---

## 3. PROCESSUS DE CHANGEMENT (RFC Light)

### Catégories de changement :

| Catégorie | Définition | Approbation | Délai planning |
|-----------|-----------|-------------|---------------|
| Standard | Changement pré-approuvé, low risk | IT-MaintenanceMaster | Immédiat |
| Normal | Changement planifié, impact modéré | IT-CTOMaster | ≥ 5 jours ouvrables |
| Urgent | Changement non planifié, P1 actif | IT-CTOMaster (verbal) | Immédiat + documentation |
| Majeur | Architecture, migration, projet | IT-DirecteurGeneral + IT-CTOMaster | ≥ 10 jours |

### Template RFC Light (standard) :
```
Titre : [Changement proposé]
Demandeur : [Agent/Technicien]
Système(s) affecté(s) : 
Date/Heure planifiée : 
Durée estimée : 
Impact service :
Description technique :
Plan de rollback :
Tests post-changement :
Approbateur : 
```

---

## 4. PROCESSUS POSTMORTEM

**Déclencheurs :** Tout incident P1 ou P2 récurrent  
**Délai :** Dans les 5 jours ouvrables post-résolution

### Structure postmortem standard :
1. **Résumé exécutif** (2-3 phrases, non-technique)
2. **Timeline** (chronologie de détection à résolution)
3. **Cause racine** (5 Whys ou Fishbone)
4. **Impact** (durée, utilisateurs, services, SLA)
5. **Ce qui a bien fonctionné**
6. **Ce qui peut être amélioré**
7. **Actions correctives** (avec responsable et échéance)
8. **Actions préventives** (avec responsable et échéance)

**Règle non-blame :** Postmortem = apprentissage, pas punition

---

## 5. GOUVERNANCE KNOWLEDGE BASE

### Cycle de vie KB :
1. **Création** : IT-KnowledgeKeeper après chaque ticket P1/P2 résolu ou N3 complexe
2. **Review** : IT-CTOMaster pour articles techniques critiques
3. **Validation** : IT-MaintenanceMaster pour procédures maintenance
4. **Publication** : dans ConnectWise KB + IT_SHARED/Knowledge/
5. **Révision** : annuelle ou si changement technologique

### Catégories KB MSP :
- `HowTo/` — procédures step-by-step
- `Troubleshooting/` — arbres de décision diagnostic
- `Reference/` — commandes, paramètres, configurations
- `Runbooks/` — procédures opérationnelles
- `Templates/` — modèles réutilisables

---

## 6. VERSIONING POLICY (IT_SHARED)

Format version : `MAJOR.MINOR.PATCH`
- **MAJOR** : changement architectural, refonte complète
- **MINOR** : nouvelle fonctionnalité, nouveau runbook
- **PATCH** : correction, mise à jour mineure

Tout fichier partagé doit inclure en en-tête :
```
Version: X.Y.Z
Dernière mise à jour: YYYY-MM-DD
Auteur: @[Agent]
Statut: [Draft|Review|Approved|Deprecated]
```
