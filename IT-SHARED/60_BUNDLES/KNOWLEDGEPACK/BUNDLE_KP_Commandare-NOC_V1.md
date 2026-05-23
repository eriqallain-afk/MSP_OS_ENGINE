# BUNDLE_KP_Commandare-NOC_V1
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Type :** KnowledgePack GPT
**Agent cible :** @IT-Commandare-NOC
**Usage :** Uploader en Knowledge dans le GPT IT-Commandare-NOC
**Contenu :** Triage alertes, corrélation, matrice sévérité NOC, protocoles d'escalade, shift handover, templates comms
**Mis à jour :** 2026-03-28

---

## 1. MATRICE SÉVÉRITÉ NOC

| Sévérité | Critères | SLA réponse | SLA update | Escalade |
|---|---|---|---|---|
| **P1** | Réseau core/site down, WAN principal coupé, VPN critique down, DC inaccessible, panne électrique site, multi-services simultanés (≥ 3 alertes corrélées) | < 5 min | 15 min | IT-UrgenceMaster + superviseur |
| **P2** | WAN redondant down, tunnel VPN instable, backup en échec > 24h, alertes en cascade (< 3), service dégradé multi-users | < 15 min | 30 min | IT-Commandare-NOCDispatcher pour assignation |
| **P3** | VPN user isolé, backup retardé < 24h, alerte seuil réseau non critique, imprimante réseau down | < 1h | 2h | Traitement direct |
| **P4** | Monitoring noise, alerte informationnelle, maintenance planifiée, rapport de santé | < 4h | — | Acquittement + documentation |

---

## 2. PROTOCOLE DE TRIAGE ALERTES

### Étape 1 — Réception et classification (< 2 min)
```
1. Source de l'alerte : RMM (N-able / CW RMM / Auvik) | SIEM | Email | Appel | Ticket CW
2. Client identifié : oui/non → si non, rechercher dans CW par asset
3. Type de domaine :
   - réseau (switch/routeur/firewall/WAN/WiFi)
   - vpn (site-to-site / utilisateur / SSL)
   - backup (Veeam/Datto/KeepIT job en échec)
   - monitoring (seuil dépassé, service down)
   - voip (trunk SIP / PBX / Teams Phone)
   - urgence (multi-services / panne / indisponibilité critique)
4. Sévérité initiale : P1/P2/P3/P4 selon matrice ci-dessus
```

### Étape 2 — Corrélation (< 3 min si P1/P2)
```
RÈGLE : Ne jamais traiter une alerte isolée sans vérifier :
- Y a-t-il d'autres alertes actives pour le même client ?
- Y a-t-il d'autres alertes actives pour le même site ?
- Le même type d'alerte touche-t-il plusieurs clients ?

SI corrélation détectée :
  → Remonter la sévérité d'un niveau
  → Documenter dans result.correlation
  → Mobiliser le Commandare spécialiste (Infra ou UrgenceMaster)

EXEMPLES CONCRETS DE CORRÉLATION :
  - 3 serveurs offline + switch core down = panne réseau site (PAS 3 incidents séparés)
  - Backup Veeam fail + disk full + CPU high = problème stockage (PAS 3 alertes)
  - VPN down + WAN down = panne opérateur (PAS 2 incidents réseau)
  - DNS timeout + AD auth fail + file share down = DC problem (PAS 3 alertes)
```

### Étape 3 — Mobilisation sous-agent

| Domaine détecté | Agent mobilisé | Quand |
|---|---|---|
| Réseau / routage / VPN / firewall | @IT-NetworkMaster | Toujours |
| Backup / DR / jobs en échec | @IT-BackupDRMaster | Toujours |
| Monitoring / seuils / noise | @IT-MonitoringMaster | Toujours |
| VoIP / trunk SIP / PBX / Teams Phone | @IT-VoIPMaster | Toujours |
| Scripts diagnostic / automatisation | @IT-ScriptMaster | Si besoin |
| Serveurs / VMs / Cloud / EntraID | → REDIRIGER vers @IT-Commandare-Infra | Hors périmètre NOC |
| Sécurité active (breach, malware) | → REDIRIGER vers @IT-SecurityMaster | Hors périmètre NOC |
| Support utilisateur N1-N3 | → REDIRIGER vers @IT-Commandare-TECH | Hors périmètre NOC |

---

## 3. SEUILS D'ALERTE STANDARD NOC

| Métrique | Warning | Critical | Action NOC |
|---|---|---|---|
| CPU serveur (avg 15 min) | > 80% | > 95% | Vérifier processus → escalade si persistant |
| RAM serveur | > 85% | > 95% | Identifier consommateur → escalade INFRA |
| Disk libre | < 20% | < 10% | Alerte immédiate → nettoyage ou escalade |
| Latence réseau LAN | > 20 ms | > 100 ms | Vérifier switch/câblage → NetworkMaster |
| Latence WAN | > 50 ms | > 200 ms | Vérifier lien opérateur → NetworkMaster |
| Backup last success | > 24h | > 48h | Alerte → BackupDRMaster |
| Certificats SSL expiry | 30 jours | 7 jours | Planifier renouvellement |
| Patch compliance | < 90% | < 75% | Alerter MaintenanceMaster |
| Device offline (heartbeat) | > 15 min | > 30 min | Vérifier alimentation/réseau |

---

## 4. PROTOCOLE SHIFT HANDOVER (fin de quart)

### Données obligatoires à transmettre
```yaml
handover:
  date: YYYY-MM-DD
  quart_sortant: "HH:MM - HH:MM (Nom)"
  quart_entrant: "HH:MM - HH:MM (Nom)"

  incidents_actifs:
    - billet: "#TXXXXXXX"
      client: "NomClient"
      sévérité: P1|P2
      statut: "en investigation | en attente | escaladé"
      prochaine_action: "description"
      eta: "HH:MM"

  alertes_non_résolues:
    - source: "RMM|SIEM|Auvik"
      asset: "nom"
      description: "description"
      depuis: "HH:MM"

  maintenances_planifiées:
    - client: "NomClient"
      fenêtre: "JJ/MM HH:MM-HH:MM"
      description: "description"

  notes_quart:
    - "Toute information pertinente pour le quart suivant"
```

### Règles de handover
- Ne JAMAIS terminer un quart avec un P1 actif sans validation superviseur
- P2 actif : le quart sortant doit avoir communiqué un statut au client dans les 30 dernières minutes
- Documenter TOUT — le quart entrant ne doit rien découvrir par surprise

---

## 5. TEMPLATES COMMUNICATIONS NOC

### Notice Teams — Incident en cours
```
🔴 [P1] | Client : [NOM] | [TYPE INCIDENT]
Billet : #TXXXXXXX
Statut : EN INVESTIGATION
Impact : [description impact]
Équipe : [nom du technicien]
Prochaine MAJ : [HH:MM]
```

### Notice Teams — Résolu
```
✅ [P1] RÉSOLU | Client : [NOM] | [TYPE INCIDENT]
Billet : #TXXXXXXX
Résolution : [description 1 ligne]
Durée : [X]h[XX]min
```

### Notice Teams — Escalade
```
⬆️ ESCALADE [P1→P1] | Client : [NOM]
Billet : #TXXXXXXX
De : @IT-Commandare-NOC
Vers : @IT-[Agent cible]
Raison : [pourquoi l'escalade]
Contexte : [résumé 2 lignes max]
```

### Email client — Incident en cours (template OPR)
```
Objet : [INCIDENT] Intervention en cours — [Description courte]

Bonjour,

Nous avons détecté un problème affectant [service/système impacté].
Notre équipe technique est mobilisée et travaille activement à la résolution.

Impact actuel : [description fonctionnelle, sans jargon technique]
Prochaine mise à jour : dans [X] minutes.

Nous vous tiendrons informé de l'évolution.
Cordialement,
[Nom] — Équipe NOC
```

---

## 6. ROUTING PAR DOMAINE — AIDE-MÉMOIRE

### Réseau
```
Switch down         → IT-NetworkMaster (diagnostic port/VLAN/STP)
Firewall alertes    → IT-NetworkMaster (WatchGuard/Fortinet/SonicWall)
WiFi AP offline     → IT-NetworkMaster (UniFi/Meraki)
WAN lent/down       → IT-NetworkMaster (traceroute, opérateur)
BGP/OSPF flap       → IT-NetworkMaster (routing)
```

### VPN
```
Site-to-site down   → IT-NetworkMaster (tunnel IPSec/IKE)
VPN user SSL/L2TP   → IT-NetworkMaster (config client/serveur)
Split tunnel issue  → IT-NetworkMaster (routes/ACL)
```

### Backup
```
Job Veeam en échec  → IT-BackupDRMaster (triage Veeam)
Datto backup fail   → IT-BackupDRMaster (triage Datto)
KeepIT M365 fail    → IT-BackupDRMaster (triage KeepIT)
DR test requis      → IT-BackupDRMaster (plan DR)
RPO/RTO compromis   → IT-BackupDRMaster + escalade P2
```

### VoIP
```
Trunk SIP down      → IT-VoIPMaster (diagnostic trunk)
PBX inaccessible    → IT-VoIPMaster (3CX/FreePBX/Teams)
Qualité appel       → IT-VoIPMaster + IT-NetworkMaster (QoS)
Teams Phone issue   → IT-VoIPMaster (config Teams)
```

### Monitoring
```
Alerte noise        → IT-MonitoringMaster (ajustement seuils)
Faux positif        → IT-MonitoringMaster (exclusion/tuning)
Gap monitoring      → IT-MonitoringMaster (couverture)
Rapport santé       → IT-MonitoringMaster (rapport mensuel)
```

---

## 7. ANTI-PATTERNS NOC (erreurs à éviter)

```
❌ Traiter 3 alertes séparément sans vérifier si elles sont corrélées
❌ Escalader un P1 sans notice Teams préalable
❌ Clôturer un P1/P2 sans validation fonctionnelle avec le client
❌ Modifier une config firewall/switch sans snapshot/backup préalable
❌ Ignorer une alerte "informationnelle" qui revient 5 fois en 1h (pattern = P2)
❌ Terminer un quart sans handover documenté
❌ Envoyer un email client avec des IPs, noms de serveurs ou jargon technique
❌ Acquitter une alerte RMM sans ouvrir de billet CW si action requise
```

---

*BUNDLE_KP_Commandare-NOC_V1 — Version 1.0 — 2026-03-28*
