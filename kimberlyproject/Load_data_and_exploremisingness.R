# Authour: Thamu and Deborah -----------------------------------------------------------
# Updated: 8/2/2020 --------------------------------------------------------------------
# Summary:
# Explore missing data and missingness mechanisms (pattern and relationships of missingness)

# libraries
library(readr)
library(ggplot2)
library(naniar)
library(tidyr)
library(esquisse)


# Import the raw_data as CSV
rawdata_1895 <- read_csv("./data/Kimberley_data_1895.csv",na=c('.',NA,NULL,'NA','NULL'))
rawdata_1900 <- read_csv("./data/Kimberley_data_1900.csv",na=c('.',NA,NULL,'NA','NULL'))
rawdata_1905 <- read_csv("./data/Kimberley_data_1905.csv",na=c('.',NA,NULL,'NA','NULL'))
rawdata_1925 <- read_csv("./data/Kimberley_data_1925.csv",na=c('.',NA,NULL,'NA','NULL'))
rawdata_1930 <- read_csv("./data/Kimberley_data_1930.csv",na=c('.',NA,NULL,'NA','NULL'))
rawdata_1935 <- read_csv("./data/Kimberley_data_1930.csv",na=c('.',NA,NULL,'NA','NULL'))
rawdata_1940 <- read_csv("./data/Kimberley_data_1930.csv",na=c('.',NA,NULL,'NA','NULL'))


dim(rawdata_1895) # Dimensions
n_var_miss(rawdata_1895) # How many features have missing values

# Visualize missing data
vis_miss(rawdata_1895,warn_large_data=FALSE)+   
  labs(title = "Relationship of missingness (Raw data)",
       subtitle = "16 features and 80983 observations.",
       y = "Observation", x = "")

# Explore missingness
gg_miss_which(rawdata_1895)+   
  labs(title = "raw data 1895 ",
       subtitle = "7 features have missing values. Now have 27 features and 1339 observations .",
       y = "", x = "Features" )

gg_miss_fct(rawdata_1895, Town)

#Sources:
#   https://rstudio-pubs-static.s3.amazonaws.com/4625_fa990d611f024ea69e7e2b10dd228fe7.html
#   https://cran.r-project.org/web/packages/naniar/vignettes/naniar-visualisation.html


