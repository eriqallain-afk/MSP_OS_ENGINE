# SEC-ENTRA-SecurityCompliance_V1
**Version :** 1.0 | **Date :** 2026-05-22 | **Statut :** ACTIF
**Agents :** @IT-ComplianceMaster | @IT-SecurityMaster | @IT-CloudMaster
**Département :** SEC | **Source :** IT MSP Intelligence Platform
**Piliers couverts :** P1 (partiel) · P2 · P3 (partiel) · P4 · P5

---

## OBJECTIF

Audit de la posture sécurité Entra ID — Conditional Access, PIM, Identity Protection, MFA, comptes privilégiés, guests, drift opérationnel.

## PRÉREQUIS

```
[ ] Accès Global Reader ou Security Reader sur le tenant
[ ] Module Microsoft.Graph installé (Install-Module Microsoft.Graph)
[ ] Connexion : Connect-MgGraph (voir Section 1)
[ ] Billet CW ouvert
[ ] Autorisation client documentée dans le ticket
```

---

## SECTION 1 — CONNEXION ET VALIDATION ACCÈS

```powershell
#Requires -Version 5.1
# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== CONNEXION MICROSOFT GRAPH ==="
try {
    Connect-MgGraph -Scopes @(
        "Directory.Read.All",
        "Policy.Read.All",
        "IdentityRiskyUser.Read.All",
        "AuditLog.Read.All",
        "Reports.Read.All",
        "RoleManagement.Read.All",
        "SecurityEvents.Read.All",
        "UserAuthenticationMethod.Read.All"
    ) -NoWelcome -EA Stop
    $ctx = Get-MgContext
    Write-Output "Connecté : $($ctx.Account) | Tenant : $($ctx.TenantId)"
} catch {
    Write-Output "ERREUR connexion Graph : $_"
    Write-Output "Installer le module : Install-Module Microsoft.Graph -Force"
    exit 1
}

Write-Output "=== INFO TENANT ==="
$org = Get-MgOrganization
[pscustomobject]@{
    Tenant      = $org.DisplayName
    TenantId    = $org.Id
    Domaines    = ($org.VerifiedDomains | Where-Object { $_.IsDefault } | Select-Object -First 1).Name
    Licences    = ($org.AssignedPlans | Where-Object { $_.CapabilityStatus -eq 'Enabled' } | Measure-Object).Count
} | Out-String -Width 300 | Write-Output
```

---

## SECTION 2 — SCRIPT AUDIT COMPLET ENTRA ID

```powershell
#Requires -Version 5.1
# Sortie : Out-String -Width 300 | Write-Output (compatible RMM)
# Prérequis : Connect-MgGraph (Section 1) déjà exécuté
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Output "=== P4 — MFA ENFORCEMENT ==="
try {
    $allUsers = Get-MgUser -All -Property Id,DisplayName,UserPrincipalName,UserType,AccountEnabled,SignInActivity
    $enabledUsers = $allUsers | Where-Object { $_.AccountEnabled -eq $true -and $_.UserType -ne 'Guest' }
    $totalEnabled = ($enabledUsers | Measure-Object).Count

    # Méthodes d'auth MFA
    $mfaCount = 0
    $noMfa = @()
    foreach ($u in $enabledUsers | Select-Object -First 200) {
        $methods = Get-MgUserAuthenticationMethod -UserId $u.Id -EA SilentlyContinue
        $hasMfa = $methods | Where-Object { $_.AdditionalProperties.'@odata.type' -notmatch 'password' }
        if ($hasMfa) { $mfaCount++ } else { $noMfa += $u.UserPrincipalName }
    }
    $mfaPct = if ($totalEnabled -gt 0) { [math]::Round(($mfaCount / [math]::Min($totalEnabled,200)) * 100, 0) } else { 0 }

    Write-Output "Utilisateurs actifs (non-guests) : $totalEnabled"
    Write-Output "MFA configuré (sample 200) : $mfaCount / $([math]::Min($totalEnabled,200)) ($mfaPct%)"
    if ($noMfa.Count -gt 0 -and $noMfa.Count -le 20) {
        Write-Output "Sans MFA : $($noMfa -join ', ')"
    } elseif ($noMfa.Count -gt 20) {
        Write-Output "⛔ $($noMfa.Count) utilisateurs sans MFA — liste tronquée"
    }
} catch { Write-Output "Erreur MFA check : $_" }

Write-Output ""
Write-Output "=== P2 — CONDITIONAL ACCESS POLICIES ==="
try {
    $caPolicies = Get-MgIdentityConditionalAccessPolicy -All
    Write-Output "Total CA policies : $($caPolicies.Count)"
    $caPolicies | Select-Object DisplayName, State,
        @{N="IncludeUsers"; E={ ($_.Conditions.Users.IncludeUsers -join ',') }},
        @{N="GrantControls"; E={ ($_.GrantControls.BuiltInControls -join ',') }} |
        Out-String -Width 300 | Write-Output

    $mfaPolicy = $caPolicies | Where-Object {
        $_.GrantControls.BuiltInControls -contains 'mfa' -and $_.State -eq 'enabled'
    }
    Write-Output "Policies MFA actives : $($mfaPolicy.Count)"

    $legacyBlock = $caPolicies | Where-Object {
        $_.Conditions.ClientAppTypes -contains 'exchangeActiveSync' -or
        $_.Conditions.ClientAppTypes -contains 'other'
    }
    Write-Output "Policies bloquant Legacy Auth : $($legacyBlock.Count)"
} catch { Write-Output "Erreur CA policies : $_" }

Write-Output ""
Write-Output "=== P2 — RÔLES PRIVILEGIÉS ==="
try {
    $privRoles = @(
        'Global Administrator', 'Privileged Role Administrator',
        'Security Administrator', 'Exchange Administrator',
        'SharePoint Administrator', 'User Administrator',
        'Conditional Access Administrator', 'Intune Administrator'
    )
    foreach ($role in $privRoles) {
        $roleObj = Get-MgDirectoryRole -Filter "DisplayName eq '$role'" -EA SilentlyContinue
        if ($roleObj) {
            $members = Get-MgDirectoryRoleMember -DirectoryRoleId $roleObj.Id -EA SilentlyContinue
            $count = ($members | Measure-Object).Count
            $flag = if ($count -gt 5) { "⚠️" } elseif ($count -eq 0) { "" } else { "✓" }
            Write-Output "  $flag $role : $count membre(s)"
            if ($count -le 10) {
                $members | ForEach-Object {
                    $u = Get-MgUser -UserId $_.Id -EA SilentlyContinue
                    if ($u) { Write-Output "      → $($u.UserPrincipalName)" }
                }
            }
        }
    }
} catch { Write-Output "Erreur rôles privilégiés : $_" }

Write-Output ""
Write-Output "=== P2 — PIM (PRIVILEGED IDENTITY MANAGEMENT) ==="
try {
    $pimSchedules = Get-MgRoleManagementDirectoryRoleEligibilitySchedule -All -EA SilentlyContinue
    if ($pimSchedules) {
        Write-Output "PIM activé ✓ — Rôles éligibles (not permanent) : $($pimSchedules.Count)"
        $pimSchedules | Select-Object @{N="Principal";E={$_.PrincipalId}},
            @{N="Role";E={$_.RoleDefinitionId}},
            @{N="Scope";E={$_.DirectoryScopeId}} |
            Select-Object -First 10 | Out-String -Width 300 | Write-Output
    } else {
        Write-Output "⛔ PIM non activé ou non détecté — rôles permanents non protégés"
    }
} catch { Write-Output "PIM non disponible (licence P2 requise) : $_" }

Write-Output ""
Write-Output "=== P4 — ENTRA ID IDENTITY PROTECTION ==="
try {
    $riskyUsers = Get-MgRiskyUser -All -EA SilentlyContinue
    if ($riskyUsers) {
        $high = ($riskyUsers | Where-Object { $_.RiskLevel -eq 'high' } | Measure-Object).Count
        $med  = ($riskyUsers | Where-Object { $_.RiskLevel -eq 'medium' } | Measure-Object).Count
        $low  = ($riskyUsers | Where-Object { $_.RiskLevel -eq 'low' } | Measure-Object).Count
        Write-Output "Utilisateurs à risque — Élevé: $high | Moyen: $med | Faible: $low"
        $riskyUsers | Where-Object { $_.RiskLevel -in 'high','medium' } |
            Select-Object UserPrincipalName, RiskLevel, RiskState, RiskLastUpdatedDateTime |
            Out-String -Width 300 | Write-Output
    } else {
        Write-Output "Aucun utilisateur à risque détecté (ou licence P2 absente)"
    }
} catch { Write-Output "Identity Protection non disponible : $_" }

Write-Output ""
Write-Output "=== P5 — COMPTES INACTIFS ET GUESTS ==="
try {
    $cutoff = (Get-Date).AddDays(-90)
    $staleUsers = Get-MgUser -All -Property Id,DisplayName,UserPrincipalName,SignInActivity,AccountEnabled,UserType |
        Where-Object {
            $_.AccountEnabled -eq $true -and
            $_.UserType -ne 'Guest' -and
            $_.SignInActivity.LastSignInDateTime -lt $cutoff -and
            $null -ne $_.SignInActivity.LastSignInDateTime
        }
    Write-Output "Comptes actifs sans connexion depuis 90 jours : $($staleUsers.Count)"
    $staleUsers | Select-Object UserPrincipalName,
        @{N="DernièreConnexion";E={$_.SignInActivity.LastSignInDateTime}} |
        Select-Object -First 20 | Out-String -Width 300 | Write-Output

    $guests = Get-MgUser -All -Filter "userType eq 'Guest'" -Property DisplayName,UserPrincipalName,SignInActivity,AccountEnabled
    $staleGuests = $guests | Where-Object {
        $_.SignInActivity.LastSignInDateTime -lt $cutoff -or
        $null -eq $_.SignInActivity.LastSignInDateTime
    }
    Write-Output "Comptes invités (guests) total : $($guests.Count)"
    Write-Output "Invités inactifs >90 jours : $($staleGuests.Count)"
} catch { Write-Output "Erreur comptes inactifs : $_" }

Write-Output ""
Write-Output "=== P5 — APP REGISTRATIONS ORPHELINES ==="
try {
    $apps = Get-MgApplication -All -Property DisplayName,AppId,CreatedDateTime,SignInAudience
    $spns = Get-MgServicePrincipal -All -Property AppId,DisplayName,AccountEnabled
    $orphans = $apps | Where-Object {
        $spn = $spns | Where-Object { $_.AppId -eq $_.AppId }
        $null -eq $spn -or $spn.AccountEnabled -eq $false
    }
    Write-Output "App registrations total : $($apps.Count)"
    Write-Output "Applications potentiellement orphelines : $($orphans.Count)"
    $apps | Where-Object { $_.CreatedDateTime -lt (Get-Date).AddDays(-365) } |
        Sort-Object CreatedDateTime |
        Select-Object DisplayName, AppId, CreatedDateTime, SignInAudience |
        Select-Object -First 15 | Out-String -Width 300 | Write-Output
} catch { Write-Output "Erreur app registrations : $_" }

Write-Output ""
Write-Output "=== P3 — COMPTES BREAK-GLASS ==="
Write-Output "Vérification manuelle requise :"
Write-Output "  1. Entra ID → Users → filtrer 'break' ou 'emergency'"
Write-Output "  2. Vérifier : exclus de toutes les CA policies"
Write-Output "  3. Vérifier : MFA via token FIDO2 ou autre méthode offline"
Write-Output "  4. Vérifier : alerte Entra sur toute connexion break-glass"
Write-Output "  5. Vérifier : dernier test de connexion documenté (<90 jours)"

Write-Output ""
Write-Output "=== SECURE SCORE ==="
try {
    $score = Get-MgSecuritySecureScore -Top 1 -EA Stop
    [pscustomobject]@{
        Score_Actuel   = "$([math]::Round($score.CurrentScore,0))/$([math]::Round($score.MaxScore,0))"
        Pourcentage    = "$([math]::Round(($score.CurrentScore/$score.MaxScore)*100,0))%"
        Date           = $score.CreatedDateTime
    } | Out-String -Width 300 | Write-Output
} catch { Write-Output "Secure Score non disponible via Graph : $_" }

Write-Output "=== FIN AUDIT ENTRA ID ==="
```

---

## SECTION 3 — SCORING P2 / P4 / P5

Après exécution du script, coter chaque critère :

```powershell
# Calculateur de score Entra ID (à remplir après audit)
$entraScore = [ordered]@{

    # P2 — Governance Integrity
    P2_AdminsDedies          = 0   # 25 pts si comptes admin dédiés confirmés
    P2_PIM_Actif             = 0   # 20 pts si PIM activé et rôles éligibles
    P2_CA_AdminsCouverture   = 0   # 20 pts si CA couvre 100% admins
    P2_GuestsGouvernes       = 0   # 15 pts si Access Reviews actives
    P2_Segmentation          = 0   # 10 pts si documentée
    P2_MFA_PhishingResistant = 0   # 10 pts si FIDO2/passkey Tier-0

    # P4 — Exposure Surface
    P4_MFA_100pct            = 0   # 25 pts si MFA 100% users
    P4_IdentityProtection    = 0   # 20 pts si risk policies actives
    P4_LegacyAuthBloque      = 0   # 15 pts si CA bloque legacy auth

    # P5 — Operational Drift
    P5_ComptesInactifs       = 0   # 25 pts si <5 comptes inactifs >90j
    P5_AppsOrphelines        = 0   # 20 pts si <3 apps orphelines
    P5_RolesPermanents       = 0   # 15 pts si <5 rôles permanents privilegiés
}

$totalP2 = $entraScore.P2_AdminsDedies + $entraScore.P2_PIM_Actif +
           $entraScore.P2_CA_AdminsCouverture + $entraScore.P2_GuestsGouvernes +
           $entraScore.P2_Segmentation + $entraScore.P2_MFA_PhishingResistant

$totalP4 = $entraScore.P4_MFA_100pct + $entraScore.P4_IdentityProtection +
           $entraScore.P4_LegacyAuthBloque

$totalP5 = $entraScore.P5_ComptesInactifs + $entraScore.P5_AppsOrphelines +
           $entraScore.P5_RolesPermanents

Write-Output "Score P2 (Governance) : $totalP2 / 100"
Write-Output "Score P4 (Exposure)   : $totalP4 / 100 (partiel Entra)"
Write-Output "Score P5 (Drift)      : $totalP5 / 100 (partiel Entra)"
```

---

## SECTION 4 — ACTIONS DE REMÉDIATION PRIORITAIRES

| Priorité | Action | Pilier | Effort | Impact score |
|---|---|---|---|---|
| 🔴 P0 | Bloquer legacy auth (CA policy) | P4 | 1h | +15 pts P4 |
| 🔴 P0 | Activer MFA utilisateurs sans MFA | P4 | 2-4h | +25 pts P4 |
| 🔴 P1 | Créer comptes break-glass + exclure CA | P3 | 2h | +20 pts P3 |
| 🟡 P1 | Activer PIM pour Global Admin | P2 | 4h | +20 pts P2 |
| 🟡 P1 | Activer Identity Protection risk policies | P4 | 2h | +20 pts P4 |
| 🟡 P2 | Désactiver comptes inactifs >90j | P5 | 2h | +25 pts P5 |
| 🟡 P2 | Access Reviews pour les guests | P2 | 2h | +15 pts P2 |
| 🟢 P3 | Nettoyer app registrations orphelines | P5 | 4h | +20 pts P5 |

---

## ESCALADE

| Situation | Vers | Délai |
|---|---|---|
| Utilisateurs à risque ÉLEVÉ Entra ID Protection | IT-SecurityMaster | Immédiat |
| Global Admin > 5 permanents et non protégés | IT-SecurityMaster | Urgent |
| Break-glass inexistants | IT-SecurityMaster + EA | Urgent |

*SEC-ENTRA-SecurityCompliance_V1 — 2026-05-22*
