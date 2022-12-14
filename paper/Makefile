## DEFINITIONS

FOLDERS = input
PAPER_SECTIONS = $(shell grep '\\input' paper.tex  | grep -v '%.*\\input' | sed 's/^.*\\input{\(.*\.tex\)}.*/\1/')
#These two lines are commented out because paper.tex lacks content at the moment:
PAPER_INPUTS = $(shell grep --no-filename 'input/' $(PAPER_SECTIONS) | grep -v '%.*\\input' | grep -o 'input/[A-Za-z0-9_\-]*\.[a-z]*')

## RECIPES

all: $(FOLDERS) $(PAPER_INPUTS_TEX) $(PAPER_INPUTS) paper.pdf

$(FOLDERS):
	mkdir $@

paper.pdf: paper.tex $(PAPER_SECTIONS) $(PAPER_INPUTS)
	if command -v sbatch > /dev/null ; then module load texlive; fi
	pdflatex -shell-escape -draftmode $(basename $<).tex
	bibtex $(basename $<).aux
	pdflatex -draftmode $(basename $<).tex
	pdflatex $(basename $<).tex
	rm $(basename $<).log $(basename $<).aux $(basename $<).out
	rm $(basename $<).bbl $(basename $<).blg

input/eventstudyplot_%.eps: ../tasks/event_studies/output/eventstudyplot_%.eps | input/
	ln -sf ../$< $@
input/eventstudytable_%.tex: ../tasks/event_studies/output/eventstudytable_%.tex | input/
	ln -sf ../$< $@
input/timetrend_%.eps: ../tasks/time_trends/output/timetrend_%.eps | input/
	ln -sf ../$< $@
input/scatter_%.eps: ../tasks/scatters/output/scatter_%.eps | input/
	ln -sf ../$< $@
input/map_%.eps: ../tasks/maps/output/map_%.eps | input/
	ln -sf ../$< $@
input/ses_bh_%.eps: ../tasks/replicate_bacher_hicks_etal/output/ses_bh_%.eps | input/
	ln -sf ../$< $@
input/intensity_bh_%.eps: ../tasks/replicate_bacher_hicks_etal/output/intensity_bh_%.eps | input/
	ln -sf ../$< $@
input/bh_replication_%.tex: ../tasks/replicate_bacher_hicks_etal/output/bh_replication_%.tex | input/
	ln -sf ../$< $@

input/:
	mkdir $@

