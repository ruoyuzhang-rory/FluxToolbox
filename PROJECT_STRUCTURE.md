# FluxToolbox Project Structure

This folder is kept as the clean MATLAB toolbox working copy.

## Keep Here

- `ECFlux.m` and the root example/readme files from the original toolbox.
- Toolbox code directories:
  - `AirborneECTools`
  - `FFP_Kljun2015`
  - `NewStuff`
  - `Plotting`
  - `Resistance`
  - `Spectra`
  - `Subfunctions`
  - `Wavelets`
  - `Python`
- Small original sample files needed by the upstream examples, such as `exampleData.mat`.
- Research code changes that intentionally modify toolbox behavior, such as edited files in `Plotting`, `Spectra`, and `Wavelets`.
- `Plotting/WaveSummaryPlot.m` is the original-style toolbox plot; `Plotting/WaveSummaryPlotResearch.m` is the cleaned research plot called by `Wavelets/WaveletFlux.m`.

## Keep Out

Generated or experiment-specific files should not live in this toolbox root:

- Daily or segment folders such as `Dayflux_segment`.
- Root-level `.nc` files.
- Root-level subset `.mat` files, except upstream sample files such as `exampleData.mat`.
- Generated figures such as `.jpg` and `.tif`.
- One-off root scripts for a specific dataset/date.

Those files were moved to the sibling folder:

`..\FluxToolbox-research_workspace`

## Reference Copy

The downloaded GitHub copy is kept separately as:

`..\FluxToolbox-master-origin`

Use it to compare which files are original and which files are research edits.

## Backup

Before this cleanup, the full messy working folder was copied to a timestamped sibling backup named:

`..\FluxToolbox-master_backup_before_cleanup_YYYYMMDD_HHMMSS`
