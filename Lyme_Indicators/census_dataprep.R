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
  mutate(income_popup = paste("<b>", county, "</b>" ,
                              "<br>", "Median Income: ", med_income)) %>% 
  st_as_sf() 
  
# reformat age set --------------------------------------------------------

total_pop <- age_insured %>% 
  filter(`Label (Grouping)` == "Civilian noninstitutionalized population") %>% 
  select(contains("Total"), -contains("Margin")) %>% 
  pivot_longer(cols = everything(), names_to = "county", values_to = "total") %>% 
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
                                                  "York",
                                                  "Maine (total)"
                                  )))

elderly_pop <- age_insured %>% 
  filter(grepl("65 years and older", `Label (Grouping)`)) %>% 
  select(contains("Total"), -contains("Margin")) %>% 
  pivot_longer(cols = everything(), names_to = "county", values_to = "elderly") %>% 
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
                                                  "York",
                                                  "Maine (total)"
                                  ))) %>% 
  left_join(total_pop, by = "county") %>% 
  mutate(pct_elderly = (elderly / total) * 100) %>% 
  filter(county != "Maine (total)") %>% 
  right_join(county_latlon_sf, by = c("county" = "COUNTY")) %>% 
  mutate(popup = paste("<b>", county, "</b>",
                       "<br>", "Percent of population over age 65:", pct_elderly)) %>% 
  st_as_sf() 



# write to new files ------------------------------------------------------

write_sf(elderly_pop, "clean_data/elderly_pct.shp")
write_sf(income, "clean_data/income.shp")
