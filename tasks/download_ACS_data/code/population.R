# libraries needed for tidycensus:
# rgdal dplyr RCpp
library(tidycensus)
library(dplyr)
census_api_key("c34c7f27552e3dede3099759c8a0f5ad0bbb3199")

acs_pop <- get_acs(geography = "county",
                 variables = "B01003_001",
                 year = 2019)  %>%
  rename("ctyfips" = "GEOID",
         "ctyname" = "NAME",
         "ctypop" = "estimate") %>%
  select(c("ctyfips", "ctyname", "ctypop"))
write.csv(acs_pop,
  "../output/ctypopulation_5yrACS2019.csv",
  row.names = FALSE)
