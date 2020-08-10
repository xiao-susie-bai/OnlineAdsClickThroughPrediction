library(xgboost)
library(data.table)
library(fastDummies)

setwd("/Users/xbai32/Desktop")

#####load data directly#####
load("./Train_Val_RData/Train10k_fixedsplit.RData")
load("./Train_Val_RData/Val10k_fixedsplit.RData")
source("/Users/xbai32/Desktop/LogLoss.R")

#Training data containing the y label
#Train <- copy(train.dummy)
Train <- copy(TrainDat)
Train <- apply(Train, 2,  as.numeric)
dtrain <- xgb.DMatrix(data=as.matrix(Train[, -1]),label= as.matrix((Train[, 'click'])))

#Validation data not containing the y label
#Val <- copy(vali.trim)
Val <- copy(ValDat)
y <- Val$click
Val <- apply(Val, 2,  as.numeric)
Val <- Val[,-1]       #***! validation data must get rid of the y variable for "xgboost"!!!
dval <- xgb.DMatrix(data=as.matrix(Val))          #xgboost offers a way to group them in a "xgb.DMatrix" object(even add metadata in it), would be useful for advanced feature

#####Some explanation of 'booster parameters' available:#####
#"objective='binary:logistic'": train a binary classification model [*should output probability]; * "objective" specifies the learning task and corrsponding learning objective
#'eval_metric': evaluation metrics for validation data, *can pass a self-defined function; *default: assigned according to the objective(rmse for regression, and **error for classification)
#'max_depth=2': maximum depth of tree; *default: 6
#'eta': control the learning rate(scale the contribution of each tree by a factor in (0,1));
#lower value for 'eta' implies larger value for "nrounds", * lower value: more robust model
#to overfitting, but slower to compute; *default: 0.3
#'gamma': minimum loss reduction required to make further split on a leaf node of tree (the larger, the more "conservative")
#'min_child_weight': minimum sum of instance weight(hessian) needed in a child (i.e.: if less than this weight, stop splitting); *default: 1
#'subsample': subsample ratio of the training instance; e.g.: if "0.5": xgboost randomly collected half of the data instances to grow trees
#--> prevent overfitting; * affects computational length!, advised used with 'eta' and increase "nrounds"; *default: 1
#'colsample_bytree': subsample ratio of columns when constructing each tree [* sampled number of features each time]; *default: 1
#'nrounds': maximum number of boosting iterations
#['watchlist': named list of "xgb.DMatrix" datasets to use for evaluating model performance]
#'verbose': "0"--xgboost stay silent; "1"--print performance info, "2"--additional info printed out; if "verbose > 0", automatically engage "cb.print.evaluation(period=1)" callback function
#######################################################################
# manully adj
set.seed(1234)

# *first, use "xgb.cv" function to tune "n_rounds" with everything else default:
###For "10k" data, running the following [* For other size of data, would take too long to run -> just manually tune it]
#package default parameters:
params <- list(booster = "gbtree", objective = "binary:logistic", eta=0.3, gamma=0, max_depth=6, min_child_weight=1, subsample=1, colsample_bytree=1, eval_metric=c("logloss"))
xgbcv <- xgb.cv(params=params, data=dtrain, nrounds=100, nfold=5, showsd=T, stratified=T, print_every_n=10, early_stopping_rounds=20)
###### *****-> best "n_rounds" with all other probabilities fixed as default: 27 (iterations)

#max_depth only: -----> ***** INSIGHT from here: xgboost tree is NOT VERY DEEP as other tree models!!!!!
LogLoss_storage <- numeric()
for (i in seq(3, 10, by=1)) {          # * best max_depth seeming around 5
  cat("Now:", i, "\t")
  xgb_current <- xgboost(data=dtrain, objective='binary:logistic', max_depth=i, nrounds=27, eval_metric = c("logloss"))
  y_pred_prob <- predict(xgb_current, dval)      #probability vectors
  LogLoss_storage <- c(LogLoss_storage, LogLoss(y_pred_prob, as.numeric(y)))
}
LogLoss_storage
plot(seq(3, 10, by=1), LogLoss_storage, xlab = "max_depth")

#[continued]eta only:
LogLoss_storage <- numeric()         # * best eta seeming around 0.3
for (i in seq(0.1,0.9, by=0.1)) {
  cat("Now:", i, "\t")
  xgb_current <- xgboost(data=dtrain, objective='binary:logistic', max_depth=5, eta=i, nrounds=27, eval_metric = c("logloss"))
  y_pred_prob <- predict(xgb_current, dval)      #probability vectors
  LogLoss_storage <- c(LogLoss_storage, LogLoss(y_pred_prob, as.numeric(y)))
}
LogLoss_storage
plot(seq(0.1,0.9, by=0.1), LogLoss_storage, xlab = "eta")

#[continued]gamma only:
LogLoss_storage <- numeric()
for (i in seq(0, 1, by=0.1)) {      #not seeming anything special that can improve(a little random)--decision: leave it default
  cat("Now:", i, "\t")
  xgb_current <- xgboost(data=dtrain, objective='binary:logistic', max_depth=5, eta=0.3, gamma=i, nrounds=27, eval_metric = c("logloss"))
  y_pred_prob <- predict(xgb_current, dval)      #probability vectors
  LogLoss_storage <- c(LogLoss_storage, LogLoss(y_pred_prob, as.numeric(y)))
}
LogLoss_storage
plot(seq(0, 1, by=0.1), LogLoss_storage, xlab = "gamma")

#[continued]min_child_weight only:
LogLoss_storage <- numeric()
for (i in seq(1, 20, by=1)) {      # * best min_child_weight seeming around 3 -- but not absolute definite(slightly fluctuating)
  cat("Now:", i, "\n")
  xgb_current <- xgboost(data=dtrain, objective='binary:logistic', max_depth=5, eta=0.3, nrounds=27, min_child_weight=i, eval_metric = c("logloss"))
  y_pred_prob <- predict(xgb_current, dval)      #probability vectors
  LogLoss_storage <- c(LogLoss_storage, LogLoss(y_pred_prob, as.numeric(y)))
}
LogLoss_storage
plot(seq(1, 20, by=1), LogLoss_storage, xlab = "min_child_weight")

#[continued]subsample only:
LogLoss_storage <- numeric()
for (i in seq(0, 1, by=0.1)) {      # best subsample seeming still around 1 -- just leave it as default "1"
  cat("Now:", i, "\n")
  xgb_current <- xgboost(data=dtrain, objective='binary:logistic', max_depth=5, eta=0.3, nrounds=27, min_child_weight=3, subsample=i, eval_metric = c("logloss"))
  y_pred_prob <- predict(xgb_current, dval)      #probability vectors
  LogLoss_storage <- c(LogLoss_storage, LogLoss(y_pred_prob, as.numeric(y)))
}
LogLoss_storage
plot(seq(0, 1, by=0.1), LogLoss_storage, xlab = "subsample")

#[continued]colsample_bytree only:
LogLoss_storage <- numeric()
for (i in seq(0, 1, by=0.1)) {      # best colsample_bytree seeming still around 1 -- just leave it as default "1"
  cat("Now:", i, "\n")
  xgb_current <- xgboost(data=dtrain, objective='binary:logistic', max_depth=5, eta=0.3, nrounds=27, min_child_weight=3, colsample_bytree=i, eval_metric = c("logloss"))
  y_pred_prob <- predict(xgb_current, dval)      #probability vectors
  LogLoss_storage <- c(LogLoss_storage, LogLoss(y_pred_prob, as.numeric(y)))
}
LogLoss_storage
plot(seq(0, 1, by=0.1), LogLoss_storage, xlab = "colsample_bytree")

####integrately manual adjusting everything:
xgb = xgboost(data=dtrain, objective='binary:logistic', max_depth=5, eta=0.3, nrounds=30, min_child_weight=3, eval_metric = c("logloss"))
 
yhat=predict(xgb,dval)

#Validation loss:
LogLoss(yhat, as.numeric(y))

#Training Loss:
yhat_tr=predict(xgb, dtrain)
LogLoss(yhat_tr, as.numeric(Train[,1]))
##################################################################################

##################################################################
#auto adj
# find the best param on CV
best_param = list()
best_seednumber = 1234
best_logloss = Inf
best_logloss_index = 0


for (iter in 1:10) {
  param <- list(objective = "binary:logistic",     # binary class
                eval_metric = c("logloss"),                # logloss
                max_depth = sample(1:10, 1),               #
                eta = runif(1, .1, 2),                   # learning rate
                gamma = runif(1, 0.0, 0.2),                
                subsample = runif(1, .6, .9),             
                colsample_bytree = runif(1, .2, .8), 
                min_child_weight = sample(1:40, 1),
                max_delta_step = sample(1:10, 1)
  )
  cv.nround = 10                                   # iteriate: 10
  cv.nfold = 5                                     # cv fold = 5
  seed.number = sample.int(10000, 1)[[1]]
  set.seed(seed.number)
  mdcv <- xgb.cv(data=dtrain, params = param, nthread=6, metrics=c('logloss'),
                 nfold=cv.nfold, nrounds=cv.nround, watchlist = list(),
                 verbose = F, early_stop_round=8, maximize=FALSE)
  
  min_logloss = min(mdcv$evaluation_log[,test_logloss_mean])
  min_logloss_index = which.min(mdcv$evaluation_log[,test_logloss_mean])
  
  if (min_logloss < best_logloss) {
    best_logloss = min_logloss
    best_logloss_index = min_logloss_index
    best_seednumber = seed.number
    best_param = param
  }
}

(nround = best_logloss_index)
set.seed(best_seednumber)
best_seednumber
(best_param)                # display the best param


# build the model based on best param
model <- xgb.train(data=dtrain, params=best_param, nrounds=nround, nthread=6, watchlist = list())

yhat=predict(model,dval)

#Validation Loss:
LogLoss(yhat, as.numeric(y))

#Training Loss:
yhat_tr=predict(model,dtrain)
LogLoss(yhat_tr, as.numeric(Train[,1]))

