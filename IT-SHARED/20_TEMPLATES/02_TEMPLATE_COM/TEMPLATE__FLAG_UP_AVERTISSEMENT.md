# TEMPLATE — FLAG UP / AVERTISSEMENT
# Usage : Diagnostic complet mais intervention non terminée
# Alerter NOC / SOC / Support qu'un problème réel existe et nécessite une suite
**Version :** 1.0 | **Date :** 2026-03-24

---

## QUAND UTILISER CE TEMPLATE

Situation : Le technicien a fait le diagnostic, a identifié le problème,
mais **ne peut pas compléter l'intervention** parce que :
- Le correctif appartient à une autre équipe (RMM, Infra, SOC, etc.)
- Une fenêtre de maintenance est requise
- L'accès requis n'est pas disponible
- Le risque est trop élevé sans approbation
- Le temps alloué est écoulé

**Ce n'est pas un échec — c'est une passation structurée.**

---

## FORMAT — CW Note Interne (FLAG UP)

```
Prise de connaissance de la demande et consultation de la documentation du client.

🚩 FLAG UP — DIAGNOSTIC COMPLET / INTERVENTION INCOMPLÈTE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Billet      : #[XXXXX]
Client      : [Nom]
Technicien  : [Initiales]
Date/Heure  : [YYYY-MM-DD HH:MM]
Transmis à  : ☐ NOC  ☐ SOC  ☐ Support  ☐ Infra  ☐ RMM  ☐ Autre: [___]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PROBLÈME IDENTIFIÉ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Symptôme     : [Description exacte du problème observé]
Depuis quand : [Date ou durée estimée]
Impact       : [Services affectés / utilisateurs impactés]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CAUSE IDENTIFIÉE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Description précise de la cause racine ou hypothèse principale fortement probable]
Niveau de confiance : ☐ Confirmé  ☐ Très probable  ☐ Hypothèse principale

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PREUVES / DIAGNOSTIC EFFECTUÉ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. [Élément de preuve 1 — source + observation]
2. [Élément de preuve 2 — source + observation]
3. [Élément de preuve 3 — source + observation]
Artefacts collectés : [Noms des fichiers / logs / scripts archivés]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
POURQUOI L'INTERVENTION N'EST PAS COMPLÈTE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
☐ Correctif appartient à l'équipe : [Nom équipe]
☐ Fenêtre de maintenance requise : [Créneau suggéré]
☐ Accès requis non disponible : [Préciser]
☐ Approbation requise avant action : [De qui]
☐ Risque trop élevé sans fenêtre contrôlée
☐ Autre : [Préciser]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ACTIONS REQUISES — ÉQUIPE RÉCEPTRICE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. [Action concrète 1 — qui fait quoi]
2. [Action concrète 2 — qui fait quoi]
3. [Validation attendue après correctif]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RISQUES SI AUCUNE ACTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[Conséquence concrète si le problème n'est pas réglé — sans alarmisme]
Délai critique : ☐ Immédiat  ☐ < 24h  ☐ < 1 semaine  ☐ Planifié
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## FORMAT — CW Discussion (client-safe — Flag Up)

```
Préparation et découverte.
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

INTERVENTION: Diagnostic et analyse — [Type de problème]
DATE: [YYYY-MM-DD]
TECHNICIEN: [Initiales]

TRAVAUX EFFECTUÉS:
• Prise en charge du billet et revue de l'historique du problème
• Diagnostic complet de [domaine concerné]
• Identification de la cause du problème
• Documentation des éléments de diagnostic et des actions recommandées
• Transmission du dossier à l'équipe responsable pour correction

RÉSULTAT:
• Cause du problème identifiée et documentée
• Plan d'action défini et transmis à l'équipe concernée
• Suivi requis : [court résumé de ce qui reste à faire]

RECOMMANDATION:
• [Action recommandée — délai — équipe responsable]
```

---

## FORMAT — Notice Teams (Flag Up)

**Titre :**
```
🚩 Avertissement — Billet : #[XXXXX]
```
**Contenu :**
```
Diagnostic complété chez [Client]
Problème identifié : [Description courte]
Action requise par : [Équipe]
Délai : [Immédiat / < 24h / Planifié]
```

---

## EXEMPLE COMPLÉTÉ — Cas Veeam ESXi (ticket #0001234)

### CW Note Interne — Flag Up réel

```
Prise de connaissance de la demande et consultation de la documentation du client.

🚩 FLAG UP — DIAGNOSTIC COMPLET / INTERVENTION INCOMPLÈTE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Billet      : #0001234
Client      : Otto Inc
Technicien  : EA
Date/Heure  : 2026-03-20 23:00
Transmis à  : ☑ RMM / Monitoring

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PROBLÈME IDENTIFIÉ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Symptôme     : Échecs récurrents jobs Veeam — "Failed to retrieve object hierarchy"
Depuis quand : Plusieurs semaines
Impact       : Sauvegardes ESXi incomplètes — risque de perte de données

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CAUSE IDENTIFIÉE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Probe RMM génère du trafic excessif sur les API VMware et SSH pendant la fenêtre
de backup → timeouts services de gestion ESXi (hostd) → Veeam ne peut pas
inventorier les VMs.
Niveau de confiance : ☑ Très probable

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PREUVES / DIAGNOSTIC EFFECTUÉ
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Logs ESXi hostd — timeouts SoapAdapter corrélés avec fenêtre backup
2. Logs SSH — "invalid protocol identifier" depuis probe RMM (mauvais type de check)
3. PRECHECK Veeam — jobs actifs, services up, dépôts OK — problème externe à Veeam
Artefacts : PRECHECK_VEEAM_T20260319_203620.log + extraits logs ESXi archivés

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
POURQUOI L'INTERVENTION N'EST PAS COMPLÈTE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
☑ Correctif appartient à l'équipe : RMM / Monitoring

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ACTIONS REQUISES — ÉQUIPE RMM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Corriger le module SSH (trafic non-SSH sur port 22)
2. Réduire/espacer le polling VMware API pendant la fenêtre backup (02:00-03:00)
3. Après correctif : relancer MP_ESXI - Local_Daily manuellement et confirmer succès

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RISQUES SI AUCUNE ACTION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Sauvegardes continueront d'échouer — exposition croissante au risque de perte de données.
Délai critique : ☑ < 24h
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Notice Teams — Flag Up réel

```
Titre   : 🚩 Avertissement — Billet : #0001234
Contenu : Diagnostic complété chez Otto Inc
          Problème identifié : probe RMM interfère avec sauvegardes Veeam ESXi
          Action requise par : Équipe RMM / Monitoring
          Délai : < 24h
```

---
*Template v1.0 — 2026-03-24 — IT MSP Intelligence Platform*
