
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
    xml_add_child(colorizer, "stop", color = default_col, value = format(breaks[1]))
    for (i in seq_along(colors)) {
        xml_add_child(colorizer, "stop", color = colors[i], value = format(breaks[i + 1]))
    }

    layer <- xml_add_child(map, "Layer", name = name, srs = "+init=epsg:3857")
    xml_set_text(xml_add_child(layer, "StyleName"), name)
    dsource <- xml_add_child(layer, "Datasource")

    param <- c(type = "gdal", file = "data.tiff", band = "1")
    for (i in seq_along(param)) xml_set_text(xml_add_child(dsource, "Parameter", name = names(param)[i]), param[i])
    return(map)
}


#' Create SVG Color Legend for Frontend
#'
#' @param bk numeric, breaks used to generate the XML file (breaks for the colors)
#' @param col vector of colors, length must be \code{length(bk) - 1}.
#' @param title character length 1, used to set the title.
#' @param ref character length 1 (reference), defaults to \code{"Referenzperiode: 1991-2020"}.
#' @param bg background color, length 1, defaults to black.
#' @param axcol color of the axis, length 1, defaults to white.
#'
#' @return Performs plotting, no return.
#'
#' @author Reto Stauffer
#' @export
draw_color_legend <- function(bk, col, title, ref = "Referenzperiode: 1991-2020", bg = "black", axcol = "white") {
    stopifnot(is.numeric(bk), length(bk) - 1 == length(col))
    stopifnot(is.character(title), length(title) == 1)
    stopifnot(is.character(ref), length(ref) == 1)
    stopifnot(length(bg) == 1)
    stopifnot(length(axcol) == 1)

    #hold <- par(no.readonly = TRUE); on.exit(par(hold))
    par(mar = c(1.5, 0.2, 1.5, 0.2), xaxs = "i", yaxs = "i", bty = "n", bg = bg)
    plot(NA, xlim = sort(range(bk)), ylim = c(0, 1),
         xaxt = "n", yaxt = "n", xlab = NA, ylab = NA)
    lines(c(0,1), c(0,1))
    offset <- diff(range(bk)) / 1000
    for (i in seq_along(col)) {
        rect(bk[i] - offset, 0, bk[i + 1] + offset, 1, col = col[i], border = NA)
    }
    axis(side = 1, line = -0.8, at = pretty(bk, 11), lwd = 0, col = "white", col.ticks = NA, col.axis = axcol)
    #axis(side = 1, at = pretty(bk, 11), col = axcol, col.ticks = axcol, col.axis = axcol)
    par(bty = "o"); box(lty = 1, lwd = 2, col = axcol)
    mtext(side = 3, line = 0.1, at = min(bk), adj = 0, title, col = axcol, cex = 1.2)
    mtext(side = 3, line = 0.1, at = max(bk), adj = 1, ref, col = "gray50", cex = 1.2)
}

draw_color_legend2 <- function(bk, col, title, digits = 2, ref = "Referenzperiode: 1991-2020", bg = "black", axcol = "white") {
    stopifnot(is.numeric(bk), length(bk) - 1 == length(col))
    stopifnot(is.character(title), length(title) == 1)
    stopifnot(is.character(ref), length(ref) == 1)
    stopifnot(length(bg) == 1)
    stopifnot(length(axcol) == 1)

    #par(mar = c(1.5, 0.2, 1.5, 0.2), xaxs = "i", yaxs = "i", bty = "n", bg = bg)
    par(mar = c(1.5, 1, 1.5, 1), xaxs = "i", yaxs = "i", bty = "n", bg = bg)
    plot(NA, xlim = c(0, 1), ylim = c(0, 1),
         xaxt = "n", yaxt = "n", xlab = NA, ylab = NA)
    lines(c(0,1), c(0,1))
    offset <- 1 / 1000
    xxx <- seq(0, 1, length.out = length(bk))
    for (i in seq_along(col)) {
        rect(xxx[i] - offset, 0, xxx[i + 1] + offset, 1, col = col[i], border = NA)
    }
    axis(side = 1, line = -0.8, at = xxx, labels = sprintf(paste("%.", digits, "f", sep = ""), bk),
         lwd = 0, col = "white", col.ticks = NA, col.axis = axcol)
    par(bty = "o"); box(lty = 1, lwd = 2, col = axcol)
    mtext(side = 3, line = 0.1, at = 0, adj = 0, title, col = axcol, cex = 1.2)
    mtext(side = 3, line = 0.1, at = 1, adj = 1, ref, col = "gray50", cex = 1.2)
}
