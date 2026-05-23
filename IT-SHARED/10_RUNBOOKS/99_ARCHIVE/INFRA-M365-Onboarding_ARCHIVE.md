# RUNBOOK — ONBOARDING UTILISATEUR M365
**Agents :** @IT-CloudMaster, IT-MaintenanceMaster, IT-SysAdmin
**Scope :** Integration complete d'un nouvel employe dans M365

---

## ETAPE 1 — Compte et licence
- [ ] Compte cree (voir RUNBOOK__M365_User_Management.md)
- [ ] Licence assignee selon role
- [ ] MFA active (Authenticator app obligatoire)

## ETAPE 2 — Appareil (Intune)
- [ ] Intune policy assignee au groupe de l'utilisateur
- [ ] Appareil Windows : OOBE + Autopilot si configure
- [ ] Appareil mobile : Company Portal installe
- [ ] Conformite verifiee dans Intune admin center

## ETAPE 3 — Applications
- [ ] Office 365 Apps installe (max 5 appareils)
- [ ] Teams configure et teste (audio/video)
- [ ] OneDrive sync configure et fonctionnel
- [ ] Outlook configure (profil cree, signature)

## ETAPE 4 — Acces et permissions
- [ ] Groupes de securite assignes selon role
- [ ] Acces SharePoint / Teams selon departement
- [ ] Acces VPN configure si requis
- [ ] Imprimantes reseau ajoutees si applicable

## ETAPE 5 — Validation
- [ ] Test envoi / reception email
- [ ] Test reunion Teams (audio + video)
- [ ] Test acces OneDrive / SharePoint
- [ ] Fiche Hudu creee pour le nouvel utilisateur
- [ ] Billet CW clôture avec liste des actions

**Duree estimee :** 45-90 min selon complexite.
