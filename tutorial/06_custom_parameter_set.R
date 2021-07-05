###
# this section is meant to be run right after section 05
# a default maxent model is needed to obtain and then set custom parameters

### 

# fine tune model parameters and create a single run tuned Maxent model
# use ENMeval to do multiple model testing in maxent & determine best parameters
## NOTE: multi-core runs are posssible use detectCores() to see how many available
library(parallel)
library(doParallel)
detectCores()

#5A.1. create a directory for the ENMeval results
dir.create("./ENMeval_sp")


library(ENMeval)
# 5A run ENMeval using the following test parameters
# Regularization Multiplier: "0.5, 1, 1.5", "2"
# Feature classes: c("L", "LQ", "H", "LQH", "LQHP", "LQHPT")
# this combination will create 18 model evaluations: RM *3 & FC *6
eval.results <- ENMevaluate(occ = xy, env = predictors, RMvalues = seq(0.5, 3, 0.5), 
                            fc = c("L", "LQ", "H"), method = 'block')
