# LVMH Stock Price Forecasting

Chau Nguyen · Purdue University · October–December 2024

## Research question
How do trend decomposition, moving averages, ARIMA and lagged-price regression describe the behavior of LVMUY stock prices?

## Dataset
The analysis uses daily LVMUY OHLCV prices for October 23, 2020 through October 23, 2024. `quantmod::getSymbols()` retrieves the series directly from Yahoo Finance. It is an online data source, not a dataset bundled with quantmod. The script caches it at data/LVMUY.csv; manual downloading is unnecessary.

## Methods
- Classical decomposition with frequency 360 and 50/200-observation moving averages.
- Automatic ARIMA fitted to the complete price series, followed by a 60-step forecast.
- Regression using Close ~ Lag5 + Volume, with a chronological 80/20 split and lags constructed within each partition.

The analysis reports in-sample residual RMSE for ARIMA and test-set RMSE for the regression. The regression uses realized same-day volume.

## Run
```sh
Rscript setup.R
Rscript run_analysis.R
```
The runner fetches prices if its default data file is absent, then writes figures, metrics and predictions to outputs/. To fetch separately, run `Rscript data/download_prices.R`. To use an existing file, run `Rscript run_analysis.R data/LVMUY.csv outputs`. Run software checks with `Rscript tests.R`.

![Analysis workflow](results/figures/workflow.svg)

[quantmod data-source documentation](https://search.r-project.org/CRAN/refmans/quantmod/html/getSymbols.yahoo.html) · [Portfolio case study](https://thesuncyrus.github.io/lvmh.html)
