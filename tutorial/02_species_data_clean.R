### 
  # basic wrangling to clean-up species observation data
    # note: this requires no georeferencing. it assumes that a statistically significant number of records exist for the species to be analyzed
 library(tidyverse)
  # list columns to select what to keep
colnames(sp)

  # keep only species, longitude, and latitude columns & overwrite data.frame
sp1 <- sp[c("species", "country", "lon", "lat")] 

  # data wrangling: figure out the missing lon/lat
summary(sp1)   # note that some lon/lat records are missing (NA)

  # check the dimensions of the data.frame  
dim(sp1)
  # figure out how many missing/non missing observations you have for lon
sum(is.na(sp1$lon))
sum(!is.na(sp1$lon))

  # create a new data.frame with complete records
sp1.com <- sp1 %>% filter(!is.na(lon)) 
 # optional: create a new data.frame with records with missing data (needs georeferencing)
sp1.mis <- sp1 %>% filter(is.na(lon))

  # eliminate duplicates
sp1.dups <- duplicated(sp1[, c("lon", "lat")]) # creae a duplicated set
sp1 <- sp1[!sp1.dups, ] # remove the duplicated set from the original data.frame


  # check the places where the species is distributed
unique(sp1$country)
    # use this information for 2 things:
      # first: create a filter of countries to map the distribution
      # second: as a modeling goal, predict which areas have suitable environmental features for this species
