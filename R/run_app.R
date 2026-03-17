# =============================================================================
# run_app.R
# The launcher function. This is the function accessible to users of the App.
# =============================================================================

#' Launch the Concrete LCA Shiny Dashboard
#'
#' Opens the interactive life cycle assessment dashboard for U.S. ready-mix
#' concrete with fly ash and GGBFS slag as supplementary cementitious
#' materials. The app is self-contained: all reference data are bundled in
#' the package \code{inst/extdata} directory.
#'
#' @param port Integer. TCP port for the Shiny server (default: \code{3838}).
#'   Set to \code{0} for a random available port.
#' @param host Character. Binding address (default: \code{"127.0.0.1"} for
#'   local use). Set to \code{"0.0.0.0"} to allow network access.
#' @param launch.browser Logical. Whether to open the system default browser
#'   automatically (default: \code{TRUE}).
#'
#' @return Invisibly returns the Shiny app object; called primarily for its
#'   side effect of launching the browser interface.
#'
#' @examples
#' \dontrun{
#'   # Launch on the default port in the system browser
#'   run_app()
#'
#'   # Launch on a specific port without opening a browser
#'   run_app(port = 4242, launch.browser = FALSE)
#' }
#'
#' @importFrom shiny runApp
#' @export
run_app <- function(port           = 3838L,
                    host           = "127.0.0.1",
                    launch.browser = TRUE) {
  app_dir <- system.file("app", package = "ConcreteImpactApp")
  if (!nzchar(app_dir)) {
    # Development fallback: run from the package root
    app_dir <- file.path(getwd(), "inst", "app")
  }
  shiny::runApp(
    appDir         = app_dir,
    port           = port,
    host           = host,
    launch.browser = launch.browser
  )
}
