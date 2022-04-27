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
station_ID <- 1
station_info <- as.list(subset(locations, ID == station_ID))
station_info$hash <- paste(station_info$name, station_info$country, sep = "_")
data <- get_data(station_info$ID, con)
data <- transform(data, t2m_monthlymean = t2m_monthlymean - 273.15)
head(data)

class(data) <- c("era5_anom", class(data))


# ------------------------------------------------------------
# Loading color-coding from the XML files used by mapnik
# ------------------------------------------------------------
(cmap_2t <- get_mapnik_colorcoding("mapnik/background_2t.xml"))
(cmap_tp <- get_mapnik_colorcoding("mapnik/background_tp.xml"))

color_2t <- as.character(cut(data$t2m_anomaly, breaks = c(-Inf, cmap_2t$stop), cmap_2t$color))
color_tp <- as.character(cut(data$t2m_anomaly, breaks = c(-Inf, cmap_tp$stop), cmap_tp$color))
head(color_2t)
head(color_tp)



# ------------------------------------------------------------
# ------------------------------------------------------------

# Adding annual mean
add_annual_mean <- function(xa, cmap, type = c("r", "p"), ..., pch = 19, cex = 2) {
    type <- match.arg(type)
    annual <- aggregate(xa, format(index(xa), "%Y"), mean)
    annual_color <- as.character(cut(annual, breaks = cmap$stop, label = tail(cmap$color, -1), include.lowest = TRUE))
    reto <<- list(annual = annual, color =annual_color)
    if (type == "r") {
        for (i in seq_along(annual)) {
            tmp <- yearmon(as.integer(index(annual[i])))
            rect(tmp, 0, tmp + 1, annual[i], col = annual_color[i], border = NA)
        }
    } else {
        points(yearmon(as.integer(index(annual))) + 0.5, annual, col = annual_color, pch = pch, cex = cex)
    }
    invisible(data.frame(value = coredata(annual), index = index(annual), color = annual_color))
}

plot.era5_anom <- function(x, what, mcol, acol, main, main2, mlab, alab,
                           cmap, cmap2 = gray.colors(10), ...,
                           axcol = "gray90", ref = yearmon(c(1991, 2021))) {

    require("colorspace")

    # Check if we can find both variables
    stopifnot(all(paste(what, c("monthlymean", "anomaly"), sep = "_") %in% names(x)))
    stopifnot(is.data.frame(cmap), all(c("stop", "color") %in% names(cmap)))
    stopifnot(is.character(cmap$color), is.numeric(cmap$stop))
    stopifnot(is.character(cmap2))

    # Store data on xm and xa (x mean and x anomaly)
    xm <- data[, paste(what, "monthlymean", sep = "_")]
    xa <- data[, paste(what, "anomaly", sep = "_")]

    # Calculating cmap2 for monthly means
    tmp <- aggregate(xm, format(index(xm), "%Y"), mean)
    cmap2 <- data.frame(stop  = seq(min(tmp), max(tmp), length.out = length(cmap2)), color = cmap2)
    rm(tmp)


    # Setting up new plot
    hold <- par(no.readonly = TRUE); on.exit(par(hold))

    # X limits are the same for both
    xlim <- range(index(x))

    # Y limits differ
    m_ylim <- range(xm, na.rm = TRUE)
    m_ylim <- m_ylim + c(-1, 0) * diff(m_ylim)

    # Using this one later for y_limits
    a_ylim <- range(xa, na.rm = TRUE)
    a_at   <- pretty(a_ylim)
    a_ylim <- a_ylim + c(0, 0.9) * diff(a_ylim)

    par(bg = "black", fg = "white", col.axis = axcol, mar = c(3.1, 4.5, 2, 4.5))
    plot(NA, xlim = xlim, ylim = m_ylim, yaxt = "n")
    axis(side = 2, at = pretty(xm), col = axcol)
    mtext(side = 2, line = 3, mlab, col = mcol, at = mean(xm, na.rm = TRUE))
    mtext(side = 3, line = .3, main,  adj = 0, col = "white", font = 2, cex = 1.8)
    mtext(side = 3, line = .3, main2, adj = 1, col = "white", font = 1, cex = 1.8)

    # Adding reference
    rect(min(ref), m_ylim[1] - diff(m_ylim), max(ref), m_ylim[2] + diff(m_ylim),
         col = colorspace::adjust_transparency("white", .1), border = NA)
    add_annual_mean(xm, cmap2, type = "p")

    lines(xm, col = mcol)

    # -------------------------------------------------
    # Adding anomalies
    par(new = TRUE)
    plot(NA, new = TRUE, xlim = xlim, ylim = a_ylim, col = 5, yaxt = "n")

    # Adding grid for anomalies
    for (iat in a_at) lines(xlim + c(0, 1) * diff(xlim), rep(iat, 2), col = "white", lty = 2)

    axis(side = 4, at = a_at, col.axis = acol)
    add_annual_mean(xa, cmap)

    # Adding monthly anomalies
    lines(xa, col = acol)
    mtext(side = 4, alab, line = 2.5, col = acol, at = 0)
}


svg(file.path(SVGDIR, sprintf("2t_%s.svg", station_info$hash)), width = 16, height = 8)
    plot(data, "t2m", "tomato", "white", cmap_2t,
         main = "Lufttemperatur",
         main2 = paste(station_info$name, station_info$country, sep = ", "),
         mlab = "Durchschnittstemperatur [Grad C]", alab = "Anomalie [Grad C]",
         cmap2 = diverging_hcl(11, "Blue-Red 2"))
dev.off()




