# ConcreteImpactApp <img src="man/figures/logo.png" align="right" height="80"/>

<!-- badges: start -->
[![R-CMD-check](https://github.com/Duah-Philip/ConcreteImpactApp/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Duah-Philip/ConcreteImpactApp/actions)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![DOI](https://img.shields.io/badge/DOI-10.XXXX%2FXXXXXX-blue.svg)](https://doi.org/10.XXXX/XXXXXX)
<!-- badges: end -->

## Overview

**ConcreteImpactApp** is an R package providing an interactive Shiny dashboard
 for evaluating the cradle-to-gate life cycle
environmental impacts of U.S. ready-mix concrete produced with supplementary
cementitious materials (SCMs):

- **Fly Ash (FA)** — 16 scenarios across 3 treatment technologies
  (Thermal, Electrostatic, Chemical), 3 source types (Fresh Ash, Landfill,
  Impoundment), and 2 dose/LOI levels; with and without avoided-impact credit
- **Slag / GGBFS** — 4 supply-chain origins (USA, Brazil, China, Japan)

All results implement the **TRACI 2.2** impact assessment methodology across
10 environmental impact categories for 6 compressive strength classes
(17.2–55.2 MPa).

Developed by the **Mine Sustainability Modeling Research Group**,
Missouri University of Science and Technology.

---

## Installation

### From the manuscript supplemental file (recommended)

```r
# Step 1 — Install dependencies
install.packages(
  c("shiny", "shinydashboard", "readxl", "DT",
    "plotly", "ggplot2", "dplyr", "scales"),
  repos = "https://cloud.r-project.org"
)

# Step 2 — Install the package
install.packages(
  "ConcreteImpactApp_1.0.0.tar.gz",
  repos = NULL,
  type  = "source"
)
```

### From GitHub (development version)

```r
# install.packages("remotes")
remotes::install_github("Duah-Philip/ConcreteImpactApp")
```

---

## Quick Start

```r
library(ConcreteImpactApp)

# Launch the interactive dashboard
run_app()
```

The dashboard opens automatically in your default browser. No internet
connection is required — all LCIA data are bundled within the package.

---

## 

The underlying data readers and plot functions are fully exported and
documented, enabling reproducible scripted analyses:

```r
library(ConcreteImpactApp)

# --- Fly Ash ---
# Absolute LCIA values (SI-5: with credit)
df <- read_fa_lcia("FreshAsh_ET12", credited = TRUE)

# Percent-change data — all strengths & replacements (SI-7)
df_pct <- read_fa_pct_full("FreshAsh_ET12", credited = TRUE)

# Facet plot
df_pct$FA_Pct <- as.character(df_pct$FA_Pct)
make_fa_pct_facet(df_pct,
  title_txt    = "% Change — Fresh Ash ET 12% (with credit)",
  subtitle_txt = "All Strengths | FA 20%, 30%, 40%"
)

# --- Slag (GGBFS) ---
df_slag     <- read_slag_lcia("USA")
df_slag_pct <- read_slag_pct_full("USA")

df_slag_pct$GGBFS_Pct <- as.character(df_slag_pct$GGBFS_Pct)
make_slag_pct_facet(df_slag_pct,
  title_txt    = "% Change — Slag GGBFS | USA",
  subtitle_txt = "All Strengths | GGBFS 30%, 40%, 50%"
)
```

---

## Package Structure

```
ConcreteImpactApp/
|─ ─ DESCRIPTION              # Package metadata (authors, dependencies, version)
|─ ─ NAMESPACE                # Exported symbols
|─ ─ LICENSE                  # Apache License 2.0
|─ ─LICENSE.md               # Full Apache 2.0 legal text
|─ ─ NEWS.md                  # Version changelog
|─ ─README.md                # This file (what you are reading now)
|─ ─R/
│   |─ ─ constants.R          # Impact label maps, FA_SHEETS, mix design data
│   |─ ─ data_readers.R       # Exported, documented data-reading functions
│   |─ ─ plot_helpers.R       # Exported ggplot2 facet plot functions
│       |- run_app.R            # Exported run_app() launcher
|─ ─inst/
│   |─ ─ app/
│   │    |─ ─ app.R            # Shiny application (UI + server)
│   ├── extdata/             # Bundled LCIA source data (XLSX)
│   │   |─ ─ Supporting__Information_5_fly_ash_concrete_credited.XLSX
│   │   |─ ─ Supporting_Information_6_fly_ash_concrete_no_credit.XLSX
│   │   |─ ─ Supporting__information_7_fly_ash_percent_change_credit.xlsx
│   │   |─ ─ Supporting__Information_8fly_ash_percent_change_no_credit.xlsx
│   │   |─ ─ Supporting__Information_11Slag_concrete_all_countries.xlsx
│   │   |─ ─ Supporting__Information_12Slag_percent_change.xlsx
│   |─ ── CITATION             # How to cite this package
|─ ─ man/                     # Auto-generated Roxygen2 documentation
|─ ─ tests/
│   |─ ─ testthat/
│      |─ ─ helper.R
│      |─ ─ test-data-readers.R   # 35 unit tests for data functions
│       ── test-plot-helpers.R   # 7 unit tests for plot functions
|─ ─vignettes/
   |─ ─ ConcreteImpactApp.Rmd     # Reproducibility vignette
```

---

## Running Tests

```r
# Run the full test suite
devtools::test()

# Or with testthat directly
testthat::test_package("ConcreteImpactApp")
```

Expected: **42 tests**, all passing.

---

## Citing This Work

```r
citation("ConcreteImpactApp")
```


## License

Copyright 2025 Mine Sustainability Modeling Research Group,
Missouri University of Science and Technology.

Licensed under the Apache License, Version 2.0. You may not use this
package except in compliance with the License. You may obtain a copy at:

http://www.apache.org/licenses/LICENSE-2.0

See [LICENSE.md](LICENSE.md) for the full license text.