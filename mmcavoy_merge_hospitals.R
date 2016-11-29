# Merge data
# Matthew McAvoy
# November 28, 2016

# libraries
library(tidyverse)
library(stringr)

setwd("C:/Users/homur/OneDrive/New College/EDA/Project2")

na_list <- c("", " ", "Not Available", "NA", "NAN", "NaN")

# load dataframes
complies <- read_csv("Data/Complications - Hospital.csv", na=na_list)
quests <- read_csv("Data/HCAHPS - Hospital.csv", na=na_list)
infects <- read_csv("Data/Healthcare Associated Infections - Hospital.csv", na=na_list)
scores <- read_csv("Data/Hospital General Information.csv", na=na_list)
spends <- read_csv("Data/Medicare Hospital Spending per Patient - Hospital.csv", na=na_list)
images <- read_csv("Data/Outpatient Imaging Efficiency - Hospital.csv", na=na_list)
values <- read_csv("Data/Payment and Value of Care - Hospital.csv", na=na_list)
deaths <- read_csv("Data/Readmissions and Deaths - Hospital.csv", na=na_list)
strucs <- read_csv("Data/Structural Measures - Hospital.csv", na=na_list)
timely <- read_csv("Data/Timely and Effective Care - Hospital.csv", na=na_list)


## Objective, group by county for each file and join into one large file.


## ------------- Complications ----------------- ##
#View(complies)
# 11 measures, all look good, so will aggregate by county
# Score is already numeric
complies_q <- complies %>% mutate(Location = paste(`County Name`, State)) %>%
		select(Location, Score) %>% filter(!is.na(Score)) %>%
		group_by(Location) %>% summarise(Compl.Score = mean(Score))
str(complies_q) # 1703 rows
#View(complies_q)
summary(complies_q$Compl.Score)


## ------------- Questionare ----------------- ##
#View(quests)
quests_q <- quests %>% filter(str_detect(`HCAHPS Question`,'Summary star rating')) %>% 
		mutate(Location = paste(`County Name`, State)) %>% 
		rename(Stars = `Patient Survey Star Rating`) %>%
		select(Location, Stars) %>% filter(!is.na(Stars)) %>%
		mutate_each(funs(as.numeric), one_of(c("Stars"))) %>% 
		group_by(Location) %>% summarise(Quests.Stars = mean(Stars))
str(quests_q) # grouping redoced from about 3500 to 1759
#View(quests_q)
summary(quests_q$Quests.Stars)


## ------------- Infections ----------------- ##
View(infects)
# Measures are upper limits and lower limits, Going to filter on Measure ID 'SIR'
# since this seems to be the important row.
infects_q <- infects %>% filter(str_detect(`Measure ID`, 'SIR')) %>%
		mutate(Location = paste(`County Name`, State)) %>% 
		select(Location, Score) %>% 
		filter(!is.na(Score)) %>%
		group_by(Location) %>% summarise(Infects.Score = mean(Score))
str(infects_q) # 1624 rows
#View(infects_q)
summary(infects_q$Infects.Score)


## ------------- Overall Score ----------------- ##
View(scores)
scores_q <- scores %>% mutate(Location = paste(`County Name`, State)) %>%
		select(Location, `Hospital overall rating`) %>%
		rename(Score = `Hospital overall rating`) %>%
		filter(!is.na(Score)) %>%
		group_by(Location) %>% summarise(Overall.Score = mean(Score))
str(scores_q) # 1916
#View(scores_q)
summary(scores_q$Overall.Score)


## ------------- Medicare Spending ----------------- ##
#View(spends)
# Measures are all the same as medicare spending, and score is numeric
spends_q <- spends %>% mutate(Location = paste(`County Name`, State)) %>%
		select(Location, Score) %>%
		filter(!is.na(Score)) %>%
		group_by(Location) %>% summarise(Spends.Score = mean(Score))
str(spends_q) # 1503
View(spends_q)
summary(spends_q$Spends.Score)


## ------------- Imaging Efficiency ----------------- ##
# View(images)
# Only six measures, none specific to MI, retained all in aggregation
images_q <- images %>% mutate(Location = paste(`County Name`, State)) %>%
		select(Location, Score) %>%	
		filter(!is.na(Score)) %>%
		group_by(Location) %>% summarise(Images.Score = mean(Score))
str(images_q) # 2052
#View(images_q)
summary(images_q$Images.Score)


## ------------- Value of Care ----------------- ##
View(values)
# Retain only heart attack and heart failure rows, not including pneumonia cases.
# Convert payment to numeric by removing comma and dollar sign
values_q <- values %>% filter(str_detect(`Payment measure ID`, 'AMI|HF')) %>%
		mutate(Location = paste(`County name`, State)) %>%
		select(Location, Payment) %>%
		mutate(NumPayment = gsub(",|\\$", "", Payment)) %>%
		mutate_each(funs(as.numeric), one_of(c("NumPayment"))) %>%
		filter(!is.na(NumPayment)) %>% 
		group_by(Location) %>% summarise(Values.Payment = mean(NumPayment))
str(values_q) # 1967
View(values_q)
summary(values_q$Values.Payment)


## ------------- Readmissions and Deaths ----------------- ##
# View(deaths)
# 14 measures, most interested in death rate for stroke patients as measure ID = MORT_30_HF
# score is numeric
deaths_q <- deaths %>% filter(`Measure ID` == "MORT_30_HF") %>% 
		mutate(Location = paste(`County Name`, State)) %>%
		select(Location, Score) %>%
		filter(!is.na(Score)) %>%
		group_by(Location) %>% summarise(Deaths.Score = mean(Score))
str(deaths_q) # 2004
View(deaths_q)
summary(deaths_q$Deaths.Score)


## ------------- Structural Measures ----------------- ##
# View(strucs)
# 7 measures, no score. Dropped from futher analysis.


## ------------- Timely Care ----------------- ##
# View(timely)
# 43 measures. 
# Retain only heart attack or chest pain measures, reduces to 7 measures.
timely_q <- timely %>% filter(str_detect(`Condition`, "Heart Attack")) %>% 
		mutate(Location = paste(`County Name`, State)) %>%
		select(Location, Score) %>%
		mutate_each(funs(as.numeric), one_of(c("Score"))) %>%
		filter(!is.na(Score)) %>%
		group_by(Location) %>% summarise(Timely.Score = mean(Score))
str(timely_q) # 1633
View(timely_q)
summary(timely_q$Timely.Score)


## ------------- Merge data ----------------- ##

full_data = complies_q %>% inner_join(quests_q) %>% inner_join(infects_q) %>% 
		inner_join(scores_q) %>% inner_join(spends_q) %>% 
		inner_join(images_q) %>% inner_join(values_q) %>% 
		inner_join(deaths_q) %>% inner_join(timely_q)
str(full_data) # 1145 rows.


