
# Leaflet: Rates by Town --------------------------------------------------

# Data from Maine Tracking Network
# Cases per 100,000 population for lyme, anaplasmosis, and babesiosis

rates_town_latlon <- town_latlon_sf %>% 
  left_join(rates, by = c("TOWN" = "Location")) %>% 
  select(-created_us, -created_da, -last_edite, -last_edi_1) %>% 
  mutate(lyme_popup = paste("<b>", TOWN, "</b>" ,
                            "<br>", "Lyme Cases per 100,000: ", lyme, 
                            "<br>", "County: ", COUNTY)) %>% 
  mutate(ana_popup = paste("<b>", TOWN, "</b>" ,
                           "<br>", "Anaplasmosis Cases per 100,000: ", anaplasmosis, 
                           "<br>", "County: ", COUNTY)) %>% 
  mutate(bab_popup = paste("<b>", TOWN, "</b>" ,
                           "<br>", "Babesiosis Cases per 100,000: ", babesiosis, 
                           "<br>", "County: ", COUNTY))

lyme_fill_palette <- colorNumeric(
  palette = "Blues",
  domain = casenum_town_latlon$lyme)

ana_fill_palette <- colorNumeric(
  palette = "Reds",
  domain = casenum_town_latlon$anaplasmosis)

bab_fill_palette <- colorNumeric(
  palette = "Greens",
  domain = casenum_town_latlon$babesiosis)

town_casenum_leaflet <- leaflet(data = casenum_town_latlon) %>% 
  addTiles(group = "OSM") %>% 
  addMapPane("cases", zIndex = 410) %>%
  addMapPane("borders", zIndex = 430) %>%
  # add borders of counties
  addPolylines(
    data = county_latlon_sf,
    group = "County Boundaries",
    color = "black",
    fillOpacity = 0,
    weight = 1,
    options = leafletOptions(pane = "borders")
  ) %>% 
  # add towns, colored by case numbers for each disease
  addPolygons(
    group = "Lyme",
    fillColor = ~lyme_fill_palette(lyme),
    color = ~lyme_fill_palette(lyme),
    weight = 1,
    fillOpacity = 0.8,
    popup = ~lyme_popup,
    options = leafletOptions(pane = "cases")
  ) %>% 
  addPolygons(
    group = "Anaplasmosis",
    fillColor = ~ana_fill_palette(anaplasmosis),
    color = ~ana_fill_palette(anaplasmosis),
    weight = 1,
    fillOpacity = 0.8,
    popup = ~ana_popup,
    options = leafletOptions(pane = "cases")
  ) %>%
  addPolygons(
    group = "Babesiosis",
    fillColor = ~bab_fill_palette(babesiosis),
    color = ~bab_fill_palette(babesiosis),
    weight = 1,
    fillOpacity = 0.8,
    popup = ~bab_popup,
    options = leafletOptions(pane = "cases")
  ) %>% 
  addLayersControl(
    overlayGroups = c("Lyme", "Anaplasmosis", "Babesiosis")
  )
