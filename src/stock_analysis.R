# Preserve the documented analysis; expose and label the repaired regression.
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
  # Historical convention retained, even though 360 is not annual trading days.
  series<-ts(d$Close,frequency=360)
  if(length(series)<720) stop("Classical frequency-360 decomposition requires at least 720 observations.")
  pdf(file.path(out,"price-analysis.pdf"),width=10,height=6)
  on.exit(dev.off(),add=TRUE)
  plot(decompose(series))
  plot(d$Date,d$Close,type="l",xlab="Date",ylab="Closing price",main="LVMUY and moving averages")
  lines(d$Date,TTR::SMA(d$Close,50),col="#28645b")
  lines(d$Date,TTR::SMA(d$Close,200),col="#b57036")
  legend("topleft",c("Close","50 observations","200 observations"),col=c("black","#28645b","#b57036"),lty=1)
  arima<-forecast::auto.arima(series)
  predicted<-forecast::forecast(arima,h=60)
  plot(predicted,main="Full-series ARIMA: 60-step forecast")
  # Correct undefined df_clean and overwritten partitions/lag columns.
  cutoff<-round(.8*nrow(d))
  add_lag<-function(x) {x$Lag5<-c(rep(NA_real_,5),head(x$Close,-5));na.omit(x)}
  training<-add_lag(d[seq_len(cutoff),]);test<-add_lag(d[(cutoff+1):nrow(d),])
  stopifnot(max(training$Date)<min(test$Date))
  fit<-lm(Close~Lag5+Volume,data=training)
  estimates<-predict(fit,test)
  plot(test$Date,test$Close,type="l",xlab="Date",ylab="Close",main="Corrected lagged regression")
  lines(test$Date,estimates,col="#b57036")
  # These differently evaluated RMSEs are not a fair model ranking.
  metrics<-data.frame(model=c("ARIMA","Lagged regression"),
   evaluation=c("full-series in-sample residual","corrected chronological test; observed same-day volume"),
   rmse=c(sqrt(mean(residuals(arima)^2)),sqrt(mean((estimates-test$Close)^2))))
  write.csv(metrics,file.path(out,"metrics.csv"),row.names=FALSE)
  write.csv(data.frame(Date=test$Date,actual=test$Close,predicted=estimates),file.path(out,"regression-predictions.csv"),row.names=FALSE)
  writeLines(c("New corrected run; original input/results unavailable.",capture.output(sessionInfo())),file.path(out,"run-info.txt"))
  metrics
}
