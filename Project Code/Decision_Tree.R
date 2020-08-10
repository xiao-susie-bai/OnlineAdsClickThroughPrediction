###############Task: Probability Estimation for Binary Class###############
library(data.table)
library(tree)

load("/Users/baixiao/Desktop/Train_Val_RData/Train10k_fixedsplit.RData") #TrainDat 
load("/Users/baixiao/Desktop/Train_Val_RData/Val10k_fixedsplit.RData") #ValDat

############Create the "LogLoss" evaluation metric##################
LogLoss_fn <- function(PHat, y_act) {       #"Phat": predicted probability of class being "positive"; "y_act": actual class (positive or negative class)
  log_loss <- y_act * log(PHat +0.0001) + (1-y_act) * log(1-PHat +0.0001)      #!!!prevent log() gets "NaN"(add small number)
  return(mean(-log_loss))
}

#fit the entire tree model once first (currently, not including the "ID" column)
FullModel <- paste("click ~", paste(colnames(TrainDat)[-1], collapse=" + "), sep=" ")      #WARNING!!!: NEED TO CHANGE SOME CODE BASED ON WHAT THE ACTUAL DATASET USING LOOKS LIKE!!!
FullModel <- formula(FullModel)

###################Decision Tree####################

#*****available parameters here (in "[..].control()" function): 
#"mincut"(minimum number of observations included in child node);
#"minsize"(smallest node size);
#"mindev"(minimum "within-node" deviance (denoted by the times that of the root node for the node to be split))
TrainDat$click <- as.factor(TrainDat$click)
tc <- tree.control(nrow(TrainDat), minsize=600, mincut=300)         #use default "control" parameters
out <- tree(FullModel, data=TrainDat, control=tc, split="gini")     #temporarily use "deviance" as splitting criteria
Fullsize <- summary(out)$size
Fullsize    
y_pred_prob <- predict(out, newdata=ValDat, type="vector")
LogLoss_fn(y_pred_prob[, 2], as.numeric(ValDat$click))
