SHELL=bash
include ../../shell_functions.make

all: ../output/atus_2019.dta

../output/atus_2019.dta: clean_atus.do ../input/atuscps_2019.do ../input/atuscps_2019.dat ../input/atussum_2019.do ../input/atussum_2019.dat | ../output
	$(STATA) $<

.PRECIOUS: ../../downloaddata/output/atussum_2019.do ../../downloaddata/output/atuscps_2019.dat ../../downloaddata/output/atuscps_2019.do ../../downloaddata/output/atussum_2019.dat
../input/atus%_2019.do: ../../downloaddata/output/atus%_2019.do | ../input
	ln -sf $< $@
../input/atus%_2019.dat: ../../downloaddata/output/atus%_2019.dat | ../input
	ln -sf $< $@

include ../../generic.make
