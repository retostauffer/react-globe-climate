


library("sf")
library("rnaturalearth")
library("cowplot")
library("ggplot2")
library("stars")

countries <- ne_countries(returnclass = "sf")
###countries <- st_make_valid(countries)

st_rectangle <- function(xmin, xmax, ymin, ymax, crs = 4326) {
    m <- cbind(x = c(xmin, xmin, xmax, xmax, xmin),
               y = c(ymin, ymax, ymax, ymin, ymin))
    st_sfc(st_polygon(list(m)), crs = crs)
}

#####
# https://wiki.openstreetmap.org/wiki/Zoom_levels
# Number of tiles for each zoom level
draw_a_tile <- function(i, j, ntiles, countries, col = "gray90", data = NULL) {

    countries <- st_transform(countries, 3395) # Mercator
    if (!is.null(data)) {
        stopifnot(inherits(data, "sf"))
        data <- st_transform(data, crs = 3395)
    }

    # Mercator x/y limits
    # x:   -20037508 to 20037508
    # y:   -20601982 to 20601982 -> taking 
    #st_transform(st_sfc(st_point(c(180, 85.0)), crs = 4326), crs = 3395)
    lons <- seq(0, 2 * 20037508,     length.out = 1 + sqrt(ntiles))
    lats <- seq(20037508, -20037508, length.out = 1 + sqrt(ntiles))

    xlim <- lons[i + 0:1]
    if (min(xlim) >= 20037508) xlim <- xlim - (2 * 20037508)
    ylim <- lats[j + 1:0]

    ##### Just points; was originally going for a polygon but this should be fine.
    ####bbox_matrix <- matrix(c(xlim[1], xlim[1], xlim[2], xlim[2], xlim[1],
    ####                        ylim[1], ylim[2], ylim[2], ylim[1], ylim[1]),
    ####                      byrow = FALSE, ncol = 2)
    ####bbox <- st_sfc(st_polygon(list(bbox_matrix)), crs = 3395)

    # Drawing the tile
    hold <- par(no.readonly = TRUE); on.exit(par(hold))
    par(mar = rep(0, 4), oma = rep(0, 4))

    plot(NA, xlim = xlim, ylim = ylim, xaxs = "i", yaxs = "i", bty = "n")
    #plot(bbox, add = TRUE, border = 2, lwd = 3)
    plot(st_cast(st_geometry(countries)), add = TRUE, col = col)
    plot(st_geometry(data), col = data$color, border = NA, add = TRUE)
    text(mean(xlim), mean(ylim), sample(LETTERS, 1))

    # Development labeling
    text(xlim[1], ylim[2], sprintf("%d/%d", i, j), adj = c(-.5, 1.5), col = 2, font = 2, cex = 5)
    box(lwd = 5)
}

u <- draw_a_tile(2, 1, ntiles[1], countries)
u <- draw_a_tile(2, 1, ntiles[1], countries, data = data)


# Number of tiles to be drawn
ntiles <- c(4, 16, 64, 256, 1024)

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# Reading stars for plotting demo
files <- list.files("../_data", full.names = TRUE)
files <- files[grep("grib$", files)]
file  <- files[1]

library("stars")
st <- read_stars(file)
st_crs(st) <- st_crs(4326)
bbox <- st_rectangle(-0.125, 359.875, -85, 85, 4326)
st <- st_crop(st, st_bbox(bbox))

data <- setNames(st_as_sf(st[1], crs = 4326), c("value", "geometry"))
value_to_color <- function(x, colors = hcl.colors(11, "Blue-Red")) {
    stopifnot(is.numeric(x))
    zlim <- max(abs(range(x, na.rm = TRUE))) * c(-1, 1)
    col <- colors[as.integer(cut(x, breaks = length(colors) + 1, include.lowest = TRUE))]
    return(col)
}
data$color <- value_to_color(data$value)
head(data)

# Problem are lat == 90! Cut those outside 85.
uu <- st_transform(data, crs = 3395)
plot(st_geometry(uu), col = uu$color, border = NA)





# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# Plotting ...

png_pixels <- 500
for (zoom in 1:4) {
    for (x in seq_len(sqrt(ntiles[zoom]))) {
        for (y in seq_len(sqrt(ntiles[zoom]))) {
            # Note that tile names are 0-based; as well as the zoom
            dir.create(dir <- sprintf("tiles/%d/%d", zoom, x - 1), showWarning = FALSE, recursive = TRUE)
            #####pngname <- sprintf("%s/%d.png", dir, y - 1)
            #####print(pngname)
            #####png(file = pngname, height = png_pixels, width = ifelse(zoom == 1, 2, 1) * png_pixels)
            #####    draw_a_tile(x, y, ntiles[zoom], countries, col = sample(rainbow(10), 1L))
            #####dev.off()

            svgname <- sprintf("%s/%d.svg", dir, y - 1)
            cat("Drawing", svgnmae, "\r")
            svg(file = svgname, height = 7, width = ifelse(zoom == 1, 2, 1) * 7)
                draw_a_tile(x, y, ntiles[zoom], countries, col = sample(rainbow(10), 1L))
            dev.off()
        }
    }
}
cat("\n")










###??
library("ggplot2")
ggplot() + geom_sf(data = data[, "value"]) + coord_map("mercator")

file.remove("countries.shp")
st_write(countries, "countries.shp")














