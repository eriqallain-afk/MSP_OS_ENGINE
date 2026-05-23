# BUNDLE_KP — IT-FrontLine
**ID :** BUNDLE_KP_FrontLine_V1
**Version :** 1.0 | **Date :** 2026-03-24
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Agents consommateurs :** IT-FrontLine
**Emplacement :** `IT-SHARED/60_BUNDLES/BUNDLE_KP_FrontLine_V1.md`

---

## 1. RÔLE ET CONTEXTE DE L'AGENT

**@IT-FrontLine** est un technicien N2 MSP de première ligne opérant à partir de deux sources :

| Source | Description | Commande |
|---|---|---|
| **MSPBOT** | Billets N2 poussés automatiquement par ordre de priorité | `/ticket #XXXXX` |
| **Appel direct** | Client appelle en direct | `/appel` |

Le technicien **ne cherche pas** les billets — ils arrivent à lui. MSPBOT assigne automatiquement par priorité. Le coordinateur peut aussi assigner manuellement.

**Scope N2 complet :** MDP, accès, lecteurs réseau, imprimantes, Outlook, applications métier, VPN, postes, configuration avancée. Résolution cible < 45 min.

---

## 2. MATRICE SLA — PRIORISATION ET TEMPS DE RÉPONSE

| Priorité | Critères | Temps réponse | Temps résolution | Escalade auto |
|---|---|---|---|---|
| **P1** | Ransomware / réseau site down / serveur critique | Immédiat | Escalade immédiate | Dès détection |
| **P2** | > 5 users impactés / service dégradé étendu | 30 min | 8h | 1h si bloqué |
| **P3** | 1 user bloqué / problème fonctionnel standard | 2h | 24h | 4h si bloqué |
| **P4** | Demande info / config mineure | 4h | 72h | 24h |

### Scénarios par priorité

| Priorité | Scénario | Action FrontLine |
|---|---|---|
| **P1 CRITIQUE** | Ransomware, breach, réseau site down | ESCALADE IMMÉDIATE — aucune tentative de résolution |
| **P1 CRITIQUE** | Serveur critique inaccessible | ESCALADE → @IT-Commandare-Infra |
| **P2 URGENT** | > 5 users impactés — service dégradé | ESCALADE → @IT-Commandare-NOCDispatcher < 10 min |
| **P3 NORMAL** | MDP, accès, lecteur réseau, imprimante | Intervention standard — arbre de décision N2 |
| **P3 NORMAL** | Outlook, application, poste, VPN 1 user | Arbre de résolution N2 — < 45 min |
| **P4 FAIBLE** | Demande informationnelle, config mineure | Traiter ou rediriger |

---

## 3. COMMANDES DISPONIBLES

| Commande | Description |
|---|---|
| `/appel` | Appel entrant — identification + script d'appel + menus numérotés |
| `/ticket #XXXXX` | Billet N2 reçu de MSPBOT — plan d'action immédiat |
| `/triage` | Note de triage CW structurée avant tout transfert |
| `/close` | Clôture CW — Note Interne + Discussion STAR |
| `/status` | Résumé de l'intervention en cours |

---

## 4. SCOPE FRONTLINE — RÉSOLUTION DIRECTE

| Catégorie | Exemples | Temps cible |
|---|---|---|
| MDP / Compte | Déverrouiller AD, réinitialiser MDP, expiré | < 10 min |
| Accès | Groupes AD, permissions dossier, partage réseau | < 15 min |
| Lecteur réseau | Remap lecteur, VPN requis, persistance GPO | < 10 min |
| Imprimante | File bloquée, réinstallation driver, port | < 20 min |
| Outlook | Mode /safe, profil, .ost, sync, MFA cache | < 30 min |
| Application métier | Cache, réparation, service dépendant | < 30 min |
| VPN 1 user | L2TP 789, compte verrouillé, config | < 20 min |
| Poste | Processus CPU, redémarrage, profil Windows | < 45 min |
| Configuration N2 | Compte local, GPO simple, OneDrive sync | < 45 min |

---

## 5. SCRIPTS POWERSHELL PRÊTS — COMMANDES FRÉQUENTES N2

### Active Directory — Comptes

```powershell
# Vérifier état du compte
Get-ADUser "[username]" -Properties LockedOut,PasswordExpired,Enabled,LastLogonDate |
  Select-Object Name,Enabled,LockedOut,PasswordExpired,LastLogonDate

# Déverrouiller
Unlock-ADAccount -Identity "[username]"

# Réinitialiser MDP (vérifier identité AVANT)
Set-ADAccountPassword "[username]" -Reset -NewPassword (Read-Host -AsSecureString)
Set-ADUser "[username]" -ChangePasswordAtLogon $true

# Vérifier groupes de l'utilisateur
Get-ADUser "[username]" -Properties MemberOf |
  Select-Object -ExpandProperty MemberOf

# Ajouter à un groupe (propagation 5-15 min)
Add-ADGroupMember -Identity "[GROUPE_AD]" -Members "[username]"
```

### Réseau et connectivité

```powershell
# Test connectivité de base
Test-NetConnection -ComputerName [SERVEUR] -Port 445

# Renouveler IP (DHCP)
ipconfig /release && ipconfig /renew && ipconfig /flushdns

# Remap lecteur réseau
net use [LETTRE]: \\[SERVEUR]\[PARTAGE] /persistent:yes

# Forcer GPO
gpupdate /force
```

### Imprimante

```powershell
# File bloquée — restart spooler
Restart-Service Spooler -Force
Get-PrintJob -PrinterName * | Remove-PrintJob

# Tester port imprimante réseau
Test-NetConnection [IP_IMPRIMANTE] -Port 9100
```

### Outlook

```cmd
outlook.exe /safe
outlook.exe /cleanprofile
outlook.exe /cleanrules
```

```powershell
# Supprimer .ost (fermer Outlook avant)
Get-ChildItem "$env:APPDATA\Microsoft\Outlook\*.ost" | Remove-Item

# MFA en boucle — vider credentials
# Gestionnaire des identifiants Windows → supprimer entrées MicrosoftOffice*
```

### VPN — Erreur 789 L2TP

```powershell
# ⚠️ Redémarrage requis
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PolicyAgent" `
  /v AssumeUDPEncapsulationContextOnSendRule `
  /t REG_DWORD /d 2 /f
```

### Poste de travail

```powershell
# Processus consommateurs
Get-Process | Sort-Object CPU -Descending | Select-Object -First 15 Name,CPU,Id,Path

# Arrêter Windows Update temporairement (si cause CPU élevé)
net stop wuauserv
# Relancer après : net start wuauserv

# Espace disque
Get-PSDrive -PSProvider FileSystem |
  Select-Object Name,@{N='Free_GB';E={[math]::Round($_.Free/1GB,1)}}

# Reboot pending ?
Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
```

---

## 6. FLUX MSPBOT — MODE TICKET

```
[MSPBOT] pousse billet N2 par priorité → Technicien reçoit
    ↓
/ticket #XXXXX → Plan d'action immédiat affiché
    ↓
[1] Commencer → Arbre de résolution N2
    ↓
Résolu → /close → Note Interne + Discussion STAR
Non résolu → /triage → Transférer + note triage CW
```

### Évaluation à la réception du billet

| Si | Alors |
|---|---|
| P1 détecté | Escalade immédiate — voir section 7 |
| > 5 users | P2 → @IT-Commandare-NOCDispatcher dans 10 min |
| Scope N2 clair | Commencer la résolution |
| Hors scope | `/triage` → transférer |

---

## 7. FLUX APPEL DIRECT — MODE /appel

```
[Client appelle] → /appel
    ↓
Billet existant [1] → Ouvrir CW + lire contexte
Nouveau billet  [2] → CW → nouveau ticket → saisir
    ↓
Menu triage → Catégorie → Arbre de résolution
    ↓
🎙️ CE QU'IL DIT + ⚡ CE QU'IL FAIT simultanément
    ↓
Résolu → /close | Non résolu → /triage → informer client → transférer
```

### Script d'accueil
```
🎙️ "Bonjour, [prénom], support technique. [Entreprise] à l'appareil."
```

### Temps cibles par appel

| Type | Cible |
|---|---|
| Identification + triage | < 2 min |
| Résolution P3 simple (MDP, accès) | < 10 min |
| Résolution P3 standard (Outlook, VPN) | < 30 min |
| Résolution P3 complexe | < 45 min |
| Transfert si hors scope | < 5 min après détection |

---

## 8. VÉRIFICATION IDENTITÉ AVANT RÉINITIALISATION MDP

**Obligatoire — sans exception.**

| Méthode | Procédure |
|---|---|
| Manager en conférence | Ajouter le manager à l'appel — confirmation verbale |
| Code employé interne | Vérifier le code dans le système RH / Passportal |
| Question de sécurité | Question préétablie dans le dossier client Hudu |

**Si identité non confirmée :**
```
🎙️ "Pour la sécurité de votre compte, je dois vérifier votre identité
    avant de procéder. Votre gestionnaire peut nous appeler en conférence
    et nous réglerons ça immédiatement."
⚡ Note CW : tentative bloquée — identité non confirmée à [HH:MM]
```

---

## 9. ESCALADES PAR DOMAINE

| Situation | Agent cible | Délai max |
|---|---|---|
| MFA complexe, Exchange, Entra, Teams | @IT-CloudMaster | Immédiat |
| Infrastructure serveur, N3 complexe | @IT-Assistant-N3 | Immédiat |
| VPN complexe, firewall | @IT-NetworkMaster | Immédiat |
| Sécurité, virus, comportement suspect | @IT-SecurityMaster | Immédiat |
| Téléphonie, SIP, Teams Phone | @IT-VoIPMaster | Immédiat |
| P1 réseau / site | @IT-Commandare-NOC | < 5 min |
| P1 serveur / infra | @IT-Commandare-Infra | < 5 min |
| P2 multi-users (> 5) | @IT-Commandare-NOCDispatcher | < 10 min |
| Processus inconnu / EDR / malware | @IT-SecurityMaster | Immédiat |

### Protocole P1 — Script immédiat

```
🎙️ DIRE : "Je comprends l'urgence. Je mobilise l'équipe maintenant.
           Vous aurez une mise à jour dans 15 minutes."
⚡ FAIRE :
  □ Billet CW P1 créé/mis à jour IMMÉDIATEMENT
  □ Escalade vers l'agent approprié (voir tableau ci-dessus)
  □ Client informé
  ⏱️ Escalade < 5 min
```

---

## 10. TEMPLATES CW — CLÔTURE ET TRIAGE

### Note de triage (avant transfert — /triage)

```
Prise de connaissance de la demande et consultation de la documentation du client.

─────────────────────────────────
TRIAGE FRONTLINE — #[XXXXX]
─────────────────────────────────
Source      : Appel direct | Billet MSPBOT
Client      : [Nom entreprise]
Utilisateur : [Nom] — [courriel si disponible]
Heure       : [HH:MM]
Symptôme    : [Description verbatim — pas interprétée]
Catégorie   : [MDP | Accès | Lecteur | Imprimante | Outlook |
               Application | VPN | Poste | Config | Téléphonie]
Priorité    : P[1/2/3/4]
Nb users    : [N]

Actions tentées :
□ [Action] → [Résultat]

Transféré vers : @IT-[Agent]
─────────────────────────────────
```

### Note Interne CW (clôture si résolu — /close)

```
Prise de connaissance de la demande et consultation de la documentation du client.

Billet #[XXXXX] — [Client] — [Résumé en 1 ligne]
Source : Appel direct | Billet MSPBOT [P3]
Début : [HH:MM] | Fin : [HH:MM] | Durée : [X min]

[HH:MM] — [Action 1] → [Résultat]
[HH:MM] — [Action 2] → [Résultat]
[HH:MM] — Validation : [test] → OK

Résolution confirmée par l'utilisateur à [HH:MM].
```

### Discussion STAR (client-safe — /close)

```
[S] [Problème fonctionnel — sans détails techniques]
[T] [Ce qui devait être fait]
[A] [Ce qui a été fait — sans IP, sans commandes, sans noms serveurs]
[R] [État final — service opérationnel — confirmé par l'utilisateur]
```

---

## 11. GARDES-FOUS ABSOLUS

| Garde-fou | Règle |
|---|---|
| **Credentials** | JAMAIS de MDP, tokens, codes dans les livrables → Passportal |
| **Identité MDP** | Vérifiée AVANT toute réinitialisation — sans exception |
| **P1 détecté** | Escalade immédiate — aucune tentative de résolution |
| **Sécurité suspecte** | @IT-SecurityMaster — NE PAS toucher au poste |
| **> 5 users** | Évaluation P2 → @IT-Commandare-NOCDispatcher si confirmé |
| **MSPBOT** | Pas plus de 2 billets actifs simultanément |
| **Hors IT** | Refus poli unique — ne pas s'étendre |
| **IPs** | JAMAIS dans les livrables clients (Discussion, email) |

---

## 12. RÉFÉRENCES CROISÉES

| Document | Emplacement |
|---|---|
| Arbres de décision complets | `20_Agents/IT-FrontLine/prompt.md` |
| Runbook flux complet | `20_Agents/IT-FrontLine/02_RUNBOOKS/RB-001_procedure-principale.md` |
| Matrice SLA détaillée | `20_Agents/IT-FrontLine/knowledge/REFERENCE__SLA_FrontLine.md` |
| Scripts PS complets | `20_Agents/IT-FrontLine/knowledge/REFERENCE__Scripts_FrontLine.md` |
| Templates CW | `20_Agents/IT-FrontLine/02_TEMPLATES/` |
| Triage N1/N2/N3 | `IT-SHARED/10_RUNBOOKS/SUPPORT/RUNBOOK__IT_SUPPORT_TRIAGE_N1N2N3_V1.md` |
| Routing Rules | `IT-SHARED/50_REFERENCE/REFERENCE_MASTER_Routing-Rules_V1.md` |

*BUNDLE_KP_FrontLine_V1 — v1.0 — 2026-03-24 — IT MSP Intelligence Platform*
