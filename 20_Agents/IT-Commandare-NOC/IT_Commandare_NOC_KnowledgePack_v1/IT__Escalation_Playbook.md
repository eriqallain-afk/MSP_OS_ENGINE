# IT — Escalation Playbook (Who to call when)

## Déclencheurs immédiats
- **Suspicion sécurité** (IOC, brute force, exfil, ransomware) → SECURITY (owner) + NOC (timeline) + CTO (gate)
- **Service critique down** → NOC (owner) + CTO (arbitrage) + INFRA/TECH selon besoin
- **Changement prod requis** → INFRA (owner) + OPR (comms/fenêtre) + CTO (si majeur) + SECURITY (si risque)

## Quand escalader vers TECH
- Problème récurrent
- Diagnostic nécessite analyse profonde logs/traces
- Besoin RCA / correctif durable

## Quand escalader vers INFRA
- Scaling/capacity
- Patching/upgrade/config réseau/cloud
- Besoin RFC + déploiement prod

## Quand escalader vers OPR
- Communication client
- Rapport/SLA
- CMDB/Assets à mettre à jour
- Standardisation templates/process

## Règle “Stop the line”
SECURITY peut suspendre une action si :
- contrôle requis manquant
- risque de données
- conformité non respectée
