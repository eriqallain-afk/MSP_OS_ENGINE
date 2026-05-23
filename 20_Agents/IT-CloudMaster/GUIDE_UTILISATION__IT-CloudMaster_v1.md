# Guide d'utilisation — @IT-CloudMaster (v1.0)
> **Pour :** Techniciens N1/N2/N3 MSP
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-CloudMaster ?

**IT-CloudMaster est l'expert Microsoft 365, Azure et services cloud pour le MSP.**

Il couvre l'ensemble de l'écosystème Microsoft cloud : Exchange Online, Entra ID (Azure AD), Teams, SharePoint, OneDrive, Intune, Compliance/Purview, Azure, et Keepit (backup M365).

| Domaine | Ce qu'il couvre |
|---|---|
| Exchange Online | Triage messagerie, règles suspectes, traces message, quotas |
| Entra ID | Comptes bloqués, MFA, accès conditionnel, sessions suspectes |
| Teams / SharePoint | Permissions, accès refusés, sync OneDrive |
| Intune | Conformité appareils, politiques, wipe à distance |
| Keepit | Backup M365 — connecteurs, restauration |

> **Règle absolue : zéro modification tenant sans change_id.** Toute action destructrice (wipe, désactivation compte, révocation session) requiert une confirmation explicite.

---

## Quand l'utiliser ?

- Un utilisateur ne peut plus envoyer ou recevoir des emails
- Un compte M365 est bloqué ou suspecté compromis
- Des règles de transfert Outlook vers une adresse externe sont détectées
- Un appareil Intune est non conforme ou doit être effacé
- Le backup Keepit est déconnecté depuis plus de 24h
- Un utilisateur ne peut pas accéder à un site SharePoint ou sync OneDrive bloqué
- MFA bloque un utilisateur légitime

---

## Les commandes principales

### `/exchange [symptôme]` — Diagnostic Exchange Online / messagerie

La commande pour tous les incidents de messagerie.

**Usage :**
```
/exchange utilisateur ne reçoit plus d'emails depuis hier matin
/exchange message non reçu — exp: fournisseur@externe.com — dest: compta@client.com
/exchange règles Outlook suspectes sur boîte jean.martin@client.com
```

**Ce que tu obtiens :**
- Classification du symptôme (envoi/réception/quota/règles/performance)
- Périmètre : 1 utilisateur ou tous
- Commandes PowerShell prêtes à exécuter :

```powershell
# Tracer un message
Get-MessageTrace -SenderAddress "exp@domaine.com" -RecipientAddress "dest@domaine.com" `
    -StartDate (Get-Date).AddDays(-2) -EndDate (Get-Date) | Select-Object Received,Status | Format-Table

# Vérifier règles Outlook suspectes
Get-InboxRule -Mailbox "user@domaine.com" |
    Select-Object Name,Enabled,ForwardTo,ForwardAsAttachmentTo,DeleteMessage | Format-List
```

> Si des règles de transfert vers l'extérieur sont détectées → escalade @IT-SecurityMaster immédiate (P1 SOC).

---

### `/entraid [symptôme]` — Diagnostic Entra ID / Azure AD / MFA

Pour les incidents de compte, d'accès conditionnel ou de compte compromis.

**Usage :**
```
/entraid utilisateur bloqué par MFA — accès conditionnel
/entraid connexions suspectes depuis pays étranger — jean.martin@client.com
/entraid compte potentiellement compromis — révoquer sessions
```

**Ce que tu obtiens :**
- Analyse des sign-in logs (IPs, pays, applications)
- Identification de la politique d'accès conditionnel bloquante
- Commandes de containment si compte compromis :

```powershell
# Désactiver + révoquer toutes les sessions (compte compromis)
Update-MgUser -UserId $userId -AccountEnabled $false
Revoke-MgUserSignInSession -UserId $userId

# Vérifier consentements OAuth suspects
Get-MgUserOauth2PermissionGrant -UserId $userId | Select-Object ClientId,Scope,ConsentType
```

> Compte Entra compromis → escalade @IT-SecurityMaster immédiate.

---

### `/teams [symptôme]` — Teams / SharePoint / OneDrive

Pour les incidents Teams, accès SharePoint refusés, sync OneDrive bloqué.

**Usage :**
```
/teams SharePoint — accès refusé sur site Projets — marie.tremblay@client.com
/teams OneDrive sync bloqué — erreur 0x8004de40
/teams Teams lent et instable depuis ce matin
```

**Ce que tu obtiens :**
- Diagnostic des permissions (Membres/Visiteurs/Propriétaires)
- Commandes de fix courantes :

```powershell
# Vider cache Teams
Get-Process -Name "Teams" | Stop-Process -Force
& "$env:LOCALAPPDATA\Microsoft\Teams\Update.exe" --processStart "Teams.exe"

# Réinitialiser OneDrive
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" /reset
```

- Caractères interdits dans noms de fichiers OneDrive : `" * : < > ? / \ |`

---

### `/intune [symptôme]` — Intune — conformité, wipe, politiques

Pour les incidents de gestion des appareils mobiles et PC via Intune.

**Usage :**
```
/intune appareil non conforme — DESKTOP-ABC123 — Jean Dupont
/intune forcer sync politique Intune sur appareil
/intune vol appareil — wipe à distance requis
```

**Ce que tu obtiens :**
- Analyse de conformité et politique bloquante
- Procédure de sync forcée
- Pour un wipe : confirmation explicite requise + escalade superviseur

> ⚠️ Wipe Intune = réinitialisation usine complète. Approbation superviseur + client requise avant exécution.

---

### `/keepit` — Vérification backup M365 Keepit

Pour vérifier l'état du backup cloud-to-cloud M365.

**Usage :**
```
/keepit — tenant client.com — connecteur déconnecté depuis 2 jours
/keepit — restauration email supprimé — jean.martin@client.com — date approximative 2026-05-10
```

**Ce que tu obtiens :**
- Procédure de reconnexion du connecteur
- Vérification : nb utilisateurs protégés = nb utilisateurs actifs M365
- Procédure de restauration : Search → [utilisateur] → Restore to original mailbox ou Export PST

> Déconnexion > 24h = données non sauvegardées → alerter le client immédiatement.

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

### Incident messagerie signalé

```
1. Ticket reçu — utilisateur ne reçoit pas d'email
   ↓
2. /exchange [symptôme] — diagnostic + trace message
   ↓
3. Si règles ForwardTo externe → escalade @IT-SecurityMaster (P1 immédiat)
   Si quota plein → ajustage mailbox
   Si livraison OK dans Exchange → problème client (Outlook)
   ↓
4. /close — Note Interne + Discussion CW
```

### Compte compromis suspecté

```
1. Alerte reçue (EDR, utilisateur, règle suspecte)
   ↓
2. /entraid [symptôme] — analyser sign-in logs
   ↓
3. Si compromission confirmée :
   - Désactiver compte + révoquer sessions (commandes /entraid)
   - Escalade @IT-SecurityMaster immédiate
   ↓
4. /close — documentation CW
```

### Appareil volé — wipe Intune

```
1. Client signale vol d'appareil
   ↓
2. /intune vol appareil — wipe à distance requis
   ↓
3. Obtenir confirmation superviseur + client (écrit)
   ↓
4. Exécuter wipe depuis Intune Admin Center
   ↓
5. /close — Note Interne + Email client
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| ZÉRO modification tenant sans change_id | Traçabilité et rollback possible |
| Règles ForwardTo externe = P1 immédiat | Exfiltration de données potentielle |
| Wipe Intune = approbation requise | Perte de données irréversible |
| ZÉRO credentials dans les livrables | Passportal uniquement |
| Compte compromis = révoquer les sessions | Couper l'accès avant d'investiguer |
| Keepit déconnecté > 24h = alerter client | Données non protégées pendant la période |

---

## Questions fréquentes

**Q : Comment savoir quelle politique d'accès conditionnel bloque un utilisateur ?**
Entra Admin Center → Utilisateurs → [User] → Sign-in logs → colonne "Conditional Access". Identifier la politique bloquante → exclure temporairement si urgence → documenter dans CW → corriger la root cause.

**Q : Un wipe Intune efface-t-il tout ?**
Oui — réinitialisation usine complète. Les données non sauvegardées dans OneDrive ou SharePoint sont perdues. Toujours confirmer que les données importantes sont dans le cloud avant d'exécuter.

**Q : Quelle différence avec IT-SecurityMaster ?**
CloudMaster gère les incidents opérationnels M365 (messagerie, comptes, appareils). SecurityMaster prend en charge si une compromission est confirmée — brèche, ransomware, phishing actif. CloudMaster escalade vers SecurityMaster dès qu'une compromission est suspectée.

**Q : Entra ID ou Azure AD — c'est la même chose ?**
Oui. Microsoft a rebrandé Azure AD en Entra ID en 2023. Les deux noms sont interchangeables en contexte MSP.

**Q : Le tenant M365 est complètement inaccessible — qui appeler ?**
@IT-Commandare-NOC immédiatement (< 5 min). Il s'agit d'un P1 — panne service critique.

---

*GUIDE_UTILISATION — IT-CloudMaster v1.0 — MSP Intelligence AI — 2026-05-18*
