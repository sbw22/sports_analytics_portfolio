# Import Libraries
library(plyr)
library(dplyr)
library(devtools)
library(DT)
library(ggplot2)
library(ggrepel)
library(ggthemes)
library(gridExtra)
library(janitor)
library(plotly)
library(stringr)
library(tidyr)
library(tidyselect)
library(tidyverse)
library(data.table)
library(reactable)
library(lubridate)

setwd("/Users/spencerweishaar/AthleteLab/sports_da_portfolio/corner3_tab/")

shooting_data <- fread("../nba_data/nba_player_shooting_stats_2025-26.csv")
per_game_data <- fread("../nba_data/nba_player_per-game_stats_2025-26.csv")

# Remove the first two rows
shooting_data <- shooting_data[-c(1,2), ]

# Maybe resets values?
Corner3_percentiles <- 0
# RelSpeed -> V27 (corner 3 usage percentage)
Corner3_Percentiles <- shooting_data[, .(
  'Corner3 Usage' = V27,
  '3s Assisted' = V24,
  'Corner 3P%' = V28
  ),# 'Max Spin' = max(SpinRate, na.rm = TRUE)),
  by=.(V2, V4)]

# Add 3PA from per_game_data
Corner3_Percentiles <- merge(Corner3_Percentiles, per_game_data[, c("Player", "Team", "3PA")], by.x = c("V2", "V4"), by.y = c("Player", "Team")) # $`3PA`

##############################################################################################################
# Making values numeric

Corner3_Percentiles$'Corner3 Usage' <- as.numeric(Corner3_Percentiles$'Corner3 Usage')
# Corner3_Percentiles$'Max Spin' <- round(Corner3_Percentiles$'Max Spin', digits = 0)



# Creating Ranking and Percentile for Corner3 Usage -- Fastball Only!

Corner3_Percentiles$Corner3Usage_percentile <- Corner3_Percentiles$`Corner3 Usage`

Corner3_Percentiles$Corner3Usage_percentile <- round(Corner3_Percentiles$Corner3Usage_percentile, digits = 2)

# if players played less than 10 minutes per game, set percentile to NA
Corner3_Percentiles$Corner3Usage_percentile[Corner3_Percentiles$V6 / 82 > 10] <- NA


Corner3_Percentiles$Corner3Usage_ranking[order(Corner3_Percentiles$Corner3Usage_percentile,
                                     decreasing = TRUE)] <- 1:nrow(Corner3_Percentiles)


Corner3_Percentiles$Corner3Usage_ranking[Corner3_Percentiles$V6 / 82 > 10] <- NA


Corner3_Percentiles$Corner3Usage_percentile <-  1 - ((Corner3_Percentiles$Corner3Usage_ranking) / max(Corner3_Percentiles$Corner3Usage_ranking, na.rm = TRUE))

Corner3_Percentiles$Corner3Usage_percentile <- round(Corner3_Percentiles$Corner3Usage_percentile, digits = 2)

Corner3_Percentiles$Corner3Usage_percentile <- Corner3_Percentiles$Corner3Usage_percentile*100


#############################################################################


# Making values numeric

Corner3_Percentiles$'3s Assisted' <- as.numeric(Corner3_Percentiles$'3s Assisted')
# Corner3_Percentiles$'Max Spin' <- round(Corner3_Percentiles$'Max Spin', digits = 0)



# Creating Ranking and Percentile for 3s Assisted -- Fastball Only!

Corner3_Percentiles$Assisted3s_percentile <- Corner3_Percentiles$`3s Assisted`

Corner3_Percentiles$Assisted3s_percentile <- round(Corner3_Percentiles$Assisted3s_percentile, digits = 2)

# if players played less than 10 minutes per game, set percentile to NA
Corner3_Percentiles$Assisted3s_percentile[Corner3_Percentiles$V6 / 82 > 10] <- NA


Corner3_Percentiles$Assisted3s_ranking[order(Corner3_Percentiles$Assisted3s_percentile,
                                               decreasing = TRUE)] <- 1:nrow(Corner3_Percentiles)


Corner3_Percentiles$Assisted3s_ranking[Corner3_Percentiles$V6 / 82 > 10] <- NA


Corner3_Percentiles$Assisted3s_percentile <-  1 - ((Corner3_Percentiles$Assisted3s_ranking) / max(Corner3_Percentiles$Assisted3s_ranking, na.rm = TRUE))

Corner3_Percentiles$Assisted3s_percentile <- round(Corner3_Percentiles$Assisted3s_percentile, digits = 2)

Corner3_Percentiles$Assisted3s_percentile <- Corner3_Percentiles$Assisted3s_percentile*100



#############################################################################


# Making values numeric

Corner3_Percentiles$'3PA' <- as.numeric(Corner3_Percentiles$'3PA')
# Corner3_Percentiles$'Max Spin' <- round(Corner3_Percentiles$'Max Spin', digits = 0)



# Creating Ranking and Percentile for 3s Assisted -- Fastball Only!

Corner3_Percentiles$Attempted3s_percentile <- Corner3_Percentiles$`3PA`

Corner3_Percentiles$Attempted3s_percentile <- round(Corner3_Percentiles$Attempted3s_percentile, digits = 2)

# if players played less than 10 minutes per game, set percentile to NA (!)
Corner3_Percentiles$Attempted3s_percentile[Corner3_Percentiles$V6 / 82 > 10] <- NA


Corner3_Percentiles$Attempted3s_ranking[order(Corner3_Percentiles$Attempted3s_percentile,
                                             decreasing = TRUE)] <- 1:nrow(Corner3_Percentiles)


Corner3_Percentiles$Attempted3s_ranking[Corner3_Percentiles$V6 / 82 > 10] <- NA


Corner3_Percentiles$Attempted3s_percentile <-  1 - ((Corner3_Percentiles$Attempted3s_ranking) / max(Corner3_Percentiles$Attempted3s_ranking, na.rm = TRUE))

Corner3_Percentiles$Attempted3s_percentile <- round(Corner3_Percentiles$Attempted3s_percentile, digits = 2)

Corner3_Percentiles$Attempted3s_percentile <- Corner3_Percentiles$Attempted3s_percentile*100



#############################################################################


# Making values numeric

Corner3_Percentiles$'Corner 3P%' <- as.numeric(Corner3_Percentiles$'Corner 3P%')
# Corner3_Percentiles$'Max Spin' <- round(Corner3_Percentiles$'Max Spin', digits = 0)



# Creating Ranking and Percentile for 3s Assisted -- Fastball Only!

Corner3_Percentiles$Corner3_FGPct_percentile <- Corner3_Percentiles$`Corner 3P%`

Corner3_Percentiles$Corner3_FGPct_percentile <- round(Corner3_Percentiles$Corner3_FGPct_percentile, digits = 2)

# if players played less than 10 minutes per game, set percentile to NA (!)
Corner3_Percentiles$Corner3_FGPct_percentile[Corner3_Percentiles$V6 / 82 > 10] <- NA


Corner3_Percentiles$Corner3_FGPct_ranking[order(Corner3_Percentiles$Corner3_FGPct_percentile,
                                              decreasing = TRUE)] <- 1:nrow(Corner3_Percentiles)


Corner3_Percentiles$Corner3_FGPct_ranking[Corner3_Percentiles$V6 / 82 > 10] <- NA


Corner3_Percentiles$Corner3_FGPct_percentile <-  1 - ((Corner3_Percentiles$Corner3_FGPct_ranking) / max(Corner3_Percentiles$Corner3_FGPct_ranking, na.rm = TRUE))

Corner3_Percentiles$Corner3_FGPct_percentile <- round(Corner3_Percentiles$Corner3_FGPct_percentile, digits = 2)

Corner3_Percentiles$Corner3_FGPct_percentile <- Corner3_Percentiles$Corner3_FGPct_percentile*100



##############################################################################################################



# IDK why this is needed in main.r, but adding it anyways until I find a fix
Corner3_Percentiles$Temp <- "Rate"



# removing rows with NA in Corner3Usage_percentile
Corner3_Percentiles <- Corner3_Percentiles[!is.na(Corner3_Percentiles$Corner3Usage_percentile), ]
# removing rows with NA in Corner3 Usage
Corner3_Percentiles <- Corner3_Percentiles[!is.na(Corner3_Percentiles$`Corner3 Usage`), ]

# removing rows with NA in Assisted3s_percentile
Corner3_Percentiles <- Corner3_Percentiles[!is.na(Corner3_Percentiles$Assisted3s_percentile), ]
# removing rows with NA in 3s Assisted
Corner3_Percentiles <- Corner3_Percentiles[!is.na(Corner3_Percentiles$`3s Assisted`), ]

# removing rows with NA in Attempted3s_percentile
Corner3_Percentiles <- Corner3_Percentiles[!is.na(Corner3_Percentiles$Attempted3s_percentile), ]
# removing rows with NA in 3s Assisted
Corner3_Percentiles <- Corner3_Percentiles[!is.na(Corner3_Percentiles$`3PA`), ]

# removing rows with NA in Corner3_FGPct_percentile
Corner3_Percentiles <- Corner3_Percentiles[!is.na(Corner3_Percentiles$Corner3_FGPct_percentile), ]
# removing rows with NA in 3s Assisted
Corner3_Percentiles <- Corner3_Percentiles[!is.na(Corner3_Percentiles$`Corner 3P%`), ]





# Creating High and Low Pitches for Color Scale

Corner3Usage_ranking_min = min(Corner3_Percentiles$Corner3Usage_ranking, na.rm = TRUE)
Corner3Usage_ranking_max = max(Corner3_Percentiles$Corner3Usage_ranking, na.rm = TRUE)

Assisted3s_ranking_min = min(Corner3_Percentiles$Assisted3s_ranking, na.rm = TRUE)
Assisted3s_ranking_max = max(Corner3_Percentiles$Assisted3s_ranking, na.rm = TRUE)

Attempted3s_ranking_min = min(Corner3_Percentiles$Attempted3s_ranking, na.rm = TRUE)
Attempted3s_ranking_max = max(Corner3_Percentiles$Attempted3s_ranking, na.rm = TRUE)

Attempted3s_max = max(Corner3_Percentiles$`3PA`, na.rm = TRUE)

Corner3_FGPct_ranking_min = min(Corner3_Percentiles$Corner3_FGPct_ranking, na.rm = TRUE)
Corner3_FGPct_ranking_max = max(Corner3_Percentiles$Corner3_FGPct_ranking, na.rm = TRUE)


# Low

All_Data_Low=subset(Corner3_Percentiles, select = c(1:3))

All_Data_Low <- All_Data_Low[!duplicated(All_Data_Low)]

colnames(All_Data_Low)

All_Data_Low$Temp <- "Low"
All_Data_Low$`Corner3 Usage` <- -0.2
All_Data_Low$`3s Assisted` <- -0.2 # Might want to change this value, just eyeballing it
All_Data_Low$`3PA` <- -0.5 # Might want to change this value, just eyeballing it
All_Data_Low$`Corner 3P%` <- -0.2
All_Data_Low$Corner3Usage_percentile <- -5
All_Data_Low$Corner3Usage_ranking <- Corner3Usage_ranking_min - 50
All_Data_Low$Assisted3s_percentile <- -5
All_Data_Low$Assisted3s_ranking <- Assisted3s_ranking_min - 50
All_Data_Low$Attempted3s_percentile <- -5
All_Data_Low$Attempted3s_ranking <- Attempted3s_ranking_min - 50
All_Data_Low$Corner3_FGPct_percentile <- -5
All_Data_Low$Corner3_FGPct_ranking <- Corner3_FGPct_ranking_min - 50

# High

All_Data_High=subset(Corner3_Percentiles, select = c(1:3))

All_Data_High <- All_Data_High[!duplicated(All_Data_High)]

colnames(All_Data_High)

All_Data_High$Temp <- "High"
All_Data_High$`Corner3 Usage` <- 1.2
All_Data_High$`3s Assisted` <- 1.2
All_Data_High$`3PA` <- Attempted3s_max + 0.5 # Might want to change this value, just eyeballing it
All_Data_High$`Corner 3P%` <- 1.2
All_Data_High$Corner3Usage_percentile <- 105
All_Data_High$Corner3Usage_ranking <- Corner3Usage_ranking_max + 50
All_Data_High$Assisted3s_percentile <- 105
All_Data_High$Assisted3s_ranking <- Assisted3s_ranking_max + 50
All_Data_High$Attempted3s_percentile <- 105
All_Data_High$Attempted3s_ranking <- Attempted3s_ranking_max + 50
All_Data_High$Corner3_FGPct_percentile <- 105
All_Data_High$Corner3_FGPct_ranking <- Corner3_FGPct_ranking_max + 50

# TaggedPitchType -> V4 (team name)






# Rbind to Combine Low and High

LowHigh <- rbind(All_Data_Low, All_Data_High)

# Rbind to Combine LowHigh with Corner3_Percentiles

Corner3_Percentiles <- rbind(Corner3_Percentiles, LowHigh)

# Set league average team values to "League Average"
Corner3_Percentiles$V4[Corner3_Percentiles$V2 == "League Average"] <- "League Average"


# Write to CSV
write.csv(Corner3_Percentiles, "../nba_data/nba_player_corner3_percentiles_2025-26.csv")
# write.csv(TM_Percentiles, "../data/TM_Percentiles.csv")

