# INDICATORS

# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse) ## dplyr, etc.
library(dplyr)
library(magrittr) ## pipes
library(leaflet) ## For leaflet interactive maps
library(sf) ## For spatial data
library(RColorBrewer) ## For colour palettes
library(htmltools) ## For html
library(leafsync) ## For placing plots side by side
library(kableExtra) ## Table output
library(maptools) ## for reading KML files


# Load Data ---------------------------------------------------------------

rates <- read_csv("clean_data/rates.csv")
fed_health <- read_csv("clean_data/fed_health.csv")
elderly_pop <- read_sf("clean_data/elderly_pct.shp")
income <- read_sf("clean_data/income.shp")
town_latlon_sf <- read_sf("clean_data/town_latlon.shp")
county_latlon_sf <- read_sf("clean_data/county_latlon.shp") 
conserved_lands_sf <- read_sf("clean_data/Maine_Conserved_Lands.kml")

# Rates by Town --------------------------------------------------
# Data from Maine Tracking Network
## Cases per 100,000 population for lyme, anaplasmosis, and babesiosis

rates <- rates %>% 
    mutate(color_values = case_when(lyme != 0 ~ log(lyme, base = 1.1),
                                    lyme == 0 ~ 0) ) %>% 
    arrange(desc(lyme))

rates_town_latlon <- town_latlon_sf %>% 
    left_join(rates, by = c("TOWN" = "Location")) %>% 
    filter(is.na(lyme) == FALSE) %>% 
    select(-created_us, -created_da, -last_edite, -last_edi_1) 

rates_town_latlon <- rates_town_latlon %>% 
    mutate(lyme_popup = paste("<b>", TOWN, "</b>" ,
                              "<br>", "Lyme Cases per 100,000: ", lyme, 
                              "<br>", "County: ", COUNTY.x)) 


# Create color palette for each disease - rates ---------------------------

## log scaled colors
lyme_rates_fill_palette <- colorNumeric(
    palette = "Blues", 
    domain = rates$color_values)


# Color palette for income ------------------------------------------------

income_palette <- colorNumeric(
  palette = "YlGn",
  domain = income$med_ncm
)


# color palette for age ---------------------------------------------------

age_palette <- colorNumeric(
  palette = "YlGn",
  domain = elderly_pop$pct_ldr
)


# define hospital marker --------------------------------------------------

hospitalMarker <- makeIcon(
  iconUrl = "http://cdn.onlinewebfonts.com/svg/img_493605.png",
  iconWidth = 20
)
# Create leaflet ----------------------------------------------------------

town_leaflet <- leaflet() %>% 
    # base map = Open Street Map
    addTiles(group = "OpenStreetMap") %>% 
    # Separate pane for each set of polygons/polylines
    addMapPane("indicators", zIndex = 440) %>%
    addMapPane("borders", zIndex = 450) %>% # borders always on top
    addMapPane("rates", zIndex = 430) %>% 
    addMapPane("conservation", zIndex = 410) %>% 
    # add polygons for conserved lands
    addPolygons(
        data = conserved_lands_sf$geometry,
        group = "Conservation Lands",
        fillColor = "green",
        color = "green",
        fillOpacity = 0.8,
        weight = 1,
        options = leafletOptions(pane = "conservation")
    ) %>% 
    # add borders of counties
    addPolylines(
        data = county_latlon_sf$geometry,
        group = "County Boundaries",
        color = "black",
        fillOpacity = 0,
        weight = 1,
        options = leafletOptions(pane = "borders")
    ) %>% 
    # add counties, colored by median income 
    addPolygons(
      data = income,
      group = "Median Income",
      fillColor = ~income_palette(med_ncm),
      color = ~income_palette(med_ncm),
      fillOpacity = 0.8,
      weight = 1,
      options = leafletOptions(pane = "indicators"),
      popup = ~incm_pp
    ) %>% 
    # add counties, colored by percent 65+ 
    addPolygons(
      data = elderly_pop,
      group = "Percent 65+",
      fillColor = ~age_palette(pct_ldr),
      color = ~age_palette(pct_ldr),
      fillOpacity = 0.7,
      weight = 1,
      options = leafletOptions(pane = "indicators"),
      popup = ~popup
    ) %>% 
    # add towns, colored by rates per 100,000 for each disease
    addPolygons(
        data = rates_town_latlon,
        group = "Lyme Rates",
        fillColor = ~lyme_rates_fill_palette(color_values),
        color = "lightskyblue",
        weight = 1,
        fillOpacity = 0.5,
        popup = ~lyme_popup,
        options = leafletOptions(pane = "rates")
    )  %>% 
    # add markers for federal healthcare centers
    addMarkers(
      data = fed_health,
      lat = ~lat,
      lng = ~lon,
      icon = hospitalMarker,
      popup = ~popup,
      group = "Federally Recognized Healthcare Centers" 
    ) %>% 
    addLayersControl(
      overlayGroups = c("Median Income",
                        "Percent 65+",
                        "Federally Recognized Healthcare Centers")
    )


# define UI ---------------------------------------------------------------

ui <- fluidPage(
    titlePanel("Lyme Rates per 100,000 Population"
               ),
    sidebarLayout(
        sidebarPanel(
            h3("Maine Tracking Network Incidence Rate Data, 2016-2020."),
            selectInput("town", label = h3("Select a Town"), 
                        choices = rates$Location, 
                        selected = "Portland")
        ),
        mainPanel(
            tabsetPanel(
                tabPanel("Map", 
                         leafletOutput("mymap")),
                tabPanel("Cases",
                         h3("Towns in the same county with the highest lyme rates."),
                         tableOutput("table")),
                tabPanel("Health Centers",
                         h3("Federally-Recognized Healthcare Centers in this town."),
                         tableOutput("health"))
            )
            
        )
    )
)   


# define server -----------------------------------------------------------

server <- function(input, output, session) {
    
    output$mymap <- renderLeaflet({
        town_leaflet %>% 
            addMapPane("highlight", zIndex = 500) %>% 
            addPolylines(
                options = leafletOptions(pane = "highlight"),
                data = rates_town_latlon %>% filter(TOWN == input$town),
                color = "yellow",
                weight = 2,
                opacity = 1
            )
    })
    output$town <- renderPrint({ input$town })
    
    library(kableExtra)
   
    output$table <- renderTable(
      rates %>% 
        filter(COUNTY == rates$COUNTY[which(rates$Location == input$town)]) %>% 
        mutate(Town = Location) %>% 
        mutate(County = COUNTY) %>% 
        select(Town, lyme, anaplasmosis, babesiosis, County) %>% 
        arrange(desc(lyme)) 
      )
    
    # NEEDS FIXING! 
    output$health <- renderTable(
      fed_health %>% 
        mutate(County = `County Equivalent Name`) %>% 
        filter(`Site City` == input$town) %>% 
        select(`Site Name`,
               `Site Address`,
               `Site City`,
                County,
               `Site Telephone Number`,
               `Site Web Address`,
        ) %>% 
        arrange(`Site Name`)
    )
    }

shinyApp(ui, server)