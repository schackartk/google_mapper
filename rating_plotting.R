library(tidyverse)
library(jsonlite)

# Import the data and filter out columns that are not useful
reviews <- fromJSON("maps_data/Reviews.json") %>% 
  as_tibble() %>% flatten() %>% as_tibble() %>%
  select(-type, -features.type, -features.geometry.coordinates, -features.geometry.type, -`features.properties.Location.Country Code`) 

# Rename columns to make more sense
colnames(reviews)[1] <- "maps_url"
colnames(reviews)[2] <- "date_time"
colnames(reviews)[3] <- "rating"
colnames(reviews)[4] <- "review"
colnames(reviews)[5] <- "address"
colnames(reviews)[6] <- "business_name"
colnames(reviews)[7] <- "latitude"
colnames(reviews)[8] <- "longitude"

# Calculate boundaries for locaitons
long_bounds <- as.double(c(min(reviews$longitude), max(reviews$longitude)))
lat_bounds <- as.double(c(min(reviews$latitude), max(reviews$latitude)))
geometrical_center <- c(mean(lat_bounds),mean(long_bounds)) # Currently as c(lat,long), may need to rearrange

# Clean up address
state_zip_pattern <- "([[:alpha:]]{2})[[:space:]]([[:digit:]]{5})"
states <- str_match(reviews$address,state_zip_pattern)[,2]
zips <- str_match(reviews$address,state_zip_pattern)[,3]

address_pattern <- "[[:digit:]]+[[:space:]][[:alpha:]]{1}[[:space:]][[:alnum:][:space:]]+"
address_matches <- gregexpr(address_pattern,reviews$address)
addresses <- regmatches(reviews$address,address_matches) %>% gsub(pattern = "character(0)", replacement = "NA")

city_pattern <- "[,][[:space:]][[:alpha:]]+[,]"
city_matches <- gregexpr(city_pattern,reviews$address)
cities <- regmatches(reviews$address,city_matches) %>% gsub(pattern = ",",replacement = "") %>% trimws()

country_pattern <- "[[:alpha:][:space:]]+$"
country_matches <- gregexpr(country_pattern,reviews$address)
countries <- regmatches(reviews$address,country_matches) %>% gsub(pattern = "USA", replacement = "United States") %>% trimws()

reviews <- reviews %>% 
  add_column(states, zips, addresses, cities, countries)

reviews <- reviews %>% select(-address)

