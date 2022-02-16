


library("sf")
library("rnaturalearth")
library("cowplot")
library("ggplot2")

countries <- ne_countries(returnclass = "sf")
countries <- st_make_valid(countries)
# No!! not flatcountries <- st_transform(countries, st_crs(3857))

plot(st_geometry(countries))

get_limits <- function(box, x, y, n) {
    tmp_x <- seq(-180, 180, length.out = n + 1)
    tmp_y <- seq( -90,  90, length.out = n + 1)
    list(xmin = tmp_x[x + 1], xmax = tmp_x[x + 2],
         ymin = tmp_y[y + 1], ymax = tmp_y[y + 2])
}
get_limit_bb <- function(box, x, y, n, crs = NULL) {
    tmp_x <- seq(-180, 180, length.out = n + 1)
    tmp_y <- seq( -90,  90, length.out = n + 1)
    st_bbox(c(xmin = tmp_x[x + 1], xmax = tmp_x[x + 2],
         ymin = tmp_y[y + 1], ymax = tmp_y[y + 2]), crs = if (is.null(crs)) st_crs(4623) else crs)
}
(bb <- get_limit_bb(st_bbox(countries), 0, 1, 2, st_crs(countries)))
#get_limits(st_bbox(countries), 0, 1, 2)
#get_limits(st_bbox(countries), 1, 1, 2)

#####
# https://wiki.openstreetmap.org/wiki/Zoom_levels
# Number of tiles for each zoom level

draw_a_tile <- function(i, j, ntiles, countries, col = "gray90") {
    # Mercator x/y limits
    # x:   -20037508 to 20037508
    # y:   -20601982 to 20601982 -> taking 
    #st_transform(st_sfc(st_point(c(180, 85.0)), crs = 4326), crs = 3395)
    lons <- seq(0, 2 * 20037508,     length.out = 1 + sqrt(ntiles))
    lats <- seq(20037508, -20037508, length.out = 1 + sqrt(ntiles))

    xlim <- lons[i + 0:1]
    if (min(xlim) >= 20037508) xlim <- xlim - (2 * 20037508)
    ylim <- lats[j + 1:0]

    # Just points; was originally going for a polygon but this should be fine.
    #bbox_matrix <- matrix(c(xlim[1], xlim[1], xlim[2], xlim[2],
    #                        ylim[1], ylim[2], ylim[2], ylim[1]),
    #                      byrow = FALSE, ncol = 2)
    #bbox_points <- lapply(seq_len(nrow(bbox_matrix)), function(i, m) st_point(m[i, ]), m = bbox_matrix)
    #bbox_points <- st_transform(st_sfc(bbox_points, crs = st_crs(4326)), crs = 3395)

    #xlim <- st_bbox(bbox_points)[c("xmin", "xmax")]
    #ylim <- st_bbox(bbox_points)[c("ymin", "ymax")]

    # Drawing the tile
    hold <- par(no.readonly = TRUE); on.exit(par(hold))
    par(mar = rep(0, 4), oma = rep(0, 4))

    plot(NA, xlim = xlim, ylim = ylim, xaxs = "i", yaxs = "i", bty = "n")
    #plot(bbox, add = TRUE, border = 2, lwd = 3)
    plot(st_cast(st_geometry(st_transform(countries, crs = 3395))), add = TRUE, col = col)
    text(mean(xlim), mean(ylim), sample(LETTERS, 1))

    # Development labeling
    text(xlim[1], ylim[2], sprintf("%d/%d", i, j), adj = c(-.5, 1.5), col = 2, font = 2, cex = 5)
    box(lwd = 5)
}
#u <- draw_a_tile(2, 1, ntiles[1], countries)


# Number of tiles to be drawn
ntiles <- c(4, 16, 64, 256, 1024)
countries <- ne_countries(returnclass = "sf")

png_pixels <- 500

for (zoom in 1:4) {
    for (x in seq_len(sqrt(ntiles[zoom]))) {
        for (y in seq_len(sqrt(ntiles[zoom]))) {
            # Note that tile names are 0-based; as well as the zoom
            dir.create(dir <- sprintf("tiles/%d/%d", zoom, x - 1), showWarning = FALSE, recursive = TRUE)
            pngname <- sprintf("%s/%d.png", dir, y - 1)
            print(pngname)
            png(file = pngname, height = png_pixels, width = ifelse(zoom == 1, 2, 1) * png_pixels)
                draw_a_tile(x, y, ntiles[zoom], countries, col = sample(rainbow(10), 1L))
            dev.off()
        }
    }
}


