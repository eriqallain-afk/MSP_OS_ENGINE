# INFRA-M365-Intune_Devices_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__M365_Intune_Devices_V1
**Version :** 1.0 | **Agents :** IT-Assistant-N3, IT-CloudMaster
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Domaine :** INFRA — Microsoft 365 / Gestion des appareils
**Mis à jour :** 2026-03-20

---

## 1. ACCÈS INTUNE

| Portail | URL |
|---|---|
| **Intune Admin Center** | https://intune.microsoft.com |
| **Entra ID** | https://entra.microsoft.com |
| **PowerShell** | Module Microsoft.Graph.Intune |

---

## 2. HEALTH CHECK INTUNE

```
Intune Admin Center → Dashboard
→ Compliance : % d'appareils conformes
→ Configuration : profils en erreur
→ Device enrollment : nouveaux appareils en attente

Devices → All Devices
→ Filtrer par : OS, Compliance Status, Last Check-in
→ Appareils non synchronisés depuis > 7 jours (signifie probablement inactifs)

Reports → Device Compliance Reports
→ Appareils non conformes : motif (pas de BitLocker, PIN requis, etc.)
```

---

## 3. ENREGISTREMENT D'UN APPAREIL (ENROLLMENT)

### Windows Autopilot
```
1. Obtenir le hash matériel du poste :
   Démarrer le poste → PowerShell admin :
   Install-Script -Name Get-WindowsAutoPilotInfo -Force
   Get-WindowsAutoPilotInfo -OutputFile "C:\hash.csv"

2. Importer le hash dans Intune :
   Intune → Devices → Enrollment → Windows Autopilot → Import
   → Uploader le fichier CSV

3. Créer un profil Autopilot :
   Intune → Devices → Enrollment → Windows Autopilot → Deployment Profiles
   → Assigner à un groupe d'appareils

4. L'utilisateur reçoit le poste → démarre → se connecte avec son compte M365
   → Intune configure automatiquement le poste
```

### Enrollment manuel (MDM)
```
Sur le poste Windows :
Paramètres → Comptes → Accès scolaire ou professionnel
→ Connecter → entrer l'adresse email professionnelle
→ Se connecter → le poste est enregistré dans Intune
```

---

## 4. CONFORMITÉ DES APPAREILS

### Vérifier la conformité d'un appareil
```
Intune → Devices → All Devices → [Appareil]
→ Compliance : Compliant / Not Compliant / Not Evaluated
→ Si Not Compliant : voir les raisons dans l'onglet "Device compliance"

Raisons courantes de non-conformité :
→ BitLocker non activé
→ PIN/mot de passe non configuré
→ OS non à jour (version < seuil défini)
→ Antivirus désactivé ou non à jour
→ Jailbreak/root détecté (mobile)
```

### Forcer une synchronisation
```
Intune → Devices → [Appareil] → Sync
→ Le poste se reconnecte à Intune dans les 5-15 minutes

Sur le poste directement :
Paramètres → Comptes → Accès scolaire ou professionnel → [Compte] → Info → Sync
```

---

## 5. ACTIONS À DISTANCE SUR UN APPAREIL

```
Intune → Devices → [Appareil] → Actions disponibles :

Restart           → Redémarrer l'appareil (rapide, non destructif)
Sync              → Forcer la synchronisation des politiques
Remote Lock       → Verrouiller l'appareil à distance
Reset Password    → Réinitialiser le PIN/mot de passe
Retire            → Supprimer les données d'entreprise (BYOD) — conserve données personnelles
Wipe              → Réinitialisation complète usine — DESTRUCTIF
Fresh Start       → Réinstallation Windows propre (garde données perso)
Locate Device     → Géolocaliser (Mobile uniquement)
```

```
⚠️ ACTIONS DESTRUCTRICES :
⛔ NE JAMAIS Wipe sans approbation explicite du client et du superviseur
⛔ NE JAMAIS Retire sans avoir vérifié que l'utilisateur a sauvegardé ses données
⛔ Documenter toute action dans CW avant exécution
```

---

## 6. DÉPLOIEMENT D'APPLICATIONS

```
Intune → Apps → All Apps → Add
→ Type : Windows app (Win32), Microsoft Store, Built-in app

Déploiement Win32 (package MSI/EXE) :
1. Préparer le package avec IntuneWinAppUtil.exe
2. Uploader dans Intune → Apps → Add → Windows app (Win32)
3. Configurer : commande d'installation, de désinstallation, règles de détection
4. Assigner à un groupe d'utilisateurs ou d'appareils
5. Surveiller : Apps → [App] → Device Install Status
```

---

## 7. PROFILS DE CONFIGURATION

```
Intune → Devices → Configuration Profiles
→ Vérifier les profils en erreur
→ Cliquer sur un profil → Device Status → voir les appareils en erreur

Si un profil ne s'applique pas :
1. Vérifier que l'appareil est dans le groupe cible
2. Forcer une synchronisation (section 5)
3. Vérifier les logs sur le poste :
   Event Viewer → Applications and Services → Microsoft → Windows → DeviceManagement-Enterprise
```

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS Wipe un appareil sans autorisation explicite
⛔ NE PAS créer des politiques de conformité trop restrictives sans tester sur un groupe pilote
⛔ NE PAS retirer un appareil Autopilot de l'inventaire Intune sans le retirer aussi d'Autopilot
⛔ NE JAMAIS assigner une politique destructrice à "Tous les appareils" — toujours tester sur un groupe
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Politique Intune mal déployée (> 50 appareils impactés) | TECH | Immédiat |
| Appareil volé (Wipe à distance requis) | TECH + SOC | Immédiat |
| Problème d'enrollment massif (Autopilot) | TECH + CloudMaster | Dans l'heure |
