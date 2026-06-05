# Changelog

All notable changes to this project are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1] — 2026-06-05

First tagged release. A single, portable LaTeX repository that carries a computational-neuroscience
manuscript through the whole publication lifecycle: draft → submission → peer review → tracked
revision → camera-ready.

### Added

- **Document class `cnnclab.cls`** — single-column, clean typography, biblatex + biber.
  - Modes: `draft`, `submission`, `review`, `final`, plus standalone `endfloat` and `lineno`
    (`submission` bundles line numbers, end-floated figures, and double spacing).
  - `graphicx` loaded `[final]` so figures render even in draft mode.
- **Title block** — tight single-spaced, heavy bold title; `\affiliation{<mark>}{<text>}` accumulator;
  `\orcidlink{<id>}` author iD (with a text-link fallback); `\corresponding`, `\keywords`,
  `\runninghead`. Keywords render after the abstract.
- **Front matter** — label-switchable `significance` environment (Significance Statement / PLOS
  Author Summary / PNAS Significance / eNeuro New & Noteworthy).
- **Back matter** — compact, unindented `acknowledgements` and `funding` environments;
  `\competinginterests`, `\authorcontributions` (CRediT), `\dataavailability`, `\codeavailability`.
- **Supplementary material** — `\beginsupplement` renumbers figures/tables/equations to the `S`
  series and first flushes any `endfloat`-deferred main floats (main figures keep 1, 2, 3);
  `\suppsection{}` helper. Example Supplementary Methods / Figures / Tables.
- **One source, many journals** — canonical `sections/` with override-only `variants/<journal>/`,
  resolved by the variant-aware `\sectioninput`. Worked example `templates/main-elife.tex`.
- **Journal profiles + checker** — machine-readable `journals/*.md` (eLife, PLOS Comp Biol) and
  `scripts/check-limits.py` (word/figure/reference limits; reports only, non-zero exit on breach).
- **Peer-review correspondence** — minimal `correspondence/cover-letter.tex`; self-contained
  `tcolorbox` rebuttal `review/response-to-reviewers.tex` with `\point`/`\reply` macros,
  biblatex-aware and cross-referenceable.
- **Change tracking** — `make diff OLD=<git-tag>` (latexdiff-vc `--flatten`) and the `changes`
  package via the `review` option.
- **Build system** — `Makefile` targets: `pdf`, `submission`, `final`, `elife`, `check`, `diff`,
  `rebuttal`, `cover`, `clean`, `distclean`.
- **Overleaf-native** — every document compiles from the project root with a bare `latexmk`;
  no Makefile required (documented in `INSTRUCTIONS.md` §1b).
- **CI** — `lint.yml` (ruff check + format) and `latex.yml` (TeX Live container: builds all
  documents, runs the Overleaf-model bare-`latexmk` compile, and the journal limit checks).
- **Docs** — `README.md`, `INSTRUCTIONS.md` (full manual), `ADAPTATION.md` (formatting-agent
  guardrails). `LICENSE` (MIT) with original Henriques Lab attribution preserved.

[Unreleased]: https://github.com/CNNC-Lab/paper-template/compare/v0.1...HEAD
[0.1]: https://github.com/CNNC-Lab/paper-template/releases/tag/v0.1
