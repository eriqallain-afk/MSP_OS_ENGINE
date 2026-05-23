# MEM-IT-Routing-Rules — v1.0
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
meta:
  doc_id: MEM-IT-Routing-Rules
  version: v1.0
  status: normative
  updated_on: 2026-01-22
  owners:
    primary: CMD-OPR
    co_owners: [CMD-NOC, CMD-INFRA, CMD-TECH, SEC-X]

## 1) But
Router un événement vers le bon owner, préciser l’escalade et les artefacts attendus.

## 2) Routing (événement → owner → escalade → artefacts)
### A) RUN — Incidents
1) Monitoring/alerting (CPU/RAM/disque/service down/latence/erreurs)
- Owner: CMD-NOC
- Escalade: CMD-INFRA (infra), CMD-TECH (apps/outils), SEC-X (si suspicion)
- Format attendu: INC + status updates + actions log

2) Réseau (WAN/LAN/VPN/Firewall/DNS)
- Owner: CMD-INFRA
- Escalade: CMD-NOC (coord), Vendor/ISP, SEC-X (si sécurité)
- Format attendu: INC + diag + mitigation

3) Endpoint / MDM / M365 / apps support
- Owner: CMD-TECH
- Escalade: CMD-NOC si majeur, Vendor si SaaS, SEC-X si compromission
- Format attendu: TICKET (mineur) ou INC (majeur)

4) SLA / escalade client / coordination multi-équipes
- Owner: CMD-OPR
- Escalade: Management + CMD-* concernés
- Format attendu: situation report + décisions + risques + actions

### B) SEC — Sécurité
Suspicion phishing/malware/EDR alert/IAM anomalie/exfil
- Owner: SEC-X (IR lead)
- Escalade: CMD-NOC (war room), CMD-INFRA (containment), CMD-TECH (endpoints), Management, Client (selon matrice)
- Format attendu: SEC-INC + preuves + mesures containment

### C) CHANGE — RFC
1) Standard (faible risque, répétitif, pré-approuvé)
- Owner: CMD-OPR
- Escalade: CMD-INFRA/CMD-TECH selon scope
- Format attendu: RFC-Light

2) Majeur (prod, downtime, sécurité, réseau core)
- Owner: CMD-OPR (gouvernance) + Tech Lead: CMD-INFRA/CMD-TECH
- Escalade: SEC-X (si impact sécu) + validation client
- Format attendu: RFC-Light + test + rollback + fenêtre

### D) PROB — Problem Management
Récurrence incidents / dette technique / capacity
- Owner: CMD-OPR (Problem Manager)
- Escalade: CMD-INFRA/CMD-TECH + Management
- Format attendu: Problem Record + CAPA + suivi

## 3) Règles d’escalade “blocage”
- Blocage technique > 15 min (S0/S1): escalade immédiate L2/L3
- Dépendance vendor: ouvrir ticket vendor + capturer ID + ETA
- Risque sécurité: SEC-X propriétaire, containment prioritaire

## 4) Artefacts minimum
- INC: ID, sévérité, impact, scope, owner, timeline, actions, ETA, next update time, clôture (RCA rapide)
- RFC: objectif, scope, risques, tests, rollback, fenêtre, owner, validation
- SEC-INC: + preuves, containment, notifications si nécessaire
