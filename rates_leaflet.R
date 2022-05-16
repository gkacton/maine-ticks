conserved_lands_latlon <- getKMLcoordinates("data/spatial_data/Maine_Conserved_Lands.kml", ignoreAltitude = TRUE)


leaflet() %>% 
  addTiles(group = "OSM") %>% 
  addPolygons(
    data = conserved_lands_sf,
    group = "Conservation Lands",
    fillColor = "green",
    color = "green",
    fillOpacity = 0.8,
    weight = 1,
    options = leafletOptions(pane = "conservation")
  )

