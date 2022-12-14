use "../input/dma_merged_analysis_file.dta", clear

rename dma_json_id dma

if "`1'" == "outcomes" {
  keep dma dma_name week specific* generic google_classroom khan_academy kahoot placebo*
  label data "Bacher-Hicks et al. Google Trends Outcomes"
  compress
  save "../output/gtrends_outcomes_dma.dta", replace
}
else if "`1'" == "non_outcomes" {
  drop week specific* generic google_classroom khan_academy kahoot placebo*
  gsort dma
  duplicates drop
  label data "Bacher-Hicks et al. non-outcome variables (population, covariates, etc.)"
  compress
  save "../output/gtrends_non_outcomes_dma.dta", replace
}
