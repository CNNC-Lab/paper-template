# Spec: CNNC-Lab/paper-template

**Status:** Approved (2026-06-05)
**Owner:** rcfduarte
**Provenance:** Forked from the Henriques Lab LaTeX template; original MIT license and
attribution preserved (see `LICENSE`, `README.md` attribution block).

## 1. Purpose

A single, portable LaTeX repository for writing computational-neuroscience manuscripts
that carries a paper all the way through the publication lifecycle:

draft → submission → peer review → revision (tracked changes) → resubmission → final.

The repo is opinionated about *structure and compliance*, not about content. It standardizes
typography, section layout, journal limits checking, editorial correspondence, rebuttal
formatting, and change-tracking — so the author spends time on science, not on reformatting
the same manuscript for the third journal.

## 2. Design principles

1. **One source, many targets.** Canonical content lives once in `sections/`. Journal-specific
   deviations are *override-only* files in `variants/<journal>/` — never full copies.
2. **Machine-readable journal rules.** Each journal's constraints live in `journals/<journal>.md`
   with a YAML frontmatter block that `scripts/check-limits.py` consumes.
3. **Self-contained.** No fragile external CTAN deps that aren't in a standard TeX Live. Reviewer
   boxes, rebuttal macros, and class options are all defined in-repo.
4. **Journal-standard artifacts.** Change tracking produces the exact marked-up PDF that PLOS,
   Elsevier, IEEE, Springer, MDPI, ACM expect (via `latexdiff`).
5. **Compliance, not authorship.** Any automation (the adaptation agent) reformats and reports;
   it never writes or rewrites scientific prose.

## 3. Repository layout

```
paper-template/
├── cnnclab.cls               # document class (see §4)
├── main.tex                  # default manuscript entry point
├── refs.bib                  # bibliography (biblatex + biber)
├── sections/                 # canonical content — one file per section
│   ├── abstract.tex
│   ├── introduction.tex
│   ├── results.tex
│   ├── discussion.tex
│   ├── methods.tex
│   └── ...
├── variants/                 # override-only per-journal sections
│   └── elife/
│       └── abstract.tex      # only the sections that differ from canonical
├── journals/                 # machine-readable journal profiles (see §6)
│   ├── elife.md
│   ├── plos-comp-biol.md
│   └── ...
├── correspondence/
│   └── cover-letter.tex      # letter to the editor (minimal letter style)
├── review/
│   └── response-to-reviewers.tex   # rebuttal (see §7)
├── scripts/
│   └── check-limits.py       # word/figure/abstract limit checker (see §6)
├── templates/
│   └── main-elife.tex        # worked example wiring a variant + journal profile
├── figures/
├── Makefile                  # build, diff, check targets (see §8)
├── LICENSE                   # original Henriques MIT license, preserved
├── README.md                 # quickstart + attribution
├── INSTRUCTIONS.md           # detailed end-to-end usage guide (the manual)
└── ADAPTATION.md             # adaptation-agent guardrails (see §9)
```

## 4. Document class — `cnnclab.cls`

Single-column, clean typography. Built on `article` (or `scrartcl`); biblatex with biber backend.

**Class options:**

| Option        | Effect |
|---------------|--------|
| `submission`  | Double-spaced, line numbers (`lineno`), figures at end (`endfloat`), no in-text figure placement. The "manuscript-for-review" look most journals demand. |
| `review`      | Loads the `changes` package so authors can hand-mark `\added`/`\deleted`/`\replaced` edits inline (color-per-author). Stripped automatically in `final`. |
| `final`       | Camera-ready: single-spaced, figures in place, no line numbers, changes markup removed. |
| `draft`       | Working mode: in-place figures, line numbers, draft watermark, `todonotes` enabled. |
| `endfloat`    | Force figures/tables to end (independently of `submission`). |
| `lineno`      | Force line numbers on. |

Options compose; `submission` is a convenience bundle of `endfloat`+`lineno`+double-spacing.

**Provides:**
- Consistent title block (title, authors, affiliations, corresponding author, ORCID).
- `\keywords{}`, `\runninghead{}`.
- Reviewer/rebuttal macros (used by `review/`) and tcolorbox styles, so the rebuttal matches the
  manuscript typographically.

## 5. Content model: canonical + variants

- `main.tex` `\input`s files from `sections/`.
- A variant build (`templates/main-elife.tex`) sets a search path so that `\input{abstract}`
  resolves to `variants/elife/abstract.tex` if present, else falls back to `sections/abstract.tex`.
- Mechanism: `\graphicspath`-style input path via `\providecommand` + `\IfFileExists`, or a small
  `\sectioninput{name}` macro defined in the class that checks `variants/<JOURNAL>/name.tex` first.
- Rule enforced by convention + `ADAPTATION.md`: a file appears in `variants/` **only if it
  differs** from canonical. No silent full-copies.

## 6. Journal profiles + limit checking

Each `journals/<journal>.md` has YAML frontmatter:

```yaml
---
journal: eLife
abstract_words: 150
title_chars: 150
main_text_words: null        # eLife has no hard main-text limit
figures_max: null
references_max: null
sections_order: [introduction, results, discussion, methods]
merge: {}                    # e.g. {results-and-discussion: [results, discussion]}
notes: "Structured abstract not required."
---
```

`scripts/check-limits.py`:
- Reads a journal profile + the compiled/source manuscript.
- Counts words per section (via `texcount` if available, else a built-in tokenizer), abstract
  length, figure count, reference count.
- Reports each constraint as PASS / OVER (with the delta), e.g.
  `Results: 820 words over limit`.
- Exits non-zero if any hard limit is exceeded (so it can gate CI / `make check`).
- **Never edits.** Reports only.

## 7. Peer-review correspondence

### `correspondence/cover-letter.tex`
Minimal, clean letter to the editor. Author/journal/date macros; no fragile letter-class deps.

### `review/response-to-reviewers.tex` — the rebuttal
- Self-contained `tcolorbox`-based reviewer-comment boxes (no dependency on `jourrr`, which isn't
  in every TeX distro).
- Macros: `\point{...}` (a reviewer comment, boxed/italic) and `\reply{...}` (the author response
  below it). Item-by-item structure.
- biblatex-aware `\cite` works inside replies.
- `\reply` blocks carry `\label`s; the manuscript and the response letter cross-reference each
  other (response links to where in the paper the change was made — margin sidenotes optional).
- Styled with the same `cnnclab` typography/colors as the manuscript.

## 8. Change tracking + Makefile targets

Two complementary mechanisms:

1. **`make diff OLD=<git-tag>`** (primary, journal-standard).
   Runs `latexdiff-vc --flatten --git -r <OLD>` against a tagged version (e.g. `submitted`),
   compiles `diff.pdf` with additions in blue, deletions in red. This is the artifact journals
   accept. Design notes / caveats handled:
   - both versions must compile;
   - `--flatten` resolves the multi-file `\input` structure;
   - same-named figures aren't diffed (documented in INSTRUCTIONS.md).
2. **`[review]` class option** — the `changes` package for deliberate, granular inline annotation
   by the authors, strippable in `final`.

**Makefile targets (planned):**

| Target              | Action |
|---------------------|--------|
| `make` / `make pdf` | Build `main.pdf` (latexmk + biber). |
| `make submission`   | Build with `submission` option. |
| `make diff OLD=tag` | latexdiff-vc against a git tag → `diff.pdf`. |
| `make check JOURNAL=elife` | Run `check-limits.py` against a journal profile. |
| `make rebuttal`     | Build `review/response-to-reviewers.pdf`. |
| `make cover`        | Build `correspondence/cover-letter.pdf`. |
| `make clean` / `make distclean` | Remove aux / all build artifacts. |

## 9. Adaptation-agent guardrails — `ADAPTATION.md`

Framed firmly and prominently as a **formatting-compliance tool**.

**Permitted:**
- Reorder / merge sections to a journal's required structure.
- Relocate figures (in-place ↔ end).
- Compute word / figure / abstract / reference counts.
- Report what exceeds limits.
- Produce a recommendations list, e.g. "Results is 820 words over; condense paragraphs 3–4."

**Forbidden:**
- Writing or rewriting scientific prose. All content changes stay with the author.

This framing keeps the repo's public footprint about compliance checking, not AI authorship.

## 10. Worked example

`templates/main-elife.tex`: a complete entry point wiring the `elife` variant search path + the
`elife` journal profile, demonstrating the canonical+variant mechanism end to end.

## 11. Deliverables for this build

1. `cnnclab.cls` with the option matrix in §4.
2. `sections/` canonical skeleton + `main.tex`.
3. `variants/elife/` example override.
4. `journals/elife.md` + at least one more profile, with valid frontmatter.
5. `scripts/check-limits.py` (reports only, non-zero exit on hard-limit breach).
6. `correspondence/cover-letter.tex`.
7. `review/response-to-reviewers.tex` with `\point`/`\reply` + tcolorbox boxes.
8. `Makefile` with the §8 targets.
9. `templates/main-elife.tex`.
10. `LICENSE` (preserved Henriques MIT), `README.md` (quickstart + attribution),
    `INSTRUCTIONS.md` (the detailed manual), `ADAPTATION.md` (guardrails).
11. Python `.gitignore` + ruff config per user standards; LaTeX aux patterns added.

## 12. Acceptance

- `make pdf` compiles `main.pdf` cleanly with biber.
- `make diff OLD=<tag>` produces a marked `diff.pdf`.
- `make check JOURNAL=elife` runs and reports limits.
- The rebuttal and cover letter compile standalone.
- No dependency outside a standard TeX Live 2023 install.
