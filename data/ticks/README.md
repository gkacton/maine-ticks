## **Maine Tracking Network Incidence Data**

### Description

"This table shows the number of confirmed and probable cases of tickborne disease in the population. Combined year population data are the sum of individual years (e.g. 2010-14 is the sum of populations in 2010, 2011, 2012, 2013, and 2014). Maine CDC’s Infectious Disease Program obtained these data through notifiable conditions surveillance based upon reports from healthcare providers, laboratories, and other healthcare partners." 

"To protect privacy as per Maine CDC’s Privacy Policy, data may be suppressed. For locations where data are suppressed, a range ('<6') is provided for the number of events. Data may also be secondarily suppressed to protect against indirect identification and are displayed as a number range (such as '6-10' or '11-15') when possible, or Not Releasable (NR). Geographical locations with populations less than 50 individuals are also displayed as Not Releasable (NR)."

*Despription reported from the Maine Tracking Network data portal*

### Format

A data frame with 533 observations and 5 variables

### Data Dictionary

## `maine_tracking_network_incidence.csv`

|variable           |class     |description |
|:------------------|:---------|:-----------|
|Location           |character | Town in Maine where tick data is being reported from |
|Anaplasmosis       |character | Total number of anaplasmosis cases by town from 2016-2020 |
|Babesiosis         |character | Total number of babesiosis cases by town from 2016-2020 |
|Lyme               |character | Total number of lyme cases by town from 2016-2020 |
|Population         |numeric   | (0-350000) 5-year cummulative population by town |

### Source

https://data.mainepublichealth.gov/tracking/home

"Maine CDC’s Infectious Disease Program collected and analyzed the data. Maine CDC used population data from the U.S. Census Bureau to calculate state and county rates of tickborne disease. Maine CDC used population data from Maine CDC Data, Research, and Vital Statistics (DRVS) to calculate town-level rates of tickborne disease. The Maine Environmental Public Health Tracking Program prepared the data display. Data updated: 05/2021. Display updated: 05/2021."

### Cleaning Script

```{r data-import-mtn-number, echo = FALSE}
# read csv file
mtn_tick_town_number <- read_csv("/cloud/project/data/ticks/maine_tracking_network_incidence.csv")

# reformat count variables
mtn_tick_town_number <- mtn_tick_town_number %>%
  mutate(Lyme_Label = Lyme) %>%
  mutate(Lyme_Label = str_replace(Lyme_Label, "NR", "Not Releasable")) %>%
  mutate(Lyme = str_replace(Lyme, "<6", "6")) %>%
  mutate(Lyme = str_replace(Lyme, "6-10", "8")) %>%
  mutate(Lyme = str_replace(Lyme, "11-15", "13")) %>%
  mutate(Babesiosis_Label = Babesiosis) %>%
  mutate(Babesiosis_Label = str_replace(Babesiosis_Label, "NR", "Not Releasable")) %>%
  mutate(Babesiosis = str_replace(Babesiosis, "<6", "6")) %>%
  mutate(Babesiosis = str_replace(Babesiosis, "6-10", "8")) %>%
  mutate(Babesiosis = str_replace(Babesiosis, "11-15", "13")) %>%
  mutate(Anaplasmosis_Label = Anaplasmosis) %>%
  mutate(Anaplasmosis_Label = str_replace(Anaplasmosis_Label, "NR", "Not Releasable")) %>%
  mutate(Anaplasmosis = str_replace(Anaplasmosis, "<6", "6")) %>%
  mutate(Anaplasmosis = str_replace(Anaplasmosis, "6-10", "8")) %>%
  mutate(Anaplasmosis = str_replace(Anaplasmosis, "11-15", "13"))
  
# create numeric count variables
mtn_tick_town_number$Lyme <- as.numeric(mtn_tick_town_number$Lyme)
mtn_tick_town_number$Babesiosis <- as.numeric(mtn_tick_town_number$Babesiosis)
mtn_tick_town_number$Anaplasmosis <- as.numeric(mtn_tick_town_number$Anaplasmosis)

mtn_tick_town_number[mtn_tick_town_number == "NR"] = NA

# reformat location variable
mtn_tick_town_number <- mtn_tick_town_number %>%
  mutate(Location = str_replace(Location, "Plt", "Plantation")) %>%
  mutate(Location = str_replace(Location, "Bancroft Twp", "Bancroft")) %>%
  mutate(Location = str_replace(Location, "Aroostook", "Aroostook Twp")) %>%
  mutate(Location = str_replace(Location, "Somerset", "Somerset Twp")) %>%
  mutate(Location = str_replace(Location, "East Hancock", "East Hancock Twp")) %>%
  mutate(Location = str_replace(Location, "Dennistown", "Dennis")) %>%
  mutate(Location = str_replace(Location, "East Central Washington", "East Central Washington Twp")) %>%
  mutate(Location = str_replace(Location, "East Central Franklin", "East Central Franklin Twp")) %>%
  mutate(Location = str_replace(Location, "West Central Franklin", "West Central Franklin Twp")) %>%
  mutate(Location = str_replace(Location, "North Franklin", "North Franklin Twp")) %>%
  mutate(Location = str_replace(Location, "South Franklin", "South Franklin Twp")) %>%
  mutate(Location = str_replace(Location, "West Franklin", "West Franklin Twp")) %>%
  mutate(Location = str_replace(Location, "East Central Penobscot", "East Central Penobscot Twp")) %>%
  mutate(Location = str_replace(Location, "Louds Island", "Louds Island Twp")) %>%
  mutate(Location = str_replace(Location, "Marshall Island", "Marshall Island Twp")) %>%
  mutate(Location = str_replace(Location, "Monhegan Island Plantation", "Monhegan Plantation")) %>%
  mutate(Location = str_replace(Location, "Islands", "Islands Twp")) %>%
  mutate(Location = str_replace(Location, "North Oxford", "North Oxford Twp")) %>%
  mutate(Location = str_replace(Location, "South Oxford", "South Oxford Twp")) %>%
  mutate(Location = str_replace(Location, "North Washington", "North Washington Twp")) %>%
  mutate(Location = str_replace(Location, "North Penobscot", "North Penobscot Twp")) %>%
  mutate(Location = str_replace(Location, "Piscataquis", "Piscataquis Twp")) %>%
  mutate(Location = str_replace(Location, "Prentiss Twp T7 R3 NBPP", "Prentiss Twp")) %>%
  mutate(Location = str_replace(Location, "Seboomook Lake", "Seboomook Lake Twp")) %>%
  mutate(Location = str_replace(Location, "Square Lake", "Square Lake Twp")) %>%
  mutate(Location = str_replace(Location, "Saint", "St.")) 
```
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
## **Maine Tracking Network Incidence Rate Data**

### Description

"This table shows incidence rate (per 100,000 people) of confirmed and probable cases of tickborne disease in the population. Combined year population data are the sum of individual years (e.g. 2010-14 is the sum of populations in 2010, 2011, 2012, 2013, and 2014). Combined year rates are annualized across all included years. Maine CDC’s Infectious Disease Program obtained these data through notifiable conditions surveillance based upon reports from healthcare providers, laboratories, and other healthcare partners." 

"To protect privacy as per Maine CDC’s Privacy Policy, data may be suppressed. For locations where data are suppressed, an asterisk (\*) is provided for the rate."

*Despription reported from the Maine Tracking Network data portal*

### Format

A data frame with 533 observations and 5 variables

### Data Dictionary

## `maine_tracking_network_rate.csv`

|variable           |class     |description |
|:------------------|:---------|:-----------|
|Location           |character | Town in Maine where tick data is being reported from |
|Anaplasmosis       |character | Incidence rate (per 100,000 people) of anaplasmosis cases by town from 2016-2020 |
|Babesiosis         |character | Incidence rate (per 100,000 people) of babesiosis cases by town from 2016-2020 |
|Lyme               |character | Incidence rate (per 100,000 people) of lyme cases by town from 2016-2020 |
|Population         |numeric   | (0-350000) 5-year cummulative population by town |

### Source

https://data.mainepublichealth.gov/tracking/home

"Maine CDC’s Infectious Disease Program collected and analyzed the data. Maine CDC used population data from the U.S. Census Bureau to calculate state and county rates of tickborne disease. Maine CDC used population data from Maine CDC Data, Research, and Vital Statistics (DRVS) to calculate town-level rates of tickborne disease. The Maine Environmental Public Health Tracking Program prepared the data display. Data updated: 05/2021. Display updated: 05/2021."

### Cleaning Script

```{r data-import-mtn-rate, echo = FALSE}
# read csv file
mtn_tick_town_rate <- read_csv("/cloud/project/data/ticks/maine_tracking_network_rate.csv")

# reformat rate
mtn_tick_town_rate[mtn_tick_town_rate == "*"] = NA
mtn_tick_town_rate[mtn_tick_town_rate == "NR"] = NA
```
