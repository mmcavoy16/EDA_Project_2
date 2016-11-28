setwd("/Users/edelsonc/Desktop/Data_Science/Group_EDA/EDA_Project_2/data/Hospital_Revised_FlatFiles")
na_list <- c("", " ", "Not Available", "NA", "NAN", "NaN")

library(tidyverse)
# load dataframes
general <- read_csv("Hospital General Information.csv", na=na_list)
readmin30_0 <- read_csv("Readmissions and Deaths - Hospital.csv", na=na_list)
image <- read_csv("Outpatient Imaging Efficiency - Hospital.csv", na=na_list)
timely <- read_csv("Timely and Effective Care - Hospital.csv", na=na_list)

# general filter and group by county
general <- general %>% mutate(Location = paste(`County Name`, State)) %>% mutate(Timely=as.integer(as.factor(`Timeliness of care national comparison`)))
general_group <- general %>% select(one_of(c("Location", "Hospital overall rating", "Timely"))) %>% group_by(Location) %>% summarise(avgRating = mean(`Hospital overall rating`, na.rm=TRUE), avgTime = as.integer(mean(Timely, rm.na=TRUE)))

ggplot(data=general_group, aes(avgTime)) + geom_bar()
ggplot(data=general_group, aes(avgRating)) + geom_histogram()


# readmin30 filter and group by county for mortality
readmin30 <- readmin30_0 %>% mutate(Location = paste(`County Name`, State)) %>% filter(`Measure ID`=="MORT_30_AMI")
readmin30_group <- readmin30 %>% select(19, 13, 12) %>% group_by(Location) %>% summarise(avgScr=mean(Score, na.rm=TRUE), avgDnm = mean(Denominator, na.rm=TRUE))


ggplot(data=readmin30_group, aes(avgScr)) + geom_histogram()  # plot distribs
ggplot(data=readmin30_group, aes(avgDnm)) + geom_histogram()

# join two new frames first
general_readmin <- inner_join(general_group, readmin30_group, by='Location')

# select only complete cases and find cor between avgRating by county and avgScr by county
gnrm_group <- general_readmin %>% filter(!(is.na(avgScr)) & !(is.na(avgRating)))
cor(gnrm_group$avgRating, gnrm_group$avgScr)  # negative correlation of -0.21
p1 <- ggplot(data=general_readmin, aes(x=avgRating, y=avgScr)) + geom_point() +geom_smooth(method='lm')  # plot to confirm

# run a linear model to check this
lm_rating_scr <- lm(avgScr ~ avgRating, data=general_readmin)
summary(lm_rating_scr)


# readmin30 filter and group by county for readmission
readmin30_r <- readmin30_0 %>% mutate(Location = paste(`County Name`, State)) %>% filter(`Measure ID`=="READM_30_HF")
readmin30_r <- readmin30_r %>% select(19, 13, 12) %>% group_by(Location) %>% summarize(avgScr_r=mean(Score, na.rm=TRUE), avgDnm_r = mean(Denominator, na.rm=TRUE))

# join new frame with old combined
general_rd <- inner_join(general_readmin, readmin30_r, by='Location')
str(general_rd)

# find complete cases and cor
gn_rd <- general_rd %>% filter(!(is.na(avgScr)) & !(is.na(avgRating)) & !(is.na(avgScr_r)))
cor(gn_rd[c(2,4:7)])  # cor for all numeric variables
p2 <- ggplot(data=general_rd, aes(x=avgRating, y=avgScr_r)) + geom_point() +geom_smooth(method='lm')  # plot to confirm

# plot both graphs to see the negative correlation with trendline
library(gridExtra)
grid.arrange(p1, p2, ncol=1)
