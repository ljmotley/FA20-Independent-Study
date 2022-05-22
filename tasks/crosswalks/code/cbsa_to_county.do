import delimited "../input/county_cbsa.csv", case(lower) clear
drop if mi(cbsacode)

keep cbsacode cbsatitle metropolitanmicropo statename fipsstatecode fipscou countycount

assert(ustrpos(met, "Metro") | ustrpos(met, "Micro"))
gen metro_micro = [ustrpos(met, "Metro")] + 1

lab define metro_micro_lab 1 "Micropolitan Statistical Area" 2 "Metropolitan Statistical Area"
lab val metro_micro metro_micro_lab

rename (cbsacode cbsatitle fipsc county fipss statename) (cbsa cbsa_name cty cty_name state state_name)

foreach var of varlist *name {
  replace `var' = ustrtrim(`var')
}

compress

lab data "CBSA to County (NBER)"

order cbsa cbsa_name metro_micro state state_name cty cty_name

save "../output/cbsa_to_cty.dta", replace
