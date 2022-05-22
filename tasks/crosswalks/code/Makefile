SHELL=bash
include ../../shell_functions.make

all: ../output/dma_to_cty.dta ../output/cbsa_to_cty.dta

../output/dma_to_cty.dta: dma_to_county.do ../input/dma_merged_analysis_file.dta ../input/county_dma.xlsx | ../output
	$(STATA) $<
../output/cbsa_to_cty.dta: cbsa_to_county.do ../input/county_cbsa.csv | ../output
	$(STATA) $<

../input/county_cbsa.csv: ../../downloaddata/output/county_cbsa.csv | ../input
	ln -sf $< $@
../input/dma_merged_analysis_file.dta: ../../downloaddata/output/dma_merged_analysis_file.dta | ../input
	ln -sf $< $@

include ../../generic.make
