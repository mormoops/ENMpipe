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
 # optional: create a new data.frame with records that have missing data (needs georeferencing)
sp1.mis <- sp1 %>% filter(is.na(lon))

  # eliminate duplicates
sp1.dups <- duplicated(sp1[, c("lon", "lat")]) # creae a duplicated set
sp1 <- sp1[!sp1.dups, ] # remove the duplicated set from the original data.frame


  # check the places where the species is distributed
unique(sp1$country)
    # use this information for 2 things:
      # first: create a filter of countries to map the distribution
      # second: as a modeling goal, predict which areas have suitable environmental features for this species


### 
  # reduce spatial autocorrelation
    # observation records are often spatially autocorrelated due to uneven or biased species sampling
    # this will further reduce your dataset

library(spThin)

  # verify the data
head(sp1.com)

  # create a thinned dataset
thin_data <- thin(loc.data = sp1.com, lat.col = "lat", long.col = "lon", spec.col = "species", 
                  thin.par = 10, reps = 50, locs.thinned.list.return = T, write.files = T, 
                  max.files = 5, out.dir = "thin_sp1/", out.base = "sp1", 
                  write.log.file = TRUE, log.file = "thin_sp1_log.txt")
    # NOTES: the thinning parameter (thin.par) controls the spatial distance in km between species observations
      # use knowledge of your species and the spacial resolution of covariates to set the thinning parameter 
      # reps indicates the number of iterations assigned. must run enough reps to ensure convergence
      # Plot 1: Gives you the number of records retained per iteration
      # Plot 2: Is the same as Plot 1 but with a log scale, so that it is easier to see if too many points or too many iterations are used
      # Plot 3: Gives you the frequency of the maximum records retained

# import the thinned dataset to proceed (assuming files are in home directory)
  # "*thin1.csv" shown as example. choose appropriate thinned dataset to import
sp <- read.csv(file = "/thin_sp1/sp1_thin1.csv", header = T)
