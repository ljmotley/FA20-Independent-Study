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

merge 1:m state dma_name using `county_dma', nogen

rename (state statefp cntyfp county dma_json_id) (state_abbr state cty cty_name dma)

order state state_abbr cty cty_name dma dma_name

compress

export delimited "../output/dma_to_cty.csv", replace
