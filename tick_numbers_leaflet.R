# Leaflets


# Leaflet of Incidence Data -----------------------------------------------

town_latlon_sf <- town_latlon %>% 
  st_as_sf()

town_leaflet <- leaflet(data = town_latlon) %>% 
  addTiles(group = "OSM") %>% 
  addPolygons(
    fill = "blue",
    color = "black",
    weight = 2
  )

