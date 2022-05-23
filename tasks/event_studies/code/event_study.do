cd "/Users/ljmotley/Desktop/FA20-Independent-Study/tasks/event_studies/code"

use "../input/ACS5yr2019_estimates.dta", clear
sum cty_medhhinc, d
gen high_inc = [inrange(cty_medhhinc, `r(mean)', .)]
tempfile acs
save `acs'

use "../input/zearn_outcomes.dta", clear
merge m:1 cty using `acs', assert(match using) keep(match)
local outcome badges

gen weeks_since_covid = round((week - date("3/1/2020", "MDY"))/7)
gen week_of_year = week(week)
gen year = year(week)
gen schoolyear = year(week)+(inrange(month(week), 6, 12))
gen post_covid = [inrange(weeks_since_covid, 0, .)]

drop if inrange(weeks_since_covid, 16, .)

// restrict analysis to appropriate window
local max 15
local fig_max 15
local min -25
local fig_min -25
gen pre_period = [inrange(weeks_since_covid, ., `min')]
replace weeks_since_covid = 0 if !inrange(weeks_since_covid, `min', `max')

// create matrices for plotting below (where i will be the position in the matrix)
local i 1
mat x = J(1, (`fig_max' - `fig_min' + 1), .)
mat y = J(1, (`fig_max' - `fig_min' + 1), .)
mat se = J(1, (`fig_max' - `fig_min' + 1), .)

// factor variable can't be negative
local zero_val = abs(`min') + 1
replace weeks_since_covid = weeks_since_covid + `zero_val'

reg `outcome' i.post_covid i.week_of_year i.schoolyear [pw=cty_pop]
reg `outcome' ib`zero_val'.weeks_since_covid i.week_of_year i.schoolyear i.pre_period [pw=cty_pop]
reg `outcome' ib`zero_val'.weeks_since_covid##i.high_inc i.week_of_year i.schoolyear i.pre_period [pw=cty_pop]

// fill matrices with predicted outcomes and ses for the given week
local stub ".weeks_since_covid#1.high_inc"
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
local ytitle "Search intensity"

coefplot matrix(y), at(x) se(se) xlabel(-25(5)10) `ylabel' ///
ytitle(`ytitle') xtitle("Weeks since 3/1/2020") ///
xline(0) yline(0) scheme(lean1)
