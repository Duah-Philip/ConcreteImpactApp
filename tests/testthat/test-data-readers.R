# =============================================================================
# test-data-readers.R
# Unit tests for all data-reader and parser functions.
# Run with: testthat::test_package("ConcreteImpactApp")
#      or:  devtools::test()
# =============================================================================

library(testthat)
library(ConcreteImpactApp)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

extdata <- function(fname) {
  system.file("extdata", fname, package = "ConcreteImpactApp")
}

# ---------------------------------------------------------------------------
# parse_abs_sheet()
# ---------------------------------------------------------------------------

test_that("parse_abs_sheet returns a data frame for a known FA credited sheet", {
  fpath <- extdata("Supporting__Information_5_fly_ash_concrete_credited.XLSX")
  skip_if(!file.exists(fpath), "SI-5 data file not found")

  df <- parse_abs_sheet(fpath, "MIX_FreshAsh_ET12%", "FA_Pct")

  expect_s3_class(df, "data.frame")
  expect_true(nrow(df) > 0L)
  expect_true("Strength_MPa" %in% colnames(df))
  expect_true("FA_Pct"       %in% colnames(df))
  expect_equal(ncol(df), 12L)  # Strength + Repl + 10 impact categories
})

test_that("parse_abs_sheet Strength_MPa column is numeric", {
  fpath <- extdata("Supporting__Information_5_fly_ash_concrete_credited.XLSX")
  skip_if(!file.exists(fpath), "SI-5 data file not found")

  df <- parse_abs_sheet(fpath, "MIX_FreshAsh_ET12%", "FA_Pct")
  expect_true(is.numeric(df$Strength_MPa))
  expect_false(any(is.na(df$Strength_MPa)))
})

test_that("parse_abs_sheet FA_Pct column contains expected replacement fractions", {
  fpath <- extdata("Supporting__Information_5_fly_ash_concrete_credited.XLSX")
  skip_if(!file.exists(fpath), "SI-5 data file not found")

  df <- parse_abs_sheet(fpath, "MIX_FreshAsh_ET12%", "FA_Pct")
  expect_true(all(unique(df$FA_Pct) %in% c(0, 0.2, 0.3, 0.4)))
})

test_that("parse_abs_sheet returns NULL for a non-existent sheet", {
  fpath <- extdata("Supporting__Information_5_fly_ash_concrete_credited.XLSX")
  skip_if(!file.exists(fpath), "SI-5 data file not found")

  expect_null(parse_abs_sheet(fpath, "SHEET_DOES_NOT_EXIST", "FA_Pct"))
})

test_that("parse_abs_sheet returns NULL for a non-existent file", {
  expect_null(parse_abs_sheet("/nonexistent/path/file.xlsx", "Sheet1", "FA_Pct"))
})

test_that("parse_abs_sheet all impact value columns are numeric", {
  fpath <- extdata("Supporting__Information_5_fly_ash_concrete_credited.XLSX")
  skip_if(!file.exists(fpath), "SI-5 data file not found")

  df   <- parse_abs_sheet(fpath, "MIX_FreshAsh_ET12%", "FA_Pct")
  ic_cols <- colnames(df)[3:ncol(df)]
  for (col in ic_cols) {
    expect_true(is.numeric(df[[col]]),
                info = paste("Column", col, "should be numeric"))
  }
})

# ---------------------------------------------------------------------------
# read_fa_lcia()
# ---------------------------------------------------------------------------

test_that("read_fa_lcia returns data for all 16 scenario IDs (credited)", {
  skip_if(
    !file.exists(extdata("Supporting__Information_5_fly_ash_concrete_credited.XLSX")),
    "SI-5 data file not found"
  )
  ids <- sapply(FA_SHEETS, `[[`, "id")
  for (sid in ids) {
    df <- read_fa_lcia(sid, credited = TRUE)
    expect_false(is.null(df),
                 info = paste("read_fa_lcia returned NULL for", sid))
    expect_true(nrow(df) > 0L,
                info = paste("read_fa_lcia returned 0 rows for", sid))
  }
})

test_that("read_fa_lcia returns data for all 16 scenario IDs (not credited)", {
  skip_if(
    !file.exists(extdata("Supporting_Information_6_fly_ash_concrete_no_credit.XLSX")),
    "SI-6 data file not found"
  )
  ids <- sapply(FA_SHEETS, `[[`, "id")
  for (sid in ids) {
    df <- read_fa_lcia(sid, credited = FALSE)
    expect_false(is.null(df),
                 info = paste("read_fa_lcia(credited=FALSE) returned NULL for", sid))
  }
})

test_that("read_fa_lcia returns NULL for unknown sheet_id", {
  expect_null(read_fa_lcia("UNKNOWN_ID"))
})

test_that("read_fa_lcia covers all 6 compressive strengths", {
  skip_if(
    !file.exists(extdata("Supporting__Information_5_fly_ash_concrete_credited.XLSX")),
    "SI-5 data file not found"
  )
  df <- read_fa_lcia("FreshAsh_ET12", credited = TRUE)
  expect_equal(length(unique(df$Strength_MPa)), 6L)
})

test_that("read_fa_lcia Global warming values are positive", {
  skip_if(
    !file.exists(extdata("Supporting__Information_5_fly_ash_concrete_credited.XLSX")),
    "SI-5 data file not found"
  )
  df <- read_fa_lcia("FreshAsh_ET12", credited = TRUE)
  expect_true(all(df[["Global warming"]] > 0),
              info = "Global warming impact values should be positive")
})

# ---------------------------------------------------------------------------
# read_slag_lcia()
# ---------------------------------------------------------------------------

test_that("read_slag_lcia returns data for all four countries", {
  skip_if(
    !file.exists(extdata("Supporting__Information_11Slag_concrete_all_countries.xlsx")),
    "SI-11 data file not found"
  )
  for (ctry in c("USA", "BRAZIL", "CHINA", "JAPAN")) {
    df <- read_slag_lcia(ctry)
    expect_false(is.null(df),   info = paste("NULL for country", ctry))
    expect_true(nrow(df) > 0L,  info = paste("0 rows for country", ctry))
  }
})

test_that("read_slag_lcia GGBFS_Pct contains 0, 0.3, 0.4, 0.5", {
  skip_if(
    !file.exists(extdata("Supporting__Information_11Slag_concrete_all_countries.xlsx")),
    "SI-11 data file not found"
  )
  df <- read_slag_lcia("USA")
  expect_true(all(unique(df$GGBFS_Pct) %in% c(0, 0.3, 0.4, 0.5)))
})

test_that("read_slag_lcia covers all 6 compressive strengths", {
  skip_if(
    !file.exists(extdata("Supporting__Information_11Slag_concrete_all_countries.xlsx")),
    "SI-11 data file not found"
  )
  df <- read_slag_lcia("USA")
  expect_equal(length(unique(df$Strength_MPa)), 6L)
})

# ---------------------------------------------------------------------------
# parse_pct_sheet()
# ---------------------------------------------------------------------------

test_that("parse_pct_sheet returns required columns", {
  fpath <- extdata("Supporting__information_7_fly_ash_percent_change_credit.xlsx")
  skip_if(!file.exists(fpath), "SI-7 data file not found")

  df <- parse_pct_sheet(fpath, "MIX_FreshAsh_ET12%", "FA_Pct")

  required <- c("Strength_MPa", "FA_Pct", "Impact_Category",
                "Value", "Baseline", "Pct_Change",
                "str_num", "Impact_Display")
  for (col in required) {
    expect_true(col %in% colnames(df),
                info = paste("Missing column:", col))
  }
})

test_that("parse_pct_sheet Pct_Change is numeric with no NAs", {
  fpath <- extdata("Supporting__information_7_fly_ash_percent_change_credit.xlsx")
  skip_if(!file.exists(fpath), "SI-7 data file not found")

  df <- parse_pct_sheet(fpath, "MIX_FreshAsh_ET12%", "FA_Pct")
  expect_true(is.numeric(df$Pct_Change))
  expect_false(any(is.na(df$Pct_Change)))
})

test_that("parse_pct_sheet Impact_Display is non-empty for all rows", {
  fpath <- extdata("Supporting__information_7_fly_ash_percent_change_credit.xlsx")
  skip_if(!file.exists(fpath), "SI-7 data file not found")

  df <- parse_pct_sheet(fpath, "MIX_FreshAsh_ET12%", "FA_Pct")
  expect_false(any(is.na(df$Impact_Display)))
  expect_false(any(df$Impact_Display == ""))
})

# ---------------------------------------------------------------------------
# read_fa_pct_full()
# ---------------------------------------------------------------------------

test_that("read_fa_pct_full returns 180 rows (6 strengths x 3 replacements x 10 categories)", {
  skip_if(
    !file.exists(extdata("Supporting__information_7_fly_ash_percent_change_credit.xlsx")),
    "SI-7 data file not found"
  )
  df <- read_fa_pct_full("FreshAsh_ET12", credited = TRUE)
  expect_equal(nrow(df), 180L)
})

test_that("read_fa_pct_full FA_Pct values are 20, 30, 40 (as integers)", {
  skip_if(
    !file.exists(extdata("Supporting__information_7_fly_ash_percent_change_credit.xlsx")),
    "SI-7 data file not found"
  )
  df <- read_fa_pct_full("FreshAsh_ET12", credited = TRUE)
  expect_true(all(unique(df$FA_Pct) %in% c(20, 30, 40)))
})

test_that("read_fa_pct_full credited vs non-credited give different Pct_Change values", {
  skip_if(
    !file.exists(extdata("Supporting__information_7_fly_ash_percent_change_credit.xlsx")) ||
    !file.exists(extdata("Supporting__Information_8fly_ash_percent_change_no_credit.xlsx")),
    "SI-7 or SI-8 data file not found"
  )
  df_cr  <- read_fa_pct_full("FreshAsh_ET12", credited = TRUE)
  df_ncr <- read_fa_pct_full("FreshAsh_ET12", credited = FALSE)
  # They should differ on at least some rows
  expect_false(all(df_cr$Pct_Change == df_ncr$Pct_Change))
})

# ---------------------------------------------------------------------------
# read_slag_pct_full()
# ---------------------------------------------------------------------------

test_that("read_slag_pct_full returns data for all four countries", {
  skip_if(
    !file.exists(extdata("Supporting__Information_12Slag_percent_change.xlsx")),
    "SI-12 data file not found"
  )
  for (ctry in c("USA", "BRAZIL", "CHINA", "JAPAN")) {
    df <- read_slag_pct_full(ctry)
    expect_false(is.null(df),  info = paste("NULL for", ctry))
    expect_true(nrow(df) > 0L, info = paste("0 rows for", ctry))
  }
})

test_that("read_slag_pct_full returns 180 rows for USA (6x3x10)", {
  skip_if(
    !file.exists(extdata("Supporting__Information_12Slag_percent_change.xlsx")),
    "SI-12 data file not found"
  )
  df <- read_slag_pct_full("USA")
  expect_equal(nrow(df), 180L)
})

test_that("read_slag_pct_full GGBFS_Pct values are 30, 40, 50", {
  skip_if(
    !file.exists(extdata("Supporting__Information_12Slag_percent_change.xlsx")),
    "SI-12 data file not found"
  )
  df <- read_slag_pct_full("USA")
  expect_true(all(unique(df$GGBFS_Pct) %in% c(30, 40, 50)))
})

# ---------------------------------------------------------------------------
# Mix design data integrity
# ---------------------------------------------------------------------------

test_that("FA_MIX has 24 rows and 13 columns", {
  expect_equal(nrow(FA_MIX), 24L)
  expect_equal(ncol(FA_MIX), 13L)
})

test_that("FA_MIX covers 6 compressive strengths", {
  expect_equal(length(unique(FA_MIX$strength)), 6L)
})

test_that("FA_MIX replacement levels are 0, 20, 30, 40", {
  expect_equal(sort(unique(FA_MIX$pct_fa)), c(0L, 20L, 30L, 40L))
})

test_that("FA_MIX cement + fly_ash decreases with increasing fly_ash replacement", {
  # For each strength, total binder should roughly track replacement logic
  for (s in unique(FA_MIX$strength)) {
    sub <- FA_MIX[FA_MIX$strength == s, ]
    sub <- sub[order(sub$pct_fa), ]
    # Fly ash should be non-decreasing
    expect_true(all(diff(sub$fly_ash) >= 0),
                info = paste("fly_ash not monotone at strength", s))
    # Cement should be non-increasing
    expect_true(all(diff(sub$cement) <= 0),
                info = paste("cement not monotone at strength", s))
  }
})

test_that("SLAG_MIX has 24 rows and 13 columns", {
  expect_equal(nrow(SLAG_MIX), 24L)
  expect_equal(ncol(SLAG_MIX), 13L)
})

test_that("SLAG_MIX replacement levels are 0, 30, 40, 50", {
  expect_equal(sort(unique(SLAG_MIX$pct_slag)), c(0L, 30L, 40L, 50L))
})

# ---------------------------------------------------------------------------
# Impact label mapping completeness
# ---------------------------------------------------------------------------

test_that("IMPACT_SHORT_TO_LONG has 10 entries", {
  expect_equal(length(IMPACT_SHORT_TO_LONG), 10L)
})

test_that("IMPACT_DISPLAY has 10 entries", {
  expect_equal(length(IMPACT_DISPLAY), 10L)
})

test_that("All IMPACT_SHORT_TO_LONG values appear in IMPACT_DISPLAY keys", {
  expect_true(all(IMPACT_SHORT_TO_LONG %in% names(IMPACT_DISPLAY)))
})

test_that("FA_SHEETS contains 16 scenarios", {
  expect_equal(length(FA_SHEETS), 16L)
})

test_that("FA_SHEET_MAP and FA_PCT_SHEET_MAP both have 16 entries", {
  expect_equal(length(FA_SHEET_MAP),     16L)
  expect_equal(length(FA_PCT_SHEET_MAP), 16L)
})

test_that("All FA_SHEETS ids appear in FA_SHEET_MAP", {
  ids <- sapply(FA_SHEETS, `[[`, "id")
  expect_true(all(ids %in% names(FA_SHEET_MAP)))
})
