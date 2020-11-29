* Author: Luke Motley
* Purpose: Analysis for independent study project on the relationship between the ability to work from home and online learning engagement and achievement at the onset of the COVID-19 pandemic
cd "/Users/ljmotley/Desktop/IS"
sysdir set PLUS "/Users/ljmotley/Desktop/stata_packages"
use final_data

* get "inc" and "tele" to front of variable name for convenience
rename (med_hh_inc_county pct_teleworkable) (inc_med_hh_county  tele_pct)

* year later used as a fixed effect in regressions
generate year = year(date(week, "YMD###"))

* take log so differences can be interpreted as pct change
foreach x of varlist specific1-placebo2 {
	gen ln_`x' = ln(`x')
}

* create indicators
foreach x of varlist tele_pct inc_med {
	gen high_`x' = `x' * 0
	quietly sum `x', detail
	replace high_`x' = 1 if `x' > r(p50) & high_`x' != .
}

* Locals that will be useful when creating plots
local covid_date = "2/23/2020"
local set_high_tele_pct = `"legend(label(1 "High Teleworkability") label(2 "Low Teleworkability"))"'
local set_high_inc_med_hh_county = `"legend(label(1 "High Income") label(2 "Low Income"))"'
local title_ln_specific1 = "School-Oriented Search Terms"
local title_ln_generic = "Parent-Oriented Search Terms"
local title_badges = "Zearn Badges"
local title_engagement = "Zearn Engagement"
local axis_ln_specific1 = "Log Search Intensity"
local axis_ln_generic = "Log Search Intensity"
local axis_badges = "Badges"
local axis_engagement = "Engagement"
local axis_high_inc_med_hh_county = `"(High - Low Income) "'
local axis_high_tele_pct = `"(High - Low Teleworkability) "'
unab dep_vars: badges engagement ln_generic ln_specific1 

* generate histograms to get an idea of the distributions
foreach x of varlist `dep_vars' {
	histogram `x', title("Histogram of `title_`x''") xtitle("`axis_`x''") color(gray) lcolor(black)
	graph export "/Users/ljmotley/Desktop/IS/final_graphs/histogram_`x'.png", as(png) name("Graph") replace
}

* standardize variables for later comparisons
foreach x of varlist badges engagement ln_generic ln_specific1 {
	egen std_`x' = std(`x')
}

* scatterplots broken up by groups
save final_data_1, replace
foreach x of varlist `dep_vars'  {
	foreach y of varlist high_inc high_tele {
		drop if wks_snc_covid < -60
		collapse (mean) std_`x', by(`y' wks_snc_covid)
		scatter std_`x' wks_snc_covid if `y' == 1, mcolor(black) msize(small) || scatter std_`x' wks_snc_covid if `y' == 0, mcolor(white) msize(small) mlcolor(black) `set_`y'' title("Average `title_`x'' by Group") xtitle("Weeks Since `covid_date'") ytitle("`axis_`x''") xline(0, lp(dash) lwidth(thin)) yline(0) 
		 graph export "/Users/ljmotley/Desktop/IS/final_graphs/scatter_`x'_`y'.png", as(png) name("Graph") replace
		 use final_data_1, clear
	}
}

* reverse the order of the "weeks before covid" indicators so they are chronological
order bf25, after(af25)
forval i = 24(-1)1 {
	local j = `i' + 1
	order bf`i', after(bf`j')
}

* create labels matrix for coefplots
mat t = J(1, 50, .)
forvalue i = 1/25 {
	matrix t[1, `i'] = -26 + `i'
}
forvalue i = 26/50 {
	matrix t[1, `i'] = -25 + `i'
}

* general regressions
foreach x of varlist `dep_vars' {
	quietly reghdfe `x' bf* af* [pweight = population_county], absorb(wk_of_yr year)
	mat A = r(table)
	mat beta = A[1, 1..colsof(A)-1]
	mat se = A[2, 1..colsof(A)-1]
	foreach i in "t" "beta" "se" {
		quietly mata: st_matrix("`i'_", select(st_matrix("`i'"), st_matrix("se")[1,.]:!=.))
	}
	coefplot (matrix(beta_), se(se_) at(t_)), xline(0, lp(dash) lwidth(thin)) title("`title_`x''") ytitle("`axis_`x''") xtitle("Week relative to `covid_date'", height(4)) coeflabels(, labsize(vsmall)) yline(0)
	graph export "/Users/ljmotley/Desktop/IS/final_graphs/coefplot1_`x'.png", as(png) name("Graph") replace
}

foreach x of varlist `dep_vars' {
	foreach y of varlist high_inc high_tele {
		if `x' == ln_specific1 | `x' == ln_generic {
			mat t_ = t[1, 1..colsof(t)-10]
			local s1 = 53
			local e1 = 152
			local s2 = 193
		}
		else {
			mat t_ = t[1, 1..10], t[1, 18..colsof(t)]
			local s1 = 46
			local e1 = 131
			local s2 = 182
		}
		quietly reghdfe `x' `y'##bf* `y'##af* [pweight = population_county], absorb(wk_of_yr year)
		mat A = r(table)
		mat beta = A[1, `s1'..`e1'], A[1, `s2'..colsof(A)-1]
		mat se = A[2, `s1'..`e1'], A[2, `s2'..colsof(A)-1]
		foreach i in "beta" "se" {
			quietly mata: st_matrix("`i'_", select(st_matrix("`i'"), st_matrix("se")[1,.]:!=.))
		}
		coefplot (matrix(beta_), se(se_) at(t_)), xline(0, lp(dash) lwidth(thin)) title("`title_`x''") ytitle("`axis_`y' '`axis_`x''") xtitle("Week relative to `covid_date'", height(4)) coeflabels(, labsize(vsmall)) yline(0)
		graph export "/Users/ljmotley/Desktop/IS/final_graphs/coefplot_`y'_`x'.png", as(png) name("Graph") replace
	}
}

quietly reghdfe `x' `y'##bf* `y'##af* [pweight = population_county], absorb(wk_of_yr year)
		mat A = r(table)
		mat beta = A[1, `s1'..`e'], A[1, `s2'..colsof(A)-1]
		mat se = A[2, `s1'..`e'], A[2, `s2'..colsof(A)-1]

foreach x of varlist `dep_vars' {
	if `x' == ln_specific1 | `x' == ln_generic {
		mat t_ = t[1, 1..colsof(t)-10]
		local s1 = 53
		local e = 152
		local s2 = 193
		local e2 = 272
	}
	else {
		mat t_ = t[1, 1..11], t[1, 19.. colsof(t)]
		local s1 = 46
		local e = 131
		local s2 = 182
		local e2 = 281
	}
	quietly reghdfe `x' high_inc##bf* high_inc##af* high_tele##bf* high_tele##af*, absorb(wk_of_yr year)
	mat A = r(table)
	mat beta_inc = A[1, `s1'..`e'], A[1, `s2'..`e2']
	mat se_inc = A[2, `s1'..`e'], A[2, `s2'..`e2']
	mat beta_tele = A[1, 3+`e2'..colsof(A)-1]
	mat se_tele = A[2, 3+`e2'..colsof(A)-1]
	foreach i in "beta_inc" "beta_tele" "se_inc" "se_tele" {
		quietly mata: st_matrix("`i'_", select(st_matrix("`i'"), st_matrix("se_tele")[1,.]:!=.))
	}
	coefplot (matrix(beta_inc_), se(se_inc_) at(t_)) (matrix(beta_tele_), se(se_tele_) at(t_)), xline(0, lp(dash) lwidth(thin)) title("`title_`x''") ytitle("(High - Low Income/Tele) `axis_`x''") xtitle("Week relative to `covid_date'", height(4)) coeflabels(, labsize(vsmall)) yline(0) legend(order(2 "High-Low Income" 4 "High-Low Teleworkability"))
		graph export "/Users/ljmotley/Desktop/IS/final_graphs/coefplot_fullreg_`x'.png", as(png) name("Graph") replace
}
