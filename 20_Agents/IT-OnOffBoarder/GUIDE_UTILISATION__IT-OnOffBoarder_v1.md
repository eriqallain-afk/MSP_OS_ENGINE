# Guide d'utilisation — @IT-OnOffBoarder (v1.0)
> **Pour :** Techniciens N1/N2/N3 MSP
> **Mis à jour :** 2026-05-18

---

## À quoi sert IT-OnOffBoarder ?

**IT-OnOffBoarder est l'agent de gestion des transitions MSP.**

Il gère tous les changements d'état — entrée et sortie — pour les deux types de parties prenantes : les clients MSP et les employés chez un client.

| Scénario | Ce que fait l'agent |
|---|---|
| Nouveau client MSP | Découverte infra (10 domaines), analyse des lacunes, proposition de mise à niveau, déploiement outils MSP, handover SOC |
| Client MSP qui quitte | Inventaire, remise documentation, transfert licences, désinstallation outils MSP, révocation accès, clôture |
| Nouvel employé chez un client | Création AD, M365, équipement, accès réseau, VoIP, accès physiques, validation |
| Employé qui quitte un client | Révocation accès, récupération équipement, transfert données, rétention légale |

---

## Quand l'utiliser ?

- Un nouveau client signe avec le MSP → onboarding complet Phase 0 à 6
- Un client annonce son départ → offboarding structuré Phase A à F
- Un client signale l'arrivée d'un employé → onboarding employé
- Un client signale un départ d'employé (planifié ou immédiat) → offboarding employé
- Tu as besoin d'une checklist spécifique à la demande → `/checklist [scenario]`
- Tu veux transformer des résultats de scripts RMM en fiches documentation → `/doc-output`

---

## Les commandes principales

### `/onboard client [nom]` — Démarrer l'onboarding d'un nouveau client MSP

La commande qui démarre le workflow complet en 6 phases.

**Usage :**
```
/onboard client Dupont & Associés
```

**Ce que tu obtiens :**
- Phase 0 : Checklist préparation administrative (contrats, CW, Hudu, contacts)
- Ensuite phase par phase sur demande : `/analyse-infra`, `/gap`, `/upgrade`, `/deploiement`, `/autodiscovery`, `/soc`

> **Règle :** Chaque phase doit être complétée avant de passer à la suivante. Zéro saut de phase.

---

### `/analyse-infra [client]` — Phase 1 — Découverte infrastructure

Analyse complète en 10 domaines. C'est le fondement — rien n'est inventé.

**Usage :**
```
/analyse-infra Dupont & Associés
```

**Ce que tu obtiens :**
- 10 domaines documentés : Utilisateurs & Identité, Équipements, Applicatif & Licences, Sécurité, Télécom & VoIP, Cloud & M365, Monitoring & RMM, Documentation existante, Contrats fournisseurs, Accès testés
- `[À CONFIRMER]` pour tout champ non vérifié sur le terrain — jamais inventé
- Score de santé initial 🔴/🟡/🟢 par domaine

---

### `/gap [client]` — Phase 2 — Rapport de lacunes

Compare l'infrastructure découverte aux standards MSP.

**Usage :**
```
/gap Dupont & Associés
```

**Ce que tu obtiens :**
```
SCORE GLOBAL : [N/10]
🔴 Lacunes critiques — action requise avant SOC
🟡 Lacunes importantes — planifier dans 30-60 jours
ℹ️ Recommandations bonnes pratiques
```

---

### `/autodiscovery [client]` — Phase 4b — Scripts RMM + documentation automatique

Lance la découverte automatique via 12 scripts PowerShell RMM, puis transforme les résultats en fiches documentation.

**Usage :**
```
/autodiscovery Dupont & Associés
```

**Étapes :**
1. L'agent te demande la plateforme de documentation : Hudu / ITGlue / Lansweeper / Universal
2. Il liste les 12 scripts (S-01 à S-12) à lancer depuis le RMM
3. Tu colles chaque résultat brut dans `/doc-output [résultat]`
4. Il produit la fiche formatée pour ta plateforme doc

**Les 12 scripts disponibles :**
| Script | Ce qu'il collecte |
|---|---|
| S-01 Get-ServerInventory | OS, RAM, CPU, uptime |
| S-02 Get-DiskInfo | Disques, espace libre |
| S-03 Get-WindowsRoles | Rôles Windows Server |
| S-04 Get-InstalledSoftware | Applications installées |
| S-05 Get-CriticalServices | Services critiques — Running/Stopped |
| S-06 Get-NetworkConfig | NICs, IP (pour docs internes uniquement) |
| S-07 Get-ADSummary | Utilisateurs AD, groupes, OUs |
| S-08 Get-InstalledPatches | KB installées, pending reboot |
| S-09 Get-BackupAgentStatus | Jobs Veeam/Datto — dernier succès |
| S-10 Get-CertificateExpiry | Certificats SSL — expiration |
| S-11 Get-ScheduledTasks | Tâches planifiées non-Microsoft |
| S-12 Get-WorkstationInventory | Postes de travail |

---

### `/offboard client [nom]` — Démarrer l'offboarding d'un client MSP

**⚠️ Approbation EA obligatoire avant de commencer la révocation des accès.**

**Usage :**
```
/offboard client Métal Pless — date de départ: 2026-06-01 — nouveau MSP: Tech Solutions Inc
```

**Ce que tu obtiens :**
- Phase A : Inventaire complet de ce que le MSP gère
- Phase B : Remise documentation (export Hudu, schémas réseau, procédures)
- Phase C : Transfert licences et contrats
- Phase D : Désinstallation outils MSP (RMM, EDR, backup, anti-spam)
- Phase E : Révocation complète accès MSP
- Phase F : Facturation finale et clôture CW

---

### `/onboard user [nom] [client]` — Onboarding employé

**Usage :**
```
/onboard user Jean Tremblay — client: Groupe Leblanc — arrivée: 2026-05-25 — rôle: Comptable — département: Finance
```

**Ce que tu obtiens :**
- Checklist complète : AD, M365, équipement, accès réseau, VoIP, accès physiques
- Validation finale : 5 tests à confirmer avec l'utilisateur (login, fichiers, email, apps, manager informé)

---

### `/offboard user [nom] [client]` — Offboarding employé

**⚠️ Validation manager obligatoire avant désactivation.**

**Usage :**
```
/offboard user Marie Côté — client: ABC Inc — départ: 2026-05-20 — type: PLANIFIÉ
```

ou pour un départ immédiat :
```
/offboard user Pierre Gagnon — client: XYZ Ltée — type: IMMÉDIAT ⚡
```

**Pour un départ IMMÉDIAT — ordre strict :**
1. Désactiver compte AD
2. Révoquer sessions M365 (Revoke-AzureADUserAllRefreshToken)
3. Changer MDP comptes partagés
4. Ensuite : données, équipement, VoIP, accès physiques

---

### `/rapport [type]` — Générer un livrable

```
/rapport rapport-decouverte   → Interne MSP — 10 domaines, tous les [À CONFIRMER]
/rapport rapport-client       → Client — résumé non-technique, bénéfices, ZÉRO IP
/rapport brief-noc            → Équipe NOC/OPS — particularités, sensibilités, runbooks
/rapport rapport-cloture      → Client + Interne — score AVANT/APRÈS, preuves de valeur
```

---

## Flux de travail recommandé

### Onboarding client MSP (workflow complet)

```
1. Contrats signés → /onboard client [nom]
   Phase 0 : Préparation admin (CW, Hudu, contacts)
        ↓
2. Sur le terrain → /analyse-infra [client]
   Phase 1 : 10 domaines documentés
        ↓
3. /gap [client]
   Phase 2 : Score de risque + lacunes priorisées
        ↓
4. /upgrade [client]
   Phase 3 : Proposition mise à niveau (validée par client)
        ↓
5. /deploiement [client] + /autodiscovery [client]
   Phase 4 : RMM, EDR, backup, monitoring, Passportal, Hudu
        ↓
6. /soc [client]
   Phase 5 : Handover NOC — SLA activé, alertes testées
        ↓
7. /close → /rapport rapport-cloture
   Phase 6 : Score AVANT/APRÈS, rapport client, QBR planifié
```

### Offboarding employé — départ planifié

```
1. Demande RH reçue → Confirmer avec manager
        ↓
2. Avant la date de départ : /offboard user [nom] [client]
   Transfert données OneDrive, redirections email, calendrier
        ↓
3. Date de départ : Désactivation AD, révocation M365, équipement récupéré
        ↓
4. Validation finale avec manager → /close
```

---

## Règles à retenir

| Règle | Pourquoi |
|---|---|
| ZÉRO IP dans les rapports clients | Sécurité et professionnalisme — jamais exposer la topologie réseau |
| ZÉRO credentials | Passportal est le seul endroit où consigner des accès |
| `[À CONFIRMER]` si non vu sur le terrain | Jamais inventer une information d'infrastructure |
| Validation manager avant offboarding user | Protéger le MSP légalement |
| Approbation EA avant révocation accès MSP (client offboard) | Décision d'affaires irréversible |
| Rapport client = langage non-technique | Le client décide, pas son équipe IT interne |

---

## Questions fréquentes

**Q : Quelle différence avec IT-OnboardingMaster (legacy) ?**
IT-OnOffBoarder remplace et étend IT-OnboardingMaster. Il couvre les 4 scénarios (onboard/offboard × client/employé), alors que l'ancien agent couvrait seulement l'onboarding client. Utiliser IT-OnOffBoarder pour tout nouveau projet.

**Q : DOC_PLATFORM — je dois le déclarer à chaque session ?**
Non. Une fois déclaré lors du `/autodiscovery` ou `/doc-output`, l'agent mémorise la plateforme pour toute la session. Idéal : le déclarer dès le début de l'onboarding d'un nouveau client.

**Q : Les scripts S-01 à S-12 sont-ils prêts à coller dans le RMM ?**
Oui. Le prompt contient le code PowerShell complet pour S-01, S-02, S-03, S-05, S-07 et S-10. Pour les autres (S-04, S-06, S-08, S-09, S-11, S-12), l'agent décrit la commande — tu les adaptes selon ton RMM.

**Q : Que faire si une infrastructure critique est découverte lors de l'analyse ?**
L'agent escalade automatiquement selon la situation : faille sécurité → @IT-SecurityMaster (immédiat), backup absent → @IT-BackupDRMaster (< 24h), réseau complexe → @IT-NetworkMaster.

**Q : Le client refuse certaines phases de mise à niveau (/upgrade) — peut-on continuer vers le SOC ?**
Oui, mais le refus est documenté dans le rapport de clôture. Le technicien responsable documente la décision du client dans CW. L'agent génère une note de décharge si nécessaire.

**Q : Comment gérer un offboarding client difficile (désaccord sur les licences) ?**
Suivre la checklist Phase C (transfert licences) étape par étape. Tout désaccord est documenté dans CW et remonté à EA. Ne jamais révoquer des licences en litige sans accord écrit.

---

*GUIDE_UTILISATION — IT-OnOffBoarder v1.0 — MSP Intelligence AI — 2026-05-18*
