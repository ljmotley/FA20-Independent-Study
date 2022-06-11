SHELL=bash
include ../../shell_functions.make

COEFPLOTS = $(addprefix  ../output/, $(foreach y, specific1 generic engagement badges, $(foreach j, wks inc tele inctele, event_study_$(y)_$(j).png)))
TABLES = $(addprefix  ../output/, $(foreach j, wks inc tele inctele N mtitles, $(j).tex))

all: $(TABLES) $(COEFPLOTS)

../output/event_study_%.png: event_studies.do $(shell grep -o '../input/\w*.\w*' prep.do | grep -v 'zearn' | grep -v 'gtrends') | ../output 
	$(STATA) $< $*
../output/%.tex: table.do $(shell grep -o '../input/\w*.\w*' prep.do) | ../output
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

include ../../generic.make
