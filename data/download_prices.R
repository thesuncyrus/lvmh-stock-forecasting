source("config.R")
# Retrieve the analysis window directly in R; no manual CSV download is required.
download_prices <- function(destination="data/LVMUY.csv", from=lvmh_config$from, through=lvmh_config$through) {
  if (!requireNamespace("quantmod",quietly=TRUE)) stop("Install quantmod with setup.R.")
  from <- as.Date(from); through <- as.Date(through)
  if (is.na(from) || is.na(through) || from>=through) stop("Invalid date range.")
  # Yahoo's upper bound is exclusive, so request the day after the final observation date.
  prices <- quantmod::getSymbols(lvmh_config$symbol,src="yahoo",from=from,to=through+1,
                                auto.assign=FALSE)
  result <- data.frame(Date=as.Date(zoo::index(prices)),
    Open=as.numeric(quantmod::Op(prices)),High=as.numeric(quantmod::Hi(prices)),
    Low=as.numeric(quantmod::Lo(prices)),Close=as.numeric(quantmod::Cl(prices)),
    Volume=as.numeric(quantmod::Vo(prices)))
  if (!nrow(result) || anyNA(result)) stop("The provider returned empty or incomplete OHLCV data.")
  dir.create(dirname(destination),recursive=TRUE,showWarnings=FALSE)
  write.csv(result,destination,row.names=FALSE)
  message("Saved ",nrow(result)," trading-day observations to ",destination)
  invisible(result)
}
if (sys.nframe()==0) {
  args <- commandArgs(trailingOnly=TRUE)
  download_prices(if(length(args)) args[1] else "data/LVMUY.csv")
}
