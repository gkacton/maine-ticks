# PREP CENSUS DATA

age_insured <- read_csv("data/census/county_age_insured.csv")
income <- read_csv("data/census/county_income.csv")
county_pop <- read_csv("data/census/county_pop.csv")

# Fix income set ----------------------------------------------------------

income <- income %>% 
  as.data.frame() %>%
  filter(`Label (Grouping)` == "Median income (dollars)") %>% 
  select(`Label (Grouping)`, contains("Households"), -contains("family"), -contains("margin")) %>% 
  pivot_longer(cols = everything(), names_to = "county", values_to = "med_income") %>% 
  filter(grepl("County", county)) %>% 
  mutate(county = str_replace_all(county, 
         pattern = county, 
         replacement = c("Androscoggin",
                         "Aroostook",
                         "Cumberland",
                         "Franklin",
                         "Hancock",
                         "Kennebec",
                         "Knox",
                         "Lincoln",
                         "Oxford",
                         "Penobscot",
                         "Piscataquis",
                         "Sagadahoc",
                         "Somerset",
                         "Waldo",
                         "Washington",
                         "York"
                         ))) %>% 
  mutate(med_income = as.numeric(gsub(",", "", med_income)))  %>%
  right_join(county_latlon_sf, by = c("county" = "COUNTY")) %>% 
  st_as_sf() %>% 
  mutate(income_popup = paste("<b>", county, "</b>" ,
                               "<br>", "Median Income: ", med_income))
