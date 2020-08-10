
trim_dummy <- function(NewDummy = NewDT, TrainDummy = TrainDT){
  
  #trim extra dummy vars in Vali or Test
  
  TrainDummy <- data.table(TrainDummy)
  NewDummy <- data.table(NewDummy)
  
  train.col <- colnames(TrainDummy)
  new.col <- colnames(NewDummy)
  
  extra_col <- setdiff(new.col, train.col)
  
  NewDummy[ , (extra_col) := NULL]
  
  absent_col <- setdiff(train.col, new.col)
  
  NewDummy[ , (absent_col) := 0]     #***force all additional columns added to the dummy validation data as "0"s
  
  ord <- names(TrainDummy)
  
  setcolorder(NewDummy, ord)
  
  return(NewDummy)
}
