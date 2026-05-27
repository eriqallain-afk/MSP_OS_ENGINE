# RÉFÉRENCE COMPLÈTE DES COMMANDES — Agents IT MSP Intelligence
**ID :** AGENT_COMMAND_REFERENCE_V1
**Version :** 1.0 | **Date :** 2026-05-14
**Couverture :** 27 agents · 4 tiers commerciaux
**Usage :** Référence rapide — toutes les commandes de tous les agents sur une page

---

## Comment utiliser ce document

1. Identifier le tier de ton abonnement (Starter / Pro / MSP Suite / Enterprise)
2. Trouver l'agent approprié selon la situation
3. Utiliser la commande correspondante dans le chat de l'agent
4. Consulter le booklet détaillé pour les exemples et règles : `AGENT_BOOK_[Tier]_V1.md`

> **Rappel clé :** Tous les agents chargent `/runbook` depuis GitHub et génèrent `/close` pour la clôture CW. Ces commandes sont universelles.

---

## TIER STARTER

### IT-FrontLine — Réception et triage N1/N2

| Commande | Description | Déclencheur |
|---|---|---|
| `/appel` | Script d'accueil + identification caller | Appel entrant |
| `/ticket #XXXXX` | Traitement billet N2 avec plan immédiat | Billet MSPBOT reçu |
| `/triage` | Note CW de triage avant transfert | Avant toute escalade |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Besoin de procédure |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-Assistant-N2 — Copilote support N1/N2 (client en ligne)

| Commande | Description | Déclencheur |
|---|---|---|
| `/start [#billet]` | Initialiser intervention : triage + plan | Début de billet |
| `/guide [étape ou sujet]` | Étapes numérotées détaillées | Besoin procédure live |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-TicketScribe — Scribe CW (livrables et documentation)

| Commande | Description | Déclencheur |
|---|---|---|
| `/note [contexte]` | CW Note Interne technique | Documentation interne |
| `/discussion [contexte]` | CW Discussion client-safe (STAR) | Communication billet |
| `/email [contexte]` | Email client professionnel | Suivi ou clôture par courriel |
| `/edocs [contexte]` | Brief pour IT-ClientDocMaster (fiche Hudu) | Nouvelle config à documenter |
| `/kb` | Brief pour IT-KnowledgeKeeper | Nouveau fix à archiver |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW complet | Fin d'intervention |

---

## TIER PRO

### IT-Assistant-N3 — Copilote N3 (incidents avancés, RCA)

| Commande | Description | Déclencheur |
|---|---|---|
| `/start [#billet]` | Triage N3 + plan d'intervention | Début billet N3 |
| `/script [desc]` | Script PowerShell production-ready | Automatisation requise |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-MaintenanceMaster — Copilote maintenance planifiée

| Commande | Description | Déclencheur |
|---|---|---|
| `/start [#billet]` | Triage + plan + precheck | Début de maintenance |
| `/start_maint` | Pack maintenance : ordre serveurs + snapshots | Maintenance multi-serveurs |
| `/script [desc]` | Script PowerShell production-ready | Automatisation maintenance |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-MonitoringMaster — Analyse alertes RMM et monitoring

| Commande | Description | Déclencheur |
|---|---|---|
| `/alerte [détails]` | Analyse alerte : classification + actions | Alerte RMM reçue |
| `/seuils [type]` | Recommandations seuils KPI | Calibration monitoring |
| `/rapport` | Rapport de santé infrastructure | Revue périodique |
| `/config [actif]` | Config monitoring recommandée | Nouvel actif |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-NOCDispatcher — Dispatch et routing NOC

| Commande | Description | Déclencheur |
|---|---|---|
| `/dispatch [ticket]` | Dispatcher ticket ou alerte RMM | Ticket sans propriétaire |
| `/escalade_sla [ticket]` | Gérer ticket SLA à risque | SLA en dépassement |
| `/handover` | Passation de quart : actifs + alertes | Changement de shift |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-ReportMaster — Rapports MSP (postmortem, mensuel, QBR, sécurité)

| Commande | Description | Déclencheur |
|---|---|---|
| `/postmortem [billet]` | Postmortem : 5 Pourquoi + MTTD/MTTR | Après P1/P2 résolu |
| `/mensuel [mois]` | Rapport mensuel MSP | Fin de mois |
| `/qbr [trimestre]` | QBR trimestriel : performance + roadmap | Réunion trimestrielle |
| `/securite [période]` | Rapport sécurité mensuel ou post-incident | Revue sécurité |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-NetworkMaster — Réseau (LAN/WAN/WiFi, firewall, VPN, VLAN)

| Commande | Description | Déclencheur |
|---|---|---|
| `/diag [symptôme]` | Diagnostic réseau : LAN/WAN/WiFi | Problème connectivité |
| `/firewall [marque]` | Config/diagnostic firewall | Intervention firewall |
| `/vpn [symptôme]` | Diagnostic VPN : SSL/IPSec/L2TP | VPN down ou lent |
| `/vlan [contexte]` | Configuration/segmentation VLAN | Projet réseau |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-CloudMaster — Cloud (M365, Entra ID, Intune, Azure)

| Commande | Description | Déclencheur |
|---|---|---|
| `/exchange [symptôme]` | Diagnostic Exchange Online | Problème courriel |
| `/entraid [symptôme]` | Entra ID / Azure AD / MFA | Compte ou authentification |
| `/teams [symptôme]` | Teams / SharePoint / OneDrive | Collaboration cloud |
| `/intune [symptôme]` | Intune : conformité, wipe, politiques | Gestion appareils |
| `/keepit` | Vérification backup Keepit M365 | Audit sauvegarde M365 |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-BackupDRMaster — Sauvegarde et reprise (Veeam, Datto, Keepit, DR)

| Commande | Description | Déclencheur |
|---|---|---|
| `/triage [job]` | Analyse job Veeam/Datto/Keepit en échec | Job sauvegarde échoué |
| `/restore [contexte]` | Restauration guidée fichier ou VM | Demande de restauration |
| `/dr [client]` | Plan DR : test ou activation | Test DR ou sinistre |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-SecurityMaster — Cybersécurité (EDR/SIEM, IR, audit, rapports)

| Commande | Description | Déclencheur |
|---|---|---|
| `/triage [alerte]` | Triage EDR/SIEM : classification + IOC + confinement | Alerte sécurité reçue |
| `/ir [phase]` | Incident Response : ID/Contain/Eradicate/Recover | IR en cours |
| `/audit` | Audit posture sécurité (CIS Controls / NIST CSF) | Revue sécurité planifiée |
| `/rapport [période]` | Rapport sécurité mensuel ou post-incident | Rapport sécurité |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

---

## TIER MSP SUITE

### IT-AssetMaster — Actifs, EOL/EOS, licences (CMDB CW)

| Commande | Description | Déclencheur |
|---|---|---|
| `/inventaire [client]` | Audit inventaire matériel et logiciel | Audit client |
| `/eol [client]` | Rapport EOL/EOS équipements | Revue fin de vie |
| `/licences [client]` | Rapport conformité licences | Audit licences |
| `/audit [client]` | Audit CMDB complet : conformité + gaps | Revue globale |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-ClientDocMaster — Documentation client Hudu (fiches par objet)

| Commande | Description | Déclencheur |
|---|---|---|
| `/analyse [texte]` | Conversation brute → fiches Hudu | Dépouillement intervention |
| `/brief [texte]` | Brief structuré → fiche Hudu | Brief TicketScribe reçu |
| `/hyperviseur [contexte]` | Fiche hyperviseur (Hyper-V/VMware/XCP-ng) | Doc hyperviseur |
| `/nas [contexte]` | Fiche NAS | Doc NAS |
| `/audit [client]` | Audit documentation Hudu client | Vérification doc |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-KnowledgeKeeper — Base de connaissances (KB, runbooks, SOPs)

| Commande | Description | Déclencheur |
|---|---|---|
| `/kb [brief]` | Article KB depuis brief ou notes CW | Incident résolu → KB |
| `/runbook [sujet]` | Créer runbook de procédure | Nouvelle procédure |
| `/sop [sujet]` | Créer SOP structurée | Nouveau processus |
| `/index` | Mettre à jour l'index KB | Après création article |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-SysAdmin — Administrateur système senior polyvalent N2/N3

| Commande | Description | Déclencheur |
|---|---|---|
| `/start [#billet]` | Triage + plan d'intervention | Début de billet |
| `/start_maint` | Pack maintenance : ordre serveurs + snapshots | Maintenance planifiée |
| `/script [desc]` | Script PowerShell production-ready | Automatisation |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-ScriptMaster — Scripts PowerShell/Bash production-ready

| Commande | Description | Déclencheur |
|---|---|---|
| `/script [description]` | Générer script PS/Bash production-ready | Nouveau script |
| `/audit [script]` | Audit qualité + sécurité + RMM | Script existant à valider |
| `/lib [catégorie]` | Extraire snippets bibliothèque MSP | Réutilisation |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-Commandare-Infra — Commandement incidents infrastructure P1/P2

| Commande | Description | Déclencheur |
|---|---|---|
| `/triage [incident]` | Analyse : domaine + sévérité + plan + spécialiste | Incident infra déclaré |
| `/escalade [domaine]` | Bloc CW de transfert structuré | Escalade vers spécialiste |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-Commandare-NOC — Commandement NOC (triage, routing, handover)

| Commande | Description | Déclencheur |
|---|---|---|
| `/triage [alerte]` | Classifier + priorité + plan + routing | Alerte NOC reçue |
| `/dispatch [ticket]` | Dispatcher l'incident | Ticket à assigner |
| `/handover` | Passation de quart : tickets actifs | Changement de shift |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-Commandare-OPR — Opérations (DoD, clôture CW, communications)

| Commande | Description | Déclencheur |
|---|---|---|
| `/note [contexte]` | CW Note Interne | Documentation interne |
| `/discussion [contexte]` | CW Discussion STAR client-safe | Communication billet |
| `/email [contexte]` | Email client professionnel | Suivi ou clôture |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Clôture complète avec validation DoD | Fermeture billet |

### IT-Commandare-TECH — Triage technique (N1/N2/N3/SOC routing)

| Commande | Description | Déclencheur |
|---|---|---|
| `/triage [ticket]` | Classifier + priorité + routing N1/N2/N3/SOC | Ticket complexe à router |
| `/soc [alerte]` | Incident sécurité : identification + confinement | Alerte sécurité |
| `/escalade [domaine]` | Bloc CW de transfert structuré | Escalade à documenter |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

---

## TIER ENTERPRISE

### IT-UrgenceMaster — Urgences P1/P2 live (panne, réseau, serveur, RAID)

| Commande | Description | Déclencheur |
|---|---|---|
| `/panne` | Protocole panne électrique HQ complet + notices Teams | Panne électrique site |
| `/urgence [desc]` | Urgence P1/P2 : réseau, serveur, multi-services | P1/P2 active en cours |
| `/retour` | Retour courant : validation GO/NO-GO | Rétablissement courant |
| `/flagup` | Intervention incomplète → documentation passation | Fin de shift P1 non résolu |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'urgence |

### IT-VoIPMaster — VoIP (qualité voix, SIP, QoS, Teams Phone, 3CX)

| Commande | Description | Déclencheur |
|---|---|---|
| `/diag [symptôme]` | Diagnostic voix : causes + checklist + commandes | Problème qualité voix |
| `/design [contexte]` | Design nouvelle solution VoIP | Nouveau déploiement |
| `/qualite` | Analyse qualité : MOS, jitter, packet loss | Mesure qualité appels |
| `/runbook [n°\|sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### IT-TicketOpr — Cycle de vie complet du billet MSP

| Commande | Description | Déclencheur |
|---|---|---|
| `/start [contexte]` | Initialiser le billet : champs de base | Début de billet |
| `/triage` | Catégoriser, prioriser (P1-P4), assigner | Qualification billet |
| `/analyse` | Analyse technique structurée (faits, hypothèses, risques) | Diagnostic à rédiger |
| `/memo [destinataire]` | Mémo interne court | Communication interne rapide |
| `/teams` | Notice Teams client-safe | Mise à jour d'équipe |
| `/rapport-client` | Rapport client sans jargon | Communication direction client |
| `/rapport-coordo` | Rapport opérationnel coordonnateur MSP | Revue coordonnateur |
| `/script-check [script]` | Vérifier script : portée, risques, prérequis, verdict | Avant exécution script |
| `/risques` | Documenter risques, mitigations, risques résiduels | Évaluation avant intervention |
| `/close` | Menu de clôture CW | Fin d'intervention |

---

## RÈGLES UNIVERSELLES — TOUS LES AGENTS

| Règle | Détail |
|---|---|
| **Blocs séparés** | Script `powershell` dans son bloc · Explication en texte · Livrable CW dans bloc `text` |
| **Phrase d'ouverture Discussion** | `Prise en connaissance de la demande et consultation de la documentation.` |
| **Phrase d'ouverture Discussion (2)** | `Connexion au RMM et analyse de l'état global et de la présence d'alerte.` |
| **Jamais dans livrables clients** | IP internes · Credentials · Tokens · Clés API · CVE exploitables · Comptes nominatifs |
| **Reboot documenté** | `shutdown /r /t 0 /c "Billet #XXXXX — [raison]" /d p:4:1` |
| **Snapshot DC** | Interdit → Windows Server Backup uniquement |
| **1 serveur à la fois** | Obligatoire — post-check DC après chaque intervention DC |
| **[À CONFIRMER]** | Pour tout champ inconnu — jamais inventer |
| **Ransomware** | → IT-SecurityMaster immédiat — ne pas toucher au système |
| **Source données** | CW/RMM uniquement — jamais inventer de métriques |

---

## MATRICE D'ESCALADE RAPIDE

| Situation | Agent de premier contact | Escalade si P1/P2 |
|---|---|---|
| Appel entrant / ticket MSPBOT | IT-FrontLine | → IT-UrgenceMaster si P1 |
| Support utilisateur N2 | IT-Assistant-N2 | → IT-Assistant-N3 si hors N2 |
| Incident complexe N3 | IT-Assistant-N3 | → IT-Commandare-Infra si P1/P2 |
| Maintenance / patching | IT-MaintenanceMaster | → IT-Commandare-Infra si incident |
| Alerte RMM | IT-MonitoringMaster → IT-NOCDispatcher | → IT-Commandare-NOC si P1/P2 |
| Réseau down | IT-NetworkMaster | → IT-UrgenceMaster si site down |
| M365 / Azure | IT-CloudMaster | → IT-SecurityMaster si compromis |
| Backup en échec | IT-BackupDRMaster | → IT-Commandare-Infra si P1 |
| Alerte sécurité / EDR | IT-SecurityMaster | → Coordonnateur + SOC si breach |
| Panne électrique / site | IT-UrgenceMaster | → IT-Commandare-Infra + NOC |
| VoIP / qualité voix | IT-VoIPMaster | → IT-NetworkMaster si infra |
| Documentation billet | IT-TicketScribe / IT-TicketOpr | — |
| Fiche Hudu | IT-ClientDocMaster | — |
| Script PS/Bash | IT-ScriptMaster | — |
| KB / runbook | IT-KnowledgeKeeper | — |
| Inventaire / EOL | IT-AssetMaster | — |

---

*AGENT_COMMAND_REFERENCE_V1 — IT MSP Intelligence — 27 agents — 2026-05-14*
