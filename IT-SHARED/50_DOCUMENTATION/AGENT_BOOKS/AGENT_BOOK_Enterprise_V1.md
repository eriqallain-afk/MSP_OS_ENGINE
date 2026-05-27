# AGENT BOOK — Tier Enterprise
**ID :** AGENT_BOOK_Enterprise_V1
**Version :** 1.0 | **Date :** 2026-05-14
**Agents couverts :** IT-UrgenceMaster · IT-VoIPMaster · IT-TicketOpr · IT-OPS-RouterIA · IT-OPS-PlaybookRunner · IT-OPS-DossierIA

---

## Ce tier comprend

Le tier Enterprise couvre les urgences P1/P2 en live, la téléphonie VoIP, la gestion complète du cycle de vie des billets (TicketOpsAI), et l'infrastructure d'orchestration interne (RouterIA, PlaybookRunner, DossierIA). Ce dernier groupe est la couche d'automatisation sous-jacente du système — il n'est pas utilisé directement par les techniciens.

| Agent | Rôle | Audience |
|---|---|---|
| IT-UrgenceMaster | Copilote urgences P1/P2 en live | Technicien d'urgence / On-call |
| IT-VoIPMaster | Expert VoIP : voix, qualité, SIP, QoS | Spécialiste VoIP / Réseau |
| IT-TicketOpr | Cycle de vie complet du billet MSP | Tous les techniciens |
| IT-OPS-RouterIA | Moteur de routing interne (YAML) | Infrastructure IA interne |
| IT-OPS-PlaybookRunner | Moteur d'exécution de playbooks (YAML) | Infrastructure IA interne |
| IT-OPS-DossierIA | Hub mémoire d'exécution (YAML) | Infrastructure IA interne |

---

## IT-UrgenceMaster

> **Rôle :** Copilote P1/P2 en live. Guidage complet de l'alerte à la clôture : panne électrique, réseau down, serveur critique, hyperviseur, RAID, multi-services impactés.

**Audience :** Technicien d'urgence, on-call, premier répondant en P1.

**Déclencheur typique :** Panne électrique site, réseau complètement down, serveur/hyperviseur critique, multiple services impactés simultanément.

### Capacités principales
- Protocole panne électrique HQ complet (séquence détaillée)
- Urgence P1/P2 : réseau, serveur, multi-services — diagnostic étape par étape
- Retour courant : validation GO/NO-GO avant redémarrage des services
- Passation d'urgence (FlagUp) : documentation complète pour passation
- Chargement automatique de runbooks selon le contexte détecté
- 3 notifications P1 générées immédiatement et mot pour mot :
  1. Notice Teams NOC : `🔴 P1 — Panne en cours — [CLIENT] (Ticket #[XXXXX])`
  2. Escalade NOC (message direct)
  3. Notification coordonnateurs (board client + coordonnateur urgences)
- RAID/ESXi/Hyper-V : couverture complète
- Ransomware → IT-SecurityMaster immédiat (ne pas toucher au système)

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/panne` | Protocole panne électrique HQ complet + notices Teams | Panne électrique site |
| `/urgence [desc]` | Urgence P1/P2 : réseau, serveur, multi-services | Urgence P1/P2 active |
| `/retour` | Retour courant/services : validation GO/NO-GO | Après rétablissement courant |
| `/flagup` | Diagnostic complet, intervention incomplète → passation | Fin de shift avec P1 non résolu |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'urgence |

### Chargement automatique de runbooks (intents)

| Contexte détecté | Runbook chargé |
|---|---|
| Panne électrique, retour courant | `MAINT-SRV-PostShutdown_Electrical_V2.md` |
| P1/P2, incident command | `NOC-OPS-IncidentCommand_V2.md` |
| VMware, ESXi, RAID | `INFRA-SRV-VMware_Operations_V2.md` |
| Hyper-V, VM offline | `INFRA-SRV-HyperV_Operations_V2.md` |
| DC, Active Directory | `INFRA-AD-DC_Operations_V3.md` |
| Veeam, Datto, backup | `INFRA-BACKUP-Veeam_Operations_V2.md` |
| Ransomware, breach | `SEC-SECU-AlertResponse_V2.md` |

### Sorties CW
- Notice Teams P1 (3 variantes : début / résolu / maintenance)
- Message d'escalade NOC
- Notification coordonnateurs (mot pour mot, prêt à coller)
- FlagUp : documentation de passation complète
- Clôture CW avec T2 (STAR) + T3

### Règles critiques
- **3 notifications P1 immédiates** — sans attendre
- **Lecture seule d'abord** — prouver avant d'agir
- **1 serveur à la fois** — post-check DC obligatoire
- **Ransomware** → IT-SecurityMaster, **ne pas toucher au système**
- **Blocs séparés obligatoires** : script `powershell`, explication texte, livrable CW `text`
- **Générer le contenu** — pas seulement décrire l'étape (notices mot pour mot)

### 🔧 Pistes d'amélioration
- Ajouter `/multi [sites]` : protocole panne multi-sites avec priorisation par criticité
- Ajouter `/upscheck [client]` : validation UPS après panne (runtime restant, tests de charge)
- Ajouter une commande `/comm [étape]` pour générer automatiquement la mise à jour de statut toutes les 30 min en P1

---

## IT-VoIPMaster

> **Rôle :** Expert VoIP. Diagnostics qualité voix, design de solutions, configuration QoS, gestion des trunks SIP. Couverture Teams Phone, 3CX, Mitel, Cisco.

**Audience :** Spécialiste VoIP, ingénieurs réseau avec téléphonie.

**Déclencheur typique :** Problème qualité voix, trunk SIP instable, déploiement nouvelle solution téléphonique, analyse MOS/jitter.

### Capacités principales
- Diagnostic qualité voix (symptôme → causes → checklist → commandes)
- Design de solution VoIP nouvelle installation
- Analyse qualité : MOS, jitter, packet loss
- Configuration QoS (priorisation trafic voix)
- Trunks SIP : configuration et validation
- Expertise : Teams Phone, 3CX, Mitel, Cisco PBX
- Validation QoS obligatoire avant tout changement sur trunk SIP
- Impact firewall/réseau sur la voix
- Jamais couper le service téléphonique sans plan de contournement

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/diag [symptôme]` | Diagnostic voix : causes + checklist + commandes | Problème qualité voix |
| `/design [contexte]` | Design nouvelle solution VoIP | Nouveau déploiement |
| `/qualite` | Analyse qualité : MOS, jitter, packet loss | Mesure qualité appels |
| `/runbook [n° ou sujet]` | Charger un runbook GitHub | Procédure spécifique |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Rapport de diagnostic voix (causes, checklist, commandes)
- Design de solution VoIP
- Rapport de métriques qualité (MOS, jitter, packet loss)
- Guide de configuration QoS
- Note interne + Discussion CW

### Règles critiques
- **Jamais couper le service téléphonique** sans plan de contournement validé
- **Valider QoS avant tout changement SIP trunk**
- Notification client obligatoire avant restart pare-feu (impact WAN)
- Escalade IT-NetworkMaster si problème réseau sous-jacent

### 🔧 Pistes d'amélioration
- Ajouter `/baseline [client]` : capture des métriques qualité de référence (MOS/jitter/perte) pour comparaison future
- Ajouter `/sip-trace` : guide d'analyse de trace SIP avec outils (Wireshark, PCAP, 3CX logs)
- Ajouter checklist de validation post-migration téléphonique (Teams Phone ou 3CX)

---

## IT-TicketOpr

> **Rôle :** Agent MSP du cycle de vie complet du billet. Du premier contact à la clôture : triage, analyse technique, livrables CW, validation de scripts, évaluation des risques, rapports.

**Audience :** Tous les techniciens — agent polyvalent pour la gestion complète d'un billet MSP.

**Déclencheur typique :** Billet à structurer, analyse technique à rédiger, communication client à préparer, script à valider, risques à documenter.

### Capacités principales
- Triage complet : catégorie, priorité (P1-P4), impact, urgence, assignation
- Analyse technique structurée (faits, hypothèses, risques, prochaines étapes)
- Note interne CW, Discussion client-safe, Email, Notice Teams, Mémo
- Rapports : client (sans jargon) et coordonnateur MSP
- Validation de script avant exécution (portée, risques, prérequis, rollback, verdict)
- Évaluation des risques avec mitigations et risques résiduels
- Escalade vers agents spécialisés (N2/N3/SysAdmin/MaintenanceMaster)
- `[À CONFIRMER]` pour tout champ inconnu — zéro invention

### Définitions priorité

| Priorité | Description |
|---|---|
| P1 — Critique | Service critique arrêté, sécurité compromise, perte données, multi-utilisateurs ou production majeure |
| P2 — Haute | Dégradation notable ou risque important avec contournement possible |
| P3 — Normale | Incident limité ou demande courante |
| P4 — Faible | Question, amélioration, demande faible urgence |

### Commandes

| Commande | Description | Quand l'utiliser |
|---|---|---|
| `/start [contexte]` | Initialiser le billet : collecter champs de base | Début de billet |
| `/triage` | Catégoriser, prioriser, évaluer impact/urgence, assignation | Qualification billet |
| `/analyse` | Analyse technique structurée | Diagnostic à documenter |
| `/memo [destinataire]` | Mémo interne court | Communication interne rapide |
| `/teams` | Notice Teams client-safe | Mise à jour d'équipe |
| `/rapport-client` | Rapport accessible, sans jargon | Communication direction client |
| `/rapport-coordo` | Rapport opérationnel coordonnateur MSP | Revue coordonnateur |
| `/script-check [script]` | Vérifier portée, risques, prérequis, rollback, verdict | Avant exécution script |
| `/risques` | Documenter risques, mitigations, risques résiduels | Évaluation avant intervention |
| `/close` | Menu de clôture CW | Fin d'intervention |

### Sorties CW
- Note interne (technique, factuelle)
- Discussion (client-safe, structurée)
- Email client professionnel
- Notice Teams
- Mémo interne
- Rapport client (sans jargon)
- Rapport coordonnateur
- Analyse technique avec risques
- Verdict script-check (Go/No-Go)

### Escalades autorisées

| Situation | Vers |
|---|---|
| Helpdesk, Outlook, imprimantes, VPN utilisateur | IT-Assistant-N2 |
| Incident complexe, panne récurrente, multi-systèmes | IT-Assistant-N3 |
| Serveur, AD, M365 admin, DNS/DHCP, SQL | IT-SysAdmin |
| Patching, maintenance planifiée, reboots | IT-MaintenanceMaster |

### 🔧 Pistes d'amélioration
- Ajouter `/csat [billet]` : demande de satisfaction client (CSAT) automatisée après clôture
- Ajouter `/kb-check` : vérifier si un article KB existe avant d'analyser (éviter redondance)
- Ajouter scoring automatique de qualité de billet en fin de clôture (complétude, communication, délai)

---

## IT-OPS-RouterIA *(Usage interne — non destiné aux techniciens)*

> **Rôle :** Moteur de routing interne. Détecte l'intent des requêtes et route vers l'agent ou le playbook approprié via les fichiers YAML de configuration. Sortie YAML uniquement.

**Audience :** Couche d'orchestration interne — pas d'usage direct par les techniciens.

### Capacités principales
- Extraction d'intent (mots-clés, verbes, domaines, patterns)
- Scoring de confiance 0.0–1.0 par route candidate
- Routing haute/moyenne/faible confiance avec fallback
- Validation disponibilité agent/playbook
- Anonymisation des données sensibles
- Maximum 1 question de clarification par requête
- Format de sortie strict : YAML uniquement

### Sorties
- Décisions de routing en YAML (pas de sortie CW directe)

### 🔧 Pistes d'amélioration
- Ajouter historique de routing pour améliorer le scoring sur les patterns récurrents
- Ajouter détection des agents en surcharge pour routing alternatif

---

## IT-OPS-PlaybookRunner *(Usage interne — non destiné aux techniciens)*

> **Rôle :** Moteur d'exécution de playbooks YAML. Transforme les playbooks en actions concrètes : initialisation, exécution ordonnée, gestion d'erreurs, livrables finaux.

**Audience :** Couche d'orchestration interne — pas d'usage direct par les techniciens.

### Capacités principales
- Exécution en 5 phases : validation → initialisation → étapes → pause/reprise → finalisation
- Ordre strict des étapes (sauf `parallel: true`)
- Politique d'erreurs : retry (max 3, backoff exponentiel), skip, abort
- Détection agents inactifs/dépréciés (refus)
- Redaction secrets dans logs (`[REDACTED]`)
- Génération run_id : `RUN-YYYYMMDD-XXXXXX`
- Journal d'exécution avec décisions, risques, hypothèses

### Sorties
- Logs d'exécution YAML (pas de sortie CW directe)

---

## IT-OPS-DossierIA *(Usage interne — non destiné aux techniciens)*

> **Rôle :** Hub mémoire d'exécution. Crée et maintient des dossiers d'intervention, archive les inputs/outputs de chaque étape, produit des exports audit-ready, permet la recherche par pertinence.

**Audience :** Couche d'orchestration interne, conformité/audit.

### Capacités principales
- Création de dossiers avec métadonnées (`DOSSIER__YYYY-MM-DD__playbook_id__sujet`)
- Archivage par étape avec inputs/outputs/logs
- Redaction par niveau de sensibilité (haute = tous les secrets masqués)
- Recherche par mots-clés, dates, tags
- Accès cloisonné par niveau de sensibilité
- Jamais inventer des chemins (uniquement chemins réels)
- Escalade si suspicion de fuite de données

### Sorties
- Archives YAML de dossiers (pas de sortie CW directe)

---

## Index des commandes — Tier Enterprise *(agents utilisés par les techniciens)*

| Agent | Commande | Description |
|---|---|---|
| IT-UrgenceMaster | `/panne` | Protocole panne électrique HQ complet |
| IT-UrgenceMaster | `/urgence [desc]` | Urgence P1/P2 : réseau, serveur, multi-services |
| IT-UrgenceMaster | `/retour` | Retour courant : validation GO/NO-GO |
| IT-UrgenceMaster | `/flagup` | Passation d'urgence (intervention incomplète) |
| IT-UrgenceMaster | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-UrgenceMaster | `/close` | Menu de clôture CW |
| IT-VoIPMaster | `/diag [symptôme]` | Diagnostic voix complet |
| IT-VoIPMaster | `/design [contexte]` | Design nouvelle solution VoIP |
| IT-VoIPMaster | `/qualite` | Analyse qualité : MOS, jitter, packet loss |
| IT-VoIPMaster | `/runbook [n°\|sujet]` | Charger un runbook GitHub |
| IT-VoIPMaster | `/close` | Menu de clôture CW |
| IT-TicketOpr | `/start [contexte]` | Initialiser le billet |
| IT-TicketOpr | `/triage` | Catégoriser, prioriser, assigner |
| IT-TicketOpr | `/analyse` | Analyse technique structurée |
| IT-TicketOpr | `/memo [destinataire]` | Mémo interne court |
| IT-TicketOpr | `/teams` | Notice Teams client-safe |
| IT-TicketOpr | `/rapport-client` | Rapport client sans jargon |
| IT-TicketOpr | `/rapport-coordo` | Rapport opérationnel coordonnateur |
| IT-TicketOpr | `/script-check [script]` | Vérifier script avant exécution |
| IT-TicketOpr | `/risques` | Évaluation des risques + mitigations |
| IT-TicketOpr | `/close` | Menu de clôture CW |

---

*AGENT_BOOK_Enterprise_V1 — IT MSP Intelligence — 2026-05-14*
