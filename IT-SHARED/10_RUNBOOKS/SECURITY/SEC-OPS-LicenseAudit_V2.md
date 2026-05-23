# SEC-OPS-LicenseAudit_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SecurityMaster | @IT-Commandare-TECH | @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** SEC | **Source :** IT MSP Intelligence Platform

---

## 1. INVENTAIRE LOGICIELS INSTALLES

```powershell
$computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name
$results = foreach ($pc in $computers) {
    try {
        Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*' |
        Where-Object DisplayName |
        Select-Object @{N='Computer';E={$pc}}, DisplayName, DisplayVersion, InstallDate
    } catch { }
}
$results | Export-Csv 'Software_Inventory.csv' -NoTypeInformation
```

---

## 2. AUDIT LICENCES M365

```powershell
Connect-MgGraph -Scopes 'User.Read.All','Organization.Read.All'
Get-MgSubscribedSku | Select-Object SkuPartNumber,
  @{N='Total';E={$_.PrepaidUnits.Enabled}},
  @{N='Utilisees';E={$_.ConsumedUnits}},
  @{N='Disponibles';E={$_.PrepaidUnits.Enabled - $_.ConsumedUnits}}
```

---

## 3. RECUPERATION DE LICENCES

**Licences recuperables typiques :**
- Comptes M365 de departs non desactives
- Logiciels installes mais non utilises
- Licences sur des VMs decommissionnees

---

## 4. DOCUMENTATION

- [ ] Exporter inventaire dans CW (Configurations)
- [ ] Mettre a jour Hudu avec licences actives
- [ ] Documenter les renouvellements (alerte 90 jours avant)
- [ ] Recuperer les licences inutilisees
