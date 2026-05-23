# SUP-M365-OneDrive_SharePoint_Sync_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-Assistant-N2 | @IT-FrontLine | @IT-MaintenanceMaster | @IT-SysAdmin
**Département :** SUP | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__OneDrive_SharePoint_Sync_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N2, IT-Assistant-N3
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Domaine :** SUPPORT — Microsoft 365
**Mis à jour :** 2026-03-20

---

## 1. ONEDRIVE — DÉPANNAGE SYNCHRONISATION

### Symptômes courants
```
→ Icône OneDrive rouge (erreur) ou bleue tournante (bloqué)
→ Fichiers ne se synchronisent pas depuis X heures/jours
→ Message "Fichier verrouillé" ou "Impossible de synchroniser"
→ Conflits de fichiers
```

### Étape 1 — Lire le message d'erreur
```
Clic sur l'icône OneDrive (barre des tâches)
→ Lire le message exact de l'erreur
→ Cliquer sur "Afficher le problème" pour le détail
```

### Étape 2 — Vérifier les fichiers problématiques
```
Caractères interdits dans les noms de fichiers OneDrive :
→ " * : < > ? / \ |
→ Noms commençant ou finissant par un espace
→ Noms commençant par un point (.)
→ Noms réservés Windows : CON, PRN, AUX, NUL, COM1-9, LPT1-9
→ Fichiers .lnk, .tmp, .pst sur certaines configurations

PowerShell — détecter les fichiers problématiques :
```powershell
$OneDrivePath = "$env:USERPROFILE\OneDrive - [NomOrganisation]"
Get-ChildItem -Path $OneDrivePath -Recurse -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -match '["\*:<>?/\\|]' -or
        $_.Name -match '^\s|\s$' -or
        $_.Name -match '^\.' -or
        $_.Name -match '^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\.|$)'
    } | Select-Object FullName | Format-Table -AutoSize
```

### Étape 3 — Réinitialiser OneDrive
```powershell
# Fermer OneDrive complètement
Get-Process -Name "OneDrive" -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 3

# Réinitialiser (conserve les fichiers locaux, recrée la synchronisation)
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" /reset

# Attendre 30 secondes puis relancer
Start-Sleep -Seconds 30
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"
Write-Host "OneDrive réinitialisé — attendre 2-5 min pour la reconnexion"
```

### Étape 4 — Si réinitialisation insuffisante
```
1. Déconnecter le compte OneDrive :
   Icône OneDrive → Paramètres → Compte → Dissocier ce PC

2. Fermer OneDrive

3. Déplacer temporairement le dossier OneDrive local (renommer en OneDrive_OLD)

4. Relancer OneDrive → se reconnecter → laisser resynchroniser

5. Comparer OneDrive_OLD avec le nouveau dossier pour s'assurer qu'aucun fichier local n'est perdu
```

---

## 2. GESTION DES CONFLITS DE FICHIERS

```
OneDrive crée des copies avec "-[Prénom Nom]-" dans le nom en cas de conflit.
Ex: Document.docx → Document-Jean Tremblay.docx

Procédure :
1. Ouvrir les deux fichiers côte à côte
2. Identifier quelle version est la plus récente/complète
3. Garder la bonne version → supprimer ou fusionner l'autre
4. Supprimer le fichier de conflit

⛔ NE PAS supprimer automatiquement tous les fichiers de conflit sans vérification
```

---

## 3. SHAREPOINT — PROBLÈMES DE SYNCHRONISATION

### Bibliothèque SharePoint qui ne se synchronise pas
```
Vérification :
1. S'assurer que OneDrive est connecté et fonctionne
2. Dans SharePoint (navigateur) → [Bibliothèque] → Synchroniser
3. OneDrive s'ouvre et propose de synchroniser la bibliothèque

Si déjà synchronisé mais bloqué :
1. Clic droit sur la bibliothèque dans l'Explorateur Windows
2. "Choisir les dossiers OneDrive à synchroniser" → vérifier la sélection
```

### Erreur "Vous ne pouvez pas synchroniser ce dossier"
```
Causes possibles :
→ Trop de fichiers (> 300 000 dans une bibliothèque)
→ Chemin trop long (> 260 caractères incluant le chemin local)
→ Quota OneDrive dépassé

Solutions :
→ Chemin trop long : raccourcir le nom des dossiers parent
→ Quota dépassé : libérer de l'espace ou augmenter le quota (admin M365)
→ Trop de fichiers : utiliser "Fichiers à la demande" au lieu de tout synchroniser
```

### Fichiers à la demande (Files on Demand)
```
Active les fichiers SharePoint/OneDrive visibles localement sans téléchargement :
Icône OneDrive → Paramètres → Paramètres → Fichiers à la demande
→ Cocher "Économiser de l'espace et télécharger les fichiers au fur et à mesure"

Icônes des fichiers :
☁️ = Disponible dans le cloud (non téléchargé)
✅ = Disponible localement (téléchargé)
🔄 = En cours de synchronisation
```

---

## 4. LIMITES IMPORTANTES ONEDRIVE/SHAREPOINT

| Limite | Valeur |
|---|---|
| Taille max fichier | 250 GB |
| Nb fichiers max bibliothèque | 300 000 (recommandé : < 100 000) |
| Longueur chemin | 400 caractères (URL) |
| Longueur nom fichier | 400 caractères |
| Types non synchronisés | .tmp, .lnk, certains .pst |
| Quota OneDrive défaut | 1 TB par utilisateur |

---

## 5. NE PAS FAIRE

```
⛔ NE JAMAIS supprimer le dossier OneDrive local directement depuis l'Explorateur
   → Peut déclencher la suppression des fichiers dans le cloud
   → Toujours dissocier d'abord depuis les paramètres OneDrive

⛔ NE PAS renommer le dossier OneDrive principal manuellement
   → Toujours utiliser les paramètres OneDrive pour modifier l'emplacement

⛔ NE PAS stocker des bases de données actives (.mdb, .accdb, certains .sqlite) dans OneDrive
   → Ces fichiers sont souvent verrouillés par l'application = erreurs de sync

⛔ NE PAS ignorer les conflits de fichiers — vérifier toujours quelle version conserver
```

---

## 6. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Données OneDrive perdues (fichiers disparus) | BackupDR (Keepit) | Immédiat |
| Quota OneDrive atteint pour plusieurs utilisateurs | CloudMaster | Dans la journée |
| Bibliothèque SharePoint corrompue | CloudMaster + TECH | Dans l'heure |

```
