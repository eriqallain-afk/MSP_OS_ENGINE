# RB-001 — Guide Résolution Helpdesk N1/N2
**Agent :** IT-AssistanTI_N2 | **Usage :** Support téléphonique quotidien

---

## 1. Réinitialisation MDP / Déverrouillage AD

**Vérifier l'identité AVANT tout :**
- Manager confirme par appel conférence OU code employé interne

```powershell
# État du compte
Get-ADUser "prenom.nom" -Properties LockedOut, PasswordExpired, Enabled |
    Select-Object Name, Enabled, LockedOut, PasswordExpired

# Déverrouiller
Unlock-ADAccount -Identity "prenom.nom"

# Réinitialiser MDP
Set-ADAccountPassword "prenom.nom" -Reset -NewPassword (Read-Host -AsSecureString)
Set-ADUser "prenom.nom" -ChangePasswordAtLogon $true
```

---

## 2. Imprimante — Dépannage

**File d'attente bloquée :**
```powershell
Restart-Service Spooler -Force
Get-PrintJob -PrinterName * | Remove-PrintJob
```

**Imprimante réseau inaccessible :**
1. `ping [IP_imprimante]` → accessible ?
2. `Test-NetConnection [IP] -Port 9100` → port ouvert ?
3. Réinstaller le pilote si persistant

---

## 3. Outlook — Problèmes courants

| Symptôme | Action |
|---|---|
| Profil corrompu | `outlook.exe /cleanprofile` |
| Pas de synchronisation | Supprimer `.ost` : `%appdata%\Microsoft\Outlook` |
| MFA prompt en boucle | Révoquer sessions → escalade @IT-CloudMaster |
| Outlook hors ligne | Fichier → Travailler hors connexion (décocher) |

---

## 4. VPN Utilisateur

**Arbre de décision :**
1. Internet OK ? → `ping 8.8.8.8`
2. Compte AD verrouillé ? → `Get-ADUser [user] -Properties LockedOut`
3. Port VPN accessible depuis l'extérieur ? → tester depuis 5G mobile
4. **Erreur 789 L2TP Meraki** → fix registre (reboot requis) :
```powershell
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\PolicyAgent" `
    -Name "AssumeUDPEncapsulationContextOnSendRule" -Value 2 -Type DWord
Restart-Computer -Force   # ⚠️ confirmer avec client
```
5. Connecté mais pas d'accès réseau → escalade @IT-NetworkMaster

---

## 5. OneDrive / SharePoint Sync

**Réinitialiser OneDrive :**
```powershell
Get-Process "OneDrive" | Stop-Process -Force
& "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe" /reset
# Attendre ~2 min — OneDrive se relance automatiquement
```

**Fichiers bloqués :** caractères interdits dans le nom → `" * : < > ? / \ |`

**SharePoint accès refusé :**
- Vérifier groupe : Membres / Visiteurs / Propriétaires
- Ne pas modifier les héritages de permissions sans @IT-CloudMaster

---

## 6. Sessions RDS

| Erreur | Cause probable | Action |
|---|---|---|
| "Access denied" | Non membre groupe "Remote Desktop Users" | Ajouter dans AD |
| "Connection was denied" | GPO bloquante | Escalade @IT-Commandare-TECH |
| "Remote computer not found" | DNS ou connectivité | Vérifier ping + nslookup |

**Session fantôme :**
```powershell
query session /server:NOM_HOST          # Identifier les sessions "Disc"
Reset-Session [ID] /server:NOM_HOST    # Forcer la fermeture
# ⛔ NE PAS toucher la session console (ID 0)
```

---

## 7. Bloc escalade (copier dans CW)

```
[ESCALADE → DÉPARTEMENT NOC/TECH]
Billet : #[XXXXXX] | Priorité : P[X] | [YYYY-MM-DD HH:MM]
Symptôme : [Description précise]
Utilisateur : [Nom] | [email@client.com]
Actions N2 tentées :
  1. [Action — résultat]
  2. [Action — résultat]
Raison escalade : [motif clair]
```
