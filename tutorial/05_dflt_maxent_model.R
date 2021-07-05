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
plot(predictors$wc2.1_2.5m_bio_1)

  # create regional extent (xmn, xmx, ymn, ymx)
geo.extent <- extent(-125, -66, 24, 50) # example
  # crop predictors
predictors <- crop(predictors, geo.extent)
  # verify by plotting one of the predictors
plot(predictors$wc2.1_2.5m_bio_1)


# Create Maxent ENMs using default settings

# extract the Feature Classes from Maxent
getFCs <- function(html) {
  htmlRead <- readLines(html)
  featureTypes <- htmlRead[grep("Feature types", htmlRead)]
  substr(featureTypes, start=21, stop=nchar(featureTypes)-4)
}


## -- multiple model testing in maxent & determine best parameters in ENMeval
setwd("~/NEW_DIR1/NEW_DIR2/") # make sure you are here
  ## i.e. must be one level up from the directory where maxent.html is

# create the Maxent model
sp.mxnt.dflt <- maxent(predictors, xy, path = "./NEW_DIR3") # use path to create new directory

# create a raster of your Maxent model prediction
sp.dflt.dist <- predict(sp.mxnt.dflt, predictors, progress = 'text')
# examine the predicted distribution
plot(sp.dflt.dist)

  # test the prediction accuracy 
  # note that in Maxent.html results you can find the AUC value. to test the predictive accuracy of the model
  # use an independent measure for presence-only data: Boyce Index (Hizrel et al 2006) as implemented in Ecospat
library(ecospat)
ecospat.boyce(sp.dflt.dist, xy, window.w = "default", res = 100, PEplot = T)
  # boyce index statistic is the Spearman.cor value (= 0.991)
    # goes between -1 to +1 
    # positive vlaues = a model which present predictions are consistent with the distribution of presences in the evaluation dataset
    # values near zero = the model is not different from a random model
    # negative values = negative values indicate counter predictions, i.e., predicting poor quality areas where presences are more frequent

# determine the Feature Classes of the default Maxent model
def.results <- getFCs(paste("MxntDflt/", "/maxent.html", sep = "")) # "MxntDflt/" needs to point to the directory where your default model lives
def.results <- strsplit(def.results, " ")[[1]]

def.results <- lapply(def.results, function(x) gsub("hinge", "H", x))
def.results <- lapply(def.results, function(x) gsub("linear", "L", x))
def.results <- lapply(def.results, function(x) gsub("product", "P", x))
def.results <- lapply(def.results, function(x) gsub("threshold", "T", x))
def.results <- lapply(def.results, function(x) gsub("quadratic", "Q", x))

def.results <- lapply(def.results, function(x) paste(x, collapse = ""))
def.results <- paste(unlist(def.results),collapse = "")
# print the Feature Classes used in the default model
def.results # "HPLQ"
