library(tidyverse)
library(jsonlite)

raw_reviews <- fromJSON("maps_data/Reviews.json") %>% 
  as_tibble() %>% flatten() %>% as_tibble() %>%
  select(-type, -features.type, -features.geometry.coordinates, -features.geometry.type, -`features.properties.Location.Country Code`) 

colnames(raw_reviews)[1] <- "maps_url"
colnames(raw_reviews)[2] <- "date_time"
colnames(raw_reviews)[3] <- "rating"
colnames(raw_reviews)[4] <- "review"
colnames(raw_reviews)[5] <- "address"
colnames(raw_reviews)[6] <- "business_name"
colnames(raw_reviews)[7] <- "latitude"
colnames(raw_reviews)[8] <- "longitude"

# Calculate boundaries for locaitons
long_bounds <- as.double(c(min(raw_reviews$longitude), max(raw_reviews$longitude)))
lat_bounds <- as.double(c(min(raw_reviews$latitude), max(raw_reviews$latitude)))
geometrical_center <- c(mean(lat_bounds),mean(long_bounds))

raw_reviews <- raw_reviews %>% 
  separate(col = address, sep = ", ", into = c("address", "city", "state.zip", "country"),remove = TRUE) %>% 
  separate(col = state.zip, into = c("state", "zip"))
