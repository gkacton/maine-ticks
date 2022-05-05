
# Loading Packages --------------------------------------------------------

library(tidyverse) ## dplyr, etc.
library(lubridate) ## helps with dates, might not be necessary
library(skimr) ## skim
library(magrittr) ## pipes
library(leaflet) ## For leaflet interactive maps
library(sf) ## For spatial data
library(RColorBrewer) ## For colour palettes
library(htmltools) ## For html
library(leafsync) ## For placing plots side by side
library(kableExtra) ## Table output
library(ggmap) ## for google geocoding

# Loading Data ------------------------------------------------------------

incidence <- read_csv("data/ticks/maine_tracking_network_incidence.csv")
rates <- read_csv("data/ticks/maine_tracking_network_rate.csv")
prevalence <- read_csv("data/ticks/umaine_tickborne_prevalence_town.csv")

