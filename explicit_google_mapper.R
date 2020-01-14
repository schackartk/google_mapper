# Load main script
# The following file following should be in the same directory as this script
source("google_mapper2.R")

# Hard coded file names and paths
ratings_file <-"Takeout/Reviews.json" 
loc_hist_file <- "Takeout/LocationHistory.json"
label_file <- "Takeout/LabeledPlaces.json"
saved_file <- "Takeout/SavePlaces.json"

# Put file names into a list
files <- c(ratings_file, loc_hist_file, label_file, saved_file)
names(files) <- c("ratings", "location", "labels", "saved")

# Call the main script, pass files as argument
map_data(files = files)