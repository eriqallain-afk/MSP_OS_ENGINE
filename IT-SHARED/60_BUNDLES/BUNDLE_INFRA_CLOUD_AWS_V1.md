# BUNDLE_INFRA_CLOUD_AWS_V1
**Catégorie :** Cloud — Amazon Web Services (AWS)
**Agents :** @IT-CloudMaster | @IT-Commandare-Infra | @IT-SecurityMaster | IT-MaintenanceMaster | IT-SysAdmin
**Version :** 1.0 | **Date :** 2026-04-05

---

## RB-AWS-001 — Administration de base AWS

**Console :** [console.aws.amazon.com](https://console.aws.amazon.com)
**Compte :** → Voir Passportal : [NomEntréeClient-AWS]

### Gestion IAM (Identity and Access Management)
```bash
# Lister les utilisateurs IAM
aws iam list-users

# Créer un utilisateur IAM
aws iam create-user --user-name NomUtilisateur

# Attacher une politique
aws iam attach-user-policy --user-name NomUtilisateur   --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# Rotation des clés d'accès
aws iam create-access-key --user-name NomUtilisateur
aws iam delete-access-key --user-name NomUtilisateur --access-key-id AKIAXXXXXXXX

# Vérifier les clés de +90 jours
aws iam generate-credential-report
aws iam get-credential-report
```

### Gestion EC2 — Instances
```bash
# Lister les instances
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType,Tags[?Key==`Name`].Value|[0]]' --output table

# Démarrer / arrêter une instance
aws ec2 start-instances --instance-ids i-XXXXXXXXXXXXXXXXX
aws ec2 stop-instances --instance-ids i-XXXXXXXXXXXXXXXXX

# Créer un snapshot
aws ec2 create-snapshot --volume-id vol-XXXXXXXXXXXXXXXXX --description "Backup manuel $(date +%Y%m%d)"

# Vérifier l'état des snapshots
aws ec2 describe-snapshots --owner-ids self --query 'Snapshots[*].[SnapshotId,VolumeId,State,StartTime,Description]' --output table
```

### Gestion S3 — Stockage
```bash
# Lister les buckets
aws s3 ls

# Contenu d'un bucket
aws s3 ls s3://NomDuBucket --recursive

# Copier un fichier
aws s3 cp fichier.txt s3://NomDuBucket/chemin/

# Vérifier la politique de rétention et versioning
aws s3api get-bucket-versioning --bucket NomDuBucket
aws s3api get-bucket-lifecycle-configuration --bucket NomDuBucket
```

### Route53 — Gestion DNS
```bash
# Lister les zones hébergées
aws route53 list-hosted-zones

# Lister les enregistrements d'une zone
aws route53 list-resource-record-sets --hosted-zone-id Z1XXXXXXXXXXXXXXXXX

# Créer/modifier un enregistrement A
aws route53 change-resource-record-sets --hosted-zone-id Z1XXX   --change-batch '{"Changes":[{"Action":"UPSERT","ResourceRecordSet":{"Name":"test.exemple.com","Type":"A","TTL":300,"ResourceRecords":[{"Value":"1.2.3.4"}]}}]}'
```

### CloudWatch — Monitoring
```bash
# Alertes actives
aws cloudwatch describe-alarms --state-value ALARM

# Métriques CPU d'une instance (30 dernières minutes)
aws cloudwatch get-metric-statistics   --namespace AWS/EC2   --metric-name CPUUtilization   --dimensions Name=InstanceId,Value=i-XXXXXXXXXXXXXXXXX   --start-time $(date -u -d '30 minutes ago' +%Y-%m-%dT%H:%M:%S)   --end-time $(date -u +%Y-%m-%dT%H:%M:%S)   --period 300 --statistics Average
```

---

## RB-AWS-002 — Sécurité AWS — Audit rapide

### Checklist sécurité minimale
- [ ] MFA activé sur le compte root AWS
- [ ] Compte root sans clé d'accès active
- [ ] AWS CloudTrail activé dans toutes les régions
- [ ] AWS Config activé
- [ ] Security Hub activé
- [ ] Aucun Security Group avec 0.0.0.0/0 sur les ports sensibles (22, 3389)

```bash
# Vérifier le MFA root
aws iam get-account-summary | grep -i mfa

# Vérifier CloudTrail
aws cloudtrail describe-trails

# Security Groups avec 0.0.0.0/0
aws ec2 describe-security-groups   --query 'SecurityGroups[?IpPermissions[?IpRanges[?CidrIp==`0.0.0.0/0`]]].{ID:GroupId,Name:GroupName}'   --output table
```

---

## RB-AWS-003 — Incidents courants AWS

### Instance EC2 inaccessible via SSH/RDP
1. Vérifier l'état de l'instance : Running ?
2. Vérifier le Security Group : port 22 ou 3389 ouvert pour l'IP source ?
3. Vérifier les Network ACL (blocage au niveau VPC)
4. Utiliser **EC2 Instance Connect** ou **Systems Manager Session Manager** comme alternative
5. Vérifier les logs système : Actions → Monitor and troubleshoot → Get system log

### Coût AWS anormal
1. AWS Cost Explorer → identifier le service source
2. Vérifier les instances non arrêtées, les snapshots orphelins, le trafic de données
3. Créer une alerte de budget si inexistante

### Escalade
- Breach sécurité AWS → @IT-SecurityMaster — isoler l'instance immédiatement
- Coût hors contrôle → escalader au responsable client
