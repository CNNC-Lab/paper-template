# INSTRUCTIONS — using the CNNC-Lab paper template

A complete, end-to-end manual for taking a manuscript from first draft through
submission, peer review, tracked revision, and camera-ready final using this template.

> **TL;DR**
> ```bash
> make                      # build main.pdf (draft mode)
> make submission           # build the review-ready manuscript (line numbers, figs at end)
> make check JOURNAL=elife  # check word/figure/abstract limits for a journal
> git tag submitted         # tag the version you submit
> make diff OLD=submitted   # after revising: marked-up diff.pdf for resubmission
> make rebuttal             # build the response-to-reviewers letter
> make cover                # build the cover letter
> ```

---

## 0. Requirements

- **TeX Live 2023+** (everything used here ships with a standard full install — no extra CTAN
  fetches). Needs: `latexmk`, `biber`, `latexdiff` / `latexdiff-vc`, `pdflatex`, and the
  `tcolorbox`, `changes`, `lineno`, `endfloat`, `biblatex`, `todonotes` packages.
- **Git** (for tagging revisions and for `latexdiff-vc --git`).
- **Python 3.11+** for `scripts/check-limits.py`. Optional: `texcount` (sharper word counts; the
  script falls back to a built-in tokenizer if absent).

Quick check:
```bash
for t in latexmk biber latexdiff-vc python3; do command -v $t || echo "MISSING: $t"; done
```

---

## 1. Repository tour

```
cnnclab.cls            The document class. Defines the look + all class options.
main.tex               Default manuscript entry point. Edit metadata here; \input sections.
refs.bib               Your bibliography (biblatex + biber).
sections/              Canonical content. One .tex per section. THIS is where you write.
variants/<journal>/    Override-only files: a section here REPLACES the canonical one
                       for that journal's build. Only put a file here if it differs.
journals/<journal>.md  Machine-readable journal rules (limits, section order). Drives `make check`.
correspondence/        cover-letter.tex — your letter to the editor.
review/                response-to-reviewers.tex — the rebuttal.
scripts/check-limits.py  Counts words/figures/refs vs a journal profile. Reports only.
templates/             Worked examples (e.g. main-elife.tex) wiring a variant + profile.
figures/               Figures (PDF/PNG/EPS).
Makefile               All build/diff/check/clean targets.
ADAPTATION.md          Rules for the (optional) formatting agent. Read before automating.
```

---

## 1b. Using this on Overleaf (no Makefile required)

The Makefile is a **local/CI convenience**, not a requirement. Every document in this repo
compiles on its own with a single click in Overleaf, because all paths are written relative to
the **project root** — which is exactly how Overleaf compiles.

**Import the project**
- *New Project → Import from GitHub* and point at `CNNC-Lab/paper-template` (keeps it synced), or
- download a zip of the repo and *New Project → Upload Project*.

`cnnclab.cls` lives at the project root, so Overleaf finds it automatically.

**Set the main document** (Menu → *Main document*):
- `main.tex` — the manuscript (default).
- `templates/main-elife.tex` — the eLife variant build (sets `\ACTIVEJOURNAL` then inputs `main.tex`).
- `review/response-to-reviewers.tex` — the rebuttal.
- `correspondence/cover-letter.tex` — the cover letter.

Each of these has its own `\documentclass`/`\begin{document}` and compiles standalone from the root.

**Compiler & bibliography**: leave the compiler on *pdfLaTeX* (Menu → *Compiler*). Overleaf runs
`latexmk`, which detects biblatex and runs **biber** automatically — no extra setup. (Do not set
the bibliography tool to "bibtex"; this template uses biber.)

**Switching modes without `make`**: the `make submission`/`final` targets just pass a class option.
On Overleaf, do the same by editing the first line of `main.tex` directly:
```latex
\documentclass[submission]{cnnclab}   % or [review], [final], [draft]
```

**What stays local / CI only** (Overleaf doesn't need these):
- `make diff` (tracked-changes PDF) — on Overleaf use its built-in *History → compare* / track changes.
- `make check JOURNAL=…` (limit checker) — run locally or let GitHub Actions run it on push.

> Sanity check used in CI: every document is compiled with a bare `latexmk -pdf <file>` from the
> repo root — the same invocation Overleaf uses — so "compiles with `make`" and "compiles on
> Overleaf" can't drift apart.

---

## 2. Writing the manuscript

1. Put author/title metadata at the top of `main.tex`:
   ```latex
   \documentclass[draft]{cnnclab}
   \title{...}
   \author{R. Duarte\,\orcidlink{0000-0001-6099-667X}\textsuperscript{1,2}}
   \affiliation{1}{CNC-UC -- Center for Neuroscience and Cell Biology, University of Coimbra, ...}
   \affiliation{2}{CIBB -- Centre for Innovative Biomedicine and Biotechnology, University of Coimbra, ...}
   \corresponding{rcfduarte@gmail.com}
   \keywords{...}
   \addbibresource{refs.bib}
   ```
   - **Affiliations:** one `\affiliation{<mark>}{<text>}` per call; they render in small type under
     the authors. CNC-UC researchers must use the **CNC-UC** and **CIBB** affiliations separately.
   - **ORCID:** put `\orcidlink{<id>}` anywhere in `\author` (it renders the linked iD icon).
2. Write each section in its own file under `sections/` (`introduction.tex`, `results.tex`, …).
   `main.tex` pulls them in with `\sectioninput{introduction}` (the class macro that honors
   variants — see §4).
3. Build as you go:
   ```bash
   make            # = make pdf, draft mode: figures in place, line numbers, todonotes on
   ```
4. Use `\todo{...}` / `\todo[inline]{...}` for working notes — they appear only in `draft` mode
   and vanish in `submission`/`final`.

### Class options (set in `\documentclass[...]{cnnclab}`)

| Option       | When to use it |
|--------------|----------------|
| `draft`      | Day-to-day writing. Figures in place, line numbers, todonotes visible, draft watermark. |
| `submission` | Building the file you upload for review. Double-spaced, line-numbered, figures at end. |
| `review`     | Revising with **inline** tracked changes (`changes` package; see §7b). |
| `final`      | Camera-ready. Single-spaced, figures in place, no line numbers, all markup stripped. |
| `endfloat`   | Force figures/tables to the end independently. |
| `lineno`     | Force line numbers independently. |

`submission` already bundles `endfloat + lineno + double spacing`; you rarely combine them by hand.

### Acknowledgements & funding

Add a compact, smaller-than-a-section acknowledgements block before `\printbibliography`:
```latex
\begin{acknowledgements}
... funding text ...
\end{acknowledgements}
```
For **CNC-UC / CiBB** publications the institutional CiBB references are **mandatory** in every
paper (`LA/P/0058/2020`, `UID/PRR/4539/2025`, `UID/04539/2025`), plus the reference(s) of the
project(s) that fund your work (e.g. an FCT-PEX project). The default `main.tex` ships the correct
boilerplate — replace the project-specific line with your grant(s). Canonical source: the vault's
`Resources/publication-rules.md`.

---

## 3. Building — the Makefile

| Command | What it does |
|---------|--------------|
| `make` or `make pdf` | Build `main.pdf` via latexmk + biber. |
| `make submission` | Build the review-ready manuscript (`submission` option). |
| `make final` | Build the camera-ready PDF. |
| `make check JOURNAL=<name>` | Run the limit checker against `journals/<name>.md`. |
| `make diff OLD=<git-tag>` | Marked-up `diff.pdf` vs a tagged version (see §7a). |
| `make rebuttal` | Build `review/response-to-reviewers.pdf`. |
| `make cover` | Build `correspondence/cover-letter.pdf`. |
| `make clean` | Remove LaTeX aux files. |
| `make distclean` | Remove everything generated, including PDFs. |

All targets are latexmk-driven, so partial rebuilds are incremental and biber is run when refs change.

---

## 4. One source, many journals: the canonical + variant model

You write each section **once** in `sections/`. When a journal needs a *different* version of a
section (e.g. eLife wants a 150-word unstructured abstract), you create **only that file** under
`variants/<journal>/`.

How resolution works: `main.tex` calls `\sectioninput{abstract}`. The class macro looks for
`variants/<ACTIVEJOURNAL>/abstract.tex` first and `\input`s it if present; otherwise it falls
back to `sections/abstract.tex`.

To build for a specific journal, use a thin entry point that sets the active journal — see
`templates/main-elife.tex`:
```latex
\def\ACTIVEJOURNAL{elife}
\input{main.tex}
```
Then `latexmk templates/main-elife.tex` (or add a `make elife` convenience target).

**Golden rule:** a file lives in `variants/` *only if it differs* from canonical. Never copy a
section wholesale "just in case" — that defeats the single-source model and silently drifts.

---

## 5. Journal limits: `make check`

Each journal has a profile in `journals/<name>.md` with YAML frontmatter:
```yaml
---
journal: eLife
abstract_words: 150
title_chars: 150
main_text_words: null      # null = no hard limit
figures_max: null
references_max: null
sections_order: [introduction, results, discussion, methods]
---
```
Run:
```bash
make check JOURNAL=elife
```
Output is a PASS/OVER report per constraint, e.g.:
```
abstract   147 / 150 words      PASS
Results    820 words over limit  OVER
figures    6 / 8                 PASS
```
The script **exits non-zero** if any hard limit is exceeded — so you can gate a CI job or a
pre-submission check on it. It **never edits your files**; it only measures and reports.

Add a new journal by copying an existing profile and editing the frontmatter. No code changes
needed — `check-limits.py` is data-driven.

---

## 6. Cover letter

Edit `correspondence/cover-letter.tex` (editor name, journal, your pitch), then:
```bash
make cover        # → correspondence/cover-letter.pdf
```
It uses the same `cnnclab` typography as the manuscript and has no fragile letter-class deps.

---

## 7. The revision cycle

### 7a. Tracked changes for resubmission — `make diff` (the journal-standard way)

Most journals want a marked-up PDF showing what changed between the submitted and revised
versions. This template generates it by diffing two git states with `latexdiff`.

Workflow:
```bash
# When you submit:
git tag submitted
git push --tags          # optional

# ... do your revisions, commit them ...

# Generate the marked-up PDF (additions blue, deletions red):
make diff OLD=submitted  # → diff.pdf
```
Under the hood this runs `latexdiff-vc --flatten --git -r submitted main.tex`. `--flatten`
resolves the multi-file `\input`/`\sectioninput` structure into one diff.

**Caveats (important):**
- **Both** the old and the new versions must compile. If `submitted` didn't compile, diff against
  the nearest tag that did.
- **Same-named figures are not diffed** — latexdiff compares text, not images. If a figure changed
  but kept its filename, note the change in the rebuttal explicitly.
- Heavily restructured tables/math can produce noisy diffs; you can hand-tune with
  `latexdiff`'s `--math-markup` / `--config` if needed (see its man page).

### 7b. Inline tracked changes while you revise — `[review]` option

For deliberate, granular annotation *as you edit* (rather than an after-the-fact diff), build with
the `review` option and use the `changes` package macros:
```latex
\documentclass[review]{cnnclab}
...
\added{new sentence}
\deleted{removed text}
\replaced{new}{old}
```
Each author can have a color. Switch to `final` and the markup is stripped automatically. Use this
for collaborative edits where reviewers/co-authors want to see *who* changed *what*; use `make diff`
for the clean submission artifact.

### 7c. The rebuttal — `review/response-to-reviewers.tex`

Structure each reviewer point with the in-repo macros:
```latex
\reviewer{1}

\point\label{r1.1}
  The authors do not justify the choice of timescale.
\reply
  We now justify this in Methods (\cref{sec:methods-timescale}). We added Fig.~3b showing
  robustness across timescales \autocite{someref2024}.

\point\label{r1.2}
  ...
\reply
  ...
```
- Reviewer comments render in a boxed/italic `tcolorbox`; your reply follows below.
- `\cite`/`\autocite` work (biblatex-aware).
- `\label` on each `\point`/`\reply` lets the manuscript and the letter cross-reference each other
  (e.g. a margin note in the paper pointing back to `r1.1`).

Build it:
```bash
make rebuttal     # → review/response-to-reviewers.pdf
```

---

## 8. Camera-ready / final

```bash
make final
```
Single-spaced, figures back in place, line numbers off, all `changes` markup removed. Run
`make check JOURNAL=<name>` one last time, and re-tag:
```bash
git tag accepted
```

---

## 9. Recommended git tagging convention

| Tag | When |
|-----|------|
| `submitted` | The exact source you uploaded for first review. |
| `revised-r1` | After addressing round-1 reviews (target of `make diff OLD=submitted`). |
| `revised-r2` | After round 2, etc. |
| `accepted` | Final accepted version. |

`make diff OLD=submitted` after each round gives the marked-up PDF that round.

---

## 10. Adding things

- **A new journal:** copy `journals/elife.md` → `journals/<name>.md`, edit frontmatter. Add
  `variants/<name>/` only for sections that genuinely differ.
- **A new section:** add `sections/<name>.tex`, `\sectioninput{<name>}` in `main.tex`.
- **A new build target:** extend the `Makefile` (targets are thin latexmk wrappers).

---

## 11. Troubleshooting

| Symptom | Fix |
|---------|-----|
| `biber` not run / `??` citations | `make clean && make` (forces a full latexmk + biber pass). |
| `make diff` errors out | Confirm both `OLD` tag and HEAD compile; check the tag exists (`git tag`). |
| Variant not picked up | Confirm `\ACTIVEJOURNAL` is set *before* `\input{main.tex}` and the file is at `variants/<journal>/<name>.tex`. |
| Figures missing in diff | Expected — latexdiff doesn't diff images; note figure changes in the rebuttal. |
| `check-limits.py` word count looks off | Install `texcount` for accurate counts; the fallback tokenizer is approximate. |

---

## 12. What the automation may and may not do

If you use the formatting agent (`ADAPTATION.md`), it is a **compliance tool only**. It may reorder
or merge sections to a journal's required structure, relocate figures, compute counts, and report
what's over limit with concrete recommendations. It will **never** write or rewrite your scientific
prose. All content decisions stay with you.

---

*Provenance: forked from the Henriques Lab LaTeX template; original MIT license preserved in
`LICENSE`. See `README.md` for attribution.*
