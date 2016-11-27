## Matthew McAvoy
## November 17, 2016
## Group Project II

## File will want is Hospital revised flat files.

library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(datasets)

# With data saved in a 'Data' folder, move to just outside it
setwd("C:/Users/homur/OneDrive/New College/EDA/Project2")


------------- helper functions -------------
# Remove NA's
clean_nas <- function(data, i) {
	nai <- which(data[,i] == "Not Available")
	data[nai,] <- "NA"
	data[,i] <- as.numeric(as.character(data[,i]))
	return(data[,i])
}

# Retain only fifty states
fifty_states <- function(data) {
	data$State <- as.character(data$State)
	fifty <- which(data$State %in% state.abb)
	datareturn <- data[fifty,]
	return(datareturn)
}


#------------- Load HCAHPS data -------------
quest <- read.csv("Data/HCAHPS - State.csv")

ques_q <- quest %>% select(State, HCAHPS.Answer.Description, HCAHPS.Answer.Percent) 
names(ques_q) <- c("State", "Question", "Ans.Percent")
ques_q[,3] <- as.numeric(as.character(ques_q[,3]))# some coerced to NA
ques_q <- fifty_states(ques_q)
#head(ques_q)
str(ques_q)

#----- Group data by postive answer ----#
# grep and sum to reduce to single line for each state
# grep "always", "did", "Strongly Agree", "10", 'definitely recommend', 
# filter on 50 states
ques_q <- ques_q %>% filter(str_detect(Question, '"always"|"did"|"Strongly Agree"|"10",definitely recommend'))
ques_qs <- ques_q %>% group_by(State) %>% summarise(avg_score = mean(Ans.Percent)) %>%
	mutate(Ques.Std.Score = (avg_score - mean(avg_score))/avg_score)

#View(ques_qs)


#------------- Load timely data -------------#
timely <- read.csv("Data/Timely and Effective Care - State.csv")

timely_q <- timely %>% select(State, Condition, Measure.Name, Score)
timely_q <- timely_q %>% filter(str_detect(Condition, 'Heart|Emergency|Preventative|Stroke'))
names(timely_q) <- c("State", "Timely.Condition", "Timely.Measure.Name", "Timely.Score")
timely_q[,4] <- as.numeric(as.character(timely_q[,4]))
timely_q <- fifty_states(timely_q)
str(timely_q)



#----- Group data by avg wait time ----#
# Need to compute average by Measure. then standardize for each measure.
# Then aggregate by standard time score.
# unique(timely_q$Timely.Measure.Name) # 58 unique variables per state for aggregating

avg_condition <- timely_q %>% filter(!is.na(Timely.Score)) %>% 
	group_by(Timely.Measure.Name) %>% 
	summarise(avg_score = mean(Timely.Score))

# join back to timely
timely_qj <- left_join(timely_q, avg_condition)

# standardize
timely_qj <- timely_qj %>% filter(!is.na(Timely.Score)) %>% 
	mutate(Std.Score = (Timely.Score - avg_score)/avg_score)
timely_qj <- timely_qj %>% select(State, Std.Score)
# With standard time score, sum to aggregate for each state
timely_qs <- timely_qj %>% group_by(State) %>% 
	summarise(Timely.Std.Score = sum(Std.Score))
#View(timely_qs)

# Final results says standardized wait time for a number of different events. larger negative is better


#------------- Load complications data -------------#
complies <- read.csv("Data/Complications - State.csv")
str(complies)
complies_q <- complies %>% select(State, Measure.Name, Number.of.Hospitals.Worse, Number.of.Hospitals.Same, Number.of.Hospitals.Better, Number.of.Hospitals.Too.Few)
names(complies_q) = c("State", "Compl.Measure.Name", "Compl.Num.H.Worse", "Compl.Num.H.Same", "Compl.Num.H.Better", "Compl.Num.H.Few")
complies_q <- complies_q %>% filter(str_detect(Compl.Measure.Name, 'Serious|Deaths|Blood'))
complies_q <- fifty_states(complies_q)

complies_q[,3] <- clean_nas(complies_q, 3)
complies_q[,4] <- clean_nas(complies_q, 4)
complies_q[,5] <- clean_nas(complies_q, 5)
complies_q[,6] <- clean_nas(complies_q, 6)


#----- Group data by ratio same or better/total hospitals ----#
#unique(complies_q$Compl.Measure.Name) # 4 complications to aggregate on

nai <- which(is.na(complies_q[,6]))
complies_q[nai,6] <- 0

complies_qj <- complies_q %>% filter(complete.cases(Compl.Num.H.Worse)) %>%
	mutate(Compl.Num.H.Tot = (Compl.Num.H.Worse + Compl.Num.H.Same + Compl.Num.H.Better + Compl.Num.H.Few))
complies_qj2 <- complies_qj %>% group_by(State) %>% 
	summarise(Sum.Same = sum(Compl.Num.H.Same), Sum.Better = sum(Compl.Num.H.Better), Sum.Total = sum(Compl.Num.H.Tot))

complies_qs <- complies_qj2 %>% 
	mutate(Compl.Ratio.Same = Sum.Same/Sum.Total) %>%
	mutate(Compl.Ratio.Better = Sum.Better/Sum.Total) %>%
	select(State, Compl.Ratio.Same, Compl.Ratio.Better)
#complies_qs %>% arrange(Compl.Ratio.Same) %>% View()


#------------- Load deaths data -------------
deaths <- read.csv("Data/Readmissions and Deaths - State.csv")

deaths_q <- deaths %>% select(State, Measure.Name, Number.of.Hospitals.Worse, Number.of.Hospitals.Same, Number.of.Hospitals.Better, Number.of.Hospitals.Too.Few)
names(deaths_q) = c("State", "Death.Measure.Name", "Death.Num.H.Worse", "Death.Num.H.Same", "Death.Num.H.Better", "Death.Num.H.Few")
deaths_q <- fifty_states(deaths_q)

deaths_q[,3] <- clean_nas(deaths_q, 3)
deaths_q[,4] <- clean_nas(deaths_q, 4)
deaths_q[,5] <- clean_nas(deaths_q, 5)
deaths_q[,6] <- clean_nas(deaths_q, 6)
str(deaths_q)


#----- Group data by ratio same or better/total hospitals ----#
#unique(deaths_q$Death.Measure.Name) # 14 complications to aggregate on

#nai <- which(is.na(deaths_q[,6]))
#deaths_q[nai,6] <- 0

deaths_qj <- deaths_q %>% filter(complete.cases(Death.Num.H.Worse)) %>%
	mutate(Death.Num.H.Tot = (Death.Num.H.Worse + Death.Num.H.Same + Death.Num.H.Better + Death.Num.H.Few))
#str(deaths_qj)

deaths_qj2 <- deaths_qj %>% group_by(State) %>% 
	summarise(Sum.Same = sum(Death.Num.H.Same), Sum.Better = sum(Death.Num.H.Better), Sum.Total = sum(Death.Num.H.Tot))
#View(deaths_qj2)
deaths_qs <- deaths_qj2 %>% 
	mutate(Death.Ratio.Same = Sum.Same/Sum.Total) %>%
	mutate(Death.Ratio.Better = Sum.Better/Sum.Total) %>%
	select(State, Death.Ratio.Same, Death.Ratio.Better)
#deaths_qs %>% arrange(Death.Ratio.Same) %>% View()
View(deaths_q)

#------------- Load ratings data -------------
ratings <- read.csv("Data/Hospital General Information.csv")

ratings_q <- ratings %>% select(State, Hospital.overall.rating)
ratings_q <- fifty_states(ratings_q)

ratings_q[,2] <- clean_nas(ratings_q, 2)
dim(ratings_q); str(ratings_q)


#----- Group data by State ----#

nai <- which(is.na(ratings_q[,2]))
ratings_q[nai,2] <- 0

ratings_qs <- ratings_q %>% group_by(State) %>% 
	summarise(Avg.Overall.Score = mean(Hospital.overall.rating))
str(ratings_qs)


------------- Load payments data -------------
payments <- read.csv("Data/Payment and Value of Care - Hospital.csv", header=TRUE)

payments_q <- payments %>% filter(str_detect(Payment.measure.name, 'heart attack'))
payments_q <- payments_q %>% select(State, Payment)

payments_q <- fifty_states(payments_q)

# need special cleaning since in dollar format
payments_q[,2] <- gsub(",", "", payments_q[,2])
payments_q[,2] <- gsub("\\$", "", payments_q[,2]) # $ is a special character
payments_q[,2] <- clean_nas(payments_q, 2)

# lame row.names wasn't easy to remove
payments_q1 <- as.data.frame(payments_q[,1])
payments_q2 <- as.data.frame(payments_q[,2])
payments_q3 <- bind_cols(payments_q1, payments_q2)
payments_q3[,1] <- as.character(payments_q3[,1])
names(payments_q3) <- c("State", "Payment")

dim(payments_q3); str(payments_q3)
str(payments_q3)

#----- Group data by State ----#

nai <- which(is.na(payments_q3[,2]))
payments_q3[nai,2] <- 0

payments_qs <- payments_q3 %>% group_by(State) %>% 
	summarise(Avg.Payment = mean(Payment))
str(payments_qs)
#View(payments_qs)

#------------- Merge data -------------#
dim(ques_qs); dim(timely_qs); dim(complies_qs); dim(deaths_qs); dim(ratings_qs); dim(payments_qs)
str(ques_qs); str(timely_qs); str(complies_qs); str(deaths_qs); str(ratings_qs); str(payments_qs)

full_data <- ques_qs %>% inner_join(timely_qs) %>% 
		inner_join(complies_qs) %>% inner_join(deaths_qs) %>%
		inner_join(ratings_qs) %>% inner_join(payments_qs)
full_data <- full_data %>% select(State, Avg.Overall.Score, Avg.Payment, avg_score, Ques.Std.Score, Timely.Std.Score, Compl.Ratio.Same, Compl.Ratio.Better, Death.Ratio.Same, Death.Ratio.Better)
dim(full_data); View(full_data)



#------------- Graphics -------------#
# Maryland is missing

dp <- prcomp(full_data[,-1], center=TRUE, scale=TRUE)
print(dp)
summary(dp)

ggplot(data=full_data) + geom_histogram(aes(x=Avg.Overall.Score))
ggplot(data=full_data) + geom_histogram(aes(x=Avg.Payment))
ggplot(data=full_data) + geom_histogram(aes(x=avg_score))
ggplot(data=full_data) + geom_histogram(aes(x=Ques.Std.Score))
ggplot(data=full_data) + geom_histogram(aes(x=Timely.Std.Score))
ggplot(data=full_data) + geom_histogram(aes(x=Compl.Ratio.Same))
ggplot(data=full_data) + geom_histogram(aes(x=Compl.Ratio.Better))
ggplot(data=full_data) + geom_histogram(aes(x=Death.Ratio.Same))
ggplot(data=full_data) + geom_histogram(aes(x=Death.Ratio.Better))

ggplot(data=full_data, aes(y=Avg.Overall.Score)) + geom_smooth(aes(x=Avg.Payment))
ggplot(data=full_data, aes(y=Avg.Overall.Score)) + geom_smooth(aes(x=avg_score))
ggplot(data=full_data, aes(y=Avg.Overall.Score)) + geom_smooth(aes(x=Ques.Std.Score))
ggplot(data=full_data, aes(y=Avg.Overall.Score)) + geom_smooth(aes(x=Timely.Std.Score))
ggplot(data=full_data, aes(y=Avg.Overall.Score)) + geom_smooth(aes(x=Compl.Ratio.Same))
ggplot(data=full_data, aes(y=Avg.Overall.Score)) + geom_smooth(aes(x=Compl.Ratio.Better))
ggplot(data=full_data, aes(y=Avg.Overall.Score)) + geom_smooth(aes(x=Death.Ratio.Same)) #strongest
ggplot(data=full_data, aes(y=Avg.Overall.Score)) + geom_smooth(aes(x=Death.Ratio.Better))


# Initial exploration shows states that cost more (to a degree) and states 
# that perform better in reducing deaths and readmissions (measured by 
# number of hospitals in that state that perform the same as average nationally
# over total number of hospitals in that state. Generally, less deaths overall
# will include reducing deaths by heart attack.


