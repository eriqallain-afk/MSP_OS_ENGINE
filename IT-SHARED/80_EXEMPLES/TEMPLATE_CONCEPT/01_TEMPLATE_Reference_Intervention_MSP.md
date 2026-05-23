# EXEMPLE DE RÉFÉRENCE — INTERVENTION MSP
## [TITRE DU CAS] — [Résumé court du problème]

**Type de document :** Référence interne / cas modèle réutilisable  
**Client du cas :** [À CONFIRMER]  
**Client anonymisé pour démonstration :** [À CONFIRMER]  
**Billet de référence :** [À CONFIRMER]  
**Priorité :** [À CONFIRMER]  
**Usage :** Réutilisation lors d’interventions similaires MSP  
**Statut :** Modèle à compléter  

---

## But du document

Transformer une intervention MSP complète en modèle de référence pour les techniciens.

Le document doit conserver :

- le contexte initial;
- la séquence d’analyse;
- les scripts ou commandes exécutés;
- les critères de diagnostic;
- les décisions prises;
- les actions effectuées;
- les suivis recommandés;
- les sorties ConnectWise prêtes à coller.

---

## 1. Quand utiliser ce document

Utiliser ce modèle lorsqu’une intervention présente un ou plusieurs des éléments suivants :

- alerte RMM/NOC nécessitant validation technique;
- diagnostic infrastructure, réseau, serveur, poste ou service cloud;
- besoin de documenter une cause racine;
- intervention pouvant devenir une référence future;
- besoin de produire une Note interne CW et une Discussion client-safe;
- cas démontrant la valeur du produit MSP.

---

## 2. Résumé exécutif du cas de référence

Le cas a commencé par :  
`[Décrire l’alerte, la demande ou le symptôme initial]`

L’analyse a confirmé que :  
`[Décrire le constat principal]`

La cause principale retenue est :  
`[Cause racine ou À CONFIRMER]`

Les actions effectuées ont permis de :  
`[Décrire le résultat final]`

Le suivi recommandé est :  
`[Décrire le suivi, s’il y a lieu]`

---

## 3. Runbooks, garde-fous et références utilisés

### 3.1 Utilisés ou référencés directement pendant le cas

- `GUARDRAILS__IT_AGENTS_MASTER` — posture lecture seule d’abord, pas d’invention, validation avant action.
- `TEMPLATE_BUNDLE_CW_CLOSE` — préparation des sorties de clôture CW.
- `[RUNBOOK À CONFIRMER]` — [Rôle du runbook dans l’intervention].
- `[RÉFÉRENCE À CONFIRMER]` — [Rôle de la référence dans l’intervention].

### 3.2 Références complémentaires pertinentes

- Documentation client : `[À CONFIRMER]`
- Documentation fournisseur : `[À CONFIRMER]`
- Historique RMM / NOC : `[À CONFIRMER]`
- Historique ConnectWise : `[À CONFIRMER]`
- KB interne : `[À CONFIRMER]`

---

## 4. Pré-requis

- Accès RMM ou outil équivalent.
- Accès administratif approprié.
- Accès à la documentation client.
- Accès aux journaux ou consoles pertinentes.
- Autorisation de changement si modification de production requise.
- Aucun correctif destructif avant confirmation de la cause principale.

---

## 5. Séquence d’analyse exacte

### 5.1 Étape 1 — Qualification initiale

**Objectif :** comprendre la demande, confirmer le périmètre et éviter toute action prématurée.

```powershell
# Exemple générique — remplacer selon le cas
Write-Host "=== CONTEXTE INITIAL ==="
Write-Host "Client        : [À CONFIRMER]"
Write-Host "Billet        : [À CONFIRMER]"
Write-Host "Système ciblé : [À CONFIRMER]"
Write-Host "Symptôme      : [À CONFIRMER]"