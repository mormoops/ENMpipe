###
# this approach uses the Maxent algorithm to produce ENMs
# this tutorial step assumes that species and environmental data are already available (see steps 1–3)

### 
# NOTE: the maxent.jar program MUST be within the java directory of the package dismo
##       to verify/get the directory of dismo use: 
system.file("java", package = "dismo")
##       then copy & paste the maxent.jar file into the directory listed by the pathname
##       download the latest copy of maxent here: https://biodiversityinformatics.amnh.org/open_source/maxent/


# fire up specific libraries (if not continuing from above)
library(raster)
library(maptools)
library(dismo)
library(rJava) # need 64-bit java version
library(ENMeval)
library(tidyverse)


# create working directories to organize your data
getwd()
dir.create("./NEW_DIR1")
dir.create("./NEW_DIR1/NEW_DIR2")


# get & wrangle species & environmental data
# species records
sp <- read.csv(file = "DATA_DIR/DATA.csv", header = T)
summary(sp)
# convert dataset to xy
xy <- sp[, c(2:3)]


## NOTE: environmental data must be a raster stack. all environmental data must have the same extent & resolution
  # create a list of all files within the directory of climate data
    # choose pattern = ".bil" or ".tif" depending on what extension your raster is
raster_files <- list.files("/PATH_TO_DIR/CLIMATE_DATA_DIR/", full.names = T, pattern = ".tif")
  # create a raster stack using the list you created
predictors <- stack(raster_files)
  #  verify
plot(predictors$NAME_PREDICTOR)

  # create two regional extents
    # 1. extent to calibrate maxent model
    # 2. extent to project maxent model
  # calibration extent: create a 5 degree radius buffer around species occurrence data.frame
    # requires to convert occurrence data into a GIS object
library(sf)
  # convert the species points into sf object
sp.sf <- st_as_sf(xy, coords = c("lon","lat"), crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")
summary(sp.sf) # examine 
class(sp.sf)  # examine 
crs(predictors) <- raster::crs(sp.sf) # match the predictor & species CRS.

# create a buffer on the species points with a 5 degree distance, then unite all buffer circles and convert to sf
sp.buf <- sf::st_buffer(sp.sf, dist = 5) %>% sf::st_union() %>% sf::st_sf()
  # NOTE: it will show a message that it is not projected, but that is OK
#  verify the full predictors
plot(predictors[[1]], main = names(predictors)[1])
# add the species points 
points(xy)
# add the buffer 
  # NOTE: use add = TRUE to include in the current plot
plot(sp.buf, border = "blue", lwd = 3, add = TRUE)
# crop the predictors based on the buffer
predictors1 <- crop(predictors, sp.buf)
  # create a mask to remove the area outside the predictors
predictors1 <- raster::mask(predictors1, sp.buf)
  # verify predictors were properly cropped
plot(predictors1$NAME_PREDICTOR)

  # projection extent: add a 10 degree square buffer to the max min lon lat coordinates from species occurrence data.frame
    # 10 degrees = ~1110 km (choose other if appropriate)
geo.ext.sqbuff <- extent(min(xy$lon)-10, max(xy$lon)+10, min(xy$lat)-10, max(xy$lat)+10) # example
  # crop original predictors
predictors2 <- crop(predictors, geo.ext.sqbuff)
  # verify by plotting one of the predictors
plot(predictors2$NAME_PREDICTOR)

  ## NOTES: this points out to creating a single projection extent using present environmental data. additional projection extents can be created for 
  ## different time periods or spatial scales

# Create Maxent ENMs using default settings

## -- multiple model testing in maxent & determine best parameters in ENMeval
setwd("~/NEW_DIR1/NEW_DIR2/") # make sure you are here
  ## i.e. must be one level up from the directory where maxent.html is

# create the Maxent model
mxnt.dflt <- maxent(predictors1, xy, path = "./NEW_DIR3") # use path to create new directory

# create the Maxent model prediction
dflt.dist <- predict(mxnt.dflt, predictors2, progress = 'text')
# examine the predicted distribution
plot(dflt.dist)

  # test the prediction accuracy 
  # note that in Maxent.html results you can find the AUC value. to test the predictive accuracy of the model
  # use an independent measure for presence-only data: Boyce Index (Hizrel et al 2006) as implemented in Ecospat
  # IMPORTANT NOTE: the species observations (i.e. point localities / xy object) used MUST be within the projected disribution. Otherwise, NAs will be produced.
library(ecospat)
ecospat.boyce(dflt.dist, xy, window.w = "default", res = 100, PEplot = T)
  # boyce index statistic is the Spearman.cor value (= 0.991)
    # goes between -1 to +1 
    # positive vlaues = a model which present predictions are consistent with the distribution of presences in the evaluation dataset
    # values near zero = the model is not different from a random model
    # negative values = negative values indicate counter predictions, i.e., predicting poor quality areas where presences are more frequent
    # NOTE on Issue: a likely source of error in Boyce index calculation is poorly georeferenced observation data; this causes NAs to appear in the Maxent model. 
      # Solution: ensure all species observations are within the boundaries of climate data before modeling.


## create function to extract the Feature Classes from Maxent
getFCs <- function(html) {
  htmlRead <- readLines(html)
  featureTypes <- htmlRead[grep("Feature types", htmlRead)]
  substr(featureTypes, start=21, stop=nchar(featureTypes)-4)
}

# determine the Feature Classes of the default Maxent model
def.results <- getFCs(paste("MxntDflt/", "/maxent.html", sep = "")) # "MxntDflt/" needs to point to the directory where your default model lives (i.e. NEW_DIR3)
def.results <- strsplit(def.results, " ")[[1]]

def.results <- lapply(def.results, function(x) gsub("hinge", "H", x))
def.results <- lapply(def.results, function(x) gsub("linear", "L", x))
def.results <- lapply(def.results, function(x) gsub("product", "P", x))
def.results <- lapply(def.results, function(x) gsub("threshold", "T", x))
def.results <- lapply(def.results, function(x) gsub("quadratic", "Q", x))

def.results <- lapply(def.results, function(x) paste(x, collapse = ""))
def.results <- paste(unlist(def.results),collapse = "")
# print the Feature Classes used in the default model
def.results 
# "HPLQ"
