# --------------------------------------------------------------
# Generates the dataset for the time series plots.
# I interpolate all the points of interest and put the
# data into an sqlite3 data set (within DATADIR).
# --------------------------------------------------------------


library("RSQLite")
library("xml2")
library("stars")
library("sf")

# Some configs
DATADIR <- "_data"
SQLITEDB <- file.path(DATADIR, "interpolated.sqlite3")

# Find available zip files
zipfiles    <- list.files(DATADIR)
zip_anomaly <- zipfiles[grepl("^[0-9]{4}_anomalies\\.zip$", zipfiles)]
zip_mean    <- zipfiles[grepl("^[0-9]{4}_monthlymean\\.zip$", zipfiles)]
cat("ZIPs found    anomalies:", length(zip_anomaly),
              "    monthly mean:", length(zip_mean), "\n")



# Loading location data
get_locations <- function(file = "frontend/locations.xml") {
    stopifnot(is.character(file), length(file) == 1L, file.exists(file))
    require("sf")
    doc <- read_xml(file)
    name    <- xml_text(xml_find_all(doc, "city/name"))
    country <- xml_text(xml_find_all(doc, "city/country"))
    lon     <- as.numeric(xml_text(xml_find_all(doc, "city/lon")))
    lat     <- as.numeric(xml_text(xml_find_all(doc, "city/lat")))
    res     <- st_as_sf(data.frame(name = name, country = country, lon = lon, lat = lat, lon2 = lon, lat2 = lat),
                        coords = c("lon2", "lat2"), crs = 4326)
}
(locations <- get_locations())


get_connection <- function(x, locations) {
    require("RSQLite")
    con <- dbConnect(SQLite(), x)
    if (!dbExistsTable(con, "locations")) {
        SQL1 <- "CREATE TABLE locations (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            country TEXT NOT NULL,
            lon REAL NOT NULL,
            lat REAL NOT NULL,
            UNIQUE (lon, lat)
        )
        "
        cat(SQL1, "\n\n")
        dbExecute(con, SQL1)
        SQL2 <- "INSERT INTO locations (name, country, lon, lat)
                 VALUES ($name, $country, $lon, $lat)"
        dbExecute(con, SQL2, subset(as.data.frame(locations), select = c(name, country, lon, lat)))
    }
    if (!dbExistsTable(con, "anomaly")) {
        SQL <- "CREATE TABLE anomaly (
            station_ID INTEGER NOT NULL,
            yearmon INTEGER NOT NULL,
            param TEXT NOT NULL,
            value REAL NOT NULL,
            UNIQUE (station_ID, yearmon, param)
        )
        "
        cat(SQL, "\n\n")
        dbExecute(con, SQL)
    }
    if (!dbExistsTable(con, "monthlymean")) {
        SQL <- "CREATE TABLE monthlymean (
            station_ID INTEGER NOT NULL,
            yearmon INTEGER NOT NULL,
            param TEXT NOT NULL,
            value REAL NOT NULL,
            UNIQUE (station_ID, yearmon, param)
        )
        "
        cat(SQL, "\n\n")
        dbExecute(con, SQL)
    }
    return(con)
}
file.remove(SQLITEDB)
con <- get_connection(SQLITEDB, locations)
##print(head(fetch(dbSendQuery(con, "select * from locations"))))


# Testing ....
get_files <- function(dir, zipfile, type) {
    stopifnot(is.character(dir), length(dir) == 1, dir.exists(dir))
    stopifnot(is.character(zipfile), length(zipfile) == 1, file.exists(file.path(dir, zipfile)))
    type <- match.arg(type, c("anomaly", "monthlymean"))

    # Unpacking the ZIP
    tmpdir <- tempdir()
    files  <- unzip(file.path(DATADIR, zipfile), exdir = tmpdir)
    print(files)

    param <- regmatches(files, regexpr("(?<=(ea_)).*?(?=_)", files, perl = TRUE))
    yearmon <- as.integer(regmatches(files, regexpr("(?<=_)[0-9]{6}(?=_)", files, perl = TRUE)))
    inv <- data.frame(zip = zipfile, file = files, type = type, param = param, yearmon = yearmon)
    return(inv)
}
interpolate_data <- function(x, con, what, bilinear = TRUE) {
    stopifnot(is.data.frame(x), nrow(x) == 1L)
    stopifnot(all(c("file", "yearmon", "param", "type") %in% names(x)))
    stopifnot(inherits(con, "SQLiteConnection"))
    stopifnot(isTRUE(bilinear) | isFALSE(bilinear))

    locations <- fetch(res <- dbSendQuery(con, "SELECT * FROM locations"))
    dbClearResult(res)
    locations <- st_as_sf(locations, coords = c("lon", "lat"), crs = 4326)

    suppressWarnings(tmp <- read_stars(x$file, band = 1))
    suppressWarnings(res <- st_extract(tmp, st_transform(locations, crs = st_crs(tmp)), bilinear = bilinear))
    names(res)[grepl("^1month", names(res))] <- "value"
    res <- na.omit(transform(st_drop_geometry(res), station_ID = locations$ID))
    SQL <- sprintf("INSERT OR IGNORE INTO %s (station_ID, yearmon, param, value) VALUES ($station_ID, %d, \"%s\", $value)",
                   x$type, x$yearmon, x$param)
    print(dim(res))
    print(SQL)
    dbExecute(con, SQL, res)
    return(res)
}

for (zipfile in zip_anomaly) {
    cat("Interpolating", zipfile, "\n")
    inv <- get_files(DATADIR, zipfile, "anomaly")
    tmp <- lapply(seq_len(nrow(inv)), function(i) interpolate_data(inv[i, ], con))
}

for (zipfile in zip_mean) {
    cat("Interpolating", zipfile, "\n")
    inv <- get_files(DATADIR, zipfile, "monthlymean")
    tmp <- lapply(seq_len(nrow(inv)), function(i) interpolate_data(inv[i, ], con))
}
















