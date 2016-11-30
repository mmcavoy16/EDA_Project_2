setwd("/Users/edelsonc/Desktop/Data_Science/Group_EDA/EDA_Project_2/data/Hospital_Revised_FlatFiles")
na_list <- c("", " ", "Not Available", "NA", "NAN", "NaN")

library(tidyverse)
# load dataframes
general <- read_csv("Hospital General Information.csv", na=na_list)
readmin30_0 <- read_csv("Readmissions and Deaths - Hospital.csv", na=na_list)
image <- read_csv("Outpatient Imaging Efficiency - Hospital.csv", na=na_list)
timely <- read_csv("Timely and Effective Care - Hospital.csv", na=na_list)

# general filter and group by county...add a factor to indicate if repsonse time if above average, average, or below average
general <- general %>% mutate(Location = paste(`County Name`, State)) %>% mutate(Timely=(as.factor(`Timeliness of care national comparison`)))
general_group <- general %>% select(one_of(c("Location", "Hospital overall rating", "Timely"))) %>% mutate(Timely = as.integer(Timely)) %>% group_by(Location) %>% summarise(avgRating = mean(`Hospital overall rating`, na.rm=TRUE), avgTime = as.integer(mean(Timely, rm.na=TRUE)))

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
readmin30_r <- readmin30_0 %>% mutate(Location = paste(`County Name`, State)) %>% filter(`Measure ID`=="READM_30_AMI")
readmin30_r <- readmin30_r %>% select(19, 13, 12) %>% group_by(Location) %>% summarize(avgScr_r=mean(Score, na.rm=TRUE), avgDnm_r = mean(Denominator, na.rm=TRUE))

# join new frame with old combined
general_rd <- inner_join(general_readmin, readmin30_r, by='Location')
str(general_rd)


#######################################################################
# A few simple models
#######################################################################

# find complete cases and cor
gn_rd <- general_rd %>% filter(!(is.na(avgScr)) & !(is.na(avgRating)) & !(is.na(avgScr_r)))
cor(gn_rd[c(2,4,5)])  # cor for all numeric variables
p2 <- ggplot(data=general_rd, aes(x=avgRating, y=avgScr_r)) + geom_point() +geom_smooth(method='lm')  # plot to confirm

# run a lm to check this again
lm_rating_scr_r <- lm(avgScr_r ~ avgRating, data=gn_rd)
summary(lm_rating_scr_r)
plot(lm_rating_scr_r)

# plot both graphs to see the negative correlation with trendline
library(gridExtra)
grid.arrange(p1, p2, ncol=1)

#######################################################################
# ANOVA and ANCOVA
#######################################################################

# attempt an ancova...
ancova_dt <- lm(avgScr ~ avgRating + as.factor(avgTime), data=gn_rd)
summary(ancova_dt)

# ANOVA for score and time
anova_dt <- lm(avgScr ~ as.factor(avgTime), data=gn_rd)
anova(anova_dt)  # not a significant decider in score... p = 0.34


# compare the ancova with the restricted model
lm_rating_scr_tm <- lm(avgScr ~ avgRating, data=gn_rd[complete.cases(gn_rd$avgTime),])
anova(lm_rating_scr_tm, ancova_dt)  # just barely significant...Rating is strong covarient

# finally look at imaging
optics_group <-  image %>% mutate(Location = paste(`County Name`, State))
optics_group <- optics_group %>% select(15,11) %>% group_by(Location) %>% summarise(avgScr_im = mean(Score, na.rm=TRUE))

# merge with original and plot and look at cor
optic_general <- inner_join(readmin30_group, optics_group, by='Location')
optic_cor <- optic_general %>% filter(!(is.na(avgScr)) & !(is.na(avgScr_im)))
cor(optic_cor$avgScr, optic_cor$avgScr_im)  # no correlation
ggplot(data=optic_general, aes(x=avgScr_im, y=avgScr)) + geom_point() + geom_smooth(method='lm')  # plot confirm

# !!! ITS A RISK SCORE !!! LOWER IS BETTER !!!

#######################################################################
# MEDIAN INCOME
#######################################################################

med <- read.csv("../Median/location_median.csv")
med_join <- med %>% select(3,4)
death_med <- inner_join(readmin30_group, med_join, "Location")

# check to see if there is anything here
ggplot(data=death_med, aes(x=INC110213, y=avgScr)) + geom_point() + geom_smooth(method='lm')
cor(death_med[complete.cases(death_med),]$avgScr, death_med[complete.cases(death_med),]$INC110213)
lm_death_md <- lm(avgScr ~ INC110213, data=death_med)
summary(lm_death_md)  # once again, F-stat good, R^2 bad...

#######################################################################
# OBESITY
#######################################################################

# load data and find average percentage for all years
obesity <- read.csv("../obesity.txt", sep='\t')
obesity[seq(5,68,7)] <- obesity %>% select(seq(5,68,7)) %>% mutate_each(funs(as.character)) %>% mutate_each(funs(as.numeric))
obesity <- obesity %>% mutate(avgPercent = (percent + percent.1 + percent.2 + percent.3 + percent.4 + percent.5 + percent.6 + percent.7 + percent.8 + percent.9)/10)

# create new frame and Location columns
obesity_county <- obesity %>% select(1,3,74)

obesity_county$County <- sapply(as.character(obesity_county$County), toupper)
obesity_county$County <- gsub("\ COUNTY", "", obesity_county$County)

get_abv = function(state_name){
  # returns the abbreviation of a state
  if (state_name %in% state.name){
    name = state.abb[[match(state_name, state.name)]]
    return(name)}

  else {return(NA)}
}

# create abbreviation column and location, then form new df by joining to rest of data
obesity_county$State_abv <- sapply(obesity_county$State, get_abv)
obesity_county <- obesity_county %>% mutate(Location = paste(County, State_abv))
df_obesity <- inner_join(gn_rd, obesity_county[c(3,5)], by="Location")

# plot the relationship between Obesity and DS and investigate linear model
ggplot(data=df_obesity, aes(x=avgPercent, y=avgScr)) + geom_point() + geom_smooth(method='lm')
obesity_lm <- lm(avgScr ~ avgPercent, data=df_obesity)
summary(obesity_lm)  # something at least
