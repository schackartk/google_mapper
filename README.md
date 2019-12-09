# my_google_maps
A script to visualize my Google Maps ratings.

# Preparatory Steps

## Download Your Data
Download your archive from [Google Takeout](https://takeout.google.com/).

More information on how to do this can be found [here](https://support.google.com/accounts/answer/3024190?hl=en).

For this script, you will need to select "Maps (your places)". You can download others, but this is the one that will be used.

## Edit file structure
In the same folder where you will clone this repository, extract your Google Archive.

When extracting from a .zip file, depending on your operating system, you may have an overly nested file system. 

Ensure that in your folder (where you will clone this repositry) you have a folder called `Takeout`. And within that folder there is a file called `Reviews.Json`.

## Get your Google Maps API Key

If you don't already have one create a [Google Cloud Platform](https://cloud.google.com/maps-platform/pricing/) account. The pricing is a little bit confusing, but if you sign up for a free account, you will have quite a few free maps requests per day, and should be enough for personal project use.

[Get your API Key](https://developers.google.com/maps/documentation/embed/get-api-key). For the code in this repo to work without modification regarding the key, you will want to paste the key into a file called `google_key.txt` file, and save the file in the same directory as the R script. Alternatively, you can paste the key directly into your code, i.e. `register_google(key = "my_google_key_I_got_from_google_cloud)`, but this is not advised because then someone else can use your key if you post your code anywhere.
