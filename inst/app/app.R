library(shiny)
library(shinydashboard)
library(readxl)
library(DT)
library(plotly)
library(dplyr)
library(ggplot2)
library(scales)
library(ConcreteImpactApp)

# Resolve data directory via package helper
data_dir <- ConcreteImpactApp:::.data_dir()

#  Impact label mappings 
# SHORT  = column headers in absolute-value sheets
# LONG   = category strings in  percent-change sheets

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

# Display labels without units – for compact axes
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

#  Fly ash sheet metadata 
FA_SHEETS <- list(
  list(id="FreshAsh_ET12",    label="Fresh Ash - Electrostatic (ET) 12%",        tech="ET",   source="Fresh Ash",   dose="12%"),
  list(id="FreshAsh_ET6",     label="Fresh Ash - Electrostatic (ET) 6%",          tech="ET",   source="Fresh Ash",   dose="6%"),
  list(id="FreshAsh_CHEM_MAX",label="Fresh Ash - Chemical (CHEM) Max Dose",       tech="CHEM", source="Fresh Ash",   dose="Max"),
  list(id="FreshAsh_CHEM_TYP",label="Fresh Ash - Chemical (CHEM) Typical Dose",   tech="CHEM", source="Fresh Ash",   dose="Typical"),
  list(id="LFILL_TT12",       label="Landfill - Thermal (TT) 12%",                tech="TT",   source="Landfill",    dose="12%"),
  list(id="LFILL_TT6",        label="Landfill - Thermal (TT) 6%",                 tech="TT",   source="Landfill",    dose="6%"),
  list(id="LFILL_ET12",       label="Landfill - Electrostatic (ET) 12%",           tech="ET",   source="Landfill",    dose="12%"),
  list(id="LFILL_ET6",        label="Landfill - Electrostatic (ET) 6%",            tech="ET",   source="Landfill",    dose="6%"),
  list(id="IMPMNT_TT12",      label="Impoundment - Thermal (TT) 12%",              tech="TT",   source="Impoundment", dose="12%"),
  list(id="IMPMNT_TT6",       label="Impoundment - Thermal (TT) 6%",               tech="TT",   source="Impoundment", dose="6%"),
  list(id="IMPMNT_ET12",      label="Impoundment - Electrostatic (ET) 12%",         tech="ET",   source="Impoundment", dose="12%"),
  list(id="IMPMNT_ET6",       label="Impoundment - Electrostatic (ET) 6%",          tech="ET",   source="Impoundment", dose="6%"),
  list(id="IMPMNT_CHEM_TYP",  label="Impoundment - Chemical (CHEM) Typical Dose",  tech="CHEM", source="Impoundment", dose="Typical"),
  list(id="IMPMNT_CHEM_MAX",  label="Impoundment - Chemical (CHEM) Max Dose",       tech="CHEM", source="Impoundment", dose="Max"),
  list(id="LFILL_CHEM_TYP",   label="Landfill - Chemical (CHEM) Typical Dose",      tech="CHEM", source="Landfill",    dose="Typical"),
  list(id="LFILL_CHEM_MAX",   label="Landfill - Chemical (CHEM) Max Dose",          tech="CHEM", source="Landfill",    dose="Max")
)

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

#  Mix design data 
FA_MIX <- data.frame(
  strength=c(17.2,17.2,17.2,17.2,20.7,20.7,20.7,20.7,27.6,27.6,27.6,27.6,
             34.5,34.5,34.5,34.5,41.4,41.4,41.4,41.4,55.2,55.2,55.2,55.2),
  pct_fa=c(0,20,30,40,0,20,30,40,0,20,30,40,0,20,30,40,0,20,30,40,0,20,30,40),
  fly_ash=c(0,53.4,82.5,113,0,60.5,93.7,128,0,77.1,119,163,0,96.1,148,202,0,101,156,214,0,119,184,252),
  cement=c(255,214,193,170,288,243,218,192,365,307,276,243,456,384,345,304,481,405,364,321,567,477,429,378),
  water=c(155,155,155,155,155,155,155,155,155,155,155,155,160,160,160,160,174,174,174,174,174,174,174,174),
  crushed_coarse=c(667,667,667,667,667,667,667,667,667,667,667,667,612,612,612,612,612,612,612,612,612,612,612,612),
  nat_coarse=c(328,328,328,328,328,328,328,328,328,328,328,328,301,301,301,301,301,301,301,301,301,301,301,301),
  crushed_fine=c(97.3,92,89.6,86.6,93.7,88.4,85.4,81.9,86.6,79.5,75.4,71.8,87.2,78.3,73.6,68.8,89.6,80.7,75.4,70,81.9,70.6,64.7,58.7),
  nat_fine=c(738,701,681,659,713,671,648,624,657,603,575,544,663,596,560,522,683,612,574,533,621,537,492,445),
  air_ent=c(0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0.04,0.04,0.06,0.06,0,0,0,0,0,0,0,0),
  water_red=c(0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11),
  hw_red=c(0,0,0,0,0,0,0,0,0,0,0,0,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15),
  acc_adm=c(0.74,0.93,1.11,1.48,0.56,0.74,0.74,1.11,0.37,0.56,0.56,0.93,0,0.37,0.56,0.74,0,0.37,0.56,0.74,0,0.37,0.56,0.56),
  stringsAsFactors=FALSE
)

SLAG_MIX <- data.frame(
  strength=c(17.24,17.24,17.24,17.24,20.68,20.68,20.68,20.68,27.58,27.58,27.58,27.58,
             34.47,34.47,34.47,34.47,41.37,41.37,41.37,41.37,55.16,55.16,55.16,55.16),
  pct_slag=c(0,30,40,50,0,30,40,50,0,30,40,50,0,30,40,50,0,30,40,50,0,30,40,50),
  cement=c(255,178,152,128,288,202,173,144,365,256,219,183,456,319,274,228,481,337,289,241,567,397,340,284),
  slag=c(0,76.5,102,127.6,0,86.6,115.1,144.2,0,109.8,145.9,182.7,0,136.5,182.1,227.8,0,144.2,192.2,240.9,0,170.3,226.6,283.6),
  water=c(155,155,155,155,155,155,155,155,155,155,155,155,160,160,160,160,174,174,174,174,174,174,174,174),
  crushed_coarse=c(667,667,667,667,667,667,667,667,667,667,667,667,612,612,612,612,612,612,612,612,612,612,612,612),
  nat_coarse=c(328,328,328,328,328,328,328,328,328,328,328,328,301,301,301,301,301,301,301,301,301,301,301,301),
  crushed_fine=c(97.3,96.7,96.1,96.1,93.7,93.1,93.1,92.6,86.6,85.4,85.4,84.8,87.2,86,86,85.4,89.6,88.4,88.4,87.8,81.9,80.1,79.5,79.5),
  nat_fine=c(738,733,732,730,713,708,706,704,657,650,648,646,663,654,651,649,683,673,670,667,621,610,606,603),
  air_ent=c(0.04,0.04,0.04,0.04,0.04,0.04,0.04,0.04,0.04,0.04,0.04,0.04,0.04,0.04,0.04,0.04,0,0,0,0,0,0,0,0),
  water_red=c(0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11,0.11),
  hw_red=c(0,0,0,0,0,0,0,0,0,0,0,0,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15,0.15),
  acc_adm=c(0.74,1.11,1.48,1.67,0.56,0.74,1.11,1.48,0.37,0.56,0.93,1.11,0,0.56,0.74,0.74,0,0.56,0.74,0.93,0,0.56,0.56,0.74),
  stringsAsFactors=FALSE
)

#  Data reader helpers 

# Parse  absolute-value sheets
parse_abs_sheet <- function(fpath, sheet_name, repl_col_name = "Repl_Pct") {
  df <- tryCatch(suppressMessages(read_excel(fpath,sheet=sheet_name,col_names=FALSE)),error=function(e)NULL)
  if (is.null(df)) return(NULL)
  hrow <- NA
  for (i in seq_len(nrow(df))) {
    if (any(grepl("Concrete Compressive Strength",unlist(df[i,]),ignore.case=TRUE))) { hrow <- i; break }
  }
  if (is.na(hrow)) return(NULL)
  imp_names  <- as.character(unlist(df[hrow-1,]))
  short_names <- imp_names[3:12]
  dat <- as.data.frame(df[(hrow+1):nrow(df),],stringsAsFactors=FALSE)
  dat <- dat[rowSums(!is.na(dat))>0,]
  scol <- as.character(dat[[1]])
  for (i in seq_along(scol))
    if (i>1 && (is.na(scol[i])||scol[i]%in%c("NA",""))) scol[i] <- scol[i-1]
  dat[[1]] <- as.numeric(sub("^([0-9.]+).*$","\\1",trimws(scol)))
  dat[[2]] <- as.numeric(dat[[2]])
  for (j in 3:min(12,ncol(dat))) dat[[j]] <- as.numeric(dat[[j]])
  colnames(dat)[1] <- "Strength_MPa"
  colnames(dat)[2] <- repl_col_name
  if (ncol(dat)>=12) colnames(dat)[3:12] <- short_names
  dat[!is.na(dat[[1]]),]
}

read_fa_lcia <- function(sheet_id, credited=TRUE) {
  fname <- if(credited) "Supporting__Information_5_fly_ash_concrete_credited.XLSX" else
    "Supporting_Information_6_fly_ash_concrete_no_credit.XLSX"
  sname <- FA_SHEET_MAP[[sheet_id]]
  if (is.null(sname)||is.na(sname)) return(NULL)
  parse_abs_sheet(file.path(data_dir,fname),sname,"FA_Pct")
}

read_slag_lcia <- function(country="USA") {
  parse_abs_sheet(file.path(data_dir,"Supporting__Information_11Slag_concrete_all_countries.xlsx"),country,"GGBFS_Pct")
}

# Parse percent-change sheets – returns ALL strengths & replacements
parse_pct_sheet <- function(fpath, sheet_name, repl_col="Repl_Pct") {
  df <- tryCatch(suppressMessages(read_excel(fpath,sheet=sheet_name,col_names=TRUE)),error=function(e)NULL)
  if (is.null(df)||nrow(df)==0) return(NULL)
  colnames(df) <- c("Strength_MPa",repl_col,"Impact_Category","Value","Baseline","Pct_Change")
  df$Strength_MPa <- trimws(as.character(df$Strength_MPa))
  df$str_num      <- as.numeric(sub("^([0-9.]+).*$","\\1",df$Strength_MPa))
  df[[repl_col]]  <- as.numeric(df[[repl_col]])
  df$Value        <- as.numeric(df$Value)
  df$Baseline     <- as.numeric(df$Baseline)
  df$Pct_Change   <- as.numeric(df$Pct_Change)
  df$Impact_Display <- IMPACT_DISPLAY[df$Impact_Category]
  df$Impact_Display[is.na(df$Impact_Display)] <- df$Impact_Category[is.na(df$Impact_Display)]
  df[!is.na(df$str_num)&!is.na(df[[repl_col]]),]
}

read_fa_pct_full <- function(sheet_id, credited=TRUE) {
  fname <- if(credited) "Supporting__information_7_fly_ash_percent_change_credit.xlsx" else
    "Supporting__Information_8fly_ash_percent_change_no_credit.xlsx"
  sname <- FA_PCT_SHEET_MAP[[sheet_id]]
  if (is.null(sname)||is.na(sname)) return(NULL)
  parse_pct_sheet(file.path(data_dir,fname),sname,"FA_Pct")
}

read_slag_pct_full <- function(country="USA") {
  smap <- c("USA"="USA MIX","JAPAN"="JAPAN MIX","CHINA"="CHINA MIX","BRAZIL"="BRAZIL MIX")
  parse_pct_sheet(file.path(data_dir,"Supporting__Information_12Slag_percent_change.xlsx"),smap[[country]],"GGBFS_Pct")
}

#  ggplot2 facet helper – shared theme 
facet_pct_theme <- function() {
  list(
    theme_minimal(base_size=11),
    theme(
      strip.background = element_rect(fill="gray92",color="gray75",size=0.6),
      strip.text       = element_text(face="bold",size=8.5,margin=margin(4,4,4,4)),
      axis.text.x      = element_text(angle=45,hjust=1,vjust=1,size=8),
      axis.text.y      = element_text(size=8),
      axis.title.x     = element_text(size=10,margin=margin(t=8)),
      axis.title.y     = element_text(size=10,margin=margin(r=8)),
      panel.border     = element_rect(color="gray60",fill=NA,size=0.5),
      panel.spacing    = unit(0.6,"lines"),
      legend.position  = "bottom",
      legend.title     = element_text(size=9,face="bold"),
      legend.text      = element_text(size=8.5),
      legend.key.size  = unit(0.55,"cm"),
      plot.title       = element_text(size=12,face="bold",hjust=0.5,margin=margin(b=8)),
      plot.subtitle    = element_text(size=9,hjust=0.5,color="gray40",margin=margin(b=6)),
      plot.margin      = margin(10,12,10,12)
    )
  )
}

make_fa_pct_facet <- function(df, title_txt, subtitle_txt,
                              fa_colors=c("20"="#FECC5C","30"="#009B3A","40"="#CC79A7")) {
  # Ensure strength is an ordered factor
  str_order <- sort(unique(df$str_num))
  df$Strength_label <- factor(df$str_num, levels=str_order,
                              labels=paste0(str_order," MPa"))
  df$Repl_label <- factor(as.character(df$FA_Pct),
                          levels=c("20","30","40"))
  
  # Highlight Global Warming panel
  cats <- unique(df$Impact_Display)
  strip_fills <- setNames(rep("gray92",length(cats)),cats)
  gw_label <- IMPACT_DISPLAY["Global warming (kg CO2 eq)"]
  if (!is.na(gw_label) && gw_label %in% names(strip_fills))
    strip_fills[gw_label] <- "#7B1818"
  strip_text_colors <- ifelse(strip_fills=="#7B1818","white","black")
  names(strip_text_colors) <- names(strip_fills)
  
  ggplot(df, aes(x=Strength_label, y=Pct_Change, fill=Repl_label)) +
    geom_bar(stat="identity", position=position_dodge(width=0.75), width=0.7) +
    geom_text(aes(label=paste0(round(Pct_Change,1),"%")),
              position=position_dodge(width=0.75),
              angle=90, hjust=ifelse(df$Pct_Change>=0,-0.15,1.15),
              size=2.2, color="gray20") +
    facet_wrap(~Impact_Display, scales="free_y", ncol=4,
               labeller=labeller(Impact_Display=function(x) x)) +
    scale_fill_manual(values=fa_colors, name="Fly Ash (%)") +
    scale_y_continuous(expand=expansion(mult=c(0.15,0.22))) +
    labs(title=title_txt, subtitle=subtitle_txt,
         x="Compressive Strength (MPa)", y="Percent Change (%)") +
    facet_pct_theme() +
    # Color individual strip backgrounds via geom trick — use ggh4x or manual override
    theme(strip.background=element_blank(),
          strip.text=element_text(face="bold",size=8.5))
}

make_slag_pct_facet <- function(df, title_txt, subtitle_txt,
                                slag_colors=c("30"="#E1BE6A","40"="#40B0A6","50"="#E0B79E")) {
  str_order <- sort(unique(df$str_num))
  df$Strength_label <- factor(df$str_num, levels=str_order,
                              labels=paste0(str_order," MPa"))
  df$Repl_label <- factor(as.character(df$GGBFS_Pct),
                          levels=c("30","40","50"))
  
  ggplot(df, aes(x=Strength_label, y=Pct_Change, fill=Repl_label)) +
    geom_bar(stat="identity", position=position_dodge(width=0.75), width=0.7) +
    geom_text(aes(label=paste0(round(Pct_Change,1),"%")),
              position=position_dodge(width=0.75),
              angle=90, hjust=ifelse(df$Pct_Change>=0,-0.15,1.15),
              size=2.2, color="gray20") +
    facet_wrap(~Impact_Display, scales="free_y", ncol=4,
               labeller=labeller(Impact_Display=function(x) x)) +
    scale_fill_manual(values=slag_colors, name="Slag GGBFS (%)") +
    scale_y_continuous(expand=expansion(mult=c(0.15,0.22))) +
    labs(title=title_txt, subtitle=subtitle_txt,
         x="Compressive Strength (MPa)", y="Percent Change (%)") +
    facet_pct_theme() +
    theme(strip.background=element_blank(),
          strip.text=element_text(face="bold",size=8.5))
}

# UI 
ui <- dashboardPage(skin="blue",
                    dashboardHeader(title=tags$span(icon("industry")," Concrete LCA Dashboard"),titleWidth=290),
                    dashboardSidebar(width=290,
                                     tags$style(HTML(".sidebar-menu>li>a{font-size:13.5px;}.skin-blue .sidebar-menu>li.active>a{border-left:4px solid #f0ad4e;}")),
                                     sidebarMenu(id="main_tabs",
                                                 menuItem("Home",         tabName="home",   icon=icon("home")),
                                                 menuItem("Fly Ash (FA)", tabName="flyash", icon=icon("leaf")),
                                                 menuItem("Slag (GGBFS)", tabName="slag",   icon=icon("cogs")),
                                                 menuItem("Comparison",   tabName="compare",icon=icon("chart-bar")),
                                                 menuItem("About",        tabName="about",  icon=icon("info-circle"))
                                     ),
                                     tags$hr(),
                                     tags$div(style="padding:12px 18px;color:#aaa;font-size:11px;",
                                              tags$b("U.S. Ready-Mix Concrete"),tags$br(),"Life Cycle Assessment Tool",
                                              tags$br(),tags$br(),"Contact & Correspondence:dpbxc@mst.edu",
                                              tags$br(),tags$br(),"Mine Sustainability Modeling Research Group (Chair: Professor Kwame Awuah-Offei) . Missouri University of Science & Technology"
                                     )
                    ),
                    dashboardBody(
                      tags$head(tags$style(HTML("
      body,.content-wrapper{background:#f4f6fb;}
      .box{border-radius:10px;box-shadow:0 2px 12px rgba(0,0,0,.08);border-top-width:3px;}
      .info-box{border-radius:10px;box-shadow:0 2px 10px rgba(0,0,0,.08);}
      .info-box-icon{border-radius:10px 0 0 10px;}
      .nav-tabs>li>a{font-weight:600;color:#1e3a5f;}
      h2.st{color:#1e3a5f;font-weight:700;border-left:4px solid #f0ad4e;padding-left:10px;margin:20px 0 14px;}
      .mc{background:white;border-radius:10px;padding:16px;margin-bottom:12px;box-shadow:0 2px 8px rgba(0,0,0,.06);}
      .mh{font-weight:700;color:#1e3a5f;font-size:15px;margin-bottom:10px;border-bottom:2px solid #f0ad4e;padding-bottom:6px;}
      table.dataTable thead th{background:#1e3a5f!important;color:white!important;}
      .facet-note{color:#555;font-size:12px;font-style:italic;margin-bottom:8px;}
    "))),
                      tabItems(
                        
                        # HOME
                        tabItem("home",
                                fluidRow(column(12,tags$div(style="text-align:center;padding:30px 20px 10px;",
                                                            tags$h1(style="color:#1e3a5f;font-weight:800;font-size:2.2em;",
                                                                    icon("industry")," The Mine Sustainability Modeling Group Concrete Life Cycle Impact Assessment Tool"),
                                                            tags$p(style="color:#555;font-size:1.1em;max-width:720px;margin:auto;",
                                                                   "
An LCA‑based sustainability decision‑support tool for the U.S. ready‑mix concrete industry, quantifying the environmental trade‑offs of fly ash and slag (ground granulated blast‑furnace slag, GGBFS) as supplementary cementitious materials.")
                                ))),
                                fluidRow(
                                  infoBox("Compressive Strengths","6 levels (17-55 MPa)",icon=icon("tachometer-alt"),color="blue",  fill=TRUE,width=3),
                                  infoBox("Fly Ash Scenarios",    "16 source/treatment", icon=icon("leaf"),          color="green", fill=TRUE,width=3),
                                  infoBox("Slag Supply Chains",   "USA/Brazil/China/Japan",icon=icon("globe"),       color="yellow",fill=TRUE,width=3),
                                  infoBox("Impact Categories",    "10 (TRACI 2.2)",      icon=icon("chart-line"),    color="red",   fill=TRUE,width=3)
                                ),
                                fluidRow(
                                  box(title="Fly Ash (FA)",status="success",solidHeader=TRUE,width=4,
                                      tags$ul(tags$li(tags$b("Thermal (TT)")," 6% or 12% LOI"),
                                              tags$li(tags$b("Electrostatic (ET)")," 6% or 12% LOI"),
                                              tags$li(tags$b("Chemical (CHEM)")," Typical or Maximum dose")),
                                      tags$p("Sources: Fresh Ash | Landfill | Impoundment"),
                                      actionButton("go_flyash","Explore Fly Ash",icon=icon("arrow-right"),class="btn btn-success")
                                  ),
                                  box(title="Slag / GGBFS",status="warning",solidHeader=TRUE,width=4,
                                      tags$ul(tags$li(tags$b("USA")," Domestic supply chain"),
                                              tags$li(tags$b("Brazil | China | Japan")," Import sources")),
                                      tags$p("Replacement levels: 30%, 40%, 50%"),
                                      actionButton("go_slag","Explore Slag",icon=icon("arrow-right"),class="btn btn-warning")
                                  ),
                                  box(title="How To Use",status="primary",solidHeader=TRUE,width=4,
                                      tags$ol(tags$li("Select Fly Ash or Slag from sidebar"),
                                              tags$li("Choose compressive strength"),
                                              tags$li("Select technology or supply chain"),
                                              tags$li("Toggle credit allocation"),
                                              tags$li("View mix design, LCIA and % change plots"))
                                  )
                                )
                        ),
                        
                        # FLY ASH
                        tabItem("flyash",
                                fluidRow(box(title="Fly Ash Settings",status="success",solidHeader=TRUE,width=12,
                                             fluidRow(
                                               column(3,selectInput("fa_strength","Compressive Strength (MPa):",
                                                                    choices=c("17.2 MPa"="17.2","20.7 MPa"="20.7","27.6 MPa"="27.6",
                                                                              "34.5 MPa"="34.5","41.4 MPa"="41.4","55.2 MPa"="55.2"),selected="27.6")),
                                               column(3,selectInput("fa_tech","Treatment Technology:",
                                                                    choices=c("Electrostatic (ET)"="ET","Thermal (TT)"="TT","Chemical (CHEM)"="CHEM"),selected="ET")),
                                               column(3,uiOutput("fa_source_ui")),
                                               column(3,uiOutput("fa_dose_ui"))
                                             ),
                                             fluidRow(
                                               column(6,radioButtons("fa_credit","Impact Assessment:",
                                                                     choices=c("With Credit (avoided impacts)"="credit","Without Credit"="nocredit"),
                                                                     selected="credit",inline=TRUE)),
                                               column(6,uiOutput("fa_scenario_label"))
                                             )
                                )),
                                fluidRow(tabBox(width=12,title="Fly Ash Results",
                                                tabPanel("Mix Design",
                                                         h2("Mix Design Material Inputs (kg/m3)",class="st"),
                                                         uiOutput("fa_mix_cards"),br(),
                                                         DT::dataTableOutput("fa_mix_table")),
                                                tabPanel("LCIA Results (Absolute)",
                                                         h2("Life Cycle Impact Assessment — Each Impact Category",class="st"),
                                                         tags$p(class="facet-note","One panel per impact category. Bars show 0%, 20%, 30%, 40% fly ash replacement at the selected compressive strength."),
                                                         plotlyOutput("fa_lcia_facet",height="820px"),
                                                         br(),
                                                         DT::dataTableOutput("fa_lcia_table")),
                                                tabPanel("% Change vs Baseline",
                                                         h2("Percent Change vs 0% Replacement — All Strengths & Replacements",class="st"),
                                                         tags$p(class="facet-note","Faceted by impact category. X-axis = compressive strength. Bars = fly ash replacement level. Green = reduction, brown/red = increase vs baseline."),
                                                         plotOutput("fa_pct_chart",height="820px"),
                                                         br(),
                                                         DT::dataTableOutput("fa_pct_table"))
                                ))
                        ),
                        
                        # SLAG
                        tabItem("slag",
                                fluidRow(box(title="Slag (GGBFS) Settings",status="warning",solidHeader=TRUE,width=12,
                                             fluidRow(
                                               column(4,selectInput("slag_strength","Compressive Strength (MPa):",
                                                                    choices=c("17.2 MPa"="17.2","20.7 MPa"="20.7","27.6 MPa"="27.6",
                                                                              "34.5 MPa"="34.5","41.4 MPa"="41.4","55.2 MPa"="55.2"),selected="27.6")),
                                               column(4,selectInput("slag_country","Supply Chain Origin:",
                                                                    choices=c("USA (Domestic)"="USA","Brazil"="BRAZIL","China"="CHINA","Japan"="JAPAN"),selected="USA")),
                                               column(4,tags$div(style="padding-top:25px;",
                                                                 wellPanel(tags$b("Replacement Levels:"),
                                                                           tags$p("0% (baseline), 30%, 40%, 50%",style="margin:0;"))))
                                             )
                                )),
                                fluidRow(tabBox(width=12,title="Slag Results",
                                                tabPanel("Mix Design",
                                                         h2("Mix Design Material Inputs — Slag(GGBFS) (kg/m3)",class="st"),
                                                         uiOutput("slag_mix_cards"),br(),
                                                         DT::dataTableOutput("slag_mix_table")),
                                                tabPanel("LCIA Results (Absolute)",
                                                         h2("Life Cycle Impact Assessment — Each Impact Category",class="st"),
                                                         tags$p(class="facet-note","One panel per impact category. Bars show 0%, 30%, 40%, 50% GGBFS replacement at the selected compressive strength."),
                                                         plotlyOutput("slag_lcia_facet",height="820px"),
                                                         br(),
                                                         DT::dataTableOutput("slag_lcia_table")),
                                                tabPanel("% Change vs Baseline",
                                                         h2("Percent Change vs 0% Replacement — All Strengths & Replacements",class="st"),
                                                         tags$p(class="facet-note","Faceted by impact category. X-axis = compressive strength. Bars = GGBFS replacement level. Green = reduction, orange/red = increase vs baseline."),
                                                         plotOutput("slag_pct_chart",height="820px"),
                                                         br(),
                                                         DT::dataTableOutput("slag_pct_table"))
                                ))
                        ),
                        
                        # COMPARISON
                        tabItem("compare",
                                fluidRow(box(title="Comparison Settings",status="primary",solidHeader=TRUE,width=12,
                                             fluidRow(
                                               column(3,selectInput("cmp_strength","Strength:",
                                                                    choices=c("17.2 MPa"="17.2","20.7 MPa"="20.7","27.6 MPa"="27.6",
                                                                              "34.5 MPa"="34.5","41.4 MPa"="41.4","55.2 MPa"="55.2"),selected="27.6")),
                                               column(4,selectInput("cmp_impact","Impact Category:",
                                                                    choices=setNames(names(IMPACT_DISPLAY),unname(gsub("\n"," ",IMPACT_DISPLAY))),
                                                                    selected="Global warming (kg CO2 eq)")),
                                               column(3,radioButtons("cmp_credit","FA Credit:",
                                                                     choices=c("With Credit"="credit","Without Credit"="nocredit"),
                                                                     selected="credit",inline=TRUE))
                                             )
                                )),
                                fluidRow(box(title="All FA Scenarios + Slag Supply Chains at Selected Strength",
                                             status="primary",solidHeader=TRUE,width=12,
                                             tags$p(class="facet-note","Each point = one scenario. Symbol shape = replacement level. Hover for details. Scroll right if needed."),
                                             plotlyOutput("compare_plot",height="650px")
                                ))
                        ),
                        
                        # ABOUT
                        tabItem("about",
                                fluidRow(
                                  box(title="About",status="info",solidHeader=TRUE,width=8,
                                      tags$h4("Background"),
                                      tags$p("Life cycle assessment results for ready-mix concrete with fly ash and slag(GGBFS) as partial cement replacements."),
                                      tags$h4("Output"),
                                      tags$ul(tags$li("Based on a complete cradle‑to‑gate life cycle impact assessment (LCIA) of Portland cement, fly ash, and slag (GGBFS: Ground Granulated Blast‑furnace Slag)"),
                                              tags$li("Impact Assessment Method: TRACI 2.2")),
                                      tags$h4("Ash Processing Technologies"),
                                      tags$ul(tags$li(tags$b("Thermal (TT):")," Combustion Loss on Ignition (LOI) 6%/12% (6% and 12% LOI (Carbon Content))"),
                                              tags$li(tags$b("Electrostatic (ET):")," Carbon separation 6%/12% (6% and 12% LOI (Carbon Content))"),
                                              tags$li(tags$b("Chemical (CHEM):")," Non-ionic surfactant Typical/Max dose (Commonly used (Typical dose) and Maximum dose of Non-ionic surfactant ")),
                                      tags$h4("Fly Ash Sources"),
                                      tags$ul(tags$li(tags$b("Fresh Ash:")," Direct from coal plant"),
                                              tags$li(tags$b("Landfill:")," Recovered from landfill"),
                                              tags$li(tags$b("Impoundment:")," Recovered from impoundment"))
                                  ),
                                  box(title="Impact Categories (TRACI 2.2)",status="info",solidHeader=TRUE,width=4,
                                      tags$table(class="table table-striped table-sm",
                                                 tags$thead(tags$tr(tags$th("Category"),tags$th("Unit"))),
                                                 tags$tbody(
                                                   tags$tr(tags$td("Global Warming"),           tags$td("kg CO2 eq")),
                                                   tags$tr(tags$td("Ozone Depletion"),          tags$td("kg CFC-11 eq")),
                                                   tags$tr(tags$td("Smog"),                     tags$td("kg O3 eq")),
                                                   tags$tr(tags$td("Acidification"),            tags$td("kg SO2 eq")),
                                                   tags$tr(tags$td("Carcinogenics"),            tags$td("CTUh")),
                                                   tags$tr(tags$td("Non-Carcinogenics"),        tags$td("CTUh")),
                                                   tags$tr(tags$td("Respiratory Effects"),      tags$td("kg PM2.5 eq")),
                                                   tags$tr(tags$td("Ecotoxicity"),              tags$td("CTUe")),
                                                   tags$tr(tags$td("Freshwater Eutrophication"),tags$td("kg P eq")),
                                                   tags$tr(tags$td("Marine Eutrophication"),    tags$td("kg N eq"))
                                                 )
                                      )
                                  )
                                )
                        )
                      )
                    )
)

#  SERVER 
server <- function(input, output, session) {
  
  observeEvent(input$go_flyash, updateTabItems(session,"main_tabs","flyash"))
  observeEvent(input$go_slag,   updateTabItems(session,"main_tabs","slag"))
  
  # FA dynamic selectors
  output$fa_source_ui <- renderUI({
    tech <- req(input$fa_tech)
    sources <- unique(sapply(FA_SHEETS[sapply(FA_SHEETS,function(s) s$tech==tech)],`[[`,"source"))
    selectInput("fa_source","Fly Ash Source:",choices=sources)
  })
  output$fa_dose_ui <- renderUI({
    tech <- req(input$fa_tech); src <- req(input$fa_source)
    sheets <- FA_SHEETS[sapply(FA_SHEETS,function(s) s$tech==tech && s$source==src)]
    doses <- setNames(sapply(sheets,`[[`,"dose"),paste("LOI/Dose:",sapply(sheets,`[[`,"dose")))
    selectInput("fa_dose","LOI / Dose Level:",choices=doses)
  })
  fa_sheet_id <- reactive({
    tech <- req(input$fa_tech); src <- req(input$fa_source); dose <- req(input$fa_dose)
    m <- FA_SHEETS[sapply(FA_SHEETS,function(s) s$tech==tech && s$source==src && s$dose==dose)]
    if (length(m)==0) return(NULL)
    m[[1]]$id
  })
  output$fa_scenario_label <- renderUI({
    sid <- fa_sheet_id(); req(sid)
    idx <- which(sapply(FA_SHEETS,`[[`,"id")==sid)
    wellPanel(tags$b("Selected:"),tags$br(),tags$small(FA_SHEETS[[idx]]$label))
  })
  
  # FA mix
  fa_mix_df <- reactive({ FA_MIX[abs(FA_MIX$strength-as.numeric(req(input$fa_strength)))<0.5,] })
  
  output$fa_mix_cards <- renderUI({
    df <- fa_mix_df(); sv <- input$fa_strength
    tc <- c("0"="info","20"="success","30"="warning","40"="danger")
    cards <- lapply(seq_len(nrow(df)),function(i){
      r <- df[i,]; p <- as.character(r$pct_fa); cl <- tc[p]
      column(3,tags$div(class="mc",
                        tags$div(class="mh",tags$span(class=paste0("label label-",cl),paste0(p,"% FA")),paste0(" - ",sv," MPa")),
                        tags$table(class="table table-condensed",style="font-size:12px;margin:0;",tags$tbody(
                          tags$tr(tags$td("Fly Ash"),      tags$td(tags$b(r$fly_ash),       " kg")),
                          tags$tr(tags$td("Cement"),        tags$td(tags$b(r$cement),        " kg")),
                          tags$tr(tags$td("Water"),         tags$td(tags$b(r$water),         " kg")),
                          tags$tr(tags$td("Crushed Coarse"),tags$td(tags$b(r$crushed_coarse)," kg")),
                          tags$tr(tags$td("Nat. Coarse"),   tags$td(tags$b(r$nat_coarse),    " kg")),
                          tags$tr(tags$td("Crushed Fine"),  tags$td(tags$b(r$crushed_fine),  " kg")),
                          tags$tr(tags$td("Nat. Fine"),     tags$td(tags$b(r$nat_fine),      " kg")),
                          tags$tr(tags$td("Air Entrainer"), tags$td(tags$b(r$air_ent),       " kg")),
                          tags$tr(tags$td("Water Reducer"), tags$td(tags$b(r$water_red),     " kg")),
                          tags$tr(tags$td("HW Reducer"),    tags$td(tags$b(r$hw_red),        " kg")),
                          tags$tr(tags$td("Accelerator"),   tags$td(tags$b(r$acc_adm),       " kg"))
                        ))
      ))
    })
    do.call(fluidRow,cards)
  })
  output$fa_mix_table <- DT::renderDataTable({
    df <- fa_mix_df(); df$pct_fa <- paste0(df$pct_fa,"%")
    colnames(df) <- c("Strength","FA Repl","Fly Ash","Cement","Water","Crushed Coarse",
                      "Nat Coarse","Crushed Fine","Nat Fine","Air Ent","Water Red","HW Red","Accel")
    DT::datatable(df,options=list(pageLength=10L,scrollX=TRUE,dom="lrtip"),rownames=FALSE,
                  class="cell-border stripe hover") %>%
      DT::formatStyle("FA Repl",backgroundColor=DT::styleEqual(
        c("0%","20%","30%","40%"),c("#d0eaff","#d4f0db","#fff3cd","#fde8e8")))
  })
  
  # FA LCIA absolute — FACET PLOT (one panel per impact category)
  fa_lcia_df <- reactive({
    sid <- req(fa_sheet_id()); sv <- as.numeric(req(input$fa_strength))
    df <- read_fa_lcia(sid,input$fa_credit=="credit")
    validate(need(!is.null(df)&&nrow(df)>0,"Data not available."))
    r <- df[abs(df$Strength_MPa-sv)<0.5,]
    validate(need(nrow(r)>0,paste0("No data for ",sv," MPa.")))
    r
  })
  
  output$fa_lcia_facet <- renderPlotly({
    df   <- fa_lcia_df()
    sv   <- input$fa_strength
    ic   <- colnames(df)[3:ncol(df)]
    # Pivot to long format
    long <- do.call(rbind, lapply(seq_len(nrow(df)), function(i) {
      row <- df[i,]
      pct <- row$FA_Pct * 100
      data.frame(
        FA_Pct    = as.character(pct),
        Impact    = ic,
        ImpLabel  = unname(ifelse(is.na(IMPACT_SHORT_LABEL[ic]), ic, IMPACT_SHORT_LABEL[ic])),
        Value     = as.numeric(row[3:ncol(row)]),
        stringsAsFactors=FALSE
      )
    }))
    long$FA_Pct <- factor(long$FA_Pct, levels=c("0","20","30","40"))
    
    bar_pal <- c("0"="#1e3a5f","20"="#2980b9","30"="#f39c12","40"="#e74c3c")
    impact_list <- unique(long$ImpLabel)
    
    # Build subplot: 10 panels, 4 cols x 3 rows
    plots_list <- lapply(impact_list, function(imp) {
      sub <- long[long$ImpLabel==imp,]
      plot_ly(sub, x=~FA_Pct, y=~Value, color=~FA_Pct, colors=bar_pal,
              type="bar", showlegend=(imp==impact_list[1]),
              hovertemplate=paste0("<b>",imp,"</b><br>FA: %{x}%<br>Value: %{y:.4g}<extra></extra>"),
              legendgroup=~FA_Pct
      ) %>%
        layout(xaxis=list(title="FA %",tickfont=list(size=9)),
               yaxis=list(title=sub(".*\n","",imp),tickfont=list(size=8)),
               annotations=list(list(text=paste0("<b>",gsub("\n","<br>",imp),"</b>"),
                                     x=0.5,y=1.08,xref="paper",yref="paper",
                                     showarrow=FALSE,font=list(size=10),align="center")))
    })
    
    # Arrange in 3 rows x 4 cols (10 panels + 2 blank)
    nrow_p <- 3; ncol_p <- 4
    subplot(plots_list, nrows=nrow_p, shareX=FALSE, shareY=FALSE,
            titleX=TRUE, titleY=TRUE, margin=0.06) %>%
      layout(
        title=list(text=paste0("<b>LCIA – ",sv," MPa | ",input$fa_tech," / ",input$fa_source,
                               if(input$fa_credit=="credit")" (with credit)" else " (no credit)","</b>"),
                   font=list(size=13), x=0.5),
        plot_bgcolor="#f9fafc", paper_bgcolor="#f9fafc",
        legend=list(title=list(text="<b>FA %</b>"),orientation="h",
                    x=0.5,xanchor="center",y=-0.05),
        margin=list(t=60,b=60,l=60,r=20)
      )
  })
  
  output$fa_lcia_table <- DT::renderDataTable({
    df <- fa_lcia_df()
    ic <- colnames(df)[3:ncol(df)]
    nice <- unname(IMPACT_SHORT_LABEL[ic]); nice[is.na(nice)] <- ic[is.na(nice)]
    out <- df; out$FA_Pct <- paste0(out$FA_Pct*100,"%")
    colnames(out) <- c("Strength (MPa)","FA Repl",nice)
    DT::datatable(out,options=list(pageLength=10L,scrollX=TRUE,dom="lrtip"),rownames=FALSE,
                  class="cell-border stripe hover") %>%
      DT::formatSignif(columns=seq(3L,ncol(out)),digits=4L)
  })
  
  # FA % change — ggplot2 FACET PLOT (all strengths, faceted by impact)
  fa_pct_full_df <- reactive({
    sid <- req(fa_sheet_id())
    df <- read_fa_pct_full(sid, input$fa_credit=="credit")
    validate(need(!is.null(df)&&nrow(df)>0,"Percent-change data not available."))
    #  pct to character for fill
    df$FA_Pct <- as.character(df$FA_Pct)
    df
  })
  
  output$fa_pct_chart <- renderPlot({
    df    <- fa_pct_full_df()
    sid   <- fa_sheet_id()
    idx   <- which(sapply(FA_SHEETS,`[[`,"id")==sid)
    lbl   <- FA_SHEETS[[idx]]$label
    credit_lbl <- if(input$fa_credit=="credit") "With Credit" else "Without Credit"
    make_fa_pct_facet(df,
                      title_txt    = paste0("% Change vs Baseline — Fly Ash\n",lbl),
                      subtitle_txt = paste0(credit_lbl," | All Compressive Strengths | FA 20%, 30%, 40%")
    )
  }, res=110)
  
  output$fa_pct_table <- DT::renderDataTable({
    df <- fa_pct_full_df()
    out <- data.frame("Strength"=df$str_num,"FA%"=df$FA_Pct,
                      "Impact"=df$Impact_Display,"Value"=round(df$Value,6),
                      "Baseline"=round(df$Baseline,6),"Pct Change"=round(df$Pct_Change,2),
                      check.names=FALSE,stringsAsFactors=FALSE)
    DT::datatable(out,options=list(pageLength=15L,scrollX=TRUE,dom="lrtip"),rownames=FALSE,
                  class="cell-border stripe hover") %>%
      DT::formatStyle("Pct Change",color=DT::styleInterval(0,c("#27ae60","#e74c3c")),fontWeight="bold")
  })
  
  # SLAG mix
  slag_mix_df <- reactive({
    sv <- as.numeric(req(input$slag_strength))
    avail <- unique(SLAG_MIX$strength)
    SLAG_MIX[SLAG_MIX$strength==avail[which.min(abs(avail-sv))],]
  })
  output$slag_mix_cards <- renderUI({
    df <- slag_mix_df(); sv <- df$strength[1]
    tc <- c("0"="info","30"="success","40"="warning","50"="danger")
    cards <- lapply(seq_len(nrow(df)),function(i){
      r <- df[i,]; p <- as.character(r$pct_slag); cl <- tc[p]
      column(3,tags$div(class="mc",
                        tags$div(class="mh",tags$span(class=paste0("label label-",cl),paste0(p,"% GGBFS")),paste0(" - ",sv," MPa")),
                        tags$table(class="table table-condensed",style="font-size:12px;margin:0;",tags$tbody(
                          tags$tr(tags$td("Cement"),         tags$td(tags$b(r$cement),        " kg")),
                          tags$tr(tags$td("Slag (GGBFS)"),   tags$td(tags$b(r$slag),          " kg")),
                          tags$tr(tags$td("Water"),          tags$td(tags$b(r$water),          " kg")),
                          tags$tr(tags$td("Crushed Coarse"), tags$td(tags$b(r$crushed_coarse), " kg")),
                          tags$tr(tags$td("Nat. Coarse"),    tags$td(tags$b(r$nat_coarse),     " kg")),
                          tags$tr(tags$td("Crushed Fine"),   tags$td(tags$b(r$crushed_fine),   " kg")),
                          tags$tr(tags$td("Nat. Fine"),      tags$td(tags$b(r$nat_fine),       " kg")),
                          tags$tr(tags$td("Air Entrainer"),  tags$td(tags$b(r$air_ent),        " kg")),
                          tags$tr(tags$td("Water Reducer"),  tags$td(tags$b(r$water_red),      " kg")),
                          tags$tr(tags$td("HW Reducer"),     tags$td(tags$b(r$hw_red),         " kg")),
                          tags$tr(tags$td("Accelerator"),    tags$td(tags$b(r$acc_adm),        " kg"))
                        ))
      ))
    })
    do.call(fluidRow,cards)
  })
  output$slag_mix_table <- DT::renderDataTable({
    df <- slag_mix_df(); df$pct_slag <- paste0(df$pct_slag,"%")
    colnames(df) <- c("Strength","GGBFS Repl","Cement","Slag GGBFS","Water","Crushed Coarse",
                      "Nat Coarse","Crushed Fine","Nat Fine","Air Ent","Water Red","HW Red","Accel")
    DT::datatable(df,options=list(pageLength=10L,scrollX=TRUE,dom="lrtip"),rownames=FALSE,
                  class="cell-border stripe hover") %>%
      DT::formatStyle("GGBFS Repl",backgroundColor=DT::styleEqual(
        c("0%","30%","40%","50%"),c("#d0eaff","#d4f0db","#fff3cd","#fde8e8")))
  })
  
  # SLAG LCIA absolute — FACET PLOT
  slag_lcia_df <- reactive({
    sv <- as.numeric(req(input$slag_strength)); ctry <- req(input$slag_country)
    df <- read_slag_lcia(ctry)
    validate(need(!is.null(df)&&nrow(df)>0,"Slag LCIA data not available."))
    r <- df[abs(df$Strength_MPa-sv)<0.5,]
    validate(need(nrow(r)>0,paste0("No data for ",sv," MPa.")))
    r
  })
  
  output$slag_lcia_facet <- renderPlotly({
    df  <- slag_lcia_df()
    sv  <- input$slag_strength
    ic  <- colnames(df)[3:ncol(df)]
    long <- do.call(rbind, lapply(seq_len(nrow(df)), function(i) {
      row <- df[i,]
      pct <- row$GGBFS_Pct * 100
      data.frame(
        GGBFS_Pct = as.character(pct),
        Impact    = ic,
        ImpLabel  = unname(ifelse(is.na(IMPACT_SHORT_LABEL[ic]),ic,IMPACT_SHORT_LABEL[ic])),
        Value     = as.numeric(row[3:ncol(row)]),
        stringsAsFactors=FALSE
      )
    }))
    long$GGBFS_Pct <- factor(long$GGBFS_Pct, levels=c("0","30","40","50"))
    bar_pal <- c("0"="#1e3a5f","30"="#27ae60","40"="#f39c12","50"="#e74c3c")
    impact_list <- unique(long$ImpLabel)
    
    plots_list <- lapply(impact_list, function(imp) {
      sub <- long[long$ImpLabel==imp,]
      plot_ly(sub, x=~GGBFS_Pct, y=~Value, color=~GGBFS_Pct, colors=bar_pal,
              type="bar", showlegend=(imp==impact_list[1]),
              hovertemplate=paste0("<b>",imp,"</b><br>GGBFS: %{x}%<br>Value: %{y:.4g}<extra></extra>"),
              legendgroup=~GGBFS_Pct
      ) %>%
        layout(xaxis=list(title="GGBFS %",tickfont=list(size=9)),
               yaxis=list(title=sub(".*\n","",imp),tickfont=list(size=8)),
               annotations=list(list(text=paste0("<b>",gsub("\n","<br>",imp),"</b>"),
                                     x=0.5,y=1.08,xref="paper",yref="paper",
                                     showarrow=FALSE,font=list(size=10),align="center")))
    })
    
    subplot(plots_list, nrows=3, shareX=FALSE, shareY=FALSE,
            titleX=TRUE, titleY=TRUE, margin=0.06) %>%
      layout(
        title=list(text=paste0("<b>LCIA – ",sv," MPa | Slag Origin: ",input$slag_country,"</b>"),
                   font=list(size=13), x=0.5),
        plot_bgcolor="#f9fafc", paper_bgcolor="#f9fafc",
        legend=list(title=list(text="<b>GGBFS %</b>"),orientation="h",
                    x=0.5,xanchor="center",y=-0.05),
        margin=list(t=60,b=60,l=60,r=20)
      )
  })
  
  output$slag_lcia_table <- DT::renderDataTable({
    df <- slag_lcia_df()
    ic <- colnames(df)[3:ncol(df)]
    nice <- unname(IMPACT_SHORT_LABEL[ic]); nice[is.na(nice)] <- ic[is.na(nice)]
    out <- df; out$GGBFS_Pct <- paste0(out$GGBFS_Pct*100,"%")
    colnames(out) <- c("Strength (MPa)","GGBFS Repl",nice)
    DT::datatable(out,options=list(pageLength=10L,scrollX=TRUE,dom="lrtip"),rownames=FALSE,
                  class="cell-border stripe hover") %>%
      DT::formatSignif(columns=seq(3L,ncol(out)),digits=4L)
  })
  
  # SLAG % change — ggplot2 FACET PLOT (all strengths)
  slag_pct_full_df <- reactive({
    ctry <- req(input$slag_country)
    df <- read_slag_pct_full(ctry)
    validate(need(!is.null(df)&&nrow(df)>0,"Slag percent-change data not available."))
    df$GGBFS_Pct <- as.character(df$GGBFS_Pct)
    df
  })
  
  output$slag_pct_chart <- renderPlot({
    df   <- slag_pct_full_df()
    ctry <- input$slag_country
    make_slag_pct_facet(df,
                        title_txt    = paste0("% Change vs Baseline — Slag GGBFS | Origin: ",ctry),
                        subtitle_txt = "All Compressive Strengths | GGBFS 30%, 40%, 50%"
    )
  }, res=110)
  
  output$slag_pct_table <- DT::renderDataTable({
    df <- slag_pct_full_df()
    out <- data.frame("Strength"=df$str_num,"GGBFS%"=df$GGBFS_Pct,
                      "Impact"=df$Impact_Display,"Value"=round(df$Value,6),
                      "Baseline"=round(df$Baseline,6),"Pct Change"=round(df$Pct_Change,2),
                      check.names=FALSE,stringsAsFactors=FALSE)
    DT::datatable(out,options=list(pageLength=15L,scrollX=TRUE,dom="lrtip"),rownames=FALSE,
                  class="cell-border stripe hover") %>%
      DT::formatStyle("Pct Change",color=DT::styleInterval(0,c("#27ae60","#e74c3c")),fontWeight="bold")
  })
  
  # COMPARISON — fixed x-axis cut-off
  output$compare_plot <- renderPlotly({
    sv <- as.numeric(req(input$cmp_strength)); ic <- req(input$cmp_impact)
    short_key <- names(IMPACT_SHORT_TO_LONG)[IMPACT_SHORT_TO_LONG==ic]
    validate(need(length(short_key)>0,"Impact category not found."))
    credited <- input$cmp_credit=="credit"
    dlbl <- gsub("\n"," ",IMPACT_DISPLAY[ic]); if(is.na(dlbl)) dlbl <- ic
    
    rows_list <- list()
    for (sh in FA_SHEETS) {
      df <- tryCatch(read_fa_lcia(sh$id,credited),error=function(e)NULL)
      if(is.null(df)) next
      df <- df[abs(df$Strength_MPa-sv)<0.5,]
      if(nrow(df)==0||!short_key%in%colnames(df)) next
      for(i in seq_len(nrow(df))) rows_list[[length(rows_list)+1]] <- data.frame(
        Label=sh$label, Repl=paste0(df$FA_Pct[i]*100,"%"),
        Value=as.numeric(df[i,short_key]), Tech=sh$tech, stringsAsFactors=FALSE)
    }
    for (ctry in c("USA","BRAZIL","CHINA","JAPAN")) {
      df <- tryCatch(read_slag_lcia(ctry),error=function(e)NULL)
      if(is.null(df)) next
      df <- df[abs(df$Strength_MPa-sv)<0.5,]
      if(nrow(df)==0||!short_key%in%colnames(df)) next
      for(i in seq_len(nrow(df))) rows_list[[length(rows_list)+1]] <- data.frame(
        Label=paste0("Slag-",ctry), Repl=paste0(df$GGBFS_Pct[i]*100,"%"),
        Value=as.numeric(df[i,short_key]), Tech="SLAG", stringsAsFactors=FALSE)
    }
    validate(need(length(rows_list)>0,"No comparison data available."))
    all_data <- do.call(rbind,rows_list); all_data <- all_data[!is.na(all_data$Value),]
    
    # Truncate long labels for display, keep full label in hover
    all_data$LabelShort <- gsub("^(Fresh Ash|Landfill|Impoundment) - ","",all_data$Label)
    all_data$LabelShort <- gsub("Electrostatic \\(ET\\)","ET",all_data$LabelShort)
    all_data$LabelShort <- gsub("Thermal \\(TT\\)","TT",all_data$LabelShort)
    all_data$LabelShort <- gsub("Chemical \\(CHEM\\)","CHEM",all_data$LabelShort)
    all_data$LabelShort <- paste0(all_data$LabelShort,"\n[",sub("-.*","",all_data$Label),"]")
    
    cmap <- c("ET"="#2980b9","TT"="#e67e22","CHEM"="#8e44ad","SLAG"="#27ae60")
    plot_ly(all_data, x=~LabelShort, y=~Value, color=~Tech, colors=cmap,
            symbol=~Repl, type="scatter", mode="markers",
            marker=list(size=12,opacity=0.85,line=list(width=1,color="white")),
            text=~paste0("<b>",Label,"</b><br>Replacement: ",Repl,"<br>Value: ",
                         formatC(Value,format="g",digits=5)),
            hoverinfo="text"
    ) %>%
      layout(
        title=list(text=paste0("<b>",dlbl," | ",sv," MPa | All Scenarios</b>"),font=list(size=14),x=0.5),
        xaxis=list(title="", tickangle=-50, tickfont=list(size=8.5),
                   automargin=TRUE),  # KEY FIX: automargin prevents label clipping
        yaxis=list(title=paste0(dlbl," (",ic,")"), tickfont=list(size=10)),
        legend=list(title=list(text="<b>Technology</b>"),orientation="h",
                    x=0.5,xanchor="center",y=-0.25),
        plot_bgcolor="#f9fafc", paper_bgcolor="#f9fafc",
        margin=list(t=60,b=180,l=80,r=20)   # large bottom margin for rotated labels
      )
  })
}

shinyApp(ui, server)
