# Author: Luke Motley
# Purpose: Create the datasets used in Independent Study project, which 
# investigates changes in engagement with online resources at the onset of the 
# COVID-19 pandemic. 
###############################################################################
setwd("~/Desktop/IS")
library(reshape2)
library(dplyr)
library(tidyr)
library(readxl)
library(writexl)

na_zero <- function(df) {
  df[is.na(df)] <- 0
  return(df)
}

#CREATE GOOGLE DATASET --------------------------------------------------------
gtrends_dma <- read_excel("trends_dma_data.xlsx", sheet = "Sheet1")
dmarank_to_dmacode <- read_excel("trends_dma_data.xlsx", sheet = "Sheet2")
dma_to_county <- read_excel("county_dma.xlsx") 

#convert state and county FIPS to full FIPS code
dma_to_county$FIPS <-  as.numeric(paste(dma_to_county$STATEFP, 
                                        formatC(dma_to_county$CNTYFP, 
                                                width=3, 
                                                flag="0"), 
                                        sep="")) 
dma_to_county <- dma_to_county %>% 
  left_join(dmarank_to_dmacode, by = "DMARANK") %>% 
  select(COUNTY, STATE, FIPS, DMA.x, DMAINDEX) %>% 
  rename(DMA = DMA.x)

gtrends_county <- dma_to_county %>% right_join(gtrends_dma, by = "DMAINDEX")

# CREATE ZEARN DATASET --------------------------------------------------------
zearn_county <- read_excel("Zearn_County_Weekly_3.xlsx")

# adjust date format to match Google data ("week" is day the week began)
zearn_county$week <- as.Date(
  as.character(
    gsub(" ",
         "",
        paste(zearn_county$year,
              "/",
              zearn_county$month,
              "/", 
              zearn_county$day_endofweek), 
              fixed = TRUE), 
              format="%Y/%m/%d")) - 6

zearn_county <- zearn_county %>% 
  rename(FIPS = countyfips, 
         normal_engagement = engagement, 
         normal_badges = badges) %>% 
  mutate(normal_engagement = as.numeric(normal_engagement),
         break_engagement = as.numeric(break_engagement))

# combine  break and normal variables, create indicator for break
zearn_county <-  zearn_county %>% 
  mutate(engagement = coalesce(normal_engagement, break_engagement), 
         badges = coalesce(normal_badges, break_badges)) 
zearn_county$"break" <- zearn_county$break_engagement / 
  zearn_county$break_engagement
zearn_county[is.na(zearn_county$"break"), "break"] <- 0

# Create Occupational Statistics Dataset --------------------------------------
emp_data <- read_excel("Occupational Data.xlsx")
hh_inc_county <- pop_county <- read_excel("ACS_med_hh_inc_2018.xlsx")
pop_county <- read_excel("ACS_2018_population_county.xlsx")
tele_data <- read_excel("teleworkable.xlsx")
cbsa_to_county <- read_excel("cbsa_crosswalk_2.xlsx")

tele_data <- tele_data %>% rename(OCC_TITLE = OES_TITLE)
cbsa_to_county <- cbsa_to_county %>% rename(CBSA = CBSAFP)
# Get full FIPS code
cbsa_to_county$FIPS= as.numeric(paste(cbsa_to_county$STATEFP, 
                                      formatC(cbsa_to_county$COUNTYFP, 
                                              width=3, 
                                              flag="0"), 
                                      sep=""))

# Check: There should be roughly 3000 FIPS codes and 900 CBSA codes
length(unique(cbsa_to_county$FIPS))
length(unique(cbsa_to_county$CBSA))

emp_data <- emp_data %>% 
  mutate(AREA = as.numeric(AREA)) %>% 
  rename(CBSA = AREA) %>% 
  left_join(tele_data, by = c("OCC_CODE", "OCC_TITLE")) %>% 
  select(CBSA, AREA_NAME, OCC_TITLE, TOT_EMP, teleworkable) %>% 
  drop_na(teleworkable)
emp_data$TOT_EMP <- na_zero(as.numeric(emp_data$TOT_EMP))
# weight emp statistics by tele data to estimate total teleworkable jobs
emp_data$TOT_EMP_TEL <- emp_data$TOT_EMP * emp_data$teleworkable
# reshape data--x per industry w/ CBSA code observations, emp stats variables
emp_reshape <- function(x) {
  return(emp_data %>% 
           group_by(CBSA, OCC_TITLE) %>% 
           summarize(.data[[x]]) %>% 
           dcast(CBSA ~ OCC_TITLE, fun.aggregate = NULL))
}
# employment data by cbsa and county, including proportion of teleworkable jobs
emp_cbsa <- list(emp_reshape("TOT_EMP"), emp_reshape("TOT_EMP_TEL"))
emp_cbsa <- lapply(emp_cbsa, na_zero)
emp_cbsa <- lapply(emp_cbsa, function(x) cbind(x, rowSums(x[, 2:757])) %>% 
                     rename(TOT = ncol(x) + 1) %>% 
                     select(CBSA, TOT))
emp_cbsa <- left_join(emp_cbsa[[1]], emp_cbsa[[2]], by = "CBSA") %>% 
  rename(TOT_EMP = 2, TOT_TEL = 3)
emp_cbsa$pct_teleworkable <- emp_cbsa$TOT_TEL / emp_cbsa$TOT_EMP
emp_county <- cbsa_to_county %>% 
  select(CBSA, CBSA_TITLE, FIPS, NAMELSAD) %>% 
  left_join(emp_cbsa, by = c("CBSA")) %>% 
  drop_na(TOT_EMP)

# Check: See if it matches Dingel and Neiman paper when sorted by
# pct_teleworkable, should be ranked:
# 1 CBSA = 41940 (pct_teleworkable ~ .512), 2 47900 (~.499), ...
top_100 <- emp_cbsa[emp_cbsa[, "TOT_EMP"] >= 
                      sort(emp_cbsa$TOT_EMP, TRUE)[100], ]


# Create final data sets ------------------------------------------------------
wks_snc_date <- function(vec, date) {
  return(as.numeric(as.Date(as.character(vec), format="%Y-%m-%d") - 
                      as.Date(as.character(date), format="%Y-%m-%d"))/7)
}

wks_snc_covid_indicators <- function(x) {
  for(i in seq(1, min(25, max(x$wks_snc_covid)))) {
    new_col <- as.integer(as.logical(x$wks_snc_covid == i))
    x <- cbind(x, new_col)
    colnames(x)[ncol(x)] <- paste("af", i, sep="")
  }
  
  for(i in seq(1, 25)) {
    new_col <- as.integer(as.logical(x$wks_snc_covid == -1*i))
    x <- cbind(x, new_col)
    colnames(x)[ncol(x)] <- paste("bf", i, sep="")
  }
  return(x)
}

gtrends_county$covid_date <-  as.Date(as.character("2/23/2020"), 
                                      format="%m/%d/%Y")
gtrends_county$yr_start_date <- as.Date(as.character("1/3/2016"), 
                                        format="%m/%d/%Y")
zearn_county$covid_date <-  as.Date(as.character("2/24/2020"), 
                                    format="%m/%d/%Y")
zearn_county$yr_start_date <- as.Date(as.character("12/31/2018"), 
                                      format="%m/%d/%Y")

final_data <- list(zearn_county, gtrends_county)
final_data <- lapply(final_data, 
                     function(x) cbind(x, wks_snc_date(x$week, x$covid_date)))
final_data <- lapply(final_data, 
                     function(x) rename(x, wks_snc_covid = ncol(x)))
final_data <- lapply(final_data, 
                     function(x) cbind(x,
                                      wks_snc_date(x$week, 
                                                   x$yr_start_date) %% 52 + 1))
final_data <- lapply(final_data, 
                     function(x) rename(x, wk_of_yr = ncol(x)))
final_data <- lapply(final_data, 
                     function(x) relocate(x, 
                                          wk_of_yr,
                                          wks_snc_covid, .after=week))
final_data <- lapply(final_data,
                     function(x) filter(x, wks_snc_covid >= -113))
final_data <- lapply(final_data, 
                     wks_snc_covid_indicators)
final_data <- lapply(final_data, 
                     function(x) left_join(x, emp_county, by = c("FIPS")))
final_data <- lapply(final_data, 
                     function(x) left_join(x, 
                                           hh_inc_county, 
                                           by = c("FIPS")) %>% 
                       select(-GEO_ID))
final_data <- lapply(final_data, 
                     function(x) left_join(x, pop_county, by = c("FIPS")) %>%
                       select(-GEO_ID, -NAME))




