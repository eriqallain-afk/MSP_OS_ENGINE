# TEMPLATE — Postmortem d'Incident IT
**ID :** TEMPLATE__POSTMORTEM_V2  
**Agent producteur :** IT-ReportMaster  
**Déclencheur :** Tout incident P1 ou P2 récurrent | **Délai :** ≤ 5 jours ouvrables post-résolution

---

# RAPPORT POSTMORTEM — [TITRE INCIDENT]

**Ticket CW :** [#TICKET]  
**Date/Heure incident :** [YYYY-MM-DD HH:MM]  
**Date/Heure résolution :** [YYYY-MM-DD HH:MM]  
**Durée totale :** [Xh Ymin]  
**Rédigé par :** [Technicien / Agent]  
**Révisé par :** [IT-Commandare-TECH / Senior]  
**Date du postmortem :** [YYYY-MM-DD]

---

## RÉSUMÉ EXÉCUTIF

> *2-3 phrases maximum. Non-technique. Répondre : Quoi s'est passé ? Quel impact ? Comment résolu ?*

[RÉSUMÉ EXÉCUTIF]

---

## IMPACT

| Dimension | Détail |
|-----------|--------|
| Services affectés | [Liste] |
| Utilisateurs touchés | [Nombre / Tous] |
| Durée d'interruption | [Xh Ymin] |
| Clients impactés | [Noms ou Tous] |
| SLA manqué | [Oui/Non — détail] |
| Perte estimée | [Si applicable] |

---

## TIMELINE DES ÉVÉNEMENTS

| Heure | Événement | Qui |
|-------|----------|-----|
| HH:MM | Déclenchement initial | [Monitoring/User/NOC] |
| HH:MM | Détection confirmée | |
| HH:MM | Premier technicien assigné | |
| HH:MM | [Action/découverte] | |
| HH:MM | Escalade vers [Agent/Senior] | |
| HH:MM | Cause racine identifiée | |
| HH:MM | Remédiation appliquée | |
| HH:MM | Service restauré | |
| HH:MM | Validation complète | |
| HH:MM | Ticket fermé | |

**MTTD (Détection) :** [Xh Ymin depuis début incident]  
**MTTR (Résolution) :** [Xh Ymin depuis ouverture ticket]

---

## ANALYSE CAUSE RACINE (5 Whys)

**Problème observé :** [Description symptôme final]

| Niveau | Pourquoi ? | Réponse |
|--------|-----------|---------|
| Why 1 | Pourquoi le service était-il down ? | |
| Why 2 | Pourquoi [réponse 1] ? | |
| Why 3 | Pourquoi [réponse 2] ? | |
| Why 4 | Pourquoi [réponse 3] ? | |
| Why 5 | Pourquoi [réponse 4] ? | |

**Cause racine identifiée :** [Description précise]

**Catégorie :** 
- [ ] Erreur humaine
- [ ] Défaillance matérielle
- [ ] Défaillance logicielle/bug
- [ ] Manque de monitoring
- [ ] Procédure absente ou inadéquate
- [ ] Changement non contrôlé
- [ ] Cause externe (FAI, fournisseur)

---

## CE QUI A BIEN FONCTIONNÉ

- [Point positif 1 — ex: détection rapide par monitoring]
- [Point positif 2]
- [Point positif 3]

---

## CE QUI PEUT ÊTRE AMÉLIORÉ

- [Amélioration 1 — ex: délai de détection trop long]
- [Amélioration 2]
- [Amélioration 3]

---

## PLAN D'ACTION

### Actions correctives (déjà prises)

| Action | Responsable | Complété le |
|--------|------------|------------|
| [Action déjà réalisée] | | [DATE] |

### Actions préventives (à planifier)

| # | Action | Responsable | Échéance | Statut |
|---|--------|------------|---------|--------|
| 1 | | | | 📋 À faire |
| 2 | | | | 📋 À faire |
| 3 | | | | 📋 À faire |

---

## COMMUNICATION EFFECTUÉE

| Destinataire | Canal | Message | Heure |
|-------------|-------|---------|-------|
| [Client] | Email/Teams | [Résumé] | |
| [Direction interne] | [Canal] | [Résumé] | |

---

## NOTES ADDITIONNELLES

[Tout autre élément pertinent, références tickets liés, KB créés]

---

**Règle non-blame :** Ce document vise l'amélioration des processus, pas l'identification de responsables.  
*Postmortem généré par @IT-ReportMaster — Confidentiel interne*
