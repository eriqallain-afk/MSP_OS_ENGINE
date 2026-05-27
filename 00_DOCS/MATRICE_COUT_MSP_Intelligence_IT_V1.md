# MATRICE DE COÛT — MSP Intelligence IT
**Version :** 1.0 | **Date :** 2026-05-23 | **Statut :** À valider par EA

---

## SECTION A — TARIFICATION CLIENT

> Prix suggérés pour la vente du produit MSP Intelligence IT aux firmes MSP.
> Modèle : abonnement mensuel par firme (non par technicien).
> Tous les prix sont en CAD, avant taxes.

---

### A1. Grille tarifaire par gamme

> Modèle : flat fee par firme MSP — non par technicien. Prix en CAD avant taxes.

| Gamme | Agents inclus | Techs cible | Prix mensuel | Prix annuel (−15 %) | Valeur livrée estimée |
|---|---|---|---|---|---|
| **Starter** | 4 agents | 1–4 techs | **249 $/mois** | **2 540 $/an** | ~800–1 500 $/mois économisés |
| **Pro** | 10 agents | 3–10 techs | **549 $/mois** | **5 600 $/an** | ~1 500–3 000 $/mois économisés |
| **MSP** | 18 agents | 5–20 techs | **999 $/mois** | **10 190 $/an** | ~3 500–6 000 $/mois économisés |
| **Enterprise** | 33 agents | 10+ techs | **1 799 $/mois** | **18 350 $/an** | ~8 000 $/mois + audits compliance facturables 2 000–5 000 $/client |

> **Ratio valeur/prix :** le Starter à 249$/mois représente moins de 5 % de la valeur récupérée. L'Enterprise à 1 799$/mois se justifie avec un seul audit compliance client facturé à l'année.

---

### A2. Ce qui est inclus par gamme

| Inclus | Starter | Pro | MSP | Enterprise |
|---|:---:|:---:|:---:|:---:|
| Agents support (FrontLine, N2, TicketOpr, TicketScribe) | ✅ | ✅ | ✅ | ✅ |
| Agents infra (N3, SysAdmin, TechOPS, Maintenance, Backup, Réseau) | — | ✅ | ✅ | ✅ |
| RouterIA (routing automatique d'intent) | — | — | ✅ | ✅ |
| NOC (Dispatcher, Monitoring, Urgences) | — | — | ✅ | ✅ |
| Cloud, OnOffBoarder, ReportMaster, AssetMaster | — | — | ✅ | ✅ |
| ComplianceMaster (Loi 25, PCI, HIPAA, cyber-assurance) | — | — | — | ✅ |
| SecurityMaster (SOC, EDR, IR) | — | — | — | ✅ |
| Audit 5 piliers + Entra + Purview | — | — | — | ✅ |
| Orchestration Claude API (Commandare) | — | — | — | ✅ |
| Runbooks (120 validés) | ✅ | ✅ | ✅ | ✅ |
| Templates (90 formats CW/Email/Teams/Rapports) | ✅ | ✅ | ✅ | ✅ |
| Scripts PowerShell (24 inline RMM-ready) | Partiel | ✅ | ✅ | ✅ |
| Mises à jour et nouveaux agents | ✅ | ✅ | ✅ | ✅ |
| Onboarding guidé (1 session démo) | ✅ | ✅ | ✅ | ✅ |
| Support EA|IA (async) | ✅ | ✅ | ✅ | ✅ |

---

### A3. Options et modules à la carte

| Option | Description | Prix suggéré |
|---|---|---|
| Module Compliance seul | ComplianceMaster + 4 runbooks audit | **149 $/mois** |
| Agents additionnels | Ajout d'un agent hors gamme | **49 $/agent/mois** |
| Démo terrain (1 billet réel) | Session guidée 60–90 min avec EA|IA | **Gratuit** (stratégie acquisition) |
| Onboarding étendu | Configuration personnalisée + formation équipe (4h) | **395 $** (une fois) |
| Accès Claude API orchestration | Commandare + PlaybookRunner actifs via API | **Inclus Enterprise** / **299 $/mois add-on** |

---

### A4. Référence de valeur (justification prix)

| Élément de valeur | Impact estimé |
|---|---|
| Note CW + discussion client post-intervention | 15–25 min → 2–3 min |
| Triage P1 structuré avec runbook chargé | 5–10 min de recherche → immédiat |
| Script PowerShell inline (RMM-ready) | 20–40 min de rédaction → immédiat |
| Rapport client post-maintenance | 45–60 min → 8–10 min |
| Audit compliance 5 piliers (trimestriel) | 6–8h manuel → 1–2h guidé |
| Clôture billet conforme (DoD qualité) | Variable → systématique |

> **Référence marché :** Un technicien MSP junior coûte 45–65 $/h. 3 heures sauvées par semaine = 140–200 $/semaine de valeur récupérée par technicien.

---

## SECTION B — COÛT D'OPÉRATION EA|IA

> Ce que ça coûte à EA|IA pour livrer et maintenir la plateforme par client actif.

---

### B1. Infrastructure plateforme (coûts fixes mensuels)

| Poste | Fournisseur | Plan | Coût mensuel (CAD) |
|---|---|---|---|
| ChatGPT Teams | OpenAI | Teams — par siège EA | ~35 $/siège |
| Claude.ai (développement) | Anthropic | Pro ou Teams | ~25–50 $/siège |
| GitHub repo (eriqallain-afk/IT) | GitHub | Free / Pro | 0–5 $ |
| Claude API (orchestration Enterprise) | Anthropic | Pay-per-use | Variable |
| Domaine + hébergement site | GitHub Pages + registraire | — | ~15 $/an |

---

### B2. Coût variable par client (livraison + support)

| Activité | Temps estimé EA | Coût estimé (65 $/h) |
|---|---|---|
| Onboarding initial (livraison agents + démo) | 2–3h | 130–195 $ |
| Support async mensuel (questions, ajustements) | 0.5–1h/mois | 30–65 $/mois |
| Mise à jour agents / nouveaux runbooks | Inclus dans maintenance | — |
| Session de calibration personnalisée | 1.5–2h | 100–130 $ |

---

### B3. Marge estimée par gamme

| Gamme | Prix client/mois | Coût variable/mois | Marge brute | Marge % |
|---|---|---|---|---|
| Starter | **249 $** | ~35 $ | ~214 $ | ~86 % |
| Pro | **549 $** | ~50 $ | ~499 $ | ~91 % |
| MSP | **999 $** | ~65 $ | ~934 $ | ~93 % |
| Enterprise | **1 799 $** | ~95 $ | ~1 704 $ | ~95 % |

> Les coûts variables incluent : fraction du temps support EA + fraction des abonnements infra.

---

### B4. Seuil de rentabilité (break-even)

| Coût fixe mensuel EA|IA | Détail |
|---|---|
| ChatGPT Teams (2 sièges) | ~70 $ |
| Claude.ai Pro (1 siège dev) | ~28 $ |
| GitHub Pro | ~5 $ |
| **Total fixe** | **~103 $/mois** |

| Scénario | Clients requis pour break-even |
|---|---|
| 1 client Starter (249$/mois) | **1 client suffit** (249$ > 103$ infra) |
| Infra + temps EA (103$ + 260$ = 363$/mois) | **2 Starter** ou **1 Pro** (549$ > 363$) |
| Objectif viable à 5 clients | 5 × Starter = 1 245$/mois → **~880$ de marge nette** |

---

## SECTION C — RÉFÉRENCES DE PRIX MARCHÉ

> Benchmark pour calibrer la grille A1.

| Concurrent / Catégorie | Prix marché | Notes |
|---|---|---|
| Copilot pour M365 | 30 USD/utilisateur/mois | Généraliste, non MSP |
| Outils ticketing IA (ex: Halo PSA AI) | 15–40 USD/tech/mois | Focalisé CW uniquement |
| Runbooks SaaS (ex: Liongard, Rewst) | 99–499 USD/mois | Automatisation workflow |
| Consultant MSP (par heure) | 100–175 CAD/h | Ponctuel, non systématique |
| Formation technicien N2→N3 | 2 000–5 000 $ | Une fois, pas de mise à jour |

> **Positionnement suggéré :** prix entre un outil SaaS spécialisé et un consultant ponctuel — valeur récurrente, systématique, mise à jour continue.

---

## PROCHAINES ÉTAPES

- [ ] EA valide les prix (grille A1 et options A3)
- [ ] Décider si onboarding étendu reste à 395$ ou devient inclus dans MSP/Enterprise
- [ ] Décider politique de mise à jour agents (incluse — recommandé pour fidélisation)
- [ ] Tester la démo gratuite comme levier d'acquisition (1 billet réel → conversion)
- [ ] Créer une page de tarification sur le site github.io

---

*MATRICE_COUT_MSP_Intelligence_IT_V1 — EA|IA — 2026-05-23 — Confidentiel*
