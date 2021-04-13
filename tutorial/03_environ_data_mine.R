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
geo.extent <- extent(-86, -65, 16, 26) # e.g. Greater Antilles

  # crop bioclim predictors to the geographic extent
bioclim.data <- crop(bioclim.data, geo.extent)

  # examine cropped raster files
plot(bioclim.data$bio1)


### 
  ## upload and wrangle already downloaded bioclim data predictors
