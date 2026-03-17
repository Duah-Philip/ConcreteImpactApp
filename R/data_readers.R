# =============================================================================
# data_readers.R
# Exported functions for reading and parsing the LCIA source Excel files.
# All the functions are independently testable and return tidy data frames.
# =============================================================================

#' Parse an absolute-value LCIA sheet
#'
#' Locates the data table within a worksheet by finding the
#' "Concrete Compressive Strength" header row, fills down the strength
#' column, and returns a tidy numeric data frame.
#'
#' @param fpath   Character. Full path to the Excel workbook.
#' @param sheet_name Character. Name of the worksheet to read.
#' @param repl_col_name Character. Column name to assign to the SCM replacement
#'   fraction column (e.g., \code{"FA_Pct"} or \code{"GGBFS_Pct"}).
#'
#' @return A data frame with columns \code{Strength_MPa} (numeric),
#'   \code{<repl_col_name>} (numeric, as a fraction 0–1), and one numeric
#'   column per impact category (10 total) named with their short labels.
#'   Returns \code{NULL} if the file or sheet cannot be read.
#'
#' @examples
#' \dontrun{
#'   fpath <- system.file("extdata",
#'     "Supporting__Information_5_fly_ash_concrete_credited.XLSX",
#'     package = "ConcreteImpactApp")
#'   df <- parse_abs_sheet(fpath, "MIX_FreshAsh_ET12%", "FA_Pct")
#'   head(df)
#' }
#'
#' @importFrom readxl read_excel
#' @export
parse_abs_sheet <- function(fpath, sheet_name, repl_col_name = "Repl_Pct") {
  df <- tryCatch(
    suppressMessages(readxl::read_excel(fpath, sheet = sheet_name, col_names = FALSE)),
    error = function(e) {
      message("parse_abs_sheet: could not read '", sheet_name, "' from '", fpath, "': ", e$message)
      NULL
    }
  )
  if (is.null(df)) return(NULL)

  # Locate the header row containing "Concrete Compressive Strength"
  hrow <- NA_integer_
  for (i in seq_len(nrow(df))) {
    if (any(grepl("Concrete Compressive Strength", unlist(df[i, ]), ignore.case = TRUE))) {
      hrow <- i
      break
    }
  }
  if (is.na(hrow)) {
    message("parse_abs_sheet: header row not found in sheet '", sheet_name, "'")
    return(NULL)
  }

  # Row immediately above the header contains the short impact names
  imp_names   <- as.character(unlist(df[hrow - 1L, ]))
  short_names <- imp_names[3:12]

  # Extract data rows; drop fully-empty rows
  dat <- as.data.frame(df[(hrow + 1L):nrow(df), ], stringsAsFactors = FALSE)
  dat <- dat[rowSums(!is.na(dat)) > 0L, ]

  # Fill-down the compressive strength label column
  scol <- as.character(dat[[1]])
  for (i in seq_along(scol)) {
    if (i > 1L && (is.na(scol[i]) || scol[i] %in% c("NA", "")))
      scol[i] <- scol[i - 1L]
  }
  # Parse numeric strength: "17.2 Mpa Concrete Mix Design" -> 17.2
  dat[[1]] <- as.numeric(sub("^([0-9.]+).*$", "\\1", trimws(scol)))
  dat[[2]] <- as.numeric(dat[[2]])
  for (j in 3:min(12L, ncol(dat))) dat[[j]] <- as.numeric(dat[[j]])

  colnames(dat)[1L] <- "Strength_MPa"
  colnames(dat)[2L] <- repl_col_name
  if (ncol(dat) >= 12L) colnames(dat)[3:12] <- short_names

  dat[!is.na(dat[[1L]]), ]
}


#' Read fly ash absolute LCIA values
#'
#' Reads one scenario sheet from either the credited or
#' non-credited fly ash LCIA workbook.
#'
#' @param sheet_id Character. Internal scenario identifier from
#'   \code{FA_SHEETS} (e.g., \code{"FreshAsh_ET12"}).
#' @param credited Logical. If \code{TRUE} (default), reads from SI-5
#'   (with avoided-impact credit); if \code{FALSE}, reads from SI-6.
#'
#' @return A tidy data frame as returned by \code{\link{parse_abs_sheet}},
#'   with the replacement column named \code{"FA_Pct"}, or \code{NULL} on
#'   failure.
#'
#' @examples
#' \dontrun{
#'   df <- read_fa_lcia("FreshAsh_ET12", credited = TRUE)
#'   df[df$FA_Pct == 0.2, c("Strength_MPa", "FA_Pct", "Global warming")]
#' }
#'
#' @export
read_fa_lcia <- function(sheet_id, credited = TRUE) {
  fname <- if (credited)
    "Supporting__Information_5_fly_ash_concrete_credited.XLSX"
  else
    "Supporting_Information_6_fly_ash_concrete_no_credit.XLSX"
  sname <- FA_SHEET_MAP[sheet_id]
  if (is.na(sname)) {
    message("read_fa_lcia: unknown sheet_id '", sheet_id, "'")
    return(NULL)
  }
  parse_abs_sheet(                           # <- this was missing
    fpath         = file.path(.data_dir(), fname),
    sheet_name    = sname,
    repl_col_name = "FA_Pct"
  )
}  


#' Read slag (GGBFS) absolute LCIA values 
#'
#' Reads the LCIA data for a specified supply-chain country from the slag
#' absolute-value workbook.
#'
#' @param country Character. One of \code{"USA"}, \code{"BRAZIL"},
#'   \code{"CHINA"}, or \code{"JAPAN"}.
#'
#' @return A tidy data frame as returned by \code{\link{parse_abs_sheet}},
#'   with the replacement column named \code{"GGBFS_Pct"}, or \code{NULL}
#'   on failure.
#'
#' @examples
#' \dontrun{
#'   df <- read_slag_lcia("USA")
#'   head(df)
#' }
#'
#' @export
read_slag_lcia <- function(country = "USA") {
  parse_abs_sheet(
    fpath         = file.path(.data_dir(),
                              "Supporting__Information_11Slag_concrete_all_countries.xlsx"),
    sheet_name    = country,
    repl_col_name = "GGBFS_Pct"
  )
}


#' Parse a percent-change LCIA sheet
#'
#' Reads a tidy long-format percent-change worksheet and attaches display
#' labels to each impact category.
#'
#' @param fpath       Character. Full path to the Excel workbook.
#' @param sheet_name  Character. Name of the worksheet to read.
#' @param repl_col    Character. Column name for the SCM replacement level
#'   (e.g., \code{"FA_Pct"} or \code{"GGBFS_Pct"}).
#'
#' @return A data frame with columns: \code{Strength_MPa}, \code{str_num}
#'   (numeric strength), \code{<repl_col>} (numeric fraction),
#'   \code{Impact_Category}, \code{Value}, \code{Baseline},
#'   \code{Pct_Change}, and \code{Impact_Display}. Returns \code{NULL} on
#'   failure.
#'
#' @examples
#' \dontrun{
#'   fpath <- system.file("extdata",
#'     "Supporting__information_7_fly_ash_percent_change_credit.xlsx",
#'     package = "ConcreteImpactApp")
#'   df <- parse_pct_sheet(fpath, "MIX_FreshAsh_ET12%", "FA_Pct")
#'   head(df)
#' }
#'
#' @importFrom readxl read_excel
#' @export
parse_pct_sheet <- function(fpath, sheet_name, repl_col = "Repl_Pct") {
  df <- tryCatch(
    suppressMessages(readxl::read_excel(fpath, sheet = sheet_name, col_names = TRUE)),
    error = function(e) {
      message("parse_pct_sheet: could not read '", sheet_name, "' from '", fpath, "': ", e$message)
      NULL
    }
  )
  if (is.null(df) || nrow(df) == 0L) return(NULL)

  colnames(df) <- c("Strength_MPa", repl_col, "Impact_Category",
                    "Value", "Baseline", "Pct_Change")
  df$Strength_MPa  <- trimws(as.character(df$Strength_MPa))
  df$str_num       <- as.numeric(sub("^([0-9.]+).*$", "\\1", df$Strength_MPa))
  df[[repl_col]]   <- as.numeric(df[[repl_col]])
  df$Value         <- as.numeric(df$Value)
  df$Baseline      <- as.numeric(df$Baseline)
  df$Pct_Change    <- as.numeric(df$Pct_Change)

  # Attach formatted display labels
  df$Impact_Display <- IMPACT_DISPLAY[df$Impact_Category]
  df$Impact_Display[is.na(df$Impact_Display)] <-
    df$Impact_Category[is.na(df$Impact_Display)]

  df[!is.na(df$str_num) & !is.na(df[[repl_col]]), ]
}


#' Read fly ash percent-change data for all strengths and replacements
#'
#' Returns the complete percent-change dataset for a given fly ash scenario —
#' all six compressive strengths and all three replacement levels — suitable
#' for the faceted plot.
#'
#' @param sheet_id Character. Internal scenario identifier (see \code{FA_SHEETS}).
#' @param credited Logical. If \code{TRUE} (default), reads SI-7 (with credit);
#'   if \code{FALSE}, reads SI-8 (without credit).
#'
#' @return A long-format data frame as returned by \code{\link{parse_pct_sheet}},
#'   or \code{NULL} on failure.
#'
#' @examples
#' \dontrun{
#'   df <- read_fa_pct_full("FreshAsh_ET12", credited = TRUE)
#'   table(df$FA_Pct, df$str_num)
#' }
#'
#' @export
read_fa_pct_full <- function(sheet_id, credited = TRUE) {
  fname <- if (credited)
    "Supporting__information_7_fly_ash_percent_change_credit.xlsx"
  else
    "Supporting__Information_8fly_ash_percent_change_no_credit.xlsx"
  sname <- FA_PCT_SHEET_MAP[sheet_id]
  if (is.na(sname)) {
    message("read_fa_pct_full: unknown sheet_id '", sheet_id, "'")
    return(NULL)
  }
  parse_pct_sheet(                           # <- this was missing
    fpath      = file.path(.data_dir(), fname),
    sheet_name = sname,
    repl_col   = "FA_Pct"
  )
}      


#' Read slag percent-change data for all strengths and replacements
#'
#' Returns the complete percent-change dataset for a given slag supply-chain
#' origin — all six compressive strengths and all three replacement levels —
#' suitable for the faceted plot.
#'
#' @param country Character. One of \code{"USA"}, \code{"BRAZIL"},
#'   \code{"CHINA"}, or \code{"JAPAN"}.
#'
#' @return A long-format data frame as returned by \code{\link{parse_pct_sheet}},
#'   or \code{NULL} on failure.
#'
#' @examples
#' \dontrun{
#'   df <- read_slag_pct_full("USA")
#'   unique(df$GGBFS_Pct)
#' }
#'
#' @export
read_slag_pct_full <- function(country = "USA") {
  smap <- c("USA"   = "USA MIX",
            "JAPAN" = "JAPAN MIX",
            "CHINA" = "CHINA MIX",
            "BRAZIL"= "BRAZIL MIX")
  parse_pct_sheet(
    fpath      = file.path(.data_dir(),
                           "Supporting__Information_12Slag_percent_change.xlsx"),
    sheet_name = smap[[country]],
    repl_col   = "GGBFS_Pct"
  )
}


# Internal helper: resolve extdata directory at runtime.
# Not exported — called only by read_fa_lcia, read_slag_lcia, etc.
.data_dir <- function() {
  d <- system.file("extdata", package = "ConcreteImpactApp")
  if (d == "") d <- file.path(getwd(), "inst", "extdata")
  d
}
