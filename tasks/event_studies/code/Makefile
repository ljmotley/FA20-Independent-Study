SHELL=bash
include ../../shell_functions.make

COEFPLOTS = $(addprefix  ../output/, $(foreach y, specific1 generic engagement badges, $(foreach j, inctele, eventstudyplot_$(y)_$(j).eps)))
TABLES = $(addprefix  ../output/, $(foreach j, beta betacomp betabroad wks inc tele comp broad inctele comptele broadtele N mtitles, eventstudytable_$(j).tex))

all: $(TABLES) $(COEFPLOTS)

../output/eventstudyplot_%_long.eps: event_studies.do $(shell grep -o '../input/\w*.\w*' prep.do | grep -v 'zearn' | grep -v 'gtrends') | ../output prep.do
	$(STATA) $< $* long
../output/eventstudyplot_%.eps: event_studies.do $(shell grep -o '../input/\w*.\w*' prep.do | grep -v 'zearn' | grep -v 'gtrends') | ../output prep.do
	$(STATA) $< $*
../output/eventstudytable_%.tex: table.do $(shell grep -o '../input/\w*.\w*' prep.do) | ../output
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
prep.do: ../../dataprepscripts/code/prep.do
	ln -sf $< $@

include ../../generic.make
