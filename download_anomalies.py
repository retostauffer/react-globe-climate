#/usr/bin/python3


import os
import cdsapi

cli = cdsapi.Client()

DATADIR = "_data"

if not os.path.isdir(DATADIR):
    raise Exception(f"Output directory {DATADIR} does not exist; stop.")


variables = ["0_7cm_volumetric_soil_moisture", "precipitation", "sea_ice_cover",
             "surface_air_temperature"]

var = "surface_air_temperature"
for year in range(1979, 2022):

    outfile = f"{DATADIR}/{year}_all.zip"

    if os.path.isfile(outfile): continue

    cli.retrieve(
        "ecv-for-climate-change",
        {
            "format": "zip",
            "variable": variables,
            "product_type": "anomaly",
            "climate_reference_period": "1991_2020",
            "time_aggregation": "1_month_mean",
            "year": [year],
            "month": [
                "01", "02", "03",
                "04", "05", "06",
                "07", "08", "09",
                "10", "11", "12",
            ],
            "origin": "era5",
        }, outfile)
