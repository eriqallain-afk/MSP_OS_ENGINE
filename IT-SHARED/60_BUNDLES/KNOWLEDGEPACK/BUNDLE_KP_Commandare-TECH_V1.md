# BUNDLE_KP_Commandare-TECH_V1
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Type :** KnowledgePack GPT
**Agent cible :** @IT-Commandare-TECH
**Usage :** Uploader en Knowledge dans le GPT IT-Commandare-TECH
**Contenu :** Triage support N1-N3, opérations SOC, cross-département, matrice SLA, confinement sécurité, RCA
**Mis à jour :** 2026-03-28

---

## 1. MATRICE TRIAGE SUPPORT

| Niveau | Critères | SLA réponse | SLA résolution | Exemples |
|---|---|---|---|---|
| **P1** | Incident sécurité actif, service critique down pour tous | < 15 min | 4h | Ransomware, Exchange down, AD auth échoue pour tous |
| **P2** | Groupe d'utilisateurs impactés, service dégradé | < 30 min | 8h | VPN lent 10+ users, imprimante département, RDS ralenti |
| **P3** | Utilisateur unique bloqué, problème fonctionnel | < 2h | 24h | MDP expiré, Outlook sync, lecteur réseau manquant |
| **P4** | Demande d'info, changement planifié, formation | < 8h | 72h | Nouvelle installation, config GPO, question licence |

---

## 2. ARBRE DE DÉCISION TRIAGE

```
TICKET REÇU
│
├─ Indicateurs sécurité détectés ?
│  (malware, accès non autorisé, exfiltration, phishing cliqué)
│  OUI → P1 immédiat → @IT-SecurityMaster en lead
│       → Confinement initial SANS attendre confirmation
│       → Ne PAS toucher au poste suspect
│
├─ Combien d'utilisateurs impactés ?
│  ├─ Tous ou service critique → P1
│  ├─ Groupe / département → P2
│  └─ Utilisateur unique → P3
│
├─ Domaine technique ?
│  ├─ Réseau/VPN/backup/monitoring → REDIRIGER @IT-Commandare-NOC
│  ├─ Serveur/VM/Cloud/DC → REDIRIGER @IT-Commandare-Infra
│  ├─ Clôture/comms/rapports → REDIRIGER @IT-Commandare-OPR
│  └─ Support utilisateur → GARDER (périmètre TECH)
│
└─ Cross-département (autre équipe FACTORY) ?
   OUI → Identifier source_dept → traiter normalement
```

---

## 3. SOUS-AGENTS ET ROUTING

| Domaine | Agent mobilisé | Quand |
|---|---|---|
| Support N1/N2 standard | @IT-FrontLine | Tickets helpdesk courants |
| Support N2 avancé | @IT-Assistant-N2 | MDP complexe, config, dépannage avancé |
| Support N3 / intervention complète | @IT-Assistant-N3 | Problèmes complexes, multi-systèmes |
| Maintenance / patching | @IT-MaintenanceMaster | Fenêtres de maintenance, scripts |
| Sécurité / SOC | @IT-SecurityMaster | Alertes sécurité, IR, forensics |
| Licences / logiciels / CMDB | @IT-AssetMaster | Inventaire, lifecycle, audit |
| Scripts PS / automatisation | @IT-ScriptMaster | Scripts diagnostic ou remédiation |

---

## 4. PROTOCOLE SOC — CONFINEMENT IMMÉDIAT

### Déclencheurs de confinement (agir SANS attendre confirmation)
```
- Alerte EDR/XDR : malware confirmé ou comportement suspect élevé
- Règles Outlook suspectes détectées (forwarding externe, suppression auto)
- Connexion depuis un pays/IP inhabituel avec action sur les données
- Brute-force réussi (Event 4624 depuis source anormale)
- Chiffrement massif de fichiers (indicateur ransomware)
```

### Actions immédiates
```
1. Classer P1 — pas de négociation sur la sévérité
2. routing: @IT-SecurityMaster (lead sécurité)
3. Isolation réseau du poste/serveur suspect :
   - Via EDR (SentinelOne/CrowdStrike) si disponible
   - OU déconnecter le câble réseau physiquement
   - ⚠️ NE PAS éteindre la machine (artefacts RAM)
4. Révoquer les sessions et tokens du compte compromis
5. Notice Teams immédiate dans le canal SOC
6. NE PAS tenter de remédiation sans @IT-SecurityMaster
```

### Ce que TECH fait vs ce que SecurityMaster fait
```
TECH (toi) :
  - Détecte les indicateurs sécurité dans le ticket
  - Classe P1 et déclenche le confinement initial
  - Isole le poste/compte (action de containment)
  - Documente la timeline dans CW
  - Coordonne la communication avec le client via @IT-Commandare-OPR

SecurityMaster (lead sécurité) :
  - Investigation forensics approfondie
  - Analyse IOC
  - Remédiation définitive
  - Post-mortem sécurité
  - Recommandations de hardening
```

---

## 5. GESTION CROSS-DÉPARTEMENT (FACTORY)

### Principe
TECH est le seul Commandare accessible aux autres départements de la FACTORY pour leurs besoins helpdesk. Les autres équipes (CCQ, EDU, TRAD, PLR) ne contactent jamais directement Commandare-NOC, Infra ou OPR.

### Traitement
```
1. Identifier source_dept dans le ticket (quelle équipe demande)
2. Traiter comme un ticket support standard (même SLA)
3. Si le besoin nécessite un spécialiste IT :
   - Router vers le bon sous-agent (@IT-Assistant-N3, @IT-MaintenanceMaster, etc.)
   - NE PAS router vers un autre Commandare directement
4. Documenter dans result.source_dept pour le reporting
```

---

## 6. RCA (Root Cause Analysis) — QUAND ET COMMENT

### Déclencheurs RCA obligatoire
```
- Tout P1 résolu
- P2 récurrent (même problème > 2 fois en 30 jours)
- Incident avec impact business client documenté
- Demande explicite du superviseur ou du client
```

### Template RCA
```yaml
rca:
  incident_id: "#TXXXXXXX"
  date_incident: YYYY-MM-DD
  date_rca: YYYY-MM-DD
  
  timeline:
    detection: "HH:MM — comment détecté"
    diagnostic: "HH:MM — actions d'investigation"
    resolution: "HH:MM — fix appliqué"
    validation: "HH:MM — service confirmé rétabli"
  
  cause_racine: "Description technique précise"
  
  facteurs_contributifs:
    - "Facteur 1"
    - "Facteur 2"
  
  actions_correctives:
    - action: "Description"
      owner: "@IT-Agent"
      eta: "YYYY-MM-DD"
      statut: planifié|en_cours|complété
  
  leçons:
    - "Ce qu'on a appris"
  
  monitoring_ajusté:
    - "Nouvelle alerte ou seuil ajouté pour prévenir la récurrence"
```

---

## 7. ANTI-PATTERNS TECH

```
❌ Traiter un incident sécurité comme un simple ticket support
❌ Attendre confirmation avant de confiner un poste suspect
❌ Router un ticket cross-département vers Commandare-NOC ou Infra directement
❌ Clôturer un P1 sans RCA planifié
❌ Escalader sans documenter ce qui a déjà été fait
❌ Appliquer un changement en prod sans passer par @IT-Commandare-OPR pour l'approbation
❌ Ignorer un P3 récurrent — 3 P3 identiques = 1 problème systémique = P2
```

---

## 8. ESCALADES

| Situation | Vers | Quand |
|---|---|---|
| Incident sécurité P1 | @IT-SecurityMaster | Immédiat — lead sécurité |
| Infrastructure (serveur/VM/cloud) | @IT-Commandare-Infra | Hors périmètre support |
| Réseau/VPN/backup/monitoring | @IT-Commandare-NOC | Hors périmètre support |
| Clôture / comms / rapports | @IT-Commandare-OPR | Après résolution |
| Change request en prod | @IT-Commandare-OPR | Approbation requise |

---

*BUNDLE_KP_Commandare-TECH_V1 — Version 1.0 — 2026-03-28*
