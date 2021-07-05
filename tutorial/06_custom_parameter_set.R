###
# this section is meant to be run right after section 05
# a default maxent model is needed to obtain and then set custom parameters

### 

# fine tune model parameters and create a single run tuned Maxent model
# use ENMeval to do multiple model testing in maxent & determine best parameters

# create a directory for the ENMeval results
dir.create("OUTPUT_DIR/ENM_EVAL_DIR")


library(ENMeval)
# 5A run ENMeval using the following test parameters
# Regularization Multiplier: "0.5, 1, 1.5", "2"
# Feature classes: c("L", "LQ", "H", "LQH", "LQHP", "LQHPT")
# this combination will create 18 model evaluations: RM *3 & FC *6
eval.results <- ENMevaluate(occ = xy, env = predictors, RMvalues = seq(0.5, 2, 0.5), 
                            fc = c("L", "LQ", "H"), method = 'block')
   ### the multiple parameter comparisons will run for ~10–15 min in a regular 4 core laptop ###

# table of ENMeval results
head(eval.results@results) 

# obtain the best model based on AIC
AICmods <- which(eval.results@results$AICc == min(na.omit(eval.results@results$AICc)))
eval.results@results[AICmods, ]
  # note the best model and the AICc score
  # note custom parameter settings for best model: RM = ## & FC = ##
  # compare it with the default model above
def.results
  # see the difference in AICc
  # list the FC tested and find the position of the one that matches the default model
eval.results@results[["features"]]
  # list the AICc values and identify the AIC.c of your default model
eval.results@results[["AICc"]]
  # note the default AICc = ###. 
  # the lower AICc value indicates the best model

# plot ENMeval model comparisons
    # par(mfrow=c(2,3)) # may use to plot in single panel
eval.plot(eval.results@results)
eval.plot(eval.results@results, "avg.test.AUC", legend = F)
eval.plot(eval.results@results, "train.AUC", legend = F)
eval.plot(eval.results@results, "avg.diff.AUC", legend = F)
eval.plot(eval.results@results, "avg.test.orMTP", legend = F)
eval.plot(eval.results@results, "avg.test.or10pct", legend = F)

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

