gen weeks_since_covid = round((week - date("3/1/2020", "MDY"))/7)
gen week_of_year = week(week)
gen year = year(week)
gen schoolyear = year(week)+(inrange(month(week), 6, 12))

preserve
use "../input/gtrends_non_outcomes_dma.dta", clear

pca ba_plus hh_med_inc hh_mean_inc hh_broadband hh_computer [aw=population]
predict ses
xtile sesq2 = ses [pw=population], n(2)

replace hh_mean_inc = hh_mean_inc/10000
replace hh_broadband = hh_broadband/10
replace hh_computer = hh_computer/10
replace sch_rural = sch_rural*10
replace stu_black = (stu_black)*10

gen high_ses = [sesq2==2]

tempfile other_reg_vars
save `other_reg_vars'
restore

merge m:1 dma using `other_reg_vars', nogen

gen thxgiv = inlist(week,20414,20778,21142,21506,21877)
gen xmas	 = inlist(week,20442,20813,21177,21541,21905)
gen newyrs = inlist(week,20449,20814,21184,21548,21912)
drop if thxgiv|xmas|newyrs

gen post_covid = [inrange(weeks_since_covid, 0, .)]
