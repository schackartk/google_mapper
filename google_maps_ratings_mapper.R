library(tidyverse) # Of course
library(leaflet) # For making beautiful maps
library(lubridate) # For working with dates/times
library(jsonlite) # Handles JSON files from Google Takeout
library(htmlwidgets) # Saving HTML widget as .html file

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
ratings$rating <- as.factor(ratings$rating) %>% 
  factor(levels = c("1", "2", "3", "4", "5"))

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

# Generate map widget -----------------------------------------------------

pal <- colorFactor("RdYlGn", ratings$rating) # Color palette

ratings_map <- leaflet(ratings) %>% addTiles() %>% 
  fitBounds(~min(longitude), ~min(latitude), ~max(longitude), ~max(latitude)) %>% 
  addCircleMarkers(radius = 8, weight = 1, color = "#777777",
                   fillColor = ~pal(rating), fillOpacity = 0.7,
                   popup = paste0("<b><a href='", ratings$maps_url,"' target='_blank'>",
                                  ratings$business_name, "</a></b>",
                                  "<br>",
                                  "Rating: ", lapply(ratings$rating, 
                                                     function(x) paste(unlist(rep("\u2605",times=x)),
                                                                       collapse = "")),
                                  "<br>",
                                  "Review: ", ratings$review
                                   )
  ) %>%
  addLegend(position = "bottomright", title = "Ratings", pal = pal, values = levels(ratings$rating))

saveWidget(ratings_map, "ratings_widget.html")
