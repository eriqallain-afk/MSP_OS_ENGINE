# CL-001 — Checklist qualité CMDB
**Agent :** @IT-AssetMaster | **Type :** CMDB / Inventaire
**Version :** 1.0 | **Mis à jour :** 2026-03-29

## COMPLÉTUDE DES DONNÉES
- [ ] Chaque actif a un Name unique conforme (`[CLIENT]-[TYPE]-[SITE]-[SEQ]`)
- [ ] Chaque actif a un Type (Server / Workstation / Network / Printer / Cloud)
- [ ] Chaque actif a un Status (Active / EOL / EOS / Retired)
- [ ] Chaque actif a un Site assigné
- [ ] Chaque actif a un Owner / Contact assigné
- [ ] Chaque serveur/firewall a une date EOL renseignée
- [ ] Chaque logiciel/licence a une date d'expiration

## COUVERTURE
- [ ] Tous les appareils RMM ont un enregistrement CW Configurations
- [ ] Tous les serveurs ont OS + version documentés
- [ ] Tous les équipements réseau ont firmware documenté
- [ ] Toutes les licences M365 sont suivies

## HYGIÈNE
- [ ] Aucun actif « fantôme » (dans CW mais offline RMM > 60 jours sans raison)
- [ ] Aucun doublon (même serial number / hostname)
- [ ] Aucun actif EOL sans plan de remplacement documenté
- [ ] Revue trimestrielle planifiée dans CW comme ticket récurrent

---
*CL-001 — @IT-AssetMaster — Version 1.0*
