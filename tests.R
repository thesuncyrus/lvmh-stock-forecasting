# Artificial input only: validate repairs without claiming research reproduction.
source("src/stock_analysis.R")
set.seed(42)
n<-800
d<-data.frame(Date=as.Date("2020-01-01")+seq_len(n),Open=100+cumsum(rnorm(n)),
 High=110,Low=90,Close=100+cumsum(rnorm(n)),Volume=seq_len(n)+1000)
folder<-tempfile();dir.create(folder)
input<-file.path(folder,"synthetic.csv");write.csv(d,input,row.names=FALSE)
loaded<-read_prices(input);stopifnot(nrow(loaded)==800)
metrics<-analyze_prices(loaded,folder)
stopifnot(nrow(metrics)==2,all(is.finite(metrics$rmse)))
p<-read.csv(file.path(folder,"regression-predictions.csv"))
stopifnot(nrow(p)==155,all(as.Date(p$Date)>d$Date[640]))
d$Date[2]<-d$Date[1];write.csv(d,input,row.names=FALSE)
stopifnot(inherits(try(read_prices(input),silent=TRUE),"try-error"))
cat("Synthetic contract, repaired chronological split, lag construction and output checks passed; no historical results reproduced.\n")
