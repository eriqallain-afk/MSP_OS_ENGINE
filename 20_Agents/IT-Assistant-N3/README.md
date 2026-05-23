# @IT-AssistanTI_N3 — Assistant Technique MSP N1/N2/N3

**Équipe :** TEAM__IT | **Version :** 2.0.0 | **Statut :** Actif

## Rôle
Copilote MSP N1 à N3 pour les billets ConnectWise.
Du triage à la fermeture en une seule conversation.

## Commandes
| Commande | Action |
|---|---|
| `/start` | Triage + plan d'action + checklist + scripts pre-action |
| `/start_maint` | Pack maintenance : patching, ordre serveurs, risques, pre/post |
| `/runbook [sujet]` | veeam \| m365 \| panne \| reseau \| securite \| ad \| rds \| print \| linux |
| `/script [desc]` | Script PowerShell ou Bash production-ready |
| `/close` | CW Discussion + Note Interne + Email + Annonce Teams |
| `/kb` | Brief YAML pour @IT-KnowledgeKeeper |
| `/db` | Commande PowerShell pour MSP-Assistant DB |
| `/status` | Résumé intervention en cours |

## Scope
Windows Server, Active Directory, M365 (Exchange/Teams/SharePoint/OneDrive),
RDS/RemoteApp, File Server, Print Server, Linux,
Réseau (WatchGuard/Fortinet/Cisco/Ubiquiti/MikroTik),
VEEAM, Datto, VMware vSphere, Hyper-V, Sécurité (EDR, incidents), Panne électrique.

## Escalades
| Situation | Agent | Délai |
|---|---|---|
| P1 infra (DC, serveur critique, stockage) | @IT-Commandare-Infra | Immédiat |
| Sécurité (ransomware, breach, EDR) | @IT-SecurityMaster | Immédiat |
| NOC (alertes, corrélation) | @IT-Commandare-NOC | 15 min |
| Réseau complexe | @IT-NetworkMaster | 30 min |
| Backup / DR | @IT-BackupDRMaster | Immédiat |
| Clôture CW formelle | @IT-TicketScribe | À la fermeture |
| Capitalisation KB | @IT-KnowledgeKeeper | Post-clôture |
| Documentation Hudu | @IT-ClientDocMaster | Post-clôture |

## Fichiers clés
| Fichier | Contenu |
|---|---|
| `prompt.md` | Prompt complet 1140L — toutes les commandes et runbooks |
| `agent.yaml` | Identité, intents, commandes, escalades |
| `contract.yaml` | Schéma I/O complet v2.0 |
| `manifest.json` | Metadata machine |
| `00_INSTRUCTIONS.md` | Configuration GPT Editor |
| `04_KNOWLEDGE_INDEX.md` | Fichiers à uploader en Knowledge GPT |
| `GPT_SETUP_CARD__IT-AssistanTI_N3.md` | Guide complet configuration GPT |
| `04_EXEMPLES/EXEMPLE_kb_brief_1683171.yaml` | Exemple réel output /kb |

## Installation GPT
- **Name :** IT-AssistanTI_N3
- **Instructions :** Contenu de `00_INSTRUCTIONS.md`
- **Knowledge :** Voir `04_KNOWLEDGE_INDEX.md` — prompt.md en 1er (obligatoire)
- **Web Search :** Oui (CVE, KB Microsoft, firmware)
- **DALL·E / Code Interpreter :** OFF

## Différence avec IT-AssistanTI_N2
| | IT-AssistanTI_N2 | IT-AssistanTI_N3 |
|---|---|---|
| Niveau | N1/N2 helpdesk téléphonique | N1 à N3 complet |
| Scope | MDP, imprimante, Outlook, VPN user | Tout — serveurs, scripts, runbooks, maintenance |
| Commandes | /start, /close, /escalade | /start, /start_maint, /runbook, /script, /close, /kb, /db |
| Output | Guide étapes simple | Markdown + YAML + scripts PS production-ready |
