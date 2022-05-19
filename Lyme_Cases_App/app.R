# LYME CASES APP

# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
source("data_cleaning.R")

# Cases per Town -----------------------------------------------
# Data from Maine Tracking Network
## Total number of lyme, anaplasmosis, and babesiosis cases per town, 2016-2020

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


# Create color palette for each disease - cases -----------------------------------

lyme_cases_fill_palette <- colorNumeric(
  palette = "Blues",
  domain = casenum_town_latlon$lyme)

ana_cases_fill_palette <- colorNumeric(
  palette = "Reds",
  domain = casenum_town_latlon$anaplasmosis)

bab_cases_fill_palette <- colorNumeric(
  palette = "Purples",
  domain = casenum_town_latlon$babesiosis)


# Create leaflet ----------------------------------------------------------

town_leaflet <- leaflet() %>% 
  # base map = Open Street Map
   addTiles(group = "OpenStreetMap") %>% 
  # Separate pane for each set of polygons/polylines
   addMapPane("cases", zIndex = 420) %>%
   addMapPane("borders", zIndex = 440) %>% # borders always on top
  # addMapPane("rates", zIndex = 430) %>% 
   addMapPane("conservation", zIndex = 410) %>% 
  # add polygons for conserved lands
   addPolygons(
     data = conserved_lands_sf,
     group = "Conservation Lands",
     fillColor = "green",
     color = "green",
     fillOpacity = 0.8,
     weight = 1,
     options = leafletOptions(pane = "conservation")
   ) %>% 
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
   addLayersControl(
     overlayGroups = c("Total Lyme Cases", 
                       "Total Anaplasmosis Cases", 
                       "Total Babesiosis Cases")
   )


# define UI ---------------------------------------------------------------


ui <- fluidPage(
  titlePanel("Tickborne Illnesses in Maine - Total Cases"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("town", label = h3("Select a Town"), 
                  choices = case_numbers$Location, 
                  selected = "Abbot"),
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Map", 
                 leafletOutput("mymap")),
        tabPanel("Table",
                 tableOutput("table")
                 )
      )

    )
  )

)

server <- function(input, output, session) {
  
  output$mymap <- renderLeaflet({
     town_leaflet %>% 
       addMapPane("highlight", zIndex = 500) %>% 
       addPolylines(
         options = leafletOptions(pane = "highlight"),
         data = casenum_town_latlon %>% filter(TOWN == input$town),
         color = "yellow",
         weight = 2,
         opacity = 1
      )
  })
  output$town <- renderPrint({ input$town })
  output$table <- function(){ 
    kbl(case_numbers) %>% 
      kable_material(c("striped", "hover")) %>% 
      kable_styling(fixed_thead = T, 
                    bootstrap_options = "striped", 
                    font_size = 10) %>% 
      row_spec(which(case_numbers$Location == input$town), color = "white", background = "blue")
    }
}

shinyApp(ui, server)