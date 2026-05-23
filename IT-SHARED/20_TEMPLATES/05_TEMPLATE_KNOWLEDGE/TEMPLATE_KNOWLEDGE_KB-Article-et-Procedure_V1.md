# TEMPLATE_KNOWLEDGE_KB-Article-et-Procedure_V1
**Agent :** IT-KnowledgeKeeper, IT-Assistant-N3
**Usage :** Article KB réutilisable + documentation d'une nouvelle procédure
**Mis à jour :** 2026-03-20

---

## PARTIE 1 — ARTICLE KB

```
═══════════════════════════════════════════════
ARTICLE KB — [TITRE COURT ET DESCRIPTIF]
ID            : KB-[YYYYMMDD]-[NNN]
Catégorie     : [Windows / AD / M365 / Réseau / Backup / Sécurité / Autre]
Système       : [Windows Server 20XX / Exchange Online / etc.]
Niveau tech   : N1 / N2 / N3
Temps estimé  : [X min]
Récurrence    : ☐ Fréquent  ☐ Occasionnel  ☐ Rare
Créé par      : [Technicien]  | Date : [YYYY-MM-DD]
Billet source : #[XXXXXX]
═══════════════════════════════════════════════

SYMPTÔMES OBSERVÉS
• [Ce que le technicien ou l'utilisateur voit — exact et précis]
• [Symptôme 2 si applicable]

CAUSE RACINE IDENTIFIÉE
[La VRAIE cause — pas le symptôme visible.
Ex: Une tâche planifiée GPO lançait gpupdate.exe toutes les 4h,
les processus s'empilaient → CPU 100%]

SOLUTION
Étapes de résolution :
1. [Action 1 — précise et actionnable]
   ✅ Validation : [Ce qu'on doit voir/observer]
2. [Action 2]
   ✅ Validation : [...]
3. [Action 3]

COMMANDES CLÉS
```powershell
# [Description de ce que fait la commande]
[Commande exacte utilisée]
```

POINTS D'ATTENTION
⛔ NE PAS [action à éviter] — Raison : [conséquence]
⚠️ [Point de vigilance — ex: redémarrer ce service peut impacter les sessions RDS actives]

VALIDATIONS FINALES
[ ] [Test de validation 1]
[ ] [Test de validation 2]

TAGS : [windows] [AD] [performance] [gpupdate] [etc.]
═══════════════════════════════════════════════
```

---

## PARTIE 2 — NOUVELLE PROCÉDURE

```
═══════════════════════════════════════════════
PROCÉDURE — [TITRE]
ID            : PROC-[YYYYMMDD]-[NNN]
Catégorie     : [Maintenance / Support / Sécurité / Backup / Réseau]
Applicabilité : [Tous clients / Client spécifique : NOM]
Niveau requis : N1 / N2 / N3
Durée estimée : [X min]
Créé par      : [Technicien] | Date : [YYYY-MM-DD]
Approuvé par  : [Superviseur / Lead]
═══════════════════════════════════════════════

OBJECTIF
[En 1-2 phrases : pourquoi cette procédure existe et quand l'utiliser]

DÉCLENCHEURS
• [Situation 1 qui nécessite cette procédure]
• [Situation 2]

PRÉREQUIS
[ ] [Accès requis / outils requis]
[ ] [Autorisation requise]
[ ] [Autre prérequis]

ÉTAPES
1. [Action précise]
   ✅ Validation : [Ce qu'on doit observer]
   ⛔ NE PAS : [Action interdite dans ce contexte]
2. [Action suivante]
3. [...]

ROLLBACK (si applicable)
[Comment annuler si quelque chose se passe mal]

DOCUMENTATION
[ ] Documenter dans CW : Note interne avec résultats
[ ] Mettre à jour Hudu si applicable
[ ] Créer un KB si nouveau type de problème résolu
═══════════════════════════════════════════════
```
