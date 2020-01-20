# google_mapper
A script to visualize Google Maps Takeout data. Written in R. Currently supports plotting place ratings/reviews, labeled places, and location history (as a heatmap).

I have supplied both a command-line executable version (`executable_google_mapper.R`) and a runnable script (`explicit_google_mapper.R`).

# Preparatory Steps

## Clone this Repository

You can refer to [these instructions](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) for help with cloning from GitHub.

## Download Your Data
Download your archive from [Google Takeout](https://takeout.google.com/).

More information on how to do this can be found [here](https://support.google.com/accounts/answer/3024190?hl=en).

For this script, you will need to select "Location History", "Maps", and "Maps (your places)". You can download others, but these are the ones that will be used.

Unzip the data. If you would like the default paths to work, the folder containing this repository should have a folder called "Takeout" and within that folder, 3 files: "Reviews.json", "LocationHistory.json", and "LabeledPlaces.json".

## Install the Necessary Libraries

As it is rather uncouth to place install commands within a script, the main script only loads the necessary packages, so you have to install them first. To make this easier, you may open and run the script `requirements.R`, or run `exec_requirements.R` from the command line.

# Expected Behavior

Both `executable_google_mapper.R` and `explicit_google_mapper.R` call `google_mapper.R`.

`executable_google_mapper.R` is run from the command line. `explicit_google_mapper.R` is run from, for instance, RStudio.

The end product is an HTML widget that can be opened in most web browsers.

## Hard-coded Script Version
Edit the `explicit_google_mapper.R` script to make the paths to the respective files match your file structure.

Run as you would any R code. 

## Command Line Executable Version

Usage Statement and Help:
```
./executable_google_mapper.R -h

usage: executable_google_mapper.R [--] [--help] [--ratings RATINGS]
       [--locations LOCATIONS] [--labels LABELS] [--outfile OUTFILE]

google_mapper

flags:
  -h, --help       show this help message and exit

optional arguments:
  -r, --ratings    Ratings/reviews json file [default:
                   Takeout/Reviews.json]
  -l, --locations  Location history json file [default:
                   Takeout/LocationHistory.json]
  -b, --labels     Labeled places json file [default:
                   Takeout/LabeledPlaces.json]
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

Error Message when Some Files Not Present:
```
./executable_google_mapper.R -l "foo"

Processing ratings file... Done processing ratings file.
No location history file found: 'foo'. Skipping.
Processing labeled places file... Done processing labeled places file.
Saving map output.
Done, see file: 'map.html'!
```

Error Message when No Files Present:
```
./executable_google_mapper.R -r "foo" -l "bar" -b "baz"

No ratings file found: 'foo'. Skipping.
No location history file found: 'bar'. Skipping.
No labeled places file found: 'baz'. Skipping.
Unable to find any usable files, no output can be generated.
Please ensure that the provided file paths are correct.
```

Incorrect File Format:
```
./executable_google_mapper.R -l "Takeout/EmptyFile.txt"

Processing ratings file... Done processing ratings file.
Processing location history file... 
Unable to interpret file: Takeout/EmptyFile.json as '.json'... Skipping.
Processing labeled places file... Done processing labeled places file.
Saving map output.
Done, see file: 'map.html'!
```

File Contents Do Not Match Context:
```
./executable_google_mapper.R -l "Takeout/Reviews.json"

Processing ratings file... Done processing ratings file.
Processing location history file... 
Unable to interpret file Takeout/Reviews.json in context as location history file.
Please ensure that you meant this file to be interpreted as location history.
Skipping.
Done processing location history file.
Processing labeled places file... Done processing labeled places file.
Saving map output.
Done, see file: 'map.html'!
```

# Authorship

Kenneth Schackart

* Twitter: [\@SchackartK](https://twitter.com/SchackartK)
* Email: schackartk1@gmail.com

