# PROC__RUNBOOK_Ajout_MAJ_Index_Intents_V1

Status : Actif
Owner : MSQ Operations / Documentation

Objectif : definir la procedure d'ajout ou de mise a jour d'un runbook dans le repo.

Fichiers a maintenir :
- IT-SHARED/00_INDEX/INDEX_MASTER_IT-SHARED_V1.md
- IT-SHARED/00_INDEX/INTENT_RUNBOOK_MATRIX_V1.md
- IT-SHARED/RUNBOOK_MENU_CONTEXTUEL_V4.md
- IT-SHARED/60_BUNDLES/[BUNDLE].md
- IT-SHARED/10_RUNBOOKS/[DOMAINE]/[RUNBOOK].md

Procedure :
1. Lire les fichiers canons en lecture seule.
2. Valider que le runbook n'existe pas deja.
3. Creer ou mettre a jour le runbook.
4. Mettre a jour le bundle si applicable.
5. Mettre a jour l'index maitre.
6. Mettre a jour le menu /runbook.
7. Mettre a jour la matrice d'intents si routage automatique requis.
8. Valider que les chemins sont exacts.
9. Valider qu'acune secret, IP, token, hash ou credential n'est present.

Checklist :
- [ ] Runbook cree ou mis a jour
- [ ] Index maitre mis a jour
- [ ] Menu /runbook mis a jour
- [ ] Matrice d'intents mise a jour si requis
- [ ] Bundle mis a jour si applicable
- [ ] Garde-fous de confidentialite valides

Fin.