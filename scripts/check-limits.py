#!/usr/bin/env python3
"""Check a manuscript against a journal's limits. Reports only — never edits.

Reads a journal profile (journals/<name>.md, YAML frontmatter) and the manuscript
sources (sections/ + any variants/<journal>/ overrides), then reports word/figure/
reference counts as PASS / OVER. Exits non-zero if any hard limit is exceeded so it
can gate `make check` or CI.

Usage:
    python3 scripts/check-limits.py --journal elife
    python3 scripts/check-limits.py --journal elife --repo /path/to/repo
"""

from __future__ import annotations

import argparse
import re
import shutil
import subprocess
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    yaml = None


def parse_frontmatter(md_path: Path) -> dict:
    """Extract the YAML frontmatter block from a journal profile."""
    text = md_path.read_text(encoding="utf-8")
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.DOTALL)
    if not m:
        sys.exit(f"No YAML frontmatter found in {md_path}")
    block = m.group(1)
    if yaml is not None:
        return yaml.safe_load(block) or {}
    return _mini_yaml(block)


def _mini_yaml(block: str) -> dict:
    """Tiny fallback parser for flat key: value frontmatter (no PyYAML)."""
    out: dict = {}
    for line in block.splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if ":" not in line:
            continue
        key, _, val = line.partition(":")
        key, val = key.strip(), val.strip()
        if val in ("null", "~", ""):
            out[key] = None
        elif val.lstrip("-").isdigit():
            out[key] = int(val)
        elif val.startswith("[") and val.endswith("]"):
            out[key] = [x.strip() for x in val[1:-1].split(",") if x.strip()]
        elif val.startswith("{"):
            out[key] = {}
        else:
            out[key] = val.strip('"')
    return out


def resolve_section(repo: Path, journal: str, name: str) -> Path | None:
    """variants/<journal>/<name>.tex if it exists, else sections/<name>.tex."""
    variant = repo / "variants" / journal / f"{name}.tex"
    if variant.exists():
        return variant
    canonical = repo / "sections" / f"{name}.tex"
    return canonical if canonical.exists() else None


def strip_latex(text: str) -> str:
    """Crude LaTeX -> plain text for word counting (fallback path)."""
    text = re.sub(r"(?<!\\)%.*", "", text)            # comments
    text = re.sub(r"\\[a-zA-Z@]+\*?(\[[^\]]*\])?", " ", text)  # commands + optargs
    text = re.sub(r"[{}\\$&~^_]", " ", text)          # residual markup
    return text


def count_words(tex_path: Path) -> int:
    """Word count via texcount if available, else a built-in tokenizer."""
    if shutil.which("texcount"):
        try:
            out = subprocess.run(
                ["texcount", "-1", "-sum", "-merge", str(tex_path)],
                capture_output=True, text=True, check=True,
            ).stdout.strip()
            return int(out.split()[0])
        except (subprocess.CalledProcessError, ValueError, IndexError):
            pass
    words = strip_latex(tex_path.read_text(encoding="utf-8")).split()
    return len(words)


def count_figures(repo: Path, journal: str, sections: list[str]) -> int:
    n = 0
    for name in sections:
        p = resolve_section(repo, journal, name)
        if p:
            n += len(re.findall(r"\\begin\{figure", p.read_text(encoding="utf-8")))
    return n


def count_references(repo: Path) -> int:
    bib = repo / "refs.bib"
    if not bib.exists():
        return 0
    return len(re.findall(r"^@\w+\s*\{", bib.read_text(encoding="utf-8"), re.MULTILINE))


def report(label: str, count: int, limit, unit: str = "words") -> bool:
    """Print one line; return True if PASS (or no limit), False if OVER."""
    if limit in (None, "null"):
        print(f"  {label:<12} {count:>5} {unit:<6} (no limit)        --")
        return True
    if count <= limit:
        print(f"  {label:<12} {count:>5} / {limit} {unit:<6} PASS")
        return True
    over = count - limit
    print(f"  {label:<12} {count:>5} / {limit} {unit:<6} OVER by {over}")
    return False


def main() -> int:
    ap = argparse.ArgumentParser(description="Check manuscript against journal limits.")
    ap.add_argument("--journal", required=True, help="journal profile name (journals/<name>.md)")
    ap.add_argument("--repo", default=".", help="repo root (default: cwd)")
    args = ap.parse_args()

    repo = Path(args.repo).resolve()
    profile = repo / "journals" / f"{args.journal}.md"
    if not profile.exists():
        sys.exit(f"No journal profile: {profile}")

    fm = parse_frontmatter(profile)
    journal = args.journal
    sections = fm.get("sections_order") or ["introduction", "results", "discussion", "methods"]

    print(f"Checking against: {fm.get('journal', journal)}  ({profile.name})\n")

    ok = True

    # Abstract
    abs_path = resolve_section(repo, journal, "abstract")
    if abs_path:
        ok &= report("abstract", count_words(abs_path), fm.get("abstract_words"))

    # Per-section word counts (informational) + main-text total
    total = 0
    for name in sections:
        p = resolve_section(repo, journal, name)
        if not p:
            continue
        w = count_words(p)
        total += w
        report(name, w, None)
    ok &= report("main-text", total, fm.get("main_text_words"))

    # Figures and references
    ok &= report("figures", count_figures(repo, journal, sections), fm.get("figures_max"), "figs")
    ok &= report("references", count_references(repo), fm.get("references_max"), "refs")

    print()
    if ok:
        print("All hard limits satisfied.")
        return 0
    print("One or more hard limits exceeded.")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
