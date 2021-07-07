###

# this section is meant to be run right after section 06 or 07
# a maxent model with species specific parameter tuning is needed to produce space or time model projections

### 
  ## upload and wrangle bioclim data predictors for the desired time period
  ## time-scaled climate projections can be obtained from: www.worlclim.org or www.paleoclim.org

library(raster)

  # import rasters from specific directory
raster_past <- list.files("~/PATH/NAME/TO_PAST_DATA/", full.names = T, pattern = ".tif")
    # the pattern argument can help find different types of rasters (e.g. *.tif, *.bil, etc.) depending on the file format
    # NOTE: because this is a pattern matching, make sure to erase the *bil.zip file from the earlier download

  # create a raster stack of bioclim predictors
predictors_past <- stack(raster_past)

  # examine the uploaded raster files
plot(predictors_past$RASTER-NAME)
    # the raster name may vary depending on the raster data names

  # create a geographic extent for your study area
    # must be equal extent to the present clim data
    # change lon/lat coordinates (xmin, xmax, ymin, ymax)
geo.extent <- extent(-86, -65, 16, 27) # e.g. Greater Antilles

  # crop bioclim predictors to the geographic extent
predictors_past <- crop(predictors_past, geo.extent)

  # examine cropped raster files
plot(predictors_past$RASTER-NAME)

  ## NOTE: this section is repetitive and can be used to get past or future climate projections to examine distributions under climate change OR 
  ## using present data with a different geospatial extent to examine distributions under different spatial extent (e.g. invasive species range)

# make model prediction
  ## after a maxent model is run using custom parameters from ENMeval, use the predict() function below to make projections across space or time
  ## simply change the "predictors" to the desired space or time Raster Stack
mxnt.past.log <- predict(mxnt.best, predictors_past, args = c("outputformat=logistic"), progress = "text")
    # NOTES: change outputformat options "=raw" or "=logistic" or "=cloglog"
# plot predicted models for visual comparison
plot(mxnt.best.dist.log, main = "Best Model", xlab = "longitude", ylab = "latitude")
plot(mxnt.past.log, main = "Past Model", xlab = "longitude", ylab = "latitude")

