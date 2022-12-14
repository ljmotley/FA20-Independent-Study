SHELL=bash
include ../../shell_functions.make

all: ../output/workfromhome2010.dta

../output/workfromhome2010.dta: clean_wfh2010.do ../input/workedathomebymetro2000-2010.xls | ../output ../report
	$(STATA) $<

../input/workedathomebymetro2000-2010.xls: ../../downloaddata/output/workedathomebymetro2000-2010.xls | ../input
	ln -sf $< $@

include ../../generic.make
