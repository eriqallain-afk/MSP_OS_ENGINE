# OPR-EOL-EOS-RiskRegister_V1
**Version :** V1 | **Statut :** active | **Domaine :** OPR | **Date :** 2026-05-23
**Agents :** @IT-AssetMaster | @IT-SecurityMaster | @IT-Commandare-OPR | @IT-ReportMaster
**Scope :** Registre des risques EOL/EOS — identification, priorisation et suivi des actifs en fin de vie chez les clients MSP

---

## Objectif

Identifier et documenter tous les systèmes d'exploitation, logiciels, matériels et équipements réseau en End of Life (EOL) ou End of Support (EOS) dans l'environnement de chaque client. Prioriser les renouvellements selon le risque, générer les recommandations clients et suivre l'avancement des remplacements.

---

## Définitions

| Terme | Définition |
|---|---|
| **EOL (End of Life)** | Le produit ne reçoit plus aucune mise à jour — ni sécurité, ni fonctionnelle |
| **EOS (End of Support)** | Le fabricant ne fournit plus de support technique |
| **EOM (End of Mainstream)** | Fin du support standard — seul le support étendu (payant) est disponible |
| **Fin de garantie matérielle** | Équipement sans garantie active — remplacement ou contrat de support requis |

---

## Déclencheurs

- Audit CMDB mensuel ou trimestriel (déclenchement depuis OPR-CMDB-Reconciliation)
- Annonce EOL/EOS par un éditeur (Microsoft, Cisco, VMware, etc.)
- Incident de sécurité sur un système potentiellement obsolète
- Renouvellement de cyber-assurance — inventaire EOL requis
- Audit de conformité (Loi 25, PCI, HIPAA) — les systèmes EOL sont un point de non-conformité
- QBR client — section recommandations techniques

---

## Prérequis

- Inventaire CMDB à jour (CW Manage + Hudu + RMM — voir OPR-CMDB-Reconciliation)
- Accès à Hudu pour lecture des actifs et mise à jour des articles
- Accès à CW Manage pour création des opportunités de renouvellement
- Dates EOL/EOS de référence (voir sources ci-dessous)

**Sources de référence EOL/EOS :**
```
https://endoflife.date/                         ← Base de données EOL/EOS tous produits
https://docs.microsoft.com/lifecycle/           ← Microsoft Lifecycle Policy
https://www.cisco.com/c/en/us/support/eos-eol  ← Cisco EOL
https://www.vmware.com/support/policies         ← VMware/Broadcom lifecycle
https://ubuntu.com/about/release-cycle          ← Ubuntu LTS
https://access.redhat.com/support/policy        ← RHEL
```

---

## Procédure

### Étape 1 — Inventaire des actifs avec dates EOL/EOS

**1.1 — Identifier les systèmes d'exploitation**

```powershell
# Exécuter sur chaque machine via RMM ou PSRemoting
param([string[]]$Servers)

foreach ($Server in $Servers) {
    Invoke-Command -ComputerName $Server -ScriptBlock {
        $os = Get-CimInstance Win32_OperatingSystem
        [pscustomobject]@{
            Serveur   = $env:COMPUTERNAME
            OS        = $os.Caption
            Version   = $os.Version
            Build     = $os.BuildNumber
            SP        = $os.ServicePackMajorVersion
            LastBoot  = $os.LastBootUpTime.ToString("yyyy-MM-dd")
        }
    } -ErrorAction SilentlyContinue
}
```

**1.2 — Dates EOL Windows — référence rapide**

| OS | EOL Mainstream | EOL Extended | Action requise |
|---|---|---|---|
| Windows Server 2008 / 2008 R2 | 2015-01-13 | **2020-01-14** | Remplacement urgent |
| Windows Server 2012 / 2012 R2 | 2018-10-09 | **2023-10-10** | Remplacement urgent |
| Windows Server 2016 | 2022-01-11 | 2027-01-12 | En extended support |
| Windows Server 2019 | 2024-01-09 | 2029-01-09 | OK |
| Windows Server 2022 | 2026-10-13 | 2031-10-14 | OK |
| Windows 10 (toutes versions) | 2025-10-14 | **2025-10-14** | Migration W11 urgente |
| Windows 11 22H2 | **2024-10-08** | **2024-10-08** | Mise à jour requise |
| Windows 11 23H2 | 2025-11-11 | 2025-11-11 | Mettre à jour vers 24H2 |

**1.3 — Logiciels critiques à vérifier**

```
□ Serveurs SQL : SQL Server 2012 (EOL 2022), 2014 (EOL 2024), 2016 (EOL 2026)
□ Exchange Server : 2013 (EOL 2023), 2016 (EOL 2025), 2019 (EOL 2025)
□ VMware ESXi : 6.5/6.7 (EOL 2022), 7.0 (EOS 2025)
□ Adobe Acrobat DC : versions > 3 ans sans mise à jour
□ Java Runtime (versions non-LTS)
□ Antivirus / EDR : vérifier fin de contrat de signature
```

**1.4 — Matériel**

```
□ Serveurs : garantie constructeur (Dell ProSupport, HP Care Pack) — chercher dans Hudu
□ Switches / Firewall : date fin de support constructeur (Cisco, Fortinet, SonicWall)
□ Workstations : > 5 ans = recommandation remplacement
□ NAS / Backup appliances : vérifier version firmware et fin de support
```

---

### Étape 2 — Évaluation du risque

**Matrice de risque EOL/EOS :**

| Criticité actif | EOL < 6 mois | EOL passé | EOL passé + vulnérabilité connue |
|---|---|---|---|
| Critique (DC, SQL prod, firewall) | Risque ÉLEVÉ | Risque CRITIQUE | Risque CRITIQUE — action immédiate |
| Important (serveur applicatif, backup) | Risque MOYEN | Risque ÉLEVÉ | Risque CRITIQUE |
| Standard (workstation, imprimante) | Risque FAIBLE | Risque MOYEN | Risque ÉLEVÉ |

**Score de risque à documenter pour chaque actif :**

```
Actif : [NOM]
Client : [NOM CLIENT]
Type : [OS / Logiciel / Matériel]
Version actuelle : [X.X]
Date EOL/EOS : [YYYY-MM-DD]
Criticité : [Critique / Important / Standard]
Vulnérabilité connue : [Oui / Non — CVE si applicable]
Score risque : [Critique / Élevé / Moyen / Faible]
Action recommandée : [Mise à niveau / Remplacement / Isolation / Exception documentée]
ETA recommandée : [YYYY-MM-DD]
```

---

### Étape 3 — Documenter dans le registre EOL

**Créer ou mettre à jour le registre dans Hudu :**

```
Hudu → [Client] → Assets → EOL Risk Register
(Créer l'article s'il n'existe pas — template : EOL Risk Register)

Tableau de registre :
| Actif | Type | Version | Date EOL | Criticité | Risque | Action | Owner | ETA | Statut |
|---|---|---|---|---|---|---|---|---|---|
```

**Mettre à jour dans CW Manage :**
```
CW → Companies → [Client] → Configurations → [Actif]
Champ "End of Life Date" : renseigner la date EOL
Champ "Notes" : documenter le score de risque et l'action recommandée
```

---

### Étape 4 — Générer les recommandations client

**Format de recommandation pour QBR ou rapport mensuel :**

```
RECOMMANDATIONS RENOUVELLEMENT — [CLIENT] — [DATE]
===================================================

CRITIQUE (action dans les 30 jours) :
• [Nom actif] — [Type] — EOL depuis [date] — Risque : exposition aux cybermenaces sans correctifs de sécurité
  Recommandation : Remplacement par [alternative] — Estimation : [coût approximatif]

ÉLEVÉ (action dans les 90 jours) :
• [Nom actif] — [Type] — EOL le [date] — Risque : fin du support constructeur
  Recommandation : Planifier la migration vers [alternative]

MOYEN (planification à 6 mois) :
• [Nom actif] — [Type] — EOL le [date]
  Recommandation : Inclure dans le budget informatique [année]
```

---

### Étape 5 — Créer les opportunités de renouvellement dans CW

```
CW → Companies → [Client] → Opportunities → + Add Opportunity
Champs à remplir :
- Name : "Renouvellement [Actif] — EOL [date]"
- Type : Hardware Upgrade / Software Upgrade / License Renewal
- Probability : 50% (à ajuster selon les discussions)
- Close Date : 30 jours avant EOL
- Notes : lien vers le registre Hudu + score de risque
→ Assigner au gestionnaire de compte
```

---

### Étape 6 — Suivre et mettre à jour

```
□ Révision mensuelle du registre EOL lors du OPR-Monthly-Client-OpsPack
□ Mettre à jour le statut de chaque élément :
   - Planifié : date de remplacement confirmée
   - En cours : migration/remplacement en progression
   - Résolu : actif remplacé ou mis à niveau
   - Exception documentée : délai justifié et approuvé par le client
□ Archiver les actifs remplacés dans Hudu (ne pas supprimer)
```

---

## Livrables attendus

| Livrable | Destination | Fréquence |
|---|---|---|
| Registre EOL mis à jour | Hudu → [Client] | Mensuel ou lors d'un changement |
| Configurations CW mises à jour (champ EOL Date) | CW Manage | À chaque audit |
| Liste de recommandations client-safe | Rapport mensuel / QBR | Mensuel / Trimestriel |
| Opportunités de renouvellement | CW Manage | Dès qu'un risque Élevé ou Critique est détecté |

---

## Critères de clôture (DoD)

- [ ] Tous les systèmes d'exploitation inventoriés avec leurs dates EOL/EOS
- [ ] Tous les logiciels critiques (SQL, Exchange, VMware) vérifiés
- [ ] Matériel sans garantie active identifié
- [ ] Score de risque attribué à chaque actif EOL
- [ ] Registre Hudu créé ou mis à jour
- [ ] Recommandations rédigées en langage client-safe
- [ ] Opportunités CW créées pour les risques Élevés et Critiques
- [ ] Aucun actif EOL critique laissé sans plan d'action ou exception documentée

---

## Escalades

| Situation | Vers | Délai |
|---|---|---|
| OS EOL avec CVE critique active et sans protection | @IT-SecurityMaster | Immédiat — P1 potentiel |
| Firewall / équipement réseau EOL sans remplacement planifié | @IT-NetworkMaster + @IT-Commandare-OPR | 24h |
| Client refuse le remplacement malgré risque critique | @IT-Commandare-OPR — email de recommandation formelle | 48h |
| Renouvellement bloqué par budget client | Gestionnaire de compte — plan de financement | Prochain QBR |

---

## Notes MSP

- **Cyber-assurance :** les assureurs demandent de plus en plus un inventaire EOL — ce registre est un actif de conformité
- **Loi 25 / PCI :** les systèmes EOL sans correctifs de sécurité constituent une non-conformité documentable
- **Règle d'isolation :** si un actif EOL critique ne peut pas être remplacé immédiatement, il doit être isolé réseau (VLAN dédié) et la décision documentée avec signature client
- **Exception documentée :** tout actif EOL sans plan de remplacement doit avoir une exception approuvée par le client avec date de révision
- Intégrer les résultats de ce runbook dans le **OPR-QBR-DataCollection** pour les présentations trimestrielles

---

*OPR-EOL-EOS-RiskRegister_V1 — IT MSP Intelligence Platform — 2026-05-23*
