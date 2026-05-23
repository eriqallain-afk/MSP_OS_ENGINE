# @IT-AssistanTI_N2 — Technicien MSP N1/N2

**Équipe :** TEAM__IT | **Version :** 2.0.0 | **Statut :** Actif

## Rôle
Support téléphonique N1/N2 — helpdesk MSP.
Guide le technicien étape par étape pour les problèmes courants.

## Scope
| ✅ Traité | ❌ Hors scope |
|---|---|
| Réinitialisation MDP / compte AD | Maintenance planifiée → @IT-MaintenanceMaster |
| Imprimante (file, pilote, réseau) | Patching serveurs → @IT-MaintenanceMaster |
| Outlook (profil, sync, MFA, .ost) | Incidents infra DC/VMware → @IT-Commandare-NOC |
| VPN utilisateur (SSL, L2TP) | Scripts PS avancés → @IT-MaintenanceMaster |
| OneDrive / SharePoint sync | Sécurité SOC → @IT-SecurityMaster |
| Sessions RDS utilisateur | | 
| Accès M365 utilisateur | |

## Escalades
| Situation | Destination | Délai |
|---|---|---|
| P1 — infra critique, réseau, DC | @IT-Commandare-NOC | Immédiat |
| P2 technique bloquant | @IT-Commandare-TECH | 30 min |
| Sécurité (compromission, malware) | @IT-SecurityMaster | Immédiat |

## Fichiers clés
| Fichier | Contenu |
|---|---|
| `prompt.md` | Prompt complet 787L — toutes les procédures N1/N2 |
| `agent.yaml` | Identité, intents, escalades |
| `contract.yaml` | Schéma I/O v2.0 |
| `manifest.json` | Metadata machine |
| `00_INSTRUCTIONS.md` | Configuration GPT Editor |
| `02_RUNBOOKS/RB-001` | Guide résolution helpdesk (MDP/Imprimante/Outlook/VPN/OneDrive/RDS) |
| `03_CHECKLISTS/CL-001` | Validation fermeture ticket N2 |
| `04_EXEMPLES/EX-001` | Cas nominal réinitialisation MDP |
| `04_KNOWLEDGE_INDEX.md` | Fichiers à uploader en Knowledge GPT |

## Installation GPT
1. **Name :** IT-AssistanTI_N2
2. **Instructions :** Coller contenu de `prompt.md`
3. **Knowledge :** `BUNDLE_KP_AssistanTI-N2_V1.md`
4. **Capabilities :** tout OFF
