# BUNDLE_KP_FrontLine_V2
**Agent :** @IT-FrontLine
**Version :** 2.0 | **Date :** 2026-05-15
**Type :** KnowledgePack GPT — Fallback GitHub
**Contenu :** Rôle FrontLine, matrice SLA, scripts N2 (AD, réseau, imprimante, Outlook, VPN, OneDrive, Teams, RDS, poste), flux MSPBOT/appel direct, sécurité identité, escalades, templates CW.

---

## SECTION 1 — RÔLE ET CONTEXTE (hérité V1)

```
@IT-FrontLine est le premier niveau de support MSP.
Deux flux d'entrée :
1. MSPBOT : l'utilisateur passe par le bot — FrontLine reçoit le contexte
2. Appel direct : FrontLine répond directement au téléphone

RÔLE :
- Triage et classification des incidents
- Résolution N1/N2 directement si dans le scope
- Escalade structurée vers N3/SysAdmin/Spécialiste si nécessaire
- Documentation systématique dans CW
- Communication client professionnelle en tout temps

SCOPE FRONTLINE (résoudre directement) :
- MDP/compte verrouillé
- Imprimante (locale et réseau)
- Outlook (profil, synchronisation, règles)
- VPN utilisateur
- OneDrive sync
- Teams (audio, cache, connexion)
- Poste lent, espace disque, Windows Update
- Accès réseau/partages (sans modification de groupes)
- RDS — connexion utilisateur (pas infrastructure)
- M365 end-user (licence, app activation)
```

---

## SECTION 2 — MATRICE SLA P1/P2/P3/P4 (hérité V1)

| Priorité | Définition | Exemples | Délai réponse | Délai résolution cible |
|---|---|---|---|---|
| P1 | Service critique arrêté, impact majeur | DC down, site complet, ransomware | < 15 min | < 4h |
| P2 | Dégradation notable, plusieurs usagers | VPN multi-usagers, M365 partiel, serveur dégradé | < 30 min | < 8h |
| P3 | Incident limité, 1 usager | Imprimante, Outlook, poste lent | < 2h | < NBH |
| P4 | Demande de service, question | Ajout logiciel, guide, demande info | < NBH | Planifié |

```
NBH = Next Business Hours
```

---

## SECTION 3 — SCRIPT DÉBUT D'APPEL ENRICHI

### Ouverture d'appel avec vérification sécurité
```
SCRIPT APPEL ENTRANT :

"Support technique [NOM MSP], [Prénom] à l'appareil — bonne [matin/après-midi/soirée].

Puis-je avoir votre nom complet et le nom de votre entreprise?"

[Note le nom et l'entreprise]

"Et pour quelle raison vous appelez-vous aujourd'hui?"

[Écoute le problème — ne pas interrompre]

"Merci. Pour pouvoir vous aider, je dois d'abord confirmer votre identité.

Pouvez-vous me donner votre adresse email professionnelle?"

[Si reset MDP ou action sensible — vérification renforcée]
"Et pouvez-vous me confirmer votre numéro de téléphone de bureau, ou le nom de votre gestionnaire direct?"

[Si incertitude sur l'identité]
→ NE PAS procéder
→ "Je vais vérifier votre dossier et vous rappeler sur le numéro enregistré."
→ Appeler sur le numéro Hudu — jamais sur le numéro fourni par l'appelant

QUESTIONS DE SÉCURITÉ OBLIGATOIRES avant reset MDP :
1. "Pouvez-vous me confirmer votre nom complet?" ✓
2. "Votre adresse email professionnelle?" ✓
3. [Choisir 1 parmi] :
   - "Votre numéro d'employé si applicable?"
   - "Le nom de votre gestionnaire?"
   - "Votre département?"
```

---

## SECTION 4 — SCRIPTS POWERSHELL N2 (hérité V1 + enrichi)

### Active Directory — MDP et comptes
```powershell
# Vérifier statut du compte
Get-ADUser "[prenom.nom]" -Properties LockedOut, PasswordExpired, PasswordLastSet, LastLogonDate |
    Select-Object Name, SamAccountName, Enabled, LockedOut, PasswordExpired, PasswordLastSet, LastLogonDate

# Déverrouiller compte
Unlock-ADAccount -Identity "[prenom.nom]"

# Réinitialiser MDP (VÉRIFIER IDENTITÉ AVANT)
Set-ADAccountPassword "[prenom.nom]" -Reset -NewPassword (Read-Host -AsSecureString "Nouveau MDP")
Set-ADUser "[prenom.nom]" -ChangePasswordAtLogon $true
Unlock-ADAccount "[prenom.nom]"

# Rechercher compte par email
Get-ADUser -Filter { EmailAddress -eq "[email@domaine.com]" } | Select-Object Name, SamAccountName, Enabled

# Groupes d'un utilisateur
(Get-ADUser "[prenom.nom]" -Properties MemberOf).MemberOf | ForEach-Object { (Get-ADGroup $_).Name } | Sort-Object

# Vérifier si l'utilisateur est dans un groupe spécifique
(Get-ADGroupMember "[NOM_GROUPE]").SamAccountName -contains "[prenom.nom]"
```

### Réseau — Diagnostics
```powershell
# Diagnostic réseau complet (à lancer sur le poste de l'utilisateur via RMM)
function Invoke-NetworkDiag {
    Write-Host "=== DIAGNOSTIC RÉSEAU ===" -ForegroundColor Cyan
    
    # IP et DNS
    $ip = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "Loopback*" }
    Write-Host "IP : $($ip.IPAddress) | Préfixe : /$($ip.PrefixLength)"
    
    # Passerelle
    $gw = (Get-NetRoute -DestinationPrefix "0.0.0.0/0").NextHop
    Write-Host "Passerelle : $gw"
    $pingGW = Test-Connection $gw -Count 2 -Quiet
    Write-Host "Ping passerelle : $(if ($pingGW) {'✅'} else {'❌'})"
    
    # DNS
    $dns = (Get-DnsClientServerAddress -AddressFamily IPv4).ServerAddresses
    Write-Host "Serveurs DNS : $($dns -join ', ')"
    
    # Internet
    $pingNet = Test-Connection "8.8.8.8" -Count 2 -Quiet
    Write-Host "Internet (8.8.8.8) : $(if ($pingNet) {'✅'} else {'❌'})"
    
    # Résolution DNS
    $dnsTest = Resolve-DnsName "microsoft.com" -ErrorAction SilentlyContinue
    Write-Host "Résolution DNS : $(if ($dnsTest) {'✅'} else {'❌ PROBLÈME DNS'})"
}
Invoke-NetworkDiag
```

### Imprimante
```powershell
# Lister imprimantes installées
Get-Printer | Select-Object Name, DriverName, PortName, Shared, PrinterStatus

# Vider la file d'impression bloquée
Stop-Service Spooler -Force
Get-ChildItem "C:\Windows\System32\spool\PRINTERS" | Remove-Item -Force
Start-Service Spooler

# Supprimer une imprimante
Remove-Printer -Name "[NOM_IMPRIMANTE]"

# Ajouter imprimante réseau
Add-Printer -Name "[NOM_IMPRIMANTE]" -DriverName "[NOM_DRIVER]" -PortName "[PORTIP_IMPRIMANTE]"
# Ou via chemin UNC :
& rundll32 printui.dll,PrintUIEntry /in /n "\\[SERVEUR_IMPRESSION]\[NOM_PARTAGE]"

# Pilotes installés
Get-PrinterDriver | Select-Object Name, Manufacturer, DriverVersion
```

### Outlook — Dépannage
```powershell
# Reconstruire profil Outlook — via CMD ou RMM
# Supprimer profil Outlook existant (⚠️ sauvegarde données PST si applicable)
$profilePath = "HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles"
Get-ChildItem $profilePath | Select-Object Name

# Réinitialiser AUTODISCOVER
$regPath = "HKCU:\Software\Microsoft\Office\16.0\Outlook\AutoDiscover"
if (!(Test-Path $regPath)) { New-Item -Path $regPath -Force }
Set-ItemProperty -Path $regPath -Name "ExcludeLastKnownGoodUrl" -Value 1 -Type DWord

# Reconstruire OST
# Outlook → Compte → Plus de paramètres → Fichier de données → Supprimer le fichier OST
# → Outlook reconstruira à la prochaine ouverture

# Tester connectivité Outlook (Autodiscover)
# Depuis Outlook : Ctrl + clic droit sur icône barre des tâches → "Tester la configuration de messagerie automatique"

# Script Outlook — vider cache autocomplete
Remove-Item "$env:APPDATA\Microsoft\Outlook\*.nk2" -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Microsoft\Outlook\RoamCache\*.dat" -ErrorAction SilentlyContinue

# Réparer Office
Start-Process "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeC2RClient.exe" -ArgumentList "scenario=Repair DisplayLevel=Full"
```

### VPN — Dépannage
```powershell
# Erreur 789 (L2TP derrière NAT)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\PolicyAgent" `
    -Name "AssumeUDPEncapsulationContextOnSendRule" -Value 2 -Type DWord
# ⚠️ Redémarrage requis

# Vérifier profil VPN Windows existant
Get-VpnConnection | Select-Object Name, ServerAddress, TunnelType, ConnectionStatus

# Tester connectivité vers serveur VPN
Test-NetConnection "[GATEWAY_VPN]" -Port 443  # SSL VPN
Test-NetConnection "[GATEWAY_VPN]" -Port 1194 # OpenVPN
Test-NetConnection "[GATEWAY_VPN]" -Port 500  # IKEv2

# Supprimer et recréer profil VPN (si profil corrompu)
Remove-VpnConnection -Name "[NOM_VPN]" -Force
# → Reconfigurer depuis zéro avec les paramètres Passportal

# ⚠️ NE JAMAIS demander le MDP VPN → utiliser Passportal
```

### OneDrive — Sync et dépannage
```powershell
# Réinitialiser OneDrive
Get-Process "OneDrive" | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" /reset
Start-Sleep -Seconds 5
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"

# Vérifier le statut de sync OneDrive
Get-Process OneDrive | Select-Object Name, CPU, WorkingSet

# Forcer synchronisation d'un dossier spécifique
# Clic droit sur le dossier OneDrive → "Toujours disponible sur cet appareil"

# OneDrive — fichiers exclus de la sync (caractères interdits)
# Caractères interdits : " * : < > ? / \ |
# Noms réservés : CON, PRN, AUX, NUL, COM1-9, LPT1-9
# → Renommer les fichiers problématiques avant de tenter la sync

# Vérifier quel compte OneDrive est connecté
Get-ChildItem "$env:USERPROFILE\OneDrive*" | Select-Object Name, FullName

# Déconnexion et reconnexion compte OneDrive
# Barre des tâches → icône OneDrive → Paramètres → Compte → Dissocier ce PC
# → Se reconnecter avec le compte pro
```

### Teams — Cache et dépannage
```powershell
# Vider cache Teams (application classique)
Get-Process Teams | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
$teamsCache = "$env:APPDATA\Microsoft\Teams"
Get-ChildItem $teamsCache -Exclude "storage*","databases*","IndexedDB*" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "Cache Teams vidé. Relancer Teams."

# Teams New (nouveau client)
Get-Process ms-teams | Stop-Process -Force -ErrorAction SilentlyContinue
$newTeamsCache = "$env:LOCALAPPDATA\Packages\MSTeams_8wekyb3d8bbwe\LocalCache"
if (Test-Path $newTeamsCache) {
    Get-ChildItem $newTeamsCache | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

# Réinstaller Teams (si cache ne règle pas)
# Désinstaller : Paramètres Windows → Applications → Microsoft Teams
# Réinstaller : https://teams.microsoft.com/downloads
```

### Problèmes Teams audio/vidéo
```
AUDIO/VIDÉO TEAMS — DIAGNOSTIC :
1. Vérifier périphériques dans Teams :
   → (...) → Paramètres → Appareils → tester micro et caméra

2. Pilotes audio/vidéo :
   Gestionnaire de périphériques → Contrôleurs audio → Mettre à jour le pilote

3. Permissions Windows :
   Paramètres → Confidentialité → Microphone → Teams = Autorisé
   Paramètres → Confidentialité → Caméra → Teams = Autorisé

4. Pilote USB/Bluetooth :
   Si casque USB → tester avec un autre port USB
   Si casque Bluetooth → supprimer et ré-appairer

5. Réinitialiser paramètres audio Teams :
   → Fermer Teams → vider cache → relancer → reconfigurer appareils
```

---

## SECTION 5 — RDS — DÉPANNAGE UTILISATEUR

### Connexion RDS qui ne démarre pas
```powershell
# Vérifier accès RDS (depuis serveur RDS ou via RMM)
query session /server:[NOM_RDS_HOST]
query user /server:[NOM_RDS_HOST]

# Sessions fantômes (Disc depuis longtemps)
query session /server:[NOM_RDS_HOST] | Where-Object { $_ -like "*Disc*" }
# Reset session fantôme :
Reset-RDSession -HostServer "[NOM_RDS_HOST]" -UnifiedSessionID [ID_SESSION]

# Vérifier groupe "Remote Desktop Users" dans AD
Get-ADGroupMember "Remote Desktop Users" | Select-Object Name, SamAccountName

# Si "Accès refusé" :
# → Vérifier que l'utilisateur est membre de "Remote Desktop Users" sur le serveur
# → Vérifier GPO "Allow log on through Remote Desktop Services"
# → Computer → Policies → Windows Settings → Security Settings → User Rights → Allow log on through RDS
```

### Profil RDS corrompu ou temporaire
```powershell
# Symptôme : utilisateur démarre avec "profil temporaire" ou bureau vide

# 1. S'assurer que l'utilisateur est déconnecté du serveur RDS
query user "[prenom.nom]" /server:[NOM_RDS_HOST]
Logoff [ID_SESSION] /server:[NOM_RDS_HOST]

# 2. Renommer le profil corrompu (NE PAS supprimer — garder pour récupération)
Rename-Item "C:\Users\[prenom.nom]" "C:\Users\[prenom.nom]_OLD_$(Get-Date -Format 'yyyyMMdd')"

# 3. Supprimer la clé de registre du profil
$sid = (Get-ADUser "[prenom.nom]" -Properties SID).SID.Value
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$sid" -ErrorAction SilentlyContinue

# 4. Reconnexion : un nouveau profil sera créé automatiquement

# 5. Récupérer les fichiers importants depuis l'ancien profil :
# C:\Users\[prenom.nom]_OLD\Desktop, Documents, AppData\Roaming\Microsoft\Outlook, etc.
```

---

## SECTION 6 — POSTE DE TRAVAIL

### Windows Update bloqué
```powershell
# Réinitialiser Windows Update
Stop-Service wuauserv, cryptSvc, bits, msiserver -Force
Rename-Item "C:\Windows\SoftwareDistribution" "C:\Windows\SoftwareDistribution.old" -ErrorAction SilentlyContinue
Rename-Item "C:\Windows\System32\catroot2" "C:\Windows\System32\catroot2.old" -ErrorAction SilentlyContinue
Start-Service wuauserv, cryptSvc, bits, msiserver

# Forcer la recherche de mises à jour
(New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()

# Outil de dépannage Windows Update
Start-Process "$env:SystemRoot\System32\msdt.exe" -ArgumentList "/id WindowsUpdateDiagnostic"
```

### Profil lent / espace disque
```powershell
# Espace disque utilisé par profil
$userProfile = "C:\Users\[prenom.nom]"
Get-ChildItem $userProfile -Directory | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
    [PSCustomObject]@{Dossier=$_.Name; TailleMB=[math]::Round($size/1MB,1)}
} | Sort-Object TailleMB -Descending | Format-Table

# Nettoyage disque
cleanmgr /sagerun:1 /sageset:1  # Interactif
# Ou silencieux :
Start-Process cleanmgr -ArgumentList "/d C: /sagerun:100" -Wait

# Vider corbeille
Clear-RecycleBin -DriveLetter C -Force

# Dossier Temp utilisateur
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Top 5 fichiers les plus lourds dans le profil
Get-ChildItem "C:\Users\[prenom.nom]" -Recurse -ErrorAction SilentlyContinue |
    Sort-Object Length -Descending | Select-Object -First 5 FullName, @{N='SizeMB';E={[math]::Round($_.Length/1MB,1)}}
```

---

## SECTION 7 — M365 END-USER

### Activation applications Office
```powershell
# Vérifier statut activation Office
cscript "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /dstatus

# Forcer activation en ligne
cscript "C:\Program Files\Microsoft Office\Office16\OSPP.VBS" /act

# Si activation échoue → désactiver et réactiver la licence
# Paramètres Windows → Comptes → Email et comptes → supprimer compte Microsoft
# → Réajouter le compte M365
```

### MFA en boucle (end-user)
```
SOLUTION MFA EN BOUCLE — UTILISATEUR FINAL :

1. Vider cache navigateur :
   → Chrome/Edge : Ctrl+Shift+Del → Cocher tout → Effacer
   → Redémarrer le navigateur

2. Déconnexion de tous les appareils :
   → office.com → Photo de profil → Se déconnecter de partout
   → Puis se reconnecter depuis zéro

3. Application Authenticator — renouveler :
   → Si message "Activité suspecte" → approuver l'invite sur l'application
   → Si application ne répond plus → appeler le support pour reset MFA

4. Escalade vers IT-CloudMaster si :
   → L'utilisateur est définitivement bloqué
   → Aucun des appareils MFA ne répond
   → Besoin de Temporary Access Pass (TAP)
```

---

## SECTION 8 — FLUX MSPBOT (hérité V1)

```
FLUX MSPBOT :

1. Utilisateur → Bot MSPBOT
2. MSPBOT collecte : nom, problème, urgence
3. MSPBOT crée ou route le billet dans CW
4. @IT-FrontLine reçoit le contexte préparé
5. FrontLine triage et répond (ou escalade structurée)

CONTENU MINIMUM REÇU DE MSPBOT :
- Nom et entreprise du client
- Description du problème (telle que rapportée)
- Classification provisoire (P3/P4 le plus souvent)
- Numéro de billet CW créé

ACTIONS FRONTLINE APRÈS MSPBOT :
1. Lire le contexte MSPBOT
2. Consulter Hudu (documentation client)
3. Déterminer si N2 ou escalade requise
4. Contacter l'utilisateur si nécessaire
5. Documenter toutes les actions dans CW
```

---

## SECTION 9 — VÉRIFICATION IDENTITÉ (hérité V1 + enrichi)

```
MÉTHODE 1 — Vérification standard :
"Votre nom complet?" + "Votre adresse email professionnelle?"
→ Valider que l'email correspond au compte dans Hudu/AD

MÉTHODE 2 — Vérification renforcée (reset MDP, accès sensible) :
"Votre nom complet?" + "Votre email?" + [UNE de] :
- "Votre numéro d'employé ou de poste?"
- "Le nom de votre gestionnaire direct?"
- "Votre département et location?"

SITUATIONS NÉCESSITANT MÉTHODE 2 :
- Réinitialisation de mot de passe
- Désactivation/activation de compte
- Accès à un autre compte (au nom de quelqu'un)
- Toute demande "urgente" d'un inconnu

RED FLAGS — NE PAS PROCÉDER :
🚩 "Mon gestionnaire m'a dit que vous pouvez le faire rapidement"
🚩 "Je ne peux pas vous donner mon email — faites-le avec mon compte"
🚩 Pression excessive / ton inhabituel
🚩 Demande de contourner une politique de sécurité
🚩 Informations inconsistantes avec Hudu

SI DOUTE → Rappeler sur le numéro HUDU (jamais le numéro de l'appelant)
```

---

## SECTION 10 — TEMPLATES CW (hérité V1)

### Note Triage (billet entrant)
```
Prise en connaissance de la demande et consultation de la documentation du client.

## Triage
Billet : #[XXXXXX] | Client : [NOM] | Priorité : P[X]
Source : [Appel / MSPBOT / Email / RMM]
Rapporté par : [Nom utilisateur]

Problème rapporté : [Description fidèle — mots de l'utilisateur]
Impact déclaré : [Combien de personnes / quelle urgence]

## Évaluation
Classification : [P1/P2/P3/P4]
Scope : [N2 FrontLine / Escalade → Qui]
Consultation Hudu : [Particularités client pertinentes]

## Prochaine action
[Action immédiate ou escalade planifiée]
```

### Note Interne — Intervention N2
```
Prise en connaissance de la demande et consultation de la documentation du client.

## Contexte
[Description du problème]

## Actions effectuées
- [Action 1 — outil — résultat]
- [Action 2 — outil — résultat]
- [Validation — résultat]

## Résolution
[Résolu / Escaladé — détails]

## Validation
- Utilisateur a confirmé le bon fonctionnement : [Oui/Non]
- Durée : [HH:MM]
```

### Discussion CW (client-safe)
```
Prise en connaissance de la demande et consultation de la documentation du client.

### TRAVAUX EFFECTUÉS
- Prise en charge de la demande et revue de la configuration
- [Action 1 en langage client]
- [Action 2 en langage client]
- Tests de validation effectués
- Confirmation du bon fonctionnement avec l'utilisateur

### RÉSULTAT
[Description du résultat final — simple et clair]

Durée : [X]h[XX]min
```

---

## SECTION 11 — GARDE-FOUS ABSOLUS (hérité V1)

```
JAMAIS sans approbation superviseur :
- Modifier des permissions directement sur les dossiers (toujours via groupes AD)
- Supprimer un compte utilisateur (désactiver seulement)
- Intervenir sur un serveur en production sans fenêtre approuvée
- Partager un mot de passe par email ou Teams non chiffré
- Procéder avec un billet sans numéro CW documenté

TOUJOURS :
- Vérifier l'identité avant tout reset de MDP
- Consulter Hudu avant d'intervenir chez un client
- Documenter chaque action dans CW en temps réel
- Informer le client avant et après intervention
- Créer un snapshot avant toute intervention serveur

ESCALADER IMMÉDIATEMENT si :
- Suspicion de compromission / phishing / ransomware → IT-SecurityMaster
- Serveur inaccessible → IT-UrgenceMaster
- Plusieurs utilisateurs affectés par le même problème → P1/P2
- Demande clairement hors scope FrontLine
```

---

## SECTION 12 — ESCALADES PAR DOMAINE (hérité V1 + enrichi)

| Domaine | Situation | Destination | Délai |
|---|---|---|---|
| Sécurité | Phishing réussi, compte compromis | IT-SecurityMaster | Immédiat |
| Sécurité | Ransomware détecté | IT-UrgenceMaster + IT-SecurityMaster | Immédiat |
| Infrastructure | Serveur inaccessible | IT-UrgenceMaster | Immédiat |
| AD avancé | GPO, OU, réplication | IT-SysAdmin | < 30 min |
| M365 admin | Licences, politiques, tenant | IT-CloudMaster | < 1h |
| Backup | Job en échec critique | IT-BackupDRMaster | < 1h |
| Réseau site | WAN down, VLAN | IT-NetworkMaster | Selon priorité |
| Documentation | Mise à jour env. client | IT-ClientDocMaster | Journée |
| N3 | Incident complexe multi-systèmes | IT-Assistant-N3 | Selon priorité |

### Protocole escalade P1
```
1. Notice Teams NOC — immédiat (template Section 2)
2. Chef d'équipe — appel téléphonique si P1
3. Ouvrir billet CW P1 avec toutes les informations collectées
4. Rester disponible pour support au technicien escalade
5. Communication client — 15 min après escalade
```

---

*BUNDLE_KP_FrontLine_V2 — Version 2.0 — 2026-05-15 — IT MSP Intelligence Platform*
