source("src/stock_analysis.R")
args<-commandArgs(trailingOnly=TRUE)
if(!length(args)) stop("Usage: Rscript run_analysis.R /private/LVMUY.csv [outputs]")
out<-if(length(args)>1) args[2] else "outputs"
print(analyze_prices(read_prices(args[1]),out))
