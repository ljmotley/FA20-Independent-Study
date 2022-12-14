local outcome = substr("`1'", 1, strpos("`1'", "_") - 1)
local version = substr("`1'", strpos("`1'", "_") + 1, length("`1'"))
local type "`2'"
local typepath = ""
if "`type'"!="long" local typepath = ""
if "`type'"!="long" local type = "short"
if "`type'"=="long" local typepath = "_long"

cap program drop save_coefs
program define save_coefs
  args v_a fig_max fig_min zero_val
  local v= "`v_a'"
  if "`v_a'" == "incold" local v = "inc"
  mat x_`v_a' = J(1, (`fig_max' - `fig_min' + 1), .)
  mat y_`v_a' = J(1, (`fig_max' - `fig_min' + 1), .)
  mat se_`v_a' = J(1, (`fig_max' - `fig_min' + 1), .)
  if "`version'" == "inctele" mat y_tele_over_inc = J(1, (`fig_max' - `fig_min' + 1), .)
  if "`version'" == "inccomp" mat y_comp_over_inc = J(1, (`fig_max' - `fig_min' + 1), .)
  if "`version'" == "incbroad" mat y_broad_over_inc = J(1, (`fig_max' - `fig_min' + 1), .)
  local i 1

  if "`v'" == "wks" local stub ".wkssnccovid"
  if "`v'" != "wks" local stub ".wkssnccovid#c.ln`v'"
  local shift = 0
  if "`v_a'" == "tele" local shift = 0.15
  if "`v_a'" == "inc" local shift = -0.15

  forval j = `fig_min'/`fig_max' {
      mat x_`v_a'[1, `i'] = `j' + `shift'
      local k = `j' + `zero_val'
      cap mat y_`v_a'[1, `i'] = _b[`k'`stub']
      cap mat se_`v_a'[1, `i'] = _se[`k'`stub']
      if _rc {
        mat y_`v_a'[1, `i'] = 0
        mat se_`v_a'[1, `i'] = 0
        local _rc = 0
      }
      local ++i
  }
end

do prep `outcome' drop_holidays
if "`outcome'"=="badges" drop if wkssnccovid==-25
if "`outcome'"=="engagement" drop if wkssnccovid==-25

// restrict analysis to appropriate window
if "`type'" == "short" {
  local max 14
  local fig_max 12
  local min -25
  local fig_min -25
}

if "`type'" == "long" {
  sum wkssnccovid
  local max = `r(max)'
  local min = `r(min)'
  local fig_max = 60
  local fig_min = -60
}
gen preperiod = (inrange(wkssnccovid, ., `min'))
replace wkssnccovid = 0 if !inrange(wkssnccovid, `min', `max')

// factor variable can't be negative
local zero_val = abs(`min') + 1
replace wkssnccovid = wkssnccovid + `zero_val'

local spec "i.schoolyear i.preperiod [pw=pop], vce(cluster state)"
di "reg `outcome' ib`zero_val'.wkssnccovid `spec'"
if "`version'" == "wks" reg `outcome' ib`zero_val'.wkssnccovid `spec'
if "`version'" == "tele" reg `outcome' ib`zero_val'.wkssnccovid##c.lntele i.weekofyear `spec'
if inlist("`version'","inc","inctelealt") reg `outcome' ib`zero_val'.wkssnccovid##c.lninc i.weekofyear `spec'
if "`version'" == "inctelealt" save_coefs incold `fig_max' `fig_min' `zero_val'
if "`version'" == "inctele" reg `outcome' ib`zero_val'.wkssnccovid##c.lninc ib`zero_val'.wkssnccovid##c.lntele i.weekofyear `spec'
if "`version'" == "inccomp" reg `outcome' ib`zero_val'.wkssnccovid##c.lninc ib`zero_val'.wkssnccovid##c.lncomp i.weekofyear `spec'
if "`version'" == "incbroad" reg `outcome' ib`zero_val'.wkssnccovid##c.lninc ib`zero_val'.wkssnccovid##c.lnbroad i.weekofyear `spec'

local list "`version'"
if "`version'" == "inctele"    local list `""inc" "tele""'
if "`version'" == "inccomp"    local list `""inc" "comp""'
if "`version'" == "incbroad"    local list `""inc" "broad""'

foreach vs in `list' {
  save_coefs `vs' `fig_max' `fig_min' `zero_val'
}

local wks_plot ""
local inc_plot ""
local tele_plot ""
local broad_plot ""
local comp_plot ""
if ustrpos("`version'", "wks") local wks_plot `"(matrix(y_wks), se(se_wks) at(x))"'
if ustrpos("`version'", "inc") local inc_plot `"(matrix(y_inc), se(se_inc) at(x_inc))"'
if ustrpos("`version'", "tele") local tele_plot `"(matrix(y_tele), se(se_tele) at(x_tele))"'
if ustrpos("`version'", "broad") local tele_plot `"(matrix(y_broad), se(se_broad) at(x))"'
if ustrpos("`version'", "comp") local tele_plot `"(matrix(y_comp), se(se_comp) at(x))"'
local plot "`wks_plot' `inc_plot' `tele_plot'"
if "`version'" == "inctelealt" local plot `"(matrix(y_inc), se(se_inc) at(x)) (matrix(y_incold), se(se_incold) at(x))"'

local legend ""
if "`version'" == "inctele" local legend `"legend(order(2 "Income" 4 "Teleworkability") size(small) ring(0))"'
if "`version'" == "inctelealt" local legend `"legend(order(2 "Before teleworkability controls" 4 "After teleworkability controls") size(small) ring(0) position(0) bplacement(nwest))"'

if "`type'" == "short" local opts "scheme(lean1) xlabel(-20 -10 0 10)"
if "`type'" == "long" local opts "recast(line) lwidth(medthick) ciopts(recast(rline) lp(dash) lwidth(vthin) color(%50)) scheme(cleanplots)"
if "`outcome'"=="generic" local ylabel "ylabel(-0.4(0.2)0.8)"
if "`outcome'"=="specific1" local ylabel "ylabel(-1(0.5)2)"
if "`outcome'"=="generic" local ytitle "Log search interest"
if "`outcome'"=="specific1" local ytitle "Log search interest"
if "`outcome'"=="badges" local ytitle "Standardized Zearn badges"
if "`outcome'"=="engagement" local ytitle "Standardized Zearn engagement"

coefplot `plot', ///
`ylabel' `opts' vertical ///
ytitle(`ytitle') xtitle("Weeks since 3/1/2020") ///
xline(0) yline(0) yaxis(1) `legend' ///
graphregion(color(white))
graph export "../output/eventstudyplot_`outcome'_`version'`typepath'.eps", replace
