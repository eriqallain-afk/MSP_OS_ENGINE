# RUNBOOK — TRIAGE ALERTES SECURITE
**Agents :** @IT-SecurityMaster, IT-MaintenanceMaster, IT-SysAdmin
**Scope :** Qualification initiale des alertes SOC/SIEM/EDR

---

## 1. SOURCES D'ALERTES

| Source | Outil | Criticite typique |
|---|---|---|
| EDR | Microsoft Defender / SentinelOne | P1-P2 si detection active |
| SIEM | Sentinel / Splunk / QRadar | P1-P3 selon rule |
| Firewall | WatchGuard / Fortinet | P2-P3 |
| M365 | Defender for O365 | P1-P2 si compte compromis |
| RMM | N-able / Auvik | P2-P3 |

---

## 2. TRIAGE — 5 MINUTES MAXIMUM

1. Lire l'alerte complete (ne pas agir avant de comprendre)
2. Identifier le systeme source et l'utilisateur si applicable
3. Qualifier : vrai positif / faux positif / a investiguer
4. Qualifier P1/P2/P3
5. Documenter dans CW

**Signaux P1 immediats :**
- Malware actif (execution confirmee)
- Mouvement lateral detecte
- Exfiltration de donnees en cours
- Compte admin compromis
- Ransomware indicators

---

## 3. ESCALADE

| Detection | Action |
|---|---|
| Malware actif | Isoler machine -> @IT-SecurityMaster IR |
| Compte compromis | Revoquer session -> MFA reset -> @IT-SecurityMaster |
| Ransomware | ISOLER reseau -> @IT-UrgenceMaster -> @IT-SecurityMaster |
| Faux positif confirme | Documenter -> Tuner la regle |

---

## 4. DOCUMENTATION OBLIGATOIRE

Chaque alerte documentee dans CW avec :
- Source de l'alerte + regle declenchee
- Verdict : vrai positif / faux positif / a surveiller
- Action prise
- Si faux positif : exception ajoutee dans l'outil
