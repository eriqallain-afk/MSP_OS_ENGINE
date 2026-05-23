# RUNBOOK — Réponse aux Incidents de Sécurité MSP
**ID :** RUNBOOK__IT_SECURITY_INCIDENT_RESPONSE  
**Version :** 2.0 | **Agent :** IT-SecurityMaster  
**Agents :** IT-MaintenanceMaster | IT-SysAdmin
**Mis à jour :** 2026-03-20 — Agents archivés remplacés
**Applicable :** Tout incident cybersécurité P1/P2 (breach, ransomware, phishing actif)

---

## DÉCLENCHEURS
- Alerte EDR/XDR confirmée (SentinelOne, CrowdStrike, Defender XDR)
- Rapport utilisateur : accès non autorisé, chiffrement fichiers, email suspect cliqué
- Alerte NOC : trafic anormal, connexions sortantes suspectes
- Demande d'audit post-incident

---

## PHASE 1 — IDENTIFICATION (0 à 15 min)

### Étape 1.1 — Qualifier l'incident
- [ ] Type confirmé : ransomware / phishing / breach / lateral_movement / autre
- [ ] Asset(s) affecté(s) identifiés
- [ ] Heure de détection vs heure estimée compromission
- [ ] Vecteur d'entrée probable (email / RDP / VPN / supply chain)
- [ ] Propagation active ? (oui/non/inconnu)

### Étape 1.2 — Classier la sévérité
| Indicateur | P1 | P2 | P3 |
|-----------|----|----|-----|
| Chiffrement actif détecté | ✓ | | |
| Credentials admin compromis | ✓ | | |
| DC / AD touché | ✓ | | |
| Single workstation isolée | | | ✓ |
| Email phishing cliqué, no exec | | | ✓ |
| Mouvement latéral confirmé | | ✓ | |
| Data exfiltration suspectée | ✓ | | |

### Étape 1.3 — Notification
- P1 : Notifier IT-Commandare-NOC + IT-Commandare-TECH **immédiatement**
- P2 : Notifier IT-Commandare-NOC dans les 30 min
- Ouvrir ticket CW avec priorité correcte

---

## PHASE 2 — CONTAINMENT (15 min à 2h)

### 2.1 Isolation réseau (si propagation active)
```powershell
# ⚠️ Impact : isolation réseau complète du poste/serveur
# Validation requise avant exécution
# Sur le poste suspect :
netsh advfirewall set allprofiles state on
netsh advfirewall firewall add rule name="BLOCK_ALL_IR" dir=out action=block
```
- [ ] Poste isolé du réseau (déconnecter NIC ou quarantaine EDR)
- [ ] NE PAS éteindre la machine (préserver artefacts forensics en RAM)
- [ ] Si serveur critique : coordination IT-Commandare-Infra avant isolation

### 2.2 Révoquer accès compromis
- [ ] Désactiver compte AD compromis
- [ ] Révoquer sessions actives Azure AD : `Revoke-AzureADUserAllRefreshToken`
- [ ] Changer mots de passe service accounts affectés
- [ ] Invalider tokens MFA si nécessaire

### 2.3 Bloquer IOCs
- [ ] Ajouter hashes malwares dans EDR exclusions (block)
- [ ] Bloquer IPs/domaines C2 sur firewall
- [ ] Règle email : bloquer domaine expéditeur malveillant

---

## PHASE 3 — INVESTIGATION (parallèle au containment)

### 3.1 Collecte d'artefacts
```powershell
# Capture état système AVANT remédiation
$OutDir = "$env:SystemDrive\IR_ARTIFACTS_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

# Processus actifs
Get-Process | Export-Csv "$OutDir\processes.csv" -NoTypeInformation
# Connexions réseau
netstat -ano > "$OutDir\netstat.txt"
# Logs événements récents (Security, System, Application)
Get-EventLog -LogName Security -Newest 500 | Export-Csv "$OutDir\events_security.csv" -NoTypeInformation
# Tâches planifiées
Get-ScheduledTask | Export-Csv "$OutDir\scheduled_tasks.csv" -NoTypeInformation
# Services
Get-Service | Export-Csv "$OutDir\services.csv" -NoTypeInformation
```
- [ ] Artefacts copiés sur stockage sécurisé (hors réseau compromis)
- [ ] NE PAS supprimer artefacts avant analyse complète

### 3.2 Analyse timeline
- [ ] Corrélation logs EDR + Event Viewer + pare-feu
- [ ] Patient zéro identifié
- [ ] Étendue de la compromission mappée

---

## PHASE 4 — ÉRADICATION

- [ ] Suppression malware (via EDR ou réinstallation OS si nécessaire)
- [ ] Patch vulnérabilité exploitée
- [ ] Nettoyage registre et persistence mécanismes
- [ ] Réinitialisation credentials complets si breach confirmé
- [ ] Vérification intégrité backups (avant restauration)

---

## PHASE 5 — RÉCUPÉRATION

- [ ] Restauration depuis backup sain (date pre-compromission confirmée)
- [ ] Validation intégrité post-restauration
- [ ] Monitoring renforcé 72h (alertes sensibilité maximale)
- [ ] Test accès utilisateurs
- [ ] Communication client (via IT-TicketScribe)

---

## PHASE 6 — POST-INCIDENT

- [ ] Postmortem avec IT-ReportMaster (dans les 5 jours ouvrables)
- [ ] KB article créé par IT-KnowledgeKeeper
- [ ] Ajustements monitoring/seuils via IT-MonitoringMaster
- [ ] Rapport sécurité mensuel mis à jour

---

## COMMUNICATION CLIENT

| Phase | Message | Via |
|-------|---------|-----|
| Détection | "Incident sécurité détecté, investigation en cours" | IT-TicketScribe |
| Containment | "Services [X] affectés temporairement, correction en cours" | IT-TicketScribe |
| Résolution | Rapport postmortem complet | IT-ReportMaster |

---

## CHECKLIST FINALE AVANT FERMETURE TICKET

- [ ] Vecteur d'entrée confirmé et bouché
- [ ] Tous les systèmes affectés traités
- [ ] Credentials compromis tous réinitialisés
- [ ] Monitoring renforcé actif
- [ ] Client notifié
- [ ] KB créé
- [ ] Postmortem documenté
