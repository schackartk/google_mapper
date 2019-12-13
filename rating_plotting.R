library(tidyverse)
library(jsonlite)
library(ggmap)
library(viridis)
library(gganimate)
library(lubridate)
library(av)

# Register my google key
google_key <- read_file("google_key.txt")
register_google(key = google_key)

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

# Select the city to use 
ratings_of_interest <- ratings[ratings$cities == "Tucson",] # This part is well suited for a shiny app, may change

ratings_of_interest$latitude <- as.double(ratings_of_interest$latitude)
ratings_of_interest$longitude <- as.double(ratings_of_interest$longitude)

# Get rid of missing values
ratings_of_interest <- ratings_of_interest %>% 
  select(date_time, rating, latitude, longitude) %>% 
  na.omit()

ratings_of_interest <- ratings_of_interest[order(ratings_of_interest$date_time),]
ratings_of_interest <- ratings_of_interest[ratings_of_interest$latitude < 32.4,]

# Calculate boundaries for locations
long_bounds <- c(min(ratings_of_interest$longitude), max(ratings_of_interest$longitude))
lat_bounds <- c(min(ratings_of_interest$latitude), max(ratings_of_interest$latitude))
geometric_center <- c(mean(long_bounds),mean(lat_bounds))

# Get map from google based on location boundaries
area_map <-
  get_googlemap(
    geometric_center,
    source = "google",
    zoom = 11,
    maptype = "terrain",
    size = c(640,640)
  )

# Plot the map and ratings
review_map <- ggmap(area_map) +
  geom_point(data = ratings_of_interest, 
             mapping = aes(x = longitude, y = latitude, color = rating, group = date_time),
             alpha = 0.7, size = 4) + 
  scale_color_brewer(palette = "Spectral", "Star Rating") +
  xlab(NULL) + ylab(NULL) + ggtitle("My Google Maps Place Ratings") +
  theme(plot.title = element_text(size = 30)) +
  transition_reveal(along = date_time, keep_last = TRUE)

animate(review_map, renderer = av_renderer(), duration = 45, height = 640, width = 640)

anim_save("animated_ratings.mp4")
