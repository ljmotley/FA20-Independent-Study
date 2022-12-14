local outcome = "`1'"
local outcome_name = "`1'"


if "`outcome'"=="inc_full" {
    use "../input/ACS5yr2019_estimates.dta", clear
    gen inc = cty_medhhinc // cty_medhhinc or medhhinc (BH DMA DMA income variable
    local outcome "inc"
}
else if inlist("`outcome'","lninc","tele","comp","broad") {
    do prep all NOdrop_holidays
}
else if inlist("`outcome'","engagement","generic","specific1","badges") {
    do prep `outcome' NOdrop_holidays
    collapse (mean) `outcome' [pw=pop], by(cty)
}
else if "`outcome'"=="wfhscore" {
    use "../input/industrywfh.dta", clear
}
keep `outcome' cty
rename cty county

// manually account for differences between 2014 FIPS codes and our FIPS codes
replace county = 46113 if county == 46102
replace county = 2270 if county == 2158

drop if mi(county)
duplicates drop

maptile `outcome', geo(county2014) propcolor
graph export "../output/map_`outcome_name'.eps", replace
