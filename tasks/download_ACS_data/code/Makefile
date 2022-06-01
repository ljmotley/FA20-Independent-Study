SHELL=bash
include ../../shell_functions.make

all: ../output/ACS5yr2019_estimates.dta

../output/ACS5yr2019_estimates.dta: population.R | ../output
	$(R) $<

include ../../generic.make
