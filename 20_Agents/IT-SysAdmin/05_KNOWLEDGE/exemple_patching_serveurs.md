# EXEMPLE INTERVENTION COMPLÈTE

## Scénario: Patching Windows 3 Serveurs

---

### OUVERTURE

**Eric:**
```
#12345 - ACME Corp
Patches Windows sur SRV-DC01, SRV-FILE01, SRV-SQL01
Fenêtre: 20h-22h ce soir
```

**IT-InterventionLive:**
```
✅ Intervention #12345 ouverte - ACME Corp
Serveurs: 3 (DC01, FILE01, SQL01)
Fenêtre: 20h-22h

Commence par quel serveur?
```

---

### SERVEUR 1: SRV-DC01

**Eric:**
```
DC01 first
[Screenshot Server Manager - All services running]
```

**IT-InterventionLive:**
```
✅ DC01 services running - noté

Check pending updates:
Get-WindowsUpdate -ComputerName SRV-DC01
```

**Eric:**
```
12 updates (3 security, 9 quality)
KB5034441, KB5034442, KB5034443...
```

**IT-InterventionLive:**
```
✅ 12 updates (3 security) - noté

Snapshot avant install?
```

**Eric:**
```
Snapshot créé 20h20
Installing now
```

**IT-InterventionLive:**
```
✅ Snapshot + install lancé - noté

Surveille progress.
```

**Eric:**
```
[Screenshot - Install 50% complete]
```

**IT-InterventionLive:**
```
✅ 50% - noté

Continue.
```

**Eric:**
```
[Screenshot - Install 100%, reboot required]
```

**IT-InterventionLive:**
```
✅ Install terminé - noté

Reboot maintenant.
Post-reboot: vérifie AD, DNS, DHCP.
```

**Eric:**
```
Rebooting...
```

**IT-InterventionLive:**
```
✅ Reboot en cours - noté

Signale quand up (~5min).
```

**Eric:**
```
Server up 20h48
[Screenshot Services - AD, DNS, DHCP all running]
```

**IT-InterventionLive:**
```
✅ SRV-DC01 complété (1/3) - noté

SRV-FILE01 suivant?
```

---

### SERVEUR 2: SRV-FILE01

**Eric:**
```
FILE01 go
[Screenshot Task Manager - CPU 8%, RAM 32%]
```

**IT-InterventionLive:**
```
✅ FILE01 état ok - noté

Pending updates?
```

**Eric:**
```
8 updates (2 security, 6 quality)
```

**IT-InterventionLive:**
```
✅ 8 updates - noté

Snapshot + install?
```

**Eric:**
```
Snapshot done 20h50
Install started 20h55
```

**IT-InterventionLive:**
```
✅ Install en cours - noté

Signale fin.
```

**Eric:**
```
Install done 21h08, need reboot
```

**IT-InterventionLive:**
```
✅ Install terminé - noté

Reboot.
Post: vérifie SMB service.
```

**Eric:**
```
Rebooted 21h13
SMB service running, shares accessible
```

**IT-InterventionLive:**
```
✅ SRV-FILE01 complété (2/3) - noté

SRV-SQL01 dernier?
```

---

### SERVEUR 3: SRV-SQL01

**Eric:**
```
SQL01 go
[Screenshot Task Manager - CPU 25%, RAM 68%]
```

**IT-InterventionLive:**
```
✅ SQL01 état noté (RAM 68% normal SQL)

Pending updates?
```

**Eric:**
```
15 updates (4 security, 11 quality)
```

**IT-InterventionLive:**
```
✅ 15 updates - noté

Snapshot + install?
```

**Eric:**
```
Snapshot 21h15
Install started 21h20
```

**IT-InterventionLive:**
```
✅ Install en cours - noté

Signale fin.
```

**Eric:**
```
Install done 21h38, reboot required
```

**IT-InterventionLive:**
```
✅ Install terminé - noté

Reboot.
Post: vérifie SQL Server service.
```

**Eric:**
```
Rebooted 21h45
SQL Server service running
[Screenshot SSMS - Connection successful]
```

**IT-InterventionLive:**
```
✅ SRV-SQL01 complété (3/3) - noté

Tous serveurs patchés!
/close quand prêt.
```

---

### CLÔTURE

**Eric:**
```
All done!
/close
```

**IT-InterventionLive:**
```yaml
╔══════════════════════════════════════════════════════════╗
║          RAPPORTS INTERVENTION #12345                    ║
╚══════════════════════════════════════════════════════════╝

# === CW_DISCUSSION ===

Maintenance planifiée - Patches Windows serveurs ACME Corp
Fenêtre: 20h00-22h00

SERVEURS TRAITÉS:
✅ SRV-DC01 - 12 updates (3 security, 9 quality) - Reboot ok
✅ SRV-FILE01 - 8 updates (2 security, 6 quality) - Reboot ok
✅ SRV-SQL01 - 15 updates (4 security, 11 quality) - Reboot ok

PROCÉDURE:
- Snapshots créés avant patching
- Updates installés via Windows Update
- Reboots effectués
- Services critiques vérifiés post-reboot

RÉSULTAT:
Tous serveurs patchés avec succès, aucune erreur.
Services opérationnels confirmés:
- AD, DNS, DHCP (DC01)
- SMB shares accessibles (FILE01)
- SQL Server connectivité ok (SQL01)

Durée totale: 1h45
Fenêtre respectée (fin 21h45).

──────────────────────────────────────────────────────────

# === CW_INTERNAL_NOTE ===

INTERVENTION: Patching Windows Serveurs
CLIENT: ACME Corp
TICKET: #12345
TECHNICIEN: Eric
DATE: 2026-02-03
DURÉE: 20h15-21h45 (1h30)

PÉRIMÈTRE:
- SRV-DC01 (Domain Controller)
- SRV-FILE01 (File Server)
- SRV-SQL01 (SQL Server)

PROCÉDURE DÉTAILLÉE:

SRV-DC01:
  État pré-maintenance: Services running normally
  Snapshot: Créé 20h20
  Updates: 12 total
    - Security: 3 (KB5034441, KB5034442, KB5034443)
    - Quality: 9
  Install: 20h25-20h42 (17 min)
  Progress: Surveillé à 50% et 100%
  Reboot: 20h43-20h48 (5 min)
  Post-reboot verification:
    - Active Directory: Running
    - DNS Server: Running
    - DHCP Server: Running
  Résultat: ✅ Succès complet

SRV-FILE01:
  État pré-maintenance: CPU 8%, RAM 32% (nominal)
  Snapshot: Créé 20h50
  Updates: 8 total
    - Security: 2
    - Quality: 6
  Install: 20h55-21h08 (13 min)
  Reboot: 21h09-21h13 (4 min)
  Post-reboot verification:
    - SMB Service: Running
    - Shares accessible: Confirmed
  Résultat: ✅ Succès complet

SRV-SQL01:
  État pré-maintenance: CPU 25%, RAM 68% (normal pour SQL)
  Snapshot: Créé 21h15
  Updates: 15 total
    - Security: 4
    - Quality: 11
  Install: 21h20-21h38 (18 min)
  Reboot: 21h39-21h45 (6 min)
  Post-reboot verification:
    - SQL Server Service: Running
    - SSMS Connection: Successful
  Résultat: ✅ Succès complet

COMMANDES UTILISÉES:
- Get-WindowsUpdate -ComputerName [server]
- Install-WindowsUpdate -ComputerName [server] -AcceptAll
- Restart-Computer -ComputerName [server] -Force
- Get-Service -Name [service]

INCIDENTS: Aucun

SNAPSHOTS:
- Tous conservés 48h pour rollback si nécessaire
- Chemins: [VMware/Hyper-V snapshot location]

NOTES TECHNIQUES:
- Aucun service n'a nécessité restart manuel
- Aucune erreur durant installations
- Tous reboots ont complété normalement
- Fenêtre maintenance respectée (fin 21h45 vs 22h00 limite)

RECOMMANDATIONS:
- Snapshots peuvent être supprimés après 48h si stabilité confirmée
- Prochaine vague patches: Mars 2026

──────────────────────────────────────────────────────────

# === EMAIL_BRIEF ===

DESTINATAIRE: IT-TicketScribe
POUR: Email client ACME Corp

SUJET: Maintenance serveurs complétée avec succès

CLIENT: ACME Corp
INTERVENTION: Patching Windows serveurs critiques
DATE: 3 février 2026, 20h00-21h45

SERVEURS CONCERNÉS:
- SRV-DC01 (Contrôleur de domaine)
- SRV-FILE01 (Serveur fichiers partagés)
- SRV-SQL01 (Serveur base de données)

TRAVAUX EFFECTUÉS:
Installation de 35 mises à jour de sécurité et qualité Windows:
- 9 correctifs de sécurité critique
- 26 mises à jour qualité

PROCÉDURE APPLIQUÉE:
1. Sauvegardes snapshots avant intervention
2. Installation mises à jour sur chaque serveur
3. Redémarrages contrôlés
4. Vérification complète services critiques

RÉSULTAT:
✅ Maintenance complétée avec succès
✅ Tous serveurs opérationnels et sécurisés
✅ Aucun incident durant intervention
✅ Services vérifiés 100% fonctionnels:
   - Active Directory / DNS / DHCP
   - Partages fichiers accessibles
   - Base de données SQL opérationnelle

DURÉE: 1h30 (fenêtre 2h respectée)
IMPACT: Aucun - intervention hors heures ouvrables

BÉNÉFICES:
- Serveurs maintenant protégés contre vulnérabilités récentes
- Stabilité et performance optimisées
- Conformité sécurité maintenue

Prochaine maintenance planifiée: Mars 2026

Les serveurs sont sécurisés et pleinement opérationnels.

──────────────────────────────────────────────────────────

╔══════════════════════════════════════════════════════════╗
║  RAPPORTS GÉNÉRÉS - PRÊTS POUR COPIER/COLLER            ║
╚══════════════════════════════════════════════════════════╝

PROCHAINES ÉTAPES:
1. Copie CW_DISCUSSION dans ticket #12345
2. Copie CW_INTERNAL_NOTE dans notes internes
3. Envoie EMAIL_BRIEF à IT-TicketScribe pour envoi client
```

---

## TIMING EXACT

```
20h15 - Intervention démarrée
20h20 - DC01 snapshot
20h25 - DC01 install started
20h42 - DC01 install done
20h48 - DC01 verified OK ✅ (33 min)

20h50 - FILE01 snapshot
20h55 - FILE01 install started
21h08 - FILE01 install done
21h13 - FILE01 verified OK ✅ (23 min)

21h15 - SQL01 snapshot
21h20 - SQL01 install started
21h38 - SQL01 install done
21h45 - SQL01 verified OK ✅ (30 min)

21h45 - /close → Rapports générés (30 sec)

TOTAL: 1h30 intervention + 30 sec rapports = 1h30.5
```

---

## ÉCONOMIE TEMPS

**Sans IT-InterventionLive:**
- Intervention: 1h30
- Écrire CW_DISCUSSION: 15 min
- Écrire CW_INTERNAL_NOTE: 20 min
- Écrire EMAIL_BRIEF: 10 min
- **Total: 2h15**

**Avec IT-InterventionLive:**
- Intervention: 1h30 (agent suit en silence)
- `/close`: 30 sec
- Copie 3 rapports: 2 min
- **Total: 1h32.5**

**ÉCONOMIE: 42.5 MINUTES! 🎉**

---

**Prêt à utiliser ce soir!**
