# 00_FACTORY_SYNC — Synchronisation Produit → Factory

Ce dossier est l'interface entre le produit MSP Intelligence AI et la Factory.

Flux :
1. IT-OPS-SyncFactory analyse les changements du produit
2. Écrit un rapport dans outbox/ au format FACTORY_SYNC_{date}.yaml
3. La Factory lit outbox/ et met à jour son registre de produits

Responsable : IT-OPS-SyncFactory
Fréquence : À chaque changement structurel (nouvel agent, nouveau module, version majeure)
