
# Overview

Code for producing OIA-based spending profiles for use in downstream calculations.

# Usage

Analysis can be reproduced with `source("code/run.R")` and includes two parts:

- Estimating participation profiles (and totals) at the activity group level (act1) using survey data. Profiles at the act1-level weren't estimated as part of OIA 2016.

- Estimating profiles for use in projects using "average activity spending per participant" for trip, equip, and vehicle (by item).

# Data

OIA spending profiles are pulled from the OIA results data: "E:/SA/Data-production/OIA_Rec_Econ_2016/Results/results.RDATA". A data dictionary is stored alongside that file.

# Software Environment

This project was setup using package [saproj](https://github.com/southwick-associates/saproj) with a [Southwick-specific R Setup](https://github.com/southwick-associates/R-setup). Certain files shouldn't be edited by hand:

- .Rprofile             specifies R version and project library
- snapshot-library.csv  details project-specific packages

## Old Packages on Server

These were used for the OIA 2016 analysis; installed here for estimating activity-group level (act1) participation rates.

```r
dir <- "E:/SA/Projects/R-Software/Southwick-packages/_builds_binary"
install.packages(file.path(dir, "tablr2_0.2.zip"), repos = NULL, type = "win.binary")
install.packages(file.path(dir, "gizmoTamer_0.1.7.zip"), repos = NULL, type = "win.binary")
```
