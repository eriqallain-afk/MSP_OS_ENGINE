# BUNDLE_KP_Assistant-N3_V1
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Type :** KnowledgePack GPT
**Agent cible :** IT-Assistant-N3
**Usage :** Uploader en Knowledge dans le GPT IT-Assistant-N3
**Contenu :** Runbooks + Templates + Checklists essentiels pour le support N1-N3
**Mis à jour :** 2026-03-20

---

## RUNBOOKS INCLUS

### /runbook ad — Active Directory
Référence : `RUNBOOK_INFRA_AD-UserManagement_V1`
```
GESTION UTILISATEURS AD
⛔ NE JAMAIS créer un compte sans demande écrite approuvée
⛔ NE JAMAIS modifier les permissions directement sur les dossiers → groupes AD uniquement
⛔ NE JAMAIS supprimer un compte — toujours désactiver 30 jours avant

Créer un compte :
New-ADUser -Name "Prénom Nom" -SamAccountName "prenom.nom" -UserPrincipalName "prenom.nom@domaine.com" `
    -Path "OU=Utilisateurs,DC=domaine,DC=local" -Enabled $true `
    -AccountPassword (Read-Host -AsSecureString) -ChangePasswordAtLogon $true

Désactiver + déplacer vers OU désactivés :
Disable-ADAccount -Identity "prenom.nom"
Move-ADObject -Identity (Get-ADUser "prenom.nom").DistinguishedName -TargetPath "OU=Comptes_Desactives,DC=domaine,DC=local"

Réinitialiser MDP (vérifier identité AVANT) :
Set-ADAccountPassword "prenom.nom" -Reset -NewPassword (Read-Host -AsSecureString)
Set-ADUser "prenom.nom" -ChangePasswordAtLogon $true
Unlock-ADAccount "prenom.nom"

Groupes d'un utilisateur :
(Get-ADUser "prenom.nom" -Properties MemberOf).MemberOf | ForEach-Object { (Get-ADGroup $_).Name } | Sort-Object

Escalade : SOC si compromission compte admin | NOC si problème réplication | INFRA si modification GPO
```

### /runbook rds — RDS / RemoteApp
Référence : `RUNBOOK_INFRA_RDS-Operations_V1`
```
HEALTH CHECK RDS
Get-Service TermService,SessionEnv,UmRdpService | Select-Object Name,Status | Format-Table
query session
query user

UTILISATEUR NE PEUT PAS SE CONNECTER
"Access denied"          → Vérifier groupe "Remote Desktop Users" dans AD
"Connection was denied"  → Vérifier GPO "Allow log on through RDS"
"Remote computer not found" → Vérifier DNS + connectivité + RD Gateway

SESSIONS FANTÔMES
query session /server:NOM_HOST → identifier les sessions "Disc"
Reset-Session [ID] /server:NOM_HOST
⛔ NE PAS déconnecter la session Console (ID 0)

REBOOT SESSION HOST
Set-RDSessionHost -SessionHost "NOM.domaine.com" -NewConnectionAllowed No -ConnectionBroker "BROKER.domaine.com"
→ Attendre fin des sessions → reboot → réactiver : -NewConnectionAllowed Yes

Escalade : NOC si Broker inaccessible | INFRA si certificat RD Gateway expiré
```

### /runbook veeam — Veeam Backup
Référence : `RUNBOOK_INFRA_VEEAM-Operations_V1`
```
VÉRIFICATION MATINALE
VBR Console → Home → Last 24 Hours
✅ Success | ⚠️ Warning → lire détail | ❌ Failed → intervention

ERREURS FRÉQUENTES
"Unable to connect"    → Service VeeamGuestHelper sur la VM cible
"Snapshot not found"   → vSphere → supprimer snapshots orphelins
"Insufficient space"   → purge restore points anciens
"Access denied"        → droits compte service VEEAM
"VSS snapshot failed"  → vssadmin list writers sur la VM cible
"Network error"        → Test-NetConnection vers cible port 445 + 6160

RESTAURATION FICHIER
VBR → Backups → VM → Restore guest files → Windows
→ Point de restauration → Copy to (emplacement alternatif)
⛔ NE PAS restaurer à l'emplacement original sans confirmation client

RESTAURATION VM COMPLÈTE ⚠️ Approbation superviseur requise
VBR → Backups → VM → Restore entire VM → Restore to new location pour test

Escalade : IT-BackupDRMaster si job critique en échec 2 jours | INFRA si repository < 10%
```

### /runbook m365 — Microsoft 365 / Exchange
Référence : `RUNBOOK_INFRA_M365-Exchange-Online_V1`
```
TRACER UN MESSAGE
Get-MessageTrace -SenderAddress "exp@domaine.com" -RecipientAddress "dest@domaine.com" `
    -StartDate (Get-Date).AddDays(-2) -EndDate (Get-Date) | Select-Object Received,Status | Format-Table

RÈGLES OUTLOOK SUSPECTES
Get-InboxRule -Mailbox "user@domaine.com" | Select-Object Name,Enabled,ForwardTo,DeleteMessage | Format-List
→ Supprimer une règle suspecte : Remove-InboxRule -Mailbox "user@domaine.com" -Identity "Nom règle"

TRANSFERT AUTOMATIQUE SUSPECT
Get-Mailbox "user@domaine.com" | Select-Object ForwardingSmtpAddress,DeliverToMailboxAndForward
→ Supprimer : Set-Mailbox "user@domaine.com" -ForwardingSmtpAddress $null

⛔ Compte compromis → escalade SOC IMMÉDIATEMENT

BOÎTE PARTAGÉE
New-Mailbox -Shared -Name "info" -PrimarySmtpAddress "info@domaine.com"
Add-MailboxPermission "info@domaine.com" -User "user@domaine.com" -AccessRights FullAccess

Escalade : SOC si règles suspectes ou transfert externe | TECH si problème licence
```

### /runbook vpn — VPN Client
Référence : `RUNBOOK_SUPPORT_VPN-Client-Troubleshooting_V1`
```
ARBRE DE DÉCISION
Pas de connexion Internet → Résoudre Internet d'abord
Erreur auth              → Vérifier compte AD (verrouillé ? expiré ?) + MFA
Timeout/serveur inaccessible → Test-NetConnection [GATEWAY] -Port 443 | Tester depuis 5G
Connecté mais pas d'accès → Problème routes ou DNS VPN → escalade INFRA

WATCHGUARD SSL VPN : Test-NetConnection [GATEWAY] -Port 443
MERAKI L2TP (erreur 789) → Vérifier clé partagée (Passportal)
Fix L2TP derrière NAT :
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\PolicyAgent" `
    -Name "AssumeUDPEncapsulationContextOnSendRule" -Value 2 -Type DWord
→ Redémarrage requis

⛔ NE JAMAIS demander le mot de passe VPN → utiliser Passportal
Escalade : NOC si plusieurs utilisateurs down simultanément
```

### /runbook onedrive — OneDrive / SharePoint Sync
Référence : `RUNBOOK_SUPPORT_OneDrive-SharePoint-Sync_V1`
```
RÉINITIALISER ONEDRIVE
Get-Process "OneDrive" | Stop-Process -Force
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" /reset
→ Attendre 2 min → OneDrive se relance automatiquement

CARACTÈRES INTERDITS DANS LES NOMS
" * : < > ? / \ |  ← renommer le fichier
Noms réservés : CON, PRN, AUX, NUL, COM1-9, LPT1-9 ← renommer

SHAREPOINT ACCÈS REFUSÉ
→ Vérifier groupe SharePoint (Membres / Visiteurs / Propriétaires)
→ NE PAS briser l'héritage des permissions sur les sous-dossiers

Escalade : BackupDR (Keepit) si données perdues
```

---

## TEMPLATES DE FERMETURE DE BILLET (copier-coller)

### Bloc escalade NOC (dans CW avant transfert)
```
[TRANSFERT → DÉPARTEMENT NOC]
Billet : #[XXXXXX] | Priorité : P[1/2] | [YYYY-MM-DD HH:MM]
Symptôme : [Description précise]
Impact : [Utilisateurs affectés / Services impactés]
Actions N2/N3 tentées :
  1. [Action — résultat]
  2. [Action — résultat]
Assets : [Liste]
```

### Bloc escalade SOC
```
[TRANSFERT → DÉPARTEMENT SOC]
Billet : #[XXXXXX] | Priorité : P[1/2] | [YYYY-MM-DD HH:MM]
Type : ☐ Phishing  ☐ Compromission  ☐ Ransomware  ☐ Autre
Compte affecté : [voir Passportal]
Actions effectuées :
  ☐ Compte désactivé  ☐ Sessions révoquées  ☐ Règles Outlook vérifiées
```

---

## CHECKLIST INTERVENTION (référence rapide)

```
KICKOFF    : Lire billet CW → Consulter Hudu → Confirmer fenêtre + approbations
PRECHECK   : Ping/RMM → CPU/RAM/Disk → Services → Pending Reboot → Event Logs → Backup
INTERVENTION : 1 action à la fois → documenter au fil de l'eau → [À CONFIRMER] si pas de preuve
POSTCHECK  : Services OK → App fonctionnelle → Event Logs → Monitoring vert → Snapshot supprimé
CLOSEOUT   : CW Note Interne → CW Discussion client-safe → Email si requis → Mode maintenance OFF
```

---

## ESCALADES RAPIDES

| Situation | Destination | Délai |
|---|---|---|
| P1 automatique (DC down, réseau site, ransomware) | IT-Commandare-NOC | Immédiat |
| P2→P1 dégradation | IT-Commandare-NOC ou TECH | Dans l'heure |
| Compte compromis (règles Outlook, transferts) | SOC | Immédiat |
| Backup job critique en échec > 24h | IT-BackupDRMaster | Dans l'heure |
| Problème réseau site | IT-NetworkMaster | 30 min |
