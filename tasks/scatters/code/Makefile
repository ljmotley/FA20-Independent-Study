SHELL=bash
include ../../shell_functions.make

PLOTS = $(addprefix  ../output/, $(foreach y, teleworkability_wfhscore lninc_lntele, scatter_$(y).eps))

all: $(PLOTS)

../output/scatter_%.eps: scatter.do ../input/industrywfh.dta $(shell grep -o '../input/\w*.\w*' prep.do) | prep.do ../output
	$(STATA) $< $*

../input/zearn_outcomes.dta: ../../clean_zearn/output/zearn_outcomes.dta | ../input
	ln -sf $< $@
../input/gtrends_outcomes_dma.dta: ../../clean_gtrends/output/gtrends_outcomes_dma.dta | ../input
	ln -sf $< $@
../input/gtrends_non_outcomes_dma.dta: ../../clean_gtrends/output/gtrends_non_outcomes_dma.dta | ../input
	ln -sf $< $@
../input/cbsa_to_cty.dta: ../../crosswalks/output/cbsa_to_cty.dta | ../input
	ln -sf $< $@
../input/dma_to_cty.dta: ../../crosswalks/output/dma_to_cty.dta | ../input
	ln -sf $< $@
../input/telework_scores_cbsa.dta: ../../clean_telework/output/telework_scores_cbsa.dta | ../input
	ln -sf $< $@
../input/ACS5yr2019_estimates.dta: ../../download_ACS_data/output/ACS5yr2019_estimates.dta | ../input
	ln -sf $< $@
../input/industrywfh.dta: ../../workfromhome_industry/output/industrywfh.dta
	ln -sf $< $@
prep.do: ../../dataprepscripts/code/prep.do
	ln -sf $< $@

include ../../generic.make
