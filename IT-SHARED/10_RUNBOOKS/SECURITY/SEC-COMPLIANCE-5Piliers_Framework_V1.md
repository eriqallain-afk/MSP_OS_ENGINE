# SEC-COMPLIANCE-5Piliers_Framework_V1
**Version :** 1.0 | **Date :** 2026-05-22 | **Statut :** ACTIF
**Agents :** @IT-ComplianceMaster | @IT-SecurityMaster | @IT-ReportMaster
**Département :** SEC | **Source :** IT MSP Intelligence Platform

---

## OBJECTIF

Framework de scoring de maturité sécurité MSP en 5 piliers.
Produit un score global pondéré dynamique — utilisable pour l'audit initial, le suivi trimestriel et le rapport exécutif client.

---

## LES 5 PILIERS

| # | Pilier | Description | Poids défaut |
|---|---|---|---|
| P1 | **Lifecycle Risk** | EOL matériel/logiciel, versioning, protocoles dépréciés | 15% |
| P2 | **Governance Integrity** | Tier-0, segmentation, accès privilégiés, CA policies | 25% |
| P3 | **Continuity Assurance** | Backup, SPOF, break-glass, rétention | 20% |
| P4 | **Exposure Surface** | MFA, firewall, DLP, partage externe, surface d'attaque | 25% |
| P5 | **Operational Drift** | Patching, config drift, Secure Score, comptes inactifs | 15% |

> **Poids ajustables par framework réglementaire :**
> - Loi 25 → P2+P4 augmentés (données personnelles, accès)
> - PCI-DSS → P4+P5 augmentés (surface d'attaque, drift)
> - Cyber-assurance → P3+P4 augmentés (continuité, exposition)
> - SOC 2 → tous les piliers équilibrés

---

## CRITÈRES DE SCORING PAR PILIER

### P1 — Lifecycle Risk (EOL, versioning)

| Critère | Score max | Source de données |
|---|---|---|
| Aucun OS/serveur EOL en production | 25 | CMDB / RMM |
| Authentification legacy (Basic Auth) désactivée | 20 | Entra ID / Exchange |
| Protocoles dépréciés absents (TLS 1.0/1.1, SSLv3) | 20 | Scan réseau / IIS |
| Logiciels tiers à jour (navigateurs, Office, agents) | 20 | RMM patch status |
| APIs dépréciées non utilisées (Azure AD Graph) | 15 | Entra app registrations |
| **TOTAL P1** | **100** | |

### P2 — Governance Integrity (Tier-0, segmentation)

| Critère | Score max | Source de données |
|---|---|---|
| Comptes admin dédiés (non utilisés au quotidien) | 25 | Entra ID / AD |
| PIM activé pour les rôles privilégiés | 20 | Entra ID PIM |
| Conditional Access couvre 100% des admins | 20 | Entra CA policies |
| Comptes invités (guests) gouvernés et revus | 15 | Entra Access Reviews |
| Segmentation réseau / VLAN documentée | 10 | CMDB / Hudu |
| MFA résistante au phishing (FIDO2/passkey) pour Tier-0 | 10 | Entra ID |
| **TOTAL P2** | **100** | |

### P3 — Continuity Assurance (backup, SPOF)

| Critère | Score max | Source de données |
|---|---|---|
| Backup testé et validé (restore test <90 jours) | 30 | Runbook [39b] |
| Aucun SPOF critique non documenté | 20 | CMDB / Hudu |
| Comptes break-glass configurés et testés | 20 | Entra ID |
| SSPR (self-service password reset) opérationnel | 15 | Entra ID |
| Politiques de rétention Purview actives | 15 | Purview Compliance |
| **TOTAL P3** | **100** | |

### P4 — Exposure Surface (WAN, MFA, firewall)

| Critère | Score max | Source de données |
|---|---|---|
| MFA enforced pour 100% des utilisateurs | 25 | Entra ID / CA |
| Entra ID Identity Protection — risk policies actives | 20 | Entra ID Protection |
| DLP policies actives et couvrant Exchange/SP/OD | 20 | Purview DLP |
| Authentification legacy bloquée (CA policy) | 15 | Entra CA |
| Partage externe SharePoint/OneDrive gouverné | 10 | Purview / SPO |
| Sensitivity labels déployées et adoptées | 10 | Purview |
| **TOTAL P4** | **100** | |

### P5 — Operational Drift (patch, config inconsistency)

| Critère | Score max | Source de données |
|---|---|---|
| Secure Score > 70% (ou progression +10pts/trimestre) | 25 | Microsoft Secure Score |
| Comptes inactifs >90 jours désactivés ou supprimés | 25 | Entra ID / AD |
| App registrations orphelines nettoyées | 20 | Entra ID |
| Alertes DLP non résolues < 5 ouvertes | 15 | Purview |
| Rôles privilégiés permanents minimisés (<5) | 15 | Entra ID PIM |
| **TOTAL P5** | **100** | |

---

## CALCUL DU SCORE GLOBAL

```
Score Global = (P1 × W1) + (P2 × W2) + (P3 × W3) + (P4 × W4) + (P5 × W5)

Défaut : (P1 × 0.15) + (P2 × 0.25) + (P3 × 0.20) + (P4 × 0.25) + (P5 × 0.15)
```

### Script de calcul

```powershell
# Calcul score pondéré 5 piliers
# Remplacer les valeurs par les scores obtenus

$scores = [ordered]@{
    P1_LifecycleRisk      = [int](Read-Host "Score P1 — Lifecycle Risk (0-100)")
    P2_GovernanceIntegrity = [int](Read-Host "Score P2 — Governance Integrity (0-100)")
    P3_ContinuityAssurance = [int](Read-Host "Score P3 — Continuity Assurance (0-100)")
    P4_ExposureSurface     = [int](Read-Host "Score P4 — Exposure Surface (0-100)")
    P5_OperationalDrift    = [int](Read-Host "Score P5 — Operational Drift (0-100)")
}

# Poids par défaut (ajustables)
$weights = [ordered]@{
    P1 = 0.15
    P2 = 0.25
    P3 = 0.20
    P4 = 0.25
    P5 = 0.15
}

$global = [math]::Round(
    ($scores.P1_LifecycleRisk       * $weights.P1) +
    ($scores.P2_GovernanceIntegrity * $weights.P2) +
    ($scores.P3_ContinuityAssurance * $weights.P3) +
    ($scores.P4_ExposureSurface     * $weights.P4) +
    ($scores.P5_OperationalDrift    * $weights.P5), 1)

Write-Output "=== RÉSULTAT SCORING 5 PILIERS ==="
$scores.GetEnumerator() | ForEach-Object {
    $rag = if ($_.Value -ge 75) { "🟢" } elseif ($_.Value -ge 50) { "🟡" } else { "🔴" }
    Write-Output "  $rag $($_.Key) : $($_.Value)/100"
}
Write-Output ""
Write-Output "  SCORE GLOBAL : $global/100 $(if ($global -ge 75) { '🟢 BON' } elseif ($global -ge 50) { '🟡 ACCEPTABLE' } else { '🔴 CRITIQUE' })"
```

---

## NIVEAUX DE MATURITÉ

| Score | Niveau | Signification |
|---|---|---|
| 85–100 | 🟢 **Mature** | Posture sécurité solide, surveillance continue |
| 70–84 | 🟢 **Bon** | Quelques lacunes mineures, plan de remédiation léger |
| 50–69 | 🟡 **Acceptable** | Lacunes identifiées, plan de remédiation requis |
| 30–49 | 🔴 **Critique** | Risques significatifs, remédiation prioritaire |
| 0–29 | 🔴 **Dangereux** | Exposition majeure, action immédiate requise |

---

## RAPPORT VISUEL — GAUGES

Chaque pilier = 1 gauge (screenshot Microsoft ou tableau RAG).
Score global = 1 gauge principale en haut du rapport.

**Sources de gauges Microsoft disponibles :**
- Secure Score → `security.microsoft.com/securescore`
- Compliance Manager → `compliance.microsoft.com/compliancemanager`
- Entra ID Protection → `entra.microsoft.com` → Identity Protection
- Defender Exposure → `security.microsoft.com` → Exposure management

**Pour les piliers sans gauge Microsoft native :**
Utiliser tableau RAG avec score numérique dans le rapport Word.

---

## RUNBOOKS ASSOCIÉS PAR PILIER

| Pilier | Runbook principal |
|---|---|
| P1 Lifecycle Risk | `IT-SHARED/10_RUNBOOKS/OPR/OPR-EOL-EOS-RiskRegister_V1.md` |
| P2 Governance Integrity | `IT-SHARED/10_RUNBOOKS/SECURITY/SEC-ENTRA-SecurityCompliance_V1.md` |
| P3 Continuity Assurance | `IT-SHARED/10_RUNBOOKS/NOC/NOC-BACKUP-Restore_Test_Trimestriel_V1.md` |
| P4 Exposure Surface | `IT-SHARED/10_RUNBOOKS/SECURITY/SEC-ENTRA-SecurityCompliance_V1.md` + `SEC-PURVIEW-ComplianceAudit_V1.md` |
| P5 Operational Drift | `IT-SHARED/10_RUNBOOKS/SECURITY/SEC-PURVIEW-ComplianceAudit_V1.md` + `MAINT-WIN-PendingReboot_V2.md` |

---

## HANDOFF_BLOCK — IT-ReportMaster

```text
HANDOFF_BLOCK — Scoring 5 Piliers
CLIENT        : [À COMPLÉTER]
PÉRIODE       : [Q1/Q2/Q3/Q4]-[ANNÉE]
FRAMEWORK     : [Loi 25 / PCI / SOC2 / Cyber-assurance / Défaut]
AUDITEUR      : [Nom technicien]

SCORES :
P1 Lifecycle Risk       : [XX]/100 🟢🟡🔴
P2 Governance Integrity : [XX]/100 🟢🟡🔴
P3 Continuity Assurance : [XX]/100 🟢🟡🔴
P4 Exposure Surface     : [XX]/100 🟢🟡🔴
P5 Operational Drift    : [XX]/100 🟢🟡🔴
SCORE GLOBAL            : [XX]/100 🟢🟡🔴

TOP 3 LACUNES CRITIQUES :
1. [lacune] — Pilier [Px] — Effort [faible/moyen/élevé]
2. [lacune] — Pilier [Px] — Effort [faible/moyen/élevé]
3. [lacune] — Pilier [Px] — Effort [faible/moyen/élevé]

GAINS RAPIDES (quick wins) :
- [action] → +[X] pts sur P[x]

PROCHAINE REVUE : [date]
```

*SEC-COMPLIANCE-5Piliers_Framework_V1 — 2026-05-22*
