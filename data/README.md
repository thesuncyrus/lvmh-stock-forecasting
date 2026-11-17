# LVMUY price data

Run `Rscript data/download_prices.R` from the repository root to retrieve daily LVMUY prices through quantmod from Yahoo Finance. The default window is 2020-10-23 through 2024-10-23 inclusive.

The generated data/LVMUY.csv contains Date, Open, High, Low, Close and Volume. Prices are obtained online and cached locally; they are not built into the package. `Rscript run_analysis.R` also downloads the default data file when it is absent.

[Official data-source documentation](https://search.r-project.org/CRAN/refmans/quantmod/html/getSymbols.yahoo.html).
