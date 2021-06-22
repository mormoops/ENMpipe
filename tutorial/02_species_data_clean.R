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
sp1.dups <- duplicated(sp1.com[ , c("lon", "lat")]) # creae a duplicated logical set from sp1.com identify identical records of lon/lat
sp1 <- sp1.com[!sp1.dups, ] # remove the duplicated set from the complete data.frame & replace sp1


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
head(sp1)

  # create a thinned dataset
thin_data <- thin(loc.data = sp1, lat.col = "lat", long.col = "lon", spec.col = "species", 
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
  # "*thin1.csv" shown as example. choose appropriate directory and thinned dataset to import
sp1 <- read.csv(file = "/thin_sp1/sp1_thin1.csv", header = T)


### 
  # basic mapping to identify point density and outliers
  # uses base R mapping

library(maptools)

    # get map data
data("wrld_simpl")

    # plot a base map
plot(wrld_simpl, xlim = c(min, max), ylim = c(min, max), axes = TRUE, col = NA)
      # replace "min" and "max" with the upper and lower limits of the desiered lon/lat coordinates

    # add species observation localities
points(x = sp1$lon, y = sp1$lat, col = "red", pch = 20, cex = 0.75)


###
# optional cleanup steps
# examine any outliers & remove them (easy to remove a few indivudual points)

# method 1: function "identify"
identify(x = sp1$lon, y = sp1$lat) # hit escape to obtain results
  # identify will return the row for the record, use bracket notation to get the info
sp1[1535, ] # in this example, record 1535 is incorrectly georeferenced
  # remove that specific row
sp1 <- sp1[-c(1535), ]
  # verify that the record is gone
sp1[1535, ] # it must show a different record
# repeat these steps for as many individual records as needed


# method 2: using a shapefile
  # wrangle data using the species range as a mask involves 4 steps: 
      # 1. getting a shapefile, 
      # 2. transforming observation data into spatial, 
      # 3. crop observation data
      # 4. back transform spatial observation data to a data.frame
  # download species distribution shapefile from IUCN redlist (www.redlist.org)

library(sf)
library(rgdal)

# read the shapefile
rbPoly <- readOGR("dirname/filename.shp") # replace 'dirname' for the appropriate directory name and 'filename' for the appropriate name of the shape file
# verify the polygon is OK
plot(rbPoly)

# convert species observations to spatial
colnames(sp1)
# extract lon lat coordinates
xy <- sp1[, c(2:3)]
summary(xy)
# convert xy data.frame to sp
spdf <- SpatialPointsDataFrame(coords = xy, data = sp1,
                               proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))

# crop the species observations to the polygon (package raster)
rbmsk <- crop(spdf, rbPoly)
#verify the points
plot(rbmsk)
# convert rbmsk to data.frame
sp2 <- as.data.frame(rbmsk)
# remove the extra lon lat variables
sp2 <- sp2[, -c(4,5)]
summary(sp2)
