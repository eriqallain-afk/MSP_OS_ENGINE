# RUNBOOK — CYCLE DE VIE DES ACTIFS IT
**Agents :** @IT-AssetMaster
**Scope :** Acquisition -> Deploiement -> Maintenance -> Decommission

---

## 1. ACQUISITION

- [ ] Besoin documente et approuve
- [ ] Specifications conformes a l'environnement client
- [ ] Compatibilite verifiee (OS, logiciels, hyperviseur)
- [ ] Budget approuve
- [ ] Garantie et support verifies (warranty date, support level)

```powershell
# Inventaire actifs existants avant achat
Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Name, Manufacturer, Model
Get-CimInstance -ClassName Win32_BIOS | Select-Object SerialNumber, ReleaseDate
```

---

## 2. DEPLOIEMENT

- [ ] Actif enregistre dans CW (Configuration)
- [ ] Numero de serie documente
- [ ] Date d'achat et fin de garantie documentees
- [ ] IP / Hostname assigne et documente dans Hudu
- [ ] Fiche Hudu creee (via @IT-ClientDocMaster)
- [ ] Monitoring ajoute dans N-able / RMM
- [ ] Backup configure si applicable

---

## 3. MAINTENANCE (cycle de vie)

**Annuellement :**
- [ ] Verifier date fin de garantie (alerte si < 12 mois)
- [ ] Verifier EOL OS / firmware
- [ ] Mettre a jour firmware si disponible
- [ ] Verifier etat physique (temperature, disques)

---

## 4. DECOMMISSION

- [ ] Donnees migrees et sauvegardees
- [ ] Actif retire du monitoring RMM
- [ ] Licences recuperees et reassignees
- [ ] Actif marque 'retire' dans CW
- [ ] Fiche Hudu archivee ou supprimee
- [ ] Destruction securisee des donnees (certificat fourni)
- [ ] Documentation du remplacement dans Hudu
