cd /Users/lukemotley/Documents/FA20-Independent-Study/tasks/replicate_FA20_version/code

use dmacode fips using "../input/final_data.dta", clear
rename fips cty
duplicates drop

tempfile crosswalk_old
save `crosswalk_old'

local outcome specific1
local v rep0
local c crosswalk_new
if "`v'"=="rep1" {
  di "OLD DATA PREP"
  qui {
    use "../input/gtrends_outcomes_dma.dta", clear
    split dma, p(-)
    rename dma3 dmacode
    destring dmacode, replace
    keep if !mi(dmacode)
    drop dma dma1 dma2
    tempfile gtrends
    save `gtrends'
    use fips dmacode date specific1-placebo2 inc_med_hh tele_pct std*  using "../input/final_data.dta", clear
    rename * fd_*
    rename (fd_fips fd_date fd_dmacode) (cty week dmacode)
    merge m:1 dma week using `gtrends', nogen
    foreach var of varlist specific1-placebo2 {
      replace `var' = ln(`var')
    }
    merge m:1 cty using "../input/cbsa_to_cty.dta", nogen
    merge m:1 cbsa using "../input/telework_scores_cbsa.dta", nogen
    merge m:1 cty using "../input/ACS5yr2019_estimates.dta", nogen
  }
  // summarize *inc*
  // summarize *tele*
  // summarize *specific1* *generic*
}
else if "`v'"=="rep0" {
  di "NEW DATA PREP"
  qui {
    use dma week specific1-placebo2 using "../input/gtrends_outcomes_dma.dta" if dma != "US", clear
    merge m:1 dma using "../input/gtrends_non_outcomes_dma.dta", keepusing(population hh_med_inc) keep(match) nogen
    split dma, p(-)
    rename dma3 dmacode
    destring dmacode, replace
  }
  if "`c'" == "crosswalk_old" {
    di "CROSSWALK OLD"
    joinby dmacode using `crosswalk_old'
  }
  if "`c'" == "crosswalk_new" {
    di "CROSSWALK NEW"
    joinby dma using "../input/dma_to_cty.dta"
  }
  qui {
    merge m:1 cty using "../input/ACS5yr2019_estimates.dta", nogen
    merge m:1 cty using "../input/cbsa_to_cty.dta", keep(master match)
    replace cbsa = 0 if cbsa == .
    keep if metro_micro == 2
    merge m:1 cbsa using "../input/telework_scores_cbsa.dta", nogen
  }
}
egen ln_tele = std(teleworkable_emp)

// All of the changes happen here
local pop cty_pop // cty_pop or population (BH DMA pop variable)
egen ln_inc = std(cty_medhhinc) // cty_medhhinc or medhhinc (BH DMA DMA income variable)

// scatter ln_tele fd_std_tel
// scatter ln_inc fd_std_inc

local outcome generic
local version tele
local type short

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

reg `outcome' i.post_covid i.week_of_year i.schoolyear [pw=`pop']
reg `outcome' ib`zero_val'.weeks_since_covid i.week_of_year i.schoolyear i.pre_period [pw=`pop']
if "`version'" == "tele" reg `outcome' ib`zero_val'.weeks_since_covid##c.ln_inc ib`zero_val'.weeks_since_covid##c.ln_tele i.week_of_year i.schoolyear i.pre_period i.state [pw=`pop']
if "`version'" == "inc" reg `outcome' ib`zero_val'.weeks_since_covid##c.ln_inc ib`zero_val'.weeks_since_covid##c.ln_inc i.week_of_year i.schoolyear i.pre_period i.state [pw=`pop']
if "`version'" == "inc_tele" reg `outcome' ib`zero_val'.weeks_since_covid##c.ln_inc ib`zero_val'.weeks_since_covid##c.ln_tele i.week_of_year i.schoolyear i.pre_period i.state [pw=`pop'], vce(cluster state)

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
