# CHECKLIST_SECURITY_Hardening-et-Audit_V1
**Agent :** IT-SecurityMaster, IT-AssistanTI_N3
**Usage :** Audit de sécurité périodique et vérification du hardening
**Mis à jour :** 2026-03-20

---

## IDENTITÉ ET ACCÈS (EntraID / AD)

- [ ] MFA activé pour tous les utilisateurs (minimum tous les admins)
- [ ] Accès conditionnel configuré (bloquer auth legacy, géo-restriction si applicable)
- [ ] Comptes admin dédiés : distinct des comptes utilisateurs quotidiens
- [ ] Comptes inactifs depuis > 90 jours désactivés
- [ ] Revue des membres Domain Admins / Global Administrators (< 5 personnes)
- [ ] Aucun compte de service avec MDP sans expiration non documenté
- [ ] Passportal à jour pour tous les comptes de service

---

## MESSAGERIE ET M365

- [ ] Defender for Office 365 actif (anti-phishing, anti-malware, Safe Links)
- [ ] Authentification basique (Legacy Auth) désactivée
- [ ] Règles de transport suspectes : aucune
- [ ] Transferts automatiques vers l'externe : aucun (ou documentés)
- [ ] Audit log M365 activé (Unified Audit Log)
- [ ] DKIM / DMARC / SPF configurés sur le domaine email
- [ ] Secure Score M365 vérifié : score actuel _______ / recommandé _______

---

## ENDPOINTS ET SERVEURS

- [ ] EDR déployé sur tous les serveurs et postes (SentinelOne / CrowdStrike / Defender XDR)
- [ ] Windows Update : patchs critiques < 30 jours sur tous les serveurs
- [ ] RDP exposé directement sur Internet : aucun (accès via VPN uniquement)
- [ ] Ports non utilisés fermés sur le firewall
- [ ] Comptes administrateurs locaux : mots de passe uniques par machine (LAPS si applicable)
- [ ] Firewall Windows activé sur tous les endpoints

---

## RÉSEAU ET PÉRIMÈTRE

- [ ] Firmware firewall à jour (WatchGuard / Fortinet / SonicWall / Meraki)
- [ ] Licences UTM/IPS actives (pas expirées)
- [ ] Certificats SSL VPN : expiration > 30 jours
- [ ] VLAN correctement segmentés (serveurs / utilisateurs / IoT séparés)
- [ ] Logs firewall activés et conservés > 90 jours
- [ ] Aucune règle "Any → Any Accept" non documentée

---

## BACKUP ET RÉSILIENCE

- [ ] Backups testés (voir CHECKLIST_BACKUP_DR-Readiness)
- [ ] Au moins 1 copie hors site (Datto cloud / Veeam Cloud / Keepit)
- [ ] Accès Passportal aux backups : restreint aux techniciens autorisés

---

## RÉSULTAT

| Zone | Status | Actions requises |
|---|---|---|
| Identité et accès | ☐ OK / ☐ Actions | |
| Messagerie M365 | ☐ OK / ☐ Actions | |
| Endpoints et serveurs | ☐ OK / ☐ Actions | |
| Réseau et périmètre | ☐ OK / ☐ Actions | |
| Backup et résilience | ☐ OK / ☐ Actions | |

**Score global :** _______ / 30 items
**Audit effectué par :** _______ | **Date :** _______ | **Billet CW :** #_______
