# Read Neural Net Output --------------------------------------------------
LogLoss_fn <- function(PHat, y_act) {       #"Phat": predicted probability of class being "positive"; "y_act": actual class (positive or negative class)
  log_loss <- y_act * log(PHat +0.0001) + (1-y_act) * log(1-PHat +0.0001)      #!!!prevent log() gets "NaN"(add small number)
  return(mean(-log_loss))
}


#### 10k ####
y_act <- read.csv('Val10k_fixedsplit.csv', header=T, sep=",")
# 4x4
TrainYHat <- read.table("TrYHatFromBCNN4x4_10K.csv",header=T,sep=",")
ValYHat <- read.table("ValYHatFromBCNN4x4_10K.csv",header=T,sep=",")
Log_Loss <- LogLoss_fn(as.numeric(ValYHat$YHatVal), as.numeric(y_act$click))
Log_Loss

# 4x10
TrainYHat <- read.table("TrYHatFromBCNN4x10_10k.csv",header=T,sep=",")
ValYHat <- read.table("ValYHatFromBCNN4x10_10k.csv",header=T,sep=",")
Log_Loss <- LogLoss_fn(as.numeric(ValYHat$YHatVal), as.numeric(y_act$click))
Log_Loss

# 10x4
TrainYHat <- read.table("TrYHatFromBCNN10x4_10k.csv",header=T,sep=",")
ValYHat <- read.table("ValYHatFromBCNN10x4_10k.csv",header=T,sep=",")
Log_Loss <- LogLoss_fn(as.numeric(ValYHat$YHatVal), as.numeric(y_act$click))
Log_Loss

#### 100k ####
y_act <- read.csv('Val100k_fixedsplit.csv', header=T, sep=",")
# 4x4
TrainYHat <- read.table("TrYHatFromBCNN4x4_100K.csv",header=T,sep=",")
ValYHat <- read.table("ValYHatFromBCNN4x4_100K.csv",header=T,sep=",")
Log_Loss <- LogLoss_fn(as.numeric(ValYHat$YHatVal), as.numeric(y_act$click))
Log_Loss

# 4x10
TrainYHat <- read.table("TrYHatFromBCNN4x10_100k.csv",header=T,sep=",")
ValYHat <- read.table("ValYHatFromBCNN4x10_100k.csv",header=T,sep=",")
Log_Loss <- LogLoss_fn(as.numeric(ValYHat$YHatVal), as.numeric(y_act$click))
Log_Loss

# 10x4
TrainYHat <- read.table("TrYHatFromBCNN10x4_100k.csv",header=T,sep=",")
ValYHat <- read.table("ValYHatFromBCNN10x4_100k.csv",header=T,sep=",")
Log_Loss <- LogLoss_fn(as.numeric(ValYHat$YHatVal), as.numeric(y_act$click))
Log_Loss
