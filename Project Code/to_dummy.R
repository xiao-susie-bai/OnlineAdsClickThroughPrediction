library(fastDummies)
library(data.table)

#data = orginal data(including 'click')
# top_categories list
to_dummy <- function(data = origional_data, top_categories = top_categories_Sample){
  
  # read in the top list
  toplist <- top_categories
  toplist <- apply(toplist, 2, as.factor)
  toplist <- data.table(toplist)
  
  # choose the dataset and assign to DT
  # DT <- copy(ProjectTestData)
  DT <- data
  DT <- data.table(DT)
  
  # remove all other id colums or informativeless colums:
  DT <- DT[ , !c('id', 'device_id', 'device_ip')]
  
  # change all to character type
  DT <- apply(DT, 2, as.factor)
  DT <- apply(DT, 2, trimws)
  # data.table
  DT <- data.table(DT)
  
  # time split to weekdays and hours
  DT[ , Weekdays := weekdays(as.Date(hour, '%y%m%d%H'))]
  DT[ , Hours := substr(hour,7,8)]
  
  DT <- DT[ , -'hour']
  
  
  
  ########Start to Encode##########################
  
  # assign the code
  for(item in colnames(toplist)){
    
    top <- na.omit(toplist[[item]])
    top <- trimws(top)        #force the format
    expr = paste0("DT[ , ",item,":=ifelse(",item," %in% top, ", item, ", 'minor'),]" )
    eval(parse(text=expr))
    
    # 
    # DT[ , (item) := ifelse(item %in% top, item, 'minor'), ]
  }
  
  # create the dummy
  DT <- cbind(DT[, "click"], dummy_columns(DT[, -"click"],remove_selected_columns = T))
  
  drop.cols <- grepl("minor", colnames(DT))
  DT[ ,(colnames(DT)[drop.cols]) := NULL]
  
  try({
    names(DT)[names(DT)=="C20_-1"] <- "C20_m1"
    })
  
  return(DT)
}








