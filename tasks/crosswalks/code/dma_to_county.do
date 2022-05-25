import excel "../input/county_dma.xlsx", firstrow case(lower) clear
rename dma dma_name

foreach char in "(" {
  split dma_name, p("`char'")
  drop dma_name
  rename dma_name1 dma_name
  keep state statefp cntyfp county dma_name
}

replace dma_name = ustrtrim(dma_name)
replace state = ustrtrim(state)
replace county = ustrtrim(county)

tempfile county_dma
save `county_dma'

use dma_json_id dma_name using "../input/dma_merged_analysis_file.dta", clear
duplicates drop

split dma_json_id, p(-)
keep dma*
rename dma_json_id2 state

foreach char in "," "-" "(" "&" {
  split dma_name, p("`char'")
  drop dma_name
  rename dma_name1 dma_name
  keep state dma_name dma_json_id
}

replace dma_name = ustrtrim(dma_name)
replace state = ustrtrim(state)

replace state = "IL" if dma_name == "CHAMPAIGN"
replace state = "IL" if dma_name == "DAVENPORT"
replace state = "NC" if dma_name == "NORFOLK"
replace state = "VA" if dma_name == "TRI"
replace dma_name = "TRI-CITIES, TN-VA" if dma_name == "TRI"
replace dma_name = "WILKES BARRE" if dma_name == "WILKES"
drop if dma_name == "US"

// THIS APPROACH WILL MISS COUNTIES IN NEIGHBORING STATES TO MAIN CITY IN DMA FOR THESE 21 DMAs
bys dma_name: gen n = _N
preserve
keep if n > 1
di _N
merge 1:m dma_name state using `county_dma', assert(using match) keep(match) nogen
tempfile non_unique_dma_name_matches
save `non_unique_dma_name_matches'
restore
drop state

keep if n == 1

// still need to match these two manually
drop if inlist(dma_name, "MYRTLE BEACH", "PALM SPRINGS")
merge 1:m dma_name using `county_dma', assert(using match) keep(match) nogen
append using `non_unique_dma_name_matches'
drop n

rename (dma_json_id state statefp cntyfp county) (dma state_abbr state cty cty_name)

order dma dma_name state state_abbr cty cty_name

replace cty = (1000*state) + cty

merge m:1 cty using "../../download_ACS_data/output/ACS5yr2019_estimates.dta", keep(match) keepusing(cty_population) nogen
bys dma: egen dma_population = sum(cty_population)
gen dma_pop_share = cty_population / dma_pop

compress

lab data "Trends DMA Code to County (Google DMA - Nielsen DMA - County)"

save "../output/dma_to_cty.dta", replace
