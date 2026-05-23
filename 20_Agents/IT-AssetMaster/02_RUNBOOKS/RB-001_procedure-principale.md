# RB-001 — Audit inventaire CMDB client
**Agent :** @IT-AssetMaster | **Type :** CMDB / Inventaire
**Version :** 1.0 | **Mis à jour :** 2026-03-29

## Objectif
Réaliser un audit complet de l'inventaire IT d'un client dans ConnectWise Configurations : identifier les actifs manquants, obsolètes, en fin de vie ou non conformes.

## Déclencheur
- QBR trimestrielle (revue systématique)
- Nouveau client onboardé
- Post-incident majeur (vérification d'impact sur les actifs)
- Demande client ou interne

## Prérequis
- [ ] Accès ConnectWise Manage → Configurations pour le client
- [ ] Export RMM (N-able/CW RMM) des appareils détectés
- [ ] Liste des licences connues (M365 admin, Azure, on-prem)

## Étapes

### Phase 1 — Collecte (données brutes)
1. Exporter la liste CW Configurations pour le client (CSV)
2. Exporter la liste RMM des appareils managés
3. Exporter la liste M365 licences assignées (si applicable)
4. Recueillir la liste des contrats/garanties actifs

### Phase 2 — Comparaison et écarts
1. Croiser CW Configurations vs RMM → identifier les appareils dans RMM mais pas dans CW
2. Croiser CW Configurations vs M365 → identifier les licences non suivies
3. Identifier les actifs CW sans heartbeat RMM > 30 jours (potentiellement retirés)
4. Identifier les actifs sans date EOL renseignée

### Phase 3 — Classification
1. Pour chaque actif : statut = Active / EOL / EOS / À remplacer / Décommissionné
2. Vérifier les dates EOL fabricant (Microsoft, Dell, HP, Cisco, Fortinet)
3. Taguer les actifs critiques (DC, firewall, serveur SQL, backup)
4. Calculer : total par catégorie, % couverture garantie, % patchés

### Phase 4 — Rapport et recommandations
1. Produire le rapport d'audit en YAML (mode AUDIT_INVENTAIRE)
2. Prioriser les recommandations par risque (EOL critique > gaps > conformité)
3. Proposer un plan de remédiation avec budget estimé si données disponibles

## Vérification
- [ ] Tous les appareils RMM ont un enregistrement CW correspondant
- [ ] Tous les actifs ont un statut (Active/EOL/EOS)
- [ ] Tous les serveurs/firewall ont une date EOL renseignée
- [ ] Rapport produit et transmis

---
*RB-001 — @IT-AssetMaster — Version 1.0*
