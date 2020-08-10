####################LOG LOSS goes here######################
LogLoss_fn <- function(PHat, y_act) {       #"Phat": predicted probability of class being "positive"; "y_act": actual class (positive or negative class)
  log_loss <- y_act * log(PHat +0.0001) + (1-y_act) * log(1-PHat +0.0001)
  return(mean(-log_loss))
}

library(e1071)

load("Train100k_fixedsplit.RData")
load("Val100k_fixedsplit.RData")
TrainDat <- as.data.frame(TrainDat)
ValDat <- as.data.frame(ValDat)

# create the naive Bayes model based on train data
model <- naiveBayes(click~., data=TrainDat)

# use the model to do the prediction
pred <- predict(model, ValDat, type = 'raw')

#View(pred)
colnames(pred) <- c('prob0', 'prob1')

# import the result back to test dataset - just for quick show purpose
Val_Result <- cbind(ValDat[, "click"], pred)
View(Val_Result)

#Evaluate the model:
LogLoss_fn(pred[, "prob1"], as.numeric(ValDat$click))
