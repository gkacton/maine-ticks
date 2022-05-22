# RATES LEAFLET

# Loading Packages --------------------------------------------------------

library(tidyverse) ## dplyr, etc.
library(dplyr)
library(lubridate) ## helps with dates, might not be necessary
library(skimr) ## skim
library(magrittr) ## pipes
library(leaflet) ## For leaflet interactive maps
library(sf) ## For spatial data
library(RColorBrewer) ## For colour palettes
library(htmltools) ## For html
library(leafsync) ## For placing plots side by side
library(kableExtra) ## Table output
library(ggmap) ## for google geocoding and fortifying 
library(maptools) ## for reading KML files
library(rgdal)
library(rmapshaper)

# Loading Preliminary Data ------------------------------------------------------------

rates <- read_csv("data/ticks/maine_tracking_network_rate.csv")

# Loading Spatial Data - leaflet ------------------------------------------

county_latlon <- readOGR("data/spatial_data/Maine_County_Boundaries/Maine_County_Boundary_Polygons_Feature.shp")
county_latlon <-spTransform(county_latlon, CRS("+proj=longlat +datum=WGS84 +no_defs")) 
  # changes shapefile to be compatible with WGS84, so it will now work with leaflet
county_latlon_sf <- county_latlon %>% 
  st_as_sf() %>% 
  rmapshaper::ms_simplify(explode = TRUE, weighting = 0.3)

town_latlon <- readOGR("data/spatial_data/towns/towns.shp")
town_latlon <-spTransform(town_latlon, CRS("+proj=longlat +datum=WGS84 +no_defs")) 
town_latlon_sf <- town_latlon %>% 
  st_as_sf() %>% 
  rmapshaper::ms_simplify(explode = TRUE, weighting = 0.5)

conserved_lands_sf <- read_sf("data/spatial_data/Maine_Conserved_Lands.kml")


# Loading Provider Data ---------------------------------------------------

# fed_healthcenters <- read_csv("data/primary_care/federally_recognized_health_centers.csv")

# Cleaning "rates" dataframe ----------------------------------------------

# reformat rate
rates[rates == "*"] = NA
rates[rates == "NR"] = NA

rates <- rates %>% 
  mutate(lyme = as.numeric(Lyme),
       babesiosis = as.numeric(Babesiosis),
       anaplasmosis = as.numeric(Anaplasmosis)) %>% 
  select(Location, lyme, babesiosis, anaplasmosis, Population) 
