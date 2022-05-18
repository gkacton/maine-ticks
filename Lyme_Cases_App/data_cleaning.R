
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

# Loading Preliminary Data ------------------------------------------------------------

incidence <- read_csv("data/ticks/maine_tracking_network_incidence.csv")
rates <- read_csv("data/ticks/maine_tracking_network_rate.csv")
prevalence <- read_csv("data/ticks/umaine_tickborne_prevalence_town.csv")

# Loading Spatial Data - leaflet ------------------------------------------

county_latlon <- readOGR("data/spatial_data/counties/Maine_County_Boundary_Polygons_Feature.shp")
county_latlon <-spTransform(county_latlon, CRS("+proj=longlat +datum=WGS84 +no_defs")) 
  # changes shapefile to be compatible with WGS84, so it will now work with leaflet
county_latlon_sf <- county_latlon %>% 
  st_as_sf()

town_latlon <- readOGR("data/spatial_data/towns/towns.shp")
town_latlon <-spTransform(town_latlon, CRS("+proj=longlat +datum=WGS84 +no_defs")) 
town_latlon_sf <- town_latlon %>% 
  st_as_sf() 

conserved_lands_sf <- read_sf("data/spatial_data/Maine_Conserved_Lands.kml")


# Loading Provider Data ---------------------------------------------------

# fed_healthcenters <- read_csv("data/primary_care/federally_recognized_health_centers.csv")


# Cleaning Incidence Data -------------------------------------------------
  ## From Matt's data cleaning script 

case_numbers <- incidence %>% 
  mutate(Lyme_Label = Lyme) %>%
  mutate(Lyme_Label = str_replace(Lyme_Label, "NR", "Not Releasable")) %>%
  mutate(Lyme = str_replace(Lyme, "<6", "6")) %>%
  mutate(Lyme = str_replace(Lyme, "6-10", "8")) %>%
  mutate(Lyme = str_replace(Lyme, "11-15", "13")) %>%
  mutate(Babesiosis_Label = Babesiosis) %>%
  mutate(Babesiosis_Label = str_replace(Babesiosis_Label, "NR", "Not Releasable")) %>%
  mutate(Babesiosis = str_replace(Babesiosis, "<6", "6")) %>%
  mutate(Babesiosis = str_replace(Babesiosis, "6-10", "8")) %>%
  mutate(Babesiosis = str_replace(Babesiosis, "11-15", "13")) %>%
  mutate(Anaplasmosis_Label = Anaplasmosis) %>%
  mutate(Anaplasmosis_Label = str_replace(Anaplasmosis_Label, "NR", "Not Releasable")) %>%
  mutate(Anaplasmosis = str_replace(Anaplasmosis, "<6", "6")) %>%
  mutate(Anaplasmosis = str_replace(Anaplasmosis, "6-10", "8")) %>%
  mutate(Anaplasmosis = str_replace(Anaplasmosis, "11-15", "13")) %>% 
  mutate(lyme = as.numeric(Lyme),
         babesiosis = as.numeric(Babesiosis),
         anaplasmosis = as.numeric(Anaplasmosis)) %>% 
  select(Location, lyme, babesiosis, anaplasmosis, Population) %>% 
  arrange(desc(lyme))

# reformatting location variable in case_numbers
  ## From Matt's script
case_numbers <- case_numbers %>%
  mutate(Location = str_replace(Location, "Plt", "Plantation")) %>%
  mutate(Location = str_replace(Location, "Bancroft Twp", "Bancroft")) %>%
  mutate(Location = str_replace(Location, "Aroostook", "Aroostook Twp")) %>%
  mutate(Location = str_replace(Location, "Somerset", "Somerset Twp")) %>%
  mutate(Location = str_replace(Location, "East Hancock", "East Hancock Twp")) %>%
  mutate(Location = str_replace(Location, "Dennistown", "Dennis")) %>%
  mutate(Location = str_replace(Location, "East Central Washington", "East Central Washington Twp")) %>%
  mutate(Location = str_replace(Location, "East Central Franklin", "East Central Franklin Twp")) %>%
  mutate(Location = str_replace(Location, "West Central Franklin", "West Central Franklin Twp")) %>%
  mutate(Location = str_replace(Location, "North Franklin", "North Franklin Twp")) %>%
  mutate(Location = str_replace(Location, "South Franklin", "South Franklin Twp")) %>%
  mutate(Location = str_replace(Location, "West Franklin", "West Franklin Twp")) %>%
  mutate(Location = str_replace(Location, "East Central Penobscot", "East Central Penobscot Twp")) %>%
  mutate(Location = str_replace(Location, "Louds Island", "Louds Island Twp")) %>%
  mutate(Location = str_replace(Location, "Marshall Island", "Marshall Island Twp")) %>%
  mutate(Location = str_replace(Location, "Monhegan Island Plantation", "Monhegan Plantation")) %>%
  mutate(Location = str_replace(Location, "Islands", "Islands Twp")) %>%
  mutate(Location = str_replace(Location, "North Oxford", "North Oxford Twp")) %>%
  mutate(Location = str_replace(Location, "South Oxford", "South Oxford Twp")) %>%
  mutate(Location = str_replace(Location, "North Washington", "North Washington Twp")) %>%
  mutate(Location = str_replace(Location, "North Penobscot", "North Penobscot Twp")) %>%
  mutate(Location = str_replace(Location, "Piscataquis", "Piscataquis Twp")) %>%
  mutate(Location = str_replace(Location, "Prentiss Twp T7 R3 NBPP", "Prentiss Twp")) %>%
  mutate(Location = str_replace(Location, "Seboomook Lake", "Seboomook Lake Twp")) %>%
  mutate(Location = str_replace(Location, "Square Lake", "Square Lake Twp")) %>%
  mutate(Location = str_replace(Location, "Saint", "St."))

# fixing TOWN names in town_latlon_sf

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
  mutate(TOWN = str_replace(TOWN, "Knox County Island", "Islesboro")) %>% 
  mutate(TOWN = str_replace(TOWN, "Hancock County Island", "Deer Isle")) %>% 
  mutate(TOWN = str_replace(TOWN, "T9 SD BPP", "Franklin")) %>% 
  mutate(TOWN = str_replace(TOWN, "T7 SD BPP", "Sullivan")) %>% 
  mutate(TOWN = str_replace(TOWN, "T10 SD BPP", "Franklin")) %>% 
  mutate(TOWN = str_replace(TOWN, "T16 MD BPP", "Eastbrook")) %>% 
  mutate(TOWN = str_replace(TOWN, "T22 MD BPP", "Osborn"))

# Cleaning "rates" dataframe ----------------------------------------------

# reformat rate
rates[rates == "*"] = NA
rates[rates == "NR"] = NA

rates <- rates %>% 
  mutate(lyme = as.numeric(Lyme),
       babesiosis = as.numeric(Babesiosis),
       anaplasmosis = as.numeric(Anaplasmosis)) %>% 
  select(Location, lyme, babesiosis, anaplasmosis, Population) 
