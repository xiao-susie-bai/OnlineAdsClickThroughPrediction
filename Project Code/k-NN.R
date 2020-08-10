LogLoss_fn <- function(PHat, y_act) {       #"Phat": predicted probability of class being "positive"; "y_act": actual class (positive or negative class)
  log_loss <- y_act * log(PHat +0.0001) + (1-y_act) * log(1-PHat +0.0001)
  return(mean(-log_loss))
}


library(kknn)

load("Train10k_fixedsplit.RData")
load("Val10k_fixedsplit.RData")
TrainDat <- as.data.frame(TrainDat)
ValDat <- as.data.frame(ValDat)

model <- kknn(formula = click ~., train=TrainDat, test=ValDat, k = 10, distance = 2, kernel = "optimal")
pred <- predict(model, ValData, type = "prob")    
# https://www.rdocumentation.org/packages/kknn/versions/1.3.1/topics/kknn



