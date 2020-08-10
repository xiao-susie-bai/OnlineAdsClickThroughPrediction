if(!require("data.table")) {install.packages("data.table"); require("data.table")}
if(!require("fastDummies")) {install.packages("fastDummies"); require("fastDummies")}
if(!require("xgboost")) {install.packages("xgboost"); require("xgboost")}

toplist <- fread("/Users/baixiao/Desktop/top_50_cutoff.csv", header=TRUE)
View(toplist)

source("/Users/baixiao/Desktop/data\ processing\ functions/to_dummy.R")
source("/Users/baixiao/Desktop/data\ processing\ functions/trim_dummy.R")
source("/Users/baixiao/Desktop/data\ processing\ functions/LogLoss.R")

#####Loading Processed Training 1M Data (Dummy created)#########
#loading 1M training data (already processed with dummies) here:
load("/Users/baixiao/Desktop/TrainDat_processed.RData")       #TrainDat_processed in memory
#loading testing data [piece-by-piece] here:
load("/Users/baixiao/Downloads/Test_1.RData")

############Our Final Model: xgboost with n_depth=10 and n_rounds=30###########
#Training data containing the y label
Train <- copy(TrainDat_processed)
Train <- apply(Train, 2,  as.numeric)
dtrain <- xgb.DMatrix(data=as.matrix(Train[, -1]),label= as.matrix((Train[, 'click'])))

#Validation data not containing the y label
Test <- copy(Test_1)         #revise according to loading test data here!!!!
Test <- apply(Test, 2,  as.numeric)
#Test <- Test[,-1]       #***! validation data must get rid of the y variable for "xgboost"!!!
dtest <- xgb.DMatrix(data=as.matrix(Test))          #xgboost offers a way to group them in a "xgb.DMatrix" object(even add metadata in it), would be useful for advanced feature

#####quick: manually exploration and testing of model here######
xgb = xgboost(data=dtrain, objective='binary:logistic', max_depth = 10, nrounds = 30, eval_metric = c("logloss"))

#Training Loss:
yhat_tr=predict(xgb, dtrain)
LogLoss(yhat_tr, as.numeric(Train[,1]))

#prediction:
yhat=predict(xgb,dtest)      #numeric vector
save(yhat, file="/Users/baixiao/Desktop/Test_1_result.RData")

#yhat_all <- rbind(yhat_all, yhat)

