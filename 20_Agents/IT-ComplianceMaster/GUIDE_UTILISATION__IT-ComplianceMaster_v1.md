# Guide d'utilisation — @IT-ComplianceMaster (v1.0)
> **Pour :** Techniciens N1/N2/N3 MSP
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-ComplianceMaster ?

**IT-ComplianceMaster est l'agent de conformité réglementaire de l'équipe MSP.**

Il ne surveille pas l'infrastructure (c'est IT-MonitoringMaster) ni la sécurité opérationnelle (c'est IT-SecurityMaster).
Il répond à la question : *"Est-ce que ce client — et le MSP lui-même — respectent leurs obligations légales et réglementaires ?"*

| Périmètre | Ce qu'il audite | Exemple |
|---|---|---|
| Client | Obligations légales du client | « BioClinic collecte des données santé — HIPAA s'applique. Voici les lacunes. » |
| MSP interne | Comment le MSP gère ses propres obligations | « Le MSP n'a pas désigné son RPRP Loi 25 — action requise. » |
| Empreinte MSP | Comment le MSP opère chez chaque client | « Technicien MSP utilise un compte partagé chez Dupont — non conforme Passportal. » |

> Les rapports produits sont **facturables**. Un audit Loi 25 bien structuré justifie un plan de remédiation payant.

---

## Quand l'utiliser ?

- Un client demande un audit de conformité (Loi 25, cyber-assurance, HIPAA, PCI-DSS)
- Le renouvellement d'une police cyber-assurance approche
- Un client fait face à un audit externe (CAI, auditeur PCI, etc.)
- Onboarding d'un nouveau client — vérifier son niveau de conformité initial
- Revue trimestrielle de conformité d'un client existant
- Incident de sécurité — vérifier les obligations de notification (Loi 25 : 72h)
- Audit interne MSP — vérifier que le MSP lui-même est conforme comme sous-traitant

---

## Les commandes principales

### `/audit-client [client] [framework]` — Audit de conformité client

La commande principale. Tu spécifies le client et le framework réglementaire applicable.

**Frameworks disponibles :** `loi25` `pci` `hipaa` `cyber-assurance` `tous`

**Usage :**
```
/audit-client Groupe Leblanc loi25
/audit-client Clinique Santé Plus hipaa
/audit-client ABC Paiements pci
/audit-client Dupont & Associés cyber-assurance
/audit-client Boutique Mode Inc tous
```

**Ce que tu obtiens :**
- Checklist structurée avec cases à cocher par section
- Indicateurs 🔴 (non conforme) / 🟡 (partiel) / 🟢 (conforme) pour chaque contrôle
- `[DONNÉES REQUISES : ...]` pour chaque information manquante — jamais inventée

> **Loi 25 s'applique à tous les clients québécois.** C'est le framework par défaut si le client n'a pas d'obligation sectorielle spécifique.

---

### `/audit-msp` — Audit de conformité interne MSP

Audite le MSP lui-même comme sous-traitant traitant des données personnelles de ses clients.

**Usage :**
```
/audit-msp
```

**Ce que tu obtiens :**
- Loi 25 sous-traitant : RPRP désigné, registre clients, ententes signées, cloisonnement données
- Gestion accès internes : comptes nominatifs, MFA, révocations, revue trimestrielle
- Sécurité postes techniciens : BitLocker, EDR, VPN, verrouillage écran
- Formation et sensibilisation du personnel

---

### `/audit-footprint [client]` — Audit de l'empreinte MSP chez un client

Répond à la question : *"Si ce client nous demande de prouver que nos techniciens opèrent de façon sécurisée chez eux — qu'est-ce qu'on peut montrer ?"*

**Usage :**
```
/audit-footprint Métal Pless
```

**Ce que tu obtiens :**
- Inventaire des comptes MSP dans l'AD client (nominatifs ? partagés ?)
- Vérification Passportal (100% des accès consignés ?)
- Moindre privilège (technicien N1 sans droits admin domaine ?)
- Trail d'audit (billets CW documentés ? logs RMM auditables ?)

---

### `/gap [client] [framework]` — Rapport de lacunes

Après un audit, produit un rapport de lacunes priorisé avec score de conformité.

**Usage :**
```
/gap Groupe Leblanc loi25
/gap BioClinic tous
```

**Ce que tu obtiens :**
```
SCORE DE CONFORMITÉ
[Framework] : [N/100] — 🔴 Non conforme | 🟡 Partiel | 🟢 Conforme
Conformes       : [N] contrôles ✅
Partiels        : [N] contrôles 🟡
Non conformes   : [N] contrôles 🔴

🔴 LACUNES CRITIQUES — action immédiate
🟡 LACUNES IMPORTANTES — planifier 30-60 jours
ℹ️  RECOMMANDATIONS — bonnes pratiques
```

---

### `/remediation [client]` — Plan de remédiation facturable

Transforme le rapport de lacunes en plan d'action avec effort et coût estimés.

**Usage :**
```
/remediation Groupe Leblanc
```

**Ce que tu obtiens :**
- Version interne (NE PAS PARTAGER) : actions, framework, responsable, délai, effort, coût estimé
- Version client-safe : bénéfices en langage non-technique, plan d'action simplifié

> C'est le livrable qui justifie la facturation. Chaque action est associée à un responsable (MSP ou client) et un délai.

---

### `/rapport [type]` — Générer un livrable

Quatre formats selon l'audience cible.

```
/rapport interne         → Tous les détails techniques, IPs, références légales précises (INTERNE)
/rapport client-safe     → Lacunes en langage non-technique, bénéfices, ZÉRO détail exploitable
/rapport executif        → Résumé 1 page — score, risques top 3, ROI de la remédiation (Direction client)
/rapport auditeur        → Preuves de conformité, contrôles en place, documentation (CAI / assureur)
```

---

### `/inventaire-donnees [client]` — Inventaire données personnelles

Requis pour la conformité Loi 25. Cartographie toutes les données personnelles collectées.

**Usage :**
```
/inventaire-donnees Clinique Santé Plus
```

**Ce que tu obtiens :**
- Tableau : catégorie de données, localisation, système, accès, rétention, sous-traitants, sensibilité
- Inventaire des sous-traitants touchant des données personnelles
- `[DONNÉES REQUISES : entrevue avec responsable opérationnel du client]` si information manquante

---

### `/suivi [client]` — Réévaluation trimestrielle

Fait le point sur les items du plan de remédiation depuis le dernier audit.

**Usage :**
```
/suivi Groupe Leblanc
```

**Ce que tu obtiens :**
- Statut de chaque action du plan (✅ Complétée / 🔄 En cours / ⏳ Non démarrée)
- Score actuel vs score initial
- Nouveaux items identifiés depuis le dernier audit

---

## Flux de travail recommandé

### Audit client initial (onboarding ou demande spécifique)

```
1. Identifier le ou les frameworks applicables
   Québec → Loi 25 (obligatoire)
   Paiements → PCI-DSS
   Santé → HIPAA
   Police cyber → cyber-assurance
        ↓
2. /audit-client [client] [framework(s)]
   Compléter les champs connus — [DONNÉES REQUISES] pour les inconnus
        ↓
3. /gap [client] [framework]
   Prioriser : Critique → Important → Recommandé
        ↓
4. /remediation [client]
   Version interne (coûts réels) + version client-safe
        ↓
5. /rapport executif
   Présenter à la direction du client — justifier le budget remédiation
        ↓
6. Planifier /suivi trimestriel
```

### Renouvellement cyber-assurance

```
1. /audit-client [client] cyber-assurance
   Focus : MFA (critique), EDR, backup hors-site, test restauration
        ↓
2. /gap [client] cyber-assurance
   Identifier les contrôles manquants qui pourraient causer un refus de réclamation
        ↓
3. /remediation [client]
   Corriger les lacunes critiques AVANT le renouvellement
        ↓
4. /rapport auditeur
   Documentation à fournir à l'assureur
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| ZÉRO IP, credentials, CVE dans les rapports clients | Ne jamais exposer des détails exploitables par un tiers |
| Chiffres = source citée | Ne jamais inventer un pourcentage ou une statistique |
| `[DONNÉES REQUISES : ...]` si manquant | Mieux qu'un rapport incomplet basé sur des hypothèses |
| Max 5 recommandations par rapport | Trop de recommandations = aucune priorisée |
| Brèche de données → @IT-UrgenceMaster en premier | L'obligation de notification (72h Loi 25) prime sur le rapport d'audit |
| Rapport client = bénéfices, pas lacunes techniques | Le client veut comprendre le risque business, pas les CVE |

---

## Questions fréquentes

**Q : Loi 25 s'applique-t-elle à tous mes clients ?**
Oui — tous les clients ayant une activité au Québec et collectant des renseignements personnels (ce qui inclut les noms, emails, numéros de téléphone) sont assujettis. L'obligation varie selon la taille et le type de données.

**Q : Quelle différence entre `/audit-client` et `/audit-footprint` ?**
`/audit-client` audite le client lui-même (ses obligations légales). `/audit-footprint` audite comment *le MSP* opère chez ce client (comptes, accès, Passportal, trail d'audit). Les deux sont complémentaires.

**Q : Un rapport `/rapport auditeur` peut-il être remis directement à la CAI ?**
Il est conçu pour ça. Il présente les contrôles en place, les lacunes connues et le plan de remédiation — le format attendu par la Commission d'accès à l'information ou un auditeur externe. Toujours valider avec le client avant envoi.

**Q : Combien de temps prend un audit Loi 25 complet ?**
Dépend des données disponibles. Si tu as déjà l'analyse d'infrastructure (Phase 1 IT-OnOffBoarder), un audit Loi 25 prend 30-60 min. Sans contexte, compter 1-2h pour collecter les `/inventaire-donnees` et compléter les champs manquants.

**Q : La commande `/audit-client [client] tous` audite tous les frameworks en une fois ?**
Oui — elle produit une checklist combinée Loi 25 + cyber-assurance + PCI-DSS + HIPAA. Utile pour un onboarding complet, mais attention à ne livrer au client que ce qui le concerne (ex : ne pas inclure HIPAA si le client n'est pas en santé).

---

*GUIDE_UTILISATION — IT-ComplianceMaster v1.0 — MSP Intelligence AI — 2026-05-18*
