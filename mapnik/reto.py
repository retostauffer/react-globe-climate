#!/usr/bin/env python3



import mapnik
import sys
import os
from numpy import sqrt


if __name__ == "__main__":

    # World
    m = mapnik.Map(1200, 1200, "+init=epsg:4326")
    #m = mapnik.Map(1200, 1200, "+init=epsg:3857")

    # World map
    mapnik.load_map(m, "background.xml")
    mapnik.load_map(m, "world_population_mercator.xml")

    #bbox = mapnik.Box2d(mapnik.Coord(-180.0, -75.0), mapnik.Coord(180.0, 90.0))
    #bbox = mapnik.Box2d(mapnik.Coord(0, -90.0), mapnik.Coord(360.0, 90.0))
    #bbox = mapnik.Box2d(mapnik.Coord(0, 0), mapnik.Coord(2048, 1024))
    bbox = mapnik.Box2d(mapnik.Coord(-20026376.39, -20048966.10),
                        mapnik.Coord(20026376.39, 20048966.10))
    #m.zoom_to_box(bbox) 
    #mapnik.render_to_file(m, 'world_population.png', 'png')

    mlim = dict(xmin = -20026376.39,
                xmax = 20026376.39,
                ymin = -20048966.10,
                ymax = 20048966.10)

    ntiles = [2, 4, 16, 64]
    for zoom in range(1, 4):

        xdiff = (mlim["xmax"] - mlim["xmin"]) / sqrt(ntiles[zoom])
        ydiff = (mlim["ymax"] - mlim["ymin"]) / sqrt(ntiles[zoom])
        print(f"   Tile coord diff: {xdiff} {ydiff}")

        for x in range(int(sqrt(ntiles[zoom]))):
            for y in range(int(sqrt(ntiles[zoom]))):
                print(f"  z/x/y:    {zoom}/{x}/{y}")


                # Calculate bottom left and top right corner
                bl = mapnik.Coord(mlim["xmin"] + x * xdiff,
                                  mlim["ymax"] - (y + 1) * ydiff)
                tr = mapnik.Coord(mlim["xmin"] + (x + 1) * xdiff,
                                  mlim["ymax"] - y * ydiff)
                bbox = mapnik.Box2d(bl, tr)

                m.zoom_to_box(bbox) 
                tmpfile = f"tiles/{zoom}/{x}/{y}.png"
                tmpdir  = os.path.dirname(tmpfile)
                if not os.path.isdir(tmpdir): os.makedirs(tmpdir, exist_ok = True)

                mapnik.render_to_file(m, tmpfile, 'png')

#        print(zoom)
#    sys.exit(3)
#
#
#
#
#
#    # Tring to do 4 segments
#    mapfile = "world_population_mercator.xml"
#    m = mapnik.Map(1200, 1200, "+init=epsg:3857")
#    mapnik.load_map(m, mapfile)
#
#
#    bbox = mapnik.Box2d(mapnik.Coord(-20026376.39, 0),
#                        mapnik.Coord(0, 20048966.10))
#    m.zoom_to_box(bbox) 
#    mapnik.render_to_file(m, '1-0-0.svg', 'svg')
#
#
#    bbox = mapnik.Box2d(mapnik.Coord(0, 0),
#                        mapnik.Coord(20026376.39, 20048966.10))
#    m.zoom_to_box(bbox) 
#    mapnik.render_to_file(m, '1-1-0.svg', 'svg')
#
#
#    bbox = mapnik.Box2d(mapnik.Coord(-20026376.39, -20048966.10),
#                        mapnik.Coord(0, 0))
#    m.zoom_to_box(bbox) 
#    mapnik.render_to_file(m, '1-0-1.svg', 'svg')
#
#
#    bbox = mapnik.Box2d(mapnik.Coord(0, -20048966.10),
#                        mapnik.Coord(20026376.39, 0))
#    m.zoom_to_box(bbox) 
#    mapnik.render_to_file(m, '1-1-1.svg', 'svg')
