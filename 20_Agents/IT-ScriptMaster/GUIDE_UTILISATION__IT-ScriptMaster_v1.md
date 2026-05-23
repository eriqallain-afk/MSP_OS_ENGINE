# Guide d'utilisation — @IT-ScriptMaster (v1.0)
> **Pour :** Techniciens N1/N2/N3 MSP
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-ScriptMaster ?

**IT-ScriptMaster génère des scripts PowerShell et Bash production-ready pour les opérations MSP.**

Il ne se contente pas d'écrire du code — il produit des scripts documentés, avec gestion d'erreurs, logging, mode dry-run, et compatibles avec les contraintes des outils RMM (N-able, ConnectWise RMM, Datto RMM). Chaque script livré peut être déployé directement en production.

| Mode | Ce qu'il produit |
|---|---|
| Génération | Script complet PS/Bash avec header, logging, try/catch, dry-run |
| Audit | Revue d'un script existant — sécurité + robustesse + script corrigé |
| Librairie | Snippets réutilisables par catégorie (monitoring, AD, backup, etc.) |

> **Règle d'or : zéro credentials hardcodés.** Tous les accès passent par des paramètres ou SecureString. Jamais de mot de passe dans le code.

---

## Quand l'utiliser ?

- Tu as besoin d'un script pour automatiser une tâche répétitive (patching, collecte infos, nettoyage)
- Tu veux déployer un script via le RMM sur un ou plusieurs postes/serveurs
- Tu as un script existant à faire auditer — sécurité, robustesse, compatibilité RMM
- Tu cherches un snippet rapide pour une fonction spécifique (logging, check admin, dry-run)
- Tu dois générer un script de diagnostic lecture seule pour investiguer un incident

---

## Les commandes principales

### `/script [description]` — Générer un script production-ready

La commande principale. Tu décris ce que tu veux, l'agent produit le script complet.

**Usage :**
```
/script audit disques et services Windows Server — compatible N-able RMM
/script collecte infos Veeam — jobs, repos, dernier statut backup
/script désactiver compte AD utilisateur inactif depuis 90 jours — dry-run first
/script inventaire logiciels installés — exporter CSV — PowerShell 5.1
/script vérifier espace disque sur tous les DCs — alerte si < 20%
```

**Ce que tu obtiens :**
- Script complet avec header standard (synopsis, paramètres, auteur, version)
- `param()` en ligne 1 avec valeurs par défaut non vides
- Logging intégré (Write-Log ou Start-Transcript)
- Try/Catch/Finally sur toutes les opérations critiques
- `-WhatIf` (dry-run) pour scripts destructifs
- Section TESTS : comment valider avant déploiement RMM
- `⚠️ Impact` si le script modifie des données

**Exemple de script généré — structure attendue :**
```powershell
param(
    [string]$Billet  = "T[XXXXX]",
    [string]$Serveur = $env:COMPUTERNAME
)
#Requires -Version 5.1
<#
.SYNOPSIS
    [Description courte]
.NOTES
    Auteur  : @IT-ScriptMaster
    Version : 1.0
    Date    : 2026-05-18
#>
function Log {
    param([AllowEmptyString()][string]$Text = "", [string]$Color = "White")
    Write-Host $(if ([string]::IsNullOrEmpty($Text)) { " " } else { $Text }) -ForegroundColor $Color
}
# [Corps du script — Try/Catch/Finally]
```

---

### `/audit [script]` — Auditer un script existant

Pour faire réviser un script avant déploiement ou pour corriger un script qui échoue en RMM.

**Usage :**
```
/audit [coller le script PowerShell ci-dessous]
```

**Ce que tu obtiens :**
- Issues de sécurité : credentials en clair, exécution sans validation, élévation non contrôlée
- Issues de robustesse : pas de gestion d'erreur, Write-Host "" (problème RMM), param() mal structuré
- Recommandations d'amélioration priorisées
- Script corrigé avec les problèmes résolus

**Cas typiques détectés :**
- `Write-Host ""` → corrigé en `Write-Host " "` (espace — règle RMM anti-erreur)
- `param([string]$Serveur)` sans valeur par défaut → corrigé (RMM peut passer une chaîne vide)
- Pas de `[AllowEmptyString()]` sur les helpers → corrigé
- Try sans Catch → ajouté

---

### `/lib [catégorie]` — Extraire des snippets de la librairie

Pour récupérer des fonctions réutilisables sans générer un script complet.

**Usage :**
```
/lib logging — Fonction Write-Log universelle
/lib monitoring — Check espace disque + CPU + RAM
/lib admin — Vérification droits administrateur
/lib dry-run — Gate WhatIf standard
/lib ad — Requêtes Active Directory courantes
```

**Ce que tu obtiens :**
Fonctions prêtes à intégrer dans tes scripts, commentées et compatibles RMM.

**Snippets les plus demandés :**

Logging universel :
```powershell
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts][$Level] $Message"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}
```

Check droits admin :
```powershell
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "Ce script requiert des droits administrateur."
    exit 1
}
```

Gate dry-run :
```powershell
if (-not $WhatIf) {
    # action réelle
} else {
    Write-Host "[DRY-RUN] Aurait effectué : $action"
}
```

---

### `/close` — Clôture CW

Menu de clôture pour générer Note Interne, Discussion CW, Email client ou Notice Teams.

**Usage :**
```
/close
```
L'agent affiche le menu — il attend ta réponse avant de produire quoi que ce soit.

---

## Flux de travail

### Générer et déployer un script RMM

```
1. Décrire le besoin précisément
   ↓
2. /script [description complète] — compatible [N-able / CW RMM]
   ↓
3. Lire la section TESTS du script livré
4. Tester manuellement sur 1 machine non-prod (ou en dry-run)
   ↓
5. Si OK → déployer via RMM
   ↓
6. /close — documenter dans CW
```

### Script existant qui échoue en RMM

```
1. Récupérer le script fautif
   ↓
2. /audit [coller le script]
   ↓
3. Lire les issues identifiées — vérifier Write-Host "" et param()
   ↓
4. Utiliser le script corrigé fourni par l'agent
   ↓
5. Retester en RMM
```

### Créer une librairie de scripts pour un client

```
1. Identifier les tâches répétitives à automatiser
   ↓
2. /script [tâche 1] — /script [tâche 2] — etc.
   ↓
3. Déposer dans IT-SHARED/SCRIPTS/ ou dossier client
   ↓
4. Handoff → @IT-MaintenanceMaster si scripts patching/maintenance
5. Handoff → @IT-SecurityMaster si scripts audit sécurité
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| `param()` en LIGNE 1 — avant tout | N-able exige que param() soit la première instruction exécutable |
| `Write-Host " "` (espace) jamais `""` | Une chaîne vide cause des erreurs silencieuses dans certains RMM |
| `[AllowEmptyString()]` sur tous les `[string]` helper | RMM peut passer des valeurs vides — sans ce décorateur : erreur de validation |
| Valeur par défaut sur tous les `param` `[string]` | Le RMM peut ne pas passer le paramètre — prévoir un fallback |
| ZÉRO credentials hardcodés | Sécurité — Passportal pour tous les accès |
| `-WhatIf` sur scripts destructifs | Tester l'impact sans modifier quoi que ce soit |
| `⚠️ Impact` avant tout script à risque | Transparence — validation explicite requise |

**Rappel structure param() correcte :**
```powershell
param(
    [string]$Billet  = "T[XXXXX]",      # valeur par défaut non vide
    [string]$Serveur = $env:COMPUTERNAME # valeur par défaut non vide
)
#Requires -Version 5.1
```

---

## Questions fréquentes

**Q : Pourquoi `param()` doit être en ligne 1, avant `#Requires` ?**
C'est une contrainte des outils RMM comme N-able. Le runtime PowerShell des agents RMM traite `param()` en premier. Si elle n'est pas en position 0, le passage de paramètres depuis l'interface RMM échoue silencieusement.

**Q : Pourquoi `Write-Host ""` pose problème en RMM ?**
Certaines versions des agents RMM interceptent la sortie standard. Une chaîne vide peut générer une exception dans le pipeline de capture de sortie. La convention `Write-Host " "` (avec un espace) contourne ce comportement.

**Q : Puis-je demander un script Bash pour des serveurs Linux ?**
Oui — IT-ScriptMaster couvre PowerShell et Bash. Préciser le contexte : Linux ou macOS, version shell (bash/zsh), environnement (serveur, Docker, WSL).

**Q : Comment tester un script avant de le passer au RMM ?**
Toujours exécuter d'abord avec `-WhatIf` si disponible. Tester sur une machine de test ou non-critique. Lire la section TESTS du script livré par l'agent — elle décrit exactement comment valider.

**Q : Quand escalader vers IT-MaintenanceMaster ?**
Si le script produit fait partie d'un workflow de maintenance planifiée (patching, reboot schedulé, nettoyage disque récurrent) — IT-MaintenanceMaster coordonne l'exécution dans les fenêtres de maintenance.

---

*GUIDE_UTILISATION — IT-ScriptMaster v1.0 — MSP Intelligence AI — 2026-05-18*
