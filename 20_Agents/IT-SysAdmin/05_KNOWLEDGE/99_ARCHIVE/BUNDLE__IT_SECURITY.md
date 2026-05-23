# BUNDLE — IT Sécurité MSP
**ID :** BUNDLE__IT_SECURITY  
**Version :** 1.0 | **Usage :** Agents sécurité et NOC  
**Agents consommateurs :** IT-SecurityMaster, IT-Commandare-NOC, IT-MonitoringMaster, IT-Commandare-TECH

---

## 1. MATRICE SÉVÉRITÉ SÉCURITÉ COMPLÈTE

| Niveau | Critères | Actions immédiates | Escalade |
|--------|----------|-------------------|---------|
| P1 | Ransomware actif, DC compromis, exfiltration data | Isolation réseau, révoquer accès | NOC + CTO immédiat |
| P1 | Breach credentials admin confirmé | Changer tous les creds, MFA forcé | NOC + CTO immédiat |
| P2 | Mouvement latéral suspect | Isolation preventive du segment | NOC dans 30 min |
| P2 | Phishing cliqué + credential soumis | Révoquer session, changer MDP | NOC dans 30 min |
| P3 | Alerte EDR non confirmée | Investigation, ne pas escalader | Analyser |
| P3 | CVE critique (CVSS ≥ 9.0) nouvelle | Patch emergency planning | Dans 24h |
| P4 | CVE modérée (CVSS 4.0-8.9) | Planifier patch cycle normal | Dans 72h |

---

## 2. TYPES D'INCIDENTS — DÉFINITIONS ET IOCs

### Ransomware
- **Indicateurs :** extensions fichiers modifiées, fichiers README.txt, CPU/disk élevé, chiffrement réseau
- **IOCs communs :** processus non signés, modifications registre Run keys, shadow copies supprimées
- **Action immédiate :** isoler réseau (ne pas éteindre), préserver artefacts RAM

### Phishing
- **Indicateurs :** email suspect, lien externe cliqué, credentials soumis sur faux site
- **IOCs :** domaine usurpé, header email (SPF/DKIM/DMARC fail), user-agent inhabituel
- **Action immédiate :** révoquer sessions Azure AD, changer mot de passe, analyse mailbox

### Attaque par force brute / credential stuffing
- **Indicateurs :** logs Event 4625 (failed logon) en masse, lockouts multiples
- **IOCs :** IPs suspectes, horaires inhabituels, compte service ciblé
- **Action immédiate :** bloquer IP source, activer MFA emergency, vérifier accès réussis

### Mouvement latéral
- **Indicateurs :** connexions RDP/WMI entre postes inhabituelles, comptes admin sur workstations
- **IOCs :** Event 4624 (logon) type 3 et 10 anormaux, PsExec, WMImplant
- **Action immédiate :** isoler segment, auditer comptes privilégiés

---

## 3. COMMANDES COLLECTE FORENSICS

```powershell
# Package de collecte artefacts (READ-ONLY)
$OutDir = "$env:SystemDrive\IR_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $OutDir | Out-Null

# Processus + hashes
Get-Process | Select-Object Id, ProcessName, Path, CPU, WS | Export-Csv "$OutDir\processes.csv" -NoTypeInformation

# Connexions réseau actives
$netstat = netstat -anob 2>&1
$netstat | Out-File "$OutDir\netstat.txt"

# Run keys (persistence)
Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" | Export-Csv "$OutDir\run_keys.csv" -NoTypeInformation
Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" | Export-Csv "$OutDir\run_keys_user.csv" -NoTypeInformation

# Comptes locaux + derniers logins
Get-LocalUser | Select-Object Name, Enabled, LastLogon | Export-Csv "$OutDir\local_users.csv" -NoTypeInformation

# Événements sécurité (4624=logon, 4625=failed, 4688=process creation)
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624,4625,4688; StartTime=(Get-Date).AddHours(-24)} -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Id, Message | Export-Csv "$OutDir\security_events.csv" -NoTypeInformation

Write-Host "Artefacts collectés dans : $OutDir"
```

---

## 4. FRAMEWORK CIS CONTROLS v8 — TOP 10 PRIORITÉS MSP

| Contrôle | Description | Implémentation rapide |
|----------|-------------|----------------------|
| CIS 1 | Inventaire actifs matériels | CMDB via IT-AssetMaster |
| CIS 2 | Inventaire logiciels | SAM via IT-SoftwMaster |
| CIS 3 | Protection des données | Chiffrement + backup |
| CIS 4 | Config sécurisée HW/SW | Hardening baselines |
| CIS 5 | Gestion comptes et accès | AD + Azure AD + PAM |
| CIS 6 | Gestion des accès | MFA universel, RBAC |
| CIS 7 | Gestion vulnérabilités | Patch management |
| CIS 8 | Log management | SIEM / Event collection |
| CIS 10 | Malware defense | EDR sur tous les endpoints |
| CIS 12 | Gestion réseau | Segmentation, firewall |

---

## 5. SEUILS EDR / SCORING CVSS

| CVSS Score | Sévérité | Patch délai | Action |
|-----------|----------|------------|--------|
| 9.0 - 10.0 | Critique | 24-48h | Emergency patch |
| 7.0 - 8.9 | Élevé | 7 jours | Prochain cycle |
| 4.0 - 6.9 | Moyen | 30 jours | Cycle mensuel |
| 0.1 - 3.9 | Faible | 90 jours | Best effort |

---

## 6. CONTACTS ET RESSOURCES SÉCURITÉ

| Ressource | URL / Contact |
|-----------|--------------|
| NIST NVD (CVEs) | nvd.nist.gov |
| Microsoft Security Updates | msrc.microsoft.com |
| CIS Benchmarks | cisecurity.org |
| Have I Been Pwned (HIBP) | haveibeenpwned.com |
| VirusTotal (analyse fichiers/URLs) | virustotal.com |
| MX Toolbox (email headers) | mxtoolbox.com |
