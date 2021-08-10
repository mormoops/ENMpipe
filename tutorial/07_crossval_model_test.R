#####################
## under construction
#####################


# improve Maxent model ussing custom parameters
  # get the custom parameters from above
setwd("PATH_TO_OUTPUT_DIR/")
  # make single run model using ALL species points
mxnt.best <- maxent(predictors1, xy, args = c("linear=true", "quadratic=true", "product=true", 
                                           "hinge=true", "threshold=false", "betamultiplier=1"), path = "Mxnt_Cust1/")
    ## NOTE: change the args specifically to the parameters obtained from ENMevaluate above

# check variable contribution
plot(mxnt.best)
# check response curves
response(mxnt.best)
# calculate Boyce index
ecospat.boyce(mxnt.best, xy, window.w = "default", res = 100, PEplot = T)
  # boyce index statistic is the Spearman.cor value = ####
  # note the ROC AUC value from the maxent.html file. AUC = ####

# make model prediction
mxnt.best.dist.log <- predict(mxnt.best, predictors2, args = c("outputformat=cloglog"), progress = "text")
    # NOTES: change outputformat options "=raw" or "=logistic" or "=cloglog"
# plot predicted models for visual comparison
plot(mxnt.best.dist.log, main = "Best Model", xlab = "longitude", ylab = "latitude")
plot(mxnt.dflt, main = "Default Model", xlab = "longitude", ylab = "latitude")

### NOTE: this approach will create a maxent model with species specific tuned parameters using all observation records. 
### to further evaluate this model's performance, follow the cross validation steps in section 07
