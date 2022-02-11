# ------------------------------------------
# Just a quick test
# ------------------------------------------


library("zoo")
library("stars")
library("ggplot2")

files <- list.files("_data", full.name = TRUE)
files <- files[grepl("\\.grib$", files)]

# Extracting reference period year and variable name
get_file_info <- function(x) {
    var  <- regmatches(x, regexpr("(?<=(ea_)).*?(?=(_))", x, perl = TRUE))
    per  <- regmatches(x, regexpr("(?<=(_))[0-9]{4}-[0-9]{4}", x, perl = TRUE))
    ymon <- regmatches(x, regexpr("(?<=(_))[0-9]{6}", x, perl = TRUE))
    ymon <- as.yearmon(ymon, format = "%Y%m")
    print(length(var))
    print(length(per))
    print(length(ymon))
    data.frame(file = x, variable = var, reference = per, yearmon = ymon)
}

info <- get_file_info(files)
head(info)

x <- subset(info, yearmon == as.yearmon("1984-04"))
tmp <- read_stars(x$file)
st_crs(tmp) <- st_crs(4326)
tmp <- st_warp(tmp, st_as_stars(st_bbox(), dx = 0.125))


library("rnaturalearth")
countries <- ne_countries(returnclass = "sf")

test_plot <- function(x, countries, col = hcl.colors(9, "Blue-Red"), ..., asp = 0) {
    hold <- par(no.readonly = TRUE); on.exit(par(hold))
    par(oma = rep(0, 4), mar = rep(0, 4))
    ret <- image(x, asp = asp, ...)
    plot(st_geometry(countries), new = FALSE)
    invisible(ret)
}
test_plot(tmp[1], countries)


library("ggplot2")
library("cowplot") # for theme_nothing()
library("colorspace")

tmp2 <- st_warp(tmp, st_as_stars(st_bbox(), dx = 0.5))
    ggplot() + geom_stars(data = tmp2[1]) + geom_sf(fill = NA, color = "white", data = countries) +
        scale_fill_continuous_diverging("Green-Orange") +
        theme_nothing() + scale_x_continuous(expand = c(0, 0)) + scale_y_continuous(expand = c(0, 0))

jpeg(file = "react-globe-climate/public/temperature.jpg", width = 2880, height = 1440)
    par(oma = rep(0, 4))
    ggplot() + geom_stars(data = tmp[1]) + geom_sf(fill = NA, color = "white", data = countries) +
        scale_fill_continuous_diverging("Green-Orange") +
        theme_nothing() + scale_x_continuous(expand = c(0, 0)) + scale_y_continuous(expand = c(0, 0))
dev.off()




