# RUNBOOK — IT_BACKUP_DR_TEST_V1
_Généré le 2026-01-17T21:19:45Z_

## 1) Objectif
Test Backup/DR (plan -> exécution -> preuves -> rapport)

## 2) Owner / Acteurs
- Owner (par défaut) : `IT-BackupDRMaster`
- Steps (ordre canon) :
  - **backup** → `IT-BackupDRMaster`
  - **report** → `IT-ReportMaster`
  - **kb** → `IT-KnowledgeKeeper`

## 3) Inputs attendus
- Contexte : demande + objectifs + contraintes
- Données : liens, docs, extraits (si applicable)
- Format de sortie requis (si applicable)

## 4) Procédure
1. Exécuter les steps dans l’ordre.
2. Documenter les décisions / hypothèses.
3. Produire l’output final + résumé exécutif.

## 5) Contrôles qualité
- Check conformité (policies du domaine)
- Cohérence interne + traçabilité des sources (si applicable)
- Format de sortie respecté

## 6) Erreurs fréquentes / Escalade
- Si informations manquantes : demander les éléments minimaux (but, audience, contraintes).
- Si risque sécurité/conformité : escalader vers `META-GouvernanceEtRisques`.

## 7) Definition of Done
- Output livré + résumé
- Artefacts archivés si nécessaire (ex: `OPS-DossierIA`)
