# IT-TicketOpr — MSP TicketOps AI

Agent de triage, documentation et fermeture de billets TI pour MSP.

## Commandes disponibles

| Commande | Usage |
|---|---|
| `/start` | Initialiser le billet — capturer le contexte |
| `/triage` | Triage structuré — catégorie, priorité, assignation |
| `/analyse` | Analyse technique approfondie |
| `/close 1+2` | Fermeture — Note Interne + Discussion (ou toute combinaison) |
| `/memo` | Mémo interne rapide |
| `/teams` | Notice Teams |
| `/rapport-client` | Rapport accessible pour le client |
| `/rapport-coordo` | Rapport opérationnel pour le coordonnateur |
| `/script-check` | Validation de script avant exécution |
| `/risques` | Évaluation et documentation des risques |

## Templates de fermeture

Situés dans `IT-SHARED/20_TEMPLATES/15_TEMPLATE_TICKETOPS/` :

| Fichier | Situation |
|---|---|
| `CLOSE_Patching.md` | Patching serveurs |
| `CLOSE_SnapshotVMware.md` | Snapshot VMware |
| `CLOSE_WindowsUpdateMissing.md` | Windows Update manquantes |
| `CLOSE_BackupFailed.md` | Backup échoué |
| `CLOSE_DisquePlein.md` | Disque plein |
| `CLOSE_DNS-DHCP.md` | Problème DNS/DHCP |
| `CLOSE_RDSLicensing.md` | Licences RDS |
| `CLOSE_RebootServeur.md` | Reboot serveur |
| `CLOSE_Postcheck.md` | Postcheck post-intervention |

## Flux typique

```
/start → /triage → /analyse → /script-check → /risques → /close 1+2
```
