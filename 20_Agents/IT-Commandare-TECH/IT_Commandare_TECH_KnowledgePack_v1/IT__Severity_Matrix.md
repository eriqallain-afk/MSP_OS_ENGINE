# IT — Severity Matrix (S0–S4)

## Objectif
Uniformiser la sévérité, la cadence d’updates, et les triggers post-mortem.

---

## S0 — Critical / Catastrophic
**Définition** : service critique indisponible pour la majorité des utilisateurs OU risque majeur sécurité/données.  
**Cadence updates** : toutes les 15 min (minimum).  
**Owner** : NOC (pilotage), CTOMaster arbitre, Security si sécu.  
**Triggers** : post-mortem obligatoire + CAPA.

## S1 — High
**Définition** : forte dégradation / impact significatif, contournement limité.  
**Cadence** : 15–30 min.  
**Triggers** : post-mortem requis si >60 min ou récidive.

## S2 — Medium
**Définition** : impact partiel, workaround disponible, risque contenu.  
**Cadence** : 30–60 min.  
**Triggers** : post-mortem si récurrent ou incident >4h.

## S3 — Low
**Définition** : problème mineur / impact limité / faible urgence.  
**Cadence** : au besoin.  
**Triggers** : action de prévention si tendance.

## S4 — Info / Noise
**Définition** : alerte informative, faux positif, bruit.  
**Cadence** : none.  
**Triggers** : ajuster seuils/alerting (MonitoringMaster).

---

## Règles générales
- Toujours distinguer : **Faits / Hypothèses / Next test**.
- Un incident devient automatiquement plus sévère si :
  - SLA à risque,
  - augmentation rapide du scope,
  - suspicion sécurité.
