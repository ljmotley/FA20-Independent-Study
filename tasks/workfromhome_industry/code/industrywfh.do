use "../output/ind_emp_cty.dta", clear

levelsof cty
di "`r(r)'"


merge m:1 occ_2digit using "../input/2_digit_pp_wfh_onet.dta", keep(master match)

gen emp_times_high_wfh = emp * high_wfh

collapse (rawsum) emp emp_times_high_wfh, by(cty)
gen wfhscore = emp_times_high_wfh / emp

save_data "../output/industrywfh.dta", key(cty) replace
