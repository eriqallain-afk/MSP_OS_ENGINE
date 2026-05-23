# RB-001 — Qualification et Dispatch Ticket/Alerte Entrant
**Agent :** IT-NOCDispatcher | **Mode :** DISPATCH

---

## Questions de qualification (dans l'ordre)

1. Quel est le **symptôme exact** ? (ne pas interpréter)
2. Combien d'**utilisateurs / systèmes** affectés ?
3. **Depuis quand** ? Impact business actif ?
4. Client sous **contrat SLA** actif ?
5. Alerte **RMM confirmée** ou faux positif ?

---

## Arbre de décision priorité

```
Site entier hors ligne → P1 immédiat
Ransomware / breach → P1 + IT-SecurityMaster lead
DC inaccessible → P1 + IT-Commandare-Infra
Réseau critique → P1/P2 + IT-NetworkMaster

Service essentiel dégradé (Exchange, VPN, RDS, backup critique) → P2
Impact < 5 utilisateurs, workaround possible → P3
Demande de service, aucun impact → P4
```

---

## Table de routing par domaine

| Symptôme | Priorité probable | Agent assigné |
|---|---|---|
| CPU/RAM/Disk > seuil (RMM) | P2/P3 | IT-Commandare-NOC |
| Service arrêté (DC, SQL, IIS) | P1/P2 | IT-Commandare-Infra |
| VPN site down | P1/P2 | IT-NetworkMaster |
| Exchange / M365 inaccessible | P2 | IT-CloudMaster |
| Job backup en échec critique | P2 | IT-BackupDRMaster |
| EDR alerte / comportement suspect | P1/P2 | IT-SecurityMaster |
| Problème utilisateur isolé (MDP, imprimante) | P3 | IT-AssistanTI_N2 |
| Diagnostic technique complexe | P2/P3 | IT-AssistanTI_N3 |
| Trunk SIP / VoIP dégradé | P2 | IT-VoIPMaster |
| Fenêtre maintenance planifiée | P4 | IT-MaintenanceMaster |

---

## SLA à calculer et noter dans CW

| Priorité | Réponse | Résolution | Escalade auto |
|---|---|---|---|
| P1 | 15 min | 4h | 30 min → IT-Commandare-NOC |
| P2 | 30 min | 8h | 2h → Senior |
| P3 | 2h | 24h | 4h → N2 |
| P4 | 4h | 72h | 24h → N2 |

---

## Communication client (P1/P2 systématique)

```
Objet : [Incident Sx] — <Service> — <ClientName>
Bonjour,
Nous avons détecté un incident impactant <service> depuis <HH:MM TZ>.
Nos équipes sont mobilisées. Prochaine mise à jour : <HH:MM TZ>.
```
