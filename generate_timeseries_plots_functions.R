# ----------------------------------------------
# Helper functions for the plotting.
# Package? No, no time :).
# ----------------------------------------------


#' Getting locations
#'
#' @param con SQLite connection
#'
#' @return location data (name, country, lon, lat) as
#' a data.frame.
get_locations <- function(con) {
    stopifnot(inherits(con, "SQLiteConnection"))
    res <- dbSendQuery(con, "SELECT * FROM locations")
    data <- fetch(res); dbClearResult(res)
    print(head(data))
    return(data)
}


#' Get Number of Days in Month
#'
#' Calculates the number of days in a month giben \code{yearmon}
#' object as input.
#'
#' @param x object of class \code{yearmon}, length 1.
#'
#' @return Integer, number of days in that specific month.
get_ndays <- function(x) {
    stopifnot(inherits(x, "yearmon"), length(x) == 1)
    bgn <- as.Date(x)
    bgn <- list(y = as.integer(format(x, "%Y")), m = as.integer(format(x, "%m")))
    end <- list(y = ifelse(bgn$m == 12, bgn$y + 1, bgn$y), m = ifelse(bgn$m == 12, 1, bgn$m + 1))
    bgn <- as.Date(sprintf("%04d-%02d-01", bgn$y, bgn$m))
    end <- as.Date(sprintf("%04d-%02d-01", end$y, end$m)) - 1
    length(seq(bgn, end, by = 1L))
}


#' Getting Data from Database
#'
#' @param con SQLite connection
#' @param ID single numeric (integer), station ID.
#'
#' @return Data.frame containing monthly anomalies
#' and the corresponding monthly mean values.
get_data <- function(ID, con) {
    require("RSQLite")
    require("zoo")
    require("tidyr")

    stopifnot(is.numeric(ID), length(ID) == 1)
    stopifnot(inherits(con, "SQLiteConnection"))

    # Getting data
    SQL  <- "SELECT * FROM %s WHERE station_ID = %d"
    SQL1 <- sprintf(SQL, "anomaly",     ID)
    a_res <- dbSendQuery(con, SQL1)
    a_data <- fetch(a_res); dbClearResult(a_res)
    SQL2 <- sprintf(SQL, "monthlymean", ID)
    m_res <- dbSendQuery(con, SQL2)
    m_data <- fetch(m_res); dbClearResult(m_res)

    # Renaming some things ...
    fn <- function(x, what, renaming = c("2t" = "t2m")) {
        for (i in names(renaming)) x$param[x$param == i] <- renaming[[i]]
        x <- transform(x, yearmon = as.yearmon(sprintf("%06d", yearmon), format = "%Y%m"), station_ID = NULL)
        x <- as.data.frame(pivot_wider(x, names_from = "param", values_from = "value"))
        x <- zoo(subset(x, select = -yearmon), x$yearmon)
        names(x) <- paste(names(x), what, sep = "_")
        return(x)
    }
    # Prepare data, merge and sort columns
    a_data <- fn(a_data, "anomaly"); m_data <- fn(m_data, "monthlymean")
    data <- merge(a_data, m_data)
    data <- data[, order(names(data))]

    return(data)
}


#' Loading Mapnik Colorcoding
#'
#' Mapnik uses a series of XML files I created containing the color palette; to
#' be more precise a series of colors and stopping points used to create the
#' maps.  To be able to use the same coding for the R plots we are reading this
#' information from the XML file.
#'
#' @param file character length 1, name of the XML file to read.
#'
#' @return Returns a data.frame with two columns \code{color} and \code{val}
#' which are the stopping values.
get_mapnik_colorcoding <- function(file) {
    require("xml2")
    stopifnot(is.character(file), length(file) == 1, file.exists(file))
    stopifnot(grepl("\\.xml$", file))

    doc      <- read_xml(file)
    nodes    <- xml_find_all(doc, ".//RasterColorizer/stop")
    stop_col <- xml_attr(nodes, "color")
    stop_val <- as.numeric(xml_attr(nodes, "value"))
    stops    <- data.frame(col = stop_col, val = stop_val)
    data.frame(color = stop_col, stop = stop_val)
}



# Adding annual mean
add_annual_mean <- function(xa, cmap, type = c("r", "p"), ..., pch = c(19, 4), cex = 2) {
    type <- match.arg(type)
    annual   <- aggregate(xa, format(index(xa), "%Y"), mean)
    annual_n <- aggregate(xa, format(index(xa), "%Y"), length)
    pch <- rep(pch, 2)
    annual_color <- as.character(cut(annual, breaks = cmap$stop, label = tail(cmap$color, -1), include.lowest = TRUE))
    reto <<- list(annual = annual, color =annual_color)
    if (type == "r") {
        for (i in seq_along(annual)) {
            tmp <- yearmon(as.integer(index(annual[i])))
            if (annual_n[i] == 12) {
                rect(tmp, 0, tmp + 1, annual[i], col = annual_color[i], border = NA)
            } else {
                rect(tmp, 0, tmp + 1, annual[i], border = annual_color[i])
            }
        }
    } else {
        pch <- ifelse(annual_n == 12, pch[1], pch[2])
        points(yearmon(as.integer(index(annual))) + 0.5, annual, col = annual_color, pch = pch, cex = cex)
    }
    invisible(data.frame(value = coredata(annual), index = index(annual), color = annual_color))
}

plot.era5_anom <- function(x, what, mcol, acol, main, main2, mlab, alab,
                           cmap, cmap2 = gray.colors(10), ...,
                           axcol = "gray90", ref = yearmon(c(1991, 2021)), add_15 = FALSE) {

    require("colorspace")

    # Check if we can find both variables; if not we draw 'No Data'
    if (!all(paste(what, c("monthlymean", "anomaly"), sep = "_") %in% names(x))) {
        hold <- par(no.readonly = TRUE); on.exit(par(hold))
        par(bg = "black", fg = "white")
        plot(NA, xlim = c(-1, 1), ylim = c(-1, 1), xaxt = "n", yaxt = "n", 
             xlab = NA, ylab = NA, bty = "n")
        text(0, 0, "No data available", col = "steelblue", cex = 3)
        return()
    }
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

    lines(xm, col = mcol, lwd = 2)

    # -------------------------------------------------
    # Adding anomalies
    par(new = TRUE)
    plot(NA, new = TRUE, xlim = xlim, ylim = a_ylim, col = 5, yaxt = "n")

    # Adding grid for anomalies
    for (iat in a_at) lines(xlim + c(0, 1) * diff(xlim), rep(iat, 2), col = "white", lty = 2)

    axis(side = 4, at = a_at, col.axis = acol)
    add_annual_mean(xa, cmap)

    # Adding monthly anomalies
    lines(xa, col = acol, lwd = 2)

    # Adding 1.5 degree mark for temperature
    if (add_15) lines(xlim + c(0, 1) * diff(xlim), rep(1.5, 2), lwd = 2, col = lighten("red", 0.3), lty = 3)

    mtext(side = 4, alab, line = 2.5, col = acol, at = 0)
}

