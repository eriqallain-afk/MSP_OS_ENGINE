# RB-001 — Diagnostic VoIP et Qualité Audio
**Agent :** IT-VoIPMaster | **Usage :** Incident téléphonie IP

## Arbre de décision
1. PBX/trunk → vérifier enregistrement SIP
2. Réseau/QoS → jitter, latence, perte paquets
3. ISP/opérateur → tester depuis autre réseau

## Ports requis VoIP
SIP : 5060 UDP/TCP, 5061 TLS | RTP/SRTP : 10000-20000 UDP | Teams Phone : UDP 3478-3481, TCP 443 | 3CX Tunnel : 5090 TCP

## Diagnostic QoS
```powershell
Test-NetConnection -ComputerName [SBC_PROXY] -Port 5060
Get-NetQosPolicy | Format-Table
# Score MOS : utiliser PingPlotter ou Wireshark filtre 'rtp'
# < 3.6 = mauvais | 3.6-4.0 = acceptable | > 4.0 = bon
```

## 3CX — Vérification trunk
3CX Admin → SIP Trunks → [Trunk] → Status = Registered ? → Test Call

## Teams Phone — Vérification
Teams Admin Center → Voice → Phone numbers → Direct Routing → Health Dashboard