# SUP-N1N2-SupportTriage V2
**ID :** RUNBOOK__IT_SUPPORT_TRIAGE_N1N2N3_V1
**Version :** 3.0 | **Agent :** IT-Assistant-N3
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Applicable :** Tout ticket support entrant (NOC / SOC / Support / Autre)
**Mis à jour :** 2026-03-20

---

## RÈGLE D'ESCALADE — À LIRE EN PREMIER

> Quand une escalade est nécessaire, l'agent indique au technicien
> **quel département humain contacter** — pas un autre GPT.
>
> **Format systématique :**
> ```
> ⚠️ [ESCALADE REQUISE]
> Confirme l'escalade du billet avec ton coach d'équipe.
> Ensuite, escalade le billet dans ConnectWise vers le bon département :
> → [Nom du département]
> ```

### Correspondance départements
| Département CW | Responsable | Couverture |
|---|---|---|
| **NOC** | IT-Commandare-NOC | Alertes RMM, réseau, backup, monitoring, infra critique |
| **SOC** | IT-Commandare-SOC | Incidents sécurité, ransomware, breach, EDR |
| **Infra** | IT-Commandare-Infra | Serveurs, virtualisation, DC/AD, Azure, stockage |
| **Tech** | IT-Commandare-TECH | Support senior N3, RCA, escalades techniques complexes |
| **OPR** | IT-Commandare-OPR | Clôture formelle, communication client, rapports |

---

## ARBRE DE DÉCISION INITIAL

```
TICKET ENTRANT (via CW / email / téléphone)
│
├─ Sécurité (virus, ransomware, phishing, accès non autorisé)
│   └─ → P1/P2 → [ESCALADE → département SOC]
│
├─ Infrastructure critique down (DC, réseau principal, backup)
│   └─ → P1/P2 → [ESCALADE → département NOC]
│
├─ Cloud/M365 inaccessible (Exchange, SharePoint, Teams)
│   └─ → P2 → [ESCALADE → département Infra]
│
├─ Réseau (connectivité site, VPN, WiFi)
│   └─ → P2/P3 → [ESCALADE → département NOC]
│
├─ Serveur non critique (lent, service arrêté)
│   └─ → P2/P3 → [ESCALADE → département Infra]
│
├─ Backup en échec
│   └─ → P2/P3 → [ESCALADE → département NOC]
│
├─ Téléphonie (VoIP coupure)
│   └─ → P2/P3 → [ESCALADE → département NOC]
│
├─ Logiciel métier (ERP, CRM)
│   └─ → P3 → N2 ou fournisseur applicatif
│
└─ Workstation / utilisateur (PC, imprimante, compte)
    └─ → P3/P4 → N1 direct
```

---

## NIVEAU 1 — WORKSTATION & UTILISATEUR

### 1.1 Réinitialisation mot de passe AD
```powershell
# ⚠️ Validation identité utilisateur requise avant exécution
Set-ADAccountPassword -Identity "username" -Reset -NewPassword (Read-Host -AsSecureString "Nouveau MDP")
Set-ADUser -Identity "username" -ChangePasswordAtLogon $true
Unlock-ADAccount -Identity "username"
```

### 1.2 PC lent / gelé
Checklist N1 :
1. Redémarrage simple → résout 40% des cas
2. Task Manager : CPU/RAM usage élevé ? Identifier processus
3. Espace disque < 10% → nettoyer (Disk Cleanup, dossier TEMP)
4. Windows Update en cours silencieusement ?
5. Event Viewer → erreurs récentes Application/System
6. Si > 30 min non résolu → escalader N2

### 1.3 Problème imprimante
Checklist N1 :
1. Câble/WiFi connecté ? PC voit l'imprimante ?
2. Redémarrer spooler : `Restart-Service Spooler`
3. File d'attente : supprimer jobs bloqués
4. Réinstaller driver si nécessaire
5. Si imprimante réseau : tester connectivité réseau

### 1.4 Outlook / email ne fonctionne pas
1. Tester webmail (OWA / outlook.com) — isole client vs serveur
2. Outlook en mode Safe (`outlook.exe /safe`)
3. Rebuild profil Outlook si corrompu
4. Si tous les utilisateurs affectés → P2 → [ESCALADE → département Infra]

---

## NIVEAU 2 — RÉSEAU LOCAL & SERVEURS NON CRITIQUES

### 2.1 Connectivité réseau partielle
```powershell
# Tests de base (ne pas inclure les IPs dans les livrables clients)
Test-NetConnection -ComputerName "8.8.8.8" -InformationLevel Detailed
ipconfig /all
Resolve-DnsName google.com
```
Si persistant → [ESCALADE → département NOC]

### 2.2 Service Windows arrêté
```powershell
Get-Service -Name "ServiceName" | Select-Object Name, Status, StartType
Start-Service -Name "ServiceName"
Get-EventLog -LogName System -Source "*ServiceName*" -Newest 20
```

### 2.3 Espace disque critique
```powershell
Get-ChildItem -Path "C:\" -Recurse -ErrorAction SilentlyContinue |
    Sort-Object Length -Descending |
    Select-Object -First 20 FullName, @{N='SizeMB';E={[math]::Round($_.Length/1MB,2)}}
```

---

## NIVEAU 3 — INFRASTRUCTURE CRITIQUE

**Toujours via le département Tech (coach d'équipe / senior).**

Checklist N3 minimum avant escalade :
- [ ] Symptôme précis documenté
- [ ] Heure de début
- [ ] Assets affectés listés
- [ ] Actions N1/N2 déjà tentées documentées
- [ ] Impact business évalué

---

## PROCÉDURE D'ESCALADE — TEXTE À AFFICHER AU TECHNICIEN

```
⚠️ [ESCALADE REQUISE — département [NOC / SOC / Infra / Tech]]

Confirme l'escalade du billet avec ton coach d'équipe.
Ensuite, escalade le billet dans ConnectWise vers le bon département.

Informations à transmettre :
- Ticket : #[XXXXX]
- Client : [Nom]
- Priorité : P[1/2]
- Symptôme : [Description précise]
- Actions déjà tentées : [Liste]
- Assets affectés : [Liste]
```

---

## SLA CIBLES MSP

| Priorité | Temps réponse | Temps résolution | Escalade auto |
|----------|--------------|-----------------|---------------|
| P1 | 15 min | 4h | 30 min → coach d'équipe |
| P2 | 30 min | 8h | 2h → coach d'équipe |
| P3 | 2h | 24h | 4h → N2 |
| P4 | 4h | 72h | 24h → N2 |
