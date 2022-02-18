#!/bin/bash

##ssrs="EPSG:4326"
tsrs="EPSG:3857"
gdalwarp -t_srs ${tsrs} _test.tiff  _test2.tiff

