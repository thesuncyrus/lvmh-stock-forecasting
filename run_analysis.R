source("src/stock_analysis.R")
args<-commandArgs(trailingOnly=TRUE)
input<-if(length(args)) args[1] else "data/LVMUY.csv"
if(!file.exists(input)) {
  if(length(args)) stop("Input file not found: ",input)
  source("data/download_prices.R")
  download_prices(input)
}
out<-if(length(args)>1) args[2] else "outputs"
print(analyze_prices(read_prices(input),out))
