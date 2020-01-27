# estimate participation rates at the activity group level (act1) & state of residency
# based on analysis code from 2016: [analysis_dir]/code/5-profile/1-part-prof.Rmd

library(tidyverse)
library(readxl)
library(tablr2)
library(gizmoTamer)

source("code/0-act1-participation/func.R")

# Load Data ---------------------------------------------------------------

# 2016 results (3 lists: tot, out, stat)
# - includes useful tables: relation tables, outliers, etc.
load("E:/SA/Data-production/OIA_Rec_Econ_2016/Results/results.RDATA")

# relation tables
analysis_dir <- "H:/SA/Projects/OIA_Rec_Econ_2016/Analysis-OIA"
act_meta <- read_excel(file.path(analysis_dir, "data", "Activities.xlsx")) # activity levels
state_reg <- ungroup(out$state_reg) # regions by state

# survey data
load(file.path(analysis_dir, "data", "svy-wtd.RDATA"))

# Clean ---------------------------------------------------------

# remove outliers
svy_final <- anti_join(svy, stat$part_outliers, by = "sid")
svy_final <- varlab_get(svy_final, svy)

# recode zero days to no activity
# - this requires matching the activity answer to the day answer
check_vars <- setdiff(act_meta$checkvar, c("mtr", "nmtr", "all_act"))
day_vars <- setdiff(act_meta$dayvar, c("mtr_day", "nmtr_day", "all_day"))

test <- list()
x <- svy_final
for (i in seq_along(check_vars)) {
    x$check <- x[[check_vars[i]]]
    x$day <- x[[day_vars[i]]]
    levs <- levels(x[[check_vars[i]]])
    x$check <- as.character(x$check)
    x$check_new <- ifelse(x$check == "Checked" & !is.na(x$day) & x$day == 0, 
                          "Unchecked", x$check) %>% factor(levs)
    x$var <- check_vars[i]
    x$dayvar <- day_vars[i]
    test[[i]] <- x[x$check_new != x[[check_vars[i]]] & !is.na(x[check_vars[i]]), ] %>%
        count(var, dayvar, check_new, check, day)
    x[[check_vars[i]]] <- x$check_new
    x <- select(x, -var, -dayvar, -check, -check_new, -day)
}
svy_final <- varlab_get(x, svy)
rm(x)

# Prepare Activity Groups -------------------------------------------------

# participation questions weren't asked by activity groups
# so individual activity questions must be aggregated
rates_mtr <- get_check_grp(svy_final, "act.mtr.all", "mtr")
rates_nmtr <- get_check_grp(svy_final, "act.nmtr.all", "nmtr")

svy_final <- svy_final %>%
    left_join(rates_mtr, by = "sid") %>%
    left_join(rates_nmtr, by = "sid")

# Motor Participation -----------------------------------------------------

mtr <- svy_final %>%
    group_by(state) %>%
    freqm(setdiff(names(rates_mtr), "sid"), "stwt") %>%
    ungroup() %>%
    mutate(act = "mtr")

# Nonmotor Participation --------------------------------------------------

# those who answered "None of these" didn't get the follow-up activity question
# - so the activity group question needs to be modified by this percentage
nmtr_grp <- svy_final %>% 
    gFreq(stwt, state, grp.nmtr.all_14) %>%
    filter(grp.nmtr.all_14 == "Unchecked") %>% 
    select(state, grp_rate = pct)

# activity group rates
nmtr <- svy_final %>%
    group_by(state) %>%
    freqm(setdiff(names(rates_nmtr), "sid"), "stwt") %>%
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
