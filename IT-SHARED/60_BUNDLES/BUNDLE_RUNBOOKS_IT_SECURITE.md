# BUNDLE_RUNBOOKS_IT_SECURITE
**Bundle Runbooks — IT MSP Intelligence Platform**
**Catégorie :** Sécurité — Incident Response, Triage alertes, Audit, Licences
**Agents consommateurs :** @IT-SecurityMaster | @IT-Commandare-TECH | @IT-Commandare-NOCDispatcher
**Version :** 1.0 | **Date :** 2026-04-04
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Repo GitHub :** `PRODUCTS/IT/IT-SHARED/60_BUNDLES/BUNDLE_RUNBOOKS_IT_SECURITE.md`

> Ce bundle regroupe tous les runbooks de la catégorie **Sécurité — Incident Response, Triage alertes, Audit, Licences**.
> Uploader en Knowledge dans les GPT agents indiqués.
> Les runbooks sont à jour — source canonique dans GitHub.

---

## RB-SEC-001 — Incident Response — Identification → Recovery

# RUNBOOK — Réponse aux Incidents de Sécurité MSP
**ID :** RUNBOOK__IT_SECURITY_INCIDENT_RESPONSE  
**Version :** 1.0 | **Agent :** IT-SecurityMaster  
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
- P1 : Notifier IT-Commandare-NOC + IT-CTOMaster **immédiatement**
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

## RB-SEC-002 — Triage Alertes Sécurité — EDR/SIEM

# RUNBOOK — IT_SECURITY_ALERT_TRIAGE_V1
_Généré le 2026-01-17T21:19:45Z_

## 1) Objectif
Alerte sécurité (analyse -> containment -> communication -> KB)

## 2) Owner / Acteurs
- Owner (par défaut) : `IT-MonitoringMaster`
- Steps (ordre canon) :
  - **monitor** → `IT-MonitoringMaster`
  - **security** → `IT-SecurityMaster`
  - **comms** → `IT-TicketScribe`
  - **kb** → `IT-KnowledgeKeeper`

## 3) Inputs attendus
- Contexte : demande + objectifs + contraintes
- Données : liens, docs, extraits (si applicable)
- Format de sortie requis (si applicable)

## 4) Procédure
1. Exécuter les steps dans l’ordre.
2. Documenter les décisions / hypothèses.
3. Produire l’output final + résumé exécutif.

## 5) Contrôles qualité
- Check conformité (policies du domaine)
- Cohérence interne + traçabilité des sources (si applicable)
- Format de sortie respecté

## 6) Erreurs fréquentes / Escalade
- Si informations manquantes : demander les éléments minimaux (but, audience, contraintes).
- Si risque sécurité/conformité : escalader vers `META-GouvernanceEtRisques`.

## 7) Definition of Done
- Output livré + résumé
- Artefacts archivés si nécessaire (ex: `OPS-DossierIA`)


---

## RB-SEC-003 — Alert Response — Procédure de réponse

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

## RB-SEC-004 — Audit Licences Logiciels — SAM

# RUNBOOK — Audit Licences Logicielles (SAM) MSP
**ID :** RUNBOOK__IT_SOFTWARE_LICENSE_AUDIT_V1  
**Version :** 1.0 | **Agent :** IT-SoftwMaster  
**Applicable :** Audit SAM trimestriel ou à la demande client

---

## DÉCLENCHEURS
- Audit SAM trimestriel planifié
- Départ employé / restructuration
- Nouveau client onboardé
- Alerte audit éditeur (Microsoft, Adobe, Oracle)
- Suspicion over-deployment ou shadow IT

---

## ÉTAPE 1 — COLLECTE INVENTAIRE LOGICIEL

### Via RMM (N-able / ConnectWise RMM) :
- Rapport "Installed Software" par client/site
- Filtrer par catégorie : OS, Office, sécurité, métier, utilitaires

### Via PowerShell (manuel si RMM indisponible) :
```powershell
# Inventaire logiciels installés (toutes architectures)
$Software = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Where-Object DisplayName -ne $null

$Software32 = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion, Publisher, InstallDate |
    Where-Object DisplayName -ne $null

$All = ($Software + $Software32) | Sort-Object Publisher, DisplayName -Unique
$All | Export-Csv "C:\TEMP\Software_Inventory_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
```

### Microsoft 365 — via PowerShell :
```powershell
# Licences M365 utilisées vs disponibles
Connect-MsolService
Get-MsolAccountSku | Select-Object AccountSkuId, ActiveUnits, ConsumedUnits, 
    @{N='Available';E={$_.ActiveUnits - $_.ConsumedUnits}} | Format-Table
```

---

## ÉTAPE 2 — ANALYSE CONFORMITÉ

### 2.1 Matrice à compléter par éditeur :

| Logiciel | Licences achetées | Installs détectées | Delta | Statut |
|----------|------------------|--------------------|-------|--------|
| Windows Server | X | X | ±X | ✅/⚠️/🔴 |
| Microsoft 365 | X | X | ±X | ✅/⚠️/🔴 |
| Adobe Creative | X | X | ±X | ✅/⚠️/🔴 |
| Antivirus/EDR | X | X | ±X | ✅/⚠️/🔴 |

**Statut :** ✅ Conforme | ⚠️ Sous-licencié (<10%) | 🔴 Non conforme (>10% over)

### 2.2 Identifier :
- Logiciels sans licence connue → shadow IT → escalade IT-SecurityMaster
- Licences expirées → renouvellement urgent
- Logiciels en EOL non remplacés → risque sécurité

### 2.3 Microsoft specifics :
- Vérifier type licence : M365 Business vs Enterprise, CAL type (Device/User)
- SQL Server : vérifier Core vs CAL licensing
- Remote Desktop : RDS CAL count vs utilisateurs concurrents
- Confirme SA (Software Assurance) si applicable

---

## ÉTAPE 3 — OPTIMISATION

### Récupérer licences inutilisées :
```powershell
# M365 : comptes sans activité depuis 90 jours
$cutoff = (Get-Date).AddDays(-90)
Get-MsolUser -All | Where-Object { $_.LastDirSyncTime -lt $cutoff -and $_.isLicensed } |
    Select-Object UserPrincipalName, LastDirSyncTime, Licenses
```

### Actions optimisation :
1. Désactiver comptes inactifs > 90 jours → libérer licences
2. Désinstaller logiciels non utilisés (usage < 2x/an)
3. Regrouper licences (consolidation éditeur)
4. Négocier volume si croissance prévue

---

## ÉTAPE 4 — RAPPORT ET RECOMMANDATIONS

### Rapport SAM à produire via IT-ReportMaster :
- Tableau conformité par éditeur
- Économies potentielles identifiées (€/$/mois)
- Risques non-conformité (pénalités estimées si audit)
- Plan d'action : 30/60/90 jours

### Livrables CW :
- Note interne : résultats audit complets
- Discussion client : résumé + recommandations (sans données sensibles)
- Créer tickets pour chaque action requise

---

## ÉTAPE 5 — MISE À JOUR CMDB

- [ ] Mettre à jour IT-AssetMaster : licences actualisées
- [ ] Documenter contrats de maintenance et dates de renouvellement
- [ ] Programmer prochaine revue (trimestrielle recommandée)
- [ ] Alertes créées pour renouvellements à venir (60 jours avant)


---

## RB-SEC-005 — Audit Sécurité — Posture et conformité

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
