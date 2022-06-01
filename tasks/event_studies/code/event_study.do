cd "/Users/lukemotley/Documents/FA20-Independent-Study/tasks/event_studies/code"
local replicate on
local outcome generic
local geo cty
local version tele
local type short

use "../input/ACS5yr2019_estimates.dta", clear
tempfile acs
save `acs'

if "`replicate'" == "on" {
  use `outcome' fips std_tele std_inc date state using "/Users/lukemotley/Downloads/Motley_BFI_Code_Sample/data/final_data.dta", clear
  rename std* ln*
  rename fips cty
  rename date week
  keep if !mi(ln_tele) & !mi(ln_inc)
  merge m:1 cty using `acs', assert(using match) keep(match) keepusing(cty_population) nogen
  rename cty_population pop
}
else {
    if inlist("`outcome'", "badges", "engagement") {
    use "../input/zearn_outcomes.dta", clear
    merge m:1 cty using `acs', assert(using match) keep(match) nogen
    drop if break
  }
  if inlist("`outcome'", "generic", "specific1", "google") {
    use dma week `outcome' using "../input/gtrends_outcomes_dma.dta" if dma != "US", clear
    merge m:1 dma using "../input/gtrends_non_outcomes_dma.dta", keepusing(population hh_med_in) keep(match) nogen
    rename hh_med_inc medhhinc
    split dma, p(-)
    rename dma3 dmacode
    destring dmacode, replace
    joinby dmacode using "/Users/lukemotley/Downloads/Motley_BFI_Code_Sample/data/temp.dta"
    rename fips cty
    merge m:1 cty using `acs', nogen
  }

  if "`geo'"=="cty" {
    merge m:1 cty using "../input/cbsa_to_cty.dta", keep(master match)
    replace cbsa = 0 if cbsa == .
    keep if metro_micro == 2
    merge m:1 cbsa using "../input/telework_scores_cbsa.dta", nogen
  }
  if "`geo'"=="cbsa" {
    merge m:1 cty using "../input/cbsa_to_cty.dta", keep(master match)
    replace cbsa = 0 if cbsa == .
    keep if metro_micro == 2
    collapse (rawsum) population=cty_population (mean) `outcome' medhhinc [pw=cty_pop],  by(cbsa state state_name week)
    // EVENTUALLY WANT TO ASSERT USING MATCH HERE -- RIGHT NOW 15 UNMATCHED METROS
    merge m:1 cbsa using "../input/telework_scores_cbsa.dta"
  }

  keep if !mi(`outcome') & !mi(teleworkable_emp)

  sum medhhinc, d
  gen high_inc = [inrange(medhhinc, `r(mean)', .)]
  egen ln_inc = std(medhhinc)
  egen ln_tele = std(teleworkable_emp)
  keep if !mi(ln_tele)
}


gen weeks_since_covid = round((week - date("3/1/2020", "MDY"))/7)
gen week_of_year = week(week)
gen year = year(week)
gen schoolyear = year(week)+(inrange(month(week), 6, 12))
gen post_covid = [inrange(weeks_since_covid, 0, .)]
drop if weeks_since_covid>12


// restrict analysis to appropriate window
if "`type'" == "short" {
  local max 14
  local fig_max 12
  local min -25
  local fig_min -25
}

if "`type'" == "long" {
  sum weeks_since_covid
  local max = `r(max)'
  local min = `r(min)'
  local fig_max = 10
  local fig_min = -15
}
gen pre_period = [inrange(weeks_since_covid, ., `min')]
replace weeks_since_covid = 0 if !inrange(weeks_since_covid, `min', `max')

// create matrices for plotting below (where i will be the position in the matrix)
mat x = J(1, (`fig_max' - `fig_min' + 1), .)
mat y_inc = J(1, (`fig_max' - `fig_min' + 1), .)
mat y_tele = J(1, (`fig_max' - `fig_min' + 1), .)
mat se_inc = J(1, (`fig_max' - `fig_min' + 1), .)
mat se_tele = J(1, (`fig_max' - `fig_min' + 1), .)
mat y_tele_over_inc = J(1, (`fig_max' - `fig_min' + 1), .)

// factor variable can't be negative
local zero_val = abs(`min') + 1
replace weeks_since_covid = weeks_since_covid + `zero_val'

quietly sum `outcome'
replace `outcome' = ln(`outcome')

reg `outcome' i.post_covid i.week_of_year i.schoolyear [pw=pop]
reg `outcome' ib`zero_val'.weeks_since_covid i.week_of_year i.schoolyear i.pre_period [pw=pop]
if "`version'" == "tele" reg `outcome' ib`zero_val'.weeks_since_covid##c.ln_inc ib`zero_val'.weeks_since_covid##c.ln_tele i.week_of_year i.schoolyear i.pre_period i.state [pw=pop]
if "`version'" == "inc" reg `outcome' ib`zero_val'.weeks_since_covid##c.ln_inc ib`zero_val'.weeks_since_covid##c.ln_inc i.week_of_year i.schoolyear i.pre_period i.state [pw=pop]
if "`version'" == "inc_tele" reg `outcome' ib`zero_val'.weeks_since_covid##c.ln_inc ib`zero_val'.weeks_since_covid##c.ln_tele i.week_of_year i.schoolyear i.pre_period i.state [pw=pop], vce(cluster state)

// fill matrices with predicted outcomes and ses for the given week

foreach v in "inc" "tele" {
  local i 1
  local stub ".weeks_since_covid#c.ln_`v'"
  forval j = `fig_min'/`fig_max' {
      di "`j'"
      mat x[1, `i'] = `j'
      local k = `j' + `zero_val'
      cap mat y_`v'[1, `i'] = _b[`k'`stub']
      cap mat se_`v'[1, `i'] = _se[`k'`stub']
      if _rc {
        mat y_`v'[1, `i'] = 0
        mat se_`v'[1, `i'] = 0
        local _rc = 0
      }
      local ++i
  }
}

local i 1
forval j = `fig_min'/`fig_max' {
  if y_inc[1, `i'] == 0 {
    mat y_tele_over_inc[1, `i'] = 0
  }
  else {
    mat y_tele_over_inc[1, `i'] = y_tele[1, `i'] / y_inc[1, `i']
  }

  if inrange(y_tele_over_inc[1, `i'], ., -5) {
    mat y_tele_over_inc[1, `i'] = -5
  }
  if inrange(y_tele_over_inc[1, `i'], 5, .) {
    mat y_tele_over_inc[1, `i'] = 5
  }
  local ++i
}
// plot
local ytitle "Search intensity"

local inc_plot ""
local tele_plot ""
if ustrpos("`version'", "inc") local inc_plot `"(matrix(y_inc), se(se_inc) at(x))"'
if ustrpos("`version'", "tele") local tele_plot `"(matrix(y_tele), se(se_tele) at(x))"'
if "`type'" == "short" local plot "`inc_plot' `tele_plot'"
if "`type'" == "long" local plot "(matrix(y_tele_over_inc), at(x))"
if "`type'" == "short" local opts "scheme(lean1)"
if "`type'" == "long" local opts "recast(line) lwidth(medthick) ciopts(recast(rline) lp(dash) lwidth(vthin)) scheme(cleanplots)"
coefplot `plot', ///
`ylabel' `opts' vertical ///
ytitle(`ytitle') xtitle("Weeks since 3/1/2020") ///
xline(0) yline(0) yaxis(1) legend(order(2 "Income" 4 "Teleworkability"))
