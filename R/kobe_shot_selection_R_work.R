# Kobe Bryant Shot Selection EDA - Predictive Analysis.

# Libraries
library(dplyr)
library(ggplot2)
library(caTools)
library(caret)
library(plotly)
library(ggthemes)
library(openxlsx)
library(scales)
library(patchwork)
library(ggwordcloud)
library(GGally)
library(DescTools)

# Import Dataset

kobe <- read.csv('Black_Mamba_Data.csv', header = TRUE, sep = ';')

# Explore Dataset
str(kobe)
summary(kobe)

# Search for NA's
# With the summary we observed that in the variable shot_made_flag there are 5000 NA's.
# Another way is with mice package
#library(mice)
#md.pattern(kobe)
# With this method our result is confirmed.

# So, the next step is to handle the NA's. One thought is to remove all these 5000 observations. 
# With this dataset, it is the only way because the NA's we have represent the test set called
# "submission file".
# So at this moment let's import the test set. We are going to use it after the descriptive analysis.

test_set<- read.csv('sample_submission.csv', header=TRUE, sep = ',')

# To continue we will transform the character variables in to factors.
kobe$action_type <- as.factor(kobe$action_type)
kobe$combined_shot_type <- as.factor(kobe$combined_shot_type)
kobe$shot_made_flag <- as.factor(kobe$shot_made_flag)
kobe$shot_type <- as.factor(kobe$shot_type)
kobe$shot_zone_area <- as.factor(kobe$shot_zone_area)
kobe$shot_zone_basic <- as.factor(kobe$shot_zone_basic)
kobe$shot_zone_range <- as.factor(kobe$shot_zone_range)
kobe$opponent <- as.factor(kobe$opponent)
kobe$playoffs <- as.factor(kobe$playoffs)
levels(kobe$playoffs) <- c('Regural Season', 'Playoffs')
kobe$period <- as.factor(kobe$period)
kobe$minutes_remaining <- as.factor(kobe$minutes_remaining)


# Furthermore, we have 1 variable that would be better to be date variable and not character. 
kobe$game_date <- as.Date(kobe$game_date)
kobe$game_date <- format(kobe$game_date, "%d-%m-%y")

# It is fact the Kobe Bryant played only for Los Angeles Lakers. So we dont need the variables
# team_name, team_id, game_event_id, game_id in our dataset. (Matchup covered by opponent).
kobe <- kobe[ , -c(3,4,20,21)]
head(kobe)


                           # Descriptive Statistics

# Categorical Variables
table(kobe$action_type)
table(kobe$combined_shot_type)
point_shot_type<- data.frame(prop.table(table(kobe$shot_type)))
point_shot_type$per<- percent(point_shot_type$Freq)
names(point_shot_type)[names(point_shot_type) == "Var1"] <- "Shot_Type_by_Point"
table(kobe$shot_zone_area)
table(kobe$shot_zone_basic)
table(kobe$shot_zone_range)
table(kobe$season)
table(kobe$playoffs)
table(kobe$period)
kobe$home_at <- ifelse(grepl("@", kobe$matchup), 'Away', 'Home')
table(kobe$home_at)
shots_by_court <- data.frame(prop.table(table(kobe$home_at)))
shots_by_court$per <- percent(shots_by_court$Freq)
names(shots_by_court)[names(shots_by_court) == "Var1"] <- "Game Played"


# Graphs
combined_shot_type_graph <- ggplot(data=kobe, aes(x=combined_shot_type))+
  geom_bar(fill='gold3')+
  ggtitle("Kobe's Shots Type")+
  theme_economist()+
  ylab('Shots')+
  xlab('Combined Shot Type')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.6,
    size = 5,
    position = position_stack(vjust = 1)
  )


kobe_colors <- c('gold3', 'purple')
point_shot_type_graph <- ggplot(point_shot_type, aes(x = "", y = Freq, fill = Shot_Type_by_Point)) +
  geom_col() +
  geom_label(aes(label = per),
             position = position_stack(vjust = 0.5),
             show.legend = FALSE) +
  coord_polar(theta = "y")+
  ggtitle("Kobe's Shot Type by Point")+
  theme_void()+
  scale_fill_manual(values = kobe_colors)+
  xlab('')+
  ylab('')

shots_by_court_graph <- ggplot(shots_by_court, aes(x = "", y = Freq, fill = `Game Played`)) +
  geom_col() +
  geom_label(aes(label = per),
             position = position_stack(vjust = 0.5),
             show.legend = FALSE) +
  coord_polar(theta = "y")+
  ggtitle("Kobe's Shots by Playing Home or Away")+
  theme_void()+
  scale_fill_manual(values = kobe_colors)+
  xlab('')+
  ylab('')

shots_vs_court_graph <- ggplot(data=kobe, aes(x=home_at, fill=shot_type))+
  geom_bar()+
  ggtitle("Kobe's Shots Type by Home or Away Game")+
  theme_economist()+
  ylab('Shots')+
  xlab('Game Played')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.6,
    size = 5,
    position = position_stack(vjust = 0)
  )+
  scale_fill_manual(values=kobe_colors)

shot_zone_area_graph <- ggplot(data=kobe, aes(x=shot_zone_area))+
  geom_bar(fill='gold3')+
  ggtitle("Kobe's Shots by Zone Area")+
  theme_economist()+
  ylab('Shots')+
  xlab('Shot Zone Area')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.6,
    size = 5,
    position = position_stack(vjust = 1)
  )+
  theme(axis.text.x = element_text(angle = 25, vjust = 1, hjust=1))

shot_zone_basic_graph <- ggplot(data=kobe, aes(x=shot_zone_basic))+
  geom_bar(fill='gold3')+
  ggtitle("Kobe's Shots by Zone Area (Basic)")+
  theme_economist()+
  ylab('Shots')+
  xlab('Shot Zone Basic')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.6,
    size = 5,
    position = position_stack(vjust = 1)
  )+
  theme(axis.text.x = element_text(angle = 25, vjust = 1, hjust=1))

shot_zone_range_graph <- ggplot(data=kobe, aes(x=shot_zone_range))+
  geom_bar(fill='gold3')+
  ggtitle("Kobe's Shots by Range")+
  theme_economist()+
  ylab('Shots')+
  xlab('Shot Zone Range')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.6,
    size = 5,
    position = position_stack(vjust = 1)
  )

shots_by_period_graph <- ggplot(data=kobe, aes(x=period, fill=shot_type))+
  geom_bar(position='dodge')+
  ggtitle("Kobe's Shots Type by Period")+
  theme_economist()+
  ylab('Shots')+
  xlab('Period')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.5,
    size = 5,
    position = position_dodge(width = 0.9)
  )+
  scale_fill_manual(values=kobe_colors)

shots_by_playoff_graph <- ggplot(data=kobe, aes(x=playoffs, fill=shot_type))+
  geom_bar()+
  ggtitle("Kobe's Shots Type by Game Type")+
  theme_economist()+
  ylab('Shots')+
  xlab('Game Type')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.6,
    size = 5,
    position = position_stack(vjust = 1)
  )+
  scale_fill_manual(values=kobe_colors)

shots_type_per_season_graph <- ggplot(data=kobe, aes(x=season, fill=shot_type))+
  geom_bar()+
  ggtitle("Kobe's Shots Type per Season")+
  theme_economist()+
  ylab('Shots')+
  xlab('Season')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.3,
    size = 4,
    position = position_stack(vjust = 1)
  )+
  scale_fill_manual(values=kobe_colors)

combined_shot_type_by_game_type_graph <- ggplot(data=kobe, aes(fill=playoffs, x=combined_shot_type))+
  geom_bar(position = 'dodge')+
  ggtitle("Kobe's Combined Shots Type by Game Type")+
  theme_economist()+
  ylab('Shots')+
  xlab('Shot Type')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.5,
    size = 5,
    position = position_dodge(width = 0.9)
  )+
  scale_fill_manual(values=kobe_colors)

combined_shot_type_graph + shot_zone_area_graph 
shot_zone_basic_graph + shot_zone_range_graph
point_shot_type_graph + shots_by_court_graph
shots_by_period_graph + shots_by_playoff_graph
shots_type_per_season_graph
combined_shot_type_by_game_type_graph

kobe_seasons <- kobe %>%
  group_by(season) %>%
  summarize(count = n()) %>%
  arrange(season)

kobe_seasons_graph <- ggplot(data=kobe_seasons, aes(x=season, y=count, group=1))+
  geom_point(color='gold3', shape=16, size=4)+
  geom_line(color='purple', size=2)+
  ggtitle("Kobe's Shots per Season")+
  theme_economist()+
  ylab('Shots')+
  xlab('Season')+
  geom_text(
    aes(label = count),
    colour='black',
    vjust = -0.6,
    size = 4
  )
kobe_seasons_graph

kobe$opponent <- as.character(kobe$opponent)
kobe$opponent <- ifelse(grepl("VAN", kobe$opponent), 'MEM', kobe$opponent)
kobe$opponent <- ifelse(grepl("SEA", kobe$opponent), 'OKC', kobe$opponent)
kobe$opponent <- ifelse(grepl("NOH", kobe$opponent), 'NOP', kobe$opponent)
kobe$opponent <- ifelse(grepl("NJN", kobe$opponent), 'BKN', kobe$opponent)
kobe$opponent <- ifelse(grepl("VAN", kobe$opponent), 'MEM', kobe$opponent)

shots_against_opponents_graph <- ggplot(data=kobe, aes(y=opponent))+
  geom_bar(fill='gold3')+
  ggtitle("Kobe's Shots by Opponent Team")+
  theme_economist()+
  ylab('Opponent Team')+
  xlab('Shots')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = 0.3,
    hjust=-0.1,
    size = 5,
    position = position_stack(vjust = 1)
  )
shots_against_opponents_graph



minutes_remaining_graph <- ggplot(data=kobe, aes(x=minutes_remaining))+
  geom_bar(fill='gold3')+
  ggtitle("Minutes Remaining after Kobe's Shot")+
  theme_economist()+
  ylab('Shots')+
  xlab('Minutes Remaining')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.5,
    size = 5,
    position = position_dodge(width = 0.9)
  )

minutes_remaining_graph

action_type <- kobe %>%
  group_by(action_type) %>%
  count(action_type)

set.seed(123)
action_type_wordcloid <- ggwordcloud(words = action_type$action_type, freq = action_type$n)
action_type_wordcloid

# Numerical Variables

summary(kobe$shot_distance)
sd(kobe$shot_distance)

shot_distance_hist <- ggplot(kobe, aes(x=shot_distance))+
  geom_histogram(aes(y = ..density..),colour = 1, fill = "gold3", bins =30)+
  geom_density(colour='purple')+
  ggtitle("Histogram of Kobe's Shot Distance")+
  theme_economist()+
  xlab('Shot Distance')

shot_distance_boxplot <- ggplot(kobe, aes(y=shot_distance, x=" "))+
  geom_jitter(color='gold3', alpha=0.4)+
  geom_boxplot(color='purple')+
  ggtitle("Boxplot of Kobe's Shot Distance")+
  theme_economist()+
  xlab('Shot Distance')
  
shot_distance_violin <- ggplot(kobe, aes(y=shot_distance, x=" "))+
  geom_jitter(color='gold3', alpha=0.4)+
  geom_violin(color='purple', fill='purple')+
    ggtitle("Violin Plot of Kobe's Shot Distance")+
  theme_economist()+
  xlab('Shot Distance')

shot_distance_hist + shot_distance_violin

# Basketball Court Graphs - Spots

library(grid)
library(jpeg)
library(RCurl)

# half court image
courtImg.URL <- "https://thedatagame.com.au/wp-content/uploads/2016/03/nba_court.jpg"

download.file(courtImg.URL, destfile = "court_image.jpg", mode = "wb")

# Read the local image file
court <- rasterGrob(readJPEG("court_image.jpg"),
                    width=unit(1, "npc"), height=unit(1, "npc"))


court_1 <- ggplot(kobe, aes(x=loc_x, y=loc_y, color=shot_type))+
             annotation_custom(court, -255, 255, -50, 420)+
             geom_jitter()+
             xlim(-255, 255) +
             ylim(-50, 420)+
             scale_color_manual(values = kobe_colors)+
             theme_economist()+
             ggtitle("Shots Representd on the court by Point Type")

court_2 <- ggplot(kobe, aes(x=loc_x, y=loc_y, color=shot_zone_basic))+
              annotation_custom(court, -255, 255, -50, 420)+
              geom_jitter()+
              xlim(-255, 255) +
              ylim(-50, 420)+
              theme_economist()+
              ggtitle("Shots Represented on the court based on Zone")
  
court_3 <- ggplot(kobe, aes(x=loc_x, y=loc_y, color=shot_distance))+
              annotation_custom(court, -255, 255, -50, 420)+
              geom_jitter()+
              xlim(-255, 255) +
              ylim(-50, 420)+
              theme_economist()+
              scale_color_gradient(low="darkred", high="white")+
              ggtitle("Shots Represented on the court based on Distance")

court_4 <- ggplot(kobe, aes(x=loc_x, y=loc_y, color=shot_zone_range))+
              annotation_custom(court, -255, 255, -50, 420)+
              geom_jitter()+
              xlim(-255, 255) +
              ylim(-50, 420)+
              theme_economist()+
              ggtitle("Shots Represented on the court based on Range")
court_1 + court_3 
court_2
court_4

# Now, we will create a subset which will be contain the data with value 1 in the
# variable shot_flag

# The main dataset for the models 

kobe_basic <- kobe %>%
  na.omit()

kobe_buckets <- kobe_basic %>%
  group_by(shot_made_flag) %>%
  filter(shot_made_flag == 1)


kobe_buckets_graph_by_zone <- ggplot(data=kobe_buckets, aes(x=shot_zone_basic))+
  geom_bar(fill='gold3')+
  ggtitle("Kobe's Buckets by Zone Area (Basic)")+
  theme_economist()+
  ylab('Buckets')+
  xlab('Shot Zone Basic')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.6,
    size = 5,
    position = position_stack(vjust = 1)
  )
kobe_buckets_graph_by_zone

kobe_buckets_graph_by_point <- ggplot(data=kobe_buckets, aes(x=shot_type))+
  geom_bar(fill='gold3')+
  ggtitle("Kobe's Buckets by Point Type")+
  theme_economist()+
  ylab('Buckets')+
  xlab('Points')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.6,
    size = 5,
    position = position_stack(vjust = 1)
  )
kobe_buckets_graph_by_point


kobe_buckets_graph_by_combined_shot_type <- ggplot(data=kobe_buckets, aes(x=combined_shot_type, fill=shot_type))+
  geom_bar(position='dodge')+
  ggtitle("Kobe's Buckets by Shot Type")+
  theme_economist()+
  ylab('Buckets')+
  xlab('Shot Type')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.5,
    size = 5,
    position = position_dodge(width = 0.9)
  )+
  scale_fill_manual(values= kobe_colors)
kobe_buckets_graph_by_combined_shot_type

#Now Lets Explore our basic dataset 

kobe_basic$shot_made_flag <- as.factor(kobe_basic$shot_made_flag)
levels(kobe_basic$shot_made_flag) <- c('No', 'Yes')

kobe_basic_shot_made_vs_point <- ggplot(kobe_basic, aes(x=shot_made_flag, fill=shot_type))+
  geom_bar()+
  ggtitle("Kobe's Shots Type vs Shot's Success")+
  theme_economist()+
  ylab('Shots')+
  xlab('Bucket or not')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.6,
    size = 5,
    position = position_stack(vjust = 0)
  )+
  scale_fill_manual(values=kobe_colors)
kobe_basic_shot_made_vs_point


kobe_basic_shot_made_vs_court <- ggplot(kobe_basic, aes(x=shot_made_flag, fill=home_at))+
  geom_bar()+
  ggtitle("Kobe's Shots Type vs Court")+
  theme_economist()+
  ylab('Shots')+
  xlab('Bucket or Not')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.6,
    size = 5,
    position = position_stack(vjust = 0)
  )+
  scale_fill_manual(values=kobe_colors)
kobe_basic_shot_made_vs_court


kobe_basic_shot_made_vs_playoff <- ggplot(kobe_basic, aes(x=shot_made_flag, fill=playoffs))+
  geom_bar()+
  ggtitle("Kobe's Shots Type vs Game Type")+
  theme_economist()+
  ylab('Shots')+
  xlab('Bucket or Not')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.6,
    size = 5,
    position = position_stack(vjust = 0)
  )+
  scale_fill_manual(values=kobe_colors)
kobe_basic_shot_made_vs_playoff


kobe_basic_shot_made_distance <- ggplot(kobe_basic, aes(y=shot_distance, x=shot_made_flag, color=shot_made_flag))+
  geom_jitter()+
  ggtitle("Kobe's Shots Success based on Distance")+
  theme_economist()+
  ylab('Distance')+
  xlab('Bucket or Not')+
  scale_color_manual(values=kobe_colors)
kobe_basic_shot_made_distance 

kobe_basic_shot_made_vs_minutes_remaining <- ggplot(kobe_basic, aes(x=minutes_remaining, fill=shot_made_flag))+
  geom_bar()+
  ggtitle("Kobe's Shots Success based on Minutes Remaining")+
  theme_economist()+
  ylab('Shots')+
  xlab('Minutes Remaining')+
  scale_fill_manual(values=kobe_colors)+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.6,
    size = 5,
    position = position_stack(vjust = 0)
  )
kobe_basic_shot_made_vs_minutes_remaining 


kobe_basic_shot_made_vs_period <- ggplot(kobe_basic, aes(x=period, fill=shot_made_flag))+
  geom_bar(position = 'dodge')+
  ggtitle("Kobe's Shots Success based on Period")+
  theme_economist()+
  ylab('Shots')+
  xlab('Period')+
  geom_text(
    aes(label = after_stat(count)),
    stat = 'count',
    colour='black',
    vjust = -0.5,
    size = 5,
    position = position_dodge(width = 0.9)
  )+
  scale_fill_manual(values=kobe_colors)
kobe_basic_shot_made_vs_period 

(kobe_basic_shot_made_vs_point + kobe_basic_shot_made_vs_court) / (kobe_basic_shot_made_vs_playoff + kobe_basic_shot_made_vs_minutes_remaining)

kobe_basic_shot_made_distance + kobe_basic_shot_made_vs_period


# Let's now, exclude some variables: shot_id, matchup, game_date, lat, lon, action_type
kobe_basic_new <- kobe_basic[ ,-c(1,3,6,18,19, 21)]
# Fixing variables
kobe_basic_new$season <- as.factor(kobe_basic$season)
kobe_basic_new$opponent <- as.factor(kobe_basic$opponent)
kobe_basic_new$home_at <- as.factor(kobe_basic$home_at)


# Correlation between shot_made_flag and other variables

shot_made_vs_home_at <- table(kobe_basic_new$shot_made_flag, kobe_basic_new$home_at)

fisher.test(x=kobe_basic_new$shot_made_flag, y=kobe_basic_new$home_at, 
            alternative = 'two.sided', conf.level = 0.95) 

chisq.test(kobe_basic_new$shot_made_flag, kobe_basic_new$home_at)

Assocs(shot_made_vs_home_at)

# There is a statistically correlation between shot_made_flag and home_at (p<0.05).
# The buckets away is more than the buckets in home. (Very Low Correlation according to Coefficients) 


shot_made_vs_playoff <- table(kobe_basic_new$shot_made_flag, kobe_basic_new$playoffs)

fisher.test(x=kobe_basic_new$shot_made_flag, y=kobe_basic_new$playoffs, 
            alternative = 'two.sided', conf.level = 0.95) 

# shot_made_flag and playoffs are not correlated.


shot_made_vs_shot_type <- table(kobe_basic_new$shot_made_flag, kobe_basic_new$shot_type)


fisher.test(x=kobe_basic_new$shot_made_flag, y=kobe_basic_new$shot_type, 
            alternative = 'two.sided', conf.level = 0.95) 


chisq.test(kobe_basic_new$shot_made_flag, kobe_basic_new$shot_type)

Assocs(shot_made_vs_shot_type)
