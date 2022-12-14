use "../input/gtrends_outcomes_dma.dta", clear

// Handle arguments
foreach var of varlist * {
  if "`1'" == "`var'" local in_set = 1
}
assert(`in_set' == 1) // assert our outcome argument is a variable in the set
local outcome "`1'"
assert(inlist("`2'", "ses", "intensity")) // assert version inputted correctly
local version = "`2'"


if "`version'" == "ses" {
  keep if dma != "US"
  replace `outcome' = 1 if mi(`outcome')
  replace `outcome' = ln(`outcome')
}
else if "`version'" == "intensity" {
  keep if dma == "US"
  foreach y of varlist specific1 specific2 generic google_classroom khan_academy kahoot {
    replace `y'=ln(`y')
    gen tempref`y' = `y' if week==21975
    egen ref`y' = max(tempref`y')
    replace `y'=`y'-ref`y'
  }
}

// Merge in other variables used in the regression
do replication_dataprep
drop if inrange(weeks_since_covid, 13, .)

// restrict analysis to appropriate window
local max 12
local fig_max 10
local min -25
local fig_min -25
gen pre_period = [inrange(weeks_since_covid, ., `min')]
replace weeks_since_covid = 0 if !inrange(weeks_since_covid, `min', `max')

// factor variable can't be negative
local zero_val = abs(`min') + 1
replace weeks_since_covid = weeks_since_covid + `zero_val'

// create matrices for plotting below (where i will be the position in the matrix)
local i 1
mat x = J(1, (`fig_max' - `fig_min' + 1), .)
mat y = J(1, (`fig_max' - `fig_min' + 1), .)
mat se = J(1, (`fig_max' - `fig_min' + 1), .)

// run regression
if "`version'" == "ses" local var "ib`zero_val'.weeks_since_covid##i.high_ses i.pre_period##i.high_ses"
if "`version'" == "intensity" local var "ib`zero_val'.weeks_since_covid i.pre_period"
if "`version'" == "ses" local opts "[pw=population], vce(cluster dma)"
if "`version'" == "intensity" local opts ", vce(robust)"

reg `outcome' `var' i.week_of_year i.schoolyear `opts'

// fill matrices with predicted outcomes and ses for the given week
if "`version'" == "ses"       local stub ".weeks_since_covid#1.high_ses"
if "`version'" == "intensity" local stub ".weeks_since_covid"
forval j = `fig_min'/`fig_max' {
    mat x[1, `i'] = `j'
    local k = `j' + `zero_val'
    cap mat y[1, `i'] = _b[`k'`stub']
    cap mat se[1, `i'] = _se[`k'`stub']
    if _rc {
      mat y[1, `i'] = 0
      mat se[1, `i'] = 0
      local _rc = 0
    }
    local ++i
}

// plot
if "`version'" == "ses" local ytitle "High - low SES search intensity"
if "`version'" == "intensity" local ytitle "Search intensity"
if "`version'" == "ses" local ylabel "ylabel(-0.3(0.3)0.6)"
if "`version'" == "intensity" local ylabel "ylabel(-0.3(0.3)1.2)"
coefplot matrix(y), at(x) se(se) xlabel(-25(5)10) `ylabel' ///
ytitle(`ytitle') xtitle("Weeks since 3/1/2020") ///
xline(0) yline(0) graphregion(color(white)) scheme(lean1)
graph export "../output/`version'_bh_replication_event_study_`1'.eps", replace
