# BUNDLE_KP_Assistant-N2_V2
**Agent :** @IT-Assistant-N2
**Version :** 2.0 | **Date :** 2026-05-15
**Type :** KnowledgePack GPT — Fallback GitHub
**Contenu :** Posture support, triage, MDP/comptes, accès dossiers, imprimante, Outlook, VPN, OneDrive, SharePoint, RDS, Teams, scripts PowerShell, vérification identité, escalades enrichies, clôture guidée.

---

## SECTION 1 — POSTURE SUPPORT TÉLÉPHONIQUE (hérité V1)

```
POSTURE @IT-Assistant-N2 :
- Ton professionnel, calme et empathique en tout temps
- Commencer par écouter COMPLÈTEMENT avant de diagnostiquer
- Poser UNE question à la fois — ne pas bombarder l'utilisateur
- Valider à voix haute chaque étape : "J'ai bien noté que..."
- Annoncer ce qu'on va faire AVANT de le faire
- Ne jamais laisser l'utilisateur dans le silence > 30 secondes sans update
- Confirmer que ça fonctionne AVANT de fermer le billet
- Remercier l'utilisateur à la fin de chaque appel

PHRASE D'OUVERTURE :
"Bonjour [Prénom], je suis [Nom] du support technique. 
Comment puis-je vous aider aujourd'hui?"

PHRASE DE CLÔTURE :
"Parfait, tout est réglé de votre côté? 
Y a-t-il autre chose que je peux faire pour vous aujourd'hui?
Je vous souhaite une bonne journée."
```

---

## SECTION 2 — GRILLE DE TRIAGE ET PRIORITÉ (hérité V1)

```
TRIAGE RAPIDE N2 :

Question 1 : "Combien de personnes sont affectées?"
→ 1 personne → P3/P4 probable
→ Plusieurs → P2 possible → escalade éventuelle
→ Tout un département/site → P1 immédiat → escalade NOW

Question 2 : "Depuis combien de temps?"
→ < 1h → peut attendre procédure standard
→ > 2h pour P2+ → délai SLA à risque → urgence

Question 3 : "Est-ce que vous pouvez travailler autrement en attendant?"
→ Oui → contournement documenté, résolution planifiée
→ Non → urgence augmentée

SEUIL D'ESCALADE N2 → N3 :
- Problème récurrent (3e fois même incident)
- Temps de résolution dépasse 45 min sans progrès
- Commande à risque sur serveur en production
- Intervention requise sur infrastructure (non poste/app)
```

---

## SECTION 3 — PROCÉDURES MDP / COMPTE (hérité V1 + enrichi)

### Reset MDP AD — Procédure complète
```powershell
# ÉTAPE 1 : Vérifier identité (OBLIGATOIRE)
# Voir Section 10

# ÉTAPE 2 : Vérifier statut du compte
Get-ADUser "[prenom.nom]" -Properties LockedOut, PasswordExpired, PasswordLastSet, LastLogonDate, Enabled |
    Select-Object Name, SamAccountName, Enabled, LockedOut, PasswordExpired, PasswordLastSet, LastLogonDate

# ÉTAPE 3 : Déverrouiller si verrouillé
Unlock-ADAccount -Identity "[prenom.nom]"

# ÉTAPE 4 : Réinitialiser le mot de passe
Set-ADAccountPassword "[prenom.nom]" -Reset -NewPassword (ConvertTo-SecureString "[MDP_TEMP]" -AsPlainText -Force)
Set-ADUser "[prenom.nom]" -ChangePasswordAtLogon $true

# ÉTAPE 5 : Confirmer
Get-ADUser "[prenom.nom]" -Properties LockedOut, PasswordExpired | Select-Object Name, LockedOut, PasswordExpired

# ÉTAPE 6 : Communiquer le MDP TEMPORAIRE de façon sécurisée
# → Via OneTimeSecret (onetimesecret.com) ou Passportal
# → JAMAIS en clair par email ou Teams
```

### Reset MDP M365
```powershell
# Via PowerShell MSGraph
Connect-MgGraph -Scopes "UserAuthenticationMethod.ReadWrite.All"

# Réinitialiser MDP
$params = @{
    passwordProfile = @{
        password = "[MDP_TEMP]"
        forceChangePasswordNextSignIn = $true
    }
}
Update-MgUser -UserId "[user]@[DOMAINE].com" -BodyParameter $params

# Révoquer sessions actives (si compromission suspectée)
Revoke-MgUserSignInSession -UserId "[user]@[DOMAINE].com"

# Réinitialiser méthodes MFA (si l'utilisateur ne peut plus se connecter)
# Portail Entra → Users → [USER] → Authentication methods → Delete all
# → Ou via Temporary Access Pass
```

### Compte désactivé / expiré
```powershell
# Réactiver compte (⚠️ vérifier pourquoi il était désactivé AVANT de réactiver)
Enable-ADAccount -Identity "[prenom.nom]"

# Remettre une date d'expiration ou supprimer l'expiration
Set-ADAccountExpiration -Identity "[prenom.nom]" -DateTime "2026-12-31"
Clear-ADAccountExpiration -Identity "[prenom.nom]"  # Pas d'expiration

# Vérifier si le compte est dans l'OU désactivés
Get-ADUser "[prenom.nom]" | Select-Object DistinguishedName
# Si dans OU désactivés → déplacer vers OU actif avant de réactiver
Move-ADObject -Identity (Get-ADUser "[prenom.nom]").DistinguishedName `
    -TargetPath "OU=Utilisateurs,DC=[DOMAINE],DC=local"
Enable-ADAccount -Identity "[prenom.nom]"
```

---

## SECTION 4 — ACCÈS REFUSÉ / DOSSIERS (hérité V1 + enrichi)

```
RÈGLE ABSOLUE :
⛔ NE JAMAIS modifier les permissions directement sur les dossiers
✅ TOUJOURS utiliser les groupes AD pour gérer les accès

PROCÉDURE ACCÈS REFUSÉ DOSSIER RÉSEAU :
1. Identifier le dossier/partage demandé
2. Identifier le groupe AD qui contrôle l'accès à ce dossier (dans Hudu)
3. Vérifier si l'utilisateur est membre du groupe :
```

```powershell
# Vérifier groupes de l'utilisateur
(Get-ADUser "[prenom.nom]" -Properties MemberOf).MemberOf | ForEach-Object { (Get-ADGroup $_).Name } | Sort-Object

# Vérifier membres d'un groupe d'accès
Get-ADGroupMember -Identity "[NOM_GROUPE_ACCES]" | Select-Object Name, SamAccountName

# Ajouter au groupe (si approuvé — billet documenté)
Add-ADGroupMember -Identity "[NOM_GROUPE_ACCES]" -Members "[prenom.nom]"

# Vérifier que le changement est pris en compte
(Get-ADUser "[prenom.nom]" -Properties MemberOf).MemberOf | ForEach-Object { (Get-ADGroup $_).Name } | Where-Object { $_ -eq "[NOM_GROUPE_ACCES]" }
```

```
4. Si l'utilisateur DOIT avoir accès → ouvrir billet CW + demander approbation si pas déjà approuvé
5. Ajouter au groupe AD approprié (JAMAIS directement sur le dossier)
6. Tester l'accès : gpupdate /force sur le poste, puis tester le chemin UNC
7. Documenter dans CW : groupe, billet d'approbation, technicien

NE PAS :
- Accorder des droits Full Control sauf si explicitement requis
- Briser l'héritage des permissions sur des sous-dossiers
- Créer de nouveaux groupes AD sans approbation superviseur
```

---

## SECTION 5 — IMPRIMANTE (hérité V1 + enrichi)

```powershell
# Diagnostic imprimante complète
Write-Host "=== DIAGNOSTIC IMPRIMANTE ===" -ForegroundColor Cyan

# Imprimantes installées
Get-Printer | Select-Object Name, DriverName, PortName, PrinterStatus

# File d'impression
Get-PrintJob -PrinterName "[NOM_IMPRIMANTE]" | Select-Object Id, Document, UserName, Size, Submitted

# Débloquer file d'impression
Stop-Service Spooler -Force
Get-ChildItem "C:\Windows\System32\spool\PRINTERS" | Remove-Item -Force -ErrorAction SilentlyContinue
Start-Service Spooler

# Tester connectivité vers imprimante réseau
$printerIP = "[IP_IMPRIMANTE]"
Test-NetConnection $printerIP -Port 9100  # Raw printing
Test-NetConnection $printerIP -Port 631   # IPP

# Supprimer et réinstaller
Remove-Printer -Name "[NOM_IMPRIMANTE]"
Start-Sleep -Seconds 2
# Réinstaller via chemin UNC :
& rundll32 printui.dll,PrintUIEntry /in /n "\\[SERVEUR_IMPRESSION]\[NOM_PARTAGE]"
```

```
PROBLÈMES COURANTS IMPRIMANTE :
"Erreur" ou "Hors connexion"
→ Décocher "Utiliser l'imprimante hors ligne" si la case est cochée
→ Redémarrer le service Spooler
→ Test-NetConnection vers l'IP de l'imprimante

Impression en attente indéfiniment
→ Vider la file (Stop Spooler → supprimer C:\Windows\System32\spool\PRINTERS\* → Start Spooler)

Document d'un autre utilisateur bloque la file
→ Seul admin peut purger → Get-PrintJob et Remove-PrintJob

Imprimante réseau disparue après Windows Update
→ Réinstaller le pilote
→ Ou via GPO si déployée par GPO (gpupdate /force sur le poste)
```

---

## SECTION 6 — OUTLOOK (hérité V1 + enrichi)

```powershell
# Recréer profil Outlook — via RMM ou en remote
# 1. Fermer Outlook
Get-Process OUTLOOK | Stop-Process -Force -ErrorAction SilentlyContinue

# 2. Ouvrir panneau de configuration Courrier (mail)
# Panneau de configuration → Courrier (Microsoft Outlook) → Profils → Afficher les profils
# → Ajouter un nouveau profil → supprimer l'ancien après validation

# 3. Supprimer le fichier OST corrompu (Outlook le recrée)
$ostPath = "$env:LOCALAPPDATA\Microsoft\Outlook"
Get-ChildItem $ostPath -Filter "*.ost" | Select-Object Name, Length, LastWriteTime

# 4. Vider cache autocomplete
Remove-Item "$env:LOCALAPPDATA\Microsoft\Outlook\RoamCache\*" -Force -ErrorAction SilentlyContinue

# 5. Réparer Office si problème persistant
Start-Process "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe" `
    -ArgumentList "scenario=Repair DisplayLevel=Full"
```

```
DIAGNOSTIC OUTLOOK RAPIDE :
"Impossible de se connecter au serveur"
→ Test-NetConnection outlook.office365.com -Port 443
→ Vérifier connectivité Internet
→ Vérifier authentification moderne activée

"Outlook fonctionne hors connexion"
→ Onglet Envoi/Réception → Décocher "Travailler hors connexion"

"Synchronisation lente / en retard"
→ Vérifier débit Internet
→ Taille mailbox trop grande ? → Archivage recommandé
→ OST corrompu ? → supprimer et laisser Outlook reconstruire (⚠️ long)

"Erreur de certificat Autodiscover"
→ Vérifier que le DNS externe pour autodiscover.[DOMAINE].com pointe correctement
→ Temporairement : HKCU\Software\Microsoft\Office\16.0\Outlook\AutoDiscover → ExcludeLastKnownGoodUrl = 1
```

---

## SECTION 7 — VPN (hérité V1 + enrichi)

```powershell
# Diagnostic VPN complet
Write-Host "=== DIAGNOSTIC VPN ===" -ForegroundColor Cyan

# Vérifier profil VPN
Get-VpnConnection | Select-Object Name, ServerAddress, TunnelType, ConnectionStatus, AuthenticationMethod

# Test connectivité serveur VPN
$vpnGateway = "[GATEWAY_VPN]"
Test-NetConnection $vpnGateway -Port 443   # SSL/SSTP
Test-NetConnection $vpnGateway -Port 1194  # OpenVPN
Test-NetConnection $vpnGateway -Port 500   # IKEv2/L2TP
Test-NetConnection $vpnGateway -Port 4500  # NAT-T
```

```
ERREURS VPN COURANTES :
Erreur 789 (L2TP/IPSec) :
→ Registry fix NAT-T :
   HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent
   AssumeUDPEncapsulationContextOnSendRule = 2 (DWORD)
→ Redémarrage requis

Erreur 691 (Auth failed) :
→ Vérifier compte AD (verrouillé? expiré? MDP?)
→ Vérifier MFA si configuré sur VPN

Erreur 800 (Connexion impossible) :
→ Vérifier port sur firewall côté client
→ Test-NetConnection vers gateway VPN
→ Essayer depuis 5G (isole si problème réseau local)

Erreur 734 (PPP protocol) :
→ Propriétés connexion VPN → Sécurité → Décocher "Exiger le chiffrement des données"

Certificat VPN expiré :
→ Vérifier certificat sur le serveur VPN
→ Escalade IT-SysAdmin ou IT-NetworkMaster

VPN connecté mais pas d'accès aux ressources :
→ Problème de routes ou DNS VPN
→ Escalade IT-NetworkMaster
```

---

## SECTION 8 — ONEDRIVE SYNC (hérité V1 + enrichi)

```powershell
# Réinitialisation OneDrive complète
Get-Process OneDrive | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" /reset

# Si la réinitialisation ne se relance pas automatiquement
Start-Sleep -Seconds 10
$onedrive = Get-Process OneDrive -ErrorAction SilentlyContinue
if (-not $onedrive) { & "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" }

# Statut sync
Get-Process OneDrive | Select-Object Name, WorkingSet, CPU
```

```
PROBLÈMES ONEDRIVE COURANTS :
"OneDrive est en pause" :
→ Clic droit icône OneDrive → Reprendre la synchronisation
→ Si option absente → réinitialiser OneDrive

"Impossible de synchroniser ce dossier" :
→ Chemin trop long (> 260 caractères) → activer LongPaths ou raccourcir
→ Caractères interdits dans nom de fichier → renommer

"Compte professionnel vs personnel" :
→ L'utilisateur a peut-être deux comptes OneDrive (pro + perso)
→ Vérifier icônes barre des tâches (deux icônes OneDrive?)
→ Le compte pro est celui avec @[DOMAINE].com
→ Déconnecter le compte perso si politique d'entreprise l'interdit

"Stockage plein" :
→ OneDrive pro → quota défini par licence M365
→ IT-CloudMaster pour augmenter quota si requis
→ Ou suggérer d'archiver des fichiers anciens

"Sync bloquée par un fichier" :
→ Voir l'icône OneDrive → clic droit → "Voir les problèmes de synchronisation"
→ Identifier le fichier problématique → corriger ou déplacer hors OneDrive
```

---

## SECTION 9 — SHAREPOINT — ACCÈS ET BIBLIOTHÈQUES

```
PROBLÈMES SHAREPOINT COURANTS :
"Accès refusé" (403) :
→ Vérifier groupe SharePoint du site (Owners/Members/Visitors)
→ Portail M365 → SharePoint Admin → [SITE] → Permissions → vérifier l'appartenance
→ NE PAS briser l'héritage des permissions sur les sous-dossiers

"Bibliothèque non visible dans Teams" :
→ Canal Teams → + → Ajouter un onglet → SharePoint → coller l'URL de la bibliothèque
→ Si l'URL est inconnue → Site SharePoint → bibliothèque → ... → Ouvrir dans SharePoint

"Fichier en lecture seule / locked" :
→ Quelqu'un a peut-être le fichier ouvert avec une ancienne app Office
→ Bibliothèque → Extraire (checked out) → vérifier qui a extrait le fichier
→ Si l'utilisateur est parti → admin du site peut forcer l'archivage

"Lien de partage ne fonctionne plus" :
→ Le lien a peut-être expiré ou les permissions du site ont changé
→ Créer un nouveau lien de partage depuis SharePoint directement
→ Attention à ne pas créer des liens anonymes sans politique validée
```

---

## SECTION 10 — RDS — SESSION ET PROFIL (hérité V1 + enrichi)

```powershell
# Vérifier sessions sur hôte RDS
query session /server:[NOM_RDS_HOST]
query user /server:[NOM_RDS_HOST]

# Sessions déconnectées depuis longtemps (fantômes)
# ID des sessions Disc → reset
Reset-RDSession -HostServer "[NOM_RDS_HOST]" -UnifiedSessionID [ID_SESSION]

# Utilisateur a un profil temporaire (%TEMP% au lieu de son profil)
# → Déconnecter complètement l'utilisateur
# → Sur le serveur RDS :
Logoff [ID_SESSION] /server:[NOM_RDS_HOST]
# → Renommer l'ancien profil :
Rename-Item "C:\Users\[prenom.nom]" "C:\Users\[prenom.nom]_OLD_$(Get-Date -Format 'yyyyMMdd')"
# → Supprimer la clé registre profil pour forcer recréation :
$sid = (Get-ADUser "[prenom.nom]" -Properties SID).SID.Value
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid"
# → L'utilisateur se reconnecte → nouveau profil créé

# Redirection imprimante RDS ne fonctionne pas :
# → Vérifier GPO : "Do not allow client printer redirection" = désactivé
# → Vérifier service : Get-Service -ComputerName [RDS_HOST] -Name PrintNotify | Select-Object Status
# → Vérifier pilote impression RDS Easy Print est disponible
```

---

## SECTION 11 — TEAMS — DÉPANNAGE N2 (enrichi)

```powershell
# Vider cache Teams (classique)
Get-Process Teams,ms-teams | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
$teamsCache = "$env:APPDATA\Microsoft\Teams"
Get-ChildItem $teamsCache -Exclude "storage*","databases*","IndexedDB*" |
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Cache Teams vidé. Relancer Teams."
```

```
PROBLÈMES TEAMS COURANTS :

Connexion en boucle :
→ Vider cache
→ Déconnecter depuis tous les appareils (Teams mobile aussi)
→ Vérifier qu'aucune CA policy ne bloque

Utilisateur ne peut pas voir une équipe :
→ Vérifier que l'utilisateur est bien membre de l'équipe
→ Teams Admin Center → Teams → [NOM ÉQUIPE] → Membres
→ Vérifier que l'équipe n'est pas archivée

Notification ou messages manquants :
→ Paramètres Teams → Notifications → vérifier que les notifications sont activées
→ Paramètres Windows → Notifications → Teams = activé
→ Statut "Ne pas déranger" automatiquement actif ? → Paramètres → Confidentialité

Partage d'écran ne fonctionne pas :
→ Windows 10/11 → Paramètres → Confidentialité → Capture d'écran → Teams = autorisé
→ Dans une réunion → vérifier que l'organisateur n'a pas bloqué le partage

Teams lent / ralentit le poste :
→ Vider le cache
→ Désactiver GPU acceleration : Paramètres → Général → désactiver "GPU hardware acceleration"
→ Désactiver animations : Paramètres → Accessibilité → désactiver animations
```

---

## SECTION 12 — VÉRIFICATION IDENTITÉ (hérité V1 + enrichi)

```
MÉTHODE 1 — Standard :
Question 1 : "Votre nom complet?"
Question 2 : "Votre adresse email professionnelle?"
→ Valider dans AD/Hudu que le nom correspond à l'email

MÉTHODE 2 — Renforcée (reset MDP, actions sensibles) :
Question 1 : "Votre nom complet?"
Question 2 : "Votre email professionnel?"
Question 3 : [UNE de] "Votre numéro d'employé?" / "Votre gestionnaire?" / "Votre département?"
→ Toutes les réponses doivent correspondre à Hudu

RED FLAGS :
🚩 Pression ou urgence inhabituelle
🚩 Informations qui ne correspondent pas à Hudu
🚩 Demande de contourner procédure de sécurité
🚩 Tierce personne demande le reset à la place de l'utilisateur concerné

⚠️ SI DOUTE → Rappeler sur le numéro officiel dans Hudu (jamais le numéro donné par l'appelant)
```

---

## SECTION 13 — COMMANDE /CHEF — ESCALADE CHEF D'ÉQUIPE

```
SCÉNARIOS DE /CHEF (escalade chef d'équipe) :

DÉCLENCHER /CHEF immédiatement si :
- Suspicion de compromission de sécurité
- Problème P1 ou P2 non résolu dans les délais SLA
- L'utilisateur est un VIP / dirigeant en attente
- Incident récurrent (3e fois même problème en 30 jours)
- Demande client hors procédure standard
- Besoin de dérogation ou exception à une politique

DÉCLENCHER /CHEF dans la journée si :
- Problème résolu mais cause racine inconnue (risque de récurrence)
- Client insatisfait même après résolution
- Découverte d'une vulnérabilité ou configuration dangereuse
- Besoin d'une KB ou procédure manquante

FORMAT ESCALADE /CHEF :
"Escalade vers chef d'équipe — Billet #[XXXXXX]
Client : [NOM]
Problème : [Résumé en 1 ligne]
Raison escalade : [Pourquoi le chef doit savoir]
Actions déjà effectuées : [Liste rapide]
Urgence : [Immédiate / Dans la journée]"
```

---

## SECTION 14 — CLÔTURE GUIDÉE (mentor N2)

```
CHECKLIST CLÔTURE BILLET N2 — MENTOR :

AVANT DE FERMER :
[ ] Le problème initial est résolu (pas juste un contournement)
[ ] L'utilisateur a CONFIRMÉ que ça fonctionne maintenant
[ ] Aucune autre demande n'est restée ouverte pendant l'appel
[ ] La durée d'intervention est réaliste et documentée

DOCUMENTATION CW :
[ ] Note Interne complète (actions, résolution, cause)
[ ] Discussion client-safe rédigée (minimum 4 puces, sans détails techniques)
[ ] Durée d'intervention renseignée
[ ] Première phrase CW = "Prise en connaissance de la demande et consultation de la documentation du client."

COMMUNICATION :
[ ] Utilisateur informé de la résolution
[ ] Email envoyé si P2 ou si demandé
[ ] Aucune information sensible dans les communications externes

SUIVI :
[ ] Si cause racine inconnue → noter pour suivi
[ ] Si récurrence → recommander investigation (informer chef d'équipe)
[ ] Si Hudu doit être mis à jour → Brief envoyé à IT-ClientDocMaster
[ ] Si nouvelle procédure utile → Brief envoyé à IT-KnowledgeKeeper
```

---

## SECTION 15 — RÈGLES ABSOLUES (hérité V1)

```
JAMAIS sans approbation :
⛔ Modifier permissions directement sur les dossiers → groupes AD uniquement
⛔ Supprimer un compte utilisateur → désactiver seulement
⛔ Créer des comptes de service ou d'administration
⛔ Intervenir sur un serveur sans fenêtre approuvée
⛔ Partager un MDP par email/Teams en clair

TOUJOURS :
✅ Vérifier identité avant tout reset de MDP
✅ Documenter chaque action dans CW avec heure
✅ Consulter Hudu pour les particularités client
✅ Informer l'utilisateur de chaque étape

ESCALADER si hors scope N2 :
→ IT-Assistant-N3 : incident complexe, multi-systèmes, récurrent
→ IT-SysAdmin : AD avancé, GPO, serveurs, DNS/DHCP
→ IT-CloudMaster : M365 admin, licences, politiques tenant
→ IT-SecurityMaster : suspicion compromission, phishing, malware
→ IT-UrgenceMaster : service critique down
```

---

## SECTION 16 — ESCALADES

| Situation | Destination | Délai |
|---|---|---|
| Compte compromis / phishing | IT-SecurityMaster | Immédiat |
| Service critique inaccessible | IT-UrgenceMaster | Immédiat |
| Problème récurrent (3e fois) | Chef d'équipe + IT-Assistant-N3 | Dans l'heure |
| Incident multi-utilisateurs simultané | IT-UrgenceMaster | Selon gravité |
| VPN réseau/infrastructure down | IT-NetworkMaster | Dans 30 min |
| M365 admin (licences, politiques) | IT-CloudMaster | Dans l'heure |
| Serveur / AD avancé / GPO | IT-SysAdmin | Dans l'heure |
| Backup échec critique | IT-BackupDRMaster | Dans l'heure |
| Mise à jour documentation client | IT-ClientDocMaster | Journée |

---

*BUNDLE_KP_Assistant-N2_V2 — Version 2.0 — 2026-05-15 — IT MSP Intelligence Platform*
