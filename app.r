# Import Libraries
library(shiny)
library(ggpubr)
library(plyr)
library(dplyr)
library(devtools)
library(DT)
library(ggplot2)
library(ggiraph)
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
library(rsconnect)
library(reticulate)


# setwd("/Users/spencerweishaar/AthleteLab/sports_da_portfolio/")
# Only set working directory when running locally (?)
if (interactive()) {
  setwd("/Users/spencerweishaar/AthleteLab/sports_da_portfolio/")
}

# py_config()

#  Install required Python packages into reticulate's environment
py_require(c("pandas", "matplotlib", "scikit-learn", "hdbscan"))


# Specify Python path (optional, but recommended)
# use_python("/usr/local/bin/python3", required = TRUE)  # Adjust to your Python path

# Source your Python script
source_python("/Users/spencerweishaar/AthleteLab/sports_da_portfolio/batter_position/batting_stance_grouping.py")

# When you need to run the analysis, pass the full path:
csv_path <- "/Users/spencerweishaar/AthleteLab/sports_da_portfolio/batter_position/batting-stance.csv"
results <- run_clustering_analysis(csv_path)

cluster_labels <- results$cluster_labels
outliers <- results$outliers
player_names <- results$player_names
features <- results$features
feature_names <- results$feature_names

# run_clustering_analysis parameters
feature_indices <- c(0, 1, 2, 3, 4, 5)  # Example indices for all six features
min_cluster_size <- 5 # Example minimum cluster size
num_of_players_ranked <- 25 # Example number of players ranked
min_samples <- 5 # Example min samples (might try to delete this from everything later)
num_of_players <- -1 # Use -1 to indicate all players


# Access results
print(cluster_labels)
print(player_names)
print(feature_names)


# return()
# rsconnect::deployApp('/Users/spencerweishaar/AthleteLab/sports_da_portfolio/')

# Deploy the app
# rsconnect::deployApp(
#   appDir = getwd(),
#   appName = "nba-player-analytics--Short-2-and-Corner-3"  # Choose your own name
# )


# TestTrackMan=fread("../R_practice/data/Corner3_Percentiles.csv")
# TestTrackMan <- subset(TestTrackMan, select = -c(V1))

# Corner3_Percentiles=fread("../R_practice/data/Corner3_Percentiles.csv")
# Corner3_Percentiles <- subset(Corner3_Percentiles, select = -c(V1))

# Converts Character Date into Proper Format

# TestTrackMan$Date <- mdy(TestTrackMan$Date)


# Importing basketball data 

shooting_data <- fread("nba_data/nba_player_shooting_stats_2025-26.csv")
per_game_data <- fread("nba_data/nba_player_per-game_stats_2025-26.csv")

Corner3_Percentiles <- fread("nba_data/nba_player_corner3_percentiles_2025-26.csv")
Short2_Percentiles <- fread("nba_data/nba_player_short2_percentiles_2025-26.csv")

# temp_v <- Corner3_Percentiles$Corner3Usage_percentile
# temp_v
# print(temp_v)
# 
# return
# sdferdgsf

# Remove the first two rows
shooting_data <- shooting_data[-c(1,2), ]
# Corner3_Percentiles <- Corner3_Percentiles[-c(736, 1472, 2208), ]


ui <- navbarPage(
  
  # Title and Theme of App
  "Spencer Weishaar - Sports Data Analytics Portfolio", theme = "flatly",
  
  tabPanel("Basketball",
           tabsetPanel(
             tabPanel("Corner 3 Projections",
                      # Question: How effective are corner 3pt shooters at other metrics?
                      # Question: How effective are corner 3pt shooters due to a playmaker on their team?
                      
                      
                      # This layout will be similar to the baseball layout, with teams and players
                      # on the left, and metrics on the right on the main page.
                      sidebarLayout(
                        sidebarPanel(
                          selectInput("Team", label = "Choose Team",
                                      # changed levels(as.factor()) to sort(unique())
                                      choices = sort(unique(shooting_data$V4))),
                          
                          selectInput("Player", label = "Choose Player",
                                      
                                      choices = sort(unique(shooting_data$V2))),
                        ),
                        mainPanel(
                          fluidRow(plotOutput("Corner3_Percentiles")),
                          br(),
                          br(),
                          br(),
                          br(),
                          br(),
                          # table will go here
                          # Contents: Player Name, Team, Corner 3 Usage %, Corner 3 FGPct, Assisted 3s %, 3pt Attempt Rate
                          fluidRow(DTOutput("Corner3_Percentiles_Data")),
                          br(),
                          br(),
                          br(),
                          br(),
                          br(),
                          fluidRow(plotlyOutput("Corner3_Team_Scatterplot")),
                          br(),
                          br(),
                          br(),
                          br(),
                          br(),
                          fluidRow(plotOutput("Short2_Percentiles")),
                          br(),
                          br(),
                          br(),
                          br(),
                          br(),
                          fluidRow(DTOutput("Short2_Percentiles_Data")),
                          br(),
                          br(),
                          br(),
                          br(),
                          br(),
                          fluidRow(plotlyOutput("Short2_Team_Scatterplot")),
                          
                      ),
                      )
              )
           )
  ),
  tabPanel("Baseball",
           tabsetPanel(
             tabPanel("Batter Positioning Analysis",
                      # Question: How effective are corner 3pt shooters at other metrics?
                      # Question: How effective are corner 3pt shooters due to a playmaker on their team?
                      
                      
                      # This layout will be similar to the baseball layout, with teams and players
                      # on the left, and metrics on the right on the main page.
                      sidebarLayout(
                        sidebarPanel(
                          checkboxGroupInput("PositionStats", label = "Choose Batter Position Stats", 
                                             choices = c("Average Batter Y Position", "Average Batter X Position", "Average Foot Seperation", "Average Stance Angle", "Average Intercept Y Versus Batter", "Average Intercept Y Versus Plate"),),
                        
                          sliderInput("PlayersRanked", label = "Number of Players Ranked", value = 10, min = 1, max = 50),
                          
                          sliderInput("SmallestGroupSize", label = "Lowest Number Of Players In Each Classifying Group", min = 1, max = 20, value = 5),
                          
                          actionButton("ApplyFilters", label = "Apply Filters"),
                          
                        ),
                        mainPanel(
                          fluidRow(plotOutput("BattersBox"))
                        ),
                      )
             )
           )
  ),
  tabPanel("Football",
            sidebarLayout(

              sidebarPanel(

              ),
              mainPanel(
                
              )
            )
  ),
  
  
)



# Start of the Server - Part 2 of App Structure
# Creates the back end of the dataset
server = function(input, output, session) {
  position_choices <- c("Average Batter Y Position", 
                        "Average Batter X Position", 
                        "Average Foot Seperation", 
                        "Average Stance Angle", 
                        "Average Intercept Y Versus Batter", 
                        "Average Intercept Y Versus Plate")
  
  # Create reactive values to store parameters
  params <- reactiveValues(
    feature_indices = c(0, 1, 2, 3, 4, 5),
    min_cluster_size = 5,
    num_of_players_ranked = 25,
    min_samples = 5,
    num_of_players = -1
  )
  
  
  # Create a reactive dataframe for clustering results
  clustering_results_df <- reactiveVal(NULL)
  
  # Initialize the dataframe on app start - wrapped in isolate to prevent reactive dependency issues
  observeEvent(once = TRUE, ignoreNULL = FALSE, ignoreInit = FALSE, {
    tryCatch({
      print("Initializing clustering results...")
      
      initial_results <- run_clustering_analysis(
        csv_path,
        feature_indices = isolate(params$feature_indices),
        min_cluster_size = isolate(params$min_cluster_size),
        num_of_players_ranked = isolate(params$num_of_players_ranked),
        min_samples = isolate(params$min_samples),
        num_of_players = isolate(params$num_of_players)
      )
      
      # Debug: Check what we got back
      print("Initial results structure:")
      print(names(initial_results))
      print(paste("Player names length:", length(initial_results$player_names)))
      print(paste("Cluster labels length:", length(initial_results$cluster_labels)))
      print(paste("Features class:", class(initial_results$features)))
      print(paste("Features dim:", paste(dim(initial_results$features), collapse = "x")))
      
      # Validate results before processing
      if(is.null(initial_results)) {
        print("Error: initial_results is NULL")
        return()
      }
      
      if(is.null(initial_results$player_names) || length(initial_results$player_names) == 0) {
        print("Error: No player names returned")
        return()
      }
      
      # Convert results to dataframe - base columns only first
      initial_df <- data.frame(
        player_name = initial_results$player_names,
        cluster_label = initial_results$cluster_labels,
        is_outlier = initial_results$outliers,
        stringsAsFactors = FALSE
      )
      
      print(paste("Base dataframe created with", nrow(initial_df), "rows"))
      
      # Add feature columns - with extensive safety checks
      if(!is.null(initial_results$features) && !is.null(initial_results$feature_names)) {
        print("Adding feature columns...")
        
        # Ensure features is a matrix
        if(is.vector(initial_results$features)) {
          # If it's a vector, convert to single-column matrix
          feature_matrix <- matrix(initial_results$features, ncol = 1)
        } else {
          feature_matrix <- as.matrix(initial_results$features)
        }
        
        print(paste("Feature matrix dimensions:", nrow(feature_matrix), "x", ncol(feature_matrix)))
        print(paste("Number of feature names:", length(initial_results$feature_names)))
        
        # Check dimensions match
        if(nrow(feature_matrix) == nrow(initial_df) && ncol(feature_matrix) > 0) {
          num_features <- min(ncol(feature_matrix), length(initial_results$feature_names))
          
          for(i in 1:num_features) {
            col_name <- initial_results$feature_names[i]
            print(paste("Adding feature:", col_name))
            initial_df[[col_name]] <- feature_matrix[, i]
          }
          
          print("All features added successfully")
        } else {
          print(paste("Warning: Dimension mismatch - Feature matrix rows:", nrow(feature_matrix), 
                      "| Dataframe rows:", nrow(initial_df),
                      "| Feature columns:", ncol(feature_matrix)))
        }
      } else {
        print("Warning: Features or feature_names is NULL")
      }
      
      print("Final dataframe structure:")
      print(str(initial_df))
      print(head(initial_df))
      
      clustering_results_df(initial_df)
      print("Initialization complete!")
      
    }, error = function(e) {
      print(paste("Error in initialization:", e$message))
      print("Full error:")
      print(e)
    })
  }, {
    # This empty block is the event we're observing (app startup)
    TRUE
  })
  
  
  
  
  
  
  
  #Players based on team
  observeEvent(
    input$Team,
    updateSelectInput(session,
                      "Player", "Choose Player",
                      # changed levels(as.factor()) to sort(unique())
                      choices = sort(unique(filter(shooting_data,
                                                     V4 == isolate(input$Team))$V2))))
  
  
  observeEvent(
    input$PositionStats,
    # updateCheckboxGroupInput(session,
    #                          "PositionStats", "Choose Batter Position Stats",
    #                          choices = c("Average Batter Y Position", "Average Batter X Position", "Average Foot Seperation", "Average Stance Angle", "Average Intercept Y Versus Batter", "Average Intercept Y Versus Plate"),
    #                          selected = isolate(input$PositionStats))
    {
      selected_indices <- which(position_choices %in% input$PositionStats)
      print(paste("Selected indices:", paste(selected_indices, collapse = ", ")))
      selected_indices <- as.integer(selected_indices - 1) # This is the index adjustment for Python (0-based indexing)
      # selected_indices <- lapply(selected_indices, as.integer)
      # ^^ Want to keep indices as a vector, not a list. line above subtracting 1 converts items in list to integers anyways.
      
      params$feature_indices <- selected_indices
      
      
    }
  )
  
  observeEvent(
    input$SmallestGroupSize,
    {
      params$min_cluster_size <- as.integer(input$SmallestGroupSize)
    }
  )
  
  observeEvent(
    input$PlayersRanked,
    {
      params$num_of_players_ranked <- as.integer(input$PlayersRanked)
    }
  )
  
  observeEvent(
    input$ApplyFilters,
    {
      # Validate that at least one feature is selected
      if(length(params$feature_indices) == 0) {
        showNotification("Please select at least one position stat", type = "error")
        return()
      }
      
      # Show that processing is happening
      print("Applying filters...")
      print(paste("Feature indices:", paste(params$feature_indices, collapse = ", ")))
      print(paste("Feature indices class:", class(params$feature_indices)))
      print(paste("Feature indices length:", length(params$feature_indices)))
      print(paste("Min cluster size:", params$min_cluster_size))
      print(paste("Players ranked:", params$num_of_players_ranked))
      
      # Ensure feature_indices are integers
      feature_idx <- as.integer(params$feature_indices)
      print(paste("Converted feature indices:", paste(feature_idx, collapse = ", ")))
      print(paste("Converted class:", class(feature_idx)))
      
      # Re-run the clustering analysis with updated parameters
      tryCatch({
        results <- run_clustering_analysis(
          csv_path,
          feature_indices = params$feature_indices, # Pass as vector, not list
          min_cluster_size = params$min_cluster_size,
          num_of_players_ranked = params$num_of_players_ranked,
          min_samples = params$min_samples,
          num_of_players = params$num_of_players
        )
   
        # Debug: Check what Python returned
        print("Results received from Python:")
        print(paste("Player names length:", length(results$player_names)))
        print(paste("Cluster labels length:", length(results$cluster_labels)))
        print(paste("Features class:", class(results$features)))
        print(paste("Feature names:", paste(results$feature_names, collapse=", ")))
        
        # Validate results
        if(is.null(results$player_names) || length(results$player_names) == 0) {
          showNotification("No results returned from clustering", type = "error")
          return()
        } # :)
        
        
        # Convert updated results to dataframe
        updated_df <- data.frame(
          player_name = results$player_names,
          cluster_label = results$cluster_labels,
          is_outlier = results$outliers,
          stringsAsFactors = FALSE
        )
        
        print(paste("Base dataframe created with", nrow(updated_df), "rows"))
        
        
        cluster_labels <<- results$cluster_labels
        outliers <<- results$outliers
        player_names <<- results$player_names
        features <<- results$features
        feature_names <<- results$feature_names
        
        
        # Add feature columns
        #for(i in 1:ncol(results$features)) {
        #  updated_df[[results$feature_names[i]]] <- results$features[, i]
        #}
        
        # Update the reactive dataframe
        clustering_results_df(updated_df)
        
        # Access results
        print("Clustering complete!")
        print(paste("Cluster labels length:", length(cluster_labels)))
        print(paste("Player names length:", length(player_names)))
        
      }, error = function(e) {
        print(paste("Error in clustering:", e$message))
        showNotification(paste("Error:", e$message), type = "error", duration = 10)
        
        # NOTE: params have been updated, so use those values in outputs
      })
    }
  )
  
  
  
  output$BattersBox <- renderPlot({
    
  })
  
  
  
  output$Corner3_Percentiles <- renderPlot({
    
    # Filter data for the selected player
    player_data_Corner3Usage <- Corner3_Percentiles %>%
      filter(V2 == input$Player,
             V4 == input$Team,
             Temp == "Rate") %>%
      # Remove rows with NA in the percentile column
      filter(!is.na(Corner3Usage_percentile))

    # Check if we have data
    if(nrow(player_data_Corner3Usage) == 0) {
      return(NULL)
    }
    
    
    # Filter data for the selected player
    player_data_Assisted3s <- Corner3_Percentiles %>%
      filter(V2 == input$Player,
             V4 == input$Team,
             Temp %in% c("Rate")) %>% #, "High", "Low")) %>%
      # Remove rows with NA in the percentile column
      filter(!is.na(Assisted3s_percentile))
      # filter(!is.na(Assisted3s_percentile)) # IDK if this will work, will check this if something goes wrong (!)
    
    # Check if we have data
    if(nrow(player_data_Assisted3s) == 0) {
      return(NULL)
    }
    
    
    
    player_data_Attempted3s <- Corner3_Percentiles %>%
      filter(V2 == input$Player,
             V4 == input$Team,
             Temp %in% c("Rate")) %>% #, "High", "Low")) %>%
      # Remove rows with NA in the percentile column
      filter(!is.na(Attempted3s_percentile))
      
    # Check if we have data
    if(nrow(player_data_Attempted3s) == 0) {
      return(NULL)
    }
    
    
    
    player_data_Corner3_FGPct <- Corner3_Percentiles %>%
      filter(V2 == input$Player,
             V4 == input$Team,
             Temp %in% c("Rate")) %>% #, "High", "Low")) %>%
      # Remove rows with NA in the percentile column
      filter(!is.na(Corner3_FGPct_percentile))
    
    # Check if we have data
    if(nrow(player_data_Corner3_FGPct) == 0) {
      return(NULL)
    }
    
    
    # Check if we have data for BOTH plots
    # if(nrow(player_data_Corner3Usage) == 0 || nrow(player_data_Assisted3s) == 0) {
    #   return(NULL)
    # }
    
    
    # Temp <- 0
    
    
    # Corner 3 Amount Usage Plot
    
    # Everything between arrows is from 5.3 problem set
    # VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
    # Creating a subplot in Percentiles output called Corner 3 Usage. Using data from the Corner3_Percentiles dataset.
    # Corner3AmountUsage <- player_data%>%
    # Selecting (pitcher's) data based off the Team and Player. One pitcher will be selected.
    # filter(# Temp == input$Team,
           # V2 == input$Player,
           # Selecting that pitcher's fastball data in Corner3_Percentiles. Commented line out . . .
           # Temp %in% c("Rate", "High", "Low")) %>% # Might have a problem here
    # Creating a ggplot to display the pitcher's fastball velo and spin percentiles. This graph was explained in Module 4 - Creating Visuals - Part 2
    # Changed from Corner3_Percentiles to player_data
    
    # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    Corner3Usage_plot <- ggplot(player_data_Corner3Usage, mapping = aes(x= Corner3Usage_percentile, y= Temp)) + # , colour = Corner3Usage_percentile)) +
      # geom_line() + geom_point(size = 9)  +
      ggtitle("% Of 3s Taken In The Corners -- Percentiles") + xlim(0, 100) + # ylim("Player") +
      xlab("") + ylab("") + theme(
        
        plot.title = element_text(color = "black", size = 15, face = "italic"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x= element_blank(),
        axis.ticks.y  =element_blank(),
        axis.ticks.x  =element_blank(),
        
        axis.text.y = element_text(size=12, face="italic", colour = "black"))+
      geom_segment(aes(x = 0, xend = 100, y = Temp, yend = Temp), color = "#9b9b9b", size = 1) +
      geom_point(aes(x = 0, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = 50, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = 100, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = Corner3Usage_percentile, y = Temp, fill = Corner3Usage_percentile), pch = 21, color = "black", size = 10) +
      geom_text(aes(label=Corner3Usage_percentile),hjust=.5, vjust=.4, color = "Black",
                size = 5)+theme(legend.position = "none")+
      # Limits parameter is what is taking the place of the -5 and 105 values we added to the dataset to create color scale, Might change this later if I really want to, but it is working fine for now.
      scale_fill_gradient2(midpoint = 50, limits = c(-5, 105), low = "#cc0000", mid = "#ffffff", high = "#2952a3", oob = scales::squish,
                           na.value = "grey50") +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank())
    
    

    Assisted3s_plot <- ggplot(player_data_Assisted3s, mapping = aes(x= Assisted3s_percentile, y= Temp, colour = Assisted3s_percentile)) +
      # geom_line() + geom_point(size = 9)  +
      ggtitle("% of 3s Assisted -- Percentiles") + xlim(0, 100) + # ylim("Player") +
      xlab("") + ylab("") + theme(
        
        plot.title = element_text(color = "black", size = 15, face = "italic"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x= element_blank(),
        axis.ticks.y  =element_blank(),
        axis.ticks.x  =element_blank(),
        
        axis.text.y = element_text(size=12, face="italic", colour = "black"))+
      geom_segment(aes(x = 0, xend = 100, y = Temp, yend = Temp), color = "#9b9b9b", size = 1) +
      geom_point(aes(x = 0, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = 50, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = 100, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = Assisted3s_percentile, y = Temp, fill = Assisted3s_percentile), pch = 21, color = "black", size = 10) +
      geom_text(aes(label=Assisted3s_percentile),hjust=.5, vjust=.4, color = "Black",
                size = 5)+theme(legend.position = "none")+
      scale_fill_gradient2(midpoint = 50, limits = c(-5, 105), low = "#cc0000", mid = "#ffffff", high = "#2952a3", oob = scales::squish,
                           na.value = "grey50") +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank())
    
    
    Attempted3s_plot <- ggplot(player_data_Attempted3s, mapping = aes(x= Attempted3s_percentile, y= Temp, colour = Attempted3s_percentile)) +
      # geom_line() + geom_point(size = 9)  +
      ggtitle("Number of 3s Attempted -- Percentiles") + xlim(0, 100) + # ylim("Player") +
      xlab("") + ylab("") + theme(
        
        plot.title = element_text(color = "black", size = 15, face = "italic"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x= element_blank(),
        axis.ticks.y  =element_blank(),
        axis.ticks.x  =element_blank(),
        
        axis.text.y = element_text(size=12, face="italic", colour = "black"))+
      geom_segment(aes(x = 0, xend = 100, y = Temp, yend = Temp), color = "#9b9b9b", size = 1) +
      geom_point(aes(x = 0, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = 50, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = 100, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = Attempted3s_percentile, y = Temp, fill = Attempted3s_percentile), pch = 21, color = "black", size = 10) +
      geom_text(aes(label=Attempted3s_percentile),hjust=.5, vjust=.4, color = "Black",
                size = 5)+theme(legend.position = "none")+
      scale_fill_gradient2(midpoint = 50, limits = c(-5, 105), low = "#cc0000", mid = "#ffffff", high = "#2952a3", oob = scales::squish,
                           na.value = "grey50") +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank())
    
    
    Corner3_FGPct_plot <- ggplot(player_data_Corner3_FGPct, mapping = aes(x= Corner3_FGPct_percentile, y= Temp, colour = Corner3_FGPct_percentile)) +
      # geom_line() + geom_point(size = 9)  +
      ggtitle("FG% for Corner 3s -- Percentiles") + xlim(0, 100) + # ylim("Player") +
      xlab("") + ylab("") + theme(
        
        plot.title = element_text(color = "black", size = 15, face = "italic"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x= element_blank(),
        axis.ticks.y  =element_blank(),
        axis.ticks.x  =element_blank(),
        
        axis.text.y = element_text(size=12, face="italic", colour = "black"))+
      geom_segment(aes(x = 0, xend = 100, y = Temp, yend = Temp), color = "#9b9b9b", size = 1) +
      geom_point(aes(x = 0, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = 50, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = 100, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = Corner3_FGPct_percentile, y = Temp, fill = Corner3_FGPct_percentile), pch = 21, color = "black", size = 10) +
      geom_text(aes(label=Corner3_FGPct_percentile),hjust=.5, vjust=.4, color = "Black",
                size = 5)+theme(legend.position = "none")+
      scale_fill_gradient2(midpoint = 50, limits = c(-5, 105), low = "#cc0000", mid = "#ffffff", high = "#2952a3", oob = scales::squish,
                           na.value = "grey50") +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank())
    
    
    
    
    ggarrange(Corner3Usage_plot, Assisted3s_plot, Corner3_FGPct_plot, Attempted3s_plot, nrow = 2, ncol = 2) 
    
    
  })
  
  
  
  output$Corner3_Percentiles_Data <- renderDT({
    
    C3P <- Corner3_Percentiles%>%
      filter(Temp == "Rate",
             V4 == input$Team,
             V2 == input$Player)
    
    C3P <- subset(C3P, select = c(2,3,4,5,6,7))
    
    # Multiply value by 100
    # Tip: double brackets to target value(s) in a data frame
    C3P[[3]] <- as.numeric(C3P[[3]]) * 100
    C3P[[4]] <- as.numeric(C3P[[4]]) * 100
    C3P[[5]] <- as.numeric(C3P[[5]]) * 100
    
    names(C3P)[1] <- "Name"
    names(C3P)[2] <- "Team"
    names(C3P)[3] <- "Corner 3 Usage %"
    names(C3P)[4] <- "3s Assisted %"
    names(C3P)[6] <- "3P Attempts"
    
    
    # datatable (?) (everything in it too)
    datatable(C3P, caption = htmltools::tags$caption( style = 'caption-side: top; 
                                                  text-align: center; color:black; font-size:200% ;',
                                                      'Corner 3 Percentiles'), options = list(dom = 't', columnDefs = list(list(targets = 0, visible = FALSE)))) %>%
      formatStyle(c(1), `border-left` = "solid 1px") %>% formatStyle(c(6), `border-right` = "solid 1px") %>%
      formatRound(columns = c(3, 4, 5, 6), digits = 1)  # Format columns 3-6 to 2 decimal places
    
  })
  
  
  
  output$Corner3_Team_Scatterplot <- renderPlotly({
    # Placeholder for future scatterplot
    team_data <- Corner3_Percentiles %>%
      filter(V4 == input$Team,
             Temp == "Rate") %>%
      # Remove rows with NA in the Corner3Usage_percentile column
      filter(!is.na(`Corner3 Usage`),
             !is.na(`Corner 3P%`),) %>%
      mutate(is_selected = ifelse(V2 == input$Player, "Selected", "Other"))
    
    team_scatterplot <- ggplot(team_data, aes(x = `Corner3 Usage`, y = `Corner 3P%`, size = `3PA`,
                                              color = is_selected,
                                              text = paste0(V2, "\n3PA: ", `3PA`))) +
      geom_point(alpha = 0.6) +
      xlim(0, 1) +  # Set x-axis from 0 to 1 (or 0 to 100 if your data is in percentages)
      ylim(0, 1) +  # Set y-axis from 0 to 1 (or 0 to 100 if your data is in percentages)
      scale_size_continuous(range = c(2, 12)) + #, limits = c(0, 500)) +  # Fix size range and data limits
      scale_color_manual(values = c("Selected" = "#2952a3", "Other" = "#9b9b9b"), name = "Player") +
      # guides(color = "none") +  # Add this line to hide the color legend
      ggtitle(paste("Corner 3 Usage vs Corner 3P% vs 3PA for", input$Team)) +
      labs(size = "3-Point Attempts")  # This adds a title to the size legend
      # guides(size = guide_legend(override.aes = list(alpha = 1))) +  # Makes legend points fully opaque
      # theme(legend.position = "bottom")
      # Legend isn't showing up for some reason, idk why
    ggplotly(team_scatterplot, tooltip = "text")
    
    
  })
  
  
  
  output$Short2_Percentiles <- renderPlot({
    
    # Filter data for the selected player
    player_data_Short2Usage <- Short2_Percentiles %>%
      filter(V2 == input$Player,
             V4 == input$Team,
             Temp == "Rate") %>%
      # Remove rows with NA in the percentile column
      filter(!is.na(Short2Usage_percentile))
    
    # Check if we have data
    if(nrow(player_data_Short2Usage) == 0) {
      return(NULL)
    }
    
    
    # Filter data for the selected player
    player_data_Assisted2s <- Short2_Percentiles %>%
      filter(V2 == input$Player,
             V4 == input$Team,
             Temp %in% c("Rate")) %>% #, "High", "Low")) %>%
      # Remove rows with NA in the percentile column
      filter(!is.na(Assisted2s_percentile))
    # filter(!is.na(Assisted2s_percentile)) # IDK if this will work, will check this if something goes wrong (!)
    
    # Check if we have data
    if(nrow(player_data_Assisted2s) == 0) {
      return(NULL)
    }
    
    
    
    player_data_Attempted2s <- Short2_Percentiles %>%
      filter(V2 == input$Player,
             V4 == input$Team,
             Temp %in% c("Rate")) %>% #, "High", "Low")) %>%
      # Remove rows with NA in the percentile column
      filter(!is.na(Attempted2s_percentile))
    
    # Check if we have data
    if(nrow(player_data_Attempted2s) == 0) {
      return(NULL)
    }
    
    
    
    player_data_Short2_FGPct <- Short2_Percentiles %>%
      filter(V2 == input$Player,
             V4 == input$Team,
             Temp %in% c("Rate")) %>% #, "High", "Low")) %>%
      # Remove rows with NA in the percentile column
      filter(!is.na(Short2_FGPct_percentile))
    
    # Check if we have data
    if(nrow(player_data_Short2_FGPct) == 0) {
      return(NULL)
    }
    
    
    # Check if we have data for BOTH plots
    # if(nrow(player_data_Short2Usage) == 0 || nrow(player_data_Assisted2s) == 0) {
    #   return(NULL)
    # }
    
    
    # Temp <- 0
    
    
    # Corner 3 Amount Usage Plot
    
    # Everything between arrows is from 5.3 problem set
    # VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV
    # Creating a subplot in Percentiles output called Corner 3 Usage. Using data from the Short2_Percentiles dataset.
    # Short2AmountUsage <- player_data%>%
    # Selecting (pitcher's) data based off the Team and Player. One pitcher will be selected.
    # filter(# Temp == input$Team,
    # V2 == input$Player,
    # Selecting that pitcher's fastball data in Short2_Percentiles. Commented line out . . .
    # Temp %in% c("Rate", "High", "Low")) %>% # Might have a problem here
    # Creating a ggplot to display the pitcher's fastball velo and spin percentiles. This graph was explained in Module 4 - Creating Visuals - Part 2
    # Changed from Short2_Percentiles to player_data
    
    # ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    Short2Usage_plot <- ggplot(player_data_Short2Usage, mapping = aes(x= Short2Usage_percentile, y= Temp)) + # , colour = Short2Usage_percentile)) +
      # geom_line() + geom_point(size = 9)  +
      ggtitle("% Of 2s Taken Within 3 ft -- Percentiles") + xlim(0, 100) + # ylim("Player") +
      xlab("") + ylab("") + theme(
        
        plot.title = element_text(color = "black", size = 15, face = "italic"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x= element_blank(),
        axis.ticks.y  =element_blank(),
        axis.ticks.x  =element_blank(),
        
        axis.text.y = element_text(size=12, face="italic", colour = "black"))+
      geom_segment(aes(x = 0, xend = 100, y = Temp, yend = Temp), color = "#9b9b9b", size = 1) +
      geom_point(aes(x = 0, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = 50, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = 100, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = Short2Usage_percentile, y = Temp, fill = Short2Usage_percentile), pch = 21, color = "black", size = 10) +
      geom_text(aes(label=Short2Usage_percentile),hjust=.5, vjust=.4, color = "Black",
                size = 5)+theme(legend.position = "none")+
      # Limits parameter is what is taking the place of the -5 and 105 values we added to the dataset to create color scale, Might change this later if I really want to, but it is working fine for now.
      scale_fill_gradient2(midpoint = 50, limits = c(-5, 105), low = "#cc0000", mid = "#ffffff", high = "#2952a3", oob = scales::squish,
                           na.value = "grey50") +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank())
    
    
    
    Assisted2s_plot <- ggplot(player_data_Assisted2s, mapping = aes(x= Assisted2s_percentile, y= Temp, colour = Assisted2s_percentile)) +
      # geom_line() + geom_point(size = 9)  +
      ggtitle("% of 2s Assisted -- Percentiles") + xlim(0, 100) + # ylim("Player") +
      xlab("") + ylab("") + theme(
        
        plot.title = element_text(color = "black", size = 15, face = "italic"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x= element_blank(),
        axis.ticks.y  =element_blank(),
        axis.ticks.x  =element_blank(),
        
        axis.text.y = element_text(size=12, face="italic", colour = "black"))+
      geom_segment(aes(x = 0, xend = 100, y = Temp, yend = Temp), color = "#9b9b9b", size = 1) +
      geom_point(aes(x = 0, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = 50, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = 100, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = Assisted2s_percentile, y = Temp, fill = Assisted2s_percentile), pch = 21, color = "black", size = 10) +
      geom_text(aes(label=Assisted2s_percentile),hjust=.5, vjust=.4, color = "Black",
                size = 5)+theme(legend.position = "none")+
      scale_fill_gradient2(midpoint = 50, limits = c(-5, 105), low = "#cc0000", mid = "#ffffff", high = "#2952a3", oob = scales::squish,
                           na.value = "grey50") +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank())
    
    
    Attempted2s_plot <- ggplot(player_data_Attempted2s, mapping = aes(x= Attempted2s_percentile, y= Temp, colour = Attempted2s_percentile)) +
      # geom_line() + geom_point(size = 9)  +
      ggtitle("Number of 2s Attempted -- Percentiles") + xlim(0, 100) + # ylim("Player") +
      xlab("") + ylab("") + theme(
        
        plot.title = element_text(color = "black", size = 15, face = "italic"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x= element_blank(),
        axis.ticks.y  =element_blank(),
        axis.ticks.x  =element_blank(),
        
        axis.text.y = element_text(size=12, face="italic", colour = "black"))+
      geom_segment(aes(x = 0, xend = 100, y = Temp, yend = Temp), color = "#9b9b9b", size = 1) +
      geom_point(aes(x = 0, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = 50, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = 100, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = Attempted2s_percentile, y = Temp, fill = Attempted2s_percentile), pch = 21, color = "black", size = 10) +
      geom_text(aes(label=Attempted2s_percentile),hjust=.5, vjust=.4, color = "Black",
                size = 5)+theme(legend.position = "none")+
      scale_fill_gradient2(midpoint = 50, limits = c(-5, 105), low = "#cc0000", mid = "#ffffff", high = "#2952a3", oob = scales::squish,
                           na.value = "grey50") +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank())
    
    
    Short2_FGPct_plot <- ggplot(player_data_Short2_FGPct, mapping = aes(x= Short2_FGPct_percentile, y= Temp, colour = Short2_FGPct_percentile)) +
      # geom_line() + geom_point(size = 9)  +
      ggtitle("FG% for 2s Within 3 ft -- Percentiles") + xlim(0, 100) + # ylim("Player") +
      xlab("") + ylab("") + theme(
        
        plot.title = element_text(color = "black", size = 15, face = "italic"),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x= element_blank(),
        axis.ticks.y  =element_blank(),
        axis.ticks.x  =element_blank(),
        
        axis.text.y = element_text(size=12, face="italic", colour = "black"))+
      geom_segment(aes(x = 0, xend = 100, y = Temp, yend = Temp), color = "#9b9b9b", size = 1) +
      geom_point(aes(x = 0, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = 50, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = 100, y = Temp), color = "#9b9b9b", size = 5) +
      geom_point(aes(x = Short2_FGPct_percentile, y = Temp, fill = Short2_FGPct_percentile), pch = 21, color = "black", size = 10) +
      geom_text(aes(label=Short2_FGPct_percentile),hjust=.5, vjust=.4, color = "Black",
                size = 5)+theme(legend.position = "none")+
      scale_fill_gradient2(midpoint = 50, limits = c(-5, 105), low = "#cc0000", mid = "#ffffff", high = "#2952a3", oob = scales::squish,
                           na.value = "grey50") +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            panel.background = element_blank())
    
    
    
    
    ggarrange(Short2Usage_plot, Assisted2s_plot, Short2_FGPct_plot, Attempted2s_plot, nrow = 2, ncol = 2) 
    
    
  })
  
  
  
  output$Short2_Percentiles_Data <- renderDT({
    
    S2P <- Short2_Percentiles%>%
      filter(Temp == "Rate",
             V4 == input$Team,
             V2 == input$Player)
    
    S2P <- subset(S2P, select = c(2,3,4,5,6,7))
    
    # Multiply value by 100
    # Tip: double brackets to target value(s) in a data frame
    S2P[[3]] <- as.numeric(S2P[[3]]) * 100
    S2P[[4]] <- as.numeric(S2P[[4]]) * 100
    S2P[[5]] <- as.numeric(S2P[[5]]) * 100
    
    names(S2P)[1] <- "Name"
    names(S2P)[2] <- "Team"
    names(S2P)[3] <- "Short 2 Usage %"
    names(S2P)[4] <- "2s Assisted %"
    names(S2P)[6] <- "2P Attempts"
    
    
    # datatable (?) (everything in it too)
    datatable(S2P, caption = htmltools::tags$caption( style = 'caption-side: top; 
                                                  text-align: center; color:black; font-size:200% ;',
                                                      'Short 2 Percentiles'), options = list(dom = 't', columnDefs = list(list(targets = 0, visible = FALSE)))) %>%
      formatStyle(c(1), `border-left` = "solid 1px") %>% formatStyle(c(6), `border-right` = "solid 1px") %>%
      formatRound(columns = c(3, 4, 5, 6), digits = 1)  # Format columns 3-6 to 2 decimal places
    
  })
  
  
  
  output$Short2_Team_Scatterplot <- renderPlotly({
    # Placeholder for future scatterplot
    team_data <- Short2_Percentiles %>%
      filter(V4 == input$Team,
             Temp == "Rate") %>%
      # Remove rows with NA in the Short2Usage_percentile column
      filter(!is.na(`Short2 Usage`),
             !is.na(`Short 2P%`),) %>%
      mutate(is_selected = ifelse(V2 == input$Player, "Selected", "Other"))
    
    team_scatterplot <- ggplot(team_data, aes(x = `Short2 Usage`, y = `Short 2P%`, size = `2PA`,
                                              color = is_selected,
                                              text = paste0(V2, "\n2PA: ", `2PA`))) +
      geom_point(alpha = 0.6) +
      xlim(0, 1) +  # Set x-axis from 0 to 1 (or 0 to 100 if your data is in percentages)
      ylim(0, 1) +  # Set y-axis from 0 to 1 (or 0 to 100 if your data is in percentages)
      scale_size_continuous(range = c(2, 12)) + #, limits = c(0, 500)) +  # Fix size range and data limits
      scale_color_manual(values = c("Selected" = "#2952a3", "Other" = "#9b9b9b")) + #, name = "Player") +
      ggtitle(paste("Short 2 Usage vs Short 2P% vs 2PA for", input$Team)) +
      labs(size = "2-Point Attempts")  # This adds a title to the size legend
    # guides(size = guide_legend(override.aes = list(alpha = 1))) +  # Makes legend points fully opaque
    # theme(legend.position = "bottom")
    # Legend isn't showing up for some reason, idk why
    ggplotly(team_scatterplot, tooltip = "text")
    
    
  })
  
  
  
  
  
}



# ShinyApp - Part 3 of App Structure
# Creates the entire app, and recieves variables that are the input and server.

shinyApp(ui = ui, server = server)




# Some changes I kind of want to make
# Maybe change the plot to show all players on a team and their corner 3 usage percentiles, and filter by position, ppg, or other stats.
  # I only want to make this change if 3pt usage rate is the only stat we are looking at, or we makea. seperate tab/plot for this change.

# REMEMBER: GIVE CREDIT TO THE DATA SOURCE IN YOUR VIDEOS/PRESENTATIONS!!
  # Sources Used: Basketball Reference, Baseball Sevant, 

