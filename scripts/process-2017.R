library(tidyr)
library(dplyr)
source("./scripts/utils.R")

#Setup environment
sub_folders <- list.files()
raw_location <- grep("raw", sub_folders, value=T)
path_to_raw <- (paste0(getwd(), "/", raw_location))
raw_data <- dir(path_to_raw, recursive=T, pattern = "ACS_17_5YR_B19083", full.names = TRUE)

data_location <- grep("data", sub_folders, value=T)[1]
path_to_processed_data <- (paste0(getwd(), "/", data_location))
data_file <- dir(path_to_processed_data, recursive=F, pattern = "2016")
previous_data <- read.csv(paste0(path_to_processed_data,"/",data_file))

# extract information and write to CSV file
ct.index <- getCTGiniIndex(raw_data)
ct.index$`Measure Type` <- "Number"
towns    <- getGatheredTownData(ct.index)

colnames(previous_data) <- colnames(towns)

previous_data <- coerceTypes(previous_data)
towns <- coerceTypes(towns)

upto2017 <- rbind(previous_data, towns)

upto2017 <- upto2017 %>% arrange(Town, Year, Variable)

WriteDFToTable(upto2017, "gini-ratio_2017.csv")
