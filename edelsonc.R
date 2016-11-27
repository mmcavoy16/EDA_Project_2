setwd("/Users/edelsonc/Desktop/Data_Science/Group_EDA/EDA_Project_2/data/Hospital_Revised_FlatFiles")
na_list <- c("", " ", "Not Available", "NA", "NAN")

library(tidyverse)
# load dataframes
general <- read_csv("Hospital General Information.csv", na=na_list)
readmin30 <- read_csv("Readmissions and Deaths - Hospital.csv", na=na_list)
image <- read_csv("Outpatient Imaging Efficiency - Hospital.csv", na=na_list)
timely <- read_csv("Timely and Effective Care - Hospital.csv", na=na_list)

# filter
general <- general %>% mutate(Location = paste(`County Name`, State)) %>% mutate(Timely=as.integer(as.factor(`Timeliness of care national comparison`)))
general_group <- general %>% select(one_of(c("Location", "Hospital overall rating", "Timely"))) %>% group_by(Location) %>% summarise(avgRating = mean(`Hospital overall rating`, na.rm=TRUE), avgTime = mean(Timely, rm.na=TRUE))

general_group %>% complete.cases() %>% sum()
