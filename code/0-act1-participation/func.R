# functions

# Prepare activity groups -------------------------------------------------

# need to create variables for the act1 question level
# - these functions aren't pretty but not feeling like rewriting

# define a function that aggregates multiple questions into one
# - acts = data frame of metadata for activities of interest
# - outvar = name of aggregated output variable 
# - refvar = string that identifies variables to include
get_check_act1 <- function(svy, acts, outvar, refvar = "mon.mtr.all") {
    get_check <- function(x, outvar, test_func = function(x) any(x == "Checked")) {
        cols <- setdiff(names(x), "sid")
        check <- select_(x, .dots = cols) %>% apply(1, test_func)
        x[[outvar]] <- check
        x <- select_(x, .dots = c("sid", outvar))
    }
    nums <- acts[acts$act1 == outvar, ]$act2_num
    vars <- paste(refvar, nums, sep = "_")
    select_(svy, .dots = c("sid", vars)) %>% get_check(outvar)
}

# apply get_check_act1 for all activities of a type (motorized or non-motorized)
get_check_grp <- function(svy, refvar, grp) {
    acts <- filter(act_meta, act == grp, !(act1 %in% c("all", "other")))
    act_grps <- unique(acts$act1)
    
    for (i in seq_along(act_grps)) {
        x <- get_check_act1(svy, acts, act_grps[i], refvar)
        if (i == 1) {
            out <- x
        } else {
            out <- full_join(out, x, by = "sid")
        }
    }
    out
}

# Estimation Functions ------------------------------------------------------
# redifining function(s) from tablr2/gizmoTamer that no longer work

# response frequency
gFreq <- function(df, wt, ...) {
    wt <- enquo(wt)
    grp_vars <- enquos(...)
    
    df %>%
        group_by(!!! grp_vars) %>%
        summarise(n = sum(!! wt)) %>%
        mutate(pct = n / sum(n)) %>%
        ungroup()
}
