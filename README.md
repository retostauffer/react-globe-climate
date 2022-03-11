

# React globe for DiSC demo


## Downloading data

`download_anomalies.py` uses the `cdsapi` library (registration required; free)
to download monthly anomalies over the past years. Will be stored in `_data` (not
under version control).

## Generate color maps given limits

To prepare the XML files for mapnik to visualize the data
we need to figure out the limits we need for the color maps and create them.

* `generate_mapnik_xml.R`: Analizes the grib files located in `_data` to get
    the limits needed from the corresponding grib files (uses functions
    from `generate_mapnik_functions.R`).
* Stores a series of XML files into `mapnik/background_\*.xml` containing
    the RasterColorizer configuration.
* Creates, in addition, the color maps and stores them into `\_tiles`, these
    are later displayed on the web interface.


### Directories

* `_data`: Contains a series of ZIP archives with the GRIB files downloaded
    from Copernicus CDS (handled by `download_anomalies.py`).
* `mapnik`: Contains mapnik (python) config files and some code (lib).
* `_tiles`: Stores tiles and images for the interface.
* `webgl-earth`: Contains the frontend related stuff.


