#/usr/bin/python3


import os
import cdsapi
import datetime as dt

cli = cdsapi.Client()

DATADIR = "_data"

if not os.path.isdir(DATADIR):
    raise Exception(f"Output directory {DATADIR} does not exist; stop.")


variables = ["0_7cm_volumetric_soil_moisture", "precipitation", "sea_ice_cover",
             "surface_air_temperature"]

# Downloading anomalies
for year in range(1979, dt.date.today().year + 1):

    outfile = f"{DATADIR}/{year}_anomalies.zip"
    print(f"Processing {outfile}")

    if os.path.isfile(outfile) and not year == dt.date.today().year: continue

    tmp = dt.date.today() - dt.timedelta(45)
    if year == tmp.year:
        months = [f'{x:02d}' for x in range(1, tmp.month + 1)]
    else:
        months = [f'{x:02d}' for x in range(1, 13)]

    # Downloading anomalies
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


# Downloading monthly means
for year in range(1979, dt.date.today().year + 1):

    outfile = f"{DATADIR}/{year}_monthlymean.zip"
    print(f"Processing {outfile}")

    if os.path.isfile(outfile) and not year == dt.date.today().year: continue

    tmp = dt.date.today() - dt.timedelta(45)
    if year == tmp.year:
        months = [f'{x:02d}' for x in range(1, tmp.month + 1)]
    else:
        months = [f'{x:02d}' for x in range(1, 13)]

    # Downloading monthly means
    cli.retrieve(
        'ecv-for-climate-change',
        {
            'format': 'zip',
            'product_type': 'monthly_mean',
            'variable': variables,
            'origin': 'era5',
            "year": [year],
            "month": [
                "01", "02", "03",
                "04", "05", "06",
                "07", "08", "09",
                "10", "11", "12",
            ],
            'time_aggregation': '1_month_mean',
        }, outfile)
