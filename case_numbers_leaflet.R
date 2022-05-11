# Data from Maine Tracking Network
## Total number of lyme, anaplasmosis, and babesiosis cases per town, 2016-2020


# Cases per Town -----------------------------------------------

town_latlon_sf <- town_latlon %>% 
  st_as_sf() 

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
  mutate(TOWN = str_replace(TOWN, "Knox County Island", "Isleboro")) %>% 
  mutate(TOWN = str_replace(TOWN, "Hancock County Island", "Deer Isle")) %>% 
  mutate(TOWN = str_replace(TOWN, "T9 SD BPP", "Franklin")) %>% 
  mutate(TOWN = str_replace(TOWN, "T7 SD BPP", "Sullivan")) %>% 
  mutate(TOWN = str_replace(TOWN, "T10 SD BPP", "Franklin")) %>% 
  mutate(TOWN = str_replace(TOWN, "T16 MD BPP", "Eastbrook")) %>% 
  mutate(TOWN = str_replace(TOWN, "T22 MD BPP", "Osborn"))

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
  addPolylines(
    data = county_latlon_sf,
    group = "County Boundaries",
    color = "black",
    fillOpacity = 0,
    weight = 1,
    options = leafletOptions(pane = "borders")
  ) %>% 
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




 
