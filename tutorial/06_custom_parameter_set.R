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
  # save the results for later reference

# get the best model based on AIC
AICmods <- which(eval.results@results$AICc == min(na.omit(eval.results@results$AICc)))
eval.results@results[AICmods, ]
  # note the best model AICc = #####.
  # note custom parameter settings for the best model: RM = ## & FC = ###
# get the default model features
def.results
# note the difference in AICc
  # list the FC tested and find the position of the one that matches the default model
eval.results@results[["fc"]]
  # list the AICc values and identify the AIC.c of your default model
eval.results@results[["AICc"]]
  # note the default AICc = #####. 
  # the model with the lowr AICc is selected as the best model

# plot ENMeval model comparisons
evalplot.stats(e = eval.results, stats = "or.mtp", color = "fc", x.var = "rm")
evalplot.stats(e = eval.results, stats = "auc.val", color = "fc", x.var = "rm")


# improve Maxent model ussing custom parameters
  # get the custom parameters
  # call AICmods
AICmods <- which(eval.results@results$AICc == min(na.omit(eval.results@results$AICc)))[1]
  # convert AICmods into a data.frame
AICmods <- eval.results@results[AICmods,]
  # Get the Feature Classes from the best model
FC_best <- as.character(AICmods$features[1])
  # get the Regularization Multiplier from the best model
RM_best <- AICmods$rm

# build a single-run custom Maxent model
  # set the parameters for the custom Maxent model
maxent.args <- make.args(RMvalues = RM_best, fc = FC_best)

  # run the custom Maxent model with the ENMeval best parameters and save in new directory
mxnt.best <- maxent(predictors, xy, args = maxent.args[[1]],
                         path = "Mxnt_Best/") # indicate an appropriate path to save results
  # create a prediction across geographic space of your custom Maxent model 
best.dist <- predict(mxnt.best, predictors, overwrite = T, progress = 'text')

  # examine both predicted distributions side by side
plot(dflt.dist, col = viridis::viridis(99), main = "Default Model")
plot(best.dist, col = viridis::viridis(99), main = "Best Model")

  # examine variable contribution for the best model
plot(mxnt.best)
  # examine the response curves for the best model
response(mxnt.best)

