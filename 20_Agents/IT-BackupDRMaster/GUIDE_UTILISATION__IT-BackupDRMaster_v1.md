# Guide d'utilisation — @IT-BackupDRMaster (v1.0)
> **Pour :** Techniciens N1/N2/N3 MSP — Équipe NOC et Backup
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-BackupDRMaster ?

**IT-BackupDRMaster est l'expert Backup & Disaster Recovery du MSP.**

Il gère Veeam B&R, Datto BCDR (SIRIS/ALTO), et Keepit (backup M365). Il intervient sur les jobs en échec, les restaurations, les tests DR mensuels, et valide les RPO/RTO contractuels.

| Besoin | Ce que fait IT-BackupDRMaster |
|---|---|
| Job Veeam en échec | Triage structuré — cause probable + commandes correctif |
| Screenshot Datto manquant | Diagnostic agent + escalade si VM critique |
| Connecteur Keepit déconnecté | Diagnostic + procédure de reconnexion M365 |
| Restauration fichier | Guide étape par étape — destination alternative par défaut |
| Restauration VM complète | Procédure critique — confirmation superviseur + client obligatoire |
| Test DR mensuel | Protocole Instant Recovery Veeam ou virtualisation Datto |
| Plan de reprise sinistre | Ordre de démarrage + communication client toutes les 30 min |

> La règle principale : **toujours tester la restauration** — un backup non testé n'est pas un backup.
> Jamais supprimer un point de restauration sans validation explicite.
> Toute restauration en production : confirmation écrite client + superviseur obligatoire.

---

## Quand l'utiliser ?

- Un job Veeam, Datto ou Keepit est en échec dans le portail ou le RMM
- Le screenshot de vérification Datto est manquant sur une VM critique
- Le connecteur Keepit est déconnecté depuis plus de 24 heures
- Un utilisateur demande la restauration d'un fichier ou d'un dossier
- Une restauration VM complète est requise (sinistre confirmé)
- Tu veux planifier ou exécuter le test DR mensuel
- Un sinistre est confirmé et tu dois activer le plan de reprise
- Le repository Veeam est à moins de 20% libre

---

## Les commandes principales

### `/triage [job]` — Trier un job en échec

La commande principale. Fournir le nom du job + le message d'erreur exact.

**Usage — Veeam :**
```
/triage
Solution : Veeam B&R
Job : BACKUP-SRV-FILE01
Erreur : Failed to flush dirty blocks to disk. Error: An I/O operation initiated by the Registry failed unrecoverably
VM : SRV-FILE01
Client : Otto Inc
```

**Usage — Datto :**
```
/triage
Solution : Datto SIRIS
Problème : Screenshot manquant sur VM-DC01 depuis 6h
Client : Otto Mfg
```

**Usage — Keepit :**
```
/triage
Solution : Keepit
Problème : Connecteur Microsoft 365 déconnecté depuis hier soir
Tenant : [NOM_TENANT]
```

**Ce que tu obtiens :**
- Mode détecté (VEEAM_TRIAGE / DATTO_TRIAGE / KEEPIT_TRIAGE)
- Sévérité P1-P4
- Cause probable (VSS / réseau / espace / credentials / snapshot orphelin)
- Actions immédiates en lecture seule
- Escalade si critique

**Commandes de triage Veeam (générées automatiquement) :**
```powershell
# Service Veeam
Get-Service VeeamBackupSvc | Select-Object Name,Status,StartType

# Espace repositories
Get-VBRBackupRepository | Select-Object Name,
    @{N='Free_GB';E={[math]::Round($_.Info.CachedFreeSpace/1GB,1)}},
    @{N='Free_PCT';E={[math]::Round($_.Info.CachedFreeSpace/$_.Info.CachedTotalSpace*100,0)}}

# VSS sur la VM cible (à exécuter sur la VM elle-même)
vssadmin list writers

# Connectivité vers la VM (ports backup)
Test-NetConnection -ComputerName [NOM-VM] -Port 445
Test-NetConnection -ComputerName [NOM-VM] -Port 6160
```

**Erreurs Veeam fréquentes et actions :**

| Erreur | Cause probable | Action |
|---|---|---|
| Unable to connect | VeeamGuestHelper non démarré | Vérifier service sur la VM cible |
| Snapshot not found | Snapshots orphelins dans vSphere | Supprimer les snapshots orphelins dans vCenter |
| Insufficient space | Repository plein | Purger les restore points anciens |
| Access denied | Droits compte service invalides | Vérifier credentials dans Passportal |
| VSS snapshot failed | Writer VSS KO | `vssadmin list writers` → redémarrer le writer fautif |
| Network error | Connectivité ports 445/6160 | `Test-NetConnection` + vérifier firewall |

**Triage Datto — navigation portail :**
```
Partner Portal → Device → [Client] → Backups
→ Vérifier Screenshot (backup bootable ?)
→ Screenshot manquant → backup non bootable → escalade IT-Commandare-Infra

# Agent Datto sur la machine protégée
Get-Service | Where-Object {$_.Name -match "Datto|Backup Agent"} | Select-Object Name,Status

Seuil stockage local :
→ Alerte : < 20% libre
→ Critique : < 10% libre — action immédiate

Synchronisation cloud :
→ Erreur > 24h = données non protégées → alerter IT-CloudMaster
```

**Triage Keepit :**
```
app.keepit.com → Connectors → [Client] → Microsoft 365 → Status
→ Disconnected → Reconnect → compte Global Admin M365 du tenant
→ Déconnexion > 24h = données M365 non sauvegardées → escalader
→ Restauration email : Search → [utilisateur/sujet/date] → Restore to original mailbox
```

---

### `/restore [contexte]` — Restauration guidée

Pour toute restauration — fichier, dossier ou VM complète.

**Usage — restauration fichier :**
```
/restore
Type : Fichier
Fichier : Budget_2026_v3.xlsx
Chemin : \\SRV-FILE01\Partage\Finance\
Point de restauration : hier soir 20h00
Client : DEF Corp
```

**Usage — restauration VM :**
```
/restore
Type : VM complète
VM : SRV-APP01
Sinistre : disque système corrompu — impossible de démarrer
Client : GHI Corp
Approbation superviseur : [NOM_SUPERVISEUR] — oui
Approbation client : [CONTACT_CLIENT] — courriel reçu
```

**Restauration fichier — étapes Veeam :**
```
VBR Console → Backups → [Job concerné]
→ Restore → Guest Files → Windows
→ Naviguer dans l'arborescence → sélectionner le fichier
→ Copy to → [DESTINATION ALTERNATIVE — jamais l'emplacement original sans confirmation]
→ Demander à l'utilisateur de valider le contenu du fichier avant de fermer
```

**Restauration VM — étapes Veeam Instant Recovery :**
```
⚠️ Impact : La VM sera restaurée dans un état antérieur — toute modification depuis
              le point de restauration sera perdue. Approbation obligatoire.

VBR Console → Backups → [VM] → Instant Recovery to VMware vSphere
→ Sélectionner le point de restauration
→ Décocher "Connected to network" pendant la validation
→ RDP → valider services, données, accès utilisateur
→ Client confirme → Migrate to Production
→ NE PAS supprimer l'ancienne VM avant validation complète
```

---

### `/dr [client]` — Test DR ou activation plan de reprise

Pour les tests DR mensuels ou l'activation en cas de sinistre réel.

**Usage — test DR mensuel :**
```
/dr
Type : Test DR mensuel
Client : Otto Mfg
VM à tester : SRV-FILE01
Solution : Veeam B&R
Objectifs : RPO 4h / RTO 2h
```

**Usage — sinistre actif :**
```
/dr
Type : Activation plan de reprise — SINISTRE CONFIRMÉ
Client : JKL Groupe
Étendue : Salle serveur inondée — 4 VMs critiques inaccessibles
Approbation client : reçue par courriel
Billet CW P1 : #99001
```

**Protocole test DR Veeam :**
```
1. VBR → VM → Instant Recovery → sélectionner point de restauration
2. Décocher "Connected to network"
3. RDP dans la VM de test → valider services + données
4. Mesurer le RTO réel vs objectif
5. Stop Publishing (< 30 min de test)
6. Documenter : date, VM testée, RTO réel, résultat, prochaine date
```

**Protocole test DR Datto :**
```
1. Partner Portal → Restore → Virtualize
2. Tester RDP → services → données
3. Mesurer RTO réel
4. Arrêter la virtualisation → documenter le résultat
```

**Ordre de démarrage DR actif :**
```
1. Réseau + Firewall + VPN
2. Domain Controller(s) — 1 à la fois, valider AD avant le suivant
3. DNS + DHCP
4. Serveur de fichiers
5. SQL + Applications
6. RDS + Accès distant
7. Monitoring + Backup
```

> Communication client obligatoire toutes les 30 minutes pendant un DR actif (P1).

---

### `/check [résultats]` — Analyser des résultats backup

Coller les résultats de tes vérifications — l'agent analyse et indique la prochaine action.

**Usage :**
```
/check
Job BACKUP-SRV-DC01 : Success — 2026-05-18 02h15
Job BACKUP-SRV-FILE01 : Failed — 2026-05-18 03h22 — Erreur: VSS snapshot failed
Repository REPO-LOCAL : 14% libre
Screenshot DC01 : OK
Screenshot FILE01 : Manquant
```

**Ce que tu obtiens :**
```
analyse:
  statut_global: PROBLÈME
  elements:
    - BACKUP-SRV-DC01 → ✅ Succès
    - BACKUP-SRV-FILE01 → ❌ VSS snapshot failed — action requise
    - Repository 14% libre → ⚠️ Alerte — purger restore points anciens
    - Screenshot FILE01 manquant → ❌ Backup non bootable — escalader
prochaine_action: Corriger VSS sur SRV-FILE01 + purger restore points + vérifier screenshot
```

---

### `/close` — Clôture CW

Menu de clôture après toute intervention backup/DR. Attend ton choix avant de générer.

**Usage :**
```
/close
```

**Ce que tu obtiens :**
```
[1] CW Note Interne
[2] CW Discussion (facturable client)
[3] Email client
[4] Notice Teams
[A] Tout
```

**Exemple CW Note Interne — triage Veeam (choix 1) :**
```
Prise de connaissance de la demande et consultation de la documentation du client.

Billet #57890 — Otto Inc — Job Veeam BACKUP-SRV-FILE01 en échec depuis hier soir
Début : 09h00 | Fin : 09h55 | Durée : 55 min

09h00 — Analyse du message d'erreur : VSS snapshot failed — writer VSS SQLSERVERAGENT KO
09h10 — vssadmin list writers → SQLSERVERAGENT writer état Waiting for completion depuis 18h
09h20 — Redémarrage service SQLServerAgent sur SRV-FILE01
09h25 — vssadmin list writers → tous les writers en état Stable
09h30 — Relance manuelle du job BACKUP-SRV-FILE01
09h55 — Job terminé avec succès — durée 25 min — taille 142 GB
Statut : ✅ Résolu
```

---

## Flux de travail recommandé

### Job en échec (détecté via RMM ou portail)

```
1. Alerte RMM ou vérification nocturne → job KO identifié
        ↓
2. /triage [job + erreur exacte]
   → Mode, sévérité, cause probable, actions immédiates
        ↓
3. Exécuter les commandes de diagnostic (lecture seule)
        ↓
4. Appliquer le correctif → relancer le job manuellement
        ↓
5. Valider le succès du job
        ↓
6. /close → Note Interne + Discussion
```

### Test DR mensuel

```
1. Planifier la fenêtre de test (hors heures de bureau)
        ↓
2. /dr [client] — Type : Test DR mensuel
   → Protocole Instant Recovery + objectifs RPO/RTO
        ↓
3. Exécuter le test — RDP → valider → mesurer RTO réel
        ↓
4. Arrêter la virtualisation de test
        ↓
5. /close → Note Interne avec rapport RPO/RTO
   → Transmettre résultat à @IT-ReportMaster pour rapport mensuel client
```

### Restauration fichier urgente

```
1. Ticket CW ouvert + utilisateur confirmé
        ↓
2. /restore [fichier + chemin + point de restauration]
   → Étapes guidées — destination alternative par défaut
        ↓
3. Exécuter la restauration → utilisateur valide le contenu
        ↓
4. /close → Note Interne + Discussion + Email client si demandé
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| Toujours tester la restauration | Un backup non testé n'est pas un backup fiable |
| Jamais supprimer un backup sans validation | Toute suppression de restore point = risque perte de données |
| Destination alternative par défaut | Restaurer vers l'emplacement original sans confirmation = risque d'écraser des données récentes |
| Snapshot DC = interdit dans Veeam | Utiliser Windows Server Backup pour les DC — les snapshots VMware causent des problèmes AD |
| Restauration VM en prod = approbation écrite | Superviseur + client — sans ça, ne pas procéder |
| Ne pas supprimer l'ancienne VM avant validation | L'utilisateur doit confirmer que tout est OK avant de libérer l'espace |
| Job en échec 24h+ → escalade dans l'heure | Chaque heure passée = fenêtre RPO qui s'élargit |
| ZÉRO credentials dans les livrables | Passportal uniquement — jamais dans une Note CW |

---

## Questions fréquentes

**Q : Quelle différence entre Veeam, Datto et Keepit — lequel pour quoi ?**
Veeam : backup VMs on-premise (VMware/Hyper-V) et serveurs physiques. Datto BCDR : backup avec image bootable (SIRIS/ALTO) — permet la virtualisation locale en cas de sinistre. Keepit : backup spécialisé Microsoft 365 (emails, SharePoint, OneDrive, Teams) — cloud-to-cloud uniquement. IT-BackupDRMaster couvre les trois dans `/triage`.

**Q : Le repository Veeam est à 15% libre — c'est une urgence ?**
Seuil alerte MSP : < 20% → investiguer. Critique : < 10% → action immédiate. À 15%, l'agent proposera une purge des restore points les plus anciens et une estimation de la croissance. Si la croissance est rapide, escalade vers IT-Commandare-Infra pour expansion du repository.

**Q : Comment savoir si un backup Datto est réellement bootable ?**
Dans le Partner Portal, chaque backup doit avoir un screenshot de vérification (capture de la VM démarrée). Pas de screenshot = backup non bootable = protection non garantie. IT-BackupDRMaster escalade automatiquement vers IT-Commandare-Infra si le screenshot est manquant sur une VM critique.

**Q : Peut-on faire un snapshot VMware d'un Domain Controller avec Veeam ?**
Non — les snapshots VMware sur les DC causent des problèmes de réplication AD (journaux USN, objets en attente). IT-BackupDRMaster refuse et redirige vers Windows Server Backup pour les DC.

**Q : Que faire si le test DR mensuel révèle que le RTO réel dépasse l'objectif contractuel ?**
Documenter l'écart dans la Note Interne, transmettre à IT-ReportMaster, et escalader vers le superviseur pour révision du contrat ou amélioration de l'infrastructure backup. IT-BackupDRMaster génère le rapport de test avec les métriques réelles vs objectifs.

---

*GUIDE_UTILISATION — IT-BackupDRMaster v1.0 — MSP Intelligence AI — 2026-05-18*
