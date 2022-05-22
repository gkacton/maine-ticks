# RATES LEAFLET

# Loading Packages --------------------------------------------------------

library(tidyverse) ## dplyr, etc.
library(dplyr)
library(skimr) ## skim
library(magrittr) ## pipes
library(leaflet) ## For leaflet interactive maps
library(sf) ## For spatial data
library(RColorBrewer) ## For colour palettes
library(htmltools) ## For html
library(leafsync) ## For placing plots side by side
library(kableExtra) ## Table output
library(maptools) ## for reading KML files
library(rmapshaper)

# Loading Preliminary Data ------------------------------------------------------------

rates <- read_csv("data/ticks/maine_tracking_network_rate.csv")

# Loading Spatial Data - leaflet ------------------------------------------

county_latlon <- read_sf("data/spatial_data/Maine_County_Boundaries/Maine_County_Boundary_Polygons_Feature.shp")
county_latlon_sf <- county_latlon %>% 
  st_transform(crs = "WGS84") %>% 
  rmapshaper::ms_simplify(explode = TRUE, weighting = 0.3)

town_latlon <- read_sf("data/spatial_data/towns/towns.shp")
town_latlon_sf <- town_latlon %>% 
  st_transform(crs = "WGS84") %>% 
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


# Recoding town names -----------------------------------------------------

town_latlon_sf <- town_latlon_sf %>% 
  mutate(TOWN = str_replace(TOWN, "Plt", "Plantation")) %>% 
  mutate(TOWN = str_replace(TOWN, "Saint", "St.")) %>% 
  mutate(TOWN = str_replace(TOWN, "Monhegan Island Plantation", "Monhegan Plantation")) %>% 
  mutate(TOWN = str_replace(TOWN, "Saint George", "St. George")) %>% 
  mutate(TOWN = str_replace(TOWN, "Matinicus Isle Plt", "Matinicus Isle Plantation")) %>% 
  mutate(TOWN = str_replace(TOWN, "Muscle Ridge Twp", "Muscle Ridge Islands Twp")) %>% 
  mutate(TOWN = str_replace(TOWN, "Andover North Surplus Twp", "Andover")) %>% 
  mutate(TOWN = str_replace(TOWN, "Andover West Surplus Twp", "Andover")) %>% 
  mutate(TOWN = str_replace(TOWN, "Magalloway Twp", "Magalloway Plantation")) %>% 
  mutate(TOWN = str_replace(TOWN, "Lincoln County Island", "Bristol")) %>% 
  mutate(TOWN = str_replace(TOWN, "Knox County Island", "Vinalhaven")) %>% 
  mutate(TOWN = str_replace(TOWN, "Hancock County Island", "Deer Isle")) %>% 
  mutate(TOWN = str_replace(TOWN, "T9 SD BPP", "Franklin")) %>% 
  mutate(TOWN = str_replace(TOWN, "T7 SD BPP", "Sullivan")) %>% 
  mutate(TOWN = str_replace(TOWN, "T10 SD BPP", "Franklin")) %>% 
  mutate(TOWN = str_replace(TOWN, "T16 MD BPP", "Eastbrook")) %>% 
  mutate(TOWN = str_replace(TOWN, "T22 MD BPP", "Osborn"))
