#!/bin/bash



DIR="../_data"
#FILE="1month_anomaly_Global_ea_2t_202009_1991-2020_v02.grib"
FILE="1month_anomaly_Global_ea_2t_202012_1991-2020_v02.grib"
INTER=`tempfile -s ".tiff"`
TARGET="_test.tiff"

SSRS="EPSG:4326" # source srs not required
TSRS="EPSG:3857" # Target SRS


# Convert grib to geotiff in step 1
gdal_translate -b 1 -a_srs "${SSRS}" "${DIR}/${FILE}" -of Gtiff ${INTER}
gdalwarp -t_srs ${TSRS} ${INTER} ${TARGET}

rm ${INTER}


./reto.py
