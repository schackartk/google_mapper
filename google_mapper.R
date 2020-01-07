library(tidyverse) # Of course
library(leaflet) # For making beautiful maps
library(leaflet.extras)
library(lubridate) # For working with dates/times
library(jsonlite) # Handles JSON files from Google Takeout
library(htmlwidgets) # Saving HTML widget as .html file

ratings_file <-"Takeout/Reviews.json" 
loc_hist_file <- "Takeout/LocationHistory.json"
label_file <- "Takeout/LabeledPlaces.json"
saved_file <- "Takeout/SavePlaces.json"


# Functions ---------------------------------------------------------------

tidy_json <- function(f) {
  out <- fromJSON(f) %>% 
    as_tibble() %>% flatten() %>% as_tibble()
  return(out)
}

clean_ratings <- function(df) {
  
  # Filter out unnecessary columns
  df <- df %>% 
    select(-type, -features.type, -features.geometry.coordinates, 
                            -features.geometry.type, -`features.properties.Location.Country Code`)
 
   # Rename columns to make more sense
  colnames(df)[1] <- "maps_url"
  colnames(df)[2] <- "date_time"
  colnames(df)[3] <- "rating"
  colnames(df)[4] <- "review"
  colnames(df)[5] <- "address"
  colnames(df)[6] <- "business_name"
  colnames(df)[7] <- "latitude"
  colnames(df)[8] <- "longitude"
  
  # Fix time formatting and data type
  df$date_time <- df$date_time %>% 
    gsub(pattern = "T", replacement = " ")  %>% 
    gsub(pattern = "Z", replacement = "") %>% ymd_hms()
  
  # Change $rating column to factor
  df$rating <- as.factor(df$rating) %>% 
    factor(levels = c("1", "2", "3", "4", "5"))
  
  # Convert latitude and longitude to numeric type
  df$latitude <- as.numeric(df$latitude)
  df$longitude <- as.numeric((df$longitude))
  
  return(df)
}

clean_history <- function(df) {
  df <- df %>% 
    select(locations.latitudeE7, locations.longitudeE7)
  
  colnames(df)[1] <- "latitude"
  colnames(df)[2] <- "longitude"
  
  # Get rid of NA values and rescale
  df <- na.omit(df)
  df <- df*10^-7 # These are originally recorded as *10^7
  
  return(df)
}

clean_labels <- function(df) {
  df <- df %>% 
    select(-type, -features.type, -features.geometry.type)
  
  colnames(df)[1] <- "coords"
  colnames(df)[2] <- "address"
  colnames(df)[3] <- "name"
  
  latitude <- str_match(df$coords, "[[:digit:]]+\\.[[:digit:]]+[,]") %>% 
    gsub(pattern = ",", replacement = "")
  
  longitude <- str_match(df$coords, ".[[:digit:]]+\\.[[:digit:]]+[\\)]") %>% 
    gsub(pattern = ")", replacement = "") %>% trimws()
  
  df <- df %>% 
    add_column(latitude, longitude) %>% select(-coords)
  
  return(df)
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
} else {
  message(paste0("No file found for ratings: '",ratings_file,"'"))
}

if (file.exists(loc_hist_file)) {
  loc_hist <- tidy_json(loc_hist_file)
  cleaned_loc_hist <- clean_history(loc_hist)
  my_map <- map_loc_hist(cleaned_loc_hist, my_map)
  layers <- append(layers, "Heatmap")
} else {
  message(paste0("No file found for location history: '",loc_hist_file, "'"))
}

if(file.exists(label_file)) {
  labs <- tidy_json(label_file)
  cleaned_labs <- clean_labels(labs)
}

my_map <- my_map %>% addLayersControl(
  overlayGroups = layers
)

my_map
