library(tidyverse) # Of course
library(leaflet) # For making beautiful maps
library(leaflet.extras)
library(lubridate) # For working with dates/times
library(jsonlite) # Handles JSON files from Google Takeout
library(htmlwidgets) # Saving HTML widget as .html file

ratings_file <-"Takeout/Reviews.json" 
loc_hist_file <- "Takeout/LocationHistory.json"


# Functions ---------------------------------------------------------------

tidy_json <- function(f) {
  out <- fromJSON(f) %>% 
    as_tibble() %>% flatten() %>% as_tibble()
  return(out)
}

clean_ratings <- function(ratings_tibble) {
  
  ratings_tibble <- ratings_tibble %>% 
    select(-type, -features.type, -features.geometry.coordinates, 
                            -features.geometry.type, -`features.properties.Location.Country Code`)
 
   # Rename columns to make more sense
  colnames(ratings_tibble)[1] <- "maps_url"
  colnames(ratings_tibble)[2] <- "date_time"
  colnames(ratings_tibble)[3] <- "rating"
  colnames(ratings_tibble)[4] <- "review"
  colnames(ratings_tibble)[5] <- "address"
  colnames(ratings_tibble)[6] <- "business_name"
  colnames(ratings_tibble)[7] <- "latitude"
  colnames(ratings_tibble)[8] <- "longitude"
  
  # Fix time formatting and data type
  ratings_tibble$date_time <- ratings_tibble$date_time %>% 
    gsub(pattern = "T", replacement = " ")  %>% 
    gsub(pattern = "Z", replacement = "") %>% ymd_hms()
  
  # Change $rating column to factor
  ratings_tibble$rating <- as.factor(ratings_tibble$rating) %>% 
    factor(levels = c("1", "2", "3", "4", "5"))
  
  # Parse out parts of the address column using regular expressions via stringr::str_match
  addresses <- str_match(ratings_tibble$address,
                         "[[:digit:]]+[[:space:]][[:alpha:]]{1}[[:space:]][[:alnum:][:space:]]+") # e.g. "21 N Squaw Creek Dr"
  cities <- str_match(ratings_tibble$address,"[,][[:space:]][[:alpha:]]+[,]") %>% # e.g. ", Bronx,"
    gsub(pattern = ",",replacement = "") %>% trimws() %>% as.vector()
  state.zip <- str_match(ratings_tibble$address,"([[:alpha:]]{2})[[:space:]]([[:digit:]]{5})") # e.g. "NY 10469"
  states <- state.zip[,2]
  zips <- state.zip[,3]
  countries <- str_match(ratings_tibble$address,"[[:alpha:][:space:]]+$") %>% # e.g. "United States" (anchored to end)
    gsub(pattern = "USA", replacement = "United States") %>% trimws()
  
  # Add in the columns of the parsed address column
  ratings_tibble <- ratings_tibble %>% 
    add_column(states, zips, addresses, cities, countries)
  
  # Remove the old, unparsed, address column
  ratings_tibble <- ratings_tibble %>% select(-address)
  
  # Convert latitude and longitude to numeric type
  ratings_tibble$latitude <- as.numeric(ratings_tibble$latitude)
  ratings_tibble$longitude <- as.numeric((ratings_tibble$longitude))
  
  return(ratings_tibble)
}

clean_history <- function(loc_hist_tibble) {
  loc_hist_tibble <- loc_hist_tibble %>% 
    select(locations.latitudeE7, locations.longitudeE7)
  
  colnames(loc_hist_tibble)[1] <- "latitude"
  colnames(loc_hist_tibble)[2] <- "longitude"
  
  # Get rid of NA values and rescale
  loc_hist_tibble <- na.omit(loc_hist_tibble)
  loc_hist_tibble <- loc_hist_tibble*10^-7 # These are originally recorded as *10^7
  
  return(loc_hist_tibble)
}

map_ratings <- function(df, m) {
  pal <- colorFactor("RdYlGn", df$rating) # Color palette
  
  m <- m %>% fitBounds(min(df$longitude), min(df$latitude), max(df$longitude), max(df$latitude)) %>% 
    addCircleMarkers(group = "Ratings", data = df,
                     radius = 8, weight = 1, color = "#777777",
                     fillColor = ~pal(rating), fillOpacity = 0.7,
                     popup = paste0("<b><a href='", df$maps_url,"' target='_blank'>",
                                    df$business_name, "</a></b>",
                                    "<br>",
                                    "Rating: ", lapply(df$rating, 
                                                       function(x) paste(unlist(rep("\u2605",times=x)),
                                                                         collapse = "")),
                                    "<br>",
                                    "Review: ", df$review
                     )
    ) %>%
    addLegend(group = "Ratings", position = "bottomright",
              title = "Ratings", pal = pal,
              values = levels(df$rating))
  
  return(m)
}

map_loc_hist <- function(df, m) {
  m <- m %>%
    addHeatmap(data = df, group = "Heatmap",
                          blur = 15, radius = 7, gradient = "Purples")
  return(m)
}

# Main --------------------------------------------------------------------


my_map <- leaflet() %>% addTiles(group = "OSM (default)")
layers <- NULL

if (file.exists(ratings_file)) {
  ratings <- tidy_json(ratings_file)
  cleaned_ratings <- clean_ratings(ratings)
  my_map <- map_ratings(cleaned_ratings, my_map)
  layers <- append(layers, "Ratings")
}

if (file.exists(loc_hist_file)) {
  loc_hist <- tidy_json(loc_hist_file)
  cleaned_loc_hist <- clean_history(loc_hist)
  my_map <- map_loc_hist(cleaned_loc_hist, my_map)
  layers <- append(layers, "Heatmap")
}

my_map <- my_map %>% addLayersControl(
  overlayGroups = layers
)

my_map
