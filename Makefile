# CNNC-Lab paper template — build, check, diff, correspondence.
# Requires: latexmk, biber, latexdiff-vc, python3.

MAIN     := main
LATEXMK  := latexmk -pdf -interaction=nonstopmode -halt-on-error
PYTHON   := python3
JOURNAL  ?=
OLD      ?=

.PHONY: all pdf submission final elife check diff rebuttal cover clean distclean help

all: pdf

## pdf: build main.pdf (draft mode, as written in main.tex)
pdf:
	$(LATEXMK) $(MAIN).tex

## submission: review-ready manuscript (line numbers, figures at end)
submission:
	$(LATEXMK) -usepretex='\PassOptionsToClass{submission}{cnnclab}' -jobname=$(MAIN)-submission $(MAIN).tex

## final: camera-ready (single-spaced, figures in place, no markup)
final:
	$(LATEXMK) -usepretex='\PassOptionsToClass{final}{cnnclab}' -jobname=$(MAIN)-final $(MAIN).tex

## elife: worked-example build for eLife (uses variants/elife/*)
elife:
	$(LATEXMK) templates/main-elife.tex

## check JOURNAL=<name>: report word/figure/reference limits (reports only)
check:
	@test -n "$(JOURNAL)" || { echo "Usage: make check JOURNAL=<name>"; exit 2; }
	$(PYTHON) scripts/check-limits.py --journal $(JOURNAL)

## diff OLD=<git-tag>: marked-up diff.pdf vs a tagged version (latexdiff-vc)
diff:
	@test -n "$(OLD)" || { echo "Usage: make diff OLD=<git-tag>"; exit 2; }
	latexdiff-vc --git --flatten --pdf -r $(OLD) $(MAIN).tex
	@echo "Wrote $(MAIN)-diff$(OLD).pdf (rename to diff.pdf as needed)."

## rebuttal: build the response-to-reviewers letter
rebuttal:
	$(LATEXMK) -cd review/response-to-reviewers.tex

## cover: build the cover letter
cover:
	$(LATEXMK) -cd correspondence/cover-letter.tex

## clean: remove LaTeX aux files
clean:
	$(LATEXMK) -c $(MAIN).tex
	$(LATEXMK) -c -cd review/response-to-reviewers.tex
	$(LATEXMK) -c -cd correspondence/cover-letter.tex

## distclean: remove all generated files, including PDFs
distclean:
	$(LATEXMK) -C $(MAIN).tex
	$(LATEXMK) -C -cd review/response-to-reviewers.tex
	$(LATEXMK) -C -cd correspondence/cover-letter.tex
	rm -f *-diff*.pdf diff.pdf

## help: list targets
help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  /'
