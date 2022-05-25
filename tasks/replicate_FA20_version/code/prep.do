local outcome "`1'"
if inlist("`outcome'", "specific1", "generic"){
  local ytitle "Log search intensity"
  use dma week `outcome' using "../input/gtrends_outcomes_dma.dta" if dma != "US", clear
  merge m:1 dma using "../input/gtrends_non_outcomes_dma.dta", keepusing(population hh_med_inc) keep(match) nogen
  split dma, p(-)
  rename dma3 dmacode
  destring dmacode, replace
  joinby dma using "../input/dma_to_cty.dta"
  replace `outcome' = ln(`outcome')
}
else if inlist("`outcome'", "engagement", "badges") {
  if "`outcome'" == "engagement"  local ytitle "Log engagement"
  if "`outcome'" == "badges"      local ytitle "Log badges"
  use cty week break `outcome' using "../input/zearn_outcomes.dta" if !break, clear
}
merge m:1 cty using "../input/ACS5yr2019_estimates.dta", nogen
merge m:1 cty using "../input/cbsa_to_cty.dta", keep(master match) nogen
replace cbsa = 0 if cbsa == .
keep if metro_micro == 2
merge m:1 cbsa using "../input/telework_scores_cbsa.dta", nogen

gen lntele = ln(teleworkable_emp)

// BIG CHANGES HAPPEN HERE
gen pop = cty_pop // cty_pop or population (BH DMA pop variable)
gen lninc = ln(cty_medhhinc) // cty_medhhinc or medhhinc (BH DMA DMA income variable)

gen wkssnccovid = round((week - date("3/1/2020", "MDY"))/7)
gen weekofyear = week(week)
gen schoolyear = year(week)+(inrange(month(week), 6, 12))
gen postcovid = (inrange(wkssnccovid, 0, .))
