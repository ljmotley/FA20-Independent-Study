SHELL=bash
include ../../shell_functions.make

all: ../output/industrywfh.dta

../output/industrywfh.dta: industrywfh.do ../input/2_digit_pp_wfh_onet.dta ../output/ind_emp_cty.dta | ../output ../report
	$(STATA) $<
../output/ind_emp_cty.dta: ind_emp_cty.do ../input/ind_occ_by_county.dta | ../output ../report
	$(STATA) $<

../input/ind_occ_by_county.dta: ../../downloaddata/output/ind_occ_by_county.dta | ../input
	ln -sf $< $@
../input/2_digit_pp_wfh_onet.dta: ../../downloaddata/output/2_digit_pp_wfh_onet.dta | ../input
	ln -sf $< $@

include ../../generic.make
