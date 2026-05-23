# EX-001 — Cas nominal : CPU 100% sur SRV-DC01 (P2 → Résolu)
**Agent :** IT-AssistanTI_N3 | **Statut :** PASS

---

## INPUT
```
/start — Billet #T1683171 — Client : Acme Corp
SRV-DC01 CPU à 100% depuis 25 min — alertes RMM — utilisateurs lents
```

## TRIAGE
```yaml
categorie: NOC
priorite: P2
systemes_affectes: [SRV-DC01]
impact: "Tous les utilisateurs du domaine — authentification lente"
risques: ["P1 si DC tombe", "réplication AD compromise"]
```

## PRECHECK (commandes exécutées)
```powershell
# Top processus CPU
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name,CPU,Id

# Résultat :
# Name          CPU    Id
# TiWorker     9842  4428   ← Windows Update en arrière-plan
# svchost      1203  1024
```

## ACTIONS
```
1. Identifier TiWorker.exe = Windows Update (WUauserv)
   → [LECTURE SEULE d'abord confirmée] ✅

2. [WARNING IMPACT] Stop-Service wuauserv va interrompre Windows Update.
   Confirmes-tu ? → "oui" ✅

3. Stop-Service wuauserv -Force
   → CPU redescend à 12% en 90 secondes ✅

4. Validation : Get-Service wuauserv → Stopped ✅
   Get-Process | Sort-Object CPU -Descending | Select-Object -First 3
   → CPU normal ✅
```

## CLÔTURE (`/close`)

**CW Note Interne :**
```
Prise de connaissance de la demande et consultation de la documentation du client.
Billet #T1683171 — SRV-DC01 CPU 100% — Acme Corp
Cause identifiée : processus TiWorker.exe (Windows Update) consommant 100% CPU depuis 25 min.
Actions : Stop-Service wuauserv -Force à 14:37.
Résultat : CPU retombé à 12% en 90s. Monitoring revenu au vert à 14:39.
Next : Planifier Windows Update hors heures — fenêtre prochaine maintenance.
```

**CW Discussion :**
```
Intervention sur le serveur signalé par le monitoring.
Identification et résolution de la surcharge processeur — toutes les performances
sont revenues à la normale. Le serveur est stable.
Une mise à jour Windows sera planifiée lors de la prochaine fenêtre de maintenance.
```

## POST-CLÔTURE
```yaml
/kb: true    # P2 résolu — runbook utile
/db: true    # > 30 min
duree: 22 min
escalade: false
```
