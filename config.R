# Existing decomposition, ARIMA and regression settings; each retains its sample.
lvmh_config <- list(
  symbol = "LVMUY", from = "2020-10-23", through = "2024-10-23",
  frequency = 360, moving_averages = c(50, 200), forecast_horizon = 60,
  regression = list(train_fraction = .8, lag_observations = 5, formula = Close ~ Lag5 + Volume)
)
