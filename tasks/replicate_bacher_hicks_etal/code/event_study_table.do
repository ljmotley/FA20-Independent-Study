assert inlist("`1'", "zero_omit", "zero_one")
local version = "`1'"
use "../input/gtrends_outcomes_dma.dta" if dma != "US", clear

if "`version'" == "zero_one" local title "Changes in Search Intensity by Socioeconomic Status and Other Measures"
if "`version'" == "zero_omit" local title "Changes in Search Intensity, excluding low search intensity observations"

do replication_dataprep

drop if inrange(weeks_since_covid, 0, 3)
drop if inrange(weeks_since_covid, 13, .)

// Merge in other variables used in the regression
// Year fixed effects really changes it compared to school-year
local oi 1
foreach outcome in specific1 generic google khan {
    if "`version'" == "zero_one" replace `outcome' = 1 if mi(`outcome')
    replace `outcome' = ln(`outcome')

    reg `outcome' i.post_covid i.week_of_year i.schoolyear [pw=population], vce(cluster dma)
    est sto r_o`oi'_x0

    reg `outcome' i.post_covid##i.high_ses i.week_of_year i.schoolyear [pw=population], vce(cluster dma)
    est sto r_o`oi'_x1

    local xi 2
    foreach x in hh_mean_inc hh_broadband hh_computer sch_rural stu_black {
      reg `outcome' i.post_covid##c.`x' i.week_of_year i.schoolyear [pw=population], vce(cluster dma)
      local N_obs_`oi' = `e(N)'
      est sto r_o`oi'_x`xi'
      local ++xi
  }
  local ++oi
}

local opts "a f plain coll(none) nodep nomti c(b(star fmt(%9.2f)) se(abs par fmt(%9.2f))) star(* .10 ** .05 *** .01) noobs"
local temp "../output/temp.tex"
file open  t using "`temp'", replace write
file write t	"\begin{table}[htbp] \centering" _n "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}" _n ///
				"\caption{`title'}" _n ///
        "\scalebox{0.7}{" _n ///
				"\begin{tabular*}{1\textwidth}{@{\extracolsep{\fill}}l*{4}{c}}" _n "\midrule" _n ///
				"&School-	&Parent-	&			&		\\" _n ///
				"&centered	&centered	&Google		&Khan	\\" _n ///
				"&resources	&resources	&Classroom	&Academy\\" _n ///
				"&(1)&(2)&(3)&(4)\\" _n ///
				"\midrule" _n
file close t
file open  t using "`temp'", append write
file write t 	"(A) Nationwide \\" _n "\cmidrule{1-1}" _n
file close t
esttab r_o*_x0 using "`temp'", keep(1.post_covid) coeflabels(1.post_covid#1.high_ses "Post COVID $\times$ High SES") l s(,) `opts'
file open  t using "`temp'", append write
file write t "\cmidrule{1-1}" _n "(B) By median SES\\" _n "\cmidrule{1-1}" _n
file close t
esttab r_o*_x1 	using "`temp'", l keep(1.post_covid#1.high_ses 1.high_ses 1.post_covid) coeflabels(1.high_ses "High SES" 1.post_covid#1.high_ses "Post COVID $\times$ High-SES" 1.post_covid "Post COVID $\times$ Low-SES") s(, lay(`""')) `opts'
file open  t using "`temp'", append write
file write t "\cmidrule{1-1}" _n "(C) By income, online access, race\\" _n "\cmidrule{1-1}" _n
file close t
file open  t using "`temp'", append write
esttab r_o*_x2 	using "`temp'", l keep(1.post_covid#*) s(, lay(`""')) `opts'
esttab r_o*_x3 	using "`temp'", l keep(1.post_covid#*) s(, lay(`""')) `opts'
esttab r_o*_x4 	using "`temp'", l keep(1.post_covid#*) s(, lay(`""')) `opts'
esttab r_o*_x5 	using "`temp'", l keep(1.post_covid#*) s(, lay(`""')) `opts'
esttab r_o*_x6 	using "`temp'", l keep(1.post_covid#*) s(, lay(`""')) `opts'
file close t
file open t using "`temp'", append write
file write t  "\hline" _n ///
  "& `N_obs_1' & `N_obs_2' & `N_obs_3' & `N_obs_4'" _n ///
  "\end{tabular*}" _n ///
  "}" _n ///
  "\end{table}" _n
file close t
filefilter "`temp'" "../output/anothertemp.tex", f(post\BS_covid=1) t("Post COVID") replace
filefilter "../output/anothertemp.tex" "../output/bh_replication_event_study_table_`version'.tex", f(%) t(\BS%) replace
rm "../output/temp.tex"
rm "../output/anothertemp.tex"
