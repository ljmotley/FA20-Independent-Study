import delimited using "../input/Zearn_County_Weekly.csv", clear case(lower)
tostring year month day, replace
gen str_date = month + "/" + day + "/" + year
gen week = date(str_date, "MDY")
format week %d

rename countyfips cty

gen exists_break_badges = [!mi(break_badges)]
gen exists_break_engagement = [!mi(break_engagement)]
gen exists_badges = [!mi(badges)]
gen exists_engagement = [!mi(engagement)]

count if exists_break_badges & exists_engagement
assert(`r(N)' == 0)

count if exists_break_engagement & exists_badges
assert(`r(N)' == 0)

gen break = [exists_break_engagement | exists_break_engagement]

replace badges = max(badges, break_badges)
replace engagement = max(badges, break_engagement)

keep cty week engagement badges imputed_from_cz break
order cty week engagement badges imputed_from_cz break

lab var week "END OF WEEK DAY"

gsort cty week

compress

lab data "Zearn learning outcome variables"

save "../output/zearn_outcomes.dta"
