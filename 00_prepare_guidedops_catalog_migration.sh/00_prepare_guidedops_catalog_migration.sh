#!/usr/bin/env bash
set -euo pipefail

REQUIRED_BRANCH="guidedops/catalog-migration-v1"
CATALOG_DIR="IT-SHARED/10_CATALOG"

echo "=== GuidedOps Catalog Migration Prep ==="

CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"

if [ "$CURRENT_BRANCH" != "$REQUIRED_BRANCH" ]; then
  echo "ERREUR: branche actuelle: $CURRENT_BRANCH"
  echo "Tu dois être sur: $REQUIRED_BRANCH"
  echo ""
  echo "Commande:"
  echo "  git checkout $REQUIRED_BRANCH"
  exit 1
fi

echo "OK: branche correcte: $CURRENT_BRANCH"

echo ""
echo "=== Création des dossiers ==="
mkdir -p "$CATALOG_DIR"

echo "Dossier prêt: $CATALOG_DIR"

echo ""
echo "=== Fichiers attendus à copier manuellement ==="
cat <<EOF
À placer dans:
$CATALOG_DIR/

- RUNBOOK_CATALOG_GUIDEDOPS.md
- RUNBOOK_CATALOG_GUIDEDOPS_table.csv
- LEGACY_PATH_REGISTRY_RUNBOOK_MENU_V4.md
- LEGACY_PATH_REGISTRY_RUNBOOK_MENU_V4.csv
- TRIAGE_INITIAL_IT_MSP_INTELLIGENCE.md
- IT_MSP_Intelligence_Master_Inventory_initial.csv
EOF

echo ""
echo "=== Vérification fichier critique legacy ==="
if [ -f "IT-SHARED/RUNBOOK_MENU_CONTEXTUEL_V4.md" ]; then
  echo "OK: IT-SHARED/RUNBOOK_MENU_CONTEXTUEL_V4.md existe"
else
  echo "ATTENTION: IT-SHARED/RUNBOOK_MENU_CONTEXTUEL_V4.md introuvable"
fi

echo ""
echo "=== État Git ==="
git status --short

echo ""
echo "=== Diff stat ==="
git diff --stat || true

echo ""
echo "Préparation terminée."
echo "Aucune suppression ni déplacement effectué."