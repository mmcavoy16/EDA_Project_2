# Matt McAvoy
# exploration of merged
# November 29, 2016

library(tidyverse)
library(stringr)
library(ggrepel)

setwd("C:/Users/homur/OneDrive/New College/EDA/Project2")
data <- read.csv("Data_concise/merged_data.csv")
str(data)

names(data)
n_data <- data %>% select(-X, -Location)

# By overall.Score
top_score <- data %>% arrange(desc(Overall.Score)) %>% slice(1:20)
bottom_score <- data %>% arrange(Overall.Score) %>% slice(1:20)

bottom_top <- bind_rows(top_score %>% mutate(Rank = "Top"), bottom_score %>% mutate(Rank = "Bottom"))

# Boxplots of bottom scores vs top scores 
ggplot(data = bottom_top, aes(x=Rank)) + geom_boxplot(aes(y=Overall.Score))
ggplot(data = bottom_top, aes(x=Rank)) + geom_boxplot(aes(y=Compl.Score))
ggplot(data = bottom_top, aes(x=Rank)) + geom_boxplot(aes(y=Quests.Stars))
ggplot(data = bottom_top, aes(x=Rank)) + geom_boxplot(aes(y=Infects.Score))
ggplot(data = bottom_top, aes(x=Rank)) + geom_boxplot(aes(y=Spends.Score))
ggplot(data = bottom_top, aes(x=Rank)) + geom_boxplot(aes(y=Values.Payment))
ggplot(data = bottom_top, aes(x=Rank)) + geom_boxplot(aes(y=Deaths.Score))
ggplot(data = bottom_top, aes(x=Rank)) + geom_boxplot(aes(y=Timely.Score))

# By Death Score
top_Dscore <- data %>% arrange(desc(Deaths.Score)) %>% slice(1:20)
bottom_Dscore <- data %>% arrange(Overall.Score) %>% slice(1:20)

D_worst_best <- bind_rows(top_Dscore %>% mutate(Rank = "Worst"), bottom_Dscore %>% mutate(Rank = "Best"))

# Boxplots of bottom scores vs top scores 
ggplot(data = D_worst_best, aes(x=Rank)) + geom_boxplot(aes(y=Overall.Score))
ggplot(data = D_worst_best, aes(x=Rank)) + geom_boxplot(aes(y=Compl.Score))
ggplot(data = D_worst_best, aes(x=Rank)) + geom_boxplot(aes(y=Quests.Stars))
ggplot(data = D_worst_best, aes(x=Rank)) + geom_boxplot(aes(y=Infects.Score))
ggplot(data = D_worst_best, aes(x=Rank)) + geom_boxplot(aes(y=Spends.Score))
ggplot(data = D_worst_best, aes(x=Rank)) + geom_boxplot(aes(y=Values.Payment))
ggplot(data = D_worst_best, aes(x=Rank)) + geom_boxplot(aes(y=Deaths.Score))
ggplot(data = D_worst_best, aes(x=Rank)) + geom_boxplot(aes(y=Timely.Score))

# Not much expected by subsetting on death score, but do see expected by overall score

# 



## State level
state_data <- data %>% mutate(State = str_extract(Location, "\\s..$"))
state_score <- state_data %>% group_by(State) %>% summarise(State.Overall.Score = mean(Overall.Score), State.Deaths.Score = mean(Deaths.Score))
dim(state_score)

ggplot(data = state_score, aes(x=State, y=State.Overall.Score)) + 
		geom_point(shape = 1, size = 2.5) + geom_text_repel(aes(label=State), size = 4) 
ggplot(data = state_score, aes(x=State, y=State.Deaths.Score)) + 
		geom_point(shape = 1, size = 2.5) + geom_text_repel(aes(label=State), size = 4) 


# Standardize scores and stars by Z-score. Scores where lower is better, swapped numerator
# Lower is better: Compl, Infects, Images, Values, Deaths, Timely
# Higher is better: Quests, Overall, Spends, 
std_data <- data %>% mutate(Std.Compl.Score = (mean(Compl.Score) - Compl.Score)/mean(Compl.Score)) %>%
		mutate(Std.Infects.Score = (mean(Infects.Score) - Infects.Score)/mean(Infects.Score)) %>%
		mutate(Std.Images.Score = (mean(Images.Score) - Images.Score)/mean(Images.Score)) %>%
		mutate(Std.Values.Payment = (mean(Values.Payment) - Values.Payment)/mean(Values.Payment)) %>%
		mutate(Std.Deaths.Score = (mean(Deaths.Score) - Deaths.Score)/mean(Deaths.Score)) %>%
		mutate(Std.Timely.Score = (mean(Timely.Score) - Timely.Score)/mean(Timely.Score)) %>%
		mutate(Std.Spends.Score = (Spends.Score - mean(Spends.Score))/mean(Spends.Score)) %>%
		mutate(Std.Quests.Stars = (Quests.Stars - mean(Quests.Stars))/mean(Quests.Stars)) %>%
		mutate(Std.Overall.Score = (Overall.Score - mean(Overall.Score))/mean(Overall.Score)) %>%
		select(Location, Std.Overall.Score, Std.Quests.Stars, Std.Spends.Score, Std.Deaths.Score, Std.Values.Payment, Std.Timely.Score, Std.Compl.Score, Std.Infects.Score, Std.Images.Score) 
str(std_data)
ggplot(data=std_data, aes(x=Std.Overall.Score)) + geom_histogram()
ggplot(data=std_data, aes(x=Std.Quests.Stars)) + geom_histogram()
ggplot(data=std_data, aes(x=Std.Spends.Score)) + geom_histogram()
ggplot(data=std_data, aes(x=Std.Deaths.Score)) + geom_histogram()
ggplot(data=std_data, aes(x=Std.Values.Payment)) + geom_histogram()
ggplot(data=std_data, aes(x=Std.Timely.Score)) + geom_histogram()
ggplot(data=std_data, aes(x=Std.Compl.Score)) + geom_histogram()
ggplot(data=std_data, aes(x=Std.Infects.Score)) + geom_histogram()
ggplot(data=std_data, aes(x=Std.Images.Score)) + geom_histogram()

ylm <- lm(Std.Overall.Score ~ Std.Compl.Score + Std.Infects.Score + Std.Spends.Score + Std.Images.Score + Std.Deaths.Score + Std.Timely.Score, data=std_data)
summary(ylm)
plot(ylm)


# Further 


