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

DATADIR = "_data"



zipfiles <- list.files(DATADIR, full.names = TRUE)
zipfiles <- zipfiles[grepl("[0-9]{4}_all.zip$", zipfiles)]
cat("Found", length(zipfiles), "files to read\n")


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
#res <- get_limits(zipfiles[1])


# Getting limits
all_limits <- list()
for (z in zipfiles) {
    all_limits[z] <- get_limits(z)
}

saveRDS(all_limits, "_test.rds")
#all_limits <- do.call(rbind, all_limits)
#rownames(all_limits) <- NULL
#saveRDS(all_limits, "all_limits.rds")




