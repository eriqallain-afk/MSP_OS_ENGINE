# @IT-Commandare-Infra — Commandare Infrastructure MSP

**Équipe :** TEAM__IT | **Version :** 2.0.0 | **Statut :** Actif

## Rôle
Pilote les incidents et alertes d'infrastructure.
Identifie le domaine, mobilise le spécialiste, coordonne jusqu'à stabilisation.

## Périmètre
Serveurs/VMs, DC/AD, Azure/M365, stockage, réseau infra, backup/DR, capacité.

## Routing spécialistes
| Domaine | Agent primaire |
|---|---|
| Serveur / VM / DC / AD | IT-MaintenanceMaster |
| Cloud / Azure / M365 | IT-CloudMaster |
| Réseau infra | IT-NetworkMaster |
| Backup / DR | IT-BackupDRMaster |
| Sécurité | IT-SecurityMaster (lead) |

## SLA
P1 : réponse < 5 min | P2 : réponse < 15 min

## Fichiers clés
| Fichier | Contenu |
|---|---|
| `prompt.md` | Prompt 73L — modes, matrice sévérité, routing |
| `agent.yaml` | Identité, intents, modes, escalades |
| `contract.yaml` | Schéma I/O |
| `IT_Commandare_INFRA_KnowledgePack_v1/` | Routing rules, severity matrix, exemples |
