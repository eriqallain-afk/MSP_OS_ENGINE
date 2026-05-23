# SUP-OPS-CommandareTech_V1
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-Assistant-N2 | @IT-FrontLine | @IT-MaintenanceMaster | @IT-SysAdmin
**Département :** SUP | **Source :** IT MSP Intelligence Platform

---

## 1. RECEPTION D'UN INCIDENT TECHNIQUE

**Informations a collecter :**
- Client + systeme affecte
- Heure d'apparition du probleme
- Changements recents (patching, config, installation)
- Symptomes exacts (messages d'erreur, logs)
- Impact utilisateurs (combien / quels services)

---

## 2. METHODE TROUBLESHOOTING

1. DEFINIR le probleme clairement
2. COLLECTER les donnees (logs, screenshots, metriques)
3. ISOLER la cause probable (infrastructure / applicatif / reseau / securite)
4. TESTER une hypothese a la fois
5. IMPLEMENTER le correctif
6. VALIDER le retour a la normale
7. DOCUMENTER

---

## 3. ESCALADE SELON LE DOMAINE

| Domaine | Agent cible |
|---|---|
| Securite / malware / compte compromis | @IT-SecurityMaster |
| Infrastructure serveur / VM | @IT-Commandare-Infra |
| Reseau / firewall / VPN | @IT-NetworkMaster |
| Cloud M365 / Azure | @IT-CloudMaster |
| Backup / DR | @IT-BackupDRMaster |
| Support N3 guide | @IT-Assistant-N3 |

---

## 4. CONFINEMENT SOC INITIAL

Si incident de securite detecte :
- [ ] Isoler la machine du reseau (physique ou via RMM)
- [ ] Bloquer le compte compromis (AD + M365)
- [ ] Revoquer les sessions actives M365
- [ ] NE PAS eteindre la machine (preserve la memoire)
- [ ] Documenter l'heure et les actions dans CW
- [ ] Escalader immediatement a @IT-SecurityMaster

---

## 5. PLAN DE REMEDIATION (CW Discussion)

```
PROBLEME IDENTIFIE : [Description]
CAUSE RACINE : [RCA]
ACTIONS EFFECTUEES : [Liste]
RESULTAT : [Resolu / Contourne / Escalade]
PREVENTION : [Action pour eviter recidive]
```
