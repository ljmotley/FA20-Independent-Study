SHELL=bash
include ../../shell_functions.make

all: ../output/dma_to_cty.csv

../output/dma_to_cty.csv: dma_to_county.do ../input/dma_merged_analysis_file.dta ../input/county_dma.xlsx | ../output
	$(STATA) $<
../input/county_dma.xlsx: ../../crosswalks/temp/county_dma.xlsx | ../input
	ln -sf $< $@

../input/dma_merged_analysis_file.dta: ../../downloaddata/output/dma_merged_analysis_file.dta | ../input
	ln -sf $< $@

include ../../generic.make
