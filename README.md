# `google_mapper`
# Make an interactive html map from your Google Takeout data
![example](https://github.com/schackartk/google_mapper/blob/master/example_output.JPG)
A script to visualize Google Maps Takeout data. Written in R. Currently supports plotting place ratings/reviews, labeled places, and location history (as a heatmap).

I have supplied both a command-line executable version (`executable_google_mapper.R`) and a hard-coded script (`IDE_google_mapper.R`).

If you are unsure which will work for you, please use the hard-coded script. The executable version will most likely require more work to get your path/environment to get it to work.

# Preparatory Steps

## Clone this Repository

You can refer to [these instructions](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) for help with cloning from GitHub.

## Download Your Data
Download your archive from [Google Takeout](https://takeout.google.com/).

More information on how to do this can be found [here](https://support.google.com/accounts/answer/3024190?hl=en).

For this script, you will need to select "Location History", "Maps", and "Maps (your places)". You can download others, but these are the ones that will be used. Download all files as JSON.

Unzip the data. If you would like the default paths to work, unzip to this repo's location on your machine and leave the default file structure. This should place a directory called "Takeout" in the same place as this repo. You may be missing some of the files used in this script if you have never posted any ratings or reviews on Google Maps, or if your location history has been disabled.

## Install the Necessary Libraries

The scripts only load the necessary packages, so you have to install the packages first. To make this easier, you may open and run the script `requirements.R` in an IDE, or run `./requirements.R` from the command line.

# Expected Behavior

There are two ways to run `google_mapper`:
* `IDE_google_mapper.R` is run from an IDE, like RStudio. If you haven't set up R for executable files from the command-line, use this version.
* `executable_google_mapper.R` is run from the command line.

The end product is an HTML widget that can be opened in most web browsers.

## `IDE_google_mapper.R`

Edit the `IDE_google_mapper.R` script to make the paths to the respective files match your file structure.

If you are using paths relative to where the script is located (which is the case for the default paths), make sure to change your working directory, e.g. run `setwd("path/to/google_mapper/directory")` in RStudio.

Run `IDE_google_mapper.R` as you would any R code.

If there are errors or warnings, they will be displayed in the same way as the command line version (as seen below).

Once it runs, open the .html file now present in the same directory as this code.

## `executable_google_mapper.R` (Command Line)

Usage Statement and Help:
```
./executable_google_mapper.R -h

usage: executable_google_mapper.R [--] [--help] [--ratings RATINGS]
       [--locations LOCATIONS] [--labels LABELS] [--outfile OUTFILE]

google_mapper

flags:
  -h, --help       show this help message and exit

optional arguments:
  -r, --ratings    Ratings/reviews json file [default: Takeout/Maps
                   (your places)/Reviews.json]
  -l, --locations  Location history json file [default:
                   Takeout/Location History/Location History.json]
  -b, --labels     Labeled places json file [default: Takeout/Maps/My
                   labeled places/Labeled places.json]
  -o, --outfile    Output file name [default: map.html]
```

Default Behavior with Valid Files:
```
./executable_google_mapper.R

Processing ratings file... Done processing ratings file.
Processing location history file... Done processing location history file.
Processing labeled places file... Done processing labeled places file.
Saving map output.
Done, see file: 'map.html'!
```

# Acknowledgements

I was inspired to make a Google Takeout Maps data visulation by Luka Steinbach's [Geo Heatmap](https://github.com/luka1199/geo-heatmap) made in Python. Honestly, leaflet's heatmap algorithm is simply better in Python, no matter how much parameter tweaking I do. Check out Luka's repo for a better location history heatmap.

# Disclaimer

I had access to only a few people's Takeout archives. I designed my data processing based on the file structures I observed. I can't guarantee Takeout will give you a file that can be handled in the way I designed this. I tried to introduce error handling, but I am not a pro.

# Authorship

Kenneth Schackart

* Twitter: [\@SchackartK](https://twitter.com/SchackartK)
* Email: schackartk1@gmail.com

