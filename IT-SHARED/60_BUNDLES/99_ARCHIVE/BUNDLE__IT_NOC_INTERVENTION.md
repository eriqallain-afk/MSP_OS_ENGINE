# BUNDLE — IT Intervention & NOC MSP
**ID :** BUNDLE__IT_NOC_INTERVENTION  
**Version :** 1.0  
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Agents consommateurs :** IT-Commandare-NOC, IT-Commandare-NOCDispatcher, IT-Commandare-NOC, IT-MSPLiveAssistant, IT-Technicien, IT-InterventionCopilot

---

## 1. CLARIFICATION DES RÔLES — COUCHE INTERVENTION

### Flux intervention standard :

```
TICKET ENTRANT
     │
     ▼
IT-Commandare-NOCDispatcher ─── 1ère réception, qualification, SLA, assignation
     │
     ├─ P3/P4 ──► IT-Technicien ─── diagnostic + préparation POUR COPILOT
     │                    │
     │                    ▼
     │              IT-MSPLiveAssistant ─── LIVE pendant intervention
     │                    │ /close
     │                    ▼
     │              IT-InterventionCopilot ─── closeout CW final
     │
     └─ P1/P2 ──► IT-Commandare-NOC ─── orchestration incident complexe
                        │
                        ▼
                 IT-Commandare-TECH ─── diagnostic technique avancé
                        │
                        ▼
                 IT-[Specialist] ─── résolution domaine expert
                        │
                        ▼
                 IT-MSPLiveAssistant ─── documentation live
                        │ /close
                        ▼
                 IT-TicketScribe ─── fermeture CW formelle
```

### Rôles et distinctions :

| Agent | Usage principal | Ne fait PAS |
|-------|----------------|------------|
| IT-Commandare-NOCDispatcher | Qualifier + assigner tickets | Résoudre techniquement |
| IT-Commandare-NOC | Orchestrer incidents P1/P2 multi-agents | Exécuter en CLI |
| IT-Technicien | Guider diagnostic + préparer handoff | Générer CW_DISCUSSION final |
| IT-MSPLiveAssistant | Assister LIVE + closeout complet | Valider architecture |
| IT-InterventionCopilot | Rédiger closeout CW (si Copilot utilisé) | Diagnostic technique |
| IT-TicketScribe | Documentation CW formelle | Diagnostiquer |

---

## 2. COMMANDES CLÉS IT-MSPLiveAssistant

| Commande | Action | Quand utiliser |
|---------|--------|---------------|
| `/start_maint` | Génère pack maintenance complet | Début fenêtre maintenance |
| `/close` | Génère les 4 livrables (CW note + discussion + email + Teams) | Fin intervention |
| `/status` | Résumé opératoire en cours | Point de contrôle mi-intervention |

---

## 3. STRUCTURE SHIFT HANDOVER NOC

```yaml
# Template Shift Handover — à compléter à chaque changement de quart
shift_handover:
  date: YYYY-MM-DD
  heure_transfert: HH:MM
  technicien_sortant: "[Nom]"
  technicien_entrant: "[Nom]"
  
  tickets_actifs:
    - ticket: "#CW-XXXX"
      client: "[Client]"
      priorité: P1|P2|P3
      statut: "En cours"
      dernière_action: "[Description]"
      prochaine_action: "[Description]"
      
  alertes_monitoring:
    - système: "[Nom]"
      alerte: "[Description]"
      statut: "Surveillé/En attente/Escaladé"
      
  maintenances_planifiées:
    - date_heure: YYYY-MM-DD HH:MM
      description: "[Maintenance]"
      client: "[Client]"
      
  points_attention:
    - "[Point important pour le quart entrant]"
```

---

## 4. PROTOCOLE ESCALADE NOC

### Escalade horizontale (entre agents mêmes niveau) :
- IT-Commandare-NOCDispatcher → IT-Commandare-NOC : si ticket se complexifie → P2+
- IT-Technicien → IT-[Specialist] : si domaine technique spécifique requis

### Escalade verticale (vers senior) :
- Tout agent → IT-Commandare-TECH : si diagnostic technique bloqué
- IT-Commandare-TECH → IT-CTOMaster : si architecture / décision critique
- IT-CTOMaster → IT-DirecteurGeneral : si impact business majeur / client VIP

### Template message d'escalade (dans CW) :
```
[ESCALADE vers @IT-[Agent]]
Raison : [Motif précis]
Contexte : [Résumé situation]
Actions déjà tentées :
  - [Action 1]
  - [Action 2]
État actuel : [Description]
Urgence : P[1/2/3]
```

---

## 5. SEUILS ESCALADE AUTOMATIQUE

| Condition | Action automatique |
|-----------|-------------------|
| P1 non assigné dans 10 min | Alerte IT-Commandare-NOC |
| P1 non résolu dans 2h | Escalade IT-CTOMaster |
| P2 non assigné dans 30 min | Alerte IT-Commandare-NOCDispatcher |
| P3 non répondu dans 4h | Rappel + escalade N2 |
| Ticket rouvert 2x même problème | Créer KB + IT-KnowledgeKeeper |
