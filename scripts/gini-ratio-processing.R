library(dplyr)
library(datapkg)
library(tidyr)

##################################################################
#
# Processing Script for Gini Ratio
# Created by Jenna Daly
# On 09/19/2017
#
##################################################################

#Setup environment
sub_folders <- list.files()
raw_location <- grep("raw", sub_folders, value=T)
path_to_raw_data <- (paste0(getwd(), "/", raw_location))
GR_data <- dir(path_to_raw_data, recursive=T, pattern = ".csv") 

GR_df <- data.frame(stringsAsFactors = FALSE)
for (i in 1:length(GR_data)) {
  current_file <- read.csv(paste0(path_to_raw_data, "/", GR_data[i]), stringsAsFactors = FALSE, header=T, check.names = F) 
  #only grab FIPS, GR, and MOE
  current_file <- current_file[,c(2,4,5)]
  colnames(current_file) <- c("FIPS", "Gini Ratio", "Margins of Error")
  current_file <- current_file[-1,] 
  get_year <- (as.numeric(substr(unique(unlist(gsub("[^0-9]", "", unlist(GR_data[i])), "")), 1, 2)))+2000
  current_file$Year <- paste(get_year-4, get_year, sep="-")
  GR_df <- rbind(GR_df, current_file)
}

#Merge in Town names by FIPS
town_fips_dp_URL <- 'https://raw.githubusercontent.com/CT-Data-Collaborative/ct-town-list/master/datapackage.json'
town_fips_dp <- datapkg_read(path = town_fips_dp_URL)
fips <- (town_fips_dp$data[[1]])

GR_df_fips <- merge(GR_df, fips, by = "FIPS", all.y=T)

#convert to long format
GR_df_fips_long <- gather(GR_df_fips, Variable, Value, 2:3, factor_key=FALSE)

#Set Measure Type
GR_df_fips_long$`Measure Type` <- "Number"

#Order and sort columns
GR_df_fips_long <- GR_df_fips_long %>% 
  select(Town, FIPS, Year, `Measure Type`, Variable, Value) %>% 
  arrange(Town, Year, Variable)

# Write to File
write.table(
  GR_df_fips_long,
  file.path(getwd(), "data", "gini-ratio_2015.csv"),
  sep = ",",
  row.names = F
)

