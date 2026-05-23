# BUNDLE_KP_SecurityMaster_V1
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Type :** KnowledgePack GPT
**Agent cible :** IT-SecurityMaster
**Usage :** Uploader en Knowledge dans le GPT IT-SecurityMaster
**Contenu :** IR Playbooks + Forensics + M365 Security + CIS + Checklists SOC
**Mis à jour :** 2026-03-20

---

## MATRICE INCIDENTS SÉCURITÉ

| Niveau | Critères | Actions immédiates | Escalade |
|---|---|---|---|
| **P1** | Ransomware actif, DC compromis, exfiltration data | Isolation réseau, révoquer accès | NOC + TECH immédiat |
| **P1** | Breach credentials admin | Changer tous les creds, MFA forcé | NOC + superviseur |
| **P2** | Mouvement latéral suspect | Isolation préventive du segment | NOC dans 30 min |
| **P2** | Phishing cliqué + credentials soumis | Révoquer session, changer MDP | NOC dans 30 min |
| **P3** | Alerte EDR non confirmée | Investigation, ne pas escalader | Analyser |
| **P3** | CVE critique (CVSS ≥ 9.0) | Emergency patch planning | Dans 24h |

---

## PHASE 1 — IDENTIFICATION ET CONTAINMENT IMMÉDIAT

### Isolation réseau (poste/serveur suspect)
```powershell
# ⚠️ NE PAS ÉTEINDRE la machine — conserver les artefacts RAM
# Isoler réseau via EDR (SentinelOne/CrowdStrike) si possible
# OU en dernier recours :
netsh advfirewall set allprofiles state on
netsh advfirewall firewall add rule name="BLOCK_ALL_IR" dir=out action=block
# → Déconnecter physiquement le câble réseau si accès physique disponible
```

### Révoquer accès compte compromis (M365 / Entra ID)
```powershell
Connect-MgGraph -Scopes "User.ReadWrite.All"
$userId = (Get-MgUser -Filter "UserPrincipalName eq 'user@domaine.com'").Id

# 1. Désactiver le compte
Update-MgUser -UserId $userId -AccountEnabled $false

# 2. Révoquer TOUTES les sessions et tokens
Revoke-MgUserSignInSession -UserId $userId

# 3. Vérifier règles Outlook suspectes
Connect-ExchangeOnline -UserPrincipalName <ADMIN_UPN>.com
Get-InboxRule -Mailbox "user@domaine.com" |
    Select-Object Name,Enabled,ForwardTo,DeleteMessage | Format-List

# 4. Supprimer transfert automatique suspect
Set-Mailbox "user@domaine.com" -ForwardingSmtpAddress $null -DeliverToMailboxAndForward $false
```

---

## PHASE 2 — COLLECTE FORENSICS (READ-ONLY)

```powershell
$OutDir = "C:\IR_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $OutDir | Out-Null

# Processus actifs + hashes
Get-Process | Select-Object Id,ProcessName,Path,CPU,WS | Export-Csv "$OutDir\processes.csv" -NoTypeInformation

# Connexions réseau
netstat -ano 2>&1 | Out-File "$OutDir\netstat.txt"

# Clés de persistance Run
Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" | Export-Csv "$OutDir\run_keys.csv" -NoTypeInformation

# Tâches planifiées
Get-ScheduledTask | Export-Csv "$OutDir\scheduled_tasks.csv" -NoTypeInformation

# Événements sécurité (4624=logon, 4625=failed, 4688=process, 4720=compte créé)
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624,4625,4688,4720; StartTime=(Get-Date).AddHours(-24)} `
    -ErrorAction SilentlyContinue | Export-Csv "$OutDir\security_events.csv" -NoTypeInformation

# Comptes locaux
Get-LocalUser | Select-Object Name,Enabled,LastLogon | Export-Csv "$OutDir\local_users.csv" -NoTypeInformation

Write-Host "Artefacts collectés dans : $OutDir"
```

---

## IOCs PAR TYPE D'INCIDENT

### Ransomware
```
Indicateurs : extensions fichiers modifiées, fichiers README.txt/DECRYPT,
              CPU/disk élevés, chiffrement réseau, shadow copies supprimées
IOCs : processus non signés, modifications Run keys, vssadmin delete shadows
Action : NE PAS éteindre → isoler réseau → préserver artefacts RAM
```

### Phishing / Compromission compte
```
Indicateurs : email suspect, lien cliqué, credentials soumis sur faux site
IOCs : domaine usurpé, SPF/DKIM/DMARC fail, règles Outlook suspectes,
       connexions depuis IPs/pays inhabituels
Vérifications M365 :
  - Règles Outlook → Get-InboxRule
  - Transferts automatiques → Get-Mailbox | Select-Object ForwardingSmtpAddress
  - Consentements OAuth → Get-MgUserOauth2PermissionGrant
  - Connexions récentes → Get-MgAuditLogSignIn (IPs, locations)
```

### Mouvement latéral
```
IOCs : Event 4624 type 3 et 10 anormaux (network + remote interactive)
       PsExec, WMImplant, connexions RDP inter-postes inhabituelles
       Comptes admin utilisés sur workstations
Action : isoler le segment → auditer les comptes privilégiés
```

---

## M365 SÉCURITÉ — VÉRIFICATIONS CLÉS

```
SECURE SCORE
security.microsoft.com → Secure Score
→ Score actuel vs recommandé
→ Actions prioritaires : MFA admins, bloquer Legacy Auth, anti-phishing

ALERTES DEFENDER (ne jamais ignorer > 2h)
security.microsoft.com → Incidents & Alerts
→ Trier par severité → classer : VP (vrai positif) / FP / Test
→ VP → escalade SOC immédiate

QUARANTAINE EMAIL
security.microsoft.com → Review → Quarantine
→ Libérer les FP → supprimer les VP

AUDIT LOG (investigation)
Search-UnifiedAuditLog -StartDate (Get-Date).AddDays(-7) -EndDate (Get-Date) `
    -UserIds "user@domaine.com" -Operations "MailboxLogin,Send,FileAccessed" -ResultSize 500
```

---

## CHECKLIST FERMETURE INCIDENT SOC

```
CONTAINMENT
[ ] Asset(s) isolé(s) du réseau
[ ] Compte(s) désactivé(s) et sessions révoquées
[ ] Règles Outlook suspectes supprimées
[ ] Transferts automatiques supprimés
[ ] IOC bloqués dans EDR + firewall

INVESTIGATION
[ ] Artefacts forensics collectés
[ ] Timeline établie (heure détection, début compromission, étendue)
[ ] Patient zéro identifié
[ ] Vecteur d'entrée confirmé

REMÉDIATION
[ ] Malware supprimé ou VM réinstallée
[ ] Vulnérabilité exploitée patchée
[ ] Tous les credentials dans le périmètre réinitialisés
[ ] Intégrité des backups vérifiée AVANT restauration

COMMUNICATIONS
[ ] NOC informé
[ ] Client notifié (fonctionnel, sans détails exploitables)
[ ] Superviseur informé

POSTMORTEM
[ ] Postmortem planifié (< 5 jours ouvrables)
[ ] KB créé
[ ] Monitoring ajusté pour détecter plus tôt à l'avenir
```
