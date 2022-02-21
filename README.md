

# React globe for DiSC demo


## Downloading data

`download_anomalies.py` uses the `cdsapi` library (registration required; free)
to download monthly anomalies over the past years. Will be stored in `_data` (not
under version control).

## Checking Limits

To prepare the xml files for visualizing the data via `mapnik` (python)
we need to figure out the limits we need for the color maps and create them.

* `check_limits.R`: Analizes the grib files located in `_data` to get
    the limits. Outputs the limits .. (?)


### Directories

* `react-globe-climate/src`: Contains the required `js` code
* `react-globe-climate/public`: index page and publicly availabe data (such as the images for the surface of the globe)
* `react-globe-climate/node_modules`: folder created by `npm` for package installation

