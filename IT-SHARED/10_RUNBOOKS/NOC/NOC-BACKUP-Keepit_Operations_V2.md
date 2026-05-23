# NOC-BACKUP-Keepit_Operations_V2
**Version :** 2.0 | **Date :** 2026-04-22 | **Statut :** ACTIF
**Agents :** @IT-Commandare-NOC | @IT-BackupDRMaster | @IT-MonitoringMaster | @IT-SysAdmin | @IT-MaintenanceMaster
**Département :** NOC | **Source :** IT MSP Intelligence Platform

---

**ID :** RUNBOOK__Keepit_Operations_V1
**Version :** 1.0 | **Agents :** IT-BackupDRMaster, IT-CloudMaster
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Domaine :** INFRA — Backup Cloud M365
**Mis à jour :** 2026-03-20

---

## 1. PRÉSENTATION KEEPIT

Keepit est une solution de **backup cloud-to-cloud** pour Microsoft 365 et autres SaaS.
Données protégées typiquement : Exchange Online, SharePoint, OneDrive, Teams, Entra ID.

**Portail :** https://app.keepit.com
**Credentials :** voir Passportal

---

## 2. VÉRIFICATION JOURNALIÈRE

```
Dashboard → Overview
→ Statut des backups par service (Exchange, SharePoint, OneDrive, Teams)
✅ Vert = backup réussi
⚠️ Orange = backup avec avertissements
❌ Rouge = backup en échec

Connectors → [Client] → [Service]
→ Dernière synchronisation
→ Nombre d'objets protégés
→ Taille totale des données sauvegardées
```

---

## 3. VÉRIFICATION CONNECTEUR MICROSOFT 365

```
Connectors → Microsoft 365 → [Tenant client]
→ Status : Connected / Disconnected / Error

Si le connecteur est déconnecté :
1. Cliquer sur le connecteur → Reconnect
2. Se connecter avec un compte admin Global Administrator du tenant M365
3. Accorder les permissions requises (OAuth)
4. Vérifier que le connecteur est vert après quelques minutes

⚠️ Si déconnexion depuis > 24h : les données ne sont plus sauvegardées
⚠️ Vérifier si le compte admin M365 utilisé par Keepit est actif et non expiré
```

---

## 4. RESTAURATION KEEPIT

### Restaurer des emails Exchange Online
```
1. Portail Keepit → Search → [Client]
2. Chercher par : utilisateur, sujet, date, expéditeur
3. Sélectionner les emails → Restore
4. Options :
   → Restore to original mailbox (restauration directe)
   → Restore to alternate mailbox
   → Export to PST
5. Suivre la progression dans : Jobs → Restore Jobs
```

### Restaurer des fichiers SharePoint / OneDrive
```
1. Portail Keepit → Sites → [Client] → SharePoint / OneDrive
2. Naviguer jusqu'au fichier/dossier
3. Cliquer sur la version à restaurer (historique disponible)
4. Restore to original location OU Download
5. Vérifier la restauration dans SharePoint/OneDrive
```

### Restaurer un compte utilisateur M365 supprimé
```
1. Portail Keepit → Users → [Client]
2. Chercher le compte supprimé (visible dans Keepit même si supprimé dans M365)
3. Sélectionner → Restore User
4. Les données sont restaurées dans un nouveau compte ou compte réactivé
⚠️ La licence M365 doit être disponible pour la restauration
```

---

## 5. AUDIT ET CONFORMITÉ

```
Portail Keepit → Reports
→ Backup Success Rate : % de backups réussis sur les 30 derniers jours
→ Storage Used : espace utilisé par client
→ Activity Log : historique des backups et restaurations

Export des rapports (pour audit client) :
Reports → Export → CSV ou PDF
```

---

## 6. GESTION DES LICENCES KEEPIT

```
Admin → [Client] → Licenses
→ Nombre d'utilisateurs licenciés vs utilisateurs protégés
→ Si utilisateurs > licences : backup incomplet

⚠️ Nouveaux utilisateurs M365 ne sont PAS automatiquement protégés
   si le nombre de licences est atteint
Action : ajouter des licences ou vérifier les utilisateurs actifs
```

---

## 7. NE PAS FAIRE

```
⛔ NE JAMAIS supprimer un connecteur — les données sauvegardées seraient perdues
⛔ NE JAMAIS modifier les permissions du compte admin M365 utilisé par Keepit
   sans tester la reconnexion ensuite
⛔ NE PAS ignorer les alertes de connecteur déconnecté plus de 24h
⛔ NE PAS restaurer vers un utilisateur actif sans vérifier l'impact sur les données existantes
```

---

## 8. ESCALADE

| Situation | Département | Délai |
|---|---|---|
| Connecteur déconnecté > 24h | BackupDR + CloudMaster | Dans l'heure |
| Restauration urgente (données perdues) | BackupDR | Immédiat |
| Problème de licences (utilisateurs non protégés) | BackupDR + TECH | Dans la journée |
