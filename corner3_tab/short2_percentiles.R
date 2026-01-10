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
Short2_percentiles <- 0
# RelSpeed -> V27 (corner 3 usage percentage)
Short2_Percentiles <- shooting_data[, .(
  'Short2 Usage' = V12,
  '2s Assisted' = V23,
  'Short 2P%' = V18
),# 'Max Spin' = max(SpinRate, na.rm = TRUE)),
by=.(V2, V4)]

# Add 2PA from per_game_data
Short2_Percentiles <- merge(Short2_Percentiles, per_game_data[, c("Player", "Team", "2PA")], by.x = c("V2", "V4"), by.y = c("Player", "Team")) # $`2PA`

##############################################################################################################
# Making values numeric

Short2_Percentiles$'Short2 Usage' <- as.numeric(Short2_Percentiles$'Short2 Usage')
# Short2_Percentiles$'Max Spin' <- round(Short2_Percentiles$'Max Spin', digits = 0)



# Creating Ranking and Percentile for Short2 Usage -- Fastball Only!

Short2_Percentiles$Short2Usage_percentile <- Short2_Percentiles$`Short2 Usage`

Short2_Percentiles$Short2Usage_percentile <- round(Short2_Percentiles$Short2Usage_percentile, digits = 2)

# if players played less than 10 minutes per game, set percentile to NA
Short2_Percentiles$Short2Usage_percentile[Short2_Percentiles$V6 / 82 > 10] <- NA


Short2_Percentiles$Short2Usage_ranking[order(Short2_Percentiles$Short2Usage_percentile,
                                               decreasing = TRUE)] <- 1:nrow(Short2_Percentiles)


Short2_Percentiles$Short2Usage_ranking[Short2_Percentiles$V6 / 82 > 10] <- NA


Short2_Percentiles$Short2Usage_percentile <-  1 - ((Short2_Percentiles$Short2Usage_ranking) / max(Short2_Percentiles$Short2Usage_ranking, na.rm = TRUE))

Short2_Percentiles$Short2Usage_percentile <- round(Short2_Percentiles$Short2Usage_percentile, digits = 2)

Short2_Percentiles$Short2Usage_percentile <- Short2_Percentiles$Short2Usage_percentile*100


#############################################################################


# Making values numeric

Short2_Percentiles$'2s Assisted' <- as.numeric(Short2_Percentiles$'2s Assisted')
# Short2_Percentiles$'Max Spin' <- round(Short2_Percentiles$'Max Spin', digits = 0)



# Creating Ranking and Percentile for 2s Assisted -- Fastball Only!

Short2_Percentiles$Assisted2s_percentile <- Short2_Percentiles$`2s Assisted`

Short2_Percentiles$Assisted2s_percentile <- round(Short2_Percentiles$Assisted2s_percentile, digits = 2)

# if players played less than 10 minutes per game, set percentile to NA
Short2_Percentiles$Assisted2s_percentile[Short2_Percentiles$V6 / 82 > 10] <- NA


Short2_Percentiles$Assisted2s_ranking[order(Short2_Percentiles$Assisted2s_percentile,
                                             decreasing = TRUE)] <- 1:nrow(Short2_Percentiles)


Short2_Percentiles$Assisted2s_ranking[Short2_Percentiles$V6 / 82 > 10] <- NA


Short2_Percentiles$Assisted2s_percentile <-  1 - ((Short2_Percentiles$Assisted2s_ranking) / max(Short2_Percentiles$Assisted2s_ranking, na.rm = TRUE))

Short2_Percentiles$Assisted2s_percentile <- round(Short2_Percentiles$Assisted2s_percentile, digits = 2)

Short2_Percentiles$Assisted2s_percentile <- Short2_Percentiles$Assisted2s_percentile*100



#############################################################################


# Making values numeric

Short2_Percentiles$'2PA' <- as.numeric(Short2_Percentiles$'2PA')
# Short2_Percentiles$'Max Spin' <- round(Short2_Percentiles$'Max Spin', digits = 0)



# Creating Ranking and Percentile for 2s Assisted -- Fastball Only!

Short2_Percentiles$Attempted2s_percentile <- Short2_Percentiles$`2PA`

Short2_Percentiles$Attempted2s_percentile <- round(Short2_Percentiles$Attempted2s_percentile, digits = 2)

# if players played less than 10 minutes per game, set percentile to NA (!)
Short2_Percentiles$Attempted2s_percentile[Short2_Percentiles$V6 / 82 > 10] <- NA


Short2_Percentiles$Attempted2s_ranking[order(Short2_Percentiles$Attempted2s_percentile,
                                              decreasing = TRUE)] <- 1:nrow(Short2_Percentiles)


Short2_Percentiles$Attempted2s_ranking[Short2_Percentiles$V6 / 82 > 10] <- NA


Short2_Percentiles$Attempted2s_percentile <-  1 - ((Short2_Percentiles$Attempted2s_ranking) / max(Short2_Percentiles$Attempted2s_ranking, na.rm = TRUE))

Short2_Percentiles$Attempted2s_percentile <- round(Short2_Percentiles$Attempted2s_percentile, digits = 2)

Short2_Percentiles$Attempted2s_percentile <- Short2_Percentiles$Attempted2s_percentile*100



#############################################################################


# Making values numeric

Short2_Percentiles$'Short 2P%' <- as.numeric(Short2_Percentiles$'Short 2P%')
# Short2_Percentiles$'Max Spin' <- round(Short2_Percentiles$'Max Spin', digits = 0)



# Creating Ranking and Percentile for 2s Assisted -- Fastball Only!

Short2_Percentiles$Short2_FGPct_percentile <- Short2_Percentiles$`Short 2P%`

Short2_Percentiles$Short2_FGPct_percentile <- round(Short2_Percentiles$Short2_FGPct_percentile, digits = 2)

# if players played less than 10 minutes per game, set percentile to NA (!)
Short2_Percentiles$Short2_FGPct_percentile[Short2_Percentiles$V6 / 82 > 10] <- NA


Short2_Percentiles$Short2_FGPct_ranking[order(Short2_Percentiles$Short2_FGPct_percentile,
                                                decreasing = TRUE)] <- 1:nrow(Short2_Percentiles)


Short2_Percentiles$Short2_FGPct_ranking[Short2_Percentiles$V6 / 82 > 10] <- NA


Short2_Percentiles$Short2_FGPct_percentile <-  1 - ((Short2_Percentiles$Short2_FGPct_ranking) / max(Short2_Percentiles$Short2_FGPct_ranking, na.rm = TRUE))

Short2_Percentiles$Short2_FGPct_percentile <- round(Short2_Percentiles$Short2_FGPct_percentile, digits = 2)

Short2_Percentiles$Short2_FGPct_percentile <- Short2_Percentiles$Short2_FGPct_percentile*100



##############################################################################################################



# IDK why this is needed in main.r, but adding it anyways until I find a fix
Short2_Percentiles$Temp <- "Rate"



# removing rows with NA in Short2Usage_percentile
Short2_Percentiles <- Short2_Percentiles[!is.na(Short2_Percentiles$Short2Usage_percentile), ]
# removing rows with NA in Short2 Usage
Short2_Percentiles <- Short2_Percentiles[!is.na(Short2_Percentiles$`Short2 Usage`), ]

# removing rows with NA in Assisted2s_percentile
Short2_Percentiles <- Short2_Percentiles[!is.na(Short2_Percentiles$Assisted2s_percentile), ]
# removing rows with NA in 2s Assisted
Short2_Percentiles <- Short2_Percentiles[!is.na(Short2_Percentiles$`2s Assisted`), ]

# removing rows with NA in Attempted2s_percentile
Short2_Percentiles <- Short2_Percentiles[!is.na(Short2_Percentiles$Attempted2s_percentile), ]
# removing rows with NA in 2s Assisted
Short2_Percentiles <- Short2_Percentiles[!is.na(Short2_Percentiles$`2PA`), ]

# removing rows with NA in Short2_FGPct_percentile
Short2_Percentiles <- Short2_Percentiles[!is.na(Short2_Percentiles$Short2_FGPct_percentile), ]
# removing rows with NA in 2s Assisted
Short2_Percentiles <- Short2_Percentiles[!is.na(Short2_Percentiles$`Short 2P%`), ]





# Creating High and Low Pitches for Color Scale

Short2Usage_ranking_min = min(Short2_Percentiles$Short2Usage_ranking, na.rm = TRUE)
Short2Usage_ranking_max = max(Short2_Percentiles$Short2Usage_ranking, na.rm = TRUE)

Assisted2s_ranking_min = min(Short2_Percentiles$Assisted2s_ranking, na.rm = TRUE)
Assisted2s_ranking_max = max(Short2_Percentiles$Assisted2s_ranking, na.rm = TRUE)

Attempted2s_ranking_min = min(Short2_Percentiles$Attempted2s_ranking, na.rm = TRUE)
Attempted2s_ranking_max = max(Short2_Percentiles$Attempted2s_ranking, na.rm = TRUE)

Attempted2s_max = max(Short2_Percentiles$`2PA`, na.rm = TRUE)

Short2_FGPct_ranking_min = min(Short2_Percentiles$Short2_FGPct_ranking, na.rm = TRUE)
Short2_FGPct_ranking_max = max(Short2_Percentiles$Short2_FGPct_ranking, na.rm = TRUE)


# Low

All_Data_Low=subset(Short2_Percentiles, select = c(1:3))

All_Data_Low <- All_Data_Low[!duplicated(All_Data_Low)]

colnames(All_Data_Low)

All_Data_Low$Temp <- "Low"
All_Data_Low$`Short2 Usage` <- -0.2
All_Data_Low$`2s Assisted` <- -0.2 # Might want to change this value, just eyeballing it
All_Data_Low$`2PA` <- -0.5 # Might want to change this value, just eyeballing it
All_Data_Low$`Short 2P%` <- -0.2
All_Data_Low$Short2Usage_percentile <- -5
All_Data_Low$Short2Usage_ranking <- Short2Usage_ranking_min - 50
All_Data_Low$Assisted2s_percentile <- -5
All_Data_Low$Assisted2s_ranking <- Assisted2s_ranking_min - 50
All_Data_Low$Attempted2s_percentile <- -5
All_Data_Low$Attempted2s_ranking <- Attempted2s_ranking_min - 50
All_Data_Low$Short2_FGPct_percentile <- -5
All_Data_Low$Short2_FGPct_ranking <- Short2_FGPct_ranking_min - 50

# High

All_Data_High=subset(Short2_Percentiles, select = c(1:3))

All_Data_High <- All_Data_High[!duplicated(All_Data_High)]

colnames(All_Data_High)

All_Data_High$Temp <- "High"
All_Data_High$`Short2 Usage` <- 1.2
All_Data_High$`2s Assisted` <- 1.2
All_Data_High$`2PA` <- Attempted2s_max + 0.5 # Might want to change this value, just eyeballing it
All_Data_High$`Short 2P%` <- 1.2
All_Data_High$Short2Usage_percentile <- 105
All_Data_High$Short2Usage_ranking <- Short2Usage_ranking_max + 50
All_Data_High$Assisted2s_percentile <- 105
All_Data_High$Assisted2s_ranking <- Assisted2s_ranking_max + 50
All_Data_High$Attempted2s_percentile <- 105
All_Data_High$Attempted2s_ranking <- Attempted2s_ranking_max + 50
All_Data_High$Short2_FGPct_percentile <- 105
All_Data_High$Short2_FGPct_ranking <- Short2_FGPct_ranking_max + 50

# TaggedPitchType -> V4 (team name)






# Rbind to Combine Low and High

LowHigh <- rbind(All_Data_Low, All_Data_High)

# Rbind to Combine LowHigh with Short2_Percentiles

Short2_Percentiles <- rbind(Short2_Percentiles, LowHigh)

# Set league average team values to "League Average"
Short2_Percentiles$V4[Short2_Percentiles$V2 == "League Average"] <- "League Average"


# Write to CSV
write.csv(Short2_Percentiles, "../nba_data/nba_player_short2_percentiles_2025-26.csv")
# write.csv(TM_Percentiles, "../data/TM_Percentiles.csv")

