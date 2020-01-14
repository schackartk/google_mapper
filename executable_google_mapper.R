#!/usr/bin/env Rscript

suppressWarnings(library(argparser))
suppressWarnings(suppressMessages(library(tidyverse)))

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
  
  add_argument("--saved",
               help = "Saved places json file",
               default = "Takeout/SavePlaces.json",
               type = "FILE"
               )

argv <- parse_args(parser)

print(argv$ratings)
