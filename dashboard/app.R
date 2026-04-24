#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(dplyr)
library(leaflet)
library(scales)
library(ggplot2)
library(ggridges)   

# Load data
routes_with_locations <- readRDS("../data/routes_with_locations.rds")

bus_stops_map <- routes_with_locations %>%
  group_by(BusStopCode, RoadName, Description, Latitude, Longitude) %>%
  summarise(ServiceCount = n_distinct(ServiceNo), .groups = "drop")

ui <- fluidPage(
  titlePanel("Singapore Bus Stop Connectivity"),
  sidebarLayout(
    sidebarPanel(
      selectizeInput("road", "Filter by road name:",
                     choices = sort(unique(bus_stops_map$RoadName)),
                     multiple = TRUE
      ),
      sliderInput("local_max", "Max services for Local:", min = 1, max = 5, value = 2),
      sliderInput("connector_max", "Max services for Connector:", min = 3, max = 10, value = 5)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Map", leafletOutput("map", height = 650)),
        tabPanel("Connectivity Categories", plotOutput("barplot", height = 500)),
        tabPanel("Ridgeline Plot", plotOutput("ridgeline", height = 600))
      )
    )
  )
)

server <- function(input, output) {
  
  filtered_data <- reactive({
    if (is.null(input$road) || length(input$road) == 0) bus_stops_map
    else bus_stops_map %>% filter(RoadName %in% input$road)
  })
  
  output$map <- renderLeaflet({
    df <- filtered_data()
    bubble_sizes <- rescale(df$ServiceCount, to = c(4, 15))
    leaflet(df) %>%
      addTiles() %>%
      addCircleMarkers(
        lng = ~Longitude, lat = ~Latitude,
        popup = ~paste0("<b>", Description, "</b><br>", RoadName, "<br>Services: ", ServiceCount),
        radius = bubble_sizes, color = "blue", fillOpacity = 0.4
      )
  })
  
  output$barplot <- renderPlot({
    df <- bus_stops_map %>%
      mutate(Category = case_when(
        ServiceCount <= input$local_max ~ "Local",
        ServiceCount <= input$connector_max ~ "Connector",
        TRUE ~ "Hub"
      )) %>% count(Category)
    
    ggplot(df, aes(x = Category, y = n, fill = Category)) +
      geom_col() +
      geom_text(aes(label = n), vjust = -0.5) +
      scale_fill_manual(values = c("Local" = "skyblue", "Connector" = "orange", "Hub" = "red")) +
      labs(title = "Bus Stops by Connectivity Category") +
      theme_minimal(base_size = 14)
  })
  
  output$ridgeline <- renderPlot({
    df <- filtered_data()  
    ggplot(df, aes(x = ServiceCount, y = RoadName, fill = RoadName)) +
      geom_density_ridges(alpha = 0.6) +
      labs(x = "Number of Services", y = "Road", title = "Distribution of Service Counts by Road") +
      theme_minimal(base_size = 14) +
      theme(legend.position = "none")
  })
}

shinyApp(ui = ui, server = server)
