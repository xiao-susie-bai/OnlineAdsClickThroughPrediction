library(data.table)
library(tree)
library(randomForest)

############Create the "LogLoss" evaluation metric##################
LogLoss_fn <- function(PHat, y_act) {       #"Phat": predicted probability of class being "positive"; "y_act": actual class (positive or negative class)
  log_loss <- y_act * log(PHat +0.0001) + (1-y_act) * log(1-PHat +0.0001)      #!!!prevent log() gets "NaN"(add small number)
  return(mean(-log_loss))
}

###################################################################
load("Train100k_fixedsplit.RData")
load("Val100k_fixedsplit.RData")

#random forest with default parameter first:
sapply(TrainDat, class)

#To make R recognize this "randomForest" algorithm is for CLASSIFICATION:
TrainDat$click <- as.character(TrainDat$click)
TrainDat$click <- as.factor(TrainDat$click)
rand_forest <- randomForest(click~., data=TrainDat, ntree=1000)      

#Validation performance:
y_pred_prob <- predict(rand_forest, newdata=ValDat, type="prob")[, 2]
LogLoss <- LogLoss_fn(y_pred_prob, as.numeric(ValDat$click))
LogLoss           #0.4798092 w/ default parameters
# when ntree = 1000 #0.4724798 

#Training performance:
y_pred_prob_tr <- predict(rand_forest, newdata=TrainDat, type="prob")[, 2]
LogLoss <- LogLoss_fn(y_pred_prob_tr, as.numeric(TrainDat$click))
LogLoss            #3.638399 w/ default parameters


##########random forest with parameter tuning############
for (i in seq(200, 1400, by=300)) {
  rand_forest <- randomForest(click~., data=TrainDat, ntree=i)
  y_pred_prob <- predict(rand_forest, newdata=ValDat, type="prob")[, 2]
  LogLoss <- LogLoss_fn(y_pred_prob, as.numeric(ValDat$click))
  LogLoss
}

for (j in seq(2,10,by=2)) {
  rand_forest <- randomForest(click~., data=TrainDat, ntree=1100, mtry=j)
  y_pred_prob <- predict(rand_forest, newdata=ValDat, type="prob")[, 2]
  LogLoss <- LogLoss_fn(y_pred_prob, as.numeric(ValDat$click))
  LogLoss
}

#####possible parameters to tune:
#"ntree": nubmer of trees to grow
# *"mtry": number of variables randomly sampled as candidates at each split
#"nodesize": minimum size of terminal nodes
LogLoss_result <- numeric()
for (i in seq(200, 1400, by=300)) {          #"ntree"
  for (j in seq(2, 10, by=2)) {               #"mtry"
    for (k in seq(10, 50, by=10)) {           #"nodesize"
      rf_current <- randomForest(FullModel, data=TrainDat, ntree=i, mtry=j, nodesize=k)
      y_pred_prob <- predict(rf_current, newdata=ValDat, type="prob")[, 2]      #probability of class "1"!
      LogLoss_result[paste0("ntree=", i, "mtry=", j, "nodesize=", k)] <- LogLoss(y_pred_prob, as.numeric(ValDat$click))
    }
  }
}
length(LogLoss_result)
LogLoss_result
best_perform <- LogLoss_result[LogLoss_result==min(LogLoss_result, na.rm=TRUE)]
best_perform
