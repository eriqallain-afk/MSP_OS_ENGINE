# Guide d'utilisation — @IT-SecurityMaster (v1.0)
> **Pour :** Techniciens N1/N2/N3 MSP
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-SecurityMaster ?

**IT-SecurityMaster est l'expert cybersécurité du MSP — triage alertes, incident response, audit posture.**

Il analyse les risques, classe les incidents de sécurité (ransomware, phishing, brèche, mouvement latéral), prescrit les actions de containment, et produit la documentation nécessaire pour ConnectWise, les rapports clients et la base de connaissances.

| Mode | Ce qu'il fait |
|---|---|
| Triage alerte | Classifie une alerte EDR/SIEM — IOC, severity, containment immédiat |
| Incident Response | Guide phase par phase : Identification → Containment → Éradication → Recovery |
| Audit posture | Évalue la posture sécurité selon CIS Controls v8 ou NIST CSF |
| Rapport sécurité | Rapport mensuel ou post-incident — métriques, CVE actives, recommandations |

> **Règle absolue : si une brèche est confirmée, escalader immédiatement.** Aucune remédiation à impact sans validation explicite préalable.

---

## Quand l'utiliser ?

- SentinelOne / EDR déclenche une alerte sur un endpoint
- Des règles de transfert Outlook vers un email externe sont détectées
- Un compte AD ou M365 semble compromis
- Un ransomware est suspecté ou confirmé
- Tu veux évaluer la posture sécurité d'un client (audit CIS/NIST)
- Tu dois produire un rapport sécurité mensuel ou post-incident
- Un CVE critique vient d'être publié — évaluer l'exposition client

---

## Les commandes principales

### `/triage [alerte]` — Triage alerte EDR/SIEM

La commande de premier réflexe face à une alerte de sécurité.

**Usage :**
```
/triage EDR SentinelOne — détection comportementale — DESKTOP-ABC123 — client Metal-Pless
/triage alerte SIEM — connexions suspectes depuis pays inconnu — compte admin
/triage règle Outlook — ForwardTo externe — marie.tremblay@client.com
/triage antivirus — trojan détecté — ACME-LT-MTL-042 — mis en quarantaine
```

**Ce que tu obtiens :**
- Classification : ransomware / phishing / breach / lateral_movement / vuln_exploit / faux positif
- Sévérité : P1 / P2 / P3 / P4 selon matrice
- IOC identifiés (hash, IP suspecte, chemin fichier, règle email)
- Scope initial : assets possiblement affectés
- Actions de containment immédiates (maximum 3 — priorité vitesse)
- Décision escalade : oui/non + vers qui

**Script de collecte IOC (lecture seule — compatible RMM) :**
```powershell
param([string]$Billet = "T[XXXXX]", [string]$Serveur = $env:COMPUTERNAME)
#Requires -Version 5.1
function Log {
    param([AllowEmptyString()][string]$Text = "", [string]$Color = "White")
    Write-Host $(if ([string]::IsNullOrEmpty($Text)) { " " } else { $Text }) -ForegroundColor $Color
}
# Connexions réseau suspectes (hors ports courants)
Get-NetTCPConnection -State Established | Where-Object { $_.RemotePort -notin @(80,443,445,3389) } |
    Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,@{N="PID";E={$_.OwningProcess}} |
    Format-Table -AutoSize
# Tâches planifiées créées récemment (< 7 jours)
Get-ScheduledTask | Where-Object { $_.Date -gt (Get-Date).AddDays(-7) } |
    Select-Object TaskName,TaskPath,Date | Format-Table -AutoSize
```

---

### `/ir [phase]` — Incident Response

Pour guider une réponse à incident P1/P2 phase par phase.

**Usage :**
```
/ir Identification — ransomware suspecté — 3 serveurs affectés — client Metal-Pless
/ir Containment — isoler ACME-SRV-MTL-001 du réseau — accès admin confirmé
/ir Éradication — malware supprimé — vérifier persistance
/ir Recovery — restaurer depuis backup Veeam — valider intégrité
/ir Post-incident — postmortem ransomware — rapport à produire
```

**Ce que tu obtiens par phase :**

| Phase | Livrables |
|---|---|
| Identification | Timeline, IOC confirmés, scope, assets affectés |
| Containment | Actions isolement réseau, révocation accès, blocage IOC |
| Éradication | Suppression malware, patch, réinitialisation credentials |
| Recovery | Restauration, validation intégrité, monitoring renforcé |
| Post-incident | Chronologie, cause racine, recommandations, rapport |

---

### `/audit` — Audit posture sécurité CIS / NIST

Pour évaluer la maturité sécurité d'un client selon un framework reconnu.

**Usage :**
```
/audit Metal-Pless — Framework CIS Controls v8
/audit Metal-Pless — NIST CSF — focus identités et accès
/audit Metal-Pless — périmètre : endpoints + email + M365
```

**Ce que tu obtiens :**
- Domaines évalués avec contrôle, état, risque et recommandation
- Score global /100
- Top 5 priorités de remédiation classées par impact/effort
- Plan d'action avec ETA suggérés

---

### `/rapport [période]` — Rapport sécurité mensuel ou post-incident

Pour produire un rapport client livrable ou un postmortem interne.

**Usage :**
```
/rapport mai 2026 — Metal-Pless — rapport mensuel
/rapport post-incident — ransomware — Metal-Pless — 2026-05-15
```

**Ce que tu obtiens :**
- Résumé exécutif (non technique — pour le client)
- Incidents du mois avec tableau (date, type, severity, statut)
- Métriques : MTTD (temps détection), MTTR (temps résolution)
- Top CVE actives (CVSS ≥ 7.0) dans le parc
- Recommandations prioritaires avec budget estimé si applicable

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

### Alerte EDR reçue — réflexe N1

```
1. Alerte SentinelOne / EDR reçue
   ↓
2. /triage [description alerte] — classification + severity
   ↓
3. Si P1 ou P2 → escalade @IT-Commandare-NOC + @IT-Commandare-TECH immédiat
   Si P3 → /ir Identification — investigation dans les 4h
   Si P4 → documenter dans CW — traiter dans les 24h
   ↓
4. Exécuter actions containment recommandées
   ↓
5. /close — Note Interne + Discussion CW
```

### Ransomware actif — protocole P1

```
1. Alerte ou signalement ransomware
   ↓
2. /ir Identification — définir le scope immédiatement
   ↓
3. ESCALADE IMMÉDIATE : @Superviseur humain + @IT-Commandare-NOC
   ↓
4. /ir Containment — isoler les assets affectés du réseau
   (Ne pas éteindre les machines — préserver les artefacts forensics)
   ↓
5. /ir Éradication — après validation superviseur
   ↓
6. /ir Recovery — restauration depuis @IT-BackupDRMaster
   ↓
7. /ir Post-incident → /rapport post-incident → @IT-ReportMaster
```

### Audit sécurité client planifié

```
1. Planification avec client (consentement explicite requis)
   ↓
2. /audit [client] — CIS Controls v8 ou NIST CSF
   ↓
3. Identifier les gaps critiques
   ↓
4. /rapport [mois] — inclure résultats audit
   ↓
5. Présenter recommandations priorisées au client
   ↓
6. /close — archiver dans CW
```

---

## Matrice de sévérité

| Niveau | Critères | Délai réponse | Escalade |
|---|---|---|---|
| P1 | Ransomware actif, brèche confirmée, service critique compromis | < 15 min | @IT-Commandare-NOC + @IT-Commandare-TECH |
| P2 | Intrusion suspectée, credentials compromis, mouvement latéral | < 1h | @IT-Commandare-NOC |
| P3 | Phishing détecté, alerte EDR non confirmée, CVE critique (CVSS ≥ 9) | < 4h | @IT-NOCDispatcher |
| P4 | Alerte informationnelle, vuln modérée (CVSS 4-8.9), audit demandé | < 24h | @IT-Assistant-N3 |

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| ZÉRO exploit ou code d'attaque | L'agent décrit les vecteurs, ne fournit jamais de PoC |
| ZÉRO désactivation EDR sans escalade | EDR désactivé = fenêtre d'attaque ouverte |
| ZÉRO secret capturé | Mots de passe, tokens, codes MFA ne sont jamais stockés |
| ZÉRO IP client dans les livrables externes | Convention MSP — confidentialité client |
| `⚠️ Impact` avant toute remédiation | Transparence — validation superviseur pour P1/P2 |
| Brèche confirmée = escalade superviseur humain | Décision légale/assueur — hors périmètre agent seul |
| `[À CONFIRMER]` si hypothèse non vérifiée | Éviter les faux positifs en incident response |

---

## Questions fréquentes

**Q : Quelle différence entre /triage et /ir ?**
`/triage` est le premier réflexe — il classifie une alerte et détermine la severity en moins de 2 minutes. `/ir` guide l'intervention complète phase par phase une fois que la severity est confirmée.

**Q : SentinelOne a mis une menace en quarantaine — est-ce que c'est réglé ?**
La quarantaine isole le fichier mais ne confirme pas que le système est sain. Faire `/triage` pour évaluer si la menace s'est propagée, a laissé de la persistance ou a exfiltré des données.

**Q : Que faire si je ne sais pas si c'est un faux positif ?**
Traiter comme un vrai positif jusqu'à preuve du contraire. Un faux positif traité à tort coûte du temps. Un vrai positif ignoré coûte une brèche. IT-SecurityMaster aide à classer VP/FP selon les IOC disponibles.

**Q : Quelle différence avec IT-CloudMaster pour les incidents M365 ?**
CloudMaster gère les incidents opérationnels M365 (messagerie, accès, appareils). SecurityMaster prend le relais dès qu'une compromission est suspectée — brèche Entra ID, règles Outlook d'exfiltration, compte admin M365 compromis.

**Q : Un rapport post-incident, c'est pour qui ?**
Le postmortem interne (technique) est pour l'équipe et la KB. Le rapport client est une version non technique sans IP ni commandes — vulnérabilité exposée, impact, actions prises, recommandations préventives. IT-SecurityMaster produit les deux formats.

---

*GUIDE_UTILISATION — IT-SecurityMaster v1.0 — MSP Intelligence AI — 2026-05-18*
