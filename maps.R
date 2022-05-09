# Basic Maps

source("data_cleaning.R")

# Base County Map ---------------------------------------------------------

## Creates a GGPlot map of the counties

county_boundaries <- fortify(county_boundaries)

county_outlines_map <- ggplot(data = county_boundaries) + 
  geom_sf(mapping = aes(geometry = geometry))


# Base Town/Township Map --------------------------------------------------

## Creates a GGPlot map of the town and township outlines

town_boundaries <- fortify(town_boundaries)

town_outlines_map <- ggplot(data = town_boundaries) + 
  geom_sf(mapping = aes(geometry = geometry))


# Basic Leaflet -----------------------------------------------------------

county_leaflet <- leaflet(data = county_boundaries) %>% 
  addTiles(group = "OSM") %>% 
  addPolygons()


