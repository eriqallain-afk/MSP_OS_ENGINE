# SEC-PURVIEW-ComplianceAudit_V1
**Version :** 1.0 | **Date :** 2026-05-22 | **Statut :** ACTIF
**Agents :** @IT-ComplianceMaster | @IT-SecurityMaster | @IT-CloudMaster
**Département :** SEC | **Source :** IT MSP Intelligence Platform
**Piliers couverts :** P3 (partiel) · P4 · P5

---

## OBJECTIF

Audit de la posture conformité Microsoft Purview — DLP, sensitivity labels, rétention, Compliance Manager, Insider Risk, partage externe.

## PRÉREQUIS

```
[ ] Rôle Compliance Administrator ou Compliance Data Administrator
[ ] Module ExchangeOnlineManagement installé
[ ] Connect-IPPSSession ou Connect-ExchangeOnline exécuté
[ ] Accès compliance.microsoft.com confirmé
[ ] Billet CW ouvert avec autorisation client
```

---

## SECTION 1 — CONNEXION PURVIEW / COMPLIANCE

```powershell
#Requires -Version 5.1
# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== CONNEXION PURVIEW / COMPLIANCE ==="
try {
    # Exchange Online Management (inclut Security & Compliance)
    Import-Module ExchangeOnlineManagement -EA Stop
    Connect-IPPSSession -EA Stop
    Write-Output "Connexion IPPS réussie ✓"
} catch {
    Write-Output "Erreur connexion IPPS : $_"
    Write-Output "Installer : Install-Module ExchangeOnlineManagement -Force"
    exit 1
}
```

---

## SECTION 2 — SCRIPT AUDIT PURVIEW COMPLET

```powershell
#Requires -Version 5.1
# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)
# Prérequis : Connect-IPPSSession déjà exécuté + Connect-MgGraph (pour SPO)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== P4 — POLITIQUES DLP ==="
try {
    $dlpPolicies = Get-DlpCompliancePolicy -EA Stop
    Write-Output "Politiques DLP total : $($dlpPolicies.Count)"
    $dlpPolicies | Select-Object Name, Mode, Enabled,
        @{N="Workloads";E={ $_.Workload -join ',' }},
        @{N="Priority";E={ $_.Priority }} |
        Sort-Object Priority | Out-String -Width 300 | Write-Output

    $enabledDLP = ($dlpPolicies | Where-Object { $_.Enabled -eq $true -and $_.Mode -eq 'Enable' }).Count
    Write-Output "DLP actives en mode Enforce : $enabledDLP / $($dlpPolicies.Count)"

    # Couvrent-elles Exchange, SharePoint, OneDrive, Teams ?
    $coverage = [ordered]@{ Exchange=0; SharePoint=0; OneDrive=0; Teams=0 }
    foreach ($p in $dlpPolicies | Where-Object { $_.Enabled }) {
        if ($p.Workload -match 'Exchange') { $coverage.Exchange++ }
        if ($p.Workload -match 'SharePoint') { $coverage.SharePoint++ }
        if ($p.Workload -match 'OneDrive') { $coverage.OneDrive++ }
        if ($p.Workload -match 'Teams') { $coverage.Teams++ }
    }
    Write-Output "Couverture workloads (nb policies) :"
    $coverage.GetEnumerator() | ForEach-Object {
        $flag = if ($_.Value -gt 0) { "✓" } else { "⛔ ABSENT" }
        Write-Output "  $flag $($_.Key) : $($_.Value) policy(ies)"
    }
} catch { Write-Output "Erreur DLP policies : $_" }

Write-Output ""
Write-Output "=== P4 — ALERTES DLP RÉCENTES ==="
try {
    $dlpAlerts = Get-DlpComplianceRule -EA SilentlyContinue
    Write-Output "Règles DLP actives : $($dlpAlerts.Count)"

    # Incidents DLP (via audit log)
    Write-Output "Incidents DLP (7 derniers jours) :"
    Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) `
        -RecordType ComplianceDLPExchange,ComplianceDLPSharePoint `
        -ResultSize 50 -EA SilentlyContinue |
        Select-Object CreationDate, UserIds, Operations, ResultStatus |
        Out-String -Width 300 | Write-Output
} catch { Write-Output "Erreur alertes DLP : $_" }

Write-Output ""
Write-Output "=== P4 — SENSITIVITY LABELS ==="
try {
    $labels = Get-Label -EA Stop
    Write-Output "Sensitivity labels créées : $($labels.Count)"
    $labels | Select-Object Name, Priority, ContentType,
        @{N="Chiffrement";E={ $_.EncryptionEnabled }},
        @{N="Marquage";E={ $_.ContentMarkingEnabled }} |
        Sort-Object Priority | Out-String -Width 300 | Write-Output

    if ($labels.Count -eq 0) {
        Write-Output "⛔ Aucun sensitivity label — données non classifiées"
    }

    # Politiques de labels publiées
    $labelPolicies = Get-LabelPolicy -EA SilentlyContinue
    Write-Output "Label policies publiées : $($labelPolicies.Count)"
    $labelPolicies | Select-Object Name, @{N="Users";E={($_.ExchangeLocation.Name -join ',')}},
        @{N="Mandatory";E={$_.Settings | Where-Object {$_.Key -eq 'mandatory'} | Select-Object -Expand Value}} |
        Out-String -Width 300 | Write-Output
} catch { Write-Output "Erreur sensitivity labels : $_" }

Write-Output ""
Write-Output "=== P3 — POLITIQUES DE RÉTENTION ==="
try {
    $retPolicies = Get-RetentionCompliancePolicy -EA Stop
    Write-Output "Politiques de rétention : $($retPolicies.Count)"
    $retPolicies | Select-Object Name, Enabled,
        @{N="Workloads";E={$_.Workload -join ','}},
        @{N="Type";E={$_.RetentionAction}} |
        Out-String -Width 300 | Write-Output

    # Couvrent-elles les workloads critiques ?
    $retCoverage = [ordered]@{ Exchange=0; SharePoint=0; OneDrive=0; Teams=0 }
    foreach ($p in $retPolicies | Where-Object { $_.Enabled }) {
        if ($p.Workload -match 'Exchange') { $retCoverage.Exchange++ }
        if ($p.Workload -match 'SharePoint') { $retCoverage.SharePoint++ }
        if ($p.Workload -match 'OneDrive') { $retCoverage.OneDrive++ }
        if ($p.Workload -match 'Teams') { $retCoverage.Teams++ }
    }
    Write-Output "Couverture rétention :"
    $retCoverage.GetEnumerator() | ForEach-Object {
        $flag = if ($_.Value -gt 0) { "✓" } else { "⛔ NON COUVERT" }
        Write-Output "  $flag $($_.Key)"
    }
} catch { Write-Output "Erreur rétention : $_" }

Write-Output ""
Write-Output "=== P4 — PARTAGE EXTERNE SHAREPOINT / ONEDRIVE ==="
try {
    Connect-ExchangeOnline -ShowBanner:$false -EA SilentlyContinue
    # Via Graph pour SPO
    $spoSettings = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/admin/sharepoint/settings" -EA SilentlyContinue
    if ($spoSettings) {
        [pscustomobject]@{
            SharingCapability        = $spoSettings.sharingCapability
            DefaultSharingLinkType   = $spoSettings.defaultSharingLinkType
            RequireAcceptingAccount  = $spoSettings.requireAcceptingAccountMatchInvitedAccount
            ExternalUserExpiration   = $spoSettings.externalUserExpirationRequired
        } | Out-String -Width 300 | Write-Output

        if ($spoSettings.sharingCapability -in 'ExternalUserAndGuestSharing','ExistingExternalUserSharingOnly') {
            Write-Output "⚠️ Partage externe activé — vérifier la gouvernance"
        }
    }
} catch { Write-Output "Vérifier partage externe manuellement : SharePoint Admin Center > Policies > Sharing" }

Write-Output ""
Write-Output "=== P5 — UNIFIED AUDIT LOG ==="
try {
    $orgConfig = Get-OrganizationConfig -EA SilentlyContinue
    if ($orgConfig) {
        $auditEnabled = -not $orgConfig.AuditDisabled
        Write-Output "Unified Audit Log activé : $(if ($auditEnabled) { '✓ OUI' } else { '⛔ NON — CRITIQUE' })"
        Write-Output "Audit de boîte activé par défaut : $($orgConfig.AuditEnabled)"
    }
} catch { Write-Output "Vérifier UAL : compliance.microsoft.com → Audit" }

Write-Output ""
Write-Output "=== P5 — COMPLIANCE MANAGER SCORE ==="
Write-Output "Vérification manuelle requise :"
Write-Output "  → compliance.microsoft.com → Compliance Manager"
Write-Output "  → Voir score par framework (NIST, ISO 27001, SOC2, Loi 25)"
Write-Output "  → Screenshots pour le rapport client"

Write-Output "=== FIN AUDIT PURVIEW ==="
```

---

## SECTION 3 — SCORING P3 / P4 / P5 PURVIEW

```powershell
# Calculateur de score Purview (à remplir après audit)
$purviewScore = [ordered]@{

    # P3 — Continuity Assurance
    P3_RetentionExchange     = 0   # 15 pts si Exchange couvert
    P3_RetentionSPOD         = 0   # 10 pts si SharePoint + OneDrive couverts
    P3_RetentionTeams        = 0   # 5 pts si Teams couvert

    # P4 — Exposure Surface
    P4_DLP_Enforce           = 0   # 20 pts si DLP en mode Enforce (pas Audit seulement)
    P4_DLP_4Workloads        = 0   # 10 pts si Exchange+SPO+OD+Teams couverts
    P4_Labels_Deployes       = 0   # 10 pts si labels publiés et adoptés
    P4_ExternalSharing       = 0   # 10 pts si partage externe gouverné

    # P5 — Operational Drift
    P5_UAL_Actif             = 0   # 15 pts si Unified Audit Log actif
    P5_AlertesDLP_Resolues   = 0   # 15 pts si <5 alertes DLP ouvertes
    P5_ComplianceScore       = 0   # 20 pts si Compliance Manager >60%
}

$p3Purview = $purviewScore.P3_RetentionExchange + $purviewScore.P3_RetentionSPOD + $purviewScore.P3_RetentionTeams
$p4Purview = $purviewScore.P4_DLP_Enforce + $purviewScore.P4_DLP_4Workloads + $purviewScore.P4_Labels_Deployes + $purviewScore.P4_ExternalSharing
$p5Purview = $purviewScore.P5_UAL_Actif + $purviewScore.P5_AlertesDLP_Resolues + $purviewScore.P5_ComplianceScore

Write-Output "Score P3 (Continuity — Purview) : $p3Purview / 30"
Write-Output "Score P4 (Exposure — Purview)   : $p4Purview / 50"
Write-Output "Score P5 (Drift — Purview)      : $p5Purview / 50"
```

---

## SECTION 4 — COMPLIANCE MANAGER — FRAMEWORKS DISPONIBLES

| Framework | Pertinence MSP | Couvrir si |
|---|---|---|
| **Loi 25 (Québec)** | Tous les clients QC | Toujours |
| **NIST CSF** | Baseline universel | Toujours |
| **ISO 27001** | Clients avec certification visée | Si demandé |
| **SOC 2 Type II** | SaaS / fournisseurs de services | Si client l'exige |
| **PCI-DSS** | Clients avec transactions CB | Si applicable |
| **HIPAA** | Santé (si client US ou données santé) | Si applicable |

---

## SECTION 5 — ACTIONS DE REMÉDIATION PRIORITAIRES

| Priorité | Action | Pilier | Effort | Impact |
|---|---|---|---|---|
| 🔴 P0 | Activer Unified Audit Log si désactivé | P5 | 15 min | +15 pts P5 |
| 🔴 P0 | Créer politique DLP minimale Exchange | P4 | 2h | +20 pts P4 |
| 🟡 P1 | Activer DLP sur SharePoint + OneDrive | P4 | 2h | +10 pts P4 |
| 🟡 P1 | Créer et publier 3 sensitivity labels (Confidentiel, Interne, Public) | P4 | 3h | +10 pts P4 |
| 🟡 P1 | Configurer rétention Exchange 7 ans | P3 | 1h | +15 pts P3 |
| 🟡 P2 | Restreindre partage externe SPO/OD | P4 | 1h | +10 pts P4 |
| 🟢 P2 | Évaluer Compliance Manager frameworks | P5 | 2h | +20 pts P5 |

---

## ESCALADE

| Situation | Vers | Délai |
|---|---|---|
| UAL désactivé (audit inexistant) | IT-SecurityMaster + EA | Immédiat |
| DLP alerte données sensibles exposées | IT-SecurityMaster | Dans l'heure |
| Litigation Hold requis (légal) | IT-CloudMaster + coordonnateur | Dans l'heure |

*SEC-PURVIEW-ComplianceAudit_V1 — 2026-05-22*
