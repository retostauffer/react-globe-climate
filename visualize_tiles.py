#!/usr/bin/python3
# -----------------------------------------------------------------
# Python script to 
# i) extract and identify the grib file needed,
# ii) convert it into a geotiff with mercator projection
# iii) visualize tiles via mapnik
# -----------------------------------------------------------------

import sys
import os
import re
import optparse
import glob

from tempfile import TemporaryDirectory
from shutil import unpack_archive, rmtree

DATADIR = "_data"
TILESDIR = "_tiles"

# -----------------------------------------------------------------
# Convert grib file to mercator-projected geotiff
# -----------------------------------------------------------------
def grib_to_tiff(gribfile, outfile):

    import os
    from tempfile import NamedTemporaryFile
    import subprocess as sub

    if not os.path.isfile(gribfile):
        raise Exception(f"Cannot find {gribfile} to be converted to tiff.")

    tmpfile = NamedTemporaryFile(suffix = ".tiff")

    SSRS = "EPSG:4326"
    TSRS = "EPSG:3857"

    CMD = ["gdal_translate", "-b", "1", "-a_srs", SSRS, gribfile, "-of", "Gtiff", tmpfile.name]
    print(" ".join(CMD) + "\n")
    p = sub.Popen(CMD, stdout = sub.PIPE, stderr = sub.PIPE)
    out,err = p.communicate()
    if not p.returncode == 0: raise Exception(err)

    CMD = ["gdalwarp", "-t_srs", TSRS, "-overwrite", tmpfile.name, outfile]
    p = sub.Popen(CMD, stdout = sub.PIPE, stderr = sub.PIPE)
    out,err = p.communicate()
    if not p.returncode == 0: raise Exception(err)

    return outfile



# -----------------------------------------------------------------
# Convert grib file to mercator-projected geotiff
# -----------------------------------------------------------------
def visualize_tiles(tiff, variable, outdir):

    import os
    import mapnik
    from numpy import sqrt

    # Setting up 'map' (defines image size)
    m = mapnik.Map(1200, 1200, "+init=epsg:4326")

    # World map
    xmlfile = f"mapnik/background_{variable}.xml"
    if not os.path.isfile(xmlfile):
        raise Exception("Rquired file {xmlfile} does not exist.")
    print(f"Using XML file {xmlfile}")
    mapnik.load_map(m, xmlfile)
    mapnik.load_map(m, "mapnik/world_population_mercator.xml")

    # Mercator bounding box (x/y limits).
    # Defined for longitude -180/180 latitude ~-85/85.
    mlim = dict(xmin = -20026376.39, xmax = 20026376.39,
                ymin = -20048966.10, ymax = 20048966.10)

    # Zoom level and the corresponding number of tiles to be stored 
    ntiles = [2, 4, 16, 64]
    for zoom in range(1, 4):

        xdiff = (mlim["xmax"] - mlim["xmin"]) / sqrt(ntiles[zoom])
        ydiff = (mlim["ymax"] - mlim["ymin"]) / sqrt(ntiles[zoom])
        #print(f"   Tile coord diff: {xdiff} {ydiff}")
        print(f"Plotting zoom level {zoom} with {ntiles[zoom]} tiles ...")

        for x in range(int(sqrt(ntiles[zoom]))):
            for y in range(int(sqrt(ntiles[zoom]))):
                # Calculate bottom left and top right corner
                bl = mapnik.Coord(mlim["xmin"] + x * xdiff,
                                  mlim["ymax"] - (y + 1) * ydiff)
                tr = mapnik.Coord(mlim["xmin"] + (x + 1) * xdiff,
                                  mlim["ymax"] - y * ydiff)
                bbox = mapnik.Box2d(bl, tr)

                m.zoom_to_box(bbox) 
                tmpfile = f"{outdir}/{zoom}/{x}/{y}.png"
                tmpdir  = os.path.dirname(tmpfile)
                if not os.path.isdir(tmpdir): os.makedirs(tmpdir, exist_ok = True)

                mapnik.render_to_file(m, tmpfile, 'png')


# -----------------------------------------------------------------
# -----------------------------------------------------------------
if __name__ == "__main__":

    # Parsing input options
    parser = optparse.OptionParser()
    parser.add_option("-y", "--year", type = "int",
                    help = "Integer, year to process")
    parser.add_option("-m", "--month", type = "int",
                    help = "Integer, month to process")
    parser.add_option("-v", "--variable", type = "string",
                    help = "Grib shortname of the variable to process/visualize")

    (options, args) = parser.parse_args()

    if options.year is None or options.month is None or options.variable is None:
        parser.print_help()
        sys.exit(666)

    # Name of the file to be considered
    zipfile = f"{DATADIR}/{options.year:04d}_anomalies.zip"
    if not os.path.isfile(zipfile):
        raise Exception(f"Cannot find {zipfile} which is needed here.")

    # 
    tmpdir = TemporaryDirectory()
    unpack_archive(zipfile, extract_dir = tmpdir.name)

    gribfile = None
    pattern = f".*{options.variable}_{options.year:04d}{options.month:02d}.*"
    for tmp in glob.glob(f"{tmpdir.name}/*.grib"):
        if re.match(pattern, tmp):
            gribfile = tmp
            break

    if gribfile is None:
        raise Exception("Could not find a grib file matching the input options")


    # -----------------------------------------------
    # Else we can process this file
    # -----------------------------------------------
    print(f"Processing grib file: {gribfile}\n")


    tiff = grib_to_tiff(gribfile, "mapnik/data.tiff")

    #visualize_tiles(tiff, options.variable, TILESDIR)
    visualize_tiles(tiff, options.variable, f"{TILESDIR}/{options.variable}/{options.year:04d}{options.month:02d}")


    # Delete temporary directory after processing
    rmtree(tmpdir.name)









