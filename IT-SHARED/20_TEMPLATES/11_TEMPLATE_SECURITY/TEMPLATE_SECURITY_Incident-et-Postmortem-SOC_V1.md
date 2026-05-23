# TEMPLATE_SECURITY_Incident-et-Postmortem-SOC_V1
**Agent :** IT-SecurityMaster, IT-Assistant-N3
**Usage :** Fiche incident sécurité active + rapport postmortem SOC
**Mis à jour :** 2026-03-20

---

## PARTIE 1 — FICHE INCIDENT SÉCURITÉ (pendant l'incident)

```
═══════════════════════════════════════════════
FICHE INCIDENT SÉCURITÉ
Billet CW      : #[XXXXXX] | Priorité : P[1/2]
Client         : [NOM]
Date/Heure     : [YYYY-MM-DD HH:MM]
Technicien SOC : [NOM]
═══════════════════════════════════════════════

TYPE D'INCIDENT
☐ Ransomware / Malware actif
☐ Phishing / Compromission compte
☐ Breach / Accès non autorisé
☐ Exfiltration de données
☐ Mouvement latéral confirmé
☐ Alerte EDR/XDR (SentinelOne / CrowdStrike / Defender XDR)
☐ Autre : [préciser]

CLASSIFICATION
P1 : ☐ Chiffrement actif  ☐ Credentials admin compromis  ☐ DC/AD touché  ☐ Exfiltration
P2 : ☐ Mouvement latéral  ☐ Multiple postes  ☐ Compte compromis isolé

ASSETS AFFECTÉS
• [Asset 1 — rôle]
• [Asset 2 — rôle]
Vecteur d'entrée probable : [Email / RDP / VPN / Supply chain / Inconnu]
Propagation active : ☐ Oui  ☐ Non  ☐ Inconnu

TIMELINE
[HH:MM] Détection : [Source — EDR / utilisateur / NOC]
[HH:MM] Qualification : [Résumé]
[HH:MM] Containment : [Action — ex: asset isolé réseau]
[HH:MM] Investigation débutée
[HH:MM] [Autres actions]

CONTAINMENT EFFECTUÉ
☐ Asset(s) isolé(s) du réseau
☐ Compte(s) désactivé(s) et sessions révoquées
☐ Hashes IOC bloqués dans EDR
☐ IPs/domaines C2 bloqués sur firewall
☐ Machine NON éteinte (artefacts forensics préservés)

ARTEFACTS COLLECTÉS
☐ Processus actifs
☐ Connexions réseau (netstat)
☐ Logs Event Viewer (Security/System)
☐ Tâches planifiées
☐ Services

COMMUNICATIONS
☐ NOC informé à [HH:MM]
☐ Client informé à [HH:MM]
☐ Superviseur informé à [HH:MM]
═══════════════════════════════════════════════
```

---

## PARTIE 2 — RAPPORT POSTMORTEM SOC

```
═══════════════════════════════════════════════
POSTMORTEM SÉCURITÉ
Billet CW   : #[XXXXXX]
Client      : [NOM]
Incident    : [Titre court]
Période     : [YYYY-MM-DD HH:MM] → [YYYY-MM-DD HH:MM]
Durée       : [Xh Ymin]
Rédigé par  : [Technicien SOC]
Date rapport: [YYYY-MM-DD]
═══════════════════════════════════════════════

RÉSUMÉ EXÉCUTIF (non-technique — pour le client)
[2-3 phrases : quoi s'est passé, quel impact, comment résolu]

CHRONOLOGIE DÉTAILLÉE
[HH:MM] [Action/Observation]
[HH:MM] [Action/Observation]
...

CAUSE RACINE
[Cause technique précise — pas le symptôme]

ÉTENDUE DE LA COMPROMISSION
Assets touchés      : [Liste]
Données exposées    : ☐ Oui → [Description]  ☐ Non  ☐ Inconnu
Propagation         : ☐ Confirmée  ☐ Non confirmée

ACTIONS DE REMÉDIATION EFFECTUÉES
1. [Action — résultat]
2. [Action — résultat]

MESURES PRÉVENTIVES RECOMMANDÉES
1. [Mesure 1 — priorité haute/moyenne/basse]
2. [Mesure 2]

LEÇONS APPRISES
• [Ce qui a bien fonctionné]
• [Ce qui peut être amélioré]
• [Changement de procédure recommandé]

SUIVI
[ ] KB article créé : [ID]
[ ] Politique de sécurité mise à jour
[ ] Formation utilisateur recommandée : ☐ Oui  ☐ Non
[ ] Prochain audit sécurité : [Date]
═══════════════════════════════════════════════
```
