

# React globe for DiSC demo


## Downloading data

`download_anomalies.py` uses the `cdsapi` library (registration required; free)
to download monthly anomalies over the past years. Will be stored in `_data` (not
under version control).


## React app

`react-globe-climate` is based on `react-globe` to display an interactive globe using
react/webGL. To get it running it should be enough to:

```
cd react-globe-climate && \
npm install \
npm run start
```

... to start a development instance on port 3000. `npm run build` prepares the
optimized version for publication.

### Directories

* `react-globe-climate/src`: Contains the required `js` code
* `react-globe-climate/public`: index page and publicly availabe data (such as the images for the surface of the globe)
* `react-globe-climate/node_modules`: folder created by `npm` for package installation

