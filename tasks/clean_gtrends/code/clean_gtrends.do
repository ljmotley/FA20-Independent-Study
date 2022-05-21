use "../input/dma_merged_analysis_file.dta", clear

rename dma_json_id dma

preserve
keep dma dma_name week specific* generic google_classroom khan_academy kahoot placebo*

label data "Bacher-Hicks et al. Google Trends Outcomes"

save "../output/gtrends_outcomes.dta", replace
restore

drop week specific* generic google_classroom khan_academy kahoot placebo*

gsort dma week

label data "Bacher-Hicks et al. non-outcome variables (population, covariates, etc.)"

save "../output/gtrends_non-outcomes.dta", replace
