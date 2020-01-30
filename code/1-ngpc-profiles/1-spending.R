# pull OIA total national spending
# by activity category (n=17) and item

library(tidyverse)
library(readxl)

load("data/results.RDATA") # out, stat, tot
part_act1 <- readRDS("data-work/part-rate-act1.rds")

# Trip & Equipment ----------------------------------------------------------

# for grouping by motorized vs. nonmotorized activities
groups <- out$act_meta %>%
    filter(act1 != "all") %>%
    distinct(act, act1)

trip <- tot$trip_spend %>%
    group_by(act1, item) %>%
    summarise(spend = sum(trip_spend_tot)) %>%
    ungroup() %>%
    mutate(type = "trip") %>%
    left_join(groups, by = "act1")

equip <- tot$equip_all %>%
    group_by(act1, item) %>%
    summarise(spend = sum(equip_spend_tot)) %>%
    ungroup() %>%
    mutate(type = "equip") %>%
    left_join(groups, by = "act1")

# Vehicle -----------------------------------------------------------------

# an additional table is needed to summarize by activity category (act1)
f <- "data/Vehicle_act1.xlsx"
vehicle_categories <- read_excel(f, sheet = "vehicle_act1") %>%
    select(act, act1, act_vehicle_all)

vehicle <- tot$vehicle_spend %>%
    mutate(item = ifelse(age == "new", "new_vehicle", "used_vehicle")) %>%
    left_join(vehicle_categories, by = "act_vehicle_all") %>%
    group_by(act, act1, item) %>%
    summarise(spend = sum(tot_spend)) %>%
    ungroup() %>%
    mutate(type = "vehicle")

# Combine & Save -------------------------------------------------------------

spend <- bind_rows(trip, equip, vehicle) %>%
    filter(act1 != "wildlife") # not including any hunting/fishing/wildlife-watching
saveRDS(spend, "data-work/spend.rds")

# Summarize ---------------------------------------------------------------

# total spending
# - excluding fish/hunt/wildlife-watching
# - see O365 > OIA-2016-001 > Deliverables > OIA...National-Regional...xlsx
tot <- tibble(
    act = "Total", act1 = "Total", spend = sum(spend$spend)
)

# spending by activity groups
# - this won't align with OIA 2016 due to the way results were presented there
# - (by 9 categories & motorized/nonmotorized based on item rather than activity)
spend %>%
    group_by(act, act1) %>%
    summarise(spend = sum(spend)) %>%
    bind_rows(tot) %>%
    knitr::kable(format.args = list(big.mark = ","))
