#!/usr/bin/env python3
"""
rebuild_it_shared_asset_index.py

But:
- Scanner IT/IT-SHARED/{10_RUNBOOKS,20_TEMPLATES,30_SCRIPTS,40_CHECKLISTS,50_REFERENCE}
- Extraire les métadonnées (front-matter YAML en tête de fichier)
- Générer IT/IT-SHARED/00_INDEX/IT_SHARED__ASSET_INDEX.generated.yaml

Usage:
  python rebuild_it_shared_asset_index.py --root IT/IT-SHARED --out IT/IT-SHARED/00_INDEX/IT_SHARED__ASSET_INDEX.generated.yaml
"""
from __future__ import annotations
import argparse, os, re, sys, json
from datetime import datetime, timezone
from pathlib import Path

try:
    import yaml
except ImportError:
    print("Missing dependency: pyyaml. Install with `pip install pyyaml`.", file=sys.stderr)
    raise

FRONT_MATTER_RE = re.compile(r"^---\s*\n(.*?)\n---\s*\n", re.DOTALL)

TYPE_MAP = {
    "10_RUNBOOKS": "runbook",
    "20_TEMPLATES": "template",
    "30_SCRIPTS": "script",
    "40_CHECKLISTS": "checklist",
    "50_REFERENCE": "reference",
}

def read_front_matter(path: Path) -> dict | None:
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return None
    m = FRONT_MATTER_RE.match(text)
    if not m:
        return None
    try:
        meta = yaml.safe_load(m.group(1)) or {}
    except Exception:
        return None
    return meta if isinstance(meta, dict) else None

def discover_files(root: Path) -> list[Path]:
    exts = {".md", ".markdown", ".txt", ".yml", ".yaml", ".ps1", ".sh", ".py", ".json"}
    out = []
    for p in root.rglob("*"):
        if p.is_file() and p.suffix.lower() in exts and ".git" not in p.parts:
            out.append(p)
    return out

def infer_type(path: Path, root: Path) -> str | None:
    rel = path.relative_to(root)
    top = rel.parts[0] if rel.parts else ""
    return TYPE_MAP.get(top)

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", required=True, help="Chemin vers IT/IT-SHARED")
    ap.add_argument("--out", required=True, help="Fichier YAML de sortie")
    args = ap.parse_args()

    root = Path(args.root).resolve()
    out_path = Path(args.out).resolve()
    out_path.parent.mkdir(parents=True, exist_ok=True)

    assets = []
    for file in discover_files(root):
        t = infer_type(file, root)
        if not t:
            continue
        meta = read_front_matter(file) or {}
        asset_id = meta.get("asset_id")
        title = meta.get("title") or file.stem.replace("_", " ").replace("__", " — ")
        desc = meta.get("description") or meta.get("summary") or ""
        use_cases = meta.get("use_cases") or []
        tags = meta.get("tags") or []
        service_area = meta.get("service_area") or []
        lifecycle = meta.get("lifecycle") or "active"
        owner = meta.get("owner") or "IT"
        signals = meta.get("signals") or []

        # Skip assets without minimal info? Here we keep them, but mark them.
        entry = {
            "asset_id": asset_id or f"{t.upper()}__AUTO__{file.stem[:48]}",
            "type": meta.get("type") or t,
            "title": title,
            "description": desc,
            "path": str(file.as_posix()),
            "use_cases": use_cases,
            "service_area": service_area,
            "tags": tags,
            "router_hints": {"signals": signals, "intents": meta.get("intents") or []},
            "governance": {
                "owner": owner,
                "lifecycle": lifecycle,
                "last_reviewed": meta.get("last_reviewed"),
                "source": "IT-SHARED",
            }
        }
        assets.append(entry)

    doc = {
        "schema_version": "1.0",
        "generated_at": datetime.now(timezone.utc).astimezone().isoformat(),
        "repo": "eriqallain-afk/IT/IT-SHARED",
        "description": "Index auto-généré des assets IT-SHARED.",
        "assets_count": len(assets),
        "assets": sorted(assets, key=lambda a: (a["type"], a["title"].lower())),
    }

    with out_path.open("w", encoding="utf-8") as f:
        yaml.safe_dump(doc, f, sort_keys=False, allow_unicode=True)

    print(f"OK: wrote {len(assets)} assets to {out_path}")

if __name__ == "__main__":
    main()
