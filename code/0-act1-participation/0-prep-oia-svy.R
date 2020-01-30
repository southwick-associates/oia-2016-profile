# prepare oia svy data for estimating act1 profiles

library(tidyverse)
library(readxl)
library(tablr2)
library(gizmoTamer)

source("code/0-act1-participation/func.R")

# Load Data ---------------------------------------------------------------

# 2016 results (3 lists: tot, out, stat)
# - includes useful tables: relation tables, outliers, etc.
load("data/results.RDATA")

# relation tables
act_meta <- read_excel("data/Activities.xlsx") # activity levels
state_reg <- ungroup(out$state_reg) # regions by state

# survey data
load("data/svy-wtd.RDATA") # svy_wtd

# Clean ---------------------------------------------------------

# remove outliers
svy_final <- anti_join(svy_wtd, stat$part_outliers, by = "sid")
svy_final <- varlab_get(svy_final, svy_wtd)

# recode zero days to no activity
# - this requires matching the activity answer to the day answer
check_vars <- setdiff(act_meta$checkvar, c("mtr", "nmtr", "all_act"))
day_vars <- setdiff(act_meta$dayvar, c("mtr_day", "nmtr_day", "all_day"))

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
    x[[check_vars[i]]] <- x$check_new
    x <- select(x, -var, -dayvar, -check, -check_new, -day)
}
svy_final <- varlab_get(x, svy_wtd)
rm(x)

# Prepare Activity Groups -------------------------------------------------

# participation questions weren't asked by activity groups
# so individual activity questions must be aggregated
rates_mtr <- get_check_grp(svy_final, "act.mtr.all", "mtr")
rates_nmtr <- get_check_grp(svy_final, "act.nmtr.all", "nmtr")

svy_final <- svy_final %>%
    left_join(rates_mtr, by = "sid") %>%
    left_join(rates_nmtr, by = "sid")

# Save --------------------------------------------------------------------

# only a subset of survey variables are needed
svy_final %>%
    select(sid, flag, state, natwt, regwt, stwt, grp.nmtr.all_14, motorcycle:wildlife) %>%
    saveRDS("data-work/svy.rds")
