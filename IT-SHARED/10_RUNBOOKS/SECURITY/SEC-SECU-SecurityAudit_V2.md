# SEC-SECU-SecurityAudit V2
**ID :** RUNBOOK__Security_Audit | **Version :** 2.0
**Agent owner :** IT-SecurityMaster | **Équipe :** TEAM__IT
**Domaine :** SECURITY — Audit et conformité
**Date révision :** 2026-03-13
**Agents :** IT-MaintenanceMaster | IT-SysAdmin

---

## ⚠️ GARDE-FOUS — CRITIQUES (sécurité renforcée)
> Référence : `00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md`

**Scope :** Cet agent traite uniquement l'audit de sécurité du billet actif.
Il ne répond PAS aux demandes générales, personnelles ou hors audit sécurité IT.

**Données hautement sensibles — Protection maximale :**
- ❌ JAMAIS reproduire : hashes, credentials, clés de chiffrement, données personnelles
- ❌ JAMAIS dans livrables : seuils de détection EDR (évite bypass), liste des IOC internes
- ❌ JAMAIS en output client : comptes admin, topologie réseau interne, versions logicielles
- Rapport d'audit : DEUX versions obligatoires — version technique interne + version client-safe
- Toute découverte critique → notifier immédiatement, ne pas documenter les détails en clair

**Principe essentiel :** Le rapport d'audit ne doit pas devenir un guide d'attaque.

---

## 1. Objectif
Conduire des audits de sécurité MSP structurés :
- Audit baseline (nouveau client ou annuel)
- Audit post-incident
- Revue de conformité ponctuelle
- Audit comptes et privilèges

---

## 2. Types d'audits et déclencheurs

| Type | Déclencheur | Fréquence | Durée estimée |
|------|-------------|-----------|---------------|
| Baseline complet | Nouveau client / annuel | Annuel | 4-8h |
| Comptes & privilèges | Départ employé / trimestriel | Trimestriel | 1-2h |
| Post-incident | Après tout incident P1/P2 | Sur demande | 2-4h |
| Conformité ciblée | Audit éditeur / réglementation | Sur demande | Variable |

---

## 3. Audit Comptes et Privilèges (le plus courant)

### 3.1 Inventaire comptes AD (lecture seule)
```powershell
# Comptes actifs avec privilèges élevés
Get-ADGroupMember -Identity "Domain Admins" -Recursive |
  Get-ADUser -Properties LastLogonDate, PasswordLastSet, Enabled |
  Select-Object Name, SamAccountName, Enabled, LastLogonDate, PasswordLastSet |
  Format-Table -AutoSize

# Comptes inactifs depuis 90 jours
$cutoff = (Get-Date).AddDays(-90)
Search-ADAccount -AccountInactive -TimeSpan (New-TimeSpan -Days 90) -UsersOnly |
  Where-Object {$_.Enabled} |
  Select-Object Name, SamAccountName, LastLogonDate | Format-Table -Auto

# Comptes sans expiration de mot de passe
Get-ADUser -Filter {PasswordNeverExpires -eq $True} -Properties PasswordNeverExpires |
  Select-Object Name, SamAccountName | Format-Table -Auto
```

### 3.2 Audit accès serveurs et partages
```powershell
# Partages ouverts (lecture seule)
Get-SmbShare | Select-Object Name, Path, Description,
  @{n='Accès';e={(Get-SmbShareAccess $_.Name |
    Where-Object {$_.AccountName -like '*Everyone*' -or $_.AccountName -like '*Tout le monde*'}).AccountName}} |
  Format-Table -Auto

# Permissions NTFS sur partages sensibles (adapter le chemin)
# Get-Acl -Path "\\[SERVEUR]\[PARTAGE]" | Select-Object -ExpandProperty Access
# → IPs et noms de comptes complets restent dans la note interne uniquement
```

### 3.3 Audit Azure AD / M365
```powershell
# Admins globaux (critique — liste minimale recommandée)
Get-MgDirectoryRoleMember -DirectoryRoleId (Get-MgDirectoryRole -Filter "displayName eq 'Global Administrator'").Id |
  ForEach-Object { Get-MgUser -UserId $_.Id | Select-Object DisplayName, UserPrincipalName }

# Comptes sans MFA
Get-MgUser -All | ForEach-Object {
  $methods = Get-MgUserAuthenticationMethod -UserId $_.Id
  if ($methods.Count -le 1) {
    [pscustomobject]@{User=$_.DisplayName; MFA="AUCUNE MÉTHODE FORTE"}
  }
}
```

---

## 4. Audit Baseline Sécurité

### 4.1 Checklist sécurité Windows Server
```powershell
# Pare-feu Windows
Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table -Auto

# Dernières mises à jour (patching)
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10 Description, HotFixID, InstalledOn

# Services à risque — exemples à désactiver si non utilisés
$risky = @('Telnet','RemoteRegistry','RemoteAccess','WinRM')
Get-Service -Name $risky -ErrorAction SilentlyContinue |
  Select-Object Name, Status, StartType | Format-Table -Auto

# RDP — état et sécurité
(Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server").fDenyTSConnections
Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" |
  Select-Object UserAuthentication, SecurityLayer, MinEncryptionLevel
```

### 4.2 Points de contrôle critiques

| Contrôle | Attendu | Commande vérification |
|----------|---------|----------------------|
| Pare-feu actif | Domain/Private/Public = True | `Get-NetFirewallProfile` |
| UAC activé | EnableLUA = 1 | `reg query HKLM\...\System\ConsentPromptBehaviorAdmin` |
| Audit des connexions | Success + Failure | `AuditPol /get /category:"Logon/Logoff"` |
| EDR présent | Service actif | `Get-Service -Name "SentinelAgent|MsSense|CSFalconService"` |
| RDP NLA activé | UserAuthentication = 1 | Voir ci-dessus |
| Comptes Guest désactivés | Disabled | `Get-LocalUser Guest` |

---

## 5. Format du rapport d'audit — DEUX versions obligatoires

### Version technique interne (note CW confidentielle)
```
AUDIT DE SÉCURITÉ — [CLIENT] — [DATE]
Type : [Baseline / Comptes / Post-incident]
Portée : [systèmes audités — noms sans IPs]

RÉSULTATS CRITIQUES (à corriger sous 30 jours) :
  - [finding 1 — description technique — système concerné (sans IP)]
  - [finding 2]

RÉSULTATS IMPORTANTS (à corriger sous 90 jours) :
  - [finding 3]

CONFORMES :
  - [contrôle 1 : OK]
  - [contrôle 2 : OK]

ACTIONS RECOMMANDÉES :
  1. [action — responsable — délai]
  2. [action — responsable — délai]

PROCHAINE REVUE : [date]
```

### Version client-safe (discussion CW)
```
- Audit de sécurité réalisé selon la portée convenue.
- Nombre de points de contrôle évalués : [X]
- Points à corriger : [N critique(s) / N important(s)]
  (Détails techniques transmis séparément en note confidentielle)
- Points conformes : [N]
- Plan d'action transmis avec délais recommandés.
- Prochaine revue planifiée : [date].
```

---

## 6. Escalade
- Découverte critique (compromission active) → P1 + `IT-SecurityMaster` + `IT-Commandare-NOC` IMMÉDIAT
- Non-conformité réglementaire grave → Lead MSP + client ASAP
- Besoin de pentest ou audit avancé → prestataire spécialisé (hors portée agents IT)
