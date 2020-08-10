LogLoss <- function(PHat, y_act) {       #"Phat": predicted probability of class being "positive"; "y_act": actual class (positive or negative class)
  log_loss <- y_act * log(PHat +0.0001) + (1-y_act) * log(1-PHat +0.0001)      #!!!prevent log() gets "NaN"(add small number)
  return(mean(-log_loss))
}