
#' Getting Limits from GRIB files
#'
#' The ERA5 data has been downloaded in a series of ZIP files
#' provided by the CDS. These ZIP files contain a bunch of GRIB version 1
#' files for different parameters.
#' This function extracts the ZIP (on the fly) and reads all GRIB files
#' via \code{\link[stars]{read_stars}}, extracts minimum/maximum to get
#' the required value limits.
#'
#' @param x character vector, name of the ZIP files.
#'
#' @return Returns a data.frame containing the limits and some information
#' about the GRIB verson 1 files and their dates (month) plus reference
#' period.
#'
#' @author Reto Stauffer
#' @export
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


#' Generate Background XML for Mapnik
#'
#' Used to generate the xml file used by mapnik (python script)
#' to generate the images. This XML file contains the rasterSymbolizer/RasterColorizer
#' config (what should be colorized how) and the layer configuration.
#'
#' @param colors vector of colors.
#' @param breaks vector of breaks. Must be one longer than \code{colors}, the break
#'        (used in \code{<stop />} defines the lower limit (where the color starts).
#' @param name character length \code{1}, name of the layer.
#' @param default_col length 1, name of the default color (for undefined areas). Defaults to \code{"yellow"}.
#' @param bg_col length 1, name of the background color (for poles). Defaults to dark gray.
#'
#' @return Returns an \code{xml_document}.
#'
#' @author Reto Stauffer
#' @export
generate_background_xml <- function(colors, breaks, name, default_col = "yellow", bg_col = "#666666") {
    stopifnot(length(colors) + 1 == length(breaks))
    stopifnot(length(name) == 1L, length(default_col) == 1L, length(bg_col) == 1)
    library("xml2")
    map <- read_xml(sprintf("<Map background-color=\"%s\" srs=\"+init=epsg:3857\"></Map>", bg_col))
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


