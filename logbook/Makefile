SHELL=bash

logbookentries := $(shell grep 'entries' logbook.tex | grep -v '^%' | grep -o 'entries/[A-Za-z0-9_]*\.tex')
img_inputs := $(shell grep '\\includegraphics' $(logbookentries) | grep -v '%.*\\includegraphics' | sed 's/^.*\\includegraphics\[.*\]{\([\./a-zA-Z0-9_]*\)}.*/\1/')
tex_inputs := $(shell grep --no-filename '\\input' $(logbookentries) | grep -v '^%' | grep -o 'input{[A-Za-z0-9_\/\.]*}'  | sed 's/input{//' | sed 's/}$$//')
scratchentries := $(shell grep 'entries' scratch.tex | grep -v '^%' | grep -o 'entries/[A-Za-z0-9_]*\.tex')
img_scratch_inputs := $(shell grep '\\includegraphics' $(scratchentries) | grep -v '%.*\\includegraphics' | sed 's/^.*\\includegraphics\[.*\]{\([\./a-zA-Z0-9_]*\)}.*/\1/')
tex_scratch_inputs := $(shell grep --no-filename '\\input' $(scratchentries) | grep -v '^%' | grep -o 'input{[A-Za-z0-9_\/\.]*}'  | sed 's/input{//' | sed 's/}$$//')

all: logbook.pdf scratch.pdf

clean:
	rm *.log *.out *.toc *.aux

clean_figs:
	rm logbook-figure*.* scratch-figure*.* *.auxlock

# NEED TO MAKE THESE DEPENDENT ON BIB EVENTUALLY
logbook.pdf: logbook.tex $(logbookentries) $(img_inputs) $(tex_inputs)
	pdflatex -shell-escape -draftmode $<
	# bibtex $(basename $<).aux
	pdflatex -shell-escape -draftmode $<
	pdflatex -shell-escape $<
	rm $(basename $<).log $(basename $<).out $(basename $<).toc $(basename $<).aux
	rm $(basename $<).bbl $(basename $<).blg

scratch.pdf: scratch.tex $(scratchentries) $(img_scratch_inputs) $(tex_scratch_inputs)
#	pdflatex -shell-escape -draftmode $<
#	bibtex $(basename $<).aux
	pdflatex -shell-escape -draftmode $<
	pdflatex -shell-escape $<
	rm $(basename $<).log $(basename $<).out $(basename $<).aux
#	rm $(basename $<).bbl $(basename $<).blg

#Input recipes
input/bh_replication_event_study_table_%.tex: ../tasks/replicate_bacher_hicks_etal/output/bh_replication_event_study_table_%.tex | input/
	ln -sf ../$< $@
input/intensity_bh_replication_event_study_%.png: ../tasks/replicate_bacher_hicks_etal/output/intensity_bh_replication_event_study_%.png | input/
	ln -sf ../$< $@
input/ses_bh_replication_event_study_%.png: ../tasks/replicate_bacher_hicks_etal/output/ses_bh_replication_event_study_%.png | input/
	ln -sf ../$< $@
input/%.tex: ../tasks/replicate_FA20_version/output/%.tex | input/
	ln -sf ../$< $@
input/event_study_%.png: ../tasks/replicate_FA20_version/output/event_study_%.png | input/
	ln -sf ../$< $@

input/:
	mkdir $@
