# BUNDLE_KP_VoIPMaster_V1
**Agent :** @IT-VoIPMaster | **Mis à jour :** 2026-03-29 | IT-MaintenanceMaster | IT-SysAdmin

## ARBRE DIAGNOSTIC VOIX
```
Problème signalé
├─ Aucun appel possible (entrant+sortant) → Trunk SIP down
│  ├─ Vérifier enregistrement PBX → provider
│  ├─ Vérifier ports SIP (5060 UDP/TCP, 5061 TLS)
│  └─ Vérifier NAT/firewall pour SIP ALG (désactiver si activé)
│
├─ Appels sortants KO, entrants OK → Route sortante PBX
│  ├─ Vérifier outbound rules
│  └─ Vérifier codec matching
│
├─ Qualité dégradée (écho, coupures, robot) → QoS/réseau
│  ├─ Jitter > 30ms → problème réseau
│  ├─ Packet loss > 1% → problème réseau
│  └─ Latence > 150ms → problème WAN
│
└─ Un poste spécifique → Config locale
   ├─ Vérifier enregistrement du poste
   ├─ Vérifier VLAN voix
   └─ Vérifier alimentation PoE
```

## PORTS ET PROTOCOLES
| Protocole | Port | Usage |
|---|---|---|
| SIP | 5060 UDP/TCP | Signalisation (non chiffré) |
| SIP TLS | 5061 TCP | Signalisation chiffré |
| RTP | 10000-20000 UDP | Média voix |
| SRTP | 10000-20000 UDP | Média voix chiffré |
| H.323 | 1720 TCP | Legacy signalisation |

## CODECS RÉFÉRENCE
| Codec | Bande passante | Qualité | Usage |
|---|---|---|---|
| G.711 | 87 kbps | Excellente | LAN, trunk local |
| G.722 | 87 kbps | HD Voice | Recommandé si supporté |
| G.729 | 32 kbps | Bonne | WAN, économie bande |
| Opus | Variable | Excellente | Teams, WebRTC |

## PBX COURANTS MSP
| PBX | Accès admin | Notes |
|---|---|---|
| 3CX | https://[ip]:5001 | Backup config avant modif |
| FreePBX | https://[ip] | Appliquer config après modif |
| Teams Phone | admin.teams.microsoft.com | Policies + Auto-attendants |

## ESCALADES
| Vers | Quand |
|---|---|
| @IT-NetworkMaster | Problème QoS, VLAN voix, firewall SIP |
| @IT-CloudMaster | Teams Phone, trunk SIP Microsoft |
| @IT-Commandare-Infra | PBX serveur VM/physique down |

---
*BUNDLE_KP_VoIPMaster_V1 — Version 1.0*
