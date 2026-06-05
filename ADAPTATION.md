# ADAPTATION.md — guardrails for the formatting agent

This repository may be driven by an automated **adaptation agent** to reformat a manuscript for a
target journal. Read this before enabling any automation. The boundary below is firm.

## The agent is a formatting-compliance tool. Nothing more.

### Permitted (formatting + reporting)

- **Reorder or merge sections** to a journal's required structure (e.g. merge Results and
  Discussion when `journals/<name>.md` declares `merge: {results-and-discussion: [results, discussion]}`).
- **Relocate figures** between in-place and end-of-document.
- **Compute counts** — words per section, abstract length, title length, figures, references.
- **Report what exceeds limits**, with concrete, actionable recommendations, e.g.
  *"Results is 820 words over the eLife limit; the longest paragraphs are 3 and 4 — consider
  condensing them."*
- **Set up variant scaffolding** — create an empty `variants/<journal>/` and a journal profile
  stub from an existing one.

### Forbidden (authorship)

- **Writing or rewriting scientific prose.** The agent must not generate, paraphrase, or
  "improve" sentences of the manuscript body, abstract, or rebuttal.
- **Changing claims, results, citations, or their interpretation.**
- **Condensing text on the author's behalf** to hit a word limit. It may *identify* and
  *recommend*; the author edits.

## Why this boundary

The repo's public footprint must be about **compliance checking**, not AI authorship. Keeping the
agent on the formatting side of the line protects authorship integrity and keeps the tool
defensible for use on real submissions.

## In practice

A correct agent run produces: a reformatted *structure* (sections in the right order, figures
relocated), a limits report, and a recommendations list. It does **not** produce new prose. If a
task would require writing a sentence of science, the agent stops and hands back to the author.
