# RB-001 — Triage et réponse alerte NOC
**Agent :** @IT-Commandare-NOC | **Type :** NOC Operations
**Version :** 1.0 | **Mis à jour :** 2026-03-28

## Objectif
Qualifier une alerte entrante (RMM, SIEM, Auvik, appel), déterminer sa sévérité, vérifier la corrélation, mobiliser le bon sous-agent et documenter dans ConnectWise.

## Déclencheur
- Alerte RMM (N-able, CW RMM, Datto RMM)
- Alerte SIEM ou Auvik
- Appel client signalant une indisponibilité
- Ticket CW non classifié transféré au NOC

## Prérequis
- [ ] Accès au dashboard RMM actif
- [ ] Accès ConnectWise Manage
- [ ] Canal Teams NOC disponible
- [ ] Liste des contacts d'urgence clients à jour

## Étapes

### Phase 1 — Réception (< 2 min)
1. Identifier la source de l'alerte (RMM / SIEM / Auvik / appel / ticket)
2. Identifier le client et le site impacté
3. Classifier le domaine : réseau | vpn | backup | monitoring | voip | urgence
4. Assigner la sévérité initiale selon la matrice NOC (P1/P2/P3/P4)
5. Si P1 → notice Teams immédiate AVANT de continuer

### Phase 2 — Corrélation (< 3 min pour P1/P2)
1. Vérifier les alertes actives pour le même client dans le RMM
2. Vérifier les alertes actives pour le même site
3. Vérifier si le même type d'alerte touche plusieurs clients
4. Si corrélation détectée :
   - Remonter la sévérité d'un niveau
   - Lier les alertes dans un seul billet CW parent
   - Documenter la corrélation dans la note interne
5. Si multi-services (≥ 3 alertes corrélées) → P1 automatique → IT-UrgenceMaster

### Phase 3 — Mobilisation sous-agent
1. Réseau / routage / VPN / firewall → @IT-NetworkMaster
2. Backup / DR / jobs en échec → @IT-BackupDRMaster
3. Monitoring / seuils / noise → @IT-MonitoringMaster
4. VoIP / trunk SIP / PBX → @IT-VoIPMaster
5. Serveurs / VMs / Cloud → REDIRIGER vers @IT-Commandare-Infra
6. Sécurité active → REDIRIGER vers @IT-SecurityMaster
7. Support utilisateur → REDIRIGER vers @IT-Commandare-TECH

### Phase 4 — Documentation et suivi
1. Ouvrir ou mettre à jour le billet CW avec :
   - Sévérité, domaine, corrélation éventuelle
   - Sous-agent mobilisé
   - Actions immédiates effectuées
2. Si P1/P2 : notice Teams publiée dans le canal NOC
3. Mettre à jour le billet selon les SLA (P1 = 15 min, P2 = 30 min)
4. À résolution : notice Teams de clôture + validation client

## Vérification
- [ ] Alerte classifiée (domaine + sévérité)
- [ ] Corrélation vérifiée (même client, même site, même type)
- [ ] Sous-agent approprié mobilisé
- [ ] Billet CW à jour avec chronologie
- [ ] Notice Teams publiée (si P1/P2)
- [ ] Client notifié (si P1/P2)

## Escalade
- P1 non résolu en 30 min → superviseur + IT-UrgenceMaster
- P2 non résolu en 2h → reclasser en P1 potentiel
- Suspicion sécurité → @IT-SecurityMaster immédiatement
- Besoin passation → handover selon protocole shift

---
*RB-001 — @IT-Commandare-NOC — Version 1.0*
