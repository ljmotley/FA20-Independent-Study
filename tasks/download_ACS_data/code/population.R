# libraries needed for tidycensus:
library(dplyr)
library(foreign)
library(tidycensus)
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

acs_comp <- get_acs(geography = "county",
                        variables = "B28003_002",
                        year = 2019) %>%
  rename("cty_comp" = "estimate") %>%
  select(c("GEOID", "cty_comp")) %>%
  mutate(cty_comp = as.numeric(cty_comp))

acs_broad <- get_acs(geography = "county",
                        variables = "B28002_004",
                        year = 2019) %>%
  rename("cty_broad" = "estimate") %>%
  select(c("GEOID", "cty_broad")) %>%
  mutate(cty_broad = as.numeric(cty_broad))

acs_hh <- get_acs(geography = "county",
                        variables = "B28002_001",
                        year = 2019) %>%
  rename("cty_totalhh" = "estimate") %>%
  select(c("GEOID", "cty_totalhh")) %>%
  mutate(cty_totalhh = as.numeric(cty_totalhh))



acs_output <- left_join(acs_pop, acs_medhhinc, by = c("GEOID"))
acs_output <- left_join(acs_output, acs_broad, by = c("GEOID"))
acs_output <- left_join(acs_output, acs_hh, by = c("GEOID"))
acs_output <- left_join(acs_output, acs_comp, by = c("GEOID")) %>%
  rename("cty" = "GEOID") %>%
  mutate(cty = as.numeric(cty))

write.dta(acs_output,"../output/ACS5yr2019_estimates.dta")


