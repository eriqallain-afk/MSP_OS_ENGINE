# EXEMPLE DE RÉFÉRENCE — P1 Site Down récurrent / Hyper-V / MegaRAID Fatal Firmware Error

**Usage :** référence interne MSP pour cas similaires  
**Statut :** exemple opérationnel anonymisable  
**Basé sur le cas :** billet #0001234 — site down récurrent — hôte Hyper-V avec contrôleur RAID en erreur fatale  
**Dernière mise à jour :** 2026-05-16  
**Confidentialité :** interne seulement. Retirer noms client, noms d’hôtes, IPs, comptes, captures et détails sensibles avant tout partage externe.

---

## 1. Objectif

Ce fichier sert de modèle de référence quand un site ou plusieurs serveurs deviennent inaccessibles et que l’hôte de virtualisation revient partiellement en ligne, mais qu’une alerte matérielle/RAID critique est détectée.

Objectifs :
- sécuriser les données;
- prouver l’état réel de l’hyperviseur et des VMs;
- éviter les actions destructives sur le RAID;
- produire une décision GO/NO-GO claire;
- escalader INFRA/NOC/vendor;
- documenter le diagnostic réel dans CW.

---

## 2. Runbooks utilisés / consultés

Source canonique utilisée : dépôt GitHub IT, branche `main`.

| Runbook / template | Usage dans ce cas |
|---|---|
| `IT-SHARED/10_RUNBOOKS/00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md` | Sécurité, confidentialité, lecture seule avant remédiation. |
| `IT-SHARED/10_RUNBOOKS/NOC/NOC-OPS-IncidentCommand_V2.md` | Incident P1/P2, site down, coordination et escalade initiale NOC. |
| `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-HyperV_Operations_V2.md` | Validation hôte Hyper-V, états VM, stockage hôte, post-check après retour. |
| `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-SRV-VMware_Operations_V2.md` | Référence RAID / contrôleur stockage / alerte hardware malgré hôte Hyper-V. |
| `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-AD-DC_Operations_V3.md` | Validation contrôleur de domaine / AD / SYSVOL / NETLOGON / réplication. |
| `IT-SHARED/10_RUNBOOKS/INFRA/INFRA-BACKUP-Veeam_Operations_V2.md` | Validation BackupDR/Veeam, restore points, job en cours, repository. |
| `IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW/TEMPLATE_BUNDLE_CW_CLOSE.md` | Livrables CW : T1 Discussion, T3 Note interne, T8 Mémo interne. |
| `BUNDLE_KP_UrgenceMaster_V1.md` | Checklists GO/NO-GO, avis Teams, escalades rapides, règles d’urgence. |

---

## 3. Déclencheurs typiques

```text
□ Site down / plusieurs serveurs unreachable
□ Incident récurrent sur le même site ou même hôte
□ Hyperviseur revenu online mais instable
□ Module de gestion hors bande accessible, mais informations limitées
□ MegaRAID / contrôleur RAID indique Fatal / Critical / Firmware error
□ Événements Windows : Kernel-Power 41, EventLog 6008, WHEA hardware error
□ Une ou plusieurs VMs critiques sont encore Running
□ Backup en cours ou restore point à valider avant toute action matérielle
```

---

## 4. Règles immédiates

```text
NO-GO global jusqu’à preuve contraire.

Ne pas :
- redémarrer l’hôte;
- faire Hard Reset;
- faire Power Cycle;
- lancer un rebuild RAID;
- faire Clear Foreign;
- initialiser un volume RAID;
- supprimer un Saved State de VM sans validation;
- dismiss l’alerte matérielle comme résolution;
- fermer le billet comme simple “serveur redémarré”.
```

Raison : si le contrôleur RAID/firmware est instable, l’hôte peut être revenu en ligne tout en restant à risque élevé pour le datastore, les VHDX et les VMs critiques.


## 5. Avis Teams — modèles

### Début P1

```text
🚨 P1 — Panne récurrente en cours — Billet : #[BILLET]

Site [SITE] de nouveau en panne chez [CLIENT].
Tâche principale : Validation NOC/INFRA de la connectivité site, alimentation, hôte physique et services critiques.
Impact : Plusieurs serveurs sont inaccessibles — incident récurrent depuis le dernier événement.
```

### Diagnostic contrôleur RAID

```text
🚨 P1 — Contrôleur RAID critique — Billet : #[BILLET]

Erreur firmware fatale confirmée sur le contrôleur RAID de l’hôte Hyper-V chez [CLIENT].
Tâche principale : Escalade INFRA/NOC/vendor et protection des services avant toute action matérielle.
Impact : Risque critique sur le stockage de l’hyperviseur et les serveurs virtuels — incident récurrent.
```

### BackupDR complété

```text
🛡️ P1 — BackupDR complété — Billet : #[BILLET]

Backup de la VM critique complété avec succès chez [CLIENT].
Tâche principale : Escalade INFRA/vendor pour contrôleur RAID en erreur firmware fatale.
Impact : Protection BackupDR confirmée, mais l’hôte Hyper-V demeure à risque matériel critique.

Statut : NO-GO matériel maintenu — aucune action RAID ou redémarrage sans INFRA/vendor.
```

---

## 6. Étapes opérationnelles — 1 action à la fois

### Étape 1 — Prise en charge et escalade initiale

```text
Prendre connaissance de la demande et consultation de la documentation.
Connexion au RMM et analyse de l'état global et de la présence d'alerte.

Statut : P1.
Escalade NOC + INFRA immédiate.
Avis Teams publié dès que le type d’urgence est connu.
```

### Étape 2 — Validation hors bande

Valider seulement l’état visible :
- alimentation;
- health global;
- console KVM;
- messages d’erreur;
- accès au contrôleur/stockage si disponible.

Ne pas appliquer de Hard Reset si le serveur est alimenté et que le diagnostic matériel n’est pas terminé.

### Étape 3 — Si l’hôte Hyper-V revient online

Lancer uniquement une validation lecture seule depuis l’hôte.

```powershell
"=== HOST UPTIME ==="
$os = Get-CimInstance Win32_OperatingSystem
$uptime = (Get-Date) - $os.LastBootUpTime
[pscustomobject]@{
    ComputerName = $env:COMPUTERNAME
    LastBoot     = $os.LastBootUpTime
    UptimeMin    = [math]::Round($uptime.TotalMinutes,1)
}

"=== HYPER-V SERVICES ==="
Get-Service vmms,vmcompute,vhdsvc,vmicheartbeat -ErrorAction SilentlyContinue |
Select-Object Name,Status,StartType

"=== HOST STORAGE ==="
Get-Volume | Select-Object DriveLetter,FileSystemLabel,HealthStatus,OperationalStatus,
@{N='SizeGB';E={[math]::Round($_.Size/1GB,1)}},
@{N='FreeGB';E={[math]::Round($_.SizeRemaining/1GB,1)}},
@{N='FreePct';E={if ($_.Size -gt 0) {[math]::Round($_.SizeRemaining/$_.Size*100,0)}}}

Get-Disk | Select-Object Number,FriendlyName,HealthStatus,OperationalStatus

"=== VM STATES ==="
Get-VM | Select-Object Name,State,Status,Uptime |
Format-Table -AutoSize

"=== RECENT CRITICAL EVENTS ==="
Get-WinEvent -FilterHashtable @{
    LogName='System'
    Level=1,2
    StartTime=(Get-Date).AddHours(-6)
} -ErrorAction SilentlyContinue |
Select-Object TimeCreated,ProviderName,Id,LevelDisplayName,Message -First 20 |
Format-List
```

Retour attendu :

```text
□ Uptime HV > 10 min : O/N
□ Services Hyper-V Running : O/N
□ Volumes / disques Healthy : O/N
□ VMs Running : [nombre]
□ VMs Off/Saved/Paused/Critical : [liste ou aucune]
□ Erreurs critiques stockage / RAID / WHEA / Kernel-Power : O/N
```


### Étape 4 — Validation MegaRAID / contrôleur RAID

Lecture seule seulement.

```text
□ Controller status : [À CONFIRMER]
□ Virtual Drive status : Optimal / Degraded / Offline / Failed / [À CONFIRMER]
□ Physical Disk status : nombre Online / Failed / Unconfigured Bad / Foreign / Rebuild
□ Battery / CacheVault / BBU status : Optimal / Failed / Missing / [À CONFIRMER]
□ Event log MegaRAID : dernier message critique visible : [À CONFIRMER]
```

Décision si `Fatal firmware error` :

```text
NO-GO global immédiat.
Escalade INFRA + vendor hardware.
Protéger les VMs / BackupDR avant toute intervention matérielle.
```

### Étape 5 — Validation VM critique / DC

Si une VM DC critique est Running, valider AD en lecture seule.

```powershell
"=== DC QUICK HEALTH ==="
Get-Service DNS,DFSR,Kdc,Netlogon,NTDS,W32Time -ErrorAction SilentlyContinue |
Select-Object Name,Status,StartType

"=== SYSVOL / NETLOGON ==="
Test-Path "\\$env:COMPUTERNAME\SYSVOL"
Test-Path "\\$env:COMPUTERNAME\NETLOGON"

"=== REPLICATION SUMMARY ==="
repadmin /replsummary

"=== TIME SOURCE ==="
w32tm /query /source
```

Retour attendu :

```text
□ Services DC Running : O/N
□ SYSVOL / NETLOGON True : O/N
□ repadmin failures : 0 / >0
□ Time source OK : O/N
```

### Étape 6 — Validation BackupDR / Veeam

Ne pas toucher au matériel tant que la protection n’est pas confirmée.

```text
□ Dernier backup réussi de la VM critique : [date/heure]
□ Backup additionnel en cours : O/N — progression : [X%]
□ Résultat final : Success / Warning / Failed
□ Restore point disponible < 24h : O/N
□ Repository accessible et sain : O/N/[À CONFIRMER]
□ Job en échec ou warning dans les dernières 24h : O/N
```

Décision :
- Si backup en cours : attendre.
- Si backup Success : escalade vendor/hardware avec preuve.
- Si backup Failed : escalade BackupDR + INFRA avant intervention matérielle.

---

## 7. Diagnostic réel — exemple de synthèse

```text
Diagnostic réel :
Incident matériel / stockage sur hôte de virtualisation.

Preuves :
- Contrôleur RAID ID 0 en erreur firmware fatale.
- Événement récurrent observé dans l’historique du contrôleur.
- Arrêt non propre de l’hôte confirmé.
- Erreur matérielle Windows WHEA sur bus PCIe / composant associé.
- VM critique revenue en ligne, mais stockage hôte non fiable.
- Sauvegarde additionnelle complétée avec succès avant action matérielle.

Conclusion :
Le retour de l’hôte ne constitue pas une résolution complète.
Le problème racine probable est matériel/firmware au niveau du contrôleur RAID ou du chemin PCIe/stockage.
Correction permanente requise : intervention INFRA/vendor et remplacement ou traitement du composant concerné.
```

---

## 8. Escalade INFRA / vendor

```text
[ESCALADE → Département INFRA + Département NOC + Vendor hardware]

Raison     : Erreur firmware fatale sur contrôleur RAID / incident site down récurrent
Ticket     : #[BILLET] | Client : [CLIENT] | Sévérité : P1
Équipement : [HÔTE HYPER-V] / contrôleur RAID ID [X]

Contexte :
Incident récurrent sur le site. Hôte Hyper-V revenu online, mais l’outil RAID signale une erreur firmware fatale sur le contrôleur. Une VM critique est en ligne. Protection BackupDR complétée avec succès avant intervention matérielle.

Preuves disponibles :
- Capture outil RAID : Fatal firmware error
- Export log contrôleur RAID
- Événements Windows : arrêt non propre / WHEA hardware error
- Backup VM critique : Success

Demande :
Diagnostic contrôleur RAID / firmware contrôleur.
Validation remplacement contrôleur ou procédure vendor.
Aucune action RAID ou redémarrage additionnel sans approbation INFRA/vendor.
```


## 9. Livrable CW client-safe — T1

Ne pas inclure : IP, hostnames internes si non requis, comptes, IDs bruts, chemins, sorties de script, messages détaillés RAID.

```text
────────────────────────────────────────────────────────────
       Intervention urgente — diagnostic matériel
────────────────────────────────────────────────────────────

BILLET : #[BILLET]
DATE : [YYYY-MM-DD]
TECHNICIEN : [À CONFIRMER]
---------

PRÉPARATION ET DÉCOUVERTE :
---------
• Prendre connaissance de la demande et consultation de la documentation.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS :
---------
• Prise en charge de l’incident récurrent signalant plusieurs serveurs inaccessibles.
• Connexion aux outils de gestion disponibles afin de valider l’état du serveur physique et des services critiques.
• Validation du retour en ligne de l’hôte de virtualisation et d’une machine virtuelle critique.
• Analyse des alertes matérielles et des événements système post-incident.
• Confirmation d’un problème critique lié au contrôleur de stockage matériel.
• Validation de l’état des sauvegardes et lancement d’une protection additionnelle avant toute intervention matérielle.
• Confirmation que la sauvegarde de la machine virtuelle critique s’est terminée avec succès.
• Escalade vers les équipes appropriées et commande du matériel de remplacement requise.

RÉSULTAT :
---------
• Les services critiques observés sont revenus en ligne.
• La machine virtuelle critique est opérationnelle au moment de la validation.
• Les sauvegardes nécessaires ont été confirmées avant la suite des travaux.
• Le diagnostic indique un problème matériel réel au niveau du contrôleur de stockage.
• Une commande de pièce est en cours pour correction matérielle.

RECOMMANDATION :
---------
• Maintenir une surveillance renforcée jusqu’au remplacement du composant matériel.
• Éviter tout redémarrage ou intervention matérielle non planifiée avant la prise en charge INFRA/vendor.
• Planifier le remplacement du composant dès réception de la pièce.
```

---

## 10. Note interne technique — T3

```text
════════════════════════════════════════════════════════════
INTERVENTION TECHNIQUE — INCIDENT MATÉRIEL / STOCKAGE
════════════════════════════════════════════════════════════

INFORMATIONS GÉNÉRALES
----------------------
Date        : [YYYY-MM-DD]
Technicien  : [À CONFIRMER]
Client      : [CLIENT]
Billet CW   : #[BILLET]
Équipements : [HÔTE HYPER-V], [VM CRITIQUE]
Type        : Urgence P1 — Site down récurrent / hôte Hyper-V / stockage

PRÉPARATION ET DÉCOUVERTE :
----------
• Prendre connaissance de la demande et consultation de la documentation.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

CONTEXTE INITIAL
----------------
Nouvel incident Site Down au site concerné.
Plusieurs serveurs rapportés inaccessibles.
Incident récurrent suivant un événement similaire récent sur le même site.
Accès effectué via un autre site afin de joindre le module de gestion hors bande et les outils de gestion disponibles.

DIAGNOSTIC / ANALYSE
--------------------
L’hôte Hyper-V est revenu en ligne après l’incident.
Une VM critique est observée Running / Operating normally.

Les sections Hyper-V Services et Host Storage doivent retourner des résultats exploitables. Si elles sont vides, ne pas considérer ces éléments validés.

Événements système à documenter :
- Kernel-Power 41 : arrêt non propre / perte de stabilité.
- EventLog 6008 : arrêt précédent inattendu.
- WHEA-Logger 16 : erreur matérielle fatale.
- Autres erreurs post-démarrage à classifier comme secondaires si elles ne pointent pas vers le stockage.

Contrôleur RAID :
- Error Level : Fatal.
- Description : Fatal firmware error.
- Historique à vérifier pour occurrences précédentes.
- Plusieurs séquences de réinitialisation / power-on / détection disques peuvent indiquer instabilité.

Cause probable :
Défaillance réelle du contrôleur RAID / firmware contrôleur, possiblement liée au bus PCIe ou au contrôleur de stockage, et non uniquement à une panne logique Windows ou Hyper-V.

ACTIONS TECHNIQUES
------------------
Action 1 — Accès et validation initiale
  Résultat : Accès hors bande obtenu. Serveur physique confirmé alimenté.

Action 2 — Validation Hyper-V
  Résultat : Hôte revenu en ligne. VM critique observée Running / Operating normally.

Action 3 — Validation événements système
  Résultat : Arrêt non propre confirmé. WHEA hardware error observé.

Action 4 — Validation contrôleur RAID
  Résultat : Erreur firmware fatale confirmée. Historique vérifié.

Action 5 — Protection BackupDR
  Résultat : Dernier backup existant confirmé. Backup additionnel lancé et terminé avec succès.

Action 6 — Escalade / matériel
  Résultat : Escalade INFRA/vendor requise. Pièce ou intervention matériel à suivre.

CONFIGURATIONS MODIFIÉES
------------------------
Aucune configuration modifiée.
Aucun rebuild RAID effectué.
Aucun clear foreign effectué.
Aucune initialisation RAID effectuée.
Aucun redémarrage ou power cycle additionnel effectué après confirmation du risque matériel.
Aucune action destructive appliquée.

TESTS DE VALIDATION
-------------------
✓ Hôte Hyper-V accessible : OK au moment de la validation.
✓ VM critique : Running / Operating normally.
✓ Backup VM critique : terminé avec succès.
✓ Repository backup : accessible selon validation.
⚠ Stockage matériel : NON VALIDÉ / NO-GO en raison de l’erreur fatale contrôleur RAID.
⚠ Stabilité matérielle : NON CONFIRMÉE en raison des événements WHEA et RAID.

RÉSULTAT FINAL
--------------
État : PARTIELLEMENT RÉSOLU / À SUIVRE

Les services critiques sont revenus en ligne et la protection BackupDR a été confirmée.
Cependant, le diagnostic réel indique une défaillance matérielle critique du contrôleur RAID.
Le billet ne doit pas être traité comme simple panne temporaire ou simple redémarrage réussi.
La correction permanente nécessite remplacement / intervention vendor sur le contrôleur ou composant associé.

SUIVI REQUIS
------------
■ Maintenir surveillance renforcée de l’hôte et des VMs critiques.
■ Ne pas redémarrer l’hôte sans validation INFRA/vendor.
■ Ne pas effectuer d’action RAID sans procédure vendor.
■ Suivre la commande de pièce et planifier l’intervention matérielle.
■ Valider les sauvegardes avant et après remplacement.
■ Effectuer post-check complet Hyper-V / DC / stockage après remplacement.

POST-INTERVENTION
-----------------
■ Courriel client envoyé : Non / [À CONFIRMER]
■ Documentation Hudu mise à jour : Non / [À CONFIRMER]

TEMPS INTERVENTION
------------------
Temps total : [À CONFIRMER]
════════════════════════════════════════════════════════════
```


## 11. Mémo interne — T8

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MÉMO INTERNE — Diagnostic réel incident stockage
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

À            : Coordonnateur / VCIO / Gestionnaire / Chef NOC / INFRA
De           : [Technicien / Agent IT]
Date         : [YYYY-MM-DD]
Billet       : #[BILLET]
Client       : [CLIENT]

RAISON
──────
Incident récurrent Site Down avec plusieurs serveurs inaccessibles et alerte critique sur l’hôte Hyper-V.

RÉSUMÉ
──────
Le serveur Hyper-V est revenu en ligne et une VM critique fonctionne actuellement.
Cependant, le diagnostic réel ne pointe pas vers une simple panne temporaire ou un simple blocage Windows.
Les preuves recueillies indiquent une défaillance matérielle critique du contrôleur RAID / firmware contrôleur.

Éléments confirmés :
- Contrôleur RAID : Fatal firmware error.
- Occurrence similaire observée dans l’historique.
- Windows : erreur matérielle fatale WHEA.
- Windows : arrêt non propre confirmé.
- VM critique en ligne au moment de la validation.
- Backup additionnel complété avec succès avant action matérielle.
- Pièce ou intervention vendor en commande / à suivre.

STATUT       : ⚠️ En cours / suivi matériel requis
SUIVI REQUIS : Oui — remplacement composant / validation INFRA-vendor / post-check après intervention

RECOMMANDATION INTERNE
──────
Ne pas considérer le billet comme résolu définitivement avant remplacement matériel et post-check complet.
Éviter tout redémarrage non requis de l’hôte avant l’intervention.
Maintenir une surveillance active et confirmer les sauvegardes avant toute manipulation matérielle.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 12. Critères de fermeture

Ne fermer comme résolu définitivement que si :

```text
□ Pièce / intervention vendor complétée
□ Hôte stable après intervention
□ Contrôleur RAID sans erreur critique active
□ Disques / Virtual Drive / cache / batterie validés
□ VMs critiques Running
□ DC validé si applicable : services, SYSVOL, NETLOGON, réplication, temps
□ Backup post-intervention complété ou planifié avec succès confirmé
□ Avis Teams final publié
□ CW T1/T3/T8 complétés selon audience
```

Si la pièce est en commande mais non remplacée :

```text
Statut recommandé : partiellement résolu / à suivre / escaladé matériel.
Ne pas écrire que la panne est définitivement résolue.
```

---

## 13. Leçons apprises

1. Un hôte revenu online n’est pas automatiquement sain.
2. Une VM critique Running ne valide pas le stockage sous-jacent.
3. Une erreur `Fatal firmware error` sur contrôleur RAID doit déclencher NO-GO matériel.
4. Les événements WHEA + Kernel-Power + MegaRAID renforcent le diagnostic matériel.
5. Le backup doit être validé avant toute action risquée.
6. Un second incident similaire change le niveau d’urgence : traiter comme récurrence / RCA matériel.
7. Le livrable client doit rester simple; le livrable interne doit contenir le diagnostic réel.

---

## 14. Résumé ultra-court pour passation

```text
P1 récurrent — site down / hôte Hyper-V.
Hôte revenu online, VM critique Running.
MegaRAID : Fatal firmware error sur contrôleur RAID.
Windows : arrêt non propre + WHEA hardware error.
Backup VM critique complété avec succès.
NO-GO matériel maintenu.
Pièce / vendor en cours.
Ne pas reboot / hard reset / rebuild / clear foreign / initialize.
Post-check complet requis après remplacement.
```
