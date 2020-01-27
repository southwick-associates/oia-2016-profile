# pull profiles together

library(tidyverse)

# Get Data ----------------------------------------------------------------

spend <- readRDS("data-work/spend.rds")
part <- readRDS("data-work/part-rate-act1.rds")

# get national-level participation
part_nat <- part %>%
    group_by(act, act1) %>%
    summarise(part = sum(part)) %>%
    ungroup()

# Spending profiles by item -----------------------------------------------

spend_avg_item <- spend %>%
    left_join(part_nat, by = c("act", "act1")) %>%
    mutate(spend_per_part = spend / part) %>%
    select(act, act1, type, item, spend_per_part)

write_csv(spend_avg_item, "out/spend_avg_item.csv")

# Profiles per participant ------------------------------------------------

# spending for trip, equip, vehicle
spend_avg_type <- spend_avg_item %>%
    group_by(act, act1, type) %>%
    summarize(spend_per_part = round(sum(spend_per_part), 0)) %>%
    spread(type, spend_per_part)

# park allocation uses a single estimate from OIA 2012
spend_avg_type %>%
    mutate(park_trip_pct = 0.523) %>%
    write_csv("out/profiles_per_participant.csv")
