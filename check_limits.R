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
# ----------------------------------------------------------------


# Helper function to read and extract data
get_limits <- function(x) {
    stopifnot(length(x) == 1L, is.character(x), file.exists(x))
    tmpdir <- tempdir()
    on.exit(unlink(tmpdir))

    require("stars")

    # Unzippint file
    files <- unzip(x, exdir = tmpdir)
    bfile <- basename(files)
    varname <- regmatches(bfile, regexpr("(?<=(ea_))[0-9a-z]+", bfile, perl = TRUE))
    yearmon <- regmatches(bfile, regexpr("[0-9]{6}", bfile))
    year    <- as.integer(substr(yearmon, 0, 4))
    month   <- as.integer(substr(yearmon, 5, 7))
    ref     <- regmatches(bfile, regexpr("[0-9]{4}-[0-9]{4}", bfile))

    res <- data.frame(file = files, variable = varname,
                      year = year, month = month, reference = ref,
                      min  = NA, max = NA)

    for (i in seq_len(nrow(res))) {
        tmp <- read_stars(res$file[i])
        tmp <- range(tmp[[1]], na.rm = TRUE)
        res$min[i] <- tmp[1]
        res$max[i] <- tmp[2]
    }
    return(res)
}
###res <- get_limits(zipfiles[1])

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
# Limits for 2t
# --------------------------------------------------
t2m <- subset(all_limits, variable == "2t")
t2m_limits <- ceiling(max(abs(c(min(t2m$min), max(t2m$max))))) * c(-1, 1)
t2m_colors <- hcl.colors(15, "Blue-Red")
fn <- function(n, pow = 1.5, lo = 0, hi = 1) {
    stopifnot(n %% 2 == 1L) # Must be an odd number
    #res <- seq(-1, 1, length.out = n + 1)
    #res <- (abs(res)^pow * sign(res) + 1) / 2
    return(round(lo + res * abs(hi - lo), digits = 2))
}
t2m_breaks <- fn(length(t2m_colors), pow = 2, min(t2m_limits), max(t2m_limits))

generate_background_xml <- function(colors, breaks, name, default_col = "yellow") {
    stopifnot(length(colors) + 1 == length(breaks))
    library("xml2")
    map <- read_xml("<Map srs=\"+init=epsg:3857\"></Map>")
    rule <- xml_add_child(xml_add_child(map, "Style", name = name), "Rule")
    symbolizer <- xml_add_child(rule, "RasterSymbolizer", opacity = "1", scaling = "bilinear", mode = "normal")
    colorizer  <- xml_add_child(symbolizer, "RasterColorizer", "default-mode" = "discrete", "default-color" = default_col)
    for (i in seq_along(colors)) {
        xml_add_child(colorizer, "stop", color = colors[i], value = format(breaks[i]))
    }
    xml_add_child(colorizer, "stop", color = default_col, value = format(breaks[i+1]))

    layer <- xml_add_child(map, "Layer", name = name, srs = "+init=epsg:3857")
    xml_set_text(xml_add_child(layer, "StyleName"), name)
    dsource <- xml_add_child(layer, "Datasource")

    param <- c(type = "gdal", file = "data.tiff", band = "1")
    for (i in seq_along(param)) xml_set_text(xml_add_child(dsource, "Parameter", name = names(param)[i]), param[i])
    return(map)
}
map <- generate_background_xml(t2m_colors, t2m_breaks, "temperature")
write_xml(map, "mapnik/background_2t.xml")






