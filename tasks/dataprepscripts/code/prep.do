local outcome "`1'"
local drop_holidays = 0
if "`2'"=="drop_holidays" local drop_holidays = 1
use "../input/ACS5yr2019_estimates.dta", clear
xtile income_quintile = cty_medhhinc, nq(5)
gen comp = cty_comp/cty_totalhh
gen broad = cty_broad/cty_totalhh
gen lncomp = ln(comp)
gen lnbroad = ln(broad)
tempfile acs_data
save `acs_data'

if inlist("`outcome'", "gtrends", "specific1", "generic"){
  local ytitle "Log search intensity"
  if "`outcome'"!="gtrends" use dma week `outcome' using "../input/gtrends_outcomes_dma.dta" if dma != "US", clear
  if "`outcome'"=="gtrends" use dma week specific1 generic using "../input/gtrends_outcomes_dma.dta" if dma != "US", clear
//  merge m:1 dma using "../input/gtrends_non_outcomes_dma.dta", keepusing(population hh_med_inc) keep(match) nogen
  split dma, p(-)
  rename dma3 dmacode
  destring dmacode, replace
  joinby dma using "../input/dma_to_cty.dta"
  if "`outcome'"!="gtrends" replace `outcome' = ln(`outcome')
  if "`outcome'"=="gtrends" replace specific1 = ln(specific1)
  if "`outcome'"=="gtrends" replace generic = ln(generic)
}
else if inlist("`outcome'", "engagement", "badges") {
  if "`outcome'" == "engagement"  local ytitle "Log engagement"
  if "`outcome'" == "badges"      local ytitle "Log badges"
  use cty week break `outcome' using "../input/zearn_outcomes.dta", clear
}
else if "`outcome'"=="all" {
  use dma week specific1 generic using "../input/gtrends_outcomes_dma.dta" if dma != "US", clear
  split dma, p(-)
  rename dma3 dmacode
  destring dmacode, replace
  joinby dma using "../input/dma_to_cty.dta"
  replace specific1 = ln(specific1)
  replace generic = ln(generic)
  merge 1:1 cty week using "../input/zearn_outcomes.dta", nogen keepusing(cty week break engagement badges)
}
merge m:1 cty using "`acs_data'", nogen
merge m:1 cty using "../input/cbsa_to_cty.dta", keep(master match) nogen
replace cbsa = 0 if cbsa == .
keep if metro_micro == 2
merge m:1 cbsa using "../input/telework_scores_cbsa.dta", nogen

gen lntele = ln(teleworkable_emp)
gen tele = teleworkable_emp

// BIG CHANGES HAPPEN HERE
gen pop = cty_pop // cty_pop or population (BH DMA pop variable)
gen lninc = ln(cty_medhhinc) // cty_medhhinc or medhhinc (BH DMA DMA income variable)
gen inc = cty_medhhinc

gen wkssnccovid = round((week - date("3/1/2020", "MDY"))/7)
gen weekofyear = week(week)
gen schoolyear = year(week)+(inrange(month(week), 6, 12))
gen postcovid = (inrange(wkssnccovid, 0, .))

if `drop_holidays' drop if inlist(wkssnccovid, -9, -10, -14, -13)
