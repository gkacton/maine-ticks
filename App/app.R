library(shiny)
library(leaflet)
source("leaflet_cases_rates.R")

# Define UI ---------------------------------------------------------------

ui <- fluidPage(
      leafletOutput("town")
  )



# Define Server Logic -----------------------------------------------------

server <- function(input, output, session) {
  
  output$town <- renderLeaflet({
    leaflet() %>% 
      # base map = Open Street Map
      addTiles(group = "OSM") %>% 
      # Separate pane for each set of polygons/polylines
      addMapPane("cases", zIndex = 420) %>%
      addMapPane("borders", zIndex = 440) %>% # borders always on top
      addMapPane("rates", zIndex = 430) %>% 
      addMapPane("conservation", zIndex = 410) %>% 
      # add polygons for conserved lands
      # addPolygons(
      #   data = conserved_lands_sf,
      #   group = "Conservation Lands",
      #   fillColor = "green",
      #   color = "green",
      #   fillOpacity = 0.8,
      #   weight = 1,
      #   options = leafletOptions(pane = "conservation")
      # ) %>% 
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
        data = casenum_town_latlon,
        group = "Total Lyme Cases",
        fillColor = ~lyme_cases_fill_palette(lyme),
        color = ~lyme_cases_fill_palette(lyme),
        weight = 1,
        fillOpacity = 0.5,
        popup = ~lyme_popup,
        options = leafletOptions(pane = "cases")
      ) %>% 
      addPolygons(
        data = casenum_town_latlon,
        group = "Total Anaplasmosis Cases",
        fillColor = ~ana_cases_fill_palette(anaplasmosis),
        color = ~ana_cases_fill_palette(anaplasmosis),
        weight = 1,
        fillOpacity = 0.5,
        popup = ~ana_popup,
        options = leafletOptions(pane = "cases")
      ) %>%
      addPolygons(
        data = casenum_town_latlon,
        group = "Total Babesiosis Cases",
        fillColor = ~bab_cases_fill_palette(babesiosis),
        color = ~bab_cases_fill_palette(babesiosis),
        weight = 1,
        fillOpacity = 0.5,
        popup = ~bab_popup,
        options = leafletOptions(pane = "cases")
      ) %>% 
      # add towns, colored by rates per 100,000 for each disease
      addPolygons(
        data = rates_town_latlon,
        group = "Lyme Rates",
        fillColor = ~lyme_rates_fill_palette(lyme),
        color = ~lyme_rates_fill_palette(lyme),
        weight = 1,
        fillOpacity = 0.5,
        popup = ~lyme_popup,
        options = leafletOptions(pane = "rates")
      ) %>% 
      addPolygons(
        data = rates_town_latlon,
        group = "Anaplasmosis Rates",
        fillColor = ~ana_rates_fill_palette(anaplasmosis),
        color = ~ana_rates_fill_palette(anaplasmosis),
        weight = 1,
        fillOpacity = 0.5,
        popup = ~ana_popup,
        options = leafletOptions(pane = "rates")
      ) %>%  
      addPolygons(
        data = rates_town_latlon,
        group = "Babesiosis Rates",
        fillColor = ~bab_rates_fill_palette(babesiosis),
        color = ~bab_rates_fill_palette(babesiosis),
        weight = 1,
        fillOpacity = 0.5,
        popup = ~bab_popup,
        options = leafletOptions(pane = "rates")
      ) %>%  
      addLayersControl(
        baseGroups = c("Conservation Lands"),
        overlayGroups = c("Total Lyme Cases", 
                          "Total Anaplasmosis Cases", 
                          "Total Babesiosis Cases",
                          "Lyme Rates",
                          "Anaplasmosis Rates",
                          "Babesiosis Rates")
      )
  })
}


# Run the app -------------------------------------------------------------

shinyApp(ui = ui, server = server)