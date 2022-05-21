SHELL=bash
include ../../shell_functions.make

all: ../output/zearn_outcomes.dta

../output/zearn_outcomes.dta: clean_zearn.do ../input/Zearn-County-Weekly.csv | ../output
	$(STATA) $<

../input/Zearn-County-Weekly.csv: ../../downloaddata/output/Zearn-County-Weekly.csv | ../input
	ln -sf $< $@

include ../../generic.make
