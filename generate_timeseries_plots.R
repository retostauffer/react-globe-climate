# ------------------------------------------------------------
# Uses the SQLite3 database created by generate_timeseries_db
# to visualize time series graphs for a series of locations.
# ------------------------------------------------------------

library("zoo")
library("RSQLite")
library("sf")
library("tidyr")

rm(list = objects())

Sys.setlocale("LC_TIME", "C")

source("generate_timeseries_plots_functions.R")

SVGDIR = "_timeseries"
if (!dir.exists(SVGDIR)) dir.create(SVGDIR)

# ------------------------------------------------------------
# Loading locations
# ------------------------------------------------------------
SQLITEDB <- "_data/interpolated.sqlite3"
con <- dbConnect(SQLite(), SQLITEDB)
locations <- get_locations(con)

# ------------------------------------------------------------
# Loading data from database; monthly mean values alongside
# with monthly anomalies (ref is always 1991-2020
# ------------------------------------------------------------
for (station_ID in locations$ID) {

    station_info <- as.list(subset(locations, ID == station_ID))
    station_info$hash <- paste(station_info$name, station_info$country, sep = "_")
    cat("Processing", station_info$hash, "\n")

    data <- get_data(station_info$ID, con)
    if (is.null(dim(data))) {
        cat("         [!] NO DATA\n")
        next
    }
    data <- transform(data, t2m_monthlymean = t2m_monthlymean - 273.15)


    data$year  <- as.integer(format(index(data), "%Y"))
    data$month <- as.integer(format(index(data), "%m"))
    data$ndays <- sapply(index(data), get_ndays)

    class(data) <- c("era5_anom", class(data))


    # ------------------------------------------------------------
    # Loading color-coding from the XML files used by mapnik
    # ------------------------------------------------------------
    (cmap_2t    <- get_mapnik_colorcoding("mapnik/background_2t.xml"))
    (cmap_tp    <- get_mapnik_colorcoding("mapnik/background_tp.xml"))
    (cmap_swvl1 <- get_mapnik_colorcoding("mapnik/background_swvl1.xml"))

    #color_2t    <- as.character(cut(data$t2m_anomaly, breaks = c(-Inf, cmap_2t$stop), cmap_2t$color))
    #color_tp    <- as.character(cut(data$tp_anomaly,  breaks = c(-Inf, cmap_tp$stop), cmap_tp$color))
    #color_swvl1 <- as.character(cut(data$swvl1_anomaly, breaks = c(-Inf, cmap_swvl1$stop), cmap_swvl1$color))

    # ------------------------------------------------------------
    # ------------------------------------------------------------
    svg(file.path(SVGDIR, sprintf("2t_%s.svg", station_info$hash)), width = 16, height = 8)
        plot(data, "t2m", "tomato", "white", cmap_2t,
             main = "Lufttemperatur",
             main2 = paste(station_info$name, station_info$country, sep = ", "),
             mlab = "Durchschnittstemperatur [Grad C]", alab = "Anomalie [Grad C]",
             cmap2 = diverging_hcl(11, "Blue-Red 2"))
    dev.off()

    svg(file.path(SVGDIR, sprintf("tp_%s.svg", station_info$hash)), width = 16, height = 8)
        plot(data, "tp", "steelblue", "white", cmap_tp,
             main = "Niederschlag",
             main2 = paste(station_info$name, station_info$country, sep = ", "),
             mlab = "Mittlerer Niederschlag [mm/Tag]", alab = "Anomalie [mm/Tag]",
             cmap2 = tail(cmap_tp$color, -1))
    dev.off()

    svg(file.path(SVGDIR, sprintf("swvl1_%s.svg", station_info$hash)), width = 16, height = 8)
        plot(data, "swvl1", "orange", "white", cmap_swvl1,
             main = "Bodenwassergehalt (0-7cm)",
             main2 = paste(station_info$name, station_info$country, sep = ", "),
             mlab = "Mittlerer Wassergehalt [m^3/m^3]", alab = "Anomalie [m^3/m^3]",
             cmap2 = tail(cmap_swvl1$color, -1))
    dev.off()

}














