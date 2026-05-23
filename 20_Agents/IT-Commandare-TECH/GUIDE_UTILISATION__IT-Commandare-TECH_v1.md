# Guide d'utilisation — @IT-Commandare-TECH (v1.0)
> **Pour :** Techniciens support N1/N2/N3, analystes SOC, équipes helpdesk
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-Commandare-TECH ?

**IT-Commandare-TECH est le commandant du support technique et du SOC.**

Il coordonne les tickets utilisateurs (N1 à N3), gère les incidents de sécurité en mode SOC (confinement, investigation, escalade), et sert de point d'entrée helpdesk pour tous les autres départements de la FACTORY. Il ne fait pas le diagnostic technique bas niveau — il **triage, oriente, coordonne et escalade**.

| Domaine | Ce que gère Commandare-TECH |
|---|---|
| Support N1 | Problèmes courants : postes, imprimantes, accès, mots de passe |
| Support N2 | Incidents récurrents, configurations, dépannage avancé |
| Support N3 | Bugs applicatifs, escalades techniques complexes |
| SOC | Alertes sécurité, phishing, malware, brute-force, accès anormaux |
| Cross-FACTORY | Tickets helpdesk des autres équipes (CCQ, EDU, TRAD, PLR, etc.) |

**Commandare-TECH ne gère PAS :**
- Alertes réseau / VPN / backup → IT-Commandare-NOC
- Incidents serveurs / Cloud / Infra → IT-Commandare-Infra
- Rapports, scribe, assets → IT-Commandare-OPR
- RCA infra profond → IT-Commandare-Infra ou IT-Commandare-NOC

---

## Quand l'utiliser ?

- Un ticket utilisateur arrive et tu dois déterminer le niveau (N1/N2/N3) et le plan d'action
- Une alerte EDR, phishing ou accès anormal est signalée — confinement requis
- Plusieurs tickets similaires arrivent → pattern à identifier, escalade coordonnée
- Un département FACTORY soumet un ticket helpdesk
- Tu dois préparer la clôture CW d'une intervention support ou SOC

---

## Les commandes principales

### `/triage` — Analyser un ticket ou une alerte sécurité

La commande principale. Tu fournis le ticket ou l'alerte, Commandare-TECH classe la sévérité, identifie le niveau de support requis et produit le plan d'action.

**Usage — ticket support :**
```
/triage
Billet #77502
Client : Otto Inc
Utilisateur : Marie Côté
Description : Impossible de se connecter au VPN depuis ce matin. Erreur "Authentication failed".
Poste : Windows 11 — portable
Dernier accès VPN réussi : il y a 3 jours
Autres utilisateurs affectés : inconnu
```

**Ce que tu obtiens (YAML) :**
```yaml
result:
  tech_domain: support_n2
  severity: P3
  decision:
    routing: IT-AssistanTI_N3
    actions_now:
      - Vérifier expiration du certificat VPN
      - Confirmer si d'autres utilisateurs affectés
      - Contrôler les logs d'authentification
  sla: "< 2h résolution"
```

**Usage — alerte sécurité :**
```
/triage
Billet #77601
Client : Otto Transport
Description : Alerte EDR — détection comportement ransomware sur poste WRK-047
Heure détection : 09:15
Actions EDR : quarantaine automatique activée
Utilisateur : Jean Martin — comptabilité
```

**Ce que tu obtiens :**
- Classement P1 automatique — incident sécurité actif
- `routing: IT-SecurityMaster` en lead immédiat
- Actions de confinement dans `actions_now` sans attendre confirmation

---

### `/escalade` — Générer le bloc CW de transfert

Quand l'incident dépasse le périmètre TECH ou qu'un spécialiste doit prendre le lead.

**Usage :**
```
/escalade IT-SecurityMaster
Billet #77601 — Otto Transport
Incident sécurité P1 — comportement ransomware détecté sur WRK-047
Poste isolé par EDR — investigation SOC requise
```

**Ce que tu obtiens :**
- Bloc CW structuré prêt à coller
- Contexte complet transmis au spécialiste
- `next_actions` avec priorité et owner clairement définis

---

### `/teams` — Générer la notice Teams

Toute intervention est notifiée dans Teams dès que le type est connu, avec le numéro de billet.

**Usage :**
```
/teams
Billet : #77601
Client : Otto Transport
Type : Incident sécurité — comportement ransomware
Statut : Actif — confinement en cours
```

**Ce que tu obtiens :**
```
⚠️ Incident actif — Billet : #77601

Incident sécurité chez Otto Transport
Tâche principale : Confinement et investigation SOC
Impact : Poste comptabilité isolé — accès restreint
```

---

### `/flagup` — Passation structurée

Quand l'intervention doit être transmise à un autre agent ou au quart suivant.

**Usage :**
```
/flagup
Billet #77502 — Otto Inc — VPN
Statut : Diagnostic en cours — certificat VPN expiré probable
En attente : vérification côté serveur RADIUS
Prochaine action : IT-AssistanTI_N3 doit valider le profil VPN
Agent suivant : IT-AssistanTI_N3
```

**Ce que tu obtiens :**
- Passation structurée avec contexte complet
- État exact : fait / en attente / prochaine étape
- Notice Teams de Flag Up générée

---

### `/close` — Clôture CW

Déclenche le menu de clôture pour les livrables CW formels.

**Usage :**
```
/close
```

**Ce que tu obtiens (menu — STOP en attente de ton choix) :**
```
Clôture — Billet #[XXXXX]
[1] CW Note Interne
[2] CW Discussion (facturable client)
[3] Email client
[4] Notice Teams
[A] Tout (1+2+3+4)

Que veux-tu générer ?
```

> Important : Commandare-TECH attend ton choix avant de générer.

---

### `/status` — Résumé en cours

**Usage :**
```
/status
```

**Ce que tu obtiens :**
- Résumé : billet, client, domaine TECH, sévérité
- Dernière action + prochaine étape
- Agents mobilisés et statut SOC si applicable

---

## Flux de travail recommandé

### Ticket support standard

```
1. Ticket reçu dans ConnectWise
        ↓
2. /triage [description complète]
   → Niveau N1/N2/N3 + sévérité P1-P4 + plan d'action
        ↓
3. Assigner à l'agent spécialiste (IT-AssistanTI_N3, IT-MaintenanceMaster, etc.)
        ↓
4. Résolution confirmée → /close [choix livrable CW]
```

### Incident sécurité — protocole SOC

```
1. Alerte EDR / phishing / accès anormal détecté
        ↓
2. /triage [description complète avec IOC si disponibles]
   → P1 automatique si indicateurs sécurité
        ↓
3. CONFINEMENT IMMÉDIAT — isolation poste/compte SANS ATTENDRE confirmation
   (règle absolue : ne pas attendre pour le confinement initial)
        ↓
4. /escalade IT-SecurityMaster — lead investigation SOC
        ↓
5. Notifier Teams immédiatement (/teams)
        ↓
6. Post-incident : /close + postmortem via IT-Commandare-OPR
```

### Ticket cross-FACTORY (autre département)

```
1. Ticket reçu depuis département CCQ / EDU / TRAD / PLR / etc.
        ↓
2. /triage avec source_dept identifié
        ↓
3. Résoudre au niveau N1/N2 ou escalader selon complexité
        ↓
4. Signaler dans result.source_dept pour suivi
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| Incident sécurité P1 → IT-SecurityMaster en lead immédiat | La sécurité ne peut pas attendre un triage prolongé |
| Confinement SANS attendre confirmation | L'isolation d'un poste suspect est réversible — une infection ne l'est pas |
| Escalader vers NOC si réseau/backup/VPN impliqué | Ne pas absorber hors périmètre TECH |
| JAMAIS de credentials dans les livrables | Même pour les notes internes — Passportal uniquement |
| Valider le changement requis → owner IT-Commandare-OPR | Les RFC passent par OPR pour la gouvernance formelle |
| Étapes de validation post-fix obligatoires | Confirmer que le fix tient avant de fermer le ticket |

---

## Questions fréquentes

**Q : Quelle différence entre Commandare-TECH et IT-AssistanTI_N3 ?**
Commandare-TECH triage, classe et coordonne les tickets support. IT-AssistanTI_N3 effectue le diagnostic technique et la résolution. Commandare-TECH mobilise le bon niveau de support selon la complexité.

**Q : Quand escalader vers Commandare-Infra vs rester en TECH ?**
Si l'incident touche un serveur, une VM, le DC ou Azure → Commandare-Infra. Si c'est un problème utilisateur ou applicatif (poste, logiciel, accès, mot de passe) → Commandare-TECH.

**Q : La règle SOC de confinement sans attendre s'applique toujours ?**
Oui — c'est un garde-fou non négociable. Si un poste présente des indicateurs de ransomware ou malware actif, on isole d'abord, on valide ensuite. Le coût d'une isolation inutile est nul comparé à une propagation.

**Q : Commandare-TECH peut gérer les tickets des autres départements FACTORY ?**
Oui — c'est son rôle cross-département. Il est le seul Commandare utilisable par CCQ, EDU, TRAD, PLR et les autres équipes pour leurs besoins helpdesk.

**Q : Qui gère la clôture formelle d'un incident SOC P1 ?**
Commandare-TECH génère les livrables CW immédiats. Pour la clôture formelle avec postmortem et DoD, il passe à IT-Commandare-OPR.

---

*GUIDE_UTILISATION — IT-Commandare-TECH v1.0 — MSP Intelligence AI — 2026-05-18*
