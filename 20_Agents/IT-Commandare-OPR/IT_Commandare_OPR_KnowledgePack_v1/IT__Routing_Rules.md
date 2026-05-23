# IT — Routing Rules (Owner → Escalation → Output)

## Principe
Chaque événement a :
- **Owner** (qui pilote)
- **Escalades** (qui intervient/valide)
- **Output attendu** (format de sortie obligatoire)

---

## Tableau (règle simple)

### 1) Incident / Alerte live
- **Owner** : NOC
- **Escalade** :
  - TECH si diagnostic L2/L3 / RCA / fix durable
  - INFRA si changement plateforme / capacity / patching / config
  - SECURITY si IOC/suspicion sécu
  - OPR pour comms client + reporting + CMDB si impact
- **Outputs** :
  - `INCIDENT SNAPSHOT`, `TIMELINE`, `STATUS UPDATE`, `ESCALADE`

### 2) Maintenance planifiée / Patching / Upgrade plateforme
- **Owner** : INFRA
- **Escalade** :
  - OPR pour comms + fenêtre + reporting
  - SECURITY si surface de risque/contrôle requis
  - NOC pour surveillance renforcée durant fenêtre
- **Outputs** :
  - `RFC LIGHT`, `EXECUTION PLAN`, `POST-CHANGE VALIDATION`, `HANDOVER NOTES`

### 3) Bug logiciel / Incident récurrent / RCA
- **Owner** : TECH
- **Escalade** :
  - INFRA si change prod nécessaire
  - SECURITY si composante sécu
  - OPR pour documentation + comms si client impacté
- **Outputs** :
  - `TECH FINDINGS`, `REMEDIATION PLAN`, `RCA SUMMARY`, `REQUEST TO INFRA`

### 4) Demande client — rapport / com / assets / conformité documentaire
- **Owner** : OPR
- **Escalade** :
  - NOC si incident en cours
  - INFRA/TECH si action technique requise
  - SECURITY si conformité/sécu
- **Outputs** :
  - `CLIENT COMMS DRAFT`, `REPORT SNAPSHOT`, `CMDB/ASSET UPDATE PLAN`, `CLOSURE QA CHECKLIST`

### 5) Sécurité (IOC, phishing, brute force, exfil suspicion)
- **Owner** : SECURITY
- **Escalade** :
  - NOC pour détection + timeline + monitoring
  - TECH pour correction durable (hardening, patch, config)
  - INFRA pour changements plateforme/contrôles
  - OPR pour comms contrôlées + preuves + rapport
- **Outputs** :
  - `SECURITY TRIAGE`, `CONTAINMENT PLAN`, `EVIDENCE LOG`, `SECURITY UPDATE`

---

## Règle d’arbitrage CTOMaster
Si conflit ou risque majeur :
- CTOMaster produit `CTO DECISION` ou `PRIORITY ARBITRATION` et impose les **conditions go/no-go**.
