# SEC-M365-Compliance_Purview_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-SecurityMaster | @IT-Commandare-TECH | @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** SEC | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__M365_Compliance_Purview_V1
**Version :** 1.0 | **Agents :** IT-CloudMaster, IT-SecurityMaster
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Domaine :** INFRA — Microsoft 365 / Conformité
**Mis à jour :** 2026-03-20

---

## 1. ACCÈS PORTAILS SÉCURITÉ ET CONFORMITÉ

| Portail | URL | Usage |
|---|---|---|
| **Microsoft Purview** | https://compliance.microsoft.com | DLP, rétention, eDiscovery |
| **Defender for M365** | https://security.microsoft.com | Sécurité, menaces, incidents |
| **Entra ID Protection** | https://entra.microsoft.com | Risques, MFA, CA |
| **Secure Score** | security.microsoft.com/securescore | Score sécurité global |

---

## 2. RECHERCHE DANS LES LOGS D'AUDIT (UNIFIED AUDIT LOG)

```powershell
# Connexion
Connect-ExchangeOnline -UserPrincipalName "<ADMIN_UPN>.com"

# Recherche générale (7 derniers jours)
Search-UnifiedAuditLog `
    -StartDate (Get-Date).AddDays(-7) `
    -EndDate (Get-Date) `
    -UserIds "utilisateur@domaine.com" `
    -RecordType ExchangeAdmin `
    -ResultSize 500 |
    Select-Object CreationDate, UserIds, Operations, RecordType, AuditData |
    Format-Table -AutoSize

# Opérations courantes à rechercher :
# MailboxLogin        → Connexions boîte aux lettres
# FileAccessed        → Accès fichiers SharePoint/OneDrive
# MemberAdded         → Ajout membre Teams/groupe
# UserLoggedIn        → Connexions utilisateurs
# Set-Mailbox         → Modifications de boîtes
# New-InboxRule       → Création règles Outlook
```

---

## 3. MICROSOFT SECURE SCORE

```
security.microsoft.com → Secure Score
→ Score actuel vs score recommandé
→ Actions recommandées : liste de mesures à prendre
→ Comparer avec : industrie, clients similaires

Actions prioritaires typiques :
→ Activer MFA pour tous les admins (impact élevé)
→ Activer Defender for Office 365 (anti-phishing)
→ Activer l'audit des boîtes aux lettres
→ Bloquer l'authentification basique (Legacy Auth)
→ Activer les révisions d'accès périodiques
```

---

## 4. DEFENDER FOR MICROSOFT 365 — ALERTES

```
security.microsoft.com → Incidents & Alerts
→ Voir les incidents actifs
→ Chaque incident regroupe plusieurs alertes liées

Triage d'une alerte :
1. Cliquer sur l'alerte → Lire la description complète
2. Identifier les entités affectées (utilisateurs, appareils, emails)
3. Évaluer : Vrai positif (VP) / Faux positif (FP) / Test
4. VP → escalade SOC immédiate
5. FP → marquer comme résolu avec commentaire

⚠️ NE JAMAIS ignorer une alerte Defender sans l'avoir classée
```

---

## 5. PROTECTION CONTRE LES MENACES EMAIL (DEFENDER FOR OFFICE 365)

```
security.microsoft.com → Email & Collaboration → Threat Explorer
→ Voir les emails malveillants récents
→ Filtrer par : Phishing, Malware, Spam

Quarantaine :
security.microsoft.com → Review → Quarantine
→ Messages retenus pour révision
→ Libérer les faux positifs
→ Signaler les vrais positifs

Politiques anti-phishing :
security.microsoft.com → Policies → Anti-phishing
→ Vérifier l'impersonation protection (usurpation d'identité)
→ Vérifier les domaines protégés
```

---

## 6. DLP (DATA LOSS PREVENTION)

```
compliance.microsoft.com → Data loss prevention → Policies
→ Voir les politiques actives
→ Vérifier les alertes DLP récentes

Alerte DLP déclenchée :
1. compliance.microsoft.com → DLP → Alerts
2. Cliquer sur l'alerte → détails de l'événement
3. Identifier : qui a envoyé quoi et à qui
4. Évaluer : accident ou intention
5. VP → escalade SOC

⚠️ NE JAMAIS désactiver une politique DLP sans approbation du client
```

---

## 7. RÉTENTION ET ARCHIVAGE

```
compliance.microsoft.com → Information governance → Retention policies
→ Vérifier les politiques de rétention actives
→ S'assurer qu'elles couvrent : Exchange, SharePoint, OneDrive, Teams

Litigation Hold (hold légal sur une boîte) :
Set-Mailbox "utilisateur@domaine.com" -LitigationHoldEnabled $true

In-Place Archive (archivage Exchange Online) :
Enable-Mailbox "utilisateur@domaine.com" -Archive
Get-Mailbox "utilisateur@domaine.com" | Select-Object ArchiveStatus, ArchiveQuota
```

---

## 8. NE PAS FAIRE

```
⛔ NE JAMAIS désactiver l'audit unifié (UAL) — requis pour toute investigation
⛔ NE PAS supprimer un Litigation Hold sans ordre juridique ou approbation client écrite
⛔ NE JAMAIS créer une règle de transport qui bypass le spam/phishing filtering
⛔ NE PAS autoriser l'authentification basique (Legacy Auth) dans de nouveaux déploiements
⛔ NE JAMAIS ignorer une alerte Defender > 2h sans l'avoir triée
```

---

## 9. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Incident Defender (vrai positif) | SOC | Immédiat |
| Alerte DLP (données sensibles exposées) | SOC + CloudMaster | Dans l'heure |
| Score sécurité < 30% | CloudMaster + TECH | Dans la semaine (planifié) |
| Litigation Hold requis (legal) | TECH + CloudMaster | Dans l'heure |
