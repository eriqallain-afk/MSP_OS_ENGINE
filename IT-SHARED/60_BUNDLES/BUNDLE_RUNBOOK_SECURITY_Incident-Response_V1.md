# BUNDLE RUNBOOK SECURITY Incident-Response V1
**Type :** Bundle Runbook — Assemblage complet
**Agents :** IT-SecurityMaster, IT-Commandare-NOC, IT-Assistant-N3 | IT-MaintenanceMaster | IT-SysAdmin
**Description :** Réponse aux incidents de sécurité — Triage, Containment, Investigation, Postmortem
**Mis à jour :** 2026-03-20

> Ce bundle regroupe runbooks + templates + checklists liés à ce domaine.
> Uploader en Knowledge dans les GPTs concernés.


---
<!-- SOURCE: RUNBOOK__IT_SECURITY_INCIDENT_RESPONSE -->
## RUNBOOK — Réponse aux Incidents de Sécurité (P1/P2)

# RUNBOOK — Réponse aux Incidents de Sécurité MSP
**ID :** RUNBOOK__IT_SECURITY_INCIDENT_RESPONSE  
**Version :** 2.0 | **Agent :** IT-SecurityMaster  
**Mis à jour :** 2026-03-20 — Agents archivés remplacés
**Applicable :** Tout incident cybersécurité P1/P2 (breach, ransomware, phishing actif)

---

## DÉCLENCHEURS
- Alerte EDR/XDR confirmée (SentinelOne, CrowdStrike, Defender XDR)
- Rapport utilisateur : accès non autorisé, chiffrement fichiers, email suspect cliqué
- Alerte NOC : trafic anormal, connexions sortantes suspectes
- Demande d'audit post-incident

---

## PHASE 1 — IDENTIFICATION (0 à 15 min)

### Étape 1.1 — Qualifier l'incident
- [ ] Type confirmé : ransomware / phishing / breach / lateral_movement / autre
- [ ] Asset(s) affecté(s) identifiés
- [ ] Heure de détection vs heure estimée compromission
- [ ] Vecteur d'entrée probable (email / RDP / VPN / supply chain)
- [ ] Propagation active ? (oui/non/inconnu)

### Étape 1.2 — Classier la sévérité
| Indicateur | P1 | P2 | P3 |
|-----------|----|----|-----|
| Chiffrement actif détecté | ✓ | | |
| Credentials admin compromis | ✓ | | |
| DC / AD touché | ✓ | | |
| Single workstation isolée | | | ✓ |
| Email phishing cliqué, no exec | | | ✓ |
| Mouvement latéral confirmé | | ✓ | |
| Data exfiltration suspectée | ✓ | | |

### Étape 1.3 — Notification
- P1 : Notifier IT-Commandare-NOC + IT-Commandare-TECH **immédiatement**
- P2 : Notifier IT-Commandare-NOC dans les 30 min
- Ouvrir ticket CW avec priorité correcte

---

## PHASE 2 — CONTAINMENT (15 min à 2h)

### 2.1 Isolation réseau (si propagation active)
```powershell
# ⚠️ Impact : isolation réseau complète du poste/serveur
# Validation requise avant exécution
# Sur le poste suspect :
netsh advfirewall set allprofiles state on
netsh advfirewall firewall add rule name="BLOCK_ALL_IR" dir=out action=block
```
- [ ] Poste isolé du réseau (déconnecter NIC ou quarantaine EDR)
- [ ] NE PAS éteindre la machine (préserver artefacts forensics en RAM)
- [ ] Si serveur critique : coordination IT-Commandare-Infra avant isolation

### 2.2 Révoquer accès compromis
- [ ] Désactiver compte AD compromis
- [ ] Révoquer sessions actives Azure AD : `Revoke-AzureADUserAllRefreshToken`
- [ ] Changer mots de passe service accounts affectés
- [ ] Invalider tokens MFA si nécessaire

### 2.3 Bloquer IOCs
- [ ] Ajouter hashes malwares dans EDR exclusions (block)
- [ ] Bloquer IPs/domaines C2 sur firewall
- [ ] Règle email : bloquer domaine expéditeur malveillant

---

## PHASE 3 — INVESTIGATION (parallèle au containment)

### 3.1 Collecte d'artefacts
```powershell
# Capture état système AVANT remédiation
$OutDir = "$env:SystemDrive\IR_ARTIFACTS_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

# Processus actifs
Get-Process | Export-Csv "$OutDir\processes.csv" -NoTypeInformation
# Connexions réseau
netstat -ano > "$OutDir\netstat.txt"
# Logs événements récents (Security, System, Application)
Get-EventLog -LogName Security -Newest 500 | Export-Csv "$OutDir\events_security.csv" -NoTypeInformation
# Tâches planifiées
Get-ScheduledTask | Export-Csv "$OutDir\scheduled_tasks.csv" -NoTypeInformation
# Services
Get-Service | Export-Csv "$OutDir\services.csv" -NoTypeInformation
```
- [ ] Artefacts copiés sur stockage sécurisé (hors réseau compromis)
- [ ] NE PAS supprimer artefacts avant analyse complète

### 3.2 Analyse timeline
- [ ] Corrélation logs EDR + Event Viewer + pare-feu
- [ ] Patient zéro identifié
- [ ] Étendue de la compromission mappée

---

## PHASE 4 — ÉRADICATION

- [ ] Suppression malware (via EDR ou réinstallation OS si nécessaire)
- [ ] Patch vulnérabilité exploitée
- [ ] Nettoyage registre et persistence mécanismes
- [ ] Réinitialisation credentials complets si breach confirmé
- [ ] Vérification intégrité backups (avant restauration)

---

## PHASE 5 — RÉCUPÉRATION

- [ ] Restauration depuis backup sain (date pre-compromission confirmée)
- [ ] Validation intégrité post-restauration
- [ ] Monitoring renforcé 72h (alertes sensibilité maximale)
- [ ] Test accès utilisateurs
- [ ] Communication client (via IT-TicketScribe)

---

## PHASE 6 — POST-INCIDENT

- [ ] Postmortem avec IT-ReportMaster (dans les 5 jours ouvrables)
- [ ] KB article créé par IT-KnowledgeKeeper
- [ ] Ajustements monitoring/seuils via IT-MonitoringMaster
- [ ] Rapport sécurité mensuel mis à jour

---

## COMMUNICATION CLIENT

| Phase | Message | Via |
|-------|---------|-----|
| Détection | "Incident sécurité détecté, investigation en cours" | IT-TicketScribe |
| Containment | "Services [X] affectés temporairement, correction en cours" | IT-TicketScribe |
| Résolution | Rapport postmortem complet | IT-ReportMaster |

---

## CHECKLIST FINALE AVANT FERMETURE TICKET

- [ ] Vecteur d'entrée confirmé et bouché
- [ ] Tous les systèmes affectés traités
- [ ] Credentials compromis tous réinitialisés
- [ ] Monitoring renforcé actif
- [ ] Client notifié
- [ ] KB créé
- [ ] Postmortem documenté


---
<!-- SOURCE: RUNBOOK__Security_Audit -->
## RUNBOOK — Audit de Sécurité MSP

# RUNBOOK — Audit de Sécurité MSP
**ID :** RUNBOOK__Security_Audit | **Version :** 2.0
**Agent owner :** IT-SecurityMaster | **Équipe :** TEAM__IT
**Domaine :** SECURITY — Audit et conformité
**Date révision :** 2026-03-13

---

## ⚠️ GARDE-FOUS — CRITIQUES (sécurité renforcée)
> Référence : `00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md`

**Scope :** Cet agent traite uniquement l'audit de sécurité du billet actif.
Il ne répond PAS aux demandes générales, personnelles ou hors audit sécurité IT.

**Données hautement sensibles — Protection maximale :**
- ❌ JAMAIS reproduire : hashes, credentials, clés de chiffrement, données personnelles
- ❌ JAMAIS dans livrables : seuils de détection EDR (évite bypass), liste des IOC internes
- ❌ JAMAIS en output client : comptes admin, topologie réseau interne, versions logicielles
- Rapport d'audit : DEUX versions obligatoires — version technique interne + version client-safe
- Toute découverte critique → notifier immédiatement, ne pas documenter les détails en clair

**Principe essentiel :** Le rapport d'audit ne doit pas devenir un guide d'attaque.

---

## 1. Objectif
Conduire des audits de sécurité MSP structurés :
- Audit baseline (nouveau client ou annuel)
- Audit post-incident
- Revue de conformité ponctuelle
- Audit comptes et privilèges

---

## 2. Types d'audits et déclencheurs

| Type | Déclencheur | Fréquence | Durée estimée |
|------|-------------|-----------|---------------|
| Baseline complet | Nouveau client / annuel | Annuel | 4-8h |
| Comptes & privilèges | Départ employé / trimestriel | Trimestriel | 1-2h |
| Post-incident | Après tout incident P1/P2 | Sur demande | 2-4h |
| Conformité ciblée | Audit éditeur / réglementation | Sur demande | Variable |

---

## 3. Audit Comptes et Privilèges (le plus courant)

### 3.1 Inventaire comptes AD (lecture seule)
```powershell
# Comptes actifs avec privilèges élevés
Get-ADGroupMember -Identity "Domain Admins" -Recursive |
  Get-ADUser -Properties LastLogonDate, PasswordLastSet, Enabled |
  Select-Object Name, SamAccountName, Enabled, LastLogonDate, PasswordLastSet |
  Format-Table -AutoSize

# Comptes inactifs depuis 90 jours
$cutoff = (Get-Date).AddDays(-90)
Search-ADAccount -AccountInactive -TimeSpan (New-TimeSpan -Days 90) -UsersOnly |
  Where-Object {$_.Enabled} |
  Select-Object Name, SamAccountName, LastLogonDate | Format-Table -Auto

# Comptes sans expiration de mot de passe
Get-ADUser -Filter {PasswordNeverExpires -eq $True} -Properties PasswordNeverExpires |
  Select-Object Name, SamAccountName | Format-Table -Auto
```

### 3.2 Audit accès serveurs et partages
```powershell
# Partages ouverts (lecture seule)
Get-SmbShare | Select-Object Name, Path, Description,
  @{n='Accès';e={(Get-SmbShareAccess $_.Name |
    Where-Object {$_.AccountName -like '*Everyone*' -or $_.AccountName -like '*Tout le monde*'}).AccountName}} |
  Format-Table -Auto

# Permissions NTFS sur partages sensibles (adapter le chemin)
# Get-Acl -Path "\\[SERVEUR]\[PARTAGE]" | Select-Object -ExpandProperty Access
# → IPs et noms de comptes complets restent dans la note interne uniquement
```

### 3.3 Audit Azure AD / M365
```powershell
# Admins globaux (critique — liste minimale recommandée)
Get-MgDirectoryRoleMember -DirectoryRoleId (Get-MgDirectoryRole -Filter "displayName eq 'Global Administrator'").Id |
  ForEach-Object { Get-MgUser -UserId $_.Id | Select-Object DisplayName, UserPrincipalName }

# Comptes sans MFA
Get-MgUser -All | ForEach-Object {
  $methods = Get-MgUserAuthenticationMethod -UserId $_.Id
  if ($methods.Count -le 1) {
    [pscustomobject]@{User=$_.DisplayName; MFA="AUCUNE MÉTHODE FORTE"}
  }
}
```

---

## 4. Audit Baseline Sécurité

### 4.1 Checklist sécurité Windows Server
```powershell
# Pare-feu Windows
Get-NetFirewallProfile | Select-Object Name, Enabled | Format-Table -Auto

# Dernières mises à jour (patching)
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 10 Description, HotFixID, InstalledOn

# Services à risque — exemples à désactiver si non utilisés
$risky = @('Telnet','RemoteRegistry','RemoteAccess','WinRM')
Get-Service -Name $risky -ErrorAction SilentlyContinue |
  Select-Object Name, Status, StartType | Format-Table -Auto

# RDP — état et sécurité
(Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server").fDenyTSConnections
Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" |
  Select-Object UserAuthentication, SecurityLayer, MinEncryptionLevel
```

### 4.2 Points de contrôle critiques

| Contrôle | Attendu | Commande vérification |
|----------|---------|----------------------|
| Pare-feu actif | Domain/Private/Public = True | `Get-NetFirewallProfile` |
| UAC activé | EnableLUA = 1 | `reg query HKLM\...\System\ConsentPromptBehaviorAdmin` |
| Audit des connexions | Success + Failure | `AuditPol /get /category:"Logon/Logoff"` |
| EDR présent | Service actif | `Get-Service -Name "SentinelAgent|MsSense|CSFalconService"` |
| RDP NLA activé | UserAuthentication = 1 | Voir ci-dessus |
| Comptes Guest désactivés | Disabled | `Get-LocalUser Guest` |

---

## 5. Format du rapport d'audit — DEUX versions obligatoires

### Version technique interne (note CW confidentielle)
```
AUDIT DE SÉCURITÉ — [CLIENT] — [DATE]
Type : [Baseline / Comptes / Post-incident]
Portée : [systèmes audités — noms sans IPs]

RÉSULTATS CRITIQUES (à corriger sous 30 jours) :
  - [finding 1 — description technique — système concerné (sans IP)]
  - [finding 2]

RÉSULTATS IMPORTANTS (à corriger sous 90 jours) :
  - [finding 3]

CONFORMES :
  - [contrôle 1 : OK]
  - [contrôle 2 : OK]

ACTIONS RECOMMANDÉES :
  1. [action — responsable — délai]
  2. [action — responsable — délai]

PROCHAINE REVUE : [date]
```

### Version client-safe (discussion CW)
```
- Audit de sécurité réalisé selon la portée convenue.
- Nombre de points de contrôle évalués : [X]
- Points à corriger : [N critique(s) / N important(s)]
  (Détails techniques transmis séparément en note confidentielle)
- Points conformes : [N]
- Plan d'action transmis avec délais recommandés.
- Prochaine revue planifiée : [date].
```

---

## 6. Escalade
- Découverte critique (compromission active) → P1 + `IT-SecurityMaster` + `IT-Commandare-NOC` IMMÉDIAT
- Non-conformité réglementaire grave → Lead MSP + client ASAP
- Besoin de pentest ou audit avancé → prestataire spécialisé (hors portée agents IT)


---
<!-- SOURCE: RUNBOOK__Alert_Response -->
## RUNBOOK — Réponse aux Alertes de Monitoring

# RUNBOOK — Réponse aux Alertes de Monitoring
**ID :** RUNBOOK__Alert_Response | **Version :** 2.0
**Agent owner :** IT-MonitoringMaster | **Équipe :** TEAM__IT
**Domaine :** SECURITY/MONITORING — Réponse aux alertes
**Date révision :** 2026-03-13

---

## ⚠️ GARDE-FOUS — OBLIGATOIRES
> Référence : `00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md`

**Scope :** Cet agent traite uniquement les alertes monitoring du billet actif.
Il ne répond pas aux demandes hors monitoring/alertes IT.

**Données sensibles :**
- ❌ JAMAIS dans les livrables : IPs, seuils de détection, noms de règles SIEM internes
- ❌ Dans les outputs client : aucun détail qui permettrait de contourner les alertes
- Les IOC (indicateurs de compromission) → note interne uniquement, jamais dans le client-safe

**Actions :**
- Désactivation d'une alerte → `⚠️ Impact : angle mort de sécurité` + validation + durée définie
- Modification de seuil → `⚠️ Impact : faux négatifs possibles` + documentation obligatoire

---

## 1. Objectif
Procédures de réponse structurées aux alertes de monitoring :
- ConnectWise RMM (alertes systèmes)
- N-able (performance / disponibilité)
- Auvik (réseau)
- SIEM / Defender XDR (sécurité)
- BackupRadar (backup)

---

## 2. Qualification d'une alerte — Priorité 0

### 2.1 Grille de qualification (remplir pour toute alerte)
```
Source    : [RMM / Auvik / BackupRadar / SIEM / Utilisateur]
Type      : [CPU / Disque / Service / Réseau / Backup / Sécurité / Disponibilité]
Sévérité  : [Critical / Warning / Informational]
Client    : [nom]
Asset     : [serveur/équipement — sans IP]
Heure     : [HH:MM]
Récurrent : [1ère fois / déjà vu — fréquence ?]
Corrélé   : [alerte isolée / liée à d'autres alertes]
```

### 2.2 Table bruit vs alerte réelle

| Pattern | Décision | Action |
|---------|----------|--------|
| Alerte disparaît < 5 min, aucun symptôme | Bruit transitoire | ACK + surveiller 30 min |
| Alerte revient > 3x / heure | Problème réel | Ouvrir ticket P2/P3 |
| Alerte corrélée avec d'autres assets | Incident infra global | Ticket P1 + Commandare |
| Alerte sur actif en maintenance connue | Faux positif maintenance | ACK + noter dans ticket |
| Alerte sécurité (EDR / SIEM) | JAMAIS ignorer | Analyser obligatoirement |

---

## 3. Réponse par type d'alerte

### 3.1 Alertes performance (CPU/RAM/Disque)
```powershell
# Diagnostic ciblé sur l'asset (lecture seule)
# CPU — identification processus
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, Id,
  @{n='CPU_s';e={[math]::Round($_.CPU,1)}},
  @{n='RAM_MB';e={[math]::Round($_.WorkingSet64/1MB,1)}} | Format-Table -Auto

# RAM — utilisation détaillée
Get-CimInstance Win32_OperatingSystem |
  Select-Object @{n='Total_GB';e={[math]::Round($_.TotalVisibleMemorySize/1MB,1)}},
                @{n='Libre_GB';e={[math]::Round($_.FreePhysicalMemory/1MB,1)}},
                @{n='Utilisé_%';e={[math]::Round((($_.TotalVisibleMemorySize-$_.FreePhysicalMemory)/$_.TotalVisibleMemorySize)*100,1)}} | Format-List

# Disque — libérer si espace critique
Get-PSDrive -PSProvider FileSystem |
  Select-Object Name, @{n='Libre_GB';e={[math]::Round($_.Free/1GB,1)}},
    @{n='Libre_%';e={[math]::Round($_.Free/($_.Free+$_.Used)*100,1)}} | Format-Table -Auto
```

### 3.2 Alertes disponibilité (service / agent offline)
```powershell
# Vérifier état services (lecture seule)
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'} |
  Select-Object DisplayName, Name, Status, StartType | Format-Table -Auto

# Dernière communication agent RMM
# → Vérifier dans la console ConnectWise RMM (Last Seen)
# Si agent offline > 30 min et pas de maintenance → alerter NOC

# ⚠️ Impact : redémarrage service affecte utilisateurs connectés
# → Confirmer avant : Restart-Service -Name "[SERVICE]"
```

### 3.3 Alertes Backup (BackupRadar)
```
Échec backup → vérifier dans cet ordre :
1. Espace destination suffisant ? (> 20% libre)
2. Service backup agent running ?
3. Connectivité vers destination ? (réseau / VPN)
4. Credentials de connexion valides ? (vérifier sans afficher)
5. Job bloqué / en conflit avec autre job ?
→ Si 3 échecs consécutifs → P2 + IT-BackupDRMaster
→ Si perte de données possible → P1 + escalade Senior immédiate
```

### 3.4 Alertes Sécurité (EDR / SIEM / Defender)
```
RÈGLE ABSOLUE : aucune alerte sécurité n'est ignorée sans analyse.

Niveau 1 — Triage (5 min max) :
  → Faux positif connu ? (processus légitime mal détecté)
  → Processus signé par éditeur reconnu + comportement normal ?
  → Si OUI → ACK + documenter la règle d'exclusion proposée (sans l'appliquer sans validation)

Niveau 2 — Analyse (si non faux positif évident) :
  → Hash / process path → vérification VirusTotal ou SIEM interne
  → Compte associé → activité anormale ?
  → Asset → d'autres alertes sur cet asset ?
  → Si suspicion → P1 + IT-SecurityMaster IMMÉDIAT

JAMAIS :
  ❌ Supprimer une alerte EDR sans analyse
  ❌ Désactiver EDR même temporairement sans approbation senior + documentation
  ❌ Créer une exclusion globale sans validation IT-SecurityMaster
```

---

## 4. Documentation obligatoire (toute alerte)

### Champs minimaux dans le ticket CW
```yaml
type_alerte    : [catégorie]
source         : [outil monitoring]
heure_détection: [HH:MM]
asset          : [nom — sans IP]
qualification  : [bruit / réel — justification]
actions        : [liste des actions et statuts]
résolution     : [cause + correctif]
durée          : [en minutes si service interrompu]
récurrence     : [première fois / N-ième — historique]
```

---

## 5. Amélioration continue du monitoring

### Règles de maintenance des seuils (mensuelle)
- Seuil CPU : revoir si > 15% de faux positifs sur 30 jours
- Seuil disque : ajuster si croissance données accélérée détectée
- Alerte récurrente identique > 3x/semaine → ticket amélioration + revue seuil
- Nouvelle alerte qui aurait évité un incident → ajouter à la baseline monitoring

---

## 6. Livrables CW

### Note interne
```
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

Source alerte  : [outil]
Type           : [catégorie]
Qualification  : [bruit / incident réel]
Sévérité réelle: P[1/2/3/4]
Asset impacté  : [nom — sans IP]
Actions :
  1. [action — FAIT / KO]
  2. [action — FAIT / KO]
Cause          : [identifiée / [À CONFIRMER]]
Résultat       : [alerte résolue / escaladée / planifiée]
Monitoring     : [ACK / seuil ajusté / à surveiller]
```

### Discussion client (client-safe)
```
- Réception et analyse de l'alerte.
- Investigation effectuée : [résumé fonctionnel sans détails techniques].
- Résolution : [correctif appliqué / surveillance renforcée].
- Prochaine étape : [monitoring actif / aucune action requise].
```


---
<!-- SOURCE: RUNBOOK__M365_Compliance_Purview_V1 -->
## RUNBOOK — M365 Conformité et Purview

# RUNBOOK — Microsoft 365 : Conformité, Purview & Sécurité
**ID :** RUNBOOK__M365_Compliance_Purview_V1
**Version :** 1.0 | **Agents :** IT-CloudMaster, IT-SecurityMaster
**Domaine :** INFRA — Microsoft 365 / Conformité
**Mis à jour :** 2026-03-20

---

## 1. ACCÈS PORTAILS SÉCURITÉ ET CONFORMITÉ

| Portail | URL | Usage |
|---|---|---|
| **Microsoft Purview** | https://compliance.microsoft.com | DLP, rétention, eDiscovery |
| **Defender for M365** | https://security.microsoft.com | Sécurité, menaces, incidents |
| **Entra ID Protection** | https://entra.microsoft.com | Risques, MFA, CA |
| **Secure Score** | security.microsoft.com/securescore | Score sécurité global |

---

## 2. RECHERCHE DANS LES LOGS D'AUDIT (UNIFIED AUDIT LOG)

```powershell
# Connexion
Connect-ExchangeOnline -UserPrincipalName "<ADMIN_UPN>.com"

# Recherche générale (7 derniers jours)
Search-UnifiedAuditLog `
    -StartDate (Get-Date).AddDays(-7) `
    -EndDate (Get-Date) `
    -UserIds "utilisateur@domaine.com" `
    -RecordType ExchangeAdmin `
    -ResultSize 500 |
    Select-Object CreationDate, UserIds, Operations, RecordType, AuditData |
    Format-Table -AutoSize

# Opérations courantes à rechercher :
# MailboxLogin        → Connexions boîte aux lettres
# FileAccessed        → Accès fichiers SharePoint/OneDrive
# MemberAdded         → Ajout membre Teams/groupe
# UserLoggedIn        → Connexions utilisateurs
# Set-Mailbox         → Modifications de boîtes
# New-InboxRule       → Création règles Outlook
```

---

## 3. MICROSOFT SECURE SCORE

```
security.microsoft.com → Secure Score
→ Score actuel vs score recommandé
→ Actions recommandées : liste de mesures à prendre
→ Comparer avec : industrie, clients similaires

Actions prioritaires typiques :
→ Activer MFA pour tous les admins (impact élevé)
→ Activer Defender for Office 365 (anti-phishing)
→ Activer l'audit des boîtes aux lettres
→ Bloquer l'authentification basique (Legacy Auth)
→ Activer les révisions d'accès périodiques
```

---

## 4. DEFENDER FOR MICROSOFT 365 — ALERTES

```
security.microsoft.com → Incidents & Alerts
→ Voir les incidents actifs
→ Chaque incident regroupe plusieurs alertes liées

Triage d'une alerte :
1. Cliquer sur l'alerte → Lire la description complète
2. Identifier les entités affectées (utilisateurs, appareils, emails)
3. Évaluer : Vrai positif (VP) / Faux positif (FP) / Test
4. VP → escalade SOC immédiate
5. FP → marquer comme résolu avec commentaire

⚠️ NE JAMAIS ignorer une alerte Defender sans l'avoir classée
```

---

## 5. PROTECTION CONTRE LES MENACES EMAIL (DEFENDER FOR OFFICE 365)

```
security.microsoft.com → Email & Collaboration → Threat Explorer
→ Voir les emails malveillants récents
→ Filtrer par : Phishing, Malware, Spam

Quarantaine :
security.microsoft.com → Review → Quarantine
→ Messages retenus pour révision
→ Libérer les faux positifs
→ Signaler les vrais positifs

Politiques anti-phishing :
security.microsoft.com → Policies → Anti-phishing
→ Vérifier l'impersonation protection (usurpation d'identité)
→ Vérifier les domaines protégés
```

---

## 6. DLP (DATA LOSS PREVENTION)

```
compliance.microsoft.com → Data loss prevention → Policies
→ Voir les politiques actives
→ Vérifier les alertes DLP récentes

Alerte DLP déclenchée :
1. compliance.microsoft.com → DLP → Alerts
2. Cliquer sur l'alerte → détails de l'événement
3. Identifier : qui a envoyé quoi et à qui
4. Évaluer : accident ou intention
5. VP → escalade SOC

⚠️ NE JAMAIS désactiver une politique DLP sans approbation du client
```

---

## 7. RÉTENTION ET ARCHIVAGE

```
compliance.microsoft.com → Information governance → Retention policies
→ Vérifier les politiques de rétention actives
→ S'assurer qu'elles couvrent : Exchange, SharePoint, OneDrive, Teams

Litigation Hold (hold légal sur une boîte) :
Set-Mailbox "utilisateur@domaine.com" -LitigationHoldEnabled $true

In-Place Archive (archivage Exchange Online) :
Enable-Mailbox "utilisateur@domaine.com" -Archive
Get-Mailbox "utilisateur@domaine.com" | Select-Object ArchiveStatus, ArchiveQuota
```

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS désactiver l'audit unifié (UAL) — requis pour toute investigation
⛔ NE PAS supprimer un Litigation Hold sans ordre juridique ou approbation client écrite
⛔ NE JAMAIS créer une règle de transport qui bypass le spam/phishing filtering
⛔ NE PAS autoriser l'authentification basique (Legacy Auth) dans de nouveaux déploiements
⛔ NE JAMAIS ignorer une alerte Defender > 2h sans l'avoir triée
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Incident Defender (vrai positif) | SOC | Immédiat |
| Alerte DLP (données sensibles exposées) | SOC + CloudMaster | Dans l'heure |
| Score sécurité < 30% | CloudMaster + TECH | Dans la semaine (planifié) |
| Litigation Hold requis (legal) | TECH + CloudMaster | Dans l'heure |


---
<!-- SOURCE: TEMPLATE_SECURITY_Incident-et-Postmortem-SOC_V1 -->
## TEMPLATE — Fiche Incident SOC et Postmortem

# TEMPLATE_SECURITY_Incident-et-Postmortem-SOC_V1
**Agent :** IT-SecurityMaster, IT-Assistant-N3
**Usage :** Fiche incident sécurité active + rapport postmortem SOC
**Mis à jour :** 2026-03-20

---

## PARTIE 1 — FICHE INCIDENT SÉCURITÉ (pendant l'incident)

```
═══════════════════════════════════════════════
FICHE INCIDENT SÉCURITÉ
Billet CW      : #[XXXXXX] | Priorité : P[1/2]
Client         : [NOM]
Date/Heure     : [YYYY-MM-DD HH:MM]
Technicien SOC : [NOM]
═══════════════════════════════════════════════

TYPE D'INCIDENT
☐ Ransomware / Malware actif
☐ Phishing / Compromission compte
☐ Breach / Accès non autorisé
☐ Exfiltration de données
☐ Mouvement latéral confirmé
☐ Alerte EDR/XDR (SentinelOne / CrowdStrike / Defender XDR)
☐ Autre : [préciser]

CLASSIFICATION
P1 : ☐ Chiffrement actif  ☐ Credentials admin compromis  ☐ DC/AD touché  ☐ Exfiltration
P2 : ☐ Mouvement latéral  ☐ Multiple postes  ☐ Compte compromis isolé

ASSETS AFFECTÉS
• [Asset 1 — rôle]
• [Asset 2 — rôle]
Vecteur d'entrée probable : [Email / RDP / VPN / Supply chain / Inconnu]
Propagation active : ☐ Oui  ☐ Non  ☐ Inconnu

TIMELINE
[HH:MM] Détection : [Source — EDR / utilisateur / NOC]
[HH:MM] Qualification : [Résumé]
[HH:MM] Containment : [Action — ex: asset isolé réseau]
[HH:MM] Investigation débutée
[HH:MM] [Autres actions]

CONTAINMENT EFFECTUÉ
☐ Asset(s) isolé(s) du réseau
☐ Compte(s) désactivé(s) et sessions révoquées
☐ Hashes IOC bloqués dans EDR
☐ IPs/domaines C2 bloqués sur firewall
☐ Machine NON éteinte (artefacts forensics préservés)

ARTEFACTS COLLECTÉS
☐ Processus actifs
☐ Connexions réseau (netstat)
☐ Logs Event Viewer (Security/System)
☐ Tâches planifiées
☐ Services

COMMUNICATIONS
☐ NOC informé à [HH:MM]
☐ Client informé à [HH:MM]
☐ Superviseur informé à [HH:MM]
═══════════════════════════════════════════════
```

---

## PARTIE 2 — RAPPORT POSTMORTEM SOC

```
═══════════════════════════════════════════════
POSTMORTEM SÉCURITÉ
Billet CW   : #[XXXXXX]
Client      : [NOM]
Incident    : [Titre court]
Période     : [YYYY-MM-DD HH:MM] → [YYYY-MM-DD HH:MM]
Durée       : [Xh Ymin]
Rédigé par  : [Technicien SOC]
Date rapport: [YYYY-MM-DD]
═══════════════════════════════════════════════

RÉSUMÉ EXÉCUTIF (non-technique — pour le client)
[2-3 phrases : quoi s'est passé, quel impact, comment résolu]

CHRONOLOGIE DÉTAILLÉE
[HH:MM] [Action/Observation]
[HH:MM] [Action/Observation]
...

CAUSE RACINE
[Cause technique précise — pas le symptôme]

ÉTENDUE DE LA COMPROMISSION
Assets touchés      : [Liste]
Données exposées    : ☐ Oui → [Description]  ☐ Non  ☐ Inconnu
Propagation         : ☐ Confirmée  ☐ Non confirmée

ACTIONS DE REMÉDIATION EFFECTUÉES
1. [Action — résultat]
2. [Action — résultat]

MESURES PRÉVENTIVES RECOMMANDÉES
1. [Mesure 1 — priorité haute/moyenne/basse]
2. [Mesure 2]

LEÇONS APPRISES
• [Ce qui a bien fonctionné]
• [Ce qui peut être amélioré]
• [Changement de procédure recommandé]

SUIVI
[ ] KB article créé : [ID]
[ ] Politique de sécurité mise à jour
[ ] Formation utilisateur recommandée : ☐ Oui  ☐ Non
[ ] Prochain audit sécurité : [Date]
═══════════════════════════════════════════════
```


---
<!-- SOURCE: TEMPLATE_INCIDENT_Log-et-Critique_V1 -->
## TEMPLATE — Journal Incident et Fiche Critique P1

# TEMPLATE_INCIDENT_Log-et-Critique_V1
**Agent :** IT-Assistant-N3, IT-MaintenanceMaster, IT-Commandare-NOC
**Usage :** Journal d'incident temps réel (P1/P2) + fiche incident critique
**Mis à jour :** 2026-03-20

---

## PARTIE 1 — JOURNAL D'INCIDENT (TIMELINE)

```
═══════════════════════════════════════════════
JOURNAL D'INCIDENT — TEMPS RÉEL
Billet CW   : #[XXXXXX]
Client      : [NOM]
Type        : [NOC / SOC / SUPPORT]
Priorité    : P[1/2]
Technicien  : [NOM]
Débuté à    : [YYYY-MM-DD HH:MM]
═══════════════════════════════════════════════

SYMPTÔME INITIAL
[Description précise — ce que l'utilisateur/monitoring a signalé]

ASSETS AFFECTÉS
→ [Serveur/équipement 1]
→ [Serveur/équipement 2]

IMPACT
Utilisateurs affectés : [Nombre / qui]
Services indisponibles : [Liste]

─────────────────────────────────────────────
TIMELINE

[HH:MM] — [FAIT] — [Description action + résultat]
[HH:MM] — [FAIT] — [Description action + résultat]
[HH:MM] — [SUGGESTION] — [Description action à valider]
[HH:MM] — [À CONFIRMER] — [Information manquante]
[HH:MM] — [ESCALADE] — Département [NOC/SOC/INFRA/TECH] notifié

─────────────────────────────────────────────
VALIDATIONS FINALES

Services critiques    : ✅ OK / ❌ KO / [À CONFIRMER]
Monitoring           : ✅ OK / ❌ KO / [À CONFIRMER]
Backups (si applicable) : ✅ OK / ❌ KO / [À CONFIRMER]
Validation utilisateur  : ✅ OK / ❌ KO / [À CONFIRMER]

STATUT FINAL : [RÉSOLU / PARTIEL / ESCALADÉ]
Résolu à    : [HH:MM]
Durée totale : [X heures Y min]
═══════════════════════════════════════════════
```

---

## PARTIE 2 — FICHE INCIDENT CRITIQUE (P1)

```
═══════════════════════════════════════════════
INCIDENT CRITIQUE — P1
Billet CW      : #[XXXXXX]
Client         : [NOM]
Date/Heure     : [YYYY-MM-DD HH:MM]
Technicien N2/N3 : [NOM]
Département notifié : [NOC / SOC / INFRA / TECH]
═══════════════════════════════════════════════

DESCRIPTION
[Ce qui s'est passé — 2-3 phrases claires]

INDICATEURS DE CRITICITÉ
☐ Ransomware / chiffrement actif
☐ Breach / compromission compte admin
☐ DC / AD inaccessible
☐ Réseau site entier down
☐ Perte de données en cours
☐ > 20 utilisateurs impactés
☐ Autre : [préciser]

ACTIONS IMMÉDIATES EFFECTUÉES
1. [Action — résultat]
2. [Action — résultat]

ÉTAT ACTUEL
[Description de la situation au moment du transfert]

RISQUES SI NON TRAITÉ IMMÉDIATEMENT
→ [Risque 1]
→ [Risque 2]
═══════════════════════════════════════════════
```


---
<!-- SOURCE: TEMPLATE_COM_Teams-Incident-Actif_V1 -->
## TEMPLATE — Communications Teams Incident Actif

# TEMPLATE_COM_Teams-Incident-Actif_V1
**Agent :** IT-TicketScribe, IT-Commandare-NOC
**Usage :** Annonces Teams pendant un incident actif (NOC/P1/P2)
**Mis à jour :** 2026-03-20

---

## DÉCLARATION D'INCIDENT

```
🚨 INCIDENT EN COURS — [DATE] [HH:MM]
📋 Type : [Panne réseau / Service down / Problème M365 / etc.]
⚠️ Impact : [Services affectés] | Utilisateurs touchés : [nombre ou "tous"]

Notre équipe est en intervention.
Prochain point de communication : [HH:MM]
Billet CW : #[XXXXXX]
```

---

## MISE À JOUR PENDANT L'INCIDENT

```
🔄 MISE À JOUR — [DATE] [HH:MM]
📋 Incident #[XXXXXX] — [Type]
✔️ [Action 1 complétée]
⏳ [Action 2 en cours]
ETA résolution : [heure estimée ou "en investigation"]
Prochain point : [HH:MM]
```

---

## RÉSOLUTION D'INCIDENT

```
✅ INCIDENT RÉSOLU — [DATE] [HH:MM]
📋 Incident #[XXXXXX] — [Type]
⏱️ Durée : [X heures Y minutes]
🔧 Cause : [Description fonctionnelle non-technique]
✔️ Tous les services sont rétablis

Un rapport post-incident vous sera transmis sous [24h/48h].
Questions : [email support] | [téléphone]
```

---

## ESCALADE INTERNE (NOC → Département)

```
⬆️ ESCALADE — [DATE] [HH:MM]
📋 Billet #[XXXXXX] — Transféré au département [NOC/SOC/INFRA/TECH]
⚠️ Niveau : P[1/2]
📝 Résumé : [Description courte]
👤 Technicien N2 : [Nom]
```


---
<!-- SOURCE: CHECKLIST_SECURITY_Hardening-et-Audit_V1 -->
## CHECKLIST — Security Hardening et Audit

# CHECKLIST_SECURITY_Hardening-et-Audit_V1
**Agent :** IT-SecurityMaster, IT-Assistant-N3
**Usage :** Audit de sécurité périodique et vérification du hardening
**Mis à jour :** 2026-03-20

---

## IDENTITÉ ET ACCÈS (EntraID / AD)

- [ ] MFA activé pour tous les utilisateurs (minimum tous les admins)
- [ ] Accès conditionnel configuré (bloquer auth legacy, géo-restriction si applicable)
- [ ] Comptes admin dédiés : distinct des comptes utilisateurs quotidiens
- [ ] Comptes inactifs depuis > 90 jours désactivés
- [ ] Revue des membres Domain Admins / Global Administrators (< 5 personnes)
- [ ] Aucun compte de service avec MDP sans expiration non documenté
- [ ] Passportal à jour pour tous les comptes de service

---

## MESSAGERIE ET M365

- [ ] Defender for Office 365 actif (anti-phishing, anti-malware, Safe Links)
- [ ] Authentification basique (Legacy Auth) désactivée
- [ ] Règles de transport suspectes : aucune
- [ ] Transferts automatiques vers l'externe : aucun (ou documentés)
- [ ] Audit log M365 activé (Unified Audit Log)
- [ ] DKIM / DMARC / SPF configurés sur le domaine email
- [ ] Secure Score M365 vérifié : score actuel _______ / recommandé _______

---

## ENDPOINTS ET SERVEURS

- [ ] EDR déployé sur tous les serveurs et postes (SentinelOne / CrowdStrike / Defender XDR)
- [ ] Windows Update : patchs critiques < 30 jours sur tous les serveurs
- [ ] RDP exposé directement sur Internet : aucun (accès via VPN uniquement)
- [ ] Ports non utilisés fermés sur le firewall
- [ ] Comptes administrateurs locaux : mots de passe uniques par machine (LAPS si applicable)
- [ ] Firewall Windows activé sur tous les endpoints

---

## RÉSEAU ET PÉRIMÈTRE

- [ ] Firmware firewall à jour (WatchGuard / Fortinet / SonicWall / Meraki)
- [ ] Licences UTM/IPS actives (pas expirées)
- [ ] Certificats SSL VPN : expiration > 30 jours
- [ ] VLAN correctement segmentés (serveurs / utilisateurs / IoT séparés)
- [ ] Logs firewall activés et conservés > 90 jours
- [ ] Aucune règle "Any → Any Accept" non documentée

---

## BACKUP ET RÉSILIENCE

- [ ] Backups testés (voir CHECKLIST_BACKUP_DR-Readiness)
- [ ] Au moins 1 copie hors site (Datto cloud / Veeam Cloud / Keepit)
- [ ] Accès Passportal aux backups : restreint aux techniciens autorisés

---

## RÉSULTAT

| Zone | Status | Actions requises |
|---|---|---|
| Identité et accès | ☐ OK / ☐ Actions | |
| Messagerie M365 | ☐ OK / ☐ Actions | |
| Endpoints et serveurs | ☐ OK / ☐ Actions | |
| Réseau et périmètre | ☐ OK / ☐ Actions | |
| Backup et résilience | ☐ OK / ☐ Actions | |

**Score global :** _______ / 30 items
**Audit effectué par :** _______ | **Date :** _______ | **Billet CW :** #_______
