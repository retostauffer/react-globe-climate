# ----------------------------------------------------------------
# checking limits needed for the visualization
# via mapnik.
# 
# 1. Find all zip files downloaded via CDS (these are the montly
#    anomalies of the (local) daily agricultural ERA5 data sets)
#    in _data
# 2. Extract on the fly; search for variables; read grib files
#    via stars and keep the limits alongside with month/year
#    for further analysis.
# 3. Generates the background_*.xml files for mapnik used to 
#    visualize the data.
# ----------------------------------------------------------------


# Contains a series of R functions to do this job
source("generate_mapnik_functions.R")


# --------------------------------------------------
# Getting limits; will be cached in an RDS file
# as it takes a few minutes.
# --------------------------------------------------
# Getting limits
rdsfile <- "all_limits.rds"
if (file.exists(rdsfile)) {
    cat("Using prepared file", rdsfile, "to calculate the limits/generate the xml files\n")
    all_limits <- readRDS(rdsfile)
} else {
    cat("Need to read all files to calculate limits required to generate the xml files\n")
    # Find all (required) zip files
    DATADIR = "_data"
    zipfiles <- list.files(DATADIR, full.names = TRUE)
    zipfiles <- zipfiles[grepl("[0-9]{4}_all.zip$", zipfiles)]
    cat("Found", length(zipfiles), "files to read\n")
    all_limits <- list()
    for (z in zipfiles) {
        all_limits[[z]] <- get_limits(z)
    }
    all_limits <- do.call(rbind, all_limits)
    saveRDS(all_limits, rdsfile)
}


# --------------------------------------------------
# Generate XML file for temperature / 2t
# --------------------------------------------------
t2m <- subset(all_limits, variable == "2t")
t2m_limits <- ceiling(max(abs(c(min(t2m$min), max(t2m$max))))) * c(-1, 1)
t2m_colors <- hcl.colors(15, "Blue-Red")
fn <- function(n, pow = 1.5, lo = 0, hi = 1) {
    stopifnot(n %% 2 == 1L) # Must be an odd number
    res <- seq(-1, 1, length.out = n + 1)
    res <- (abs(res)^pow * sign(res) + 1) / 2
    return(round(lo + res * abs(hi - lo), digits = 2))
}
###fn(3, pow = 1, -1.5, 1.5) # test
t2m_breaks <- fn(length(t2m_colors), pow = 2, min(t2m_limits), max(t2m_limits))
map <- generate_background_xml(t2m_colors, t2m_breaks, "temperature")
write_xml(map, "mapnik/background_2t.xml")


# --------------------------------------------------
# Generate XML file for total precipitation / tp
# --------------------------------------------------
tp <- subset(all_limits, variable == "tp")
tp_limits <- max(c(min(tp$min), max(tp$max))) * c(-1.01, 1.01)
tp_colors <- hcl.colors(15, "Earth", rev = TRUE)
fn <- function(n, pow = 1.5, lo = 0, hi = 1) {
    stopifnot(n %% 2 == 1L) # Must be an odd number
    res <- seq(-1, 1, length.out = n + 1)
    res <- (abs(res)^pow * sign(res) + 1) / 2
    return(round(lo + res * abs(hi - lo), digits = 4))
}
###fn(3, pow = 1, -1.5, 1.5) # test
tp_breaks <- fn(length(tp_colors), pow = 3, min(tp_limits), max(tp_limits))
plot(tp_breaks[-1], pch = 19, cex = 3, col = tp_colors)
map <- generate_background_xml(tp_colors, tp_breaks, "total_precipitation")
write_xml(map, "mapnik/background_tp.xml")


# --------------------------------------------------
# Generate XML file for total precipitation / tp
# --------------------------------------------------
ci <- subset(all_limits, variable == "ci")
ci_limits <- c(-1, 1)
ci_colors <- hcl.colors(15, "PuOr")
fn <- function(n, pow = 1.5, lo = 0, hi = 1) {
    stopifnot(n %% 2 == 1L) # Must be an odd number
    res <- seq(-1, 1, length.out = n + 1)
    res <- (abs(res)^pow * sign(res) + 1) / 2
    return(round(lo + res * abs(hi - lo), digits = 4))
}
###fn(3, pow = 1, -1.5, 1.5) # test
ci_breaks <- fn(length(ci_colors), pow = 2, min(ci_limits), max(ci_limits))
plot(ci_breaks[-1], pch = 19, cex = 3, col = ci_colors)
map <- generate_background_xml(ci_colors, ci_breaks, "sea_ice_fraction")
write_xml(map, "mapnik/background_ci.xml")


# --------------------------------------------------
# Generate XML file for Volumetric soil water layer 1 (m^3/m^3) / swvl1
# where layer 1 is
# --------------------------------------------------
swvl1 <- subset(all_limits, variable == "swvl1")
swvl1_limits <- max(c(min(swvl1$min), max(swvl1$max))) * c(-1.01, 1.01)
swvl1_limits <- range(pretty(max(c(min(swvl1$min), max(swvl1$max))) * c(-1.01, 1.01)))
swvl1_colors <- hcl.colors(15, "Zissou 1", rev = TRUE)
fn <- function(n, pow = 1.5, lo = 0, hi = 1) {
    stopifnot(n %% 2 == 1L) # Must be an odd number
    res <- seq(-1, 1, length.out = n + 1)
    res <- (abs(res)^pow * sign(res) + 1) / 2
    return(round(lo + res * abs(hi - lo), digits = 4))
}
###fn(3, pow = 1, -1.5, 1.5) # test
swvl1_breaks <- fn(length(swvl1_colors), pow = 1.7, min(swvl1_limits), max(swvl1_limits))
plot(swvl1_breaks[-1], pch = 19, cex = 3, col = swvl1_colors)
map <- generate_background_xml(swvl1_colors, swvl1_breaks, "volumetric_soil_water")
write_xml(map, "mapnik/background_swvl1.xml")








