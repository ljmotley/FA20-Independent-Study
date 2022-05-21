SHELL=bash
include ../../shell_functions.make

all: ../output/gtrends_outcomes.dta ../output/gtrends_non-outcomes.dta

../output/gtrends_%.dta: clean_gtrends.do ../input/dma_merged_analysis_file.dta | ../output
	$(STATA) $<

../input/dma_merged_analysis_file.dta: ../../downloaddata/output/dma_merged_analysis_file.dta | ../input
	ln -sf $< $@

include ../../generic.make
