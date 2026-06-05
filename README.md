# CNNC-Lab paper template

[![Lint](https://github.com/CNNC-Lab/paper-template/actions/workflows/lint.yml/badge.svg)](https://github.com/CNNC-Lab/paper-template/actions/workflows/lint.yml)
[![LaTeX](https://github.com/CNNC-Lab/paper-template/actions/workflows/latex.yml/badge.svg)](https://github.com/CNNC-Lab/paper-template/actions/workflows/latex.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A single, portable LaTeX repository for computational-neuroscience manuscripts that carries a paper
through the whole publication lifecycle: **draft → submission → peer review → tracked revision →
camera-ready**.

It is opinionated about *structure and compliance*, not about content: standardized typography,
canonical sections with per-journal overrides, machine-readable journal limits, editorial
correspondence, a self-contained rebuttal format, and journal-standard change tracking.

## Quickstart

```bash
make                      # build main.pdf (draft mode)
make submission           # review-ready manuscript (line numbers, figures at end)
make check JOURNAL=elife  # check word/figure/abstract limits for a journal
git tag submitted         # tag the version you submit
make diff OLD=submitted   # after revising: marked-up diff.pdf
make rebuttal             # build the response-to-reviewers letter
make cover                # build the cover letter
```

Full manual: **[INSTRUCTIONS.md](INSTRUCTIONS.md)**.

## What's here

| Path | Purpose |
|------|---------|
| `cnnclab.cls` | Document class — typography + `draft`/`submission`/`review`/`final` options. |
| `sections/` | Canonical content (write here). |
| `variants/<journal>/` | Override-only per-journal sections. |
| `journals/<journal>.md` | Machine-readable journal limits (drives `make check`). |
| `correspondence/cover-letter.tex` | Letter to the editor. |
| `review/response-to-reviewers.tex` | Rebuttal (`\point`/`\reply`, tcolorbox boxes). |
| `scripts/check-limits.py` | Word/figure/reference limit checker (reports only). |
| `templates/main-elife.tex` | Worked example wiring a variant + journal profile. |
| `ADAPTATION.md` | Guardrails for the optional formatting agent. |

## Overleaf

The Makefile is a convenience, not a requirement — the template is **Overleaf-native**. Import the
repo (*New Project → Import from GitHub*), set the main document (`main.tex`, or
`templates/main-elife.tex` for the eLife variant), and compile with pdfLaTeX; Overleaf runs biber
automatically. Switch modes by editing `\documentclass[submission]{cnnclab}` directly. See
[INSTRUCTIONS.md §1b](INSTRUCTIONS.md). Every document compiles from the project root with a bare
`latexmk` — the same invocation Overleaf uses — and CI enforces it.

## Requirements

TeX Live 2023+ (full), Git, Python 3.11+. Everything used ships with a standard TeX Live install —
no extra CTAN fetches. Optional `texcount` for sharper word counts.

## Attribution

Derived from the **Henriques Lab LaTeX template** by Ricardo Henriques. Original and derivative are
both MIT-licensed — see [LICENSE](LICENSE). Adaptation (publication-lifecycle tooling: journal
profiles, limit checker, rebuttal format, change-tracking targets) by the CNNC Lab.
