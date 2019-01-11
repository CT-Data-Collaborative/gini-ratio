ToNumeric <- function (factor) {
  return(as.numeric(as.character(factor)))
}

ExtractNumData <- function (factor) {
  return(ToNumeric(factor[1:length(factor)]))
}

WriteDFToTable <- function(df, filename){
  write.table(
    df,
    file = file.path(getwd(), "data", filename),
    sep = ",",
    row.names = FALSE
  )
}

# Read Connecticut-specific CSV for median household income
getCTGiniIndex <- function(filepath){
  ct.data  <- read.csv(filepath, header = FALSE)
  ct.data <- ct.data[-1:-2,]
  names(ct.data) <- c("Id", "FIPS", "Town", "Gini Ratio", "Margins of Error")
  
  ct.data$Year <- rep("2013-2017", length(ct.data[,1]))
  ct.data <- ct.data[!(grepl("not defined", ct.data$Town)),]
  return(ct.data)
}

# group moe and income under single observational unit
gatherEstimateMoE <- function(ct.income){
  ct.income <- ct.income[,c(3,2,4:7)]
  return(
    ct.income %>%
      gather("Variable", "Value", c("Gini Ratio","Margins of Error")) %>%
      select(Town, FIPS, Year, `Measure Type`, Variable, Value)
  )
}

# Sort data by FIPS Code
orderedByGeography <- function(ct.income){
  return(ct.income[order(ct.income[,2], ct.income[,3]),])
}

getGatheredTownData <- function(ct.income){
  ct.income$Town <- gsub(",.*, Connecticut", "", ct.income$Town)
  ct.income <-  ct.income[grepl("(^Connecticut$)|town", ct.income$Town),]
  ct.income$Town <- gsub(" town", "", ct.income$Town)
  gathered<- gatherEstimateMoE(ct.income)
  return(orderedByGeography(gathered))
}


coerceTypes <- function (df){
  df$Town <- as.character(df$Town)
  df$FIPS <- as.integer(as.character(df$FIPS))
  df$Year <- as.character(df$Year)
  df$`Measure Type` <- as.character(df$`Measure Type`)
  df$Variable <- as.character(df$Variable)
  df$Value <- as.numeric(df$Value)
  return(df)
}
