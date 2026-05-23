# BUNDLE_NOC_SOC_SIEM_V1
**Catégorie :** SOC — SIEM, EDR, Threat Hunting, Forensique, Incident Response
**Agents :** @IT-SecurityMaster | @IT-Commandare-TECH | @IT-Commandare-NOC | IT-MaintenanceMaster | IT-SysAdmin
**Version :** 1.0 | **Date :** 2026-04-05

---

## RB-SOC-001 — Triage d'alerte de sécurité — Méthodologie

### Niveau de sévérité
| Sévérité | Description | Délai réponse |
|---|---|---|
| Critique | Breach actif, ransomware, exfiltration confirmée | < 15 min |
| Haute | IOC confirmé, mouvement latéral, élévation de privilège | < 1h |
| Moyenne | Alerte EDR non confirmée, comportement suspect | < 4h |
| Faible | Faux positif probable, activité atypique sans impact | < 24h |

### Processus de triage
```
1. RECEVOIR l'alerte (SIEM / EDR / email)
2. QUALIFIER : vrai positif ou faux positif ?
   → Contexte : heure, utilisateur, machine, IP source
   → Est-ce attendu pour ce compte/machine ?
3. PRIORISER selon la sévérité
4. CONTENIR si sévérité Critique/Haute (isoler AVANT d'investiguer)
5. NOTIFIER : @IT-Commandare-NOC + superviseur + client si P1
6. INVESTIGUER
7. REMÉDIER
8. DOCUMENTER → @IT-KnowledgeKeeper + @IT-ReportMaster
```

---

## RB-SOC-002 — SIEM — Splunk / Microsoft Sentinel / QRadar

### Microsoft Sentinel — Requêtes KQL essentielles
```kql
// Connexions échouées (brute force)
SigninLogs
| where ResultType != 0
| summarize Failures = count() by UserPrincipalName, IPAddress, bin(TimeGenerated, 5m)
| where Failures > 10
| order by Failures desc

// Nouveau pays de connexion
SigninLogs
| where ResultType == 0
| summarize Countries = make_set(LocationDetails.countryOrRegion) by UserPrincipalName
| where array_length(Countries) > 1

// Règles de transfert email suspectes (compte compromis)
OfficeActivity
| where Operation in ("Set-Mailbox", "New-InboxRule", "Set-InboxRule")
| where Parameters contains "ForwardTo" or Parameters contains "RedirectTo"
| project TimeGenerated, UserId, Parameters

// Alerte EDR — Defender for Endpoint
DeviceEvents
| where ActionType == "AntivirusDetection"
| project TimeGenerated, DeviceName, FileName, FolderPath, ThreatName
| order by TimeGenerated desc

// Connexions vers des IPs suspectes
DeviceNetworkEvents
| where RemoteIPType == "Public"
| join kind=inner (ThreatIntelligenceIndicator
    | where Active == true and ExpirationDateTime > now()
    | project NetworkIP) on $left.RemoteIP == $right.NetworkIP
| project TimeGenerated, DeviceName, RemoteIP, RemotePort
```

### Splunk — Requêtes SPL essentielles
```spl
// Brute force SSH/RDP
index=security sourcetype=WinEventLog:Security EventCode=4625
| stats count by src_ip, user
| where count > 20
| sort -count

// Élévation de privilège
index=security EventCode IN (4728,4732,4756) Group_Name IN ("Administrators","Domain Admins")
| table _time, Account_Name, Member_Account_Name, Group_Name, ComputerName

// Exécution PowerShell encodée (IoC commun)
index=windows source="WinEventLog:Microsoft-Windows-PowerShell/Operational" EventCode=4104
| search ScriptBlockText="*-enc*" OR ScriptBlockText="*-EncodedCommand*"
| table _time, ComputerName, UserID, ScriptBlockText

// Connexions réseau inhabituelles (volume élevé)
index=network | stats bytes_out by src_ip, dest_ip
| where bytes_out > 1000000000
| sort -bytes_out
```

### QRadar — Recherches AQL
```sql
-- Connexions depuis plusieurs pays en 1h
SELECT sourceip, username, COUNT(*) as events,
  MIN(starttime) as first_seen, MAX(starttime) as last_seen
FROM events
WHERE qid IN (SELECT id FROM qids WHERE name ILIKE '%authentication%')
AND DATEFORMAT(starttime,'HH') = DATEFORMAT(NOW(),'HH')
GROUP BY sourceip, username HAVING COUNT(DISTINCT country) > 1

-- Alerte volume trafic sortant
SELECT sourceip, destinationip, SUM(magnitude) as total_magnitude
FROM flows
WHERE flowtype = 'Outbound'
GROUP BY sourceip, destinationip
HAVING SUM(magnitude) > 100
ORDER BY total_magnitude DESC
```

---

## RB-SOC-003 — EDR — Microsoft Defender for Endpoint

### Actions d'investigation et de confinement
```powershell
# Via API Defender (nécessite Azure App Registration)
# Isoler une machine (confinement réseau)
Invoke-RestMethod -Uri "https://api.securitycenter.microsoft.com/api/machines/$machineId/isolate" `
  -Method POST -Headers @{Authorization="Bearer $token"} `
  -Body '{"Comment":"Isolation preventive - investigation SOC","IsolationType":"Full"}' `
  -ContentType "application/json"

# Lancer un scan antivirus
Invoke-RestMethod -Uri "https://api.securitycenter.microsoft.com/api/machines/$machineId/runAntiVirusScan" `
  -Method POST -Headers @{Authorization="Bearer $token"} `
  -Body '{"Comment":"Scan SOC","ScanType":"Full"}' `
  -ContentType "application/json"

# Collecter un package d'investigation
Invoke-RestMethod -Uri "https://api.securitycenter.microsoft.com/api/machines/$machineId/collectInvestigationPackage" `
  -Method POST -Headers @{Authorization="Bearer $token"} `
  -Body '{"Comment":"Collection forensique SOC"}' `
  -ContentType "application/json"
```

### Commandes PowerShell d'investigation locale
```powershell
# Processus suspects en cours (connexions réseau actives)
Get-NetTCPConnection -State Established |
  Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort,
    @{n='Process';e={(Get-Process -Id $_.OwningProcess -EA SilentlyContinue).Name}} |
  Where-Object {$_.RemoteAddress -ne "127.0.0.1"} |
  Sort-Object RemoteAddress

# Processus avec connexions réseau externes
netstat -bno | Select-String -Pattern "(ESTABLISHED|LISTENING)"

# Services récemment installés ou modifiés
Get-WinEvent -LogName System |
  Where-Object {$_.Id -in @(7000,7045) -and $_.TimeCreated -gt (Get-Date).AddDays(-7)} |
  Select-Object TimeCreated, Message

# Tâches planifiées suspectes
Get-ScheduledTask | Where-Object {$_.State -eq "Ready" -and $_.TaskPath -notlike "\Microsoft\*"} |
  Select-Object TaskName, TaskPath, @{n='Command';e={$_.Actions.Execute}}

# Clés Run (persistance malware)
Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
Get-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
Get-ItemProperty "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Run"
```

---

## RB-SOC-004 — Threat Hunting — Recherche proactive

### Hypothèses de chasse courantes (MSP)
```
1. Credential stuffing → chercher des connexions réussies après multiples échecs
2. Living off the land → exécutions PowerShell/WMI/MSHTA anormales
3. Persistance via tâches planifiées → tâches créées hors GPO
4. Exfiltration → gros volumes sortants vers des IPs inconnues
5. Mouvement latéral → connexions SMB/RDP entre postes non habituelles
```

### Hunting PowerShell / WMI (LOLBAS)
```powershell
# Processus PowerShell avec ligne de commande encodée
Get-WinEvent -LogName "Microsoft-Windows-PowerShell/Operational" |
  Where-Object {$_.Id -eq 4104 -and $_.Message -match "-enc|-EncodedCommand|IEX|Invoke-Expression"} |
  Select-Object TimeCreated, Message | Format-List

# Exécutions WMI suspectes
Get-WinEvent -LogName "Microsoft-Windows-WMI-Activity/Operational" |
  Where-Object {$_.Id -eq 5857} |
  Select-Object TimeCreated, Message

# Connexions MSHTA/WSCRIPT vers Internet
Get-WinEvent -LogName Security | Where-Object {
  $_.Id -eq 4688 -and
  ($_.Message -match "mshta.exe|wscript.exe|cscript.exe") -and
  $_.Message -match "http"
}
```

---

## RB-SOC-005 — Incident Response — Protocole complet

### Phase 1 — Identification (< 15 min)
```
- Confirmer l'alerte (SIEM / EDR / signalement utilisateur)
- Identifier : quoi, qui, quand, où (machine, compte, IP, action)
- Évaluer l'impact potentiel (nombre de machines, données exposées)
- Ouvrir un ticket P1 dans CW si impact > 1 machine ou données critiques
- Notifier : @IT-Commandare-NOC + superviseur
```

### Phase 2 — Confinement (< 30 min)
```powershell
# Isoler la machine via Defender (voir RB-SOC-003)
# OU isoler physiquement :
#   - Débrancher le câble réseau
#   - Désactiver la carte Wi-Fi (Device Manager)
#   - NE PAS ÉTEINDRE la machine (préserver la mémoire RAM)

# Désactiver le compte compromis immédiatement
Disable-ADAccount -Identity "NomUtilisateur"
# M365 :
Set-MsolUser -UserPrincipalName "user@domaine.com" -BlockCredential $true
# Révoquer toutes les sessions M365 :
Revoke-AzureADUserAllRefreshToken -ObjectId "[ObjectID]"
```

### Phase 3 — Éradication
```
- Identifier et supprimer tous les fichiers malveillants
- Supprimer les clés de registre de persistance
- Désinstaller les logiciels non autorisés installés par l'attaquant
- Supprimer les comptes créés par l'attaquant
- Réinitialiser TOUS les MDP des comptes potentiellement compromis
- Changer le KRBTGT (si compromission AD) → @IT-Assistant-N3
```

### Phase 4 — Récupération
```
- Restaurer depuis le dernier backup sain (voir @IT-BackupDRMaster)
- Vérifier l'intégrité des données restaurées
- Réintégrer la machine isolée progressivement (surveiller 24-48h)
- Vérifier que la menace n'a pas réapparu
```

### Phase 5 — Documentation (< 48h post-incident)
```
→ @IT-ReportMaster : rapport postmortem complet
→ @IT-KnowledgeKeeper : KB article sur la menace et les mesures prises
→ @IT-ClientDocMaster : mettre à jour la documentation Hudu du client
→ Réunion de retour d'expérience interne
```

---

## RB-SOC-006 — Ransomware — Protocole d'urgence

```
PRIORITÉ ABSOLUE : ISOLER avant tout le reste

1. ISOLER IMMÉDIATEMENT toutes les machines affectées
   → Débrancher réseau + couper Wi-Fi
   → NE PAS redémarrer, NE PAS éteindre (préserver les artefacts)

2. IDENTIFIER l'étendue
   → Quels partages réseau sont chiffrés ?
   → Quel est le vecteur d'entrée (email, RDP exposé, VPN ?) 

3. ALERTER
   → Superviseur + client + direction (P1 absolu)
   → @IT-Commandare-NOC pour coordination
   → Documenter : heure de découverte, machines impactées, données concernées

4. ÉVALUER les backups
   → @IT-BackupDRMaster : derniers backups disponibles et sains
   → Vérifier que les backups ne sont pas chiffrés aussi

5. CONTACTER les autorités si requis
   → Canada : Centre canadien pour la cybersécurité (cyber.gc.ca)
   → NE PAS payer la rançon sans avis juridique et direction

6. RÉCUPÉRATION depuis les backups uniquement
   → Rebuild des machines affectées (ne pas "nettoyer")
   → Restaurer depuis backup sain pré-infection

Escalade : Superviseur humain — Immédiat — Cas P1 absolu
```
