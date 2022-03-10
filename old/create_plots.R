# ------------------------------------------
# Just a quick test
# ------------------------------------------

rm(list = objects())

library("zoo")
library("stars")

files <- list.files("_data", full.name = TRUE)
files <- files[grepl("\\.grib$", files)]

# Extracting reference period year and variable name
get_file_info <- function(x) {
    var   <- regmatches(x, regexpr("(?<=(ea_)).*?(?=(_))", x, perl = TRUE))
    per   <- regmatches(x, regexpr("(?<=(_))[0-9]{4}-[0-9]{4}", x, perl = TRUE))
    ymon  <- regmatches(x, regexpr("(?<=(_))[0-9]{6}", x, perl = TRUE))
    ymon  <- as.yearmon(ymon, format = "%Y%m")
    year  <- as.integer(format(as.Date(ymon), "%Y"))
    month <- as.integer(format(as.Date(ymon), "%m"))
    data.frame(file = x, variable = var, reference = per, yearmon = ymon,
               year = year, month = month)
}
info <- get_file_info(files)
tail(info)

# Libraries needed for plotting
library("ggplot2")
library("cowplot") # for theme_nothing()
library("colorspace")
library("rnaturalearth")
countries <- ne_countries(returnclass = "sf")

# Creating some images
year <- 2020
for (month in 1:12) {

    hash <- sprintf("%04d-%02d", year, month)

    cat("Processing", hash, "\n")
    required_files <- subset(info, yearmon == as.yearmon(hash), select = file, drop = TRUE)
    stopifnot(length(required_files) == 4)
    tmp <- read_stars(required_files)
    st_crs(tmp) <- st_crs(4326)
    tmp <- st_warp(tmp, st_as_stars(st_bbox(), dx = 0.125))

    ###tmp2 <- st_warp(tmp, st_as_stars(st_bbox(), dx = 0.5))
    ###    ggplot() + geom_stars(data = tmp2[1]) + geom_sf(fill = NA, color = "gray30", data = countries) +
    ###        scale_fill_continuous_diverging("Green-Orange") +
    ###        theme_nothing() + scale_x_continuous(expand = c(0, 0)) + scale_y_continuous(expand = c(0, 0))

    idx <- grep("_2t_", names(tmp))
    stopifnot(length(idx) == 1L)

    pngfile <- file.path("react-globe-climate", "public", sprintf("%s_temperature.png", hash))
    cat(" .....", pngfile, "\n")
    png(pngfile, width = 2880, height = 1440)
        par(oma = rep(0, 4))
        ggplot() + geom_stars(data = tmp[idx]) + geom_sf(fill = NA, color = "gray30", data = countries) +
            scale_fill_continuous_diverging("Green-Orange") +
            theme_nothing() + scale_x_continuous(expand = c(0, 0)) + scale_y_continuous(expand = c(0, 0))
    dev.off()

}


