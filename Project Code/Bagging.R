############Create the "LogLoss" evaluation metric##################
LogLoss_fn <- function(PHat, y_act) {       #"Phat": predicted probability of class being "positive"; "y_act": actual class (positive or negative class)
  log_loss <- y_act * log(PHat +0.0001) + (1-y_act) * log(1-PHat +0.0001)      #!!!prevent log() gets "NaN"(add small number)
  return(mean(-log_loss))
}


load("Train100k_fixedsplit.RData")
load("Val100k_fixedsplit.RData")

#To make R recognize this "randomForest" algorithm is for CLASSIFICATION:
TrainDat$click <- as.character(TrainDat$click)
TrainDat$click <- as.factor(TrainDat$click)
rand_forest <- randomForest(click~., data=TrainDat, ntree=1000)      

#fit the entire tree model once first (currently, not including the "ID" column)
FullModel <- paste("y_Train ~", paste(colnames(TrainDat), collapse=" + "), sep=" ")      #WARNING!!!: NEED TO CHANGE SOME CODE BASED ON WHAT THE ACTUAL DATASET USING LOOKS LIKE!!!
FullModel <- formula(FullModel)

#(make Training and Testing data again:)
TrainDat <- dat[1:ceiling(nrow(dat)*0.6), ]
ValDat <- dat[(ceiling(nrow(dat)*0.6)+1):nrow(dat), ]

TrainDat <- sapply(TrainDat, factor)
TrainDat <- as.data.frame(TrainDat)
ValDat <- sapply(ValDat, factor)
ValDat <- as.data.frame(ValDat)

class(TrainDat$click)
class(ValDat$click)

FullModel <- paste("click ~", paste(colnames(TrainDat)[2:ncol(TrainDat)], collapse=" + "), sep=" ")      #WARNING!!!: NEED TO CHANGE SOME CODE BASED ON WHAT THE ACTUAL DATASET USING LOOKS LIKE!!!
FullModel <- formula(FullModel)

#bagging(full model with all X_variables) with default parameter first:
bagging <- randomForest(FullModel, data=TrainDat, mtry=(ncol(TrainDat)-1))
y_pred_prob <- predict(bagging, newdata=ValDat, type="prob")[, 2]        #WARNING AGAIN!!!: Error: "New Factor Levels in Testing/Validation Data not present in the Training Data"
LogLoss <- LogLoss(y_pred_prob, as.numeric(ValDat$click))
LogLoss

#####still, possible parameters to tune:
#"ntree": nubmer of trees to grow
#"nodesize": minimum size of terminal nodes
LogLoss_result <- numeric()
for (m in seq(200, 1400, by=300)) {          #"ntree"
  for (n in seq(10, 50, by=10)) {           #"nodesize"
    bagging_current <- randomForest(FullModel, data=TrainDat, ntree=m, mtry=(ncol(TrainDat)-1), nodesize=n)
    y_pred_prob <- predict(bagging_current, newdata=ValDat, type="prob")[, 2]      #probability of class "1"!
    LogLoss_result[paste0("ntree=", m, "nodesize=", n)] <- LogLoss(y_pred_prob, as.numeric(ValDat$click))
  }
}
length(LogLoss_result)
LogLoss_result
best_perform <- LogLoss_result[LogLoss_result==min(LogLoss_result, na.rm=TRUE)]
best_perform
