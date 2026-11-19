source("config.R")
# LVMUY price decomposition, moving averages, ARIMA and lagged regression.
read_prices <- function(path) {
  if(!file.exists(path)) stop("Supply an authorized LVMUY OHLCV CSV.")
  d<-read.csv(path,stringsAsFactors=FALSE)
  needed<-c("Date","Open","High","Low","Close","Volume")
  if(!all(needed %in% names(d))) stop("Expected Date, Open, High, Low, Close, Volume.")
  d$Date<-as.Date(d$Date)
  if(anyNA(d[,needed]) || anyDuplicated(d$Date)) stop("Missing values or duplicate dates.")
  if(is.unsorted(d$Date)) stop("Input must be chronological; do not silently reorder observations.")
  if(!all(vapply(d[needed[-1]],is.numeric,logical(1)))) stop("OHLCV fields must be numeric.")
  d
}
analyze_prices <- function(d,out) {
  if(!requireNamespace("forecast",quietly=TRUE) || !requireNamespace("TTR",quietly=TRUE)) stop("Run setup.R.")
  dir.create(out,recursive=TRUE,showWarnings=FALSE)
  # Series frequency used by the decomposition and ARIMA analysis.
  series<-ts(d$Close,frequency=lvmh_config$frequency)
  if(length(series)<2*lvmh_config$frequency) stop("Classical frequency-360 decomposition requires at least 720 observations.")
  pdf(file.path(out,"price-analysis.pdf"),width=10,height=6)
  on.exit(dev.off(),add=TRUE)
  plot(decompose(series))
  plot(d$Date,d$Close,type="l",xlab="Date",ylab="Closing price",main="LVMUY and moving averages")
  lines(d$Date,TTR::SMA(d$Close,lvmh_config$moving_averages[1]),col="#28645b")
  lines(d$Date,TTR::SMA(d$Close,lvmh_config$moving_averages[2]),col="#b57036")
  legend("topleft",c("Close","50 observations","200 observations"),col=c("black","#28645b","#b57036"),lty=1)
  arima<-forecast::auto.arima(series)
  predicted<-forecast::forecast(arima,h=lvmh_config$forecast_horizon)
  plot(predicted,main="Full-series ARIMA: 60-step forecast")
  # Chronological training/test partitions with within-partition lag construction.
  cutoff<-round(lvmh_config$regression$train_fraction*nrow(d))
  add_lag<-function(x) {x$Lag5<-c(rep(NA_real_,lvmh_config$regression$lag_observations),head(x$Close,-lvmh_config$regression$lag_observations));na.omit(x)}
  training<-add_lag(d[seq_len(cutoff),]);test<-add_lag(d[(cutoff+1):nrow(d),])
  stopifnot(max(training$Date)<min(test$Date))
  fit<-lm(lvmh_config$regression$formula,data=training)
  estimates<-predict(fit,test)
  plot(test$Date,test$Close,type="l",xlab="Date",ylab="Close",main="Lagged regression: test predictions")
  lines(test$Date,estimates,col="#b57036")
  # These differently evaluated RMSEs are not a fair model ranking.
  metrics<-data.frame(model=c("ARIMA","Lagged regression"),
   evaluation=c("full-series in-sample residual","chronological test; observed same-day volume"),
   rmse=c(sqrt(mean(residuals(arima)^2)),sqrt(mean((estimates-test$Close)^2))))
  write.csv(metrics,file.path(out,"metrics.csv"),row.names=FALSE)
  write.csv(data.frame(Date=test$Date,actual=test$Close,predicted=estimates),file.path(out,"regression-predictions.csv"),row.names=FALSE)
  writeLines(c("LVMUY price analysis; price provider and dates are specified by the input file.",capture.output(sessionInfo())),file.path(out,"run-info.txt"))
  metrics
}
