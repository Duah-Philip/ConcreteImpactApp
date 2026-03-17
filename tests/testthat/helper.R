# Shared helper: resolve extdata path for tests
extdata_path <- function(fname) {
  system.file("extdata", fname, package = "ConcreteImpactApp")
}

# Skip a test if all data files are absent
skip_if_no_data <- function() {
  fpath <- extdata_path("Supporting__Information_5_fly_ash_concrete_credited.XLSX")
  testthat::skip_if(!file.exists(fpath), "Bundled extdata files not found")
}
