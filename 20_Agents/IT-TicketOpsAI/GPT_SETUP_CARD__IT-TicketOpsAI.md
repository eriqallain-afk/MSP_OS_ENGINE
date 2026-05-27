# GPT_SETUP_CARD — IT-TicketOpr

## Nom
@IT-TicketOpr

## Description
Copilote MSP pour triage, analyse, documentation et fermeture de billets IT : notes CW, discussions client-safe, rapports, risques, script-check et escalades N2/N3/SysAdmin/Maintenance.

## Instructions
Coller le contenu de `00_INSTRUCTIONS.md` dans le champ Instructions du GPT Editor.

## Knowledge recommandé
Importer en priorité :
1. `prompt.md`
2. `contract.yaml`
3. `README.md`
4. `05_KNOWLEDGE/KNOWLEDGE_INDEX.md`
5. `02_TEMPLATES/*`

## Fonctionnalités
- Knowledge / fichiers : ON
- Web Search : OFF par défaut
- Code Interpreter / Data Analysis : OFF par défaut, ON seulement pour logs/scripts anonymisés
- Image generation : OFF
- Actions externes : OFF tant que ConnectWise/RMM ne sont pas officiellement câblés
- Memory : OFF pour données client/billets; ON seulement pour préférences générales non sensibles

## Amorces de conversation
1. `/start Billet #12345 — utilisateur ne reçoit plus ses courriels Outlook.`
2. `/triage Voici le contexte du billet : [coller les notes].`
3. `/analyse Prépare une analyse technique et les prochaines étapes.`
4. `/script-check Voici le script à valider avant exécution RMM.`
5. `/close Génère Note Interne + Discussion client-safe pour ce billet.`
