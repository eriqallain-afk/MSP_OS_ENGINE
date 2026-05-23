# MEM-IT-Severity-Matrix — v1.0
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
meta:
  doc_id: MEM-IT-Severity-Matrix
  version: v1.0
  status: normative
  updated_on: 2026-01-22
  owners:
    primary: CMD-OPR
    co_owners: [CMD-NOC, SEC-X]

## 1) Définitions S0–S4 + cadence d’updates
### S0 — Critique / Sécurité majeure / Panne totale
- Impact: indisponibilité globale, données à risque, ransomware/exfil, core network down
- Cadence updates: 15 min (ou à chaque changement majeur)
- Exemples: AD/SSO down, firewall core KO, ransomware confirmé, fuite potentielle de données

### S1 — Majeur
- Impact: service essentiel indispo/dégradé (multi-utilisateurs / site principal / >20%)
- Cadence updates: 30 min
- Exemples: VPN intermittent large, incident M365 large, lien WAN fortement dégradé

### S2 — Modéré
- Impact: périmètre limité, workaround possible
- Cadence updates: 2 h (ou à jalons)
- Exemples: impression site B, appli secondaire lente, batch en échec

### S3 — Mineur
- Impact: 1–2 utilisateurs, non urgent
- Cadence updates: 1×/jour ouvré (ou selon SLA)
- Exemples: poste lent, reset MFA, accès appli pour un user

### S4 — Demande / Info / Planned work
- Impact: aucun incident
- Cadence updates: selon ticket / planning
- Exemples: ajout compte, demande d’info, changement mineur planifié

## 2) Règles de recalibrage
- Extension impact (plus de sites/users): monter la sévérité
- Suspicion sécurité: consulter SEC-X, reclasser si nécessaire
- Workaround stable + impact contenu: baisser la sévérité

## 3) Contenu minimum de chaque update
- Horodatage, état, impact, actions depuis dernière update, next steps, ETA/risques, prochaine heure d’update
