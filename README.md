# my_google_maps
A script to visualize my Google Maps Takeout data. Written in R.

# Preparatory Steps

## Clone this Repository

You can refer to [these instructions](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) for help with cloning from GitHub.

## Download Your Data
Download your archive from [Google Takeout](https://takeout.google.com/).

More information on how to do this can be found [here](https://support.google.com/accounts/answer/3024190?hl=en).

For this script, you will need to select "Maps (your places)". You can download others, but this is the one that will be used.

## Edit file structure
In the same folder where you will clone this repository, extract your Google Archive.

When extracting from a .zip file, depending on your operating system, you may have an overly nested file system. 

Ensure that in your folder (where you will clone this repositry) you have a folder called `Takeout`. And within that folder there is a file called `Reviews.Json`.


## Install the Necessary Libraries

As it is rather uncouth to place install commands within a script, the main script only loads the necessary packages, so you have to install them first. To make this easier, just open and run the script `requirements.R`, or if you are familiar with R, install the necessary packages yourself.

# Expected Results

Upon running the code, a new file called `ratings_widget.html` will be saved in the same directory as the script.

This file can be opened with any browser.

