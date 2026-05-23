# Exemple d’intervention — Windows Update Missing / Patchs “Under review” dans RMM

**Type :** Référence interne MSP  
**Catégorie :** MAINTENANCE / RMM / Windows Patching  
**Cas source :** Billet CW #0001234  
**Client source :** Otto Inc  
**Date du cas :** 2026-05-15  
**Statut final du cas :** À suivre par l’équipe RMM  
**Niveau de sensibilité :** Interne — ne pas transmettre tel quel au client  

> Ce document sert d’exemple pour les billets similaires où un monitor “Windows Update Missing - Server” est déclenché, mais où les mises à jour sont visibles dans l’outil RMM avec le statut **Missing / Under review**.  
> Les noms d’hôtes, informations techniques sensibles, IPs et identifiants doivent être exclus des livrables client.

---

## 1. Résumé du cas

Un billet NOC a été ouvert à la suite d’une alerte de surveillance indiquant qu’un serveur Windows n’avait pas installé de mises à jour critiques ou de sécurité depuis environ deux mois.

Le monitor concerné était :

```text
Script Monitor - Windows Update Missing - Server
```

Le message d’alerte indiquait :

```text
No critical or security updates were installed in the last 2 months.
```

Après vérification dans l’outil RMM, les mises à jour applicables étaient bien détectées, mais elles étaient en statut :

```text
Missing / Under review
```

Conclusion opérationnelle :  
le problème ne semblait pas être un bris local de Windows Update, mais plutôt un enjeu de **politique d’approbation / configuration de patching RMM**.

---

## 2. Runbooks / références utilisés

### Runbooks utilisés pendant l’intervention

| Référence | Utilisation |
|---|---|
| `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-WIN-Patching_Complet_V3.md` | Runbook principal pour le diagnostic Windows patching, logique precheck → patching → reboot contrôlé → postcheck |
| `IT-SHARED/10_RUNBOOKS/00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md` | Validation des garde-fous : lecture seule d’abord, aucune action destructive sans confirmation, confidentialité |
| `IT-SHARED/20_TEMPLATES/01_TEMPLATE_CW/TEMPLATE_BUNDLE_CW_CLOSE.md` | Templates CW utilisés pour T1, T3 et T8 |

### Runbook connexe à charger si le contexte change

| Référence | Quand l’utiliser |
|---|---|
| `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-WIN-PendingReboot_V2.md` | Si un pending reboot est détecté ou si le billet devient une intervention de reboot contrôlé |
| `IT-SHARED/10_RUNBOOKS/MAINTENANCE/MAINT-WIN-Patching_CW-RMM_V3.md` | Si l’équipe passe à une remédiation complète via CW RMM |

---

## 3. Déclencheurs typiques

Utiliser ce modèle lorsque l’un des symptômes suivants est présent :

- Monitor RMM : `Windows Update Missing - Server`
- Message indiquant qu’aucune mise à jour critique/sécurité n’a été installée depuis 30, 60 ou 90 jours
- Correctifs visibles comme `Missing`, mais avec statut `Under review`
- Aucune installation récente visible dans l’historique des correctifs
- Aucun problème Windows Update local confirmé à ce stade

---

## 4. Exemple d’observations

Dans le cas source, deux mises à jour étaient visibles comme manquantes :

```text
KB5088864
2026-05 mise à jour cumulative .NET Framework pour Windows Server 2019 x64
Statut : Missing / Under review
Catégorie : Security Updates
Sévérité : Important
Impact : Can request restart
Taille : 173.50 MB
```

```text
KB5087538
2026-05 mise à jour cumulative Windows Server 2019 1809 x64
Statut : Missing / Under review
Catégorie : Security Updates
Impact : Can request reboot
```

Note : les numéros de KB changent selon le mois. L’élément important est le couple :

```text
Missing + Under review
```

---

## 5. Interprétation technique

### Ce que signifie probablement “Missing / Under review”

Le correctif est détecté comme applicable, mais il n’est pas encore approuvé pour installation par la politique de patching RMM.

Causes probables :

- Patch en attente de révision dans la politique RMM
- Groupe de patching client configuré en approbation manuelle
- Classification de patch non approuvée automatiquement
- Exclusion ou délai d’approbation configuré
- Période de déploiement non atteinte
- Serveur rattaché au mauvais groupe/policy RMM

### Ce que ce cas ne confirme pas automatiquement

Ne pas conclure sans preuve que :

- Windows Update est brisé localement
- Le service Windows Update est arrêté
- Le serveur nécessite immédiatement un reboot
- Les correctifs doivent être installés hors fenêtre
- La politique RMM est erronée pour tous les clients

---

## 6. Procédure recommandée

### Étape 1 — Diagnostic lecture seule

Valider les éléments suivants :

- Serveur / asset ciblé
- Rôle du serveur
- Derniers correctifs installés
- Correctifs manquants
- Statut RMM des correctifs
- Présence de pending reboot
- État général minimal : disque, services Windows Update, erreurs récentes

Aucune installation ni reboot à cette étape.

---

### Étape 2 — Qualification du blocage

Si les correctifs sont `Missing / Under review` :

```text
Cause probable : approbation ou configuration RMM à valider.
Action : escalader / transférer à l’équipe RMM pour ajustement des politiques.
```

Ne pas installer manuellement les correctifs sauf si :

- Fenêtre approuvée
- Backup récent confirmé
- Rôle serveur validé
- Mode maintenance RMM activé
- Reboot possible accepté
- Client / coordonnateur informé selon le contexte

---

### Étape 3 — Remédiation par équipe RMM

L’équipe RMM doit valider :

- Groupe de patching associé à l’asset
- Règles d’approbation des cumulative updates
- Règles d’approbation des security updates
- Statut `Under review`
- Délais ou anneaux de déploiement applicables
- Exceptions client ou serveur
- Prochaine fenêtre d’installation

---

## 7. Garde-fous importants

```text
À NE PAS FAIRE
- Ne pas forcer un reboot sans approbation.
- Ne pas installer manuellement les KB sans fenêtre approuvée.
- Ne pas supposer que Windows Update est corrompu sans diagnostic.
- Ne pas fermer comme résolu si les patchs demeurent Under review.
- Ne pas inclure d’IP, credentials, chemins internes ou détails sensibles dans la Discussion client.
```

```text
À FAIRE
- Documenter que l’alerte est valide.
- Documenter que les patchs sont détectés comme Missing / Under review.
- Transférer à l’équipe RMM pour ajustement si le blocage est côté policy.
- Garder le billet en suivi ou créer une tâche RMM selon le processus interne.
```

---

## 8. Exemple de triage initial

```yaml
triage:
  categorie: "MAINTENANCE"
  priorite: "P4 / Low selon NOC"
  systemes_affectes:
    - "Serveur Windows concerné"
  symptome: "Windows Update Missing - Server"
  impact_utilisateurs: "[À CONFIRMER]"
  risque: "Serveur potentiellement non conforme aux correctifs de sécurité mensuels"
  statut_initial: "Aucune remédiation effectuée — diagnostic lecture seule requis"

plan_action:
  - "Valider l’alerte et les correctifs manquants"
  - "Vérifier si les correctifs sont bloqués par statut RMM Under review"
  - "Documenter la cause probable"
  - "Transférer à l’équipe RMM pour ajustement des politiques"
  - "Planifier installation contrôlée si les correctifs sont approuvés"
```

---

## 9. Notice Teams — début d’intervention

À utiliser si une notice Teams est requise au début de l’intervention :

```text
⚠️ Maintenance en cours — Billet : #[BILLET]

Maintenance en cours chez [CLIENT]
Tâche principale : Vérification d’une alerte Windows Update manquantes sur un serveur.
Impact : Aucun impact prévu pour le diagnostic initial en lecture seule.
```

---

## 10. Livrable CW — T1 Discussion client

À utiliser lorsque l’analyse confirme une alerte valide, mais que l’action est transférée en suivi RMM.

```text
────────────────────────────────────────────────────────
       Analyse d’alerte — mises à jour Windows
────────────────────────────────────────────────────────

BILLET : #[BILLET]
DATE : [YYYY-MM-DD]
TECHNICIEN : [INITIALS]
---------

PRÉPARATION ET DÉCOUVERTE :
---------
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

TRAVAUX EFFECTUÉS :
---------
• Analyse de l’alerte de surveillance signalant des mises à jour Windows manquantes
• Vérification de l’état des mises à jour applicables au serveur concerné
• Confirmation que les mises à jour de sécurité sont détectées, mais en attente de validation dans le processus de gestion des correctifs
• Aucun redémarrage ni changement de configuration appliqué durant l’analyse

RÉSULTAT :
---------
• Alerte validée et cause probable identifiée
• Intervention transférée en suivi interne afin d’ajuster le processus d’approbation des correctifs

RECOMMANDATION :
---------
• Ajuster les paramètres de gestion des correctifs afin que les mises à jour applicables puissent être approuvées et déployées lors de la prochaine fenêtre appropriée
```

---

## 11. Livrable CW — T3 Note interne

```text
════════════════════════════════════════════════════════════════
INTERVENTION TECHNIQUE — ALERTE WINDOWS UPDATE
════════════════════════════════════════════════════════════════

INFORMATIONS GÉNÉRALES
-----------------------
Date        : [YYYY-MM-DD]
Technicien  : [INITIALS]
Client      : [CLIENT]
Billet CW   : #[BILLET]
Équipements : [ASSET / SANS IP]
Type        : Troubleshooting / Alerte NOC

PRÉPARATION ET DÉCOUVERTE :
---------
• Prendre connaissance de la demande et consultation de la documentation de l'entreprise.
• Connexion au RMM et analyse de l'état global et de la présence d'alerte.

CONTEXTE INITIAL
----------------
Alerte NOC reçue pour le monitor "Windows Update Missing - Server".
Le monitor indique qu’aucune mise à jour critique ou de sécurité n’a été installée dans les 2 derniers mois.

DIAGNOSTIC / ANALYSE
--------------------
Étapes effectuées :
- Validation du détail de l’alerte RMM
- Vérification des mises à jour applicables visibles dans l’outil de gestion des correctifs
- Analyse du statut des mises à jour détectées

Observations :
- [KB] détectée comme Missing / Under review
  Description : [Description du correctif]
  Catégorie : Security Updates
  Impact : peut demander un redémarrage

Cause probable :
- Les correctifs sont détectés comme applicables, mais leur statut "Under review" empêche leur installation automatique.
- La cause semble liée au processus d’approbation ou à la configuration de patching côté RMM, plutôt qu’à une indisponibilité locale de Windows Update.

ACTIONS TECHNIQUES
-------------------
Action 1 — Analyse de l’alerte NOC / RMM
  Résultat : Alerte confirmée comme valide.

Action 2 — Vérification des correctifs manquants
  Résultat : Mises à jour de sécurité/cumulatives identifiées comme Missing / Under review.

Action 3 — Validation du type de remédiation requis
  Résultat : Aucun correctif installé durant cette intervention. Aucun redémarrage effectué. Suivi requis par l’équipe RMM pour ajustement des approbations/configurations.

CONFIGURATIONS MODIFIÉES
-------------------------
Aucune configuration modifiée.

TESTS DE VALIDATION
-------------------
✓ Alerte NOC analysée : OK
✓ Mises à jour manquantes identifiées : OK
✓ Cause probable documentée : OK
✓ Remédiation destructive évitée sans fenêtre/approbation : OK

RÉSULTAT FINAL
--------------
État : À SUIVRE

SUIVI REQUIS
------------
■ Transmettre à l’équipe RMM pour validation des politiques d’approbation des patchs
■ Confirmer si les mises à jour "Under review" doivent être approuvées pour ce client / ce groupe de serveurs
■ Après ajustement RMM, planifier installation contrôlée avec validation de fenêtre, backup récent et redémarrage possible

POST-INTERVENTION
-----------------
■ Courriel client envoyé : Non requis
■ Documentation Hudu mise à jour : Non requis

TEMPS INTERVENTION
------------------
Temps total : [À CONFIRMER]
════════════════════════════════════════════════════════════════
```

---

## 12. Livrable interne — T8 Mémo équipe RMM

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MÉMO INTERNE — Ajustement configuration RMM patching
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
À            : Équipe RMM
De           : IT-SysAdmin / [INITIALS]
Date         : [YYYY-MM-DD]
Billet       : #[BILLET]
Client       : [CLIENT]

RAISON
──────
Alerte NOC Windows Update Missing validée — correctifs applicables bloqués au statut Under review.

RÉSUMÉ
──────
Le monitor RMM indique qu’aucune mise à jour critique ou de sécurité n’a été installée dans les 2 derniers mois sur l’asset concerné.
Des mises à jour applicables sont détectées comme Missing, mais leur statut est "Under review", ce qui semble empêcher l’installation automatique.
Aucune installation ni redémarrage n’a été effectué durant l’analyse.
Un ajustement RMM est requis pour valider les politiques d’approbation ou d’exclusion applicables à ce client / asset / groupe de patching.

Correctifs observés :
- [KB] — [Description] — Missing / Under review — peut demander un redémarrage
- [KB] — [Description] — Missing / Under review — peut demander un redémarrage

STATUT        : ⚠️ En cours
SUIVI REQUIS : Oui — valider et ajuster la configuration RMM de patch approval / review, puis confirmer quand les correctifs peuvent être approuvés pour installation contrôlée.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 13. Critères de fermeture

Fermer le billet seulement si l’un des états suivants est vrai :

### Option A — Fermeture après transfert RMM

Le billet peut être fermé si le processus interne prévoit que l’équipe RMM gère l’ajustement dans un autre billet/tâche, et que le transfert est clairement documenté.

Statut recommandé :

```text
À suivre par équipe RMM — ajustement configuration patch approval / Under review
```

### Option B — Garder ouvert

Garder le billet ouvert si aucun mécanisme de suivi RMM n’est créé.

Conditions de suivi :

- L’équipe RMM confirme l’ajustement
- Les patchs passent de `Under review` à approuvés
- Une fenêtre d’installation est confirmée
- Le serveur est patché et validé

---

## 14. Points d’attention pour futurs cas

- Le monitor peut être valide même si Windows Update fonctionne.
- `Under review` est un indicateur fort d’un blocage côté processus de patching.
- Ne pas confondre “patch missing” avec “Windows Update broken”.
- La remédiation dépend souvent de l’équipe RMM, pas du technicien serveur.
- Un reboot peut être requis, mais ne doit pas être lancé sans fenêtre approuvée.
- Si le serveur est un DC, SQL, RDS, Hyper-V ou Veeam, charger le runbook spécifique avant toute action.
