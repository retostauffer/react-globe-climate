



draw_tile <- function(color, name) {
    hold <- par(no.readonly = TRUE); on.exit(par(hold))
    png(name, width = 10, height = 10)
        par(oma = rep(0, 4), mar = rep(0, 4))
        image(matrix(1), col = color, bty = "n")
    dev.off()
}

#####
# https://wiki.openstreetmap.org/wiki/Zoom_levels

# Number of tiles for each zoom level
ntiles <- c(4, 16, 64, 256, 1024)


for (zoom in 1:5) {
    stopifnot(length(ntiles) >= zoom)
    xyseq <- seq(0L, sqrt(ntiles[zoom]), by = 1L)
    colors = rainbow(100)
    for (x in xyseq) {
        for (y in xyseq) {
            dir <- sprintf("tiles/%d/%d", zoom, x)
            dir.create(dir, showWarning = FALSE, recursive = TRUE)
            draw_tile(sample(colors, 1), sprintf("%s/%d.png", dir, y))
        }
    }
}
