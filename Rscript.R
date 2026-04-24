#Load packages 
library(pacman)
pacman::p_load(httr, jsonlite, dplyr, ggplot2, purrr)
library(tidyverse)

#Define base URL
base_url <- "https://datamall2.mytransport.sg/ltaodataservice"

#Define access tokens 
API_KEY <- "aNXZQibBTGStKiyq3RGGiQ=="

# Correct endpoints
endpoint_busstop <- "/BusStops"
endpoint_busroute <- "/BusRoutes"

##For BusStops
#To get request 
get_busstops <- function(skip) { 
  url <- paste0(base_url, "/BusStops?$skip=", skip) 
  response <- GET( 
    url, 
    add_headers(AccountKey = API_KEY, accept = "application/json") ) 
  data <- content(response, as = "text", encoding = "UTF-8") %>% fromJSON(flatten = TRUE) 
  return(data$value) 
  } 

#Loop through pages (500 records per page) 
all_busstops <- map_dfr(seq(0, 60000, by = 500), get_busstops) 

#Inspect results 
glimpse(all_busstops)

##For Bus Routes 
get_busroutes <- function(skip) { 
  url <- paste0(base_url, "/BusRoutes?$skip=", skip) 
  response <- GET( 
    url, 
    add_headers(AccountKey = API_KEY, accept = "application/json") ) 
  data <- content(response, as = "text", encoding = "UTF-8") %>% fromJSON(flatten = TRUE) 
  return(data$value) 
} 

#Loop through pages (500 records per page) 
all_busroutes <- map_dfr(seq(0, 60000, by = 500), get_busroutes) 

#Inspect results 
glimpse(all_busroutes)

#Merge both data sets based on bus route column 
routes_with_locations <- merge(
  all_busroutes,
  all_busstops,
  by = "BusStopCode",
  all = FALSE
)


#Part 2 cleaning data?
bus_stops <- all_busstops %>%
  transmute(
    BusStopCode = as.character(BusStopCode),
    RoadName    = as.character(RoadName),
    Description = as.character(Description),
    Latitude    = as.numeric(Latitude),
    Longitude   = as.numeric(Longitude)
  ) %>%
  distinct()

nrow(bus_stops)
glimpse(bus_stops)
colSums(is.na(bus_stops))


#Part 3 
library(shiny)


write.csv(routes_with_locations, file="routes_with_locations")
read.csv("routes_with_locations")