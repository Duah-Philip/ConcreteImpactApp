# =============================================================================
# plot_helpers.R
# ggplot2-based facet plot functions for percent-change visualizations.
# Separated from app logic so they can be unit-tested and reused in the
# vignette independently of Shiny (The Shiny App).
# =============================================================================

# Suppress R CMD check false positives for ggplot2 aes() column names
utils::globalVariables(c("Strength_label", "Pct_Change", "Repl_label"))
# Internal helper: shared ggplot2 theme for percent-change facet plots.
# Returns a list of theme elements matching the manuscript figure style.
facet_pct_theme <- function() {
  list(
    ggplot2::theme_minimal(base_size = 11),
    ggplot2::theme(
      strip.background = ggplot2::element_rect(fill = "gray92", color = "gray75",
                                               linewidth = 0.6),
      strip.text       = ggplot2::element_text(face = "bold", size = 8.5,
                                               margin = ggplot2::margin(4, 4, 4, 4)),
      axis.text.x      = ggplot2::element_text(angle = 45, hjust = 1, vjust = 1,
                                               size = 8),
      axis.text.y      = ggplot2::element_text(size = 8),
      axis.title.x     = ggplot2::element_text(size = 10,
                                               margin = ggplot2::margin(t = 8)),
      axis.title.y     = ggplot2::element_text(size = 10,
                                               margin = ggplot2::margin(r = 8)),
      panel.border     = ggplot2::element_rect(color = "gray60", fill = NA,
                                               linewidth = 0.5),
      panel.spacing    = ggplot2::unit(0.6, "lines"),
      legend.position  = "bottom",
      legend.title     = ggplot2::element_text(size = 9, face = "bold"),
      legend.text      = ggplot2::element_text(size = 8.5),
      legend.key.size  = ggplot2::unit(0.55, "cm"),
      plot.title       = ggplot2::element_text(size = 12, face = "bold",
                                               hjust = 0.5,
                                               margin = ggplot2::margin(b = 8)),
      plot.subtitle    = ggplot2::element_text(size = 9, hjust = 0.5,
                                               color = "gray40",
                                               margin = ggplot2::margin(b = 6)),
      plot.margin      = ggplot2::margin(10, 12, 10, 12)
    )
  )
}


#' Faceted percent-change bar plot for fly ash scenarios
#'
#' Produces a 4-column \code{facet_wrap} plot of LCIA percent changes vs the
#' 0\% cement-replacement baseline, with one panel per TRACI 2.2 impact
#' category. The x-axis shows all six compressive strength classes; dodged
#' bars represent fly ash replacement levels.
#'
#' @param df         Data frame returned by \code{\link{read_fa_pct_full}}.
#'   Must contain columns \code{str_num}, \code{FA_Pct}, \code{Pct_Change},
#'   and \code{Impact_Display}.
#' @param title_txt  Character. Main plot title.
#' @param subtitle_txt Character. Plot subtitle.
#' @param fa_colors Named character vector mapping replacement level (as
#'   character: \code{"20"}, \code{"30"}, \code{"40"}) to hex colour codes.
#'   Defaults to a colorblind-accessible palette.
#'
#' @return A \code{ggplot} object.
#'
#' @examples
#' \dontrun{
#'   df <- read_fa_pct_full("FreshAsh_ET12", credited = TRUE)
#'   df$FA_Pct <- as.character(df$FA_Pct)
#'   p <- make_fa_pct_facet(df,
#'     title_txt    = "% Change vs Baseline — Fresh Ash ET 12%",
#'     subtitle_txt = "With Credit | All Strengths | FA 20%, 30%, 40%"
#'   )
#'   print(p)
#' }
#'
#' @importFrom ggplot2 ggplot aes geom_bar geom_text facet_wrap scale_fill_manual
#'   scale_y_continuous labs expansion labeller
#' @export
make_fa_pct_facet <- function(
    df,
    title_txt,
    subtitle_txt,
    fa_colors = c("20" = "#FECC5C", "30" = "#009B3A", "40" = "#CC79A7")
) {
  # Ordered factor for x-axis (compressive strength)
  str_order <- sort(unique(df$str_num))
  df$Strength_label <- factor(df$str_num,
                              levels = str_order,
                              labels = paste0(str_order, " MPa"))
  df$Repl_label <- factor(as.character(df$FA_Pct), levels = c("20", "30", "40"))

  ggplot2::ggplot(df, ggplot2::aes(
    x    = Strength_label,
    y    = Pct_Change,
    fill = Repl_label
  )) +
    ggplot2::geom_bar(
      stat     = "identity",
      position = ggplot2::position_dodge(width = 0.75),
      width    = 0.7
    ) +
    ggplot2::geom_text(
      ggplot2::aes(label = paste0(round(Pct_Change, 1L), "%")),
      position = ggplot2::position_dodge(width = 0.75),
      angle    = 90,
      hjust    = ifelse(df$Pct_Change >= 0, -0.15, 1.15),
      size     = 2.2,
      color    = "gray20"
    ) +
    ggplot2::facet_wrap(
      ~Impact_Display,
      scales   = "free_y",
      ncol     = 4L,
      labeller = ggplot2::labeller(Impact_Display = function(x) x)
    ) +
    ggplot2::scale_fill_manual(values = fa_colors, name = "Fly Ash (%)") +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0.15, 0.22))
    ) +
    ggplot2::labs(
      title    = title_txt,
      subtitle = subtitle_txt,
      x        = "Compressive Strength (MPa)",
      y        = "Percent Change (%)"
    ) +
    facet_pct_theme() +
    ggplot2::theme(
      strip.background = ggplot2::element_blank(),
      strip.text       = ggplot2::element_text(face = "bold", size = 8.5)
    )
}


#' Faceted percent-change bar plot for slag (GGBFS) scenarios
#'
#' Produces a 4-column \code{facet_wrap} plot of LCIA percent changes vs the
#' 0\% cement-replacement baseline for slag supply-chain scenarios.
#'
#' @param df         Data frame returned by \code{\link{read_slag_pct_full}}.
#'   Must contain columns \code{str_num}, \code{GGBFS_Pct}, \code{Pct_Change},
#'   and \code{Impact_Display}.
#' @param title_txt  Character. Main plot title.
#' @param subtitle_txt Character. Plot subtitle.
#' @param slag_colors Named character vector mapping replacement level (as
#'   character: \code{"30"}, \code{"40"}, \code{"50"}) to hex colour codes.
#'   Defaults to a colorblind-accessible palette.
#'
#' @return A \code{ggplot} object.
#'
#' @examples
#' \dontrun{
#'   df <- read_slag_pct_full("USA")
#'   df$GGBFS_Pct <- as.character(df$GGBFS_Pct)
#'   p <- make_slag_pct_facet(df,
#'     title_txt    = "% Change vs Baseline — Slag GGBFS | Origin: USA",
#'     subtitle_txt = "All Compressive Strengths | GGBFS 30%, 40%, 50%"
#'   )
#'   print(p)
#' }
#'
#' @importFrom ggplot2 ggplot aes geom_bar geom_text facet_wrap scale_fill_manual
#'   scale_y_continuous labs expansion labeller
#' @export
make_slag_pct_facet <- function(
    df,
    title_txt,
    subtitle_txt,
    slag_colors = c("30" = "#E1BE6A", "40" = "#40B0A6", "50" = "#E0B79E")
) {
  str_order <- sort(unique(df$str_num))
  df$Strength_label <- factor(df$str_num,
                              levels = str_order,
                              labels = paste0(str_order, " MPa"))
  df$Repl_label <- factor(as.character(df$GGBFS_Pct), levels = c("30", "40", "50"))

  ggplot2::ggplot(df, ggplot2::aes(
    x    = Strength_label,
    y    = Pct_Change,
    fill = Repl_label
  )) +
    ggplot2::geom_bar(
      stat     = "identity",
      position = ggplot2::position_dodge(width = 0.75),
      width    = 0.7
    ) +
    ggplot2::geom_text(
      ggplot2::aes(label = paste0(round(Pct_Change, 1L), "%")),
      position = ggplot2::position_dodge(width = 0.75),
      angle    = 90,
      hjust    = ifelse(df$Pct_Change >= 0, -0.15, 1.15),
      size     = 2.2,
      color    = "gray20"
    ) +
    ggplot2::facet_wrap(
      ~Impact_Display,
      scales   = "free_y",
      ncol     = 4L,
      labeller = ggplot2::labeller(Impact_Display = function(x) x)
    ) +
    ggplot2::scale_fill_manual(values = slag_colors, name = "Slag GGBFS (%)") +
    ggplot2::scale_y_continuous(
      expand = ggplot2::expansion(mult = c(0.15, 0.22))
    ) +
    ggplot2::labs(
      title    = title_txt,
      subtitle = subtitle_txt,
      x        = "Compressive Strength (MPa)",
      y        = "Percent Change (%)"
    ) +
    facet_pct_theme() +
    ggplot2::theme(
      strip.background = ggplot2::element_blank(),
      strip.text       = ggplot2::element_text(face = "bold", size = 8.5)
    )
}
