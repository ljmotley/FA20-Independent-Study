local outcomes = "`1'"
local y = substr("`1'", 1, strpos("`1'", "_") - 1)
local x = substr("`1'", strpos("`1'", "_") + 1, length("   `1'"))

// do prep all NOdrop_holidays
if "`outcomes'"=="lninc_lntele" {
    use "../input/ACS5yr2019_estimates.dta", clear
    gen lninc = ln(cty_medhhinc) // cty_medhhinc or medhhinc (BH DMA DMA income variable)
    merge m:1 cty using "../input/cbsa_to_cty.dta", keep(master match) nogen
    merge m:1 cbsa using "../input/telework_scores_cbsa.dta", nogen
    gen lntele = ln(teleworkable_emp)
    keep cty lninc lntele
    duplicates drop
}
else if "`outcomes'"=="teleworkability_wfhscore" {
    use "../input/telework_scores_cbsa.dta", clear
    merge 1:m cbsa using "../input/cbsa_to_cty.dta", keep(match) nogen
    merge 1:1 cty using "../input/industrywfh.dta", nogen
    list
    rename teleworkable_emp teleworkability
    keep cty teleworkability wfhscore
    duplicates drop
}

if "`y'"=="lninc" local ytitle "Log Income"
if "`x'"=="lntele" local xtitle "Log Teleworkability"
if "`y'"=="teleworkability" local ytitle "Teleworkability percentage"
if "`x'"=="wfhscore" local xtitle "Work from home score"

* Equation Line
reg  `y' `x' `graph_weighting', robust
local constant `: di  %7.2f _b[_cons]'
local operator `=cond(_b[ `x']>0, "+", "-")' // Change equation specification based on sign of beta coefficient
local std_error `: di  %7.2f _se[ `x']'
local regressor `:di %6.2f abs(_b[ `x'])' [`std_error'] X // Absolute value take given definition of operator above
local eq " Y = `constant' `operator' `regressor' + {&epsilon} "

* Summary Stats
local R2 `: di  %7.4f e(r2)'
local sum_stats = "{it:N = `e(N)';  R{sup:2} = `R2'}"

twoway (scatter `y' `x', color(blue)) ///
(lfit `y' `x', color(black) lp(dash) legend(off) ///
, ytitle("`ytitle'") xtitle("`xtitle'") ///
xline(0) ///
note("`eq'" "`sum_stats'", size(medsmall) ring(0) pos(4) just(centre))) ///
, graphregion(color(white))
graph export "../output/scatter_`y'_`x'.eps", replace
