SHELL=bash
include ../../shell_functions.make

all: ../output/ctypopulation_5yrACS2019.csv

../output/ctypopulation_5yrACS2019.csv: population.R | ../output
	$(R) $<

include ../../generic.make
