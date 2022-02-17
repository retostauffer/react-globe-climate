#!/usr/bin/env python3


import mapnik

# World
mapfile = "world_population_mercator.xml"
m = mapnik.Map(1200, 1200, "+init=epsg:3857")
mapnik.load_map(m, mapfile)
#bbox = mapnik.Box2d(mapnik.Coord(-180.0, -75.0), mapnik.Coord(180.0, 90.0))
bbox = mapnik.Box2d(mapnik.Coord(-20026376.39, -20048966.10),
                    mapnik.Coord(20026376.39, 20048966.10))
m.zoom_to_box(bbox) 
mapnik.render_to_file(m, 'world_population.svg', 'svg')


# Tring to do 4 segments
mapfile = "world_population_mercator.xml"
m = mapnik.Map(1200, 1200, "+init=epsg:3857")
mapnik.load_map(m, mapfile)


bbox = mapnik.Box2d(mapnik.Coord(-20026376.39, 0),
                    mapnik.Coord(0, 20048966.10))
m.zoom_to_box(bbox) 
mapnik.render_to_file(m, '1-0-0.svg', 'svg')


bbox = mapnik.Box2d(mapnik.Coord(0, 0),
                    mapnik.Coord(20026376.39, 20048966.10))
m.zoom_to_box(bbox) 
mapnik.render_to_file(m, '1-1-0.svg', 'svg')


bbox = mapnik.Box2d(mapnik.Coord(-20026376.39, -20048966.10),
                    mapnik.Coord(0, 0))
m.zoom_to_box(bbox) 
mapnik.render_to_file(m, '1-0-1.svg', 'svg')


bbox = mapnik.Box2d(mapnik.Coord(0, -20048966.10),
                    mapnik.Coord(20026376.39, 0))
m.zoom_to_box(bbox) 
mapnik.render_to_file(m, '1-1-1.svg', 'svg')
