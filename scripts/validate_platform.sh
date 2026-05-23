#!/usr/bin/env bash
# validate_platform.sh — MSP Intelligence AI
# Usage: bash scripts/validate_platform.sh
# Détecte tous les désyncs plateforme en < 10 secondes.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS_DIR="$REPO_ROOT/20_Agents"
AGENTS_INDEX="$REPO_ROOT/00_INDEX/agents_index.yaml"
FACTORY_MANIFEST="$REPO_ROOT/FACTORY_MANIFEST_IT.yaml"
GPT_CATALOG="$REPO_ROOT/00_INDEX/gpt_catalog.yaml"

RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

ERRORS=0; WARNINGS=0

header() { echo -e "\n${CYAN}${BOLD}══ $1 ══${NC}"; }
ok()     { echo -e "  ${GREEN}✓${NC} $1"; }
warn()   { echo -e "  ${YELLOW}⚠${NC}  $1"; WARNINGS=$((WARNINGS+1)); }
fail()   { echo -e "  ${RED}✗${NC} $1"; ERRORS=$((ERRORS+1)); }

echo -e "${BOLD}MSP Intelligence AI — Validation plateforme  $(date '+%Y-%m-%d %H:%M')${NC}"
echo "Repo : $REPO_ROOT"

# ─────────────────────────────────────────────
header "1. COMPTAGE AGENTS"

count_disk=$(find "$AGENTS_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')
count_index=$(grep -c '^\s\{2\}IT-' "$AGENTS_INDEX" 2>/dev/null || echo "?")
count_manifest=$(grep 'agents_count:' "$FACTORY_MANIFEST" | head -1 | grep -oE '[0-9]+' || echo "?")

echo "  20_Agents/       : $count_disk dossiers"
echo "  agents_index     : $count_index entrées"
echo "  FACTORY_MANIFEST : $count_manifest déclaré"

if [ "$count_disk" = "$count_index" ] && [ "$count_disk" = "$count_manifest" ]; then
    ok "Comptage cohérent ($count_disk agents)"
else
    fail "Désync comptage — disk:$count_disk  index:$count_index  manifest:$count_manifest"
fi

# ─────────────────────────────────────────────
header "2. FICHIERS OBLIGATOIRES PAR AGENT"

missing_files=0
for agent_dir in "$AGENTS_DIR"/*/; do
    agent_id=$(basename "$agent_dir")
    agent_missing=""
    for f in agent.yaml prompt.md contract.yaml 00_INSTRUCTIONS.md 04_KNOWLEDGE_INDEX.md; do
        [ ! -f "$agent_dir/$f" ] && agent_missing="$agent_missing $f"
    done
    if [ -n "$agent_missing" ]; then
        fail "$agent_id : manque$agent_missing"
        missing_files=$((missing_files+1))
    fi
done
[ "$missing_files" -eq 0 ] && ok "Tous les agents ont leurs 5 fichiers obligatoires"

# ─────────────────────────────────────────────
header "2b. SETUP CARD PAR AGENT"

missing_cards=0
for agent_dir in "$AGENTS_DIR"/*/; do
    agent_id=$(basename "$agent_dir")
    has_card=false
    ls "$agent_dir"GPT_SETUP_CARD__* 2>/dev/null | grep -q . && has_card=true
    [ -f "$agent_dir/setupCard.md" ] && has_card=true
    if ! $has_card; then
        fail "$agent_id : GPT_SETUP_CARD manquante"
        missing_cards=$((missing_cards+1))
    fi
done
[ "$missing_cards" -eq 0 ] && ok "Tous les agents ont une GPT_SETUP_CARD"

# ─────────────────────────────────────────────
header "3. COHÉRENCE 20_Agents/ ↔ agents_index.yaml"

disk_missing_index=0
for agent_dir in "$AGENTS_DIR"/*/; do
    agent_id=$(basename "$agent_dir")
    if ! grep -q "  $agent_id:" "$AGENTS_INDEX" 2>/dev/null; then
        fail "20_Agents/$agent_id non référencé dans agents_index.yaml"
        disk_missing_index=$((disk_missing_index+1))
    fi
done
[ "$disk_missing_index" -eq 0 ] && ok "Tous les dossiers 20_Agents/ sont dans agents_index"

index_missing_disk=0
while IFS= read -r line; do
    aid=$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/:.*//')
    if [ -n "$aid" ] && [ ! -d "$AGENTS_DIR/$aid" ]; then
        fail "agents_index: $aid — aucun dossier dans 20_Agents/"
        index_missing_disk=$((index_missing_disk+1))
    fi
done < <(grep '^\s\{2\}IT-' "$AGENTS_INDEX")
[ "$index_missing_disk" -eq 0 ] && ok "Tous les agents de l'index ont un dossier sur disque"

# ─────────────────────────────────────────────
header "4. AGENTS STAGING MAL PLACÉS"

staging_bad=0
for agent_dir in "$AGENTS_DIR"/*/; do
    agent_id=$(basename "$agent_dir")
    agent_yaml="$agent_dir/agent.yaml"
    if [ -f "$agent_yaml" ]; then
        status=$(grep 'status:' "$agent_yaml" | head -1 | awk '{print $2}' | tr -d '"'"'"'')
        if [ "$status" = "staging" ]; then
            fail "$agent_id a status:staging mais est dans 20_Agents/ — devrait être dans 99_STAGING/"
            staging_bad=$((staging_bad+1))
        fi
    fi
done
[ "$staging_bad" -eq 0 ] && ok "Aucun agent staging dans 20_Agents/"

# ─────────────────────────────────────────────
header "5. BLOCS OBLIGATOIRES 00_INSTRUCTIONS.md (5 premiers agents)"

checked=0; block_errors=0
for agent_dir in "$AGENTS_DIR"/*/; do
    [ "$checked" -ge 5 ] && break
    agent_id=$(basename "$agent_dir")
    instr="$agent_dir/00_INSTRUCTIONS.md"
    if [ -f "$instr" ]; then
        if ! grep -q "curité\|Security\|SECURIT\|Non négociable" "$instr" 2>/dev/null; then
            fail "$agent_id/00_INSTRUCTIONS.md : bloc Sécurité manquant"
            block_errors=$((block_errors+1))
        fi
        if ! grep -q "RUNBOOKS GITHUB" "$instr" 2>/dev/null; then
            fail "$agent_id/00_INSTRUCTIONS.md : bloc RUNBOOKS GITHUB manquant"
            block_errors=$((block_errors+1))
        fi
        checked=$((checked+1))
    fi
done
[ "$block_errors" -eq 0 ] && ok "Blocs obligatoires présents (spot-check $checked agents)"

# ─────────────────────────────────────────────
header "6. CHEMINS 00_INSTRUCTIONS.md dans gpt_catalog"

catalog_errors=0
while IFS= read -r line; do
    path=$(echo "$line" | sed 's/.*instructions:[[:space:]]*//' | tr -d '"'"'" | tr -d ' ')
    if [ -n "$path" ] && [ ! -f "$REPO_ROOT/$path" ]; then
        fail "gpt_catalog chemin invalide : $path"
        catalog_errors=$((catalog_errors+1))
    fi
done < <(grep 'instructions:' "$GPT_CATALOG" 2>/dev/null)
[ "$catalog_errors" -eq 0 ] && ok "Tous les chemins instructions gpt_catalog sont valides"

# ─────────────────────────────────────────────
header "RÉSUMÉ FINAL"

echo ""
if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "  ${GREEN}${BOLD}✓ PLATEFORME 100% — Aucun désync détecté${NC}"
elif [ "$ERRORS" -eq 0 ]; then
    echo -e "  ${YELLOW}${BOLD}⚠  $WARNINGS avertissement(s) — Plateforme fonctionnelle${NC}"
else
    echo -e "  ${RED}${BOLD}✗ $ERRORS erreur(s) | $WARNINGS avertissement(s)${NC}"
    echo -e "  ${RED}  Corriger avant la prochaine session.${NC}"
    exit 1
fi
