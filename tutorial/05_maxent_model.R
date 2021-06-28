## 4B: this approach uses the Maxent algorithm for ENM
  # NOTE: you need only "lon", and "lat" variables; edit the complete bat data.frame to have

# fire up specific libraries (if not continuing from above)
library(raster)
library(maptools)
library(dismo)
library(rJava)
library(ENMeval)
library(tidyverse)


# set working directory. all outputs will be here.
setwd("~/MaxEnt_Test/")

# 4B.1. script to get the Feature Classes from Maxent
getFCs <- function(html) {
  htmlRead <- readLines(html)
  featureTypes <- htmlRead[grep("Feature types", htmlRead)]
  substr(featureTypes, start=21, stop=nchar(featureTypes)-4)
}

# get & wrangle your climate & species data (### --- used from section 1 & 2 above --- ###)
    ## NOTE: if you  already downloaded climate data you can just import as a raster stack
# create a list of all files within the directory of climate data
  # choose pattern = ".bil" or ".tif" depending on what extension your raster is
raster_files <- list.files("wc2-5/", full.names = T, pattern = ".bil")
# create a raster stack using the list you created
predictors <- stack(raster_files)
# to verify, use 
plot(predictors)
  # then rm() the objects not in use to clean the environment
  # as long as you have all rasters in the same resolution & extent, you can load them as a stack
# then you can crop to the extent you desire (xmn, xmx, ymn, ymx)
geo.extent <- extent(-86, -65, 16, 24)
# crop predictors
predictors <- crop(predictors, geo.extent)
# verify by plotting one of the predictors
plot(predictors$wc2.1_2.5m_bio_1)

# 4B.2. define spatial projections of sp data & verify
pfal.spdf <- SpatialPointsDataFrame(coords = pfal2, data = pfal2,
                               proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"))
summary(pfal.spdf)

# 4B.3. simple map to verify localities (you could try the ggplot2 approach)
data("wrld_simpl")
plot(pfal.spdf, pch = 21, cex = 1, col = "red")
plot(wrld_simpl, add = T)

# 4B.4. Create Maxent ENMs using default settings
  # create a new directory to save outputs
dir.create("./Mxnt_Dflt_Out")  ### sipped!
    #### NEW #####
## -- multiple model testing in maxent & determine best parameters in ENMeval
setwd("~/MaxEnt/Outputs/") # make sure you are here
## this must be one level up from the directory where maxent.html is

# create the Maxent model
pfal.mxnt.dflt <- maxent(predictors, pfal.spdf, path = "Mxnt_Dflt_Out/")
    ## NOTE: the maxent.jar program MUST be within the java directory of the package dismo
    ##       to verify/get the directory of dismo use: 
system.file("java", package = "dismo")
    ##       then move copy & paste the maxent.jar file into the directory listed by the pathname
    ## more info here: https://rdrr.io/cran/dismo/man/maxent.html

# create a raster of your Maxent model prediction
pfal.dflt.dist <- predict(pfal.mxnt.dflt, predictors, progress = 'text')
# examine the predicted distribution
plot(pfal.dflt.dist)

# test the prediction accuracy 
  # note that in Maxent.html results you can find the AUC value. to test the predictive accuracy of the model
  # use an independent measure for presence-only data: Boyce Index (Hizrel et al 2006) as implemented in Ecospat
library(ecospat)
ecospat.boyce(pfal.dflt.dist, pfal2, window.w = "default", res = 100, PEplot = T)
  # note that you need to use the species point xy data.frame (here pfal2) not the spdf data used for modeling
  # your statistic is the Spearman.cor value (= 0.904)
  # goes between -1 to +1 
    # positive vlaues = a model which present predictions are consistent with the distribution of presences in the evaluation dataset
    # values near zero = the model is not different from a random model
    # negative values = negative values indicate counter predictions, i.e., predicting poor quality areas where presences are more frequent
  # you can save your raster layer & points file to recalculate this any time
write.csv(pfal2, file = "Mxnt_Dflt_Out/Pfal_xy.csv", row.names = F) # write sp data
writeRaster(pfal.dflt.dist, file = "Mxnt_Dflt_Out/Pfal_mxntDist.raster")
   # to read a raster back 
      # data.raster <- raster("DIRECTORY/RasterLayerNAME.grd")
