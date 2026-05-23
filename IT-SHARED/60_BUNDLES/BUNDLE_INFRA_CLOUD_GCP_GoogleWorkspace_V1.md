# BUNDLE_INFRA_CLOUD_GCP_GoogleWorkspace_V1
**Catégorie :** Cloud — Google Cloud Platform & Google Workspace
**Agents :** @IT-CloudMaster | @IT-Commandare-Infra | IT-MaintenanceMaster | IT-SysAdmin
**Version :** 1.0 | **Date :** 2026-04-05

---

## RB-GCP-001 — Google Workspace Admin — Opérations courantes

**Console :** [admin.google.com](https://admin.google.com)
**Compte admin :** → Voir Passportal : [NomEntréeClient-GoogleAdmin]

### Gestion des utilisateurs
```
Admin Console → Directory → Users

Créer un utilisateur :
- Prénom, Nom, Email principal (@domaine.com)
- Licences : G Suite Business / Workspace Business Starter/Standard/Plus
- Groupes à assigner selon le département

Réinitialiser le MDP :
- Cliquer l'utilisateur → Reset password → Demander changement au prochain login ✅

Suspendre / Réactiver un compte :
- Plus → Suspend / Reactivate user

Transférer les données (départ employé) :
- Admin Console → Data migration → sélectionner la source → transférer vers le nouveau propriétaire
```

### Gestion des licences
```
Admin Console → Billing → Subscriptions
→ Vérifier le nombre de licences actives vs assignées
→ Ajouter/réduire selon les besoins
→ IMPORTANT : réduire les licences avant la prochaine facturation
```

### Google Drive — Espace et partage
```
Admin Console → Reports → Audit → Drive
→ Identifier les gros fichiers / utilisateurs dépassant leur quota
→ Configurer les politiques de partage (externe autorisé ou non)

Reports → Storage → identifier les utilisateurs proches de la limite
```

### Gmail — Problèmes livraison
```
Admin Console → Reporting → Email Log Search
→ Saisir l'adresse source ou destination + plage de dates
→ Identifier : Delivered / Bounced / Rejected / Spam
→ MX Records corrects : dig MX domaine.com
   → Doit pointer vers aspmx.l.google.com
```

---

## RB-GCP-002 — Google Cloud Platform — Opérations de base

**Console :** [console.cloud.google.com](https://console.cloud.google.com)

### Compute Engine — Instances VM
```bash
# Lister les instances
gcloud compute instances list

# Démarrer / arrêter
gcloud compute instances start NomInstance --zone=us-central1-a
gcloud compute instances stop NomInstance --zone=us-central1-a

# SSH dans l'instance
gcloud compute ssh NomInstance --zone=us-central1-a

# Créer un snapshot de disque
gcloud compute disks snapshot NomDisque --snapshot-names=snap-$(date +%Y%m%d) --zone=us-central1-a
```

### Cloud Storage
```bash
# Lister les buckets
gsutil ls

# Copier un fichier
gsutil cp fichier.txt gs://NomDuBucket/chemin/

# Vérifier l'utilisation
gsutil du -sh gs://NomDuBucket
```

### Cloud DNS
```bash
# Lister les zones
gcloud dns managed-zones list

# Lister les enregistrements
gcloud dns record-sets list --zone=NomZone

# Ajouter un enregistrement A
gcloud dns record-sets transaction start --zone=NomZone
gcloud dns record-sets transaction add 1.2.3.4 --name=test.exemple.com. --ttl=300 --type=A --zone=NomZone
gcloud dns record-sets transaction execute --zone=NomZone
```

---

## RB-GCP-003 — Incidents Google Workspace courants

### Email non reçu
1. Vérifier Email Log Search (Admin Console → Reporting)
2. Vérifier les enregistrements MX : `dig MX domaine.com`
3. Vérifier SPF/DKIM/DMARC : `dig TXT domaine.com`
4. Vérifier les filtres Gmail de l'utilisateur et le dossier Spam

### Compte Google suspendu
1. Admin Console → Users → l'utilisateur apparaît en rouge (Suspended)
2. Cliquer → Reactivate
3. Si suspendu pour activité suspecte : changer le MDP et activer/vérifier la 2FA

### Quota Drive dépassé
1. Identifier les gros fichiers : Drive → Storage
2. Vider la corbeille Drive
3. Supprimer les anciennes versions de fichiers (si non nécessaire)
4. Ou augmenter le plan de stockage
