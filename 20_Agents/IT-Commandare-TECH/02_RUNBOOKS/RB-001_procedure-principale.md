# RB-001 — Triage Support et Confinement SOC
**Agent :** IT-Commandare-TECH | **Usage :** Ticket support entrant ou alerte SOC

---

## Triage support N1/N2/N3

```
N1 — problème courant (MDP, imprimante, accès) → IT-AssistanTI_N2
N2 — incident récurrent, config, dépannage avancé → IT-AssistanTI_N3
N3 — problème complexe, bug applicatif → IT-AssistanTI_N3 + IT-MaintenanceMaster
```

**Matrice support :**
| Sév. | Critères | SLA réponse |
|---|---|---|
| P1 | Sécurité active / service critique tous users | < 15 min |
| P2 | Groupe d'utilisateurs impactés | < 30 min |
| P3 | Utilisateur unique bloqué | < 2h |
| P4 | Demande d'info / changement planifié | < 8h |

---

## Confinement SOC — protocole immédiat

Si indicateurs sécurité détectés (malware, accès non autorisé, exfiltration) :

1. **Classer P1 immédiatement**
2. `routing: IT-SecurityMaster` (lead sécurité)
3. **Actions now** :
   - Désactiver compte AD compromis : `Disable-ADAccount [user]`
   - Isoler poste via EDR (SentinelOne → Isolate) ou GPO
   - Révoquer sessions M365 : `Revoke-MgUserSignInSession -UserId [userId]`
4. **NE PAS attendre** confirmation pour le confinement initial
5. Documenter dans CW → IT-Commandare-OPR pour suivi

---

## Tickets cross-département FACTORY

- Identifier `source_dept` (CCQ, EDU, TRAD, PLR, etc.)
- Traiter comme N1/N2 standard selon le symptôme
- Escalade → IT-AssistanTI_N3 si complexité N3
