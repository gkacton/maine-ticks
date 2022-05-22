# INDICATORS

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

# Rates by Town --------------------------------------------------
# Data from Maine Tracking Network
## Cases per 100,000 population for lyme, anaplasmosis, and babesiosis

rates <- rates %>% 
    mutate(color_values = case_when(lyme != 0 ~ log(lyme, base = 1.2),
                                    lyme == 0 ~ 0) )

rates_town_latlon <- town_latlon_sf %>% 
    left_join(rates, by = c("TOWN" = "Location")) %>% 
    select(-created_us, -created_da, -last_edite, -last_edi_1) %>% 
    mutate(lyme_popup = paste("<b>", TOWN, "</b>" ,
                              "<br>", "Lyme Cases per 100,000: ", lyme, 
                              "<br>", "County: ", COUNTY)) 


# Create color palette for each disease - rates ---------------------------

## log scale colors???
lyme_rates_fill_palette <- colorNumeric(
    palette = "Blues", 
    domain = rates$color_values)

# Create leaflet ----------------------------------------------------------

town_leaflet <- leaflet() %>% 
    # base map = Open Street Map
    addTiles(group = "OpenStreetMap") %>% 
    # Separate pane for each set of polygons/polylines
    # addMapPane("cases", zIndex = 420) %>%
    addMapPane("borders", zIndex = 440) %>% # borders always on top
    addMapPane("rates", zIndex = 430) %>% 
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
    # add towns, colored by rates per 100,000 for each disease
    addPolygons(
        data = rates_town_latlon,
        group = "Lyme Rates",
        fillColor = ~lyme_rates_fill_palette(color_values),
        color = ~lyme_rates_fill_palette(color_values),
        weight = 1,
        fillOpacity = 0.5,
        popup = ~lyme_popup,
        options = leafletOptions(pane = "rates")
    ) 


# define UI ---------------------------------------------------------------

ui <- fluidPage(
    titlePanel("Lyme Rates per 100,000 Population"),
    
    sidebarLayout(
        sidebarPanel(
            selectInput("town", label = h3("Select a Town"), 
                        choices = case_numbers$Location, 
                        selected = "Portland"),
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
    output$table <- function(){ 
        kbl(rates) %>% 
            kable_material(c("striped", "hover")) %>% 
            kable_styling(fixed_thead = T, 
                          bootstrap_options = "striped", 
                          font_size = 10) %>% 
            row_spec(which(rates$Location == input$town), color = "white", background = "blue")
    }
}

shinyApp(ui, server)