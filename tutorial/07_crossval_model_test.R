###
# this section is meant to be run right after section 06
# a custom maxent model is needed 

### 


# evaluate Maxent model using a k-fold cross validation approach
setwd("PATH_TO_OUTPUT_DIR/")
  # make single run model using ALL species points
mxnt.cv <- maxent(predictors1, xy, args = c("linear=true", "quadratic=true", "product=true", "hinge=true", 
                                            "threshold=false", "betamultiplier=1", "replicates=5", 
                                            "outputgrids=FALSE"), path = "Mxnt_Cval/")
    ## NOTES: this model uses the tuning parameters obtained from ENMevaluate (section 06). 
    ## the args "replicates=5" refers to the number of cross validation replicates (i.e. 5). this may be changed depending on the number of species observations
    ## the args "outputgrids=FALSE" refers to write each k-fold replicate model or not. 


# make model prediction
mxnt.cv.dist <- predict(mxnt.cv, predictors2, args = c("outputformat=cloglog", "outputgrids=FALSE"), progress = "text") ## this will spit out separate models for each replicate, not one summary 
    ## NOTES: change outputformat options "=raw" or "=logistic" or "=cloglog"
    ## after cross validation is performed, examine the average AUC value and compare with the model created using the full dataset
    ## this does not lead to plotting the average model produced by cross validation because in theory the model produced using the full dataset (section 06) should generalise better
