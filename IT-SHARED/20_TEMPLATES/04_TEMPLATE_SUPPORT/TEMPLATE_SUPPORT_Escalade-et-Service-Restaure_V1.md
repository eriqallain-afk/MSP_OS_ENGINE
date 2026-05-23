# TEMPLATE_SUPPORT_Escalade-et-Service-Restaure_V1
**Agent :** IT-Assistant-N2, IT-Assistant-N3 | IT-MaintenanceMaster | IT-SysAdmin
**Usage :** Blocs CW à coller avant transfert d'un billet + confirmation service rétabli
**Mis à jour :** 2026-03-20

---

## PARTIE 1 — BLOC ESCALADE NOC (à coller dans CW avant transfert)

```
═══════════════════════════════════════════════
TRANSFERT → DÉPARTEMENT NOC
Billet : #[XXXXXX] | Priorité : P[1/2]
Technicien : [NOM] | [YYYY-MM-DD HH:MM]
═══════════════════════════════════════════════

SYMPTÔME
[Description précise]

IMPACT IMMÉDIAT
• Utilisateurs affectés : [Nombre / Qui]
• Services impactés    : [Liste]
• Heure de début       : [HH:MM]

RISQUES À VENIR SI NON TRAITÉ
• [Risque 1]
• [Risque 2]

ASSETS AFFECTÉS
• [Asset 1]
• [Asset 2]

ACTIONS DÉJÀ TENTÉES (N2/N3)
1. [Action — résultat]
2. [Action — résultat]
═══════════════════════════════════════════════
```

---

## PARTIE 2 — BLOC ESCALADE SOC

```
═══════════════════════════════════════════════
TRANSFERT → DÉPARTEMENT SOC
Billet : #[XXXXXX] | Priorité : P[1/2]
Technicien : [NOM] | [YYYY-MM-DD HH:MM]
═══════════════════════════════════════════════

TYPE : ☐ Phishing/Compromission  ☐ Ransomware  ☐ Breach  ☐ Autre

COMPTE/ASSET AFFECTÉ
• [Utilisateur / Asset — voir Passportal pour credentials]
• Heure de détection : [HH:MM]

SYMPTÔMES OBSERVÉS
• [Symptôme 1]
• [Symptôme 2]

ACTIONS IMMÉDIATES EFFECTUÉES (N2/N3)
☐ Compte désactivé
☐ Sessions révoquées
☐ MDP réinitialisé (voir Passportal)

VÉRIFICATIONS À COMPLÉTER PAR LE SOC
☐ Règles Outlook suspectes
☐ Transferts automatiques
☐ Activité connexion 7 derniers jours
☐ Propagation — autres comptes
═══════════════════════════════════════════════
```

---

## PARTIE 3 — BLOC ESCALADE TECH (Senior/RCA)

```
═══════════════════════════════════════════════
TRANSFERT → DÉPARTEMENT TECH (Support N3+)
Billet : #[XXXXXX] | Priorité : P[1/2/3]
Technicien N2 : [NOM] | [YYYY-MM-DD HH:MM]
Durée intervention N2 : [X min]
═══════════════════════════════════════════════

PROBLÉMATIQUE
[Description complète]

CE QUI A ÉTÉ TENTÉ
1. [Action — résultat]
2. [Action — résultat]
3. [Action — résultat]

HYPOTHÈSE ACTUELLE
[Ce que le technicien pense être la cause]

CLIENT EN ATTENTE : ☐ Oui  ☐ Non
SLA À RISQUE      : ☐ Oui  ☐ Non
═══════════════════════════════════════════════
```

---

## PARTIE 4 — CONFIRMATION SERVICE RÉTABLI (CW Discussion + Teams)

### CW Discussion (client-safe)
```
RÉSOLUTION : [Type de service] rétabli
DATE : [YYYY-MM-DD] | TECHNICIEN : [Initiales]

TRAVAUX EFFECTUÉS :
• Analyse du service et vérifications de l'environnement
• [Action corrective 1 — description fonctionnelle sans détails techniques sensibles]
• [Action corrective 2]
• Contrôles de bon fonctionnement effectués

RÉSULTAT :
• [Service X] : pleinement opérationnel depuis [HH:MM]
• Monitoring confirmé — aucune alerte active

RECOMMANDATION :
• [Si applicable — ex: planifier une mise à jour de prévention]
```

### Annonce Teams
```
✅ Service rétabli — [Nom du service] | [DATE] [HH:MM]
Billet #[XXXXXX] — [Technicien]
[Description 1 ligne de la résolution]
```
