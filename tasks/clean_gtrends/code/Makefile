SHELL=bash
include ../../shell_functions.make

all: ../output/gtrends_outcomes_dma.dta ../output/gtrends_non_outcomes_dma.dta

../output/gtrends_%_dma.dta: clean_gtrends.do ../input/dma_merged_analysis_file.dta | ../output
	$(STATA) $< $*

../input/dma_merged_analysis_file.dta: ../../downloaddata/output/dma_merged_analysis_file.dta | ../input
	ln -sf $< $@

include ../../generic.make
