# FluxToolbox Research Fork

This is a cleaned research fork of the original MATLAB FluxToolbox.

## What Changed

- Added `Plotting/WaveSummaryPlotResearch.m` for the three-panel wavelet flux diagnostic plot.
- Updated `Wavelets/WaveletFlux.m` to use the research plot when `plotWave` is enabled.
- Allowed `options.nStat = 0` in `ECFlux.m` to skip the stationarity test.
- Added `.gitignore` so generated data and figures stay out of the code repo.

## Quick Start

Open MATLAB in this folder and run:

```matlab
exampleFluxCalculation
```

The example loads `exampleData.mat`, calculates the flux, and generates the wavelet diagnostic figure.

## Keep Data Out

Do not commit generated or experiment-specific files such as:

- `.nc`
- subset `.mat` files
- `.jpg` / `.tif` figures
- `Dayflux_segment`

Keep those files in a separate research workspace instead.

## More Notes

See `PROJECT_STRUCTURE.md` for the cleaned folder layout.

The original toolbox note is still kept in `Readme.txt`.
