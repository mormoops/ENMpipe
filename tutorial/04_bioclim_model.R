###
  # this approach uses the Bioclim algorithm to produce an ENM
  # if running a different algorithm, this step of the tutorial can be skipped
  # this tutorial step assumes that species and environmental data are already available (see steps 1–3)

  # ensure species name spelling is unique
summary(sp)
unique(sp$species)
   # NOTE: if more than one species name spelling, names must be standardized before modeling
   
  # create the modeling xy data.frame & verify it
sp.xy <- sp[c("lon", "lat")] 
summary(sp.xy)

  # ensure predictors (i.e. environmental data) is cropped to the desired extent (see step 3)
geo.extent <- extent(-86, -65, 16, 26) # e.g. Greater Antilles

library(dismo)

## create a bioclim ENM
sp.model <- bioclim(x = predictors, p = sp.xy)

  # create a prediction of presence for the model
predict.presence <- dismo::predict(object = sp.model, x = predictors, ext = geo.extent)

  # examine the predictive model
plot(predict.presence)

  # mapping ENM predictions
    # base R map 
    # attach map daata
data("wrld_simpl")

  # plot map
plot(wrld_simpl, xlim = c(-86, -65), ylim = c(16, 26), axes = TRUE, col = NA, add = T)

  # OPTIONAL: add species localities
points(sp$lon, sp$lat, col = "black", pch = 20, cex = 0.75)


