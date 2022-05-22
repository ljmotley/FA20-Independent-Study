import delimited "../input/MSA_workfromhome.csv", clear case(lower)

rename area* cbsa*

label data "Dingel-Neiman Teleworkability Scores"

gsort cbsa

compress

save "../output/telework_scores_cbsa.dta", replace
