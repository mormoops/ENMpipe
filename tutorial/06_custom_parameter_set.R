###
# this section is meant to be run right after section 05
# a default maxent model is needed to obtain the parameters for comparison

### 

# use ENMeval to do multiple model testing in maxent & determine best parameters

# create a directory to save the ENMeval results
dir.create("OUTPUT_DIR/ENM_EVAL_DIR")
setwd("ENM_EVAL_DIR")


library(ENMeval)
library(maxnet)
# run ENMeval using different test parameters
# example: rm = regularization Multiplier: "0.5, 1, 1.5", "2"
# example: fc = feature classes: c("L", "LQ", "H", "LQH", "LQHP", "LQHPT")
# this combination will create 18 model evaluations: RM *3 & FC *6
eval.results <- ENMevaluate(occs = xy, envs = predictors,  
                    algorithm = 'maxnet', partitions = 'block', 
                    tune.args = list(fc = c("L", "LQ", "H", "LQH", "LQHP", "LQHPT"), rm = 1:3))
      ### if dismo::maxent is preferred, change algorithm = "maxent.jar"
      ### the multiple parameter comparisons will run for ~10–15 min in a regular 4 core laptop ###

# table of ENMeval results
head(eval.results@results)
  # save table of results for later use
write.csv(eval.results@results, file = "eval.results.csv", row.names = F)

# obtain the best model based on AIC
AICmods <- which(eval.results@results$AICc == min(na.omit(eval.results@results$AICc)))
eval.results@results[AICmods, ]
  # for this dataset, the best was model had AICc = ###
  # custom parameter settings for this model are: RM = ## & FC = ###
  # compare it with the default model above
def.results
# see the difference in AICc
  # list the FC tested and find the position of the one that matches the default model
eval.results@results[["fc"]]
  # list the AICc values and identify the AIC.c of your default model
eval.results@results[["AICc"]]
  # the default AICc = #### 
  # the lower AICc value indicates the best model

# plot ENMeval model comparisons
evalplot.stats(e = eval.results, stats = "or.mtp", color = "fc", x.var = "rm")
evalplot.stats(e = eval.results, stats = "auc.val", color = "fc", x.var = "rm")


# improve Maxent model ussing custom parameters
  # get the custom parameters from above
setwd("PATH_TO_OUTPUT_DIR/")
  # make single run model using ALL species points
mxnt.best <- maxent(predictors, xy, args = c("linear=true", "quadratic=true", "product=true", 
                                           "hinge=true", "threshold=false", "betamultiplier=1"), path = "Mxnt_Cust1/")
    ## NOTE: change the args specifically to the parameters obtained from ENMevaluate above

# check variable contribution
plot(mxnt.best)
# check response curves
response(mxnt.best)

# make model prediction
mxnt.best.dist.log <- predict(mxnt.best, predictors, args = c("outputformat=logistic"), progress = "text")
    # NOTES: change outputformat options "=raw" or "=logistic" or "=coglog"
# plot predicted models for visual comparison
plot(mxnt.best.dist.log, main = "Best Model", xlab = "longitude", ylab = "latitude")
plot(mxnt.dflt, main = "Default Model", xlab = "longitude", ylab = "latitude")
