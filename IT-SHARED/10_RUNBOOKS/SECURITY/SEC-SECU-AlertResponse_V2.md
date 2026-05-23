# SEC-SECU-AlertResponse V2
**ID :** RUNBOOK__Alert_Response | **Version :** 2.0
**Agent owner :** IT-MonitoringMaster | **Équipe :** TEAM__IT
**Domaine :** SECURITY/MONITORING — Réponse aux alertes
**Date révision :** 2026-03-13
**Agents :** IT-MaintenanceMaster | IT-SysAdmin | IT-UrgenceMaster

---

## ⚠️ GARDE-FOUS — OBLIGATOIRES
> Référence : `00_POLICIES/GUARDRAILS__IT_AGENTS_MASTER.md`

**Scope :** Cet agent traite uniquement les alertes monitoring du billet actif.
Il ne répond pas aux demandes hors monitoring/alertes IT.

**Données sensibles :**
- ❌ JAMAIS dans les livrables : IPs, seuils de détection, noms de règles SIEM internes
- ❌ Dans les outputs client : aucun détail qui permettrait de contourner les alertes
- Les IOC (indicateurs de compromission) → note interne uniquement, jamais dans le client-safe

**Actions :**
- Désactivation d'une alerte → `⚠️ Impact : angle mort de sécurité` + validation + durée définie
- Modification de seuil → `⚠️ Impact : faux négatifs possibles` + documentation obligatoire

---

## 1. Objectif
Procédures de réponse structurées aux alertes de monitoring :
- ConnectWise RMM (alertes systèmes)
- N-able (performance / disponibilité)
- Auvik (réseau)
- SIEM / Defender XDR (sécurité)
- BackupRadar (backup)

---

## 2. Qualification d'une alerte — Priorité 0

### 2.1 Grille de qualification (remplir pour toute alerte)
```
Source    : [RMM / Auvik / BackupRadar / SIEM / Utilisateur]
Type      : [CPU / Disque / Service / Réseau / Backup / Sécurité / Disponibilité]
Sévérité  : [Critical / Warning / Informational]
Client    : [nom]
Asset     : [serveur/équipement — sans IP]
Heure     : [HH:MM]
Récurrent : [1ère fois / déjà vu — fréquence ?]
Corrélé   : [alerte isolée / liée à d'autres alertes]
```

### 2.2 Table bruit vs alerte réelle

| Pattern | Décision | Action |
|---------|----------|--------|
| Alerte disparaît < 5 min, aucun symptôme | Bruit transitoire | ACK + surveiller 30 min |
| Alerte revient > 3x / heure | Problème réel | Ouvrir ticket P2/P3 |
| Alerte corrélée avec d'autres assets | Incident infra global | Ticket P1 + Commandare |
| Alerte sur actif en maintenance connue | Faux positif maintenance | ACK + noter dans ticket |
| Alerte sécurité (EDR / SIEM) | JAMAIS ignorer | Analyser obligatoirement |

---

## 3. Réponse par type d'alerte

### 3.1 Alertes performance (CPU/RAM/Disque)
```powershell
# Diagnostic ciblé sur l'asset (lecture seule)
# CPU — identification processus
Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, Id,
  @{n='CPU_s';e={[math]::Round($_.CPU,1)}},
  @{n='RAM_MB';e={[math]::Round($_.WorkingSet64/1MB,1)}} | Format-Table -Auto

# RAM — utilisation détaillée
Get-CimInstance Win32_OperatingSystem |
  Select-Object @{n='Total_GB';e={[math]::Round($_.TotalVisibleMemorySize/1MB,1)}},
                @{n='Libre_GB';e={[math]::Round($_.FreePhysicalMemory/1MB,1)}},
                @{n='Utilisé_%';e={[math]::Round((($_.TotalVisibleMemorySize-$_.FreePhysicalMemory)/$_.TotalVisibleMemorySize)*100,1)}} | Format-List

# Disque — libérer si espace critique
Get-PSDrive -PSProvider FileSystem |
  Select-Object Name, @{n='Libre_GB';e={[math]::Round($_.Free/1GB,1)}},
    @{n='Libre_%';e={[math]::Round($_.Free/($_.Free+$_.Used)*100,1)}} | Format-Table -Auto
```

### 3.2 Alertes disponibilité (service / agent offline)
```powershell
# Vérifier état services (lecture seule)
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'} |
  Select-Object DisplayName, Name, Status, StartType | Format-Table -Auto

# Dernière communication agent RMM
# → Vérifier dans la console ConnectWise RMM (Last Seen)
# Si agent offline > 30 min et pas de maintenance → alerter NOC

# ⚠️ Impact : redémarrage service affecte utilisateurs connectés
# → Confirmer avant : Restart-Service -Name "[SERVICE]"
```

### 3.3 Alertes Backup (BackupRadar)
```
Échec backup → vérifier dans cet ordre :
1. Espace destination suffisant ? (> 20% libre)
2. Service backup agent running ?
3. Connectivité vers destination ? (réseau / VPN)
4. Credentials de connexion valides ? (vérifier sans afficher)
5. Job bloqué / en conflit avec autre job ?
→ Si 3 échecs consécutifs → P2 + IT-BackupDRMaster
→ Si perte de données possible → P1 + escalade Senior immédiate
```

### 3.4 Alertes Sécurité (EDR / SIEM / Defender)
```
RÈGLE ABSOLUE : aucune alerte sécurité n'est ignorée sans analyse.

Niveau 1 — Triage (5 min max) :
  → Faux positif connu ? (processus légitime mal détecté)
  → Processus signé par éditeur reconnu + comportement normal ?
  → Si OUI → ACK + documenter la règle d'exclusion proposée (sans l'appliquer sans validation)

Niveau 2 — Analyse (si non faux positif évident) :
  → Hash / process path → vérification VirusTotal ou SIEM interne
  → Compte associé → activité anormale ?
  → Asset → d'autres alertes sur cet asset ?
  → Si suspicion → P1 + IT-SecurityMaster IMMÉDIAT

JAMAIS :
  ❌ Supprimer une alerte EDR sans analyse
  ❌ Désactiver EDR même temporairement sans approbation senior + documentation
  ❌ Créer une exclusion globale sans validation IT-SecurityMaster
```

---

## 4. Documentation obligatoire (toute alerte)

### Champs minimaux dans le ticket CW
```yaml
type_alerte    : [catégorie]
source         : [outil monitoring]
heure_détection: [HH:MM]
asset          : [nom — sans IP]
qualification  : [bruit / réel — justification]
actions        : [liste des actions et statuts]
résolution     : [cause + correctif]
durée          : [en minutes si service interrompu]
récurrence     : [première fois / N-ième — historique]
```

---

## 5. Amélioration continue du monitoring

### Règles de maintenance des seuils (mensuelle)
- Seuil CPU : revoir si > 15% de faux positifs sur 30 jours
- Seuil disque : ajuster si croissance données accélérée détectée
- Alerte récurrente identique > 3x/semaine → ticket amélioration + revue seuil
- Nouvelle alerte qui aurait évité un incident → ajouter à la baseline monitoring

---

## 6. Livrables CW

### Note interne
```
Prendre connaissance de la demande et connexion à la documentation de l'entreprise.

Source alerte  : [outil]
Type           : [catégorie]
Qualification  : [bruit / incident réel]
Sévérité réelle: P[1/2/3/4]
Asset impacté  : [nom — sans IP]
Actions :
  1. [action — FAIT / KO]
  2. [action — FAIT / KO]
Cause          : [identifiée / [À CONFIRMER]]
Résultat       : [alerte résolue / escaladée / planifiée]
Monitoring     : [ACK / seuil ajusté / à surveiller]
```

### Discussion client (client-safe)
```
- Réception et analyse de l'alerte.
- Investigation effectuée : [résumé fonctionnel sans détails techniques].
- Résolution : [correctif appliqué / surveillance renforcée].
- Prochaine étape : [monitoring actif / aucune action requise].
```
