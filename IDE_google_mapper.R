# Load main script
# The following file should be in the same directory as this script

source("google_mapper.R")

# Hard coded file names and paths

ratings_file <- "Takeout/Maps (your places)/Reviews.json"
loc_hist_file <- "Takeout/Location History/Location History.json"
label_file <- "Takeout/Maps/My labeled places/Labeled places.json"
out_file <- "map.html"

# Put file names into a list

files <- c(ratings_file, loc_hist_file, label_file, out_file)
names(files) <- c("ratings", "location", "labels", "outfile")

# Call the main script, pass files as argument

map_data(files = files)
