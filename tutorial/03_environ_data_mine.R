###
  ## downloading & wrangling environmental data: WorldClim (www.worldclim.org)

library(raster)

  # NOTE: this will download, decompress, and make a raster stack of 2.5' resolution climate data 
    # for specific arguments see ?getData
    # recommended: create a specific directory where data will be downloaded & add it into path
bioclim.data <- getData(name = "worldclim", var = "bio", res = 2.5, path = "~/")

  # examine the downloaded raster files
plot(bioclim.data$bio1)

  # create a geographic extent for your study area
    # change lon/lat coordinates
      # coordinates in order: xmin, xmax, ymin, ymax)
geo.extent <- extent(-86, -65, 16, 27) # e.g. Greater Antilles

  # crop bioclim predictors to the geographic extent
predictors <- crop(bioclim.data, geo.extent)

  # examine cropped raster files
plot(predictors$RASTER-NAME)


### 
  ## upload and wrangle already downloaded bioclim data predictors

  # import rasters from specific directory
raster_files <- list.files("~/PATH/NAME", full.names = T, pattern = ".tif")
    # the pattern argument can help find different types of rasters (e.g. *.tif, *.bil, etc.) depending on the file format
    # NOTE: because this is a pattern matching, make sure to erase the *bil.zip file from the earlier download

  # create a raster stack of bioclim predictors
predictors <- stack(raster_files)

  # examine the uploaded raster files
plot(predictors$RASTER-NAME)
    # the raster name may vary depending on the raster data names
  # NOTES: once uploaded, create a geo.extent and crop predictors (i.e. line 14 to 22 above)
