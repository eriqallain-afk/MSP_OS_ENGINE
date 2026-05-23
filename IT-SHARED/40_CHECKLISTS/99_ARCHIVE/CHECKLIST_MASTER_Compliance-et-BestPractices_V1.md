# CHECKLIST_MASTER_Compliance-et-BestPractices_V1
**Agent :** IT-MaintenanceMaster, IT-SecurityMaster
**Usage :** Vérification trimestrielle de la conformité MSP et des bonnes pratiques
**Mis à jour :** 2026-03-20

---

## DOCUMENTATION CLIENT (Hudu / edocs)

- [ ] Fiche de chaque serveur critique à jour (OS, rôle, IP de gestion → Passportal)
- [ ] Fiche de chaque solution backup configurée
- [ ] Fiche des équipements réseau (firewall, switches) à jour
- [ ] Contacts d'urgence à jour (responsable IT, décideur pour DR)
- [ ] Plan de relève documenté et à jour (< 6 mois)
- [ ] Aucun champ `[À COMPLÉTER]` publié sans valeur

---

## GESTION DES ACCÈS

- [ ] Tous les credentials dans Passportal (zéro MDP dans CW, Hudu, emails)
- [ ] Comptes de service documentés avec leur usage et leur rotation planifiée
- [ ] Accès client révoqués pour les techniciens qui ont quitté l'équipe
- [ ] MFA actif sur tous les portails MSP (CW, Datto, N-able, M365 admin)

---

## TICKETS ET PROCESSUS

- [ ] Aucun ticket P1/P2 ouvert sans technicien assigné
- [ ] Billets > 14 jours sans activité identifiés et traités
- [ ] Notes internes sur tous les billets actifs (pas de billets sans contexte)
- [ ] Closures CW : toutes avec Note Interne + Discussion client-safe

---

## COMMUNICATION CLIENT

- [ ] Rapport mensuel envoyé pour les clients sous contrat (< 5 jours après fin de mois)
- [ ] QBR planifié pour les clients stratégiques (trimestriel)
- [ ] Aucun incident P1 non documenté avec postmortem

---

## OUTILS ET MONITORING

- [ ] Agents RMM déployés sur 100% des serveurs et postes gérés
- [ ] Alertes critiques configurées : CPU, RAM, disque, service critique, offline
- [ ] Mode maintenance RMM utilisé systématiquement lors des interventions
- [ ] Seuils d'alerte révisés (pas les valeurs par défaut génériques)

---

## SÉCURITÉ OPÉRATIONNELLE

- [ ] Logs firewall activés sur tous les sites
- [ ] Rapport EDR vérifié (alertes ouvertes / fermées)
- [ ] Patchs critiques (CVSS ≥ 7.0) appliqués dans les 30 jours sur tous les serveurs
- [ ] Aucun RDP exposé directement sur Internet

---

## RÉSULTAT

**Conformité globale :** _______ / _______ items
**Effectué par :** _______ | **Date :** _______ | **Prochain audit :** _______
**Actions prioritaires :**
1. _______
2. _______
