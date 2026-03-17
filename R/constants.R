# =============================================================================
# constants.R
# These are Global lookup tables, sheet maps, and mix design reference data.
# These objects are created once at package load and shared by all functions in the package.
# =============================================================================

# -----------------------------------------------------------------------------
# Impact category label mappings
# SHORT  = column headers as they appear in absolute-value XLSX sheets 
# LONG   = full category strings as they appear in percent-change sheets
# DISPLAY = formatted multi-line labels for plot axes and facet strips
# --------------------------------------------------------------------------------

#' @keywords internal
IMPACT_SHORT_TO_LONG <- c(
  "Ozone depletion"           = "Ozone depletion (kg CFC-11 eq)",
  "Global warming"            = "Global warming (kg CO2 eq)",
  "Smog"                      = "Smog ( kg O3 eq)",
  "Acidification"             = "Acidification (kg SO2 eq)",
  "Carcinogenics"             = "Carcinogenics (CTUh)",
  "Non carcinogenics"         = "Non carcinogenics (CTUh)",
  "Respiratory effects"       = "Respiratory effects (kg PM2.5 eq)",
  "Ecotoxicity"               = "Ecotoxicity (CTUe)",
  "Freshwater eutrophication" = "Freshwater eutrophication (kg P eq)",
  "Marine eutrophication"     = "Marine eutrophication (kg N eq)"
)

#' @keywords internal
IMPACT_DISPLAY <- c(
  "Ozone depletion (kg CFC-11 eq)"      = "Ozone Depletion\n(kg CFC-11 eq)",
  "Global warming (kg CO2 eq)"          = "Global Warming\n(kg CO2 eq)",
  "Smog ( kg O3 eq)"                    = "Smog\n(kg O3 eq)",
  "Acidification (kg SO2 eq)"           = "Acidification\n(kg SO2 eq)",
  "Carcinogenics (CTUh)"                = "Carcinogenics\n(CTUh)",
  "Non carcinogenics (CTUh)"            = "Non-Carcinogenics\n(CTUh)",
  "Respiratory effects (kg PM2.5 eq)"   = "Respiratory Effects\n(kg PM2.5 eq)",
  "Ecotoxicity (CTUe)"                  = "Ecotoxicity\n(CTUe)",
  "Freshwater eutrophication (kg P eq)" = "Freshwater\neutrophication\n(kg P eq)",
  "Marine eutrophication (kg N eq)"     = "Marine\neutrophication\n(kg N eq)"
)

#' @keywords internal
IMPACT_SHORT_DISPLAY <- c(
  "Ozone depletion"           = "Ozone Depletion\n(kg CFC-11 eq)",
  "Global warming"            = "Global Warming\n(kg CO2 eq)",
  "Smog"                      = "Smog\n(kg O3 eq)",
  "Acidification"             = "Acidification\n(kg SO2 eq)",
  "Carcinogenics"             = "Carcinogenics\n(CTUh)",
  "Non carcinogenics"         = "Non-Carcinogenics\n(CTUh)",
  "Respiratory effects"       = "Respiratory Effects\n(kg PM2.5 eq)",
  "Ecotoxicity"               = "Ecotoxicity\n(CTUe)",
  "Freshwater eutrophication" = "Freshwater\neutrophication\n(kg P eq)",
  "Marine eutrophication"     = "Marine\neutrophication\n(kg N eq)"
)

#' @keywords internal
IMPACT_SHORT_LABEL <- c(
  "Ozone depletion"           = "Ozone Depletion",
  "Global warming"            = "Global Warming",
  "Smog"                      = "Smog",
  "Acidification"             = "Acidification",
  "Non carcinogenics"         = "Non-Carcinogenics",
  "Carcinogenics"             = "Carcinogenics",
  "Respiratory effects"       = "Respiratory Effects",
  "Ecotoxicity"               = "Ecotoxicity",
  "Freshwater eutrophication" = "Freshwater Eutroph.",
  "Marine eutrophication"     = "Marine Eutroph."
)

# -----------------------------------------------------------------------------
# Fly ash scenario metadata: id, display label, technology, source, dose (non-ionic surfactant)
# -----------------------------------------------------------------------------

#' @keywords internal
FA_SHEETS <- list(
  list(id="FreshAsh_ET12",    label="Fresh Ash - Electrostatic (ET) 12%",         tech="ET",   source="Fresh Ash",   dose="12%"),
  list(id="FreshAsh_ET6",     label="Fresh Ash - Electrostatic (ET) 6%",           tech="ET",   source="Fresh Ash",   dose="6%"),
  list(id="FreshAsh_CHEM_MAX",label="Fresh Ash - Chemical (CHEM) Max Dose",        tech="CHEM", source="Fresh Ash",   dose="Max"),
  list(id="FreshAsh_CHEM_TYP",label="Fresh Ash - Chemical (CHEM) Typical Dose",    tech="CHEM", source="Fresh Ash",   dose="Typical"),
  list(id="LFILL_TT12",       label="Landfill - Thermal (TT) 12%",                 tech="TT",   source="Landfill",    dose="12%"),
  list(id="LFILL_TT6",        label="Landfill - Thermal (TT) 6%",                  tech="TT",   source="Landfill",    dose="6%"),
  list(id="LFILL_ET12",       label="Landfill - Electrostatic (ET) 12%",            tech="ET",   source="Landfill",    dose="12%"),
  list(id="LFILL_ET6",        label="Landfill - Electrostatic (ET) 6%",             tech="ET",   source="Landfill",    dose="6%"),
  list(id="IMPMNT_TT12",      label="Impoundment - Thermal (TT) 12%",               tech="TT",   source="Impoundment", dose="12%"),
  list(id="IMPMNT_TT6",       label="Impoundment - Thermal (TT) 6%",                tech="TT",   source="Impoundment", dose="6%"),
  list(id="IMPMNT_ET12",      label="Impoundment - Electrostatic (ET) 12%",          tech="ET",   source="Impoundment", dose="12%"),
  list(id="IMPMNT_ET6",       label="Impoundment - Electrostatic (ET) 6%",           tech="ET",   source="Impoundment", dose="6%"),
  list(id="IMPMNT_CHEM_TYP",  label="Impoundment - Chemical (CHEM) Typical Dose",   tech="CHEM", source="Impoundment", dose="Typical"),
  list(id="IMPMNT_CHEM_MAX",  label="Impoundment - Chemical (CHEM) Max Dose",        tech="CHEM", source="Impoundment", dose="Max"),
  list(id="LFILL_CHEM_TYP",   label="Landfill - Chemical (CHEM) Typical Dose",       tech="CHEM", source="Landfill",    dose="Typical"),
  list(id="LFILL_CHEM_MAX",   label="Landfill - Chemical (CHEM) Max Dose",           tech="CHEM", source="Landfill",    dose="Max")
)

# Map scenario IDs -> sheet names in the absolute value files
#' @keywords internal
FA_SHEET_MAP <- c(
  "FreshAsh_ET12"    = "MIX_FreshAsh_ET12%",
  "FreshAsh_ET6"     = "MIX_FreshAsh _ET6%",
  "FreshAsh_CHEM_MAX"= "MIX_FreshAsh_CHEM_MAX_DOSE",
  "FreshAsh_CHEM_TYP"= "MIX_FreshAsh _CHEM_TYPICAL DOSE",
  "LFILL_TT12"       = "MIX_FA_LFILL_TT12%",
  "LFILL_TT6"        = "MIX_FA_LFILL_TT6%",
  "LFILL_ET12"       = "MIX_FA_LFILL_ET12%",
  "LFILL_ET6"        = "MIX_FA_LFILL_ET6%",
  "IMPMNT_TT12"      = "MIX_FA_IMPMNT_TT12%",
  "IMPMNT_TT6"       = "MIX_FA_IMPMNT_TT6%",
  "IMPMNT_ET12"      = "MIX_FA_IMPMNT_ET12%",
  "IMPMNT_ET6"       = "MIX_FA_IMPMNT_ET6%",
  "IMPMNT_CHEM_TYP"  = "MIX_FA_IMPMNT_CHEM_TYPICAL_DOSE",
  "IMPMNT_CHEM_MAX"  = "MIX_FA_IMPMNT_CHEM_MAX_DOSE",
  "LFILL_CHEM_TYP"   = "MIX_FA_LFILL_CHEM_TYPICAL DOSE",
  "LFILL_CHEM_MAX"   = "MIX_FA_LFILL_CHEM_MAX_DOSE"
)

# Map scenario IDs -> sheet names in percent-change files
#' @keywords internal
FA_PCT_SHEET_MAP <- c(
  "FreshAsh_ET12"    = "MIX_FreshAsh_ET12%",
  "FreshAsh_ET6"     = "MIX_FreshAsh _ET6%",
  "FreshAsh_CHEM_MAX"= "MIX_FreshAsh_CHEM_MAX_DOSE",
  "FreshAsh_CHEM_TYP"= "MIX_FreshAsh _CHEM_TYPICAL_DOSE",
  "LFILL_TT12"       = "MIX_FA_LFILL_TT12%",
  "LFILL_TT6"        = "MIX_FA_LFILL_TT6%",
  "LFILL_ET12"       = "MIX_FA_LFILL_ET12%",
  "LFILL_ET6"        = "MIX_FA_LFILL_ET6%",
  "IMPMNT_TT12"      = "MIX_FA_IMPMNT_TT12%",
  "IMPMNT_TT6"       = "MIX_FA_IMPMNT_TT6%",
  "IMPMNT_ET12"      = "MIX_FA_IMPMNT_ET12%",
  "IMPMNT_ET6"       = "MIX_FA_IMPMNT_ET6%",
  "IMPMNT_CHEM_TYP"  = "MIX_FA_IMPMNT_CHEM_TYPICAL_DOSE",
  "IMPMNT_CHEM_MAX"  = "MIX_FA_IMPMNT_CHEM_MAX_DOSE",
  "LFILL_CHEM_TYP"   = "MIX_FA_LFILL_CHEM_TYPICAL DOSE",
  "LFILL_CHEM_MAX"   = "MIX_FA_LFILL_CHEM_MAX_DOSE"
)

# -----------------------------------------------------------------------------
# Mix design reference data
# Source: National Ready Mixed Concrete Association(NRMCA) Member Survey 
# Units: kg/m3 for all material quantities (Functional Unit = 1m3)
# -----------------------------------------------------------------------------

#' Fly Ash Concrete Mix Design Proportions
#'
#' Sample mix design proportions as reported by NRMCA members for concrete
#' incorporating fly ash as a partial replacement of Portland cement.
#'
#' @format A data frame with 24 rows and 13 columns:
#' \describe{
#'   \item{strength}{Compressive strength class (MPa)}
#'   \item{pct_fa}{Fly ash replacement percentage (\%)}
#'   \item{fly_ash}{Fly ash content (kg/m3)}
#'   \item{cement}{Portland cement content (kg/m3)}
#'   \item{water}{Batch water (kg/m3)}
#'   \item{crushed_coarse}{Crushed coarse aggregate (kg/m3)}
#'   \item{nat_coarse}{Natural coarse aggregate (kg/m3)}
#'   \item{crushed_fine}{Crushed fine aggregate (kg/m3)}
#'   \item{nat_fine}{Natural fine aggregate (kg/m3)}
#'   \item{air_ent}{Air-entraining admixture (kg/m3)}
#'   \item{water_red}{Water-reducing admixture (kg/m3)}
#'   \item{hw_red}{High-range water-reducing admixture (kg/m3)}
#'   \item{acc_adm}{Accelerating admixture (kg/m3)}
#' }
#' @source NRMCA (2021); EPRI (2023)


#' @keywords internal
FA_MIX <- data.frame(
  strength      = c(17.2,17.2,17.2,17.2, 20.7,20.7,20.7,20.7, 27.6,27.6,27.6,27.6,
                    34.5,34.5,34.5,34.5, 41.4,41.4,41.4,41.4, 55.2,55.2,55.2,55.2),
  pct_fa        = c(0,20,30,40, 0,20,30,40, 0,20,30,40, 0,20,30,40, 0,20,30,40, 0,20,30,40),
  fly_ash       = c(0,53.4,82.5,113, 0,60.5,93.7,128, 0,77.1,119,163,
                    0,96.1,148,202, 0,101,156,214, 0,119,184,252),
  cement        = c(255,214,193,170, 288,243,218,192, 365,307,276,243,
                    456,384,345,304, 481,405,364,321, 567,477,429,378),
  water         = c(155,155,155,155, 155,155,155,155, 155,155,155,155,
                    160,160,160,160, 174,174,174,174, 174,174,174,174),
  crushed_coarse= c(667,667,667,667, 667,667,667,667, 667,667,667,667,
                    612,612,612,612, 612,612,612,612, 612,612,612,612),
  nat_coarse    = c(328,328,328,328, 328,328,328,328, 328,328,328,328,
                    301,301,301,301, 301,301,301,301, 301,301,301,301),
  crushed_fine  = c(97.3,92,89.6,86.6, 93.7,88.4,85.4,81.9, 86.6,79.5,75.4,71.8,
                    87.2,78.3,73.6,68.8, 89.6,80.7,75.4,70, 81.9,70.6,64.7,58.7),
  nat_fine      = c(738,701,681,659, 713,671,648,624, 657,603,575,544,
                    663,596,560,522, 683,612,574,533, 621,537,492,445),
  air_ent       = c(0.04,0.04,0.06,0.06, 0.04,0.04,0.06,0.06, 0.04,0.04,0.06,0.06,
                    0.04,0.04,0.06,0.06, 0,0,0,0, 0,0,0,0),
  water_red     = rep(0.11, 24),
  hw_red        = c(0,0,0,0, 0,0,0,0, 0,0,0,0,
                    0.15,0.15,0.15,0.15, 0.15,0.15,0.15,0.15, 0.15,0.15,0.15,0.15),
  acc_adm       = c(0.74,0.93,1.11,1.48, 0.56,0.74,0.74,1.11, 0.37,0.56,0.56,0.93,
                    0,0.37,0.56,0.74, 0,0.37,0.56,0.74, 0,0.37,0.56,0.56),
  stringsAsFactors = FALSE
)

#' Slag (GGBFS) Concrete Mix Design Proportions
#'
#' Sample mix design proportions as reported by NRMCA members for concrete
#' incorporating ground granulated blast-furnace slag (GGBFS) as a partial
#' replacement of Portland cement.
#'
#' @format A data frame with 24 rows and 13 columns:
#' \describe{
#'   \item{strength}{Compressive strength class (MPa)}
#'   \item{pct_slag}{GGBFS replacement percentage (\%)}
#'   \item{cement}{Portland cement content (kg/m3)}
#'   \item{slag}{GGBFS content (kg/m3)}
#'   \item{water}{Batch water (kg/m3)}
#'   \item{crushed_coarse}{Crushed coarse aggregate (kg/m3)}
#'   \item{nat_coarse}{Natural coarse aggregate (kg/m3)}
#'   \item{crushed_fine}{Crushed fine aggregate (kg/m3)}
#'   \item{nat_fine}{Natural fine aggregate (kg/m3)}
#'   \item{air_ent}{Air-entraining admixture (kg/m3)}
#'   \item{water_red}{Water-reducing admixture (kg/m3)}
#'   \item{hw_red}{High-range water-reducing admixture (kg/m3)}
#'   \item{acc_adm}{Accelerating admixture (kg/m3)}
#' }
#' @source NRMCA (2021)


#' @keywords internal
SLAG_MIX <- data.frame(
  strength      = c(17.24,17.24,17.24,17.24, 20.68,20.68,20.68,20.68,
                    27.58,27.58,27.58,27.58, 34.47,34.47,34.47,34.47,
                    41.37,41.37,41.37,41.37, 55.16,55.16,55.16,55.16),
  pct_slag      = c(0,30,40,50, 0,30,40,50, 0,30,40,50, 0,30,40,50, 0,30,40,50, 0,30,40,50),
  cement        = c(255,178,152,128, 288,202,173,144, 365,256,219,183,
                    456,319,274,228, 481,337,289,241, 567,397,340,284),
  slag          = c(0,76.5,102,127.6, 0,86.6,115.1,144.2, 0,109.8,145.9,182.7,
                    0,136.5,182.1,227.8, 0,144.2,192.2,240.9, 0,170.3,226.6,283.6),
  water         = c(155,155,155,155, 155,155,155,155, 155,155,155,155,
                    160,160,160,160, 174,174,174,174, 174,174,174,174),
  crushed_coarse= c(667,667,667,667, 667,667,667,667, 667,667,667,667,
                    612,612,612,612, 612,612,612,612, 612,612,612,612),
  nat_coarse    = c(328,328,328,328, 328,328,328,328, 328,328,328,328,
                    301,301,301,301, 301,301,301,301, 301,301,301,301),
  crushed_fine  = c(97.3,96.7,96.1,96.1, 93.7,93.1,93.1,92.6, 86.6,85.4,85.4,84.8,
                    87.2,86,86,85.4, 89.6,88.4,88.4,87.8, 81.9,80.1,79.5,79.5),
  nat_fine      = c(738,733,732,730, 713,708,706,704, 657,650,648,646,
                    663,654,651,649, 683,673,670,667, 621,610,606,603),
  air_ent       = c(0.04,0.04,0.04,0.04, 0.04,0.04,0.04,0.04, 0.04,0.04,0.04,0.04,
                    0.04,0.04,0.04,0.04, 0,0,0,0, 0,0,0,0),
  water_red     = rep(0.11, 24),
  hw_red        = c(0,0,0,0, 0,0,0,0, 0,0,0,0,
                    0.15,0.15,0.15,0.15, 0.15,0.15,0.15,0.15, 0.15,0.15,0.15,0.15),
  acc_adm       = c(0.74,1.11,1.48,1.67, 0.56,0.74,1.11,1.48, 0.37,0.56,0.93,1.11,
                    0,0.56,0.74,0.74, 0,0.56,0.74,0.93, 0,0.56,0.56,0.74),
  stringsAsFactors = FALSE
)
