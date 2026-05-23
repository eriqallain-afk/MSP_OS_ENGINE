# Template — /escalade-ventes

> Ce template définit la commande `/escalade-ventes` à intégrer dans les 10 agents terrain autorisés.
> **STATUT : A INTEGRER** — Intégration dans les prompts agents après activation EA du MODULE_PROJETS.

---

## Commande : /escalade-ventes

### Description (à ajouter dans le tableau Commandes de chaque agent)

| Commande | Description |
|---|---|
| `/escalade-ventes` | Escalader une opportunité de projet vers le pipeline /ventes/ |

---

## Comportement attendu — /escalade-ventes

Quand un technicien ou un agent détecte un besoin de projet chez un client (infrastructure, migration, sécurité, cloud, VoIP, etc.) qui dépasse le cadre du support courant :

1. Demander les informations manquantes si nécessaire
2. Créer le fichier `ventes/opportunities/OPP-{CLIENT}-{DATE}.yaml` selon le schéma ci-dessous
3. Confirmer l'escalade au technicien avec le numéro d'opportunité créé

---

## Schema fichier — /ventes/opportunities/OPP-{CLIENT}-{DATE}.yaml

```yaml
schema_version: "1.0"
opp_id: "OPP-{CLIENT}-{YYYYMMDD}"
date_detection: "{YYYY-MM-DD}"
agent_source: "{ID de l'agent qui escalade}"
technicien: "[À VALIDER]"

client:
  nom: "{Nom du client}"
  contact: "[À VALIDER]"

projet:
  titre: "{Titre court du projet}"
  categorie: "{migration | infrastructure | securite | cloud | voip | backup | reseau | autre}"
  description: >
    {Description du besoin détecté — contexte, déclencheur, urgence perçue}
  urgence: "{faible | modérée | haute | critique}"

lacunes_detectees:
  - "{Lacune 1 identifiée}"
  - "{Lacune 2 identifiée}"

risques_si_non_adresse:
  - "{Risque 1}"

source_detection:
  type: "{ticket | intervention | onboarding | audit | demande_client}"
  reference: "{Numéro ticket CW ou référence}"

statut: "nouveau"
assigne_a: "IT-ProjetSOW"
```

---

## Notes d'intégration par agent

- **IT-FrontLine** : Détecter lors du triage initial — projets > 2h ou hors support standard
- **IT-Assistant-N2 / N3** : Détecter lors de l'analyse — dégradation infrastructure, dette technique
- **IT-SysAdmin** : Détecter lors d'audits — lacunes systèmes, end-of-life, migrations requises
- **IT-MaintenanceMaster** : Détecter lors de patching — infrastructure obsolète, upgrades majeurs
- **IT-OnOffBoarder** : Systématique — les lacunes `/gap` deviennent des opportunités ventes
- **IT-NetworkMaster** : Détecter lors d'interventions réseau — redesign, VLAN, SD-WAN
- **IT-SecurityMaster** : Détecter lors d'audits sécurité — remédiation, compliance, EDR
- **IT-BackupDRMaster** : Détecter lors de validations backup — PRA manquant, RTO/RPO non conformes
- **IT-CloudMaster** : Détecter lors de provisioning — migration cloud, M365, Azure

---

## Agents autorisés à utiliser /escalade-ventes

```
IT-FrontLine
IT-Assistant-N2
IT-Assistant-N3
IT-SysAdmin
IT-MaintenanceMaster
IT-OnOffBoarder
IT-NetworkMaster
IT-SecurityMaster
IT-BackupDRMaster
IT-CloudMaster
```

> Tout autre agent doit escalader vers l'un des agents ci-dessus plutôt qu'écrire directement dans /ventes/.
