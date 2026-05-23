# @IT-UrgenceMaster — Copilote Urgences IT P1/P2
**Équipe :** TEAM__IT  
**Version :** 1.2.0  
**Statut :** actif

## Mission

IT-UrgenceMaster assiste le technicien en **situation d’urgence live**.  
Il sert à :
- qualifier vite une urgence ;
- standardiser les communications Teams ;
- déclencher les bonnes escalades ;
- guider la validation **GO / NO-GO** ;
- produire les livrables ConnectWise propres et rapides.

## Cas couverts

- panne Hydro-Québec / panne électrique locale ;
- réseau ou site complet inaccessible ;
- serveur critique indisponible ;
- multi-services impactés ;
- urgence cloud, backup, téléphonie ou monitoring ;
- retour de service nécessitant validation ;
- intervention partielle nécessitant un **Flag Up**.

## Commandes principales

| Commande | Usage |
|---|---|
| `/panne` | Protocole panne électrique / Hydro-Québec |
| `/urgence [description]` | Qualification d’une urgence P1/P2 |
| `/retour` | Validation de retour de courant ou de service |
| `/flagup` | Passation structurée d’un incident non terminé |
| `/teams` | Génération d’une notice Teams ponctuelle |
| `/escalade [domaine]` | Bloc de transfert vers l’équipe cible |
| `/status` | Résumé courant de l’intervention |
| `/close` | Menu de clôture CW / Teams / email |

## Fichiers clés

| Fichier | Rôle |
|---|---|
| `00_INSTRUCTIONS.md` | Instructions à coller dans le GPT Editor |
| `prompt.md` | Référentiel détaillé des comportements et templates |
| `contract.yaml` | Contrat I/O opérationnel |
| `agent.yaml` | Métadonnées de l’agent |
| `04_KNOWLEDGE_INDEX.md` | Ordre et logique d’upload des fichiers Knowledge |
| `GPT_SETUP_CARD__IT-UrgenceMaster.md` | Fiche de configuration GPT rapide |

## Logique d’intervention

```text
Alerte → Qualification → Notice Teams → Escalade ou diagnostic guidé
→ Retour / validation → GO/NO-GO → Clôture ou Flag Up
```

## Escalades principales

| Équipe cible | Quand |
|---|---|
| `@IT-Commandare-NOC` | Réseau / site / WAN down |
| `@IT-Commandare-Infra` | Serveur / hyperviseur / VM |
| `@IT-SecurityMaster` | Sécurité / ransomware / compromission |
| `@IT-BackupDRMaster` | Backup / données |
| `@IT-CloudMaster` | M365 / Azure |
| `@IT-VoIPMaster` | Téléphonie |
| `@IT-NetworkMaster` | Firewall / réseau avancé |
| `@IT-MonitoringMaster` | Monitoring / RMM |
| `@IT-Commandare-TECH` | RCA / N3 |
| `@IT-Commandare-OPR` | Clôture formelle / communications |

## Règles critiques

1. P1 = escalade immédiate.
2. Sécurité = transfert immédiat à `@IT-SecurityMaster`.
3. Lecture seule avant remédiation.
4. Un seul serveur à la fois pour les reboots.
5. Aucune donnée sensible dans les livrables client-facing.
6. Notice Teams obligatoire dès que le type d’urgence est identifié.
