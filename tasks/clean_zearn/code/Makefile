SHELL=bash
include ../../shell_functions.make

all: ../output/zearn_outcomes.dta

../output/zearn_outcomes.dta: clean_zearn.do ../input/Zearn_County_Weekly.csv | ../output
	$(STATA) $<

../input/Zearn_County_Weekly.csv: ../../downloaddata/output/Zearn_County_Weekly.csv | ../input
	ln -sf $< $@

include ../../generic.make
