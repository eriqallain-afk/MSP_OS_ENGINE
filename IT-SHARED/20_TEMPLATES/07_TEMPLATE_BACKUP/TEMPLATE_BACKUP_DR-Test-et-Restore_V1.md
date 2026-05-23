# TEMPLATE_BACKUP_DR-Test-et-Restore_V1
**Agent :** IT-BackupDRMaster, IT-MaintenanceMaster | IT-SysAdmin
**Usage :** Rapport de test DR + Demande de restauration formelle
**Mis à jour :** 2026-03-20

---

## PARTIE 1 — RAPPORT TEST DR

```
═══════════════════════════════════════════════
RAPPORT TEST DISASTER RECOVERY
Client        : [NOM CLIENT]
Date du test  : [YYYY-MM-DD]
Effectué par  : [Technicien]
Billet CW     : #[XXXXXX]
Solution backup : [Datto / Veeam / Keepit / Autre]
═══════════════════════════════════════════════

SCÉNARIO TESTÉ
Type : [Restauration fichier / VM complète / Instant Virtualization / Bare Metal]
Asset testé  : [Nom VM ou serveur]
Point de restauration utilisé : [Date/heure du snapshot]
Objectif RPO : [Xh] | Objectif RTO : [Xh]

PROCÉDURE EXÉCUTÉE
1. [Étape 1 — ex: Démarrage VM via Instant Virtualization Datto]
2. [Étape 2 — ex: Test RDP/connexion]
3. [Étape 3 — ex: Validation des services critiques]
4. [Étape 4 — ex: Arrêt de la VM de test]

RÉSULTATS
RPO réel : [Xh depuis le dernier backup sain]
RTO réel : [Xh Ymin pour atteindre un état opérationnel]

Validation :
☐ VM/système a démarré correctement
☐ Services critiques opérationnels : [Liste]
☐ Données accessibles et intègres
☐ Accès réseau/utilisateurs fonctionnel (si testé)
☐ Screenshot backup présent (Datto)

Résultat global : ✅ PASS / ❌ FAIL / ⚠️ PARTIEL

ÉCARTS ET ACTIONS CORRECTIVES
[Si FAIL ou PARTIEL : décrire l'écart et l'action pour y remédier]

PROCHAINE DATE DE TEST RECOMMANDÉE : [YYYY-MM-DD]
═══════════════════════════════════════════════
```

---

## PARTIE 2 — DEMANDE DE RESTAURATION

```
═══════════════════════════════════════════════
DEMANDE DE RESTAURATION
Billet CW      : #[XXXXXX]
Client         : [NOM]
Date/Heure     : [YYYY-MM-DD HH:MM]
Demandé par    : [Nom utilisateur / responsable]
Technicien     : [NOM]
═══════════════════════════════════════════════

OBJET DE LA RESTAURATION
Type : ☐ Fichier(s)/Dossier(s)  ☐ VM complète  ☐ Base de données  ☐ Autre

Fichier(s) concerné(s) :
• [Chemin et nom exact du fichier ou dossier]
• [Fichier 2 si applicable]

Serveur/VM source : [NOM]
Solution backup   : [Datto / Veeam / Keepit]

POINT DE RESTAURATION DEMANDÉ
Date/heure souhaitée : [YYYY-MM-DD HH:MM]
(dernier backup disponible avant la perte/corruption)

DESTINATION
☐ Emplacement original (écrase l'existant — confirmer avec client)
☐ Emplacement alternatif : [Préciser le chemin]
☐ Téléchargement local (pour vérification)

AUTORISATION
Autorisé par : [Nom du responsable client]
Méthode      : ☐ Verbal  ☐ Email  ☐ Teams  ☐ Billet CW

VALIDATION POST-RESTAURATION
[ ] Fichier ouvert et contenu vérifié par [utilisateur]
[ ] Données intègres confirmées
[ ] Billet CW complété avec résultats
═══════════════════════════════════════════════
```
