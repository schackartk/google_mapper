library(tidyverse)
library(jsonlite)
library(ggmap)

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

# Calculate boundaries for locaitons
buffer <- 0.05
bounding_box <- c(min(ratings_of_interest$longitude, na.rm = TRUE) - buffer, # Left
                 min(ratings_of_interest$latitude, na.rm = TRUE) - buffer,   # Bottom
                 max(ratings_of_interest$longitude, na.rm = TRUE) + buffer,  # Right
                 max(ratings_of_interest$latitude, na.rm = TRUE) + buffer    # Top
                 )

# Get map from google based on location boundaries
sq_map2 <-
  get_map(
    bounding_box,
    source = "google",
    zoom = 10
  )

# Plot the map and ratings
review_map <- ggmap(sq_map2) +
  geom_point(data = ratings_of_interest, 
             mapping = aes(x = longitude, y = latitude, color = rating, alpha = 0.7),
             size = 2) + xlab(NULL) + ylab(NULL)
review_map
