# estimate participation rates at the activity group level (act1) & state of residency
# based on analysis code from 2016: [analysis_dir]/code/5-profile/1-part-prof.Rmd

library(tidyverse)
library(readxl)
library(tablr2)
library(gizmoTamer)

source("code/0-act1-participation/func.R")
svy <- readRDS("data-work/svy.rds")
load("data/results.RDATA")

# Motor Participation -----------------------------------------------------

# variable names for selected activities
acts <- select(svy, motorcycle:rv) %>% names()

mtr <- svy %>%
    group_by(state) %>%
    freqm(acts, "stwt") %>%
    ungroup() %>%
    mutate(act = "mtr")

# Nonmotor Participation --------------------------------------------------

# those who answered "None of these" didn't get the follow-up activity question
# - so the activity group question needs to be modified by this percentage
nmtr_grp <- svy %>% 
    gFreq(stwt, state, grp.nmtr.all_14) %>%
    filter(grp.nmtr.all_14 == "Unchecked") %>% 
    select(state, grp_rate = pct)

# activity group rates
acts <- select(svy, run:wildlife) %>% names()
nmtr <- svy %>%
    group_by(state) %>%
    freqm(acts, "stwt") %>%
    ungroup()
    
nmtr <- nmtr %>%
    right_join(nmtr_grp, by = "state") %>%
    mutate(pct = pct * grp_rate, act = "nmtr")

# Total Participants ------------------------------------------------------

# combine
part <- bind_rows(mtr, nmtr) %>%
    filter(Response) %>% # percent of those who checked activity
    select(state, act, act1 = var, rate = pct, se = standard.error) 

# total participants
part <- left_join(part, tot$pop, by = "state") %>%
    mutate(part = pop * rate) %>%
    select(state, reg_num, reg, act:se, pop, part)

# Save --------------------------------------------------------------------

saveRDS(part, "data-work/part-rate-act1.rds")
