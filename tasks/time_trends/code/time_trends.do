local outcome = "`1'"

do prep `outcome' drop_holidays

if "`outcome'"=="badges" local ytitle "Mean standardized Zearn badges"
if "`outcome'"=="engagement" local ytitle "Mean standardized Zearn engagement"
if "`outcome'"=="gtrends"|"`outcome'"=="specific1"|"`outcome'"=="generic" local ytitle "Mean search intensity"
replace income_quintile = 24 if inrange(income_quintile, 2, 4)

if "`outcome'"!="gtrends" collapse (mean) `outcome' [pw=pop], by(wkssnccovid income_quintile)
if "`outcome'"=="gtrends" collapse (mean) specific1 generic [pw=pop], by(wkssnccovid)
keep if inrange(wkssnccovid, -25, 10)

if "`outcome'"!="gtrends" {
    twoway (scatter `outcome' wkssnccovid if income_quintile==5, color(red)) ///
        (scatter `outcome' wkssnccovid if income_quintile == 24, color(gray) recast(line)) ///
        (scatter `outcome' wkssnccovid if income_quintile==1, color(blue)) ///
    , ytitle(`ytitle') xtitle("Weeks since 3/1/2020") ///
    xline(0) legend(label(1 "Top Income Quintile") label(2 "Middle Income Quintiles") label(3 "Bottom Income Quintile")) ///
    graphregion(color(white)) legend(pos(6) rows(1) region(lcolor(white)))
    graph export "../output/timetrend_`outcome'.eps", replace
}
else {
    twoway (line specific1 wkssnccovid, yaxis(1) color(red)) ///
        (line generic wkssnccovid, yaxis(2) color(blue)) ///
    , ytitle("`ytitle' (school-centered)", axis(1)) ytitle("`ytitle' (parent-centered)", axis(2))xtitle("Weeks since 3/1/2020") ///
    xline(0) legend(label(1 "School-centered resources") label(2 "Parent-centered resources")) ///
    graphregion(color(white)) legend(pos(6) rows(1) region(lcolor(white)))
    graph export "../output/timetrend_`outcome'.eps", replace
}
