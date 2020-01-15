#!/usr/bin/env Rscript

suppressWarnings(library(argparser))
suppressWarnings(suppressMessages(library(tidyverse)))

# Load main script
# The following file following should be in the same directory as this script
source("google_mapper.R")

parser <- arg_parser("google_mapper", hide.opts = TRUE)

parser <- parser %>% 
  add_argument("--ratings",
               help = "Ratings/reviews json file",
               default = "Takeout/Reviews.json"
               ) %>% 
  
  add_argument("--locations",
               help = "Location history json file",
               default = "Takeout/LocationHistory.json"
               ) %>% 
  
  add_argument("--labels",
               short = "-b",
               help = "Labeled places json file",
               default = "Takeout/LabeledPlaces.json"
               ) %>% 
  
  add_argument("--outfile",
               help = "Output file name",
               default = "map.html"
  )

argv <- parse_args(parser)

# Put file names into a list
files <- c(argv$ratings, argv$locations, argv$labels, argv$outfile)
names(files) <- c("ratings", "location", "labels", "outfile")


# Call the main script, pass files as argument
map_data(files = files)
