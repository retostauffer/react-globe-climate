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

    doc      <- read_xml("mapnik/background_2t.xml")
    nodes    <- xml_find_all(doc, ".//RasterColorizer/stop")
    stop_col <- xml_attr(nodes, "color")
    stop_val <- as.numeric(xml_attr(nodes, "value"))
    stops    <- data.frame(col = stop_col, val = stop_val)
    data.frame(color = stop_col, stop = stop_val)
}
