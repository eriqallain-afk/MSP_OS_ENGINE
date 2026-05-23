# INFRA-AD-FolderSecurity_V1

> **Domaine :** Active Directory — Sécurité des dossiers partagés
> **Version :** 1.0 — 2026-05-16
> **Agents concernés :** IT-SysAdmin, IT-Commandare-TECH, IT-NetworkMaster
> **Contexte :** Gestion des permissions NTFS via groupes AD, héritage parent-enfant, audit et correction

---

## 1. PRINCIPE FONDAMENTAL — AGDLP

Toujours appliquer la règle **AGDLP** :

```
A  → Account (utilisateur ou ordinateur)
G  → Global Group (groupe global — regroupe les users)
DL → Domain Local Group (groupe local de domaine — reçoit les permissions)
P  → Permission (appliquée sur le dossier)
```

**Flux correct :**
```
Utilisateur → Groupe Global → Groupe Local de Domaine → Permission NTFS sur dossier
```

**Ne jamais** assigner des permissions directement à un utilisateur ou à un groupe global sur un dossier.

---

## 2. AUDIT AVANT INTERVENTION

### 2.1 Lister les permissions NTFS d'un dossier

```powershell
# Permissions NTFS d'un dossier (1 niveau)
$Chemin = "\\SRV-FS01\Partage\DossierCible"
(Get-Acl $Chemin).Access | Select-Object IdentityReference, FileSystemRights, AccessControlType, IsInherited |
    Format-Table -AutoSize

# Avec héritage affiché explicitement
(Get-Acl $Chemin).Access | Select-Object IdentityReference, FileSystemRights, AccessControlType, IsInherited, InheritanceFlags, PropagationFlags |
    Format-Table -AutoSize
```

### 2.2 Lister les membres d'un groupe AD

```powershell
# Membres directs
Get-ADGroupMember -Identity "DL-FS-Partage-RW" | Select-Object Name, SamAccountName, ObjectClass

# Membres récursifs (groupes imbriqués)
Get-ADGroupMember -Identity "DL-FS-Partage-RW" -Recursive | Select-Object Name, SamAccountName
```

### 2.3 Vérifier à quels groupes appartient un utilisateur

```powershell
$User = "jdupont"
(Get-ADUser $User -Properties MemberOf).MemberOf | Get-ADGroup | Select-Object Name, GroupScope, GroupCategory | Sort-Object Name
```

### 2.4 Audit complet d'un partage (récursif)

```powershell
# ⚠️ Peut être long sur les gros partages — limiter la profondeur si nécessaire
$Racine = "\\SRV-FS01\Partage"
Get-ChildItem -Path $Racine -Recurse -Directory | ForEach-Object {
    $acl = Get-Acl $_.FullName
    foreach ($access in $acl.Access) {
        [PSCustomObject]@{
            Chemin     = $_.FullName
            Identite   = $access.IdentityReference
            Droits     = $access.FileSystemRights
            Type       = $access.AccessControlType
            Hérite     = $access.IsInherited
        }
    }
} | Export-Csv "C:\Audit_NTFS_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation -Encoding UTF8
```

---

## 3. COMPRENDRE L'HÉRITAGE PARENT-ENFANT

### 3.1 Comment fonctionne l'héritage NTFS

```
\\SRV-FS01\Partage\                        ← Racine — permissions explicites
├── Département-RH\                         ← Hérite de Partage + peut avoir permissions propres
│   ├── Confidentiels\                      ← Peut bloquer l'héritage (Break Inheritance)
│   │   └── Contrats\                      ← Hérite de Confidentiels uniquement
│   └── Général\                           ← Hérite de Département-RH
└── Département-IT\                        ← Hérite de Partage + permissions propres
```

**Drapeaux d'héritage :**

| Flag | Signification |
|---|---|
| `ContainerInherit` | S'applique aux sous-dossiers |
| `ObjectInherit` | S'applique aux fichiers |
| `None` | S'applique uniquement à ce dossier |
| `NoPropagateInherit` | Ne se propage pas au-delà du premier niveau enfant |

### 3.2 Vérifier si l'héritage est bloqué

```powershell
$Chemin = "\\SRV-FS01\Partage\Département-RH\Confidentiels"
$acl = Get-Acl $Chemin
Write-Host "Héritage activé : $($acl.AreAccessRulesProtected -eq $false)"
# True = héritage activé | False = héritage BLOQUÉ (break inheritance)
```

### 3.3 Réactiver l'héritage sur un dossier

```powershell
$Chemin = "\\SRV-FS01\Partage\DossierCible"
$acl = Get-Acl $Chemin

# Réactiver l'héritage en conservant les permissions explicites existantes
$acl.SetAccessRuleProtection($false, $false)
Set-Acl -Path $Chemin -AclObject $acl
Write-Host "Héritage réactivé sur $Chemin"
```

### 3.4 Bloquer l'héritage sur un dossier (Break Inheritance)

```powershell
$Chemin = "\\SRV-FS01\Partage\DossierSensible"
$acl = Get-Acl $Chemin

# Bloquer l'héritage en CONSERVANT une copie des permissions héritées
$acl.SetAccessRuleProtection($true, $true)
Set-Acl -Path $Chemin -AclObject $acl
Write-Host "Héritage bloqué — permissions copiées localement sur $Chemin"
```

> ⚠️ **Après un Break Inheritance**, toutes les permissions héritées deviennent explicites sur ce dossier. Il faut ensuite supprimer manuellement celles qu'on ne veut pas.

---

## 4. CRÉER ET ASSIGNER UN GROUPE AD (PROCÉDURE COMPLÈTE)

### 4.1 Créer les groupes AD selon AGDLP

```powershell
# 1. Groupe Global — regroupe les utilisateurs
New-ADGroup -Name "GG-RH-Employes" `
    -GroupScope Global `
    -GroupCategory Security `
    -Path "OU=Groupes,OU=RH,DC=domaine,DC=local" `
    -Description "Groupe global — Employés RH"

# 2. Groupe Local de Domaine — reçoit les permissions NTFS
New-ADGroup -Name "DL-FS-RH-RW" `
    -GroupScope DomainLocal `
    -GroupCategory Security `
    -Path "OU=Groupes,OU=Fichiers,DC=domaine,DC=local" `
    -Description "Accès lecture-écriture — Partage RH"

New-ADGroup -Name "DL-FS-RH-RO" `
    -GroupScope DomainLocal `
    -GroupCategory Security `
    -Path "OU=Groupes,OU=Fichiers,DC=domaine,DC=local" `
    -Description "Accès lecture seule — Partage RH"

# 3. Imbrication : ajouter le groupe Global dans le groupe Local
Add-ADGroupMember -Identity "DL-FS-RH-RW" -Members "GG-RH-Employes"
```

### 4.2 Assigner les permissions NTFS

```powershell
$Chemin = "\\SRV-FS01\Partage\Département-RH"
$acl = Get-Acl $Chemin

# Lecture-Écriture pour DL-FS-RH-RW
$regleRW = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "DOMAINE\DL-FS-RH-RW",
    "Modify",
    "ContainerInherit, ObjectInherit",
    "None",
    "Allow"
)

# Lecture seule pour DL-FS-RH-RO
$regleRO = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "DOMAINE\DL-FS-RH-RO",
    "ReadAndExecute",
    "ContainerInherit, ObjectInherit",
    "None",
    "Allow"
)

$acl.AddAccessRule($regleRW)
$acl.AddAccessRule($regleRO)
Set-Acl -Path $Chemin -AclObject $acl
Write-Host "Permissions appliquées sur $Chemin"
```

### 4.3 Ajouter des utilisateurs aux groupes

```powershell
# Ajouter un utilisateur au groupe global
Add-ADGroupMember -Identity "GG-RH-Employes" -Members "jdupont", "mtremblay"

# Vérifier
Get-ADGroupMember -Identity "GG-RH-Employes" | Select-Object Name, SamAccountName
```

---

## 5. CONVENTION DE NOMMAGE DES GROUPES

| Préfixe | Type | Exemple | Usage |
|---|---|---|---|
| `GG-` | Global Group | `GG-RH-Employes` | Regroupe les utilisateurs par département/fonction |
| `DL-FS-` | Domain Local — File Share | `DL-FS-RH-RW` | Permissions sur partages fichiers |
| `DL-GPO-` | Domain Local — GPO | `DL-GPO-Poste-RH` | Security filtering GPO |
| `DL-SW-` | Domain Local — Software | `DL-SW-Office365` | Déploiement logiciel |

**Convention complète :** `{Type}-{Ressource}-{Sous-ressource}-{Permission}`
- `DL-FS-RH-RW` → DomainLocal — FileShare — RH — ReadWrite
- `DL-FS-RH-Confidentiels-RO` → DomainLocal — FileShare — RH\Confidentiels — ReadOnly

---

## 6. CAS FRÉQUENTS ET SOLUTIONS

### 6.1 Un utilisateur n'a pas accès alors qu'il est dans le bon groupe

```powershell
# 1. Vérifier l'appartenance (récursive)
Get-ADUser "jdupont" -Properties MemberOf | Select-Object -ExpandProperty MemberOf |
    Get-ADGroup | Where-Object { $_.Name -like "DL-FS-RH*" }

# 2. Forcer la mise à jour du token Kerberos (déconnexion/reconnexion requise)
# Sur le poste du user :
gpupdate /force
# Puis déconnecter/reconnecter la session Windows

# 3. Vérifier les permissions effectives avec icacls
icacls "\\SRV-FS01\Partage\Département-RH" /verify
```

### 6.2 Permissions héritées non désirées sur un sous-dossier

```powershell
# Identifier les permissions héritées
$Chemin = "\\SRV-FS01\Partage\RH\Confidentiel"
(Get-Acl $Chemin).Access | Where-Object { $_.IsInherited -eq $true } |
    Select-Object IdentityReference, FileSystemRights

# Solution : Break Inheritance puis supprimer les règles non désirées
$acl = Get-Acl $Chemin
$acl.SetAccessRuleProtection($true, $true)   # Bloquer + copier les règles existantes
Set-Acl -Path $Chemin -AclObject $acl

# Recharger l'ACL et supprimer les règles indésirables
$acl = Get-Acl $Chemin
$regleASupprimer = $acl.Access | Where-Object { $_.IdentityReference -eq "DOMAINE\GG-Tous-Employes" }
foreach ($regle in $regleASupprimer) {
    $acl.RemoveAccessRule($regle) | Out-Null
}
Set-Acl -Path $Chemin -AclObject $acl
```

### 6.3 Trouver tous les dossiers avec héritage bloqué sous une racine

```powershell
$Racine = "\\SRV-FS01\Partage"
Get-ChildItem -Path $Racine -Recurse -Directory | ForEach-Object {
    $acl = Get-Acl $_.FullName
    if ($acl.AreAccessRulesProtected) {
        Write-Host "Héritage BLOQUÉ : $($_.FullName)" -ForegroundColor Yellow
    }
}
```

---

## 7. CHECKLIST INTERVENTION SÉCURITÉ DOSSIERS

- [ ] Auditer les permissions actuelles avant toute modification (`Export-Csv`)
- [ ] Vérifier que les groupes AGDLP existent et sont bien nommés
- [ ] Confirmer l'héritage activé/bloqué sur les dossiers concernés
- [ ] Appliquer les permissions via groupes DL — jamais directement sur un utilisateur
- [ ] Valider l'accès avec un compte test après modification
- [ ] Documenter dans le ticket CW : groupes créés/modifiés, dossiers affectés
- [ ] Exporter l'ACL post-intervention et archiver dans Hudu

---

*INFRA-AD-FolderSecurity_V1 — IT-SHARED — MSP Intelligence AI — 2026-05-16*
