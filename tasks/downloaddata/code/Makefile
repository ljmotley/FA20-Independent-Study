SHELL=bash
include ../../shell_functions.make

OUTPUT = $(foreach stub, dma_merged_analysis_file.dta MSA_workfromhome.csv Zearn-County-Weekly.csv county_cbsa.csv, ../output/$(stub))

all: $(OUTPUT)

../output/Zearn_County_Weekly.csv: | ../output
	wget https://raw.githubusercontent.com/OpportunityInsights/EconomicTracker/main/data/Zearn%20-%20County%20-%20Weekly.csv -O $@

../output/MSA_workfromhome.csv: | ../output
	wget https://raw.githubusercontent.com/jdingel/DingelNeiman-workathome/master/MSA_measures/output/MSA_workfromhome.csv -O $@

../output/dma_merged_analysis_file.dta: | ../output ../output/nber.zip
	unzip -p ../output/nber.zip dma_merged_analysis_file.dta >../output/dma_merged_analysis_file.dta

../output/county_cbsa.csv: | ../output
	wget https://data.nber.org/cbsa-csa-fips-county-crosswalk/cbsa2fipsxw.csv -O $@

.INTERMEDIATE: ../output/nber.zip

../output/nber.zip: | ../output
	wget https://data.nber.org/data-appendix/w27555/nber.zip -O $@

include ../../generic.make
