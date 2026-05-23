# TEMPLATES D'INTERVENTIONS
## TEMPLATE - Azure Health Report

**Date:** [DATE]  
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Période:** [PÉRIODE]  
**Analyste:** [NOM]  
**Tenant:** [NOM TENANT]

---

## 1. RÉSUMÉ EXÉCUTIF

### Santé globale
🟢 **Statut:** Healthy / 🟡 Warning / 🔴 Critical

### Points clés
- [Point important 1]
- [Point important 2]
- [Point important 3]

### Actions recommandées (Top 3)
1. [Action prioritaire 1]
2. [Action prioritaire 2]
3. [Action prioritaire 3]

---

## 2. COMPUTE (Virtual Machines)

### Vue d'ensemble
| Métrique | Valeur | Statut |
|----------|--------|--------|
| VMs totales | [X] | 🟢 |
| VMs en exécution | [X] | 🟢 |
| Utilisation CPU moyenne | [X]% | 🟢/🟡/🔴 |
| Utilisation RAM moyenne | [X]% | 🟢/🟡/🟢 |

### VMs nécessitant attention

#### CPU Over-utilized (>80% avg)
| VM Name | Resource Group | CPU Avg | Recommandation |
|---------|----------------|---------|----------------|
| [vm-name] | [rg-name] | [X]% | Resize to [SKU] |

#### Memory Over-utilized (>85% avg)
| VM Name | Resource Group | RAM Avg | Recommandation |
|---------|----------------|---------|----------------|
| [vm-name] | [rg-name] | [X]% | Resize to [SKU] |

#### Under-utilized (<20% CPU & <30% RAM)
| VM Name | Resource Group | CPU Avg | RAM Avg | Économie potentielle |
|---------|----------------|---------|---------|---------------------|
| [vm-name] | [rg-name] | [X]% | [X]% | [$X/mois] |

### Backup Status
| VM Name | Last Backup | Status | Action |
|---------|-------------|--------|--------|
| [vm-name] | [DATE] | ✓/✗ | [Action si requis] |

### Alertes actives
- [Alerte 1 - Description]
- [Alerte 2 - Description]

---

## 3. STORAGE

### Storage Accounts
| Account | Type | Used | Capacity | % Used | Status |
|---------|------|------|----------|--------|--------|
| [st-name] | [Premium/Standard] | [X GB] | [X GB] | [X]% | 🟢 |

### Blob Storage Tiers
| Hot | Cool | Archive | Recommandation |
|-----|------|---------|----------------|
| [X GB] | [X GB] | [X GB] | Move [X GB] to Cool tier → $[X]/mois savings |

### Disques non attachés
| Disk Name | Size | Type | Coût mensuel | Action |
|-----------|------|------|--------------|--------|
| [disk-name] | [X GB] | Premium SSD | $[X] | Delete/Archive |

**Économies potentielles:** $[X]/mois en supprimant disques orphelins

---

## 4. NETWORKING

### VNets et Peerings
| VNet | Address Space | Subnets | Peerings | Status |
|------|---------------|---------|----------|--------|
| [vnet-name] | [[IP_CLIENTE]/16] | [X] | [X] | 🟢 |

### NSG Rules Review
| NSG | Problème | Sévérité | Recommandation |
|-----|----------|----------|----------------|
| [nsg-name] | Any-Any rule found | 🔴 High | Restreindre source/destination |
| [nsg-name] | Port [X] ouvert à 0.0.0.0/0 | 🟡 Medium | Limiter par IP |

### Load Balancers Health
| LB Name | Backend Pools | Health Probes | Status |
|---------|---------------|---------------|--------|
| [lb-name] | [X] | [X/X healthy] | 🟢 |

### Public IPs non utilisées
| IP Name | Associated To | Action |
|---------|---------------|--------|
| [ip-name] | None | Delete → $[X]/mois savings |

---

## 5. SÉCURITÉ

### Azure Security Center Score
**Score actuel:** [X]/100

### Recommandations critiques
| Recommandation | Ressources affectées | Impact |
|----------------|---------------------|--------|
| [Recommandation 1] | [X] | High |
| [Recommandation 2] | [X] | Medium |

### Compliance Status
| Standard | Conformité | Actions requises |
|----------|------------|------------------|
| CIS Azure Benchmark | [X]% | [X] contrôles à corriger |
| ISO 27001 | [X]% | [X] contrôles à corriger |

### Vulnerabilities détectées
| Sévérité | Count | Exemple |
|----------|-------|---------|
| Critical | [X] | [CVE-XXXX sur vm-prod-01] |
| High | [X] | |
| Medium | [X] | |

### MFA Status (Azure AD)
| Total Users | MFA Enabled | % | Status |
|-------------|-------------|---|--------|
| [X] | [X] | [X]% | 🟢 (>95%) / 🟡 (80-95%) / 🔴 (<80%) |

---

## 6. COÛTS & OPTIMISATION

### Dépenses mensuelles
| Catégorie | Mois précédent | Mois actuel | Tendance |
|-----------|----------------|-------------|----------|
| Compute | $[X] | $[X] | ↗ ↘ → |
| Storage | $[X] | $[X] | ↗ ↘ → |
| Networking | $[X] | $[X] | ↗ ↘ → |
| **TOTAL** | **$[X]** | **$[X]** | **↗ ↘ →** |

### Top 5 ressources coûteuses
| Ressource | Type | Coût mensuel | Optimisation possible |
|-----------|------|--------------|---------------------|
| [resource-1] | VM | $[X] | Downsize → $[X] savings |
| [resource-2] | Storage | $[X] | Tier adjustment → $[X] savings |

### Économies identifiées

#### Immediate (Quick wins)
- Supprimer [X] disques non attachés → $[X]/mois
- Supprimer [X] IPs non utilisées → $[X]/mois
- **Total quick wins:** $[X]/mois

#### Short-term (1-3 mois)
- Resize [X] VMs over/under-utilized → $[X]/mois
- Acheter Reserved Instances pour [X] VMs → $[X]/mois (économie 30-40%)
- Migrer [X GB] vers Cool/Archive tier → $[X]/mois
- **Total short-term:** $[X]/mois

**Économies totales potentielles:** $[X]/mois ($[X]/an)

### Reserved Instances Opportunities
| VM SKU | Qty Running | RI Coverage | Économie potentielle (1yr) |
|--------|-------------|-------------|--------------------------|
| Standard_D2s_v3 | [X] | [X]% | $[X] |
| Standard_D4s_v3 | [X] | [X]% | $[X] |

---

## 7. DISPONIBILITÉ & PERFORMANCE

### SLA Status
| Service | Target SLA | Actual | Status |
|---------|-----------|--------|--------|
| VMs (Availability Set) | 99.95% | [X]% | 🟢/🟡/🔴 |
| Storage | 99.9% | [X]% | 🟢 |

### Incidents récents
| Date | Service | Impact | Durée | RCA |
|------|---------|--------|-------|-----|
| [DATE] | [Service] | [High/Med/Low] | [Xh] | [Lien/Résumé] |

### Maintenance planifiée
| Date | Service | Impact attendu | Action requise |
|------|---------|----------------|----------------|
| [DATE] | [Service] | [Description] | [Action] |

---

## 8. BACKUP & DISASTER RECOVERY

### Backup Compliance
| Total Protected Items | Last 24h Success | Failures | Status |
|---------------------|------------------|----------|--------|
| [X] VMs | [X] | [X] | 🟢/🟡/🔴 |
| [X] Databases | [X] | [X] | 🟢/🟡/🔴 |

### Backup Failures (si applicable)
| Item | Last Attempt | Error | Action |
|------|--------------|-------|--------|
| [vm-name] | [DATE] | [Error msg] | [Action] |

### DR Readiness
| Component | Status | Last Test | Next Test |
|-----------|--------|-----------|-----------|
| Failover plan | ✓ Documented | [DATE] | [DATE] |
| Test failover | ⚠ Overdue | [DATE] | **ASAP** |

---

## 9. RECOMMENDATIONS

### Priorité HAUTE (Immediate action)
1. **[Titre recommandation 1]**
   - Impact: [Security/Cost/Performance]
   - Effort: [Low/Medium/High]
   - Bénéfice: [Description]
   - Action: [Steps précis]

2. **[Titre recommandation 2]**
   - Impact: [Security/Cost/Performance]
   - Effort: [Low/Medium/High]
   - Bénéfice: [Description]
   - Action: [Steps précis]

### Priorité MOYENNE (1-3 mois)
1. [Recommandation]
2. [Recommandation]

### Priorité BASSE (Nice to have)
1. [Recommandation]
2. [Recommandation]

---

## 10. ACTIONS & FOLLOW-UP

### Actions assignées
| # | Action | Propriétaire | Échéance | Status |
|---|--------|-------------|----------|--------|
| 1 | [Action] | [Nom] | [DATE] | 🔄 En cours |
| 2 | [Action] | [Nom] | [DATE] | ⏳ Planifié |

### Prochaine revue
**Date:** [DATE]  
**Focus:** [Thèmes à approfondir]

---

## ANNEXES

### A. Méthodologie
- Période analysée: [DATE DÉBUT] → [DATE FIN]
- Outils utilisés: Azure Portal, Azure Monitor, Azure Advisor, Cost Management
- Metrics collectées: CPU, Memory, Disk, Network (avg 30 jours)

### B. Contacts
- **Azure Admin:** [Nom] - [Email]
- **Security Lead:** [Nom] - [Email]
- **FinOps:** [Nom] - [Email]

### C. Références
- Azure Advisor recommendations: [Lien]
- Cost Management dashboard: [Lien]
- Security Center: [Lien]

---

**Rapport généré le:** [DATE/TIME]  
**Prochain rapport:** [DATE]

# TEMPLATE - Health Check

**Agent:** IT-TicketScribe  
**Rôle:** MAINTENANCE  
**Date:** 2024-02-14

---

## Patching

Ce document fournit les procédures et références essentielles pour IT-MaintenanceMaster

## Procédures

### 1. Procédure standard

**Objectif:** [Décrire l'objectif]

**Étapes:**
1. Vérifier les pré-requis
2. Exécuter l'action principale
3. Valider le résultat
4. Documenter dans ConnectWise

### 2. Cas d'usage courants

#### Scénario A
**Situation:** [Description]  
**Action:** [Steps]  
**Résultat attendu:** [Expected outcome]

#### Scénario B
**Situation:** [Description]  
**Action:** [Steps]  
**Résultat attendu:** [Expected outcome]

## Checklist

- [ ] Pré-requis validés
- [ ] Configuration vérifiée
- [ ] Tests effectués
- [ ] Documentation mise à jour
- [ ] Client informé (si applicable)

## Commandes utiles

```powershell
# PowerShell examples
Get-Service | Where Status -eq 'Running'
Get-EventLog -LogName System -Newest 50
```

```bash
# Bash examples  
systemctl status servicename
tail -f /var/log/syslog
```

## Références

### Documentation interne
- Knowledge Base: [Lien]
- Runbooks: [Lien]
- Standards: [Lien]

### Documentation externe
- Vendor documentation
- Microsoft Docs
- Community forums

## Troubleshooting

### Problème courant 1
**Symptômes:** [Description]  
**Cause:** [Root cause]  
**Solution:** [Fix]

### Problème courant 2
**Symptômes:** [Description]  
**Cause:** [Root cause]  
**Solution:** [Fix]

## Notes

- Important: [Note importante]
- Attention: [Point d'attention]
- Best practice: [Recommandation]

---
# RUNBOOK - Patching Process

**Agent:** IT-MaintenanceMaster  
**Rôle:** MAINTENANCE  
**Date:** 2024-02-14

---

## Vue d'ensemble

Ce document fournit les procédures et références essentielles pour IT-MaintenanceMaster.

## Procédures

### 1. Procédure standard

**Objectif:** [Décrire l'objectif]

**Étapes:**
1. Vérifier les pré-requis
2. Exécuter l'action principale
3. Valider le résultat
4. Documenter dans ConnectWise

### 2. Cas d'usage courants

#### Scénario A
**Situation:** [Description]  
**Action:** [Steps]  
**Résultat attendu:** [Expected outcome]

#### Scénario B
**Situation:** [Description]  
**Action:** [Steps]  
**Résultat attendu:** [Expected outcome]

## Checklist

- [ ] Pré-requis validés
- [ ] Configuration vérifiée
- [ ] Tests effectués
- [ ] Documentation mise à jour
- [ ] Client informé (si applicable)

## Commandes utiles

```powershell
# PowerShell examples
Get-Service | Where Status -eq 'Running'
Get-EventLog -LogName System -Newest 50
```

```bash
# Bash examples  
systemctl status servicename
tail -f /var/log/syslog
```

## Références

### Documentation interne
- Knowledge Base: [Lien]
- Runbooks: [Lien]
- Standards: [Lien]

### Documentation externe
- Vendor documentation
- Microsoft Docs
- Community forums

## Troubleshooting

### Problème courant 1
**Symptômes:** [Description]  
**Cause:** [Root cause]  
**Solution:** [Fix]

### Problème courant 2
**Symptômes:** [Description]  
**Cause:** [Root cause]  
**Solution:** [Fix]

## Notes

- Important: [Note importante]
- Attention: [Point d'attention]
- Best practice: [Recommandation]

---

**Dernière mise à jour:** 2024-02-14  
**Prochaine révision:** 2024-03-14
