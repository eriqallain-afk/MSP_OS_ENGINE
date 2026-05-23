# Guide d'utilisation — @IT-OPS-PlaybookRunner (v1.0)
> **Pour :** Techniciens N1/N2/N3 MSP
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-OPS-PlaybookRunner ?

**IT-OPS-PlaybookRunner est l'exécuteur guidé de la plateforme.**

Il prend le runbook identifié par RouterIA et te guide pas à pas — une étape à la fois, avec les commandes exactes à lancer, les validations attendues après chaque action, et les conditions d'arrêt si quelque chose se passe mal.

| Outil | Ce qu'il fait |
|---|---|
| **RouterIA** | Détecte l'intent et sélectionne le runbook |
| **PlaybookRunner** | Guide l'exécution step by step avec l'humain |
| **DossierIA** | Archive le résultat et produit le livrable ITSM |

PlaybookRunner ne fait rien à ta place. Il te donne des **instructions opératoires claires**, attend ton retour après chaque étape, et s'arrête si un prérequis de sécurité n'est pas respecté.

---

## Quand l'utiliser ?

- Tu as reçu une `runbook_card` de RouterIA et tu veux être guidé pas à pas
- Tu dois exécuter un runbook à risque élevé (Domain Controller, Hyper-V, SAN) avec gating obligatoire
- Tu veux un plan d'exécution séquencé avec préchecks, rollback, et closure formalisés
- Tu dois transmettre l'exécution à DossierIA pour archivage ITSM

---

## Les commandes principales

### Démarrer l'exécution guidée

La commande principale. Tu fournis la `runbook_card` de RouterIA (ou le chemin du runbook), PlaybookRunner déroule le plan complet.

**Usage — depuis une runbook_card RouterIA :**
```
Voici la runbook_card de RouterIA — démarre l'exécution guidée.

runbook_path: IT-SHARED/40_RUNBOOKS/RUNBOOKS_MD/RUNBOOK__IT_PATCH_DC_V1.md
intent: it.windows.update_missing
client: Otto Inc
serveur: DC01
risk_level: high
maintenance_window: 2026-05-18 22:00-23:00
change_id: CHG-2026-0517
backup_confirmed: true
```

**Ce que tu obtiens :**

Phase 1 — PRÉCHECKS (avant de toucher quoi que ce soit) :
```
PRÉCHECKS — À exécuter AVANT toute action

Étape 1.1 — Vérifier la réplication AD
  instruction: Sur DC01, exécuter repadmin /replsummary
  expected: Aucune erreur de réplication
  stop_if: Erreur de réplication → escalader à IT-NetworkMaster avant de continuer

Étape 1.2 — Confirmer le backup récent
  instruction: Vérifier dans Veeam/Datto que le backup DC01 date de < 24h
  expected: Backup réussi daté d'hier ou aujourd'hui
  stop_if: Backup absent ou échoué → NE PAS continuer — ouvrir incident backup
```

Phase 2 — EXÉCUTION (étape par étape)
Phase 3 — POSTCHECKS (valider le résultat)
Phase 4 — ROLLBACK (si problème détecté)
Phase 5 — CLOSURE + handoff DossierIA

---

### Confirmer une étape et passer à la suivante

Après chaque étape, tu fournis le résultat obtenu et PlaybookRunner continue.

**Usage :**
```
Étape 1.1 terminée — résultat obtenu :
repadmin /replsummary → Aucune erreur. Dernier cycle : il y a 5 minutes. OK.
```

**Ce que tu obtiens :**
- Validation du résultat vs `expected`
- Passage à l'étape suivante (ou STOP si `stop_if` déclenché)

---

### Déclarer une erreur et évaluer le rollback

Si une étape échoue, tu signales l'erreur et PlaybookRunner évalue le rollback.

**Usage :**
```
STOP — erreur à l'étape 2.3 — installation patch :
Erreur : "Windows Update 0x800f0831 — fichier CBS corrompu"
L'installation n'a pas abouti. Que faire ?
```

**Ce que tu obtiens :**
- Évaluation de la situation : rollback possible ou non
- Instructions de rollback si applicable
- Décision CONTINUE / ROLLBACK / ESCALADER
- Bloc de passation si Flag Up requis

---

### Gating risque — runbook high

Pour les runbooks `risk_level: high`, PlaybookRunner vérifie les prérequis avant de démarrer.

**Usage — sans les prérequis :**
```
Démarre le runbook RUNBOOK__IT_HYPER_V_MIGRATION_V1 pour le client ABC.
```

**Ce que tu obtiens (STOP automatique) :**
```
STOP — runbook risk_level: high détecté.
Prérequis obligatoires manquants :
  [ ] maintenance_window — créneau approuvé requis
  [ ] change_id — numéro de changement requis
  [ ] backup_confirmed — snapshot ou backup pré-migration confirmé requis

Fournir ces éléments pour démarrer.
```

---

## Flux de travail recommandé

### Exécution standard via RouterIA

```
1. RouterIA détecte l'intent → livre la runbook_card
        ↓
2. Coller la runbook_card dans PlaybookRunner
        ↓
3. PlaybookRunner exécute les préchecks → valider chaque résultat
        ↓
4. Exécution phase par phase — confirmer chaque étape
        ↓
5. Postchecks — valider le retour à la normale
        ↓
6. PlaybookRunner produit le handoff_to_dossier
        ↓
7. Coller le handoff dans DossierIA → dossier ITSM généré
```

### Runbook à risque élevé

```
1. Obtenir la runbook_card de RouterIA (risk_level: high confirmé)
        ↓
2. Préparer les prérequis :
   - Approuver la maintenance_window avec le client
   - Créer le change_id dans CW
   - Confirmer le backup pré-intervention
        ↓
3. Fournir les prérequis à PlaybookRunner → gating validé
        ↓
4. Exécution guidée — STOP immédiat si stop_if déclenché
        ↓
5. Postchecks obligatoires (≥ 2 pour P1/P2)
        ↓
6. Handoff DossierIA + postmortem si incident survenu
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| Ne jamais inventer une étape | PlaybookRunner ne complète que ce qui est dans le runbook source |
| STOP si `stop_if` déclenché | Un stop mal géré est moins grave qu'une escalade ratée |
| Prérequis high = bloquants | Aucune exécution high sans maintenance_window + change_id + backup |
| Confirmer chaque étape avant la suivante | La plateforme est séquentielle — jamais de saut d'étape |
| Toujours produire `handoff_to_dossier` | DossierIA ne peut archiver que ce que PlaybookRunner lui transmet |
| ZÉRO credential dans les outputs | Les commandes utilisent des placeholders — jamais de vrais mots de passe |

---

## Questions fréquentes

**Q : Puis-je démarrer PlaybookRunner sans passer par RouterIA ?**
Oui. Fournis directement le chemin du runbook et le contexte de l'intervention. PlaybookRunner chargera le runbook via GitHub Action et démarrera l'exécution guidée.

**Q : Que se passe-t-il si le runbook n'existe pas au chemin indiqué ?**
PlaybookRunner signale l'erreur 404, demande de corriger le chemin, et ne démarre pas avec un runbook inventé.

**Q : Est-ce que je dois confirmer chaque étape ?**
Oui. PlaybookRunner attend ton retour après chaque étape avant de passer à la suivante. C'est le principe fondamental — l'humain reste en contrôle à chaque instant.

**Q : Comment savoir si mon runbook est risk_level high ?**
Le `risk_level` est indiqué dans le `MASTER_DISPATCH_INDEX_V2.yaml` et dans le runbook lui-même. RouterIA le signale toujours dans la `runbook_card`. Exemples high : Domain Controller, Hyper-V, SAN, Firewall, migration données.

**Q : Quelle différence entre PlaybookRunner et DossierIA ?**
PlaybookRunner guide l'exécution en temps réel avec l'humain. DossierIA archive ce qui s'est passé après l'intervention. PlaybookRunner produit le `handoff_to_dossier` pour que DossierIA puisse créer le dossier ITSM complet.

---

*GUIDE_UTILISATION — IT-OPS-PlaybookRunner v1.0 — MSP Intelligence AI — 2026-05-18*
