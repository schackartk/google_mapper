library(shiny)
library(leaflet)
library(RColorBrewer)
library(lubridate) # For working with dates/times
library(tidyverse)
library(jsonlite)
library(viridis)


# Data Tidying ------------------------------------------------------------


# Import the data and filter out columns that are not useful
ratings <- fromJSON("maps_data/Reviews.json") %>% 
  as_tibble() %>% flatten() %>% as_tibble() %>%
  select(-type, -features.type, -features.geometry.coordinates, 
         -features.geometry.type, -`features.properties.Location.Country Code`) 

# Rename columns to make more sense
colnames(ratings)[1] <- "maps_url"
colnames(ratings)[2] <- "date_time"
colnames(ratings)[3] <- "rating"
colnames(ratings)[4] <- "review"
colnames(ratings)[5] <- "address"
colnames(ratings)[6] <- "business_name"
colnames(ratings)[7] <- "latitude"
colnames(ratings)[8] <- "longitude"

# Fix time formatting and data type
ratings$date_time <- ratings$date_time %>% 
  gsub(pattern = "T", replacement = " ")  %>% 
  gsub(pattern = "Z", replacement = "") %>% ymd_hms()

# Change $rating column to factor
ratings$rating <- as.factor(ratings$rating)
levels(ratings$rating) <- seq(1:5)

# Parse out parts of the address column using regular expressions via stringr::str_match
addresses <- str_match(ratings$address,
                       "[[:digit:]]+[[:space:]][[:alpha:]]{1}[[:space:]][[:alnum:][:space:]]+") # e.g. "21 N Squaw Creek Dr"
cities <- str_match(ratings$address,"[,][[:space:]][[:alpha:]]+[,]") %>% # e.g. ", Bronx,"
  gsub(pattern = ",",replacement = "") %>% trimws() %>% as.vector()
state.zip <- str_match(ratings$address,"([[:alpha:]]{2})[[:space:]]([[:digit:]]{5})") # e.g. "NY 10469"
states <- state.zip[,2]
zips <- state.zip[,3]
countries <- str_match(ratings$address,"[[:alpha:][:space:]]+$") %>% # e.g. "United States" (anchored to end)
  gsub(pattern = "USA", replacement = "United States") %>% trimws()

# Add in the columns of the parsed address column
ratings <- ratings %>% 
  add_column(states, zips, addresses, cities, countries)

# Remove the old, unparsed, address column
ratings <- ratings %>% select(-address)

# Convert latitude and longitude to numeric type
ratings$latitude <- as.numeric(ratings$latitude)
ratings$longitude <- as.numeric((ratings$longitude))

# Shiny Application -------------------------------------------------------

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10,
                selectInput("colors", "Color Scheme",
                            rownames(subset(brewer.pal.info, category %in% c("seq", "div")))
                )
  )
)

server <- function(input, output, session) {
  
  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.
  colorpal <- reactive({
    colorFactor(input$colors, ratings$rating)
  })
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(ratings) %>% addTiles() %>% 
      fitBounds(~min(longitude), ~min(latitude), ~max(longitude), ~max(latitude))
  })
  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
    pal <- colorpal()
    
    leafletProxy("map", data = ratings) %>%
      clearShapes() %>%
      addCircleMarkers(radius = 8, weight = 1, color = "#777777",
                 fillColor = ~pal(rating), fillOpacity = 0.7, popup = ~paste(rating)
      )
  })
  
  # Use a separate observer to recreate the legend as needed.
  observe({
    proxy <- leafletProxy("map", data = ratings)
    
    # Remove any existing legend, and only if the legend is
    # enabled, create a new one.
    proxy %>% clearControls()
    pal <- colorpal()
    proxy %>% addLegend(position = "bottomright",
                        pal = pal, values = ~rating
    )
  })
}

shinyApp(ui, server)