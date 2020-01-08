# my_google_maps
A script to visualize Google Maps Takeout data. Written in R. Currently supports plotting place ratings/reviews, labeled places, and location history (as a heatmap).

# Preparatory Steps

## Clone this Repository

You can refer to [these instructions](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) for help with cloning from GitHub.

## Download Your Data
Download your archive from [Google Takeout](https://takeout.google.com/).

More information on how to do this can be found [here](https://support.google.com/accounts/answer/3024190?hl=en).

For this script, you will need to select "Location History", "Maps", and "Maps (your places)". You can download others, but these are the ones that will be used.

## Edit file structure
In the same folder where you cloned this repository, extract your Google Archive.

Ensure that in your folder (where you will clone this repositry) you have a folder called `Takeout`. And within that folder there are files called `Reviews.Json`, `LabeledPlaces.Json`, and `LocationHistory.Json`.


## Install the Necessary Libraries

As it is rather uncouth to place install commands within a script, the main script only loads the necessary packages, so you have to install them first. To make this easier, just open and run the script `requirements.R`, or if you are familiar with R, install the necessary packages yourself.

# Expected Behavior

Run the script `google_mapper.R`. This may take a while, especially if the "Location History" file is large.

Upon running the script, a new file called `map.html` will be saved in the same directory as the script.

This file can be opened with any browser.

