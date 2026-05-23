# MEM-IT-Comms-Templates — v1.0
meta:
  doc_id: MEM-IT-Comms-Templates
  version: v1.0
  status: normative
  updated_on: 2026-01-22
  owners:
    primary: CMD-OPR
    co_owners: [CMD-NOC, SEC-X]

## 1) Interne (Teams/Slack)
### A) Incident start
[INCIDENT][Sx] <INC_ID> — <ClientCode> — <Service>
- Impact:
- Scope:
- Owner:
- War room / canal:
- Hypothèse initiale:
- Actions en cours:
- Prochaine update: HH:MM

### B) Update
[UPDATE][Sx] <INC_ID>
- État: investigation / mitigation / monitoring / resolved
- Changements depuis dernière update:
- Impact actuel:
- Next steps:
- ETA (si possible):
- Prochaine update: HH:MM

### C) Resolved
[RESOLVED][Sx] <INC_ID>
- Résolution:
- Durée:
- Cause probable (RCA rapide):
- Actions follow-up:
- Postmortem: oui/non (date)

## 2) Client (email)
### A) Initial notification
Objet: Incident [Sx] — <Service> — <ClientName> — <INC_ID>
Bonjour,
Nous avons détecté un incident impactant <service> depuis <HH:MM TZ>.
- Impact observé:
- Périmètre:
Nos équipes sont mobilisées. Prochaine mise à jour à <HH:MM TZ>.
Cordialement,
<MSP NOC>

### B) Update
Objet: Mise à jour — Incident [Sx] — <INC_ID>
- Statut:
- Impact actuel:
- Actions en cours:
- Prochaine mise à jour: <HH:MM TZ>

### C) Resolution
Objet: Résolution — Incident [Sx] — <INC_ID>
L’incident est résolu depuis <HH:MM TZ>.
- Résumé:
- Mesure corrective immédiate:
- Actions de prévention (si applicable):
Si un postmortem est prévu (S0/S1), nous partagerons un compte-rendu.

## Checklist Comms
- [ ] Ton factuel (pas de spéculation)
- [ ] Prochaine heure d’update indiquée
- [ ] Validation SEC-X si incident/suspicion sécurité
- [ ] IDs (INC/RFC/PM) présents partout
