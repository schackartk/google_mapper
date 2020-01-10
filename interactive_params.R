library(shiny)
library(leaflet)
library(leaflet.extras)
library(RColorBrewer)
library(tidyverse)
library(jsonlite)


# Data Tidying ------------------------------------------------------------


# Import the data and filter out columns that are not useful
locations <- fromJSON("Takeout/LocationHistory.json") %>% 
  as_tibble() %>% flatten() %>% as_tibble() %>% 
  select(locations.latitudeE7, locations.longitudeE7)

# Rename columns to make more sense

colnames(locations)[1] <- "latitude"
colnames(locations)[2] <- "longitude"

# Fix time formatting and data type
locations <- na.omit(locations)
locations <- locations*10^-7 # These are originally recorded as *10^7

# Shiny Application -------------------------------------------------------

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                selectInput("colors", "Color Scheme",
                            rownames(subset(brewer.pal.info, category %in% "seq"))
                ),
                
                sliderInput("radius", "Radius:",
                            min = 1, max = 100,
                            value = 25),
                
                sliderInput("blur", "Blur:",
                            min = 1, max = 100,
                            value = 15),
                
                sliderInput("max", "Max:",
                            min = 0, max = 1,
                            step = 0.05, value = 1),
                
                sliderInput("minOpacity", "Min Opacity:",
                            min = 0, max = 1,
                            value = 0),
                
                sliderInput("cellSize", "Cell Size:",
                            min = 1, max = 100,
                            value = 12)
  )
)

server <- function(input, output, session) {
  
  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.
  #colorpal <- reactive({
  #  colorFactor(input$colors, ratings$rating)
  #})
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(locations) %>% addTiles() %>% 
      fitBounds(~min(longitude), ~min(latitude), ~max(longitude), ~max(latitude))
  })
  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
  #  pal <- colorpal()
    
    leafletProxy("map", data = locations) %>%
      clearShapes() %>% clearHeatmap() %>% 
      addHeatmap(blur = input$blur, radius = input$radius, max = input$max, gradient = input$colors,
                 minOpacity = input$minOpacity, cellSize = input$cellSize)
  })
}

shinyApp(ui, server)