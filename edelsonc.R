setwd("/Users/edelsonc/Desktop/Data_Science/Group_EDA/EDA_Project_2/data/Hospital_Revised_FlatFiles")
na_list <- c("", " ", "Not Available", "NA", "NAN", "NaN")

library(tidyverse)
# load dataframes
general <- read_csv("Hospital General Information.csv", na=na_list)
readmin30 <- read_csv("Readmissions and Deaths - Hospital.csv", na=na_list)
image <- read_csv("Outpatient Imaging Efficiency - Hospital.csv", na=na_list)
timely <- read_csv("Timely and Effective Care - Hospital.csv", na=na_list)

# general filter and group by county
general <- general %>% mutate(Location = paste(`County Name`, State)) %>% mutate(Timely=as.integer(as.factor(`Timeliness of care national comparison`)))
general_group <- general %>% select(one_of(c("Location", "Hospital overall rating", "Timely"))) %>% group_by(Location) %>% summarise(avgRating = mean(`Hospital overall rating`, na.rm=TRUE), avgTime = as.integer(mean(Timely, rm.na=TRUE)))

ggplot(data=general_group, aes(avgTime)) + geom_bar()
ggplot(data=general_group, aes(avgRating)) + geom_histogram()


# readmin30 filter and group by county
readmin30 <- readmin30 %>% mutate(Location = paste(`County Name`, State)) %>% filter(`Measure ID`=="MORT_30_AMI")
readmin30_group <- readmin30 %>% select(19, 13, 12) %>% group_by(Location) %>% summarise(avgScr=mean(Score, na.rm=TRUE), avgDnm = mean(Denominator, na.rm=TRUE))

ggplot(data=readmin30_group, aes(avgScr)) + geom_histogram()
ggplot(data=readmin30_group, aes(avgDnm)) + geom_histogram()

# join two new frames
general_readmin <- inner_join(general_group, readmin30_group, by='Location')

# select only complete cases and find cor
gnrm_group <- general_readmin[complete.cases(general_readmin),]
cor(gnrm_group$avgRating, gnrm_group$avgScr)
ggplot(data=gnrm_group, aes(x=avgScr, y=avgRating)) + geom_point() +geom_smooth(method='lm')
