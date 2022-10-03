

# Conda mapnik?

# WebGL globe for DiSC demo

## Mapnik

Issues October 2022 to install the library as the current release `3.1`
does not support Python 3.10. Currently trying to build the library
from the master branch. According to <https://github.com/mapnik/mapnik/blob/master/INSTALL.md>

With commit <https://github.com/mapnik/mapnik/commit/53a8e2ec2c31862f1072950885b4b90279d0129d>.

```
# you might have to update your outdated clang
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get update -y
sudo apt-get install -y gcc-6 g++-6 clang-3.8
export CXX="clang++-3.8" && export CC="clang-3.8"

# install mapnik
git clone https://github.com/mapnik/mapnik mapnik --depth 10
cd mapnik
git submodule update --init
sudo apt-get install zlib1g-dev clang make pkg-config curl
source bootstrap.sh
PYTHON=python3 ./configure CUSTOM_CXXFLAGS="-D_GLIBCXX_USE_CXX11_ABI=0" CXX=${CXX} CC=${CC}
```

Manually applied this:

* <https://github.com/mapnik/mapnik/issues/4243>


```
###PYTHON=python3 make
###PYTHON=python3 make test
sudo PYTHON=python3 make install
```

**This helped at leat with installation ....**

## Downloading data

`download_anomalies.py` uses the `cdsapi` library (registration required; free)
to download monthly anomalies over the past years. Will be stored in `_data` (not
under version control).

* <https://cds.climate.copernicus.eu/cdsapp#!/dataset/ecv-for-climate-change?tab=form>

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


# Directories

* `_data`: Contains a series of ZIP archives with the GRIB files downloaded
    from Copernicus CDS (handled by `download_anomalies.py`).
* `mapnik`: Contains mapnik (python) config files and some code (lib).
* `_tiles`: Stores tiles and images for the interface.
* `frontend`: Contains the frontend related stuff (`webglearth`, `jquery`, ...).

# Frontend

The `frontend` folder contains `package.json` to build the js dependencies.
Simply run `npm install` for installation (jquery, bootstrap). This will
download source and builds and store it in `node_modules`.

For practical reasons (syncing to external machine) I am linking a series
of `.js` and `.css` files into the corresponding folders `js` and `css`.
Make sure they do exist:

* In `js`:
    * `bootstrap.min.js -> ../node_modules/bootstrap/dist/js/bootstrap.min.js`
    * `bootstrap.min.js.map -> ../node_modules/bootstrap/dist/js/bootstrap.min.js.map`
    * `jquery.min.js -> ../node_modules/jquery/dist/jquery.min.js`
* In `css`
    * `bootstrap.min.css -> ../node_modules/bootstrap/dist/css/bootstrap.min.css`
    * `bootstrap.min.css.map -> ../node_modules/bootstrap/dist/css/bootstrap.min.css.map`



