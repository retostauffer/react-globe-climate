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

par(mfrow = c(2, 1))
plot(data$t2m_monthlymean)
barplot(data$t2m_anomaly, col = clr)




