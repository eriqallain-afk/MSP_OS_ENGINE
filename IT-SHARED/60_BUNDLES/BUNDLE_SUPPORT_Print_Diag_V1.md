# BUNDLE_SUPPORT_Print_Diag_V1
**Catégorie :** Diagnostic impression — Imprimantes réseau, serveurs d'impression, pilotes
**Agents :** @IT-Assistant-N2 | @IT-Assistant-N3 | @IT-MaintenanceMaster | IT-SysAdmin
**Version :** 1.0 | **Date :** 2026-04-05

---

## RB-PRINT-001 — Arbre de décision

```
Imprimante joignable ? → ping [IP_IMPRIMANTE]
  OUI → Étape 2
  NON → RB-PRINT-003 (problème réseau/physique)

Un seul poste ou plusieurs ?
  Un seul   → RB-PRINT-002 (problème local)
  Plusieurs → RB-PRINT-004 (problème serveur ou imprimante)

Partagée via serveur print ?
  OUI → RB-PRINT-005
  NON → File d'attente locale
```

---

## RB-PRINT-002 — Problème un seul poste

### Vider la file bloquée
```powershell
Stop-Service -Name Spooler -Force
Remove-Item "C:\Windows\System32\spool\PRINTERS\*" -Force
Start-Service -Name Spooler
Get-Service Spooler
```

### Réinstaller l'imprimante (IP directe)
```powershell
Remove-Printer -Name "NomImprimante"
Remove-PrinterPort -Name "IP_XXXXX"
Add-PrinterPort -Name "IP_[IP_IMPRIMANTE]" -PrinterHostAddress "[IP_IMPRIMANTE]"
Add-Printer -Name "NomImprimante" -DriverName "NomDriver" -PortName "IP_[IP_IMPRIMANTE]"
```

### Réinstaller le driver
```
Gestionnaire de périphériques → File d'impression → clic droit → Désinstaller
Cocher : "Supprimer le logiciel pilote pour ce périphérique"
Télécharger driver depuis le site fabricant (HP, Canon, Konica, Xerox)
Réajouter l'imprimante
```

---

## RB-PRINT-003 — Imprimante hors réseau

```
1. Vérifier voyants LED imprimante et câble réseau (switch actif ?)
2. Imprimer page config réseau depuis le panneau imprimante
3. Confirmer l'IP (peut avoir changé en DHCP)
4. Si IP changée → configurer IP statique via interface web : http://[IP_ACTUELLE]
   → Network Settings → IP Configuration → Static
5. Si Wi-Fi : Menu imprimante → Réseau → Wi-Fi → Reconnect
```

### Retrouver l'imprimante sur le réseau
```powershell
# Chercher via DHCP (par MAC)
Get-DhcpServerv4Lease -ScopeId "[SCOPE_IP]" |
  Where-Object {$_.ClientId -like "*[MAC_PARTIELLE]*"}
```

---

## RB-PRINT-004 — Plusieurs postes impactés

```
1. Redémarrer l'imprimante (éteindre 30 sec)
2. Vérifier consommables : http://[IP_IMPRIMANTE] → Status / Supply Levels
3. Vérifier bourrages, tiroirs ouverts
4. Imprimer page test depuis l'imprimante (sans PC)
   → OK : problème réseau ou spouleur
   → KO : problème matériel → support fabricant

Test ports réseau :
```
```powershell
Test-NetConnection -ComputerName "[IP_IMPRIMANTE]" -Port 9100   # JetDirect
Test-NetConnection -ComputerName "[IP_IMPRIMANTE]" -Port 443    # HTTPS web
Test-NetConnection -ComputerName "[IP_IMPRIMANTE]" -Port 631    # IPP
```

---

## RB-PRINT-005 — Serveur d'impression Windows

### Santé du serveur
```powershell
# Vérifier service + imprimantes partagées
Get-Service Spooler -ComputerName NomServeur
Get-Printer -ComputerName NomServeur | Select-Object Name, PrinterStatus, Shared

# Jobs bloqués
Get-PrintJob -PrinterName "NomImprimante" -ComputerName NomServeur | Remove-PrintJob

# Reset complet Spooler serveur
Invoke-Command -ComputerName NomServeur -ScriptBlock {
    Stop-Service Spooler -Force
    Remove-Item "C:\Windows\System32\spool\PRINTERS\*" -Force
    Start-Service Spooler
}
```

### Driver manquant ou corrompu
```powershell
Get-PrinterDriver -ComputerName NomServeur
Add-PrinterDriver -Name "HP Universal Printing PCL 6" -ComputerName NomServeur
Remove-PrinterDriver -Name "NomDriverCorrompu" -ComputerName NomServeur
```

### Reconnexion client à l'imprimante partagée
```powershell
Add-Printer -ConnectionName "\\NomServeur\NomPartage"
# OU : Win+R → \\NomServeur → double-clic sur l'imprimante
```

---

## RB-PRINT-006 — Forcer impression N/B (contrôle coûts)

```
Via GPO :
Computer Configuration → Policies → Administrative Templates → Printers
→ Printer Properties → Advanced → Printing Defaults → Color → Black & White

Via script déploiement pour standardiser tous les postes
```

---

## RB-PRINT-007 — Universal Print (Microsoft M365)

```
Prérequis : Licence M365 Business Premium ou Enterprise
Azure Portal → Universal Print → Printers → Register Printer

Si imprimante non native Universal Print :
→ Installer Universal Print Connector sur serveur Windows
→ Enregistrer les imprimantes partagées
→ Assigner aux utilisateurs via M365 Admin ou Intune

Dépannage :
Event Viewer → Applications → Universal Print
services.msc → Universal Print Connector (doit être Running)
```

---

## Escalades impression

| Situation | Agent cible |
|---|---|
| Problème réseau (IP, VLAN, switch) | @IT-NetworkMaster |
| Serveur d'impression défaillant (Windows Server) | @IT-Assistant-N3 |
| Driver incompatible avec Windows Update | @IT-MaintenanceMaster |
| Universal Print / M365 | @IT-CloudMaster |
| Matériel défaillant | Support fabricant (voir Hudu) |
