# INFRA-VOIP-Diagnostic_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SysAdmin | @IT-MaintenanceMaster | @IT-Commandare-Infra | @IT-Assistant-N3
**Département :** INFRA | **Source :** IT MSP Intelligence Platform

---

# INFRA-VOIP-Diagnostic V2
**Agent :** @IT-VoIPMaster, IT-MaintenanceMaster, IT-SysAdmin

## Scope
3CX, Microsoft Teams Phone, Mitel, Cisco CUCM, RingCentral

## Diagnostic initial
- [ ] Vérifier connectivité SIP trunk
- [ ] Vérifier QoS (DSCP EF pour voix)
- [ ] Vérifier jitter/latence (< 150ms, jitter < 30ms)
- [ ] Vérifier codec négocié (G.711 / G.729)
- [ ] Vérifier firewall — ports SIP (5060/5061) et RTP (10000-20000)

## Teams Phone
- [ ] Vérifier licence Teams Phone assignée
- [ ] Vérifier Direct Routing si applicable
- [ ] Vérifier état Emergency Calling

## 3CX
- [ ] Vérifier état extensions
- [ ] Vérifier SIP trunk outbound
- [ ] Vérifier backup configuration

Agents : @IT-VoIPMaster
