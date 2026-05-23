# Fichier exemple — Intervention Veeam — Repository plein / espace insuffisant

## Référence
- **Billet** : #0001234
- **Client** : Otto Inc
- **Technicien** : [À CONFIRMER]
- **Type d'incident** : Alerte Veeam — Warning / manque d’espace repository
- **Job** : `LOCAL_GALE_QUOTIDIEN`
- **VM affectée** : `PRT01W16-STH`
- **Date de l'événement** : 2026-04-19 21:58:14
- **Prochaine sauvegarde planifiée** : 21:00
- **Statut final du prochain cycle** : [À CONFIRMER]

---

## 1. Symptômes observés
Le job Veeam `LOCAL_GALE_QUOTIDIEN` a généré un avertissement/échec avec un message d’espace insuffisant au moment d’écrire un fichier temporaire `.vbm` dans le dépôt de sauvegarde.

### Message d’erreur exact
```text
Processing PRT01W16-STH Error: Failed to call RPC function 'FcWriteFileEx': There is not enough space on the disk.
Failed to write data to the file [D:\Backup\LOCAL_GALE_QUOTIDIEN\PRT01W16-STH_149EA.vbm_9_tmp].
Session with ID "5acf9635-0657-4a2c-8c74-f91c1884d541" is not started yet.
Processing finished with errors at 2026-04-19 9:58:14 PM
```

---

## 2. Diagnostic retenu
### Cause probable
- **Cause primaire** : manque d’espace sur le repository utilisé par le job Veeam.
- **Cause secondaire** : le message indiquant que la session n’est pas démarrée est interprété comme une conséquence de l’échec d’écriture, et non comme la cause racine.

### Indices qui ont mené au diagnostic
- L’erreur contient explicitement : `There is not enough space on the disk`.
- Le chemin d’écriture visé pointe vers `D:\Backup\LOCAL_GALE_QUOTIDIEN\...`
- La validation de capacité a montré qu’il restait environ **280 GB libres sur 7 TB**, soit environ **4 %** d’espace libre.
- Ce niveau demeure **critique** pour un repository Veeam.

---

## 3. Vérifications effectuées
### Lecture seule
- Consultation du message exact dans la session Veeam.
- Tentative de validation PowerShell Veeam du repository.
- Constat que la cmdlet `Get-VBRBackupRepository` n’était pas disponible dans la session utilisée.
- Validation indirecte de l’espace libre du dépôt.
- Suivi de l’exécution après relance.

### Point notable
- Une phase de **merge** a été observée après l’ajustement de la rétention.
- Le merge était rendu à **7 %** au dernier suivi observé.

---

## 4. Actions réalisées
- Analyse de l’erreur exacte du job.
- Confirmation que la cause la plus probable est le manque d’espace du repository.
- Ajustement de la rétention de **30 jours à 25 jours**.
- Redémarrage manuel de la sauvegarde.
- Surveillance de la tâche relancée.
- Mise en pause du dossier avec suivi prévu au prochain cycle automatique de **21:00**.

---

## 5. État au moment de la mise en pause
- La tâche avait repris et entrait en phase de consolidation/merge.
- Il restait environ **280 GB libres sur 7 TB**.
- Le risque de récurrence demeurait présent.
- Le dossier restait **à suivre** jusqu’à validation du prochain cycle.

---

## 6. Risques / attention particulière
- Un dépôt à environ **4 % libre** reste en **zone critique**.
- Même si un merge démarre, cela ne garantit pas que le problème est réglé durablement.
- Une nouvelle sauvegarde peut encore tomber en **Warning** ou **Failed** si l’espace récupéré demeure insuffisant.
- Toute purge de restore points doit être **documentée** et validée selon les règles internes applicables.

---

## 7. Déroulé type recommandé pour cas similaires
1. Lire le **message exact** dans la session Veeam.
2. Identifier la **VM affectée**, l’heure d’échec et le chemin visé.
3. Si l’erreur mentionne `There is not enough space on the disk`, orienter immédiatement le diagnostic vers le repository.
4. Vérifier l’espace libre du dépôt dans VBR Console ou via PowerShell Veeam si disponible.
5. Si le repository est sous le seuil critique, documenter et escalader selon les règles internes.
6. Si une mesure de rétention est appliquée, la documenter clairement.
7. Redémarrer le job seulement après avoir confirmé qu’une action correctrice a été prise.
8. Surveiller la présence d’un merge/consolidation.
9. Confirmer le résultat du prochain cycle : `Success`, `Warning` ou `Failed`.
10. Recommander une réévaluation de la capacité si le dépôt reste serré.

---

## 8. Résolution / prochaine validation
### Résolution temporaire appliquée
- Réduction de la rétention de 30 à 25 jours.
- Reprise du traitement avec merge observé.

### Validation encore requise
- Résultat final du cycle de 21:00 : **[À CONFIRMER]**
- Espace libre après exécution : **[À CONFIRMER]**
- Besoin d’augmenter la capacité ou revoir la politique de rétention : **[À CONFIRMER]**

---

## 9. Modèle de mémo coordonnateur
```text
Mémo coordonnateur — Billet #[NUMÉRO] — [CLIENT]

Alerte Veeam sur le job [JOB] pour [VM].
Cause identifiée : manque d’espace sur le dépôt de sauvegarde.
Une réduction de la rétention a été effectuée afin de permettre la reprise du traitement.
Une phase de merge/consolidation a été observée après relance.
État actuel : [ESPACE LIBRE] sur [CAPACITÉ TOTALE].
Le dossier demeure à suivre jusqu’à validation du prochain cycle.
Point d’attention : si le dépôt demeure sous le seuil acceptable, prévoir une réévaluation de la capacité ou de la rétention.
```

---

## 10. Runbooks / références utilisés
### Utilisés directement ou comme base de travail
1. **BUNDLE_KP_BackupDRMaster_V1**
   - Référence utilisée pour :
     - la vérification quotidienne Veeam
     - l’interprétation de l’erreur `Insufficient space`
     - les seuils de repository
     - l’escalade si repository < 10 %

2. **RUNBOOK — VEEAM Backup Operations (MSP)**  
   *(bundle Veeam Operations / RUNBOOK__IT_VEEAM_OPERATIONS_V1)*
   - Référence utilisée pour :
     - la méthode de lecture du message exact
     - le diagnostic d’un job en warning/failed
     - l’association `Insufficient space` → repository plein

3. **TEMPLATE BUNDLE — CW CLOSE**
   - Référence utilisée pour :
     - les livrables de fermeture
     - les phrases d’ouverture obligatoires
     - la structure de la Discussion CW et de la Note Interne

### Références non utilisées directement dans le diagnostic, mais liées au domaine
- RUNBOOK__Backup_Configuration
- RUNBOOK__DR_Plan_Validation_V1
- BUNDLE_RUNBOOKS_IT_BACKUP_DR

---

## 11. Leçons retenues
- Le message exact d’erreur Veeam donne souvent la cause racine immédiatement.
- Un repository presque plein peut produire un warning initial avant d’entraîner des échecs récurrents.
- Une réduction de rétention peut débloquer temporairement la situation, mais ne remplace pas une vraie revue de capacité.
- Il faut toujours documenter l’état du dépôt **avant** et **après** la correction.

---

## 12. Champs à compléter si réutilisé
- **Nom exact du repository** : [À CONFIRMER]
- **Free_GB avant correction** : [À CONFIRMER]
- **Free_PCT avant correction** : [À CONFIRMER]
- **Free_GB après correction** : [À CONFIRMER]
- **Free_PCT après correction** : [À CONFIRMER]
- **Résultat du prochain job** : [À CONFIRMER]
- **Nom du technicien** : [À CONFIRMER]
- **Approbation superviseur liée à la purge/rétention** : [À CONFIRMER]
