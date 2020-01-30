# run analysis

# To run each R script, storing knitted html output in log folder
run_script <- function(script_name, script_dir = "1-ngpc-profiles") {
    rmarkdown::render(
        input = file.path("code", script_dir, script_name),
        output_dir = file.path("code", script_dir, "log"),
        knit_root_dir = getwd()
    )
}

# get participation rates for activity groups
# using OIA survey data
source("code/0-act1-participation/0-prep-oia-svy.R")
source("code/0-act1-participation/1-part-rates-act1.R")

# get profiles for use in NGPC
run_script("1-spending.R")
run_script("2-profile.R")
