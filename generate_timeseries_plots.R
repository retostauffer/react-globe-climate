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

SQLITEDB <- "_data/interpolated.sqlite3"
con <- dbConnect(SQLite(), SQLITEDB)

get_locations <- function(con) {
    stopifnot(inherits(con, "SQLiteConnection"))
    res <- dbSendQuery(con, "SELECT * FROM locations")
    data <- fetch(res); dbClearResult(res)
    print(head(data))
    return(data)
}

locations <- get_locations(con)

get_data <- function(ID, con, what = c("anomaly", "monthlymean")) {
    require("RSQLite")
    require("zoo")

    stopifnot(is.numeric(ID), length(ID) == 1)
    stopifnot(inherits(con, "SQLiteConnection"))
    what <- match.arg(what)

    # Getting data
    SQL <- sprintf("SELECT * FROM %s WHERE station_ID = %d", what, ID)
    res <- dbSendQuery(con, SQL)
    data <- fetch(res); dbClearResult(res)

    # Renaming some things ...
    renaming <- c("2t" = "t2m")
    for (i in names(renaming)) data$param[data$param == i] <- renaming[[i]]
    data <- transform(data, yearmon = as.yearmon(sprintf("%06d", yearmon), format = "%Y%m"), station_ID = NULL)
    data <- as.data.frame(pivot_wider(data, names_from = "param", values_from = "value"))
    data <- zoo(subset(data, select = -yearmon), data$yearmon)
    names(data) <- paste(names(data), what, sep = "_")
    return(data)
}
dim(tmp1 <- get_data(1, con, "anomaly"))
dim(tmp2 <- get_data(1, con, "monthlymean"))
data <- merge(tmp1, tmp2)
data <- data[, sort(names(data))]
data <- transform(data, t2m_monthlymean = t2m_monthlymean - 273.15)

class(data) <- c("era5_anom", class(data))
#data$month <- as.integer(format(index(data), "%m"))
#tab <- table(as.integer(format(seq(as.Date("2022-01-01"), as.Date("2022-12-31"), by = 1L), "%m")))
#data$ndays <- as.integer(tab[match(as.character(data$month), names(tab))])


library("xml2")
doc <- read_xml("mapnik/background_2t.xml")
nodes <- xml_find_all(doc, ".//RasterColorizer/stop")
stop_col <- xml_attr(nodes, "color")
stop_val <- as.numeric(xml_attr(nodes, "value"))
(stops <- data.frame(col = stop_col, val = stop_val))
clr <- as.character(cut(data$t2m_anomaly, breaks = c(-Inf, stops$val), stops$col))
clr

cmap <- data.frame(color = stop_col, stop = stop_val)
cmap


# Adding annual mean
add_annual_mean <- function(xa, cmap, type = c("r", "p"), ..., pch = 19, cex = 2) {
    type <- match.arg(type)
    annual <- aggregate(xa, format(index(xa), "%Y"), mean)
    annual_color <- as.character(cut(annual, breaks = cmap$stop, label = tail(cmap$color, -1), include.lowest = TRUE))
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

plot.era5_anom <- function(x, what, mcol, acol, main, mlab, alab, cmap, cmap2 = gray.colors(10), ..., ref = yearmon(c(1991, 2021))) {

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

    par(bg = "black", fg = "white", col.axis = mcol, mar = c(3.1, 4.5, 2, 4.5))
    plot(NA, xlim = xlim, ylim = m_ylim, yaxt = "n")
    axis(side = 2, at = pretty(xm), col = mcol)
    mtext(side = 2, line = 3, mlab, col = mcol, at = mean(xm, na.rm = TRUE))

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
    reto <<- add_annual_mean(xa, cmap)

    # Adding monthly anomalies
    lines(xa, col = acol)
    mtext(side = 4, alab, line = 2.5, col = acol, at = 0)
}
plot(data, "t2m", "tomato", "white", cmap,
     main = "Lufttemperatur", mlab = "Durchschnittstemperatur [Grad C]", alab = "Anomalie [Grad C]",
     cmap2 = diverging_hcl(11, "Blue-Red 2"))

reto
dev.print(file = "~/Downloads/test_t2m.jpg", width = 1000, dev = jpeg)

xm




