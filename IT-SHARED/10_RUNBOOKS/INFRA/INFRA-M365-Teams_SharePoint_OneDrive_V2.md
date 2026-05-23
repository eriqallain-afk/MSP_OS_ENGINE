# INFRA-M365-Teams_SharePoint_OneDrive_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__M365_Teams_SharePoint_OneDrive_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N2, IT-Assistant-N3, IT-CloudMaster
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Domaine :** INFRA — Microsoft 365
**Mis à jour :** 2026-03-20

---

## 1. MICROSOFT TEAMS — DÉPANNAGE

### Arbre de décision Teams
```
L'utilisateur ne peut pas accéder à Teams
│
├─ Impossible de se connecter
│   → Vérifier compte M365 actif + licence Teams assignée
│   → Vérifier Accès conditionnel (Entra ID) qui bloque
│
├─ Teams s'ouvre mais les canaux/équipes sont vides
│   → Vérifier appartenance aux équipes dans Teams Admin
│   → Vérifier que l'utilisateur n'a pas été retiré des groupes
│
├─ Teams lent / instable
│   → Vider le cache Teams (voir procédure ci-dessous)
│   → Vérifier la connexion Internet (bande passante)
│
└─ Fonctionnalité spécifique ne fonctionne pas (appels, réunions)
    → Vérifier la licence (Teams Phone requis pour appels PSTN)
    → Vérifier les politiques Teams Admin
```

### Vider le cache Teams (Windows)
```powershell
# Fermer Teams complètement d'abord
Get-Process -Name "Teams" -ErrorAction SilentlyContinue | Stop-Process -Force

# Vider le cache
$CachePath = "$env:APPDATA\Microsoft\Teams"
$Folders = @("Cache","Code Cache","GPUCache","databases","Local Storage","tmp")
foreach ($f in $Folders) {
    $path = Join-Path $CachePath $f
    if (Test-Path $path) {
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Vidé : $path"
    }
}
Write-Host "Cache Teams vidé. Redémarrer Teams."
```

### Gestion Teams via PowerShell
```powershell
# Connexion
Install-Module MicrosoftTeams -Force
Connect-MicrosoftTeams

# Lister toutes les équipes
Get-Team | Select-Object DisplayName, GroupId, Visibility, Archived | Format-Table -AutoSize

# Membres d'une équipe
Get-TeamMember -GroupId "[GROUP_ID]" | Select-Object User, Role | Format-Table

# Ajouter un membre à une équipe
Add-TeamMember -GroupId "[GROUP_ID]" -User "utilisateur@domaine.com"

# Créer une nouvelle équipe
$team = New-Team -DisplayName "Nom Équipe" -Description "Description" -Visibility "Private"
# Ajouter des membres
Add-TeamMember -GroupId $team.GroupId -User "utilisateur@domaine.com"
```

---

## 2. SHAREPOINT ONLINE — GESTION ET DÉPANNAGE

### Vérification d'accès SharePoint
```
⚠️ RÈGLE : NE JAMAIS donner l'accès SharePoint sans autorisation du propriétaire du site

Procédure :
1. Identifier le propriétaire du site : SharePoint Admin → Sites → [Site] → Owners
2. Obtenir l'autorisation du propriétaire (écrit)
3. Ajouter l'utilisateur au bon groupe :
   → Visiteurs = lecture seule
   → Membres = lecture/écriture
   → Propriétaires = contrôle total
```

```powershell
# Connexion SharePoint Online
Install-Module PnP.PowerShell -Force
Connect-PnPOnline -Url "https://[tenant].sharepoint.com" -Interactive

# Lister les sites
Get-PnPTenantSite | Select-Object Title, Url, Template, StorageUsageCurrent | Format-Table -AutoSize

# Membres d'un groupe SharePoint
$site = "https://[tenant].sharepoint.com/sites/[NomSite]"
Connect-PnPOnline -Url $site -Interactive
Get-PnPGroup | ForEach-Object {
    $g = $_
    $members = Get-PnPGroupMember -Group $g.Title
    [pscustomobject]@{Group=$g.Title; Members=($members.Title -join ", ")}
} | Format-Table -AutoSize

# Ajouter un utilisateur au groupe Membres
Add-PnPGroupMember -LoginName "utilisateur@domaine.com" -Group "NomSite Members"
```

### Dépannage accès refusé SharePoint
```
1. L'utilisateur reçoit "Access Denied"
   → Vérifier qu'il est bien dans le bon groupe SharePoint
   → Vérifier que l'héritage des permissions est activé (pas de rupture d'héritage sur le sous-dossier)

2. Le site n'apparaît pas dans la liste des sites de l'utilisateur
   → S'assurer que l'utilisateur est ajouté au groupe ET que le site est partagé avec lui
   → Vérifier la visibilité du site (Private vs Public)

3. Quota dépassé
   SharePoint Admin → Sites → [Site] → Storage
   → Augmenter le quota ou archiver du contenu
```

---

## 3. ONEDRIVE — SYNCHRONISATION ET DÉPANNAGE

### Problèmes de synchronisation OneDrive
```powershell
# Vérifier l'état OneDrive (commande sur le poste)
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" /status

# Réinitialiser OneDrive (résout la majorité des problèmes)
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" /reset

# Redémarrer OneDrive après reset
Start-Sleep -Seconds 5
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"
Write-Host "OneDrive relancé — attendre 1-2 min pour resynchronisation"
```

### Gestion OneDrive admin
```powershell
# Voir le quota OneDrive d'un utilisateur
Connect-SPOService -Url "https://[tenant]-admin.sharepoint.com"
Get-SPOSite -IncludePersonalSite $true -Limit All -Filter "Url -like '-my.sharepoint.com/personal/'" |
    Select-Object Url, StorageUsageCurrent, StorageQuota | Format-Table -AutoSize

# Augmenter le quota d'un utilisateur
Set-SPOSite -Identity "https://[tenant]-my.sharepoint.com/personal/[UPN_encodé]" -StorageQuota 50000
```

### Fichiers coincés en synchronisation
```
Sur le poste utilisateur :
1. Clic droit sur l'icône OneDrive (barre des tâches) → Afficher les fichiers synchronisés
2. Identifier les fichiers bloqués (symbole d'erreur)
3. Actions :
   → Renommer le fichier (supprimer les caractères spéciaux : # % & * : < > ? / \ { | })
   → Déplacer hors du dossier OneDrive, puis remettre
   → Si erreur 0x80070005 (accès refusé) → fermer l'application qui utilise le fichier
```

---

## 4. NE PAS FAIRE

```
⛔ NE JAMAIS partager un site SharePoint en "Tout le monde" sans approbation
⛔ NE JAMAIS rompre l'héritage des permissions sur des sous-dossiers
   → Crée des cas très difficiles à gérer (permissions orphelines)
⛔ NE PAS supprimer un groupe M365 lié à une équipe Teams
   → Supprime automatiquement l'équipe Teams associée
⛔ NE PAS archiver une équipe Teams sans prévenir les membres
⛔ NE JAMAIS réinitialiser OneDrive d'un utilisateur sans l'avoir averti
   → Toutes les syncs locales sont recréées (peut prendre des heures)
```

---

## 5. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Teams inaccessible pour tous les utilisateurs | NOC + TECH | Immédiat |
| Site SharePoint corrompu ou inaccessible | TECH | Dans l'heure |
| Perte de données OneDrive (fichiers supprimés) | BackupDR (Keepit) | Immédiat |
| Quota OneDrive/SharePoint dépassé massivement | TECH | Dans la journée |
