# Data from Maine Tracking Network
## Total number of lyme, anaplasmosis, and babesiosis cases per town, 2016-2020


# Cases per Town -----------------------------------------------

town_latlon_sf <- town_latlon %>% 
  st_as_sf() 

casenum_town_latlon <- town_latlon_sf %>% 
  left_join(case_numbers, by = c("TOWN" = "Location")) %>% 
  select(-created_us, -created_da, -last_edite, -last_edi_1) %>% 
  mutate(lyme_popup = paste("<b>", TOWN, "</b>" ,
                            "<br>", "Lyme Cases: ", lyme, 
                            "<br>", "County: ", COUNTY)) %>% 
  mutate(ana_popup = paste("<b>", TOWN, "</b>" ,
                           "<br>", "Anaplasmosis Cases: ", anaplasmosis, 
                           "<br>", "County: ", COUNTY)) %>% 
  mutate(bab_popup = paste("<b>", TOWN, "</b>" ,
                           "<br>", "Babesiosis Cases: ", babesiosis, 
                           "<br>", "County: ", COUNTY))

lyme_fill_palette <- colorNumeric(
  palette = "Blues",
  domain = ticknum_town_latlon$lyme)

ana_fill_palette <- colorNumeric(
  palette = "Reds",
  domain = ticknum_town_latlon$anaplasmosis)

bab_fill_palette <- colorNumeric(
  palette = "Greens",
  domain = ticknum_town_latlon$babesiosis)

town_casenum_leaflet <- leaflet(data = casenum_town_latlon) %>% 
  addTiles(group = "OSM") %>% 
  addPolygons(
    group = "Lyme",
    fillColor = ~lyme_fill_palette(lyme),
    color = ~lyme_fill_palette(lyme),
    weight = 1,
    fillOpacity = 0.8,
    popup = ~lyme_popup
  ) %>% 
  addPolygons(
    group = "Anaplasmosis",
    fillColor = ~ana_fill_palette(anaplasmosis),
    color = ~ana_fill_palette(anaplasmosis),
    weight = 1,
    fillOpacity = 0.8,
    popup = ~ana_popup
  ) %>%
  addPolygons(
    group = "Babesiosis",
    fillColor = ~bab_fill_palette(babesiosis),
    color = ~bab_fill_palette(babesiosis),
    weight = 1,
    fillOpacity = 0.8,
    popup = ~bab_popup
  ) %>% 
  addLayersControl(
    overlayGroups = c("Lyme", "Anaplasmosis", "Babesiosis")
  )


# Cases per County --------------------------------------------------------


 
