# libraries needed for tidycensus:
# rgdal dplyr RCpp
library(tidycensus)
library(dplyr)
library(foreign)
census_api_key("c34c7f27552e3dede3099759c8a0f5ad0bbb3199")

acs_pop <- get_acs(geography = "county",
                   variables = "B01003_001",
                   year = 2019) %>%
  rename("cty_population" = "estimate") %>%
  select(c("GEOID","cty_population")) %>%
  mutate(cty_population = as.numeric(cty_population))

acs_medhhinc <- get_acs(geography = "county",
                        variables = "B29004_001",
                        year = 2019) %>%
  rename("cty_medhhinc" = "estimate") %>%
  select(c("GEOID", "cty_medhhinc")) %>%
  mutate(cty_medhhinc = as.numeric(cty_medhhinc))

acs_output <- left_join(acs_pop, acs_medhhinc, by = c("GEOID")) %>%
  rename("cty" = "GEOID") %>%
  mutate(cty = as.numeric(cty))

write.dta(acs_output,"../output/ACS5yr2019_estimates.dta")
