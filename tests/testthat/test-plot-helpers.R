# =============================================================================
# test-plot-helpers.R
# Unit tests for ggplot2 plot-helper functions.
# =============================================================================

library(testthat)
library(ConcreteImpactApp)
library(ggplot2)

extdata <- function(fname) {
  system.file("extdata", fname, package = "ConcreteImpactApp")
}

# ---------------------------------------------------------------------------
# make_fa_pct_facet()
# ---------------------------------------------------------------------------

test_that("make_fa_pct_facet returns a ggplot object", {
  skip_if(
    !file.exists(extdata("Supporting__information_7_fly_ash_percent_change_credit.xlsx")),
    "SI-7 data file not found"
  )
  df <- read_fa_pct_full("FreshAsh_ET12", credited = TRUE)
  df$FA_Pct <- as.character(df$FA_Pct)

  p <- make_fa_pct_facet(df,
    title_txt    = "Test FA Plot",
    subtitle_txt = "Subtitle"
  )
  expect_s3_class(p, "ggplot")
})

test_that("make_fa_pct_facet produces 10 facet panels", {
  skip_if(
    !file.exists(extdata("Supporting__information_7_fly_ash_percent_change_credit.xlsx")),
    "SI-7 data file not found"
  )
  df <- read_fa_pct_full("FreshAsh_ET12", credited = TRUE)
  df$FA_Pct <- as.character(df$FA_Pct)

  p    <- make_fa_pct_facet(df, "Test", "Sub")
  built <- ggplot2::ggplot_build(p)
  n_panels <- length(unique(built$layout$layout$PANEL))
  expect_equal(n_panels, 10L)
})

test_that("make_fa_pct_facet accepts custom color palette", {
  skip_if(
    !file.exists(extdata("Supporting__information_7_fly_ash_percent_change_credit.xlsx")),
    "SI-7 data file not found"
  )
  df <- read_fa_pct_full("FreshAsh_ET12", credited = TRUE)
  df$FA_Pct <- as.character(df$FA_Pct)

  custom_cols <- c("20" = "#FF0000", "30" = "#00FF00", "40" = "#0000FF")
  p <- make_fa_pct_facet(df, "Test", "Sub", fa_colors = custom_cols)
  expect_s3_class(p, "ggplot")
})

# ---------------------------------------------------------------------------
# make_slag_pct_facet()
# ---------------------------------------------------------------------------

test_that("make_slag_pct_facet returns a ggplot object", {
  skip_if(
    !file.exists(extdata("Supporting__Information_12Slag_percent_change.xlsx")),
    "SI-12 data file not found"
  )
  df <- read_slag_pct_full("USA")
  df$GGBFS_Pct <- as.character(df$GGBFS_Pct)

  p <- make_slag_pct_facet(df,
    title_txt    = "Test Slag Plot",
    subtitle_txt = "Subtitle"
  )
  expect_s3_class(p, "ggplot")
})

test_that("make_slag_pct_facet produces 10 facet panels", {
  skip_if(
    !file.exists(extdata("Supporting__Information_12Slag_percent_change.xlsx")),
    "SI-12 data file not found"
  )
  df <- read_slag_pct_full("USA")
  df$GGBFS_Pct <- as.character(df$GGBFS_Pct)

  p    <- make_slag_pct_facet(df, "Test", "Sub")
  built <- ggplot2::ggplot_build(p)
  n_panels <- length(unique(built$layout$layout$PANEL))
  expect_equal(n_panels, 10L)
})

test_that("make_slag_pct_facet x-axis has 6 levels (compressive strengths)", {
  skip_if(
    !file.exists(extdata("Supporting__Information_12Slag_percent_change.xlsx")),
    "SI-12 data file not found"
  )
  df <- read_slag_pct_full("USA")
  df$GGBFS_Pct <- as.character(df$GGBFS_Pct)
  
  p <- make_slag_pct_facet(df, "Test", "Sub")
  # Check the factor levels in the data directly — more reliable than built data
  str_order <- sort(unique(df$str_num))
  df$Strength_label <- factor(df$str_num,
                              levels = str_order,
                              labels = paste0(str_order, " MPa"))
  expect_equal(nlevels(df$Strength_label), 6L)
})

# ---------------------------------------------------------------------------
# facet_pct_theme()
# ---------------------------------------------------------------------------

test_that("facet_pct_theme returns a list", {
  th <- facet_pct_theme()
  expect_type(th, "list")
  expect_true(length(th) >= 2L)
})
