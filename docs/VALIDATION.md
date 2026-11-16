# Validation

Executed 2026-11-16 with R 4.4.3, forecast 9.0.2 and TTR. `Rscript tests.R` passed the synthetic 800-row contract check, including chronological lag handling (155 usable test rows) and duplicate-date rejection. This checks software behavior only. No real-data model evaluation was rerun because the original OHLCV file and saved outputs are unavailable. Source files also parsed successfully.
