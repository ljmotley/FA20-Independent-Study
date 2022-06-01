cd /Users/lukemotley/Documents/FA20-Independent-Study/tasks/crosswalks/code
use dma dma_name cty using "../output/dma_to_cty.dta" if !mi(dma), clear
tempfile dma
save `dma'

use cbsa cbsa_name cty metro_micro using "../output/cbsa_to_cty.dta" if metro_micro == 2, clear
drop metro_micro
tempfile cbsa
save `cbsa'

use `dma', clear
joinby cty using `cbsa'

collapse (sum) cty_population, by(cty dma cbsa)

bys dma: egen dma_pop = sum(cty_population)
bys cbsa: egen cbsa_pop = sum(cty_population)

gen pop_share_dma = cty_population / dma_pop
gen pop_share_cbsa = cty_population / cbsa_pop

keep dma cty cbsa pop_share*
