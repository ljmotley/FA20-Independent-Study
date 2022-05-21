SHELL=bash
include ../../shell_functions.make

all: ../output/telework_scores_cbsa.dta

../output/telework_scores_cbsa.dta: clean_MSA_workfromhome.do ../input/MSA_workfromhome.csv | ../output
	$(STATA) $<

../input/MSA_workfromhome.csv: ../../downloaddata/output/MSA_workfromhome.csv | ../input
	ln -sf $< $@

include ../../generic.make
