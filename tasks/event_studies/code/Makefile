SHELL=bash
include ../../shell_functions.make

# COEFPLOTS = $(foreach i, ses intensity, $(foreach j, specific1 generic, ../output/$(i)_bh_replication_event_study_$(j).png))
# TABLES = $(foreach stub, zero_one zero_omit, ../output/bh_replication_event_study_table_$(stub).tex)

all:

# ../output/bh_replication_event_study_table_%.tex: event_study_table.do ../input/gtrends_outcomes_dma.dta ../input/gtrends_non_outcomes_dma.dta | ../output
# 	$(STATA) $< $*
#
# ../output/ses_bh_replication_event_study_%.png: event_study.do ../input/gtrends_outcomes_dma.dta ../input/gtrends_non_outcomes_dma.dta | ../output
# 	$(STATA) $< $* ses
#
# ../output/intensity_bh_replication_event_study_%.png: event_study.do ../input/gtrends_outcomes_dma.dta ../input/gtrends_non_outcomes_dma.dta | ../output
# 	$(STATA) $< $* intensity
#
# ../input/gtrends_outcomes_dma.dta: ../../clean_gtrends/output/gtrends_outcomes_dma.dta | ../input
# 	ln -sf $< $@

../input/zearn_outcomes.dta: ../../clean_zearn/output/zearn_outcomes.dta | ../input
	ln -sf $< $@
../input/cbsa_to_cty.csv: ../../crosswalks/output/cbsa_to_cty.dta | ../input
	ln -sf $< $@
../input/telework_scores_cbsa.dta: ../../clean_telework/output/telework_scores_cbsa.dta | ../input
	ln -sf $< $@
../input/ACS5yr2019_estimates.dta: ../../download_ACS_data/output/ACS5yr2019_estimates.dta | ../input
	ln -sf $< $@

include ../../generic.make
