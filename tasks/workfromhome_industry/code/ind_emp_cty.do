use "../input/ind_occ_by_county.dta", clear
keep if year==2019

gen occ_2digit = 0
replace occ_2digit = 1 if inrange(occ, 10,499)
replace occ_2digit = 5 if inrange(occ, 500,999)
replace occ_2digit = 10 if inrange(occ, 1000,1299)
replace occ_2digit = 13 if inrange(occ, 1300,1599)
replace occ_2digit = 16 if inrange(occ, 1600,1999)
replace occ_2digit = 20 if inrange(occ, 2000,2099)
replace occ_2digit = 21 if inrange(occ, 2100,2199)
replace occ_2digit = 22 if inrange(occ, 2200,2599)
replace occ_2digit = 26 if inrange(occ, 2600,2999)
replace occ_2digit = 30 if inrange(occ, 3000,3599)
replace occ_2digit = 36 if inrange(occ, 3600,3699)
replace occ_2digit = 37 if inrange(occ, 3700,3999)
replace occ_2digit = 40 if inrange(occ, 4000,4199)
replace occ_2digit = 42 if inrange(occ, 4200,4299)
replace occ_2digit = 43 if inrange(occ, 4300,4699)
replace occ_2digit = 47 if inrange(occ, 4700,4999)
replace occ_2digit = 50 if inrange(occ, 5000,5999)
replace occ_2digit = 60 if inrange(occ, 6000,6199)
replace occ_2digit = 62 if inrange(occ, 6200,6999)
replace occ_2digit = 70 if inrange(occ, 7000,7699)
replace occ_2digit = 77 if inrange(occ, 7700,8999)
replace occ_2digit = 90 if inrange(occ, 9000,9499)
replace occ_2digit = 95 if inrange(occ, 9500,9799)
replace occ_2digit = 98 if inrange(occ, 9800,9999)

gen cty = 1000*statefip + countyfip

collapse (sum) emp=perwt, by(cty occ_2digit)

save_data "../output/ind_emp_cty.dta", key(cty occ_2digit) replace
