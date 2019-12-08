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
geometrical_center <- c(mean(lat_bounds),mean(long_bounds)) # Currently as c(lat,long), may need to rearrange

# Clean up address
state_zip_pattern <- "([[:alpha:]]{2})[[:space:]]([[:digit:]]{5})"
states <- str_match(raw_reviews$address,state_zip_pattern)[,2]
zips <- str_match(raw_reviews$address,state_zip_pattern)[,3]

address_pattern <- "[[:digit:]]+[[:space:]][[:alpha:]]{1}[[:space:]][[:alnum:][:space:]]+"
address_matches <- gregexpr(address_pattern,raw_reviews$address)
addresses <- regmatches(raw_reviews$address,address_matches) %>% gsub(pattern = "character(0)", replacement = "NA")

city_pattern <- "[,][[:space:]][[:alpha:]]+[,]"
city_matches <- gregexpr(city_pattern,raw_reviews$address)
cities <- regmatches(raw_reviews$address,city_matches) %>% gsub(pattern = ",",replacement = "") %>% trimws()

country_pattern <- "[[:alpha:][:space:]]+$"
country_matches <- gregexpr(country_pattern,raw_reviews$address)
countries <- regmatches(raw_reviews$address,country_matches) %>% gsub(pattern = "USA", replacement = "United States") %>% trimws()

  