# BUNDLE_KP_SecurityMaster_V2
**Agent :** @IT-SecurityMaster
**Version :** 2.0 | **Date :** 2026-05-15
**Type :** KnowledgePack GPT — Fallback GitHub
**Contenu :** Matrice incidents, IR/forensics, BEC playbook, insider threat, account takeover, Defender for Endpoint, Microsoft Sentinel KQL, Zero Trust assessment, hardening post-incident, rapport d'incident, escalades.

---

## SECTION 1 — MATRICE INCIDENTS SÉCURITÉ (hérité V1)

| Priorité | Type | Exemples | Réponse |
|---|---|---|---|
| P1 | Critique | Ransomware actif, exfiltration données, compromission admin, DC compromis | Isolation immédiate + SOC + Management |
| P1 | Critique | BEC confirmé avec transaction frauduleuse, accès physique non autorisé | Isolation + Juridique + Management |
| P2 | Haute | Phishing réussi (credentials volés), mouvement latéral détecté | Confinement + Investigation dans l'heure |
| P2 | Haute | Malware sur poste, accès suspect à des données sensibles | Isolation poste + Analyse |
| P3 | Normale | Tentatives bruteforce bloquées, phishing intercepté | Documentation + monitoring renforcé |
| P3 | Normale | Politique de sécurité non respectée | Correction + sensibilisation |

---

## SECTION 2 — RÉPONSE À INCIDENT — PHASE 1 : CONFINEMENT (hérité V1)

### Isolation réseau immédiate
```powershell
# Bloquer tout trafic réseau (poste compromis — Windows)
# Option 1 : via Firewall Windows
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound
netsh advfirewall set allprofiles state on

# Option 2 : Désactiver carte réseau
Get-NetAdapter | Disable-NetAdapter -Confirm:$false

# Réactiver (après investigation)
Get-NetAdapter | Enable-NetAdapter -Confirm:$false
netsh advfirewall set allprofiles firewallpolicy blockinbound,allowoutbound
```

### Révoquer accès M365 (compte compromis)
```powershell
# Connexion
Connect-ExchangeOnline -UserPrincipalName "[ADMIN]@[DOMAINE].com"
Connect-MgGraph -Scopes "User.ReadWrite.All"

# 1. Désactiver le compte
Update-MgUser -UserId "[user]@[DOMAINE].com" -AccountEnabled $false

# 2. Révoquer toutes les sessions actives
Revoke-MgUserSignInSession -UserId "[user]@[DOMAINE].com"

# 3. Réinitialiser MDP avec MFA obligatoire
# Portail Entra → Users → [USER] → Reset password → Auto-generate

# 4. Réinitialiser les méthodes MFA
# Portail Entra → Users → [USER] → Authentication methods → Delete all

# 5. Vérifier règles Outlook suspectes
Get-InboxRule -Mailbox "[user]@[DOMAINE].com" | Select-Object Name, Enabled, ForwardTo, DeleteMessage, RedirectTo | Format-List
# Supprimer règle suspecte :
Remove-InboxRule -Mailbox "[user]@[DOMAINE].com" -Identity "[NOM_REGLE]" -Confirm:$false

# 6. Supprimer transferts automatiques
Set-Mailbox "[user]@[DOMAINE].com" -ForwardingSmtpAddress $null -DeliverToMailboxAndForward $false

# 7. Révoquer OAuth grants
$grants = Get-MgUserOauth2PermissionGrant -UserId "[user]@[DOMAINE].com"
foreach ($grant in $grants) { Remove-MgUserOauth2PermissionGrant -OAuth2PermissionGrantId $grant.Id }
```

---

## SECTION 3 — RÉPONSE À INCIDENT — PHASE 2 : FORENSICS (hérité V1)

### Script de collecte forensics
```powershell
# ===== COLLECTE FORENSICS — POSTE COMPROMIS =====
$OutputDir = "C:\Forensics_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $OutputDir | Out-Null

# Informations système
Get-ComputerInfo | Out-File "$OutputDir\SystemInfo.txt"

# Processus actifs avec hash
Get-Process | Select-Object Name, Id, Path, Company, CPU, WorkingSet | Export-Csv "$OutputDir\Processes.csv" -NoTypeInformation
Get-Process | Where-Object {$_.Path} | ForEach-Object { 
    Get-FileHash $_.Path -ErrorAction SilentlyContinue 
} | Export-Csv "$OutputDir\ProcessHashes.csv" -NoTypeInformation

# Connexions réseau actives
Get-NetTCPConnection -State Established | 
    Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess |
    Export-Csv "$OutputDir\NetworkConnections.csv" -NoTypeInformation

# Connexions sortantes suspects
Get-NetTCPConnection -State Established | Where-Object { $_.RemotePort -notin @(80,443,3389) } |
    Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess | Format-Table

# Services installés récemment
Get-Service | Where-Object { $_.StartType -ne "Disabled" } | Sort-Object DisplayName |
    Export-Csv "$OutputDir\Services.csv" -NoTypeInformation

# Tâches planifiées suspectes
Get-ScheduledTask | Where-Object { $_.TaskPath -notlike "\Microsoft\*" } | 
    Select-Object TaskName, TaskPath, State | Export-Csv "$OutputDir\ScheduledTasks.csv" -NoTypeInformation

# Comptes locaux
Get-LocalUser | Export-Csv "$OutputDir\LocalUsers.csv" -NoTypeInformation
Get-LocalGroupMember -Group "Administrators" | Export-Csv "$OutputDir\LocalAdmins.csv" -NoTypeInformation

# Fichiers récemment modifiés (72h)
Get-ChildItem C:\, C:\Users, C:\Windows\Temp -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -gt (Get-Date).AddHours(-72) -and -not $_.PSIsContainer } |
    Select-Object FullName, LastWriteTime, Length | 
    Export-Csv "$OutputDir\RecentFiles.csv" -NoTypeInformation

# Event logs — Security (connexions et privilèges)
Get-WinEvent -LogName Security -MaxEvents 1000 -FilterHashtable @{LogName='Security'; Id=@(4624,4625,4648,4672,4720,4732)} |
    Select-Object TimeCreated, Id, Message | Export-Csv "$OutputDir\SecurityEvents.csv" -NoTypeInformation

# Autorun locations
reg export HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run "$OutputDir\RunKeys.reg" /y
reg export HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run "$OutputDir\RunKeysUser.reg" /y

Write-Host "Collecte forensics terminée : $OutputDir" -ForegroundColor Green
```

---

## SECTION 4 — PLAYBOOK BEC (BUSINESS EMAIL COMPROMISE)

### Indicateurs BEC
```
SIGNES D'ALERTE BEC :
- Email envoyé depuis domaine similaire (homoglyphe : acme.com vs acnne.com)
- Règle Outlook créée récemment → forwarding vers externe
- Changement de coordonnées bancaires demandé par email
- Demande urgente de virement "confidentiel"
- Conversation email avec "reply-to" différent du "from"
- Connexions depuis pays non habituels (sign-in logs)
```

### Procédure BEC confirmé
```
ÉTAPE 1 — CONFINEMENT IMMÉDIAT (< 15 min)
[ ] Désactiver le compte compromis (Entra ID)
[ ] Révoquer toutes les sessions actives
[ ] Bloquer l'expéditeur externe si BEC entrant (Mail Flow Rules)
[ ] Alerter le responsable financier du client — NE PAS transférer d'argent
[ ] Alerter le superviseur / chef d'équipe

ÉTAPE 2 — INVESTIGATION (< 1h)
[ ] Sign-in logs — depuis où et quand (Entra ID → Sign-in logs)
[ ] Audit log M365 — actions effectuées avec le compte
[ ] Règles Outlook — identifier et supprimer
[ ] Transferts email automatiques — vérifier et supprimer
[ ] OAuth apps autorisées — vérifier et révoquer
[ ] Emails envoyés depuis le compte compromis — identifier destinataires

ÉTAPE 3 — COMMUNICATION
[ ] Email interne NOC — résumé de la situation
[ ] Alerte au responsable du client (par téléphone si transaction financière)
[ ] Si virement effectué → banque du client doit être contactée dans l'heure
[ ] Documentation CW en temps réel (Note Interne P1)
```

```powershell
# Audit log BEC — actions du compte compromis (derniers 30 jours)
Connect-ExchangeOnline -UserPrincipalName "[ADMIN]@[DOMAINE].com"
Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-30) -EndDate (Get-Date) `
    -UserIds "[user.compromis]@[DOMAINE].com" -ResultSize 500 |
    Select-Object CreationDate, Operations, UserIds, AuditData | 
    Export-Csv "C:\Temp\BEC_AuditLog.csv" -NoTypeInformation

# Emails envoyés depuis le compte compromis
Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-30) -EndDate (Get-Date) `
    -UserIds "[user.compromis]@[DOMAINE].com" -Operations "Send,SendAs,SendOnBehalf" -ResultSize 500 |
    Select-Object CreationDate, Operations, AuditData
```

---

## SECTION 5 — INSIDER THREAT

### Indicateurs de menace interne
```
COMPORTEMENTS SUSPECTS À SIGNALER :
- Téléchargements massifs de fichiers hors des heures normales
- Accès à des dossiers inhabituels pour le rôle
- Copie vers clé USB / cloud personnel
- Tentatives d'accès refusées répétées sur des ressources sensibles
- Désactivation de l'antivirus / logs de sécurité
- Connexions hors des heures normales (nuit, weekends)
- Recherches inhabituelles dans les systèmes (RH, finances, R&D)
```

### Procédure investigation insider threat
```
⚠️ RÈGLE FONDAMENTALE : Investigation doit être approuvée par management AVANT toute action.
Ne JAMAIS confronter l'employé suspect pendant l'investigation.

COLLECTE PREUVES (mode furtif — pas d'alerte à l'utilisateur) :
[ ] Audit logs SharePoint/OneDrive — activité de l'utilisateur
[ ] DLP alerts — données sensibles déplacées
[ ] Azure AD sign-in logs — patterns de connexion inhabituels
[ ] Defender for Endpoint — activité fichiers/processus

NE PAS :
- Bloquer le compte sans approbation management + RH + légal
- Partager les détails de l'investigation avec d'autres employés
- Modifier ou supprimer des preuves potentielles
```

```powershell
# Activité SharePoint/OneDrive d'un utilisateur
Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-30) -EndDate (Get-Date) `
    -UserIds "[suspect]@[DOMAINE].com" `
    -Operations "FileDownloaded,FileCopied,FileAccessed,SharingSet,AnonymousLinkCreated" `
    -ResultSize 1000 | Select-Object CreationDate, Operations, AuditData
```

---

## SECTION 6 — ACCOUNT TAKEOVER (O365)

### Indicateurs d'ATO
```
SIGNAUX D'ALERTE O365 ATO :
- Connexion depuis nouveau pays ou impossible travel (deux pays en < 2h)
- Connexion depuis IP de datacenter/VPN/TOR
- Spike d'envois d'emails depuis le compte
- Création de règles Outlook nouvelles
- Modifications paramètres mailbox (forwarding, alias)
- Connexion depuis appareil inconnu / non conforme
- Tentative d'accès à l'administration (si compte non-admin)
```

### Procédure ATO O365
```powershell
# INVESTIGATION ATO — Étapes dans l'ordre

# 1. Connexions récentes (50 dernières)
Get-MgAuditLogSignIn -Filter "userPrincipalName eq '[user]@[DOMAINE].com'" -Top 50 |
    Select-Object CreatedDateTime, IPAddress, Location, ClientAppUsed, ConditionalAccessStatus, RiskLevelDuringSignIn |
    Format-Table

# 2. Règles mailbox
Get-InboxRule -Mailbox "[user]@[DOMAINE].com" | Select-Object Name, Enabled, ForwardTo, DeleteMessage, MoveToFolder | Format-List

# 3. Délégations mailbox
Get-MailboxPermission "[user]@[DOMAINE].com" | Where-Object { $_.User -notlike "*SELF*" -and $_.User -notlike "*NT AUTHORITY*" }

# 4. Applications OAuth autorisées
Get-MgUserOauth2PermissionGrant -UserId "[user]@[DOMAINE].com" | Select-Object ClientId, Scope

# 5. Vérifier si l'utilisateur a ajouté un MFA backup
# Portail Entra → Users → [USER] → Authentication methods

# CONFINEMENT IMMÉDIAT SI ATO CONFIRMÉ
Update-MgUser -UserId "[user]@[DOMAINE].com" -AccountEnabled $false
Revoke-MgUserSignInSession -UserId "[user]@[DOMAINE].com"
# → Puis contacter l'utilisateur par téléphone pour reset MDP + MFA
```

---

## SECTION 7 — DEFENDER FOR ENDPOINT

### Gestion alertes et investigation
```
NAVIGATION : security.microsoft.com
→ Incidents & alerts → Alerts

WORKFLOW ALERTE DEFENDER :
1. Classifier l'alerte (True positive / False positive)
2. Évaluer la sévérité (Critical / High / Medium / Low)
3. Voir la timeline d'activité sur l'appareil
4. Identifier le fichier ou processus déclencheur
5. Décider : isoler le poste ou surveiller

ISOLATION D'UN POSTE VIA DEFENDER :
security.microsoft.com → Assets → Devices → [Poste] → Actions → Isolate device
⚠️ L'isolation coupe tout accès réseau — uniquement Defender reste connecté
⚠️ Notifier l'utilisateur avant isolation (sauf urgence)
```

```powershell
# Via MSGraph / Defender API — Isoler un appareil
$deviceId = "[DEVICE_ID_DEFENDER]"
$body = @{ Comment = "Isolation P1 — Billet #[XXXXXX]" } | ConvertTo-Json
Invoke-MgGraphRequest -Method POST `
    -Uri "https://api.securitycenter.microsoft.com/api/machines/$deviceId/isolate" `
    -Body $body

# Lever l'isolation
Invoke-MgGraphRequest -Method POST `
    -Uri "https://api.securitycenter.microsoft.com/api/machines/$deviceId/unisolate" `
    -Body ($body | ConvertFrom-Json | Add-Member -MemberType NoteProperty -Name Comment -Value "Isolation levée — validée" -PassThru | ConvertTo-Json)

# Lancer scan antivirus à distance
Invoke-MgGraphRequest -Method POST `
    -Uri "https://api.securitycenter.microsoft.com/api/machines/$deviceId/runAntiVirusScan" `
    -Body '{"Comment":"Scan demandé — Billet #[XXXXXX]","ScanType":"Full"}' -ContentType "application/json"
```

---

## SECTION 8 — MICROSOFT SENTINEL — REQUÊTES KQL

### Requêtes d'investigation courantes
```kql
// Connexions échouées massives (bruteforce) — 30 dernières minutes
SigninLogs
| where TimeGenerated > ago(30m)
| where ResultType != 0
| summarize FailedAttempts = count() by UserPrincipalName, IPAddress, ResultDescription
| where FailedAttempts > 10
| order by FailedAttempts desc

// Impossible Travel — connexions depuis 2 pays différents
SigninLogs
| where TimeGenerated > ago(24h)
| where ResultType == 0
| summarize Locations = make_set(Location), Times = make_set(TimeGenerated) by UserPrincipalName
| where array_length(Locations) > 1

// Règles Outlook créées (indicateur BEC/ATO)
OfficeActivity
| where TimeGenerated > ago(7d)
| where Operation == "New-InboxRule"
| project TimeGenerated, UserId, Parameters
| order by TimeGenerated desc

// Téléchargements massifs SharePoint/OneDrive
OfficeActivity
| where TimeGenerated > ago(24h)
| where Operation in ("FileDownloaded", "FileCopied")
| summarize Downloads = count() by UserId, bin(TimeGenerated, 1h)
| where Downloads > 100
| order by Downloads desc

// Connexions depuis TOR/anonymiseurs (IP risk)
SigninLogs
| where TimeGenerated > ago(24h)
| where RiskLevelDuringSignIn in ("high", "medium")
| project TimeGenerated, UserPrincipalName, IPAddress, Location, RiskDetail, RiskEventTypes

// Comptes admin actifs hors heures ouvrables
SigninLogs
| where TimeGenerated > ago(7d)
| where ResultType == 0
| where UserPrincipalName has "admin" or AppDisplayName has "Azure Active Directory"
| extend Hour = datetime_part("hour", TimeGenerated)
| where Hour < 6 or Hour > 22
| project TimeGenerated, UserPrincipalName, IPAddress, AppDisplayName

// Malware détecté par Defender
SecurityAlert
| where TimeGenerated > ago(7d)
| where ProviderName == "Microsoft Defender Advanced Threat Protection"
| where AlertSeverity in ("High", "Critical")
| project TimeGenerated, AlertName, Description, Entities, SystemAlertId
| order by TimeGenerated desc
```

---

## SECTION 9 — ZERO TRUST ASSESSMENT (vérifications rapides)

### Checklist Zero Trust MSP
```
IDENTITÉS :
[ ] MFA activé pour 100% des utilisateurs (vérifier CA policy)
[ ] Authentification héritée bloquée (Legacy auth)
[ ] Accès admin via comptes dédiés (pas les comptes normaux)
[ ] Privileged Identity Management (PIM) configuré pour rôles globaux
[ ] Politique d'expiration des mots de passe configurée (ou sans expiration + MFA)

APPAREILS :
[ ] Politique de conformité Intune active
[ ] Chiffrement BitLocker requis
[ ] Antivirus à jour obligatoire
[ ] Accès conditionnel exige appareil conforme pour apps sensibles

APPLICATIONS :
[ ] Inventaire des apps OAuth autorisées (pas d'apps tierces non approuvées)
[ ] Politique MCAS/Defender for Cloud Apps pour apps non sanctionnées
[ ] SSO configuré pour les principales apps métier

RÉSEAU :
[ ] VPN avec split-tunneling documenté
[ ] Pas d'exposition directe RDP sur Internet
[ ] MFA sur VPN

DONNÉES :
[ ] DLP policy active dans M365
[ ] Étiquetage de sensibilité (MIP) configuré
[ ] Backup M365 actif (KeepIT ou autre)

SURVEILLANCE :
[ ] Defender for Office 365 Plan 2 ou équivalent
[ ] Audit log M365 activé et conservé 90+ jours
[ ] Alertes SOC configurées pour événements critiques
```

---

## SECTION 10 — HARDENING POST-INCIDENT

### Actions de renforcement immédiates
```powershell
# Bloquer authentification héritée (via CA Policy — portail Entra)
# → Conditional Access → New policy → Cloud apps → All → Legacy auth clients → Block

# Désactiver SMBv1 (tous les serveurs)
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
Set-SmbClientConfiguration -EnableSMB1Protocol $false -Force

# Désactiver LLMNR et NBT-NS (vecteur responder)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Value 0 -Type DWord
# NBT-NS via GUI : Connexions réseau → Propriétés TCP/IP → Avancé → WINS → Désactiver NetBIOS

# Forcer MFA pour tous les admins (via GPO ou Entra CA)
# CA Policy : Require MFA → Administrators → All cloud apps

# Rotation des mots de passe comptes de service
Get-ADServiceAccount -Filter * | Select-Object Name, PasswordLastSet
# → Changer via : Set-ADServiceAccount -Identity "[COMPTE_SERVICE]" -Reset

# Audit LAPS (Local Admin Password Solution)
Get-ADComputer -Filter * -Properties ms-Mcs-AdmPwdExpirationTime | 
    Where-Object { $_."ms-Mcs-AdmPwdExpirationTime" -eq $null } |
    Select-Object Name
# Postes sans LAPS = mot de passe admin local identique partout = risque
```

### GPO de sécurité post-incident
```
GPO RECOMMANDÉES POST-INCIDENT :
- Désactiver accès USB (si exfiltration par USB)
- Restreindre Powershell : Constrained Language Mode pour non-admins
- Audit renforcé : Object Access, Logon/Logoff, Privilege Use
- Bloquer macros Office non signées
- Activer AMSI (Antimalware Scan Interface)
- Configurer Credential Guard (Windows 10/11)
```

---

## SECTION 11 — IOCs PAR TYPE (hérité V1)

### Ransomware
```
IOCs RANSOMWARE :
- Processus : vssadmin.exe delete shadows, wbadmin delete catalog, bcdedit /set recoveryenabled no
- Extensions : .locked, .encrypted, .crypted, .enc + variantes spécifiques par famille
- Comportement : chiffrement massif en quelques minutes, suppression shadow copies
- Réseau : connexions sortantes vers IPs/domaines Tor, C2 callback

DÉTECTION :
Get-WinEvent -LogName System | Where-Object { $_.Message -like "*vssadmin*" -or $_.Message -like "*shadow*" } | Select-Object -First 10
```

### Phishing et mouvement latéral
```
IOCs PHISHING :
- Règles Outlook créées récemment (ForwardTo externe, DeleteMessage)
- Connexions depuis IPs non habituelles dans les 2h suivant le clic
- Téléchargement de fichiers .zip .iso depuis navigateur

IOCs MOUVEMENT LATÉRAL :
- Connexions SMB entre postes inhabituelles
- PsExec.exe, wmic.exe utilisés à distance
- Pass-the-hash : connexion avec credentials d'un autre utilisateur (Event 4648)
- Event ID 4688 (création processus) avec ligne de commande suspecte
```

---

## SECTION 12 — TEMPLATE RAPPORT D'INCIDENT

```
RAPPORT D'INCIDENT SÉCURITÉ — [CLIENT]
════════════════════════════════════════
Date : [YYYY-MM-DD] | Billet : #[XXXXXX]
Rédigé par : [NOM] | Approuvé par : [À CONFIRMER]

RÉSUMÉ EXÉCUTIF
[3-5 lignes en langage non technique — ce qui s'est passé, impact, résolution]

CHRONOLOGIE
- [HH:MM] Détection / alerte initiale
- [HH:MM] Prise en charge
- [HH:MM] Confinement
- [HH:MM] Résolution
- Durée totale : [HH:MM]

CAUSE RACINE
[Cause identifiée — factuelle, sans spéculation]

SYSTÈMES AFFECTÉS
- [Système 1 — impact]
- [Système 2 — impact]

IMPACT MESURÉ
- Utilisateurs affectés : [Nombre]
- Données exposées : [Oui/Non — nature si Oui]
- Services interrompus : [Liste et durée]

ACTIONS EFFECTUÉES
1. [Action de confinement]
2. [Action d'investigation]
3. [Action de remédiation]
4. [Validation]

RECOMMANDATIONS
[ ] [Action préventive 1 — responsable — échéance]
[ ] [Action préventive 2 — responsable — échéance]

LEÇONS APPRISES
- [Leçon 1]
- [Leçon 2]
════════════════════════════════════════
```

---

## SECTION 13 — CHECKLIST FERMETURE INCIDENT SOC (hérité V1)

```
FERMETURE INCIDENT SÉCURITÉ :
[ ] Cause racine identifiée et documentée
[ ] Tous les vecteurs d'accès compromis fermés
[ ] Comptes compromis réinitialisés (MDP + MFA)
[ ] Sessions révoquées sur tous les appareils
[ ] Règles suspectes supprimées (Outlook, Transport rules)
[ ] OAuth grants suspects révoqués
[ ] Appareils compromis nettoyés ou réimagés
[ ] Monitoring renforcé activé (7 jours minimum)
[ ] Client informé avec rapport complet
[ ] Rapport d'incident rédigé et archivé
[ ] Actions préventives planifiées dans CW
[ ] Leçons apprises documentées dans KB
```

---

## SECTION 14 — ESCALADES

| Situation | Destination | Délai | Action |
|---|---|---|---|
| Ransomware actif | IT-UrgenceMaster + SOC + Management | Immédiat | Isolation réseau + confinement |
| Compte admin compromis | SOC + Management client | Immédiat | Désactiver + révoquer |
| BEC avec transaction financière | Management client + Banque | Immédiat | Appel téléphonique direct |
| Exfiltration données confirmée | SOC + Juridique + Management | Immédiat | Préserver preuves |
| Insider threat confirmé | Management + RH + Juridique | Immédiat | Ne pas alerter l'employé |
| Incident > 4h non résolu | Chef d'équipe + Management | Dans l'heure | Escalade hiérarchique |
| Notification conformité requise (PIPEDA, RGPD) | Management + Juridique | Dans 24h | Formulaires légaux |

---

*BUNDLE_KP_SecurityMaster_V2 — Version 2.0 — 2026-05-15 — IT MSP Intelligence Platform*
