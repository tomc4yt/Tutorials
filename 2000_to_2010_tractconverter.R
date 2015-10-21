library(plyr)
library(reshape2)
library(data.table)
setwd("C:/Users/Thomas/Documents/github/03-gentrifuge/data")

convert_to_2010 <- function(df,census_2000_file, crosswalk_file ){
  census2000 <- read.csv(census_2000, header=T, skip=1,
                         colClasses=c('Id2'='character')) # 2000 Census data

  census2000 <- subset(census2000, grepl(Id2, pattern = "^11001"))
  census2000 <- dplyr::select(census2000, -Id)
  
  # Merge 2000 census to Crosswalk data
  xwalk <- plyr::arrange(read.csv(crosswalk_file,
                                  colClasses=c('character', 'character')), trtid10)
  xwalk <- within(xwalk, weight <- as.numeric(weight))
  xwalk <- subset(xwalk, grepl(trtid10, pattern = "^11001"))
  
  
  setnames(census2000, "Id2", "trtid00")
  
  # Subset the crosswalk table to just those tracts in our census data
  xwalk <- subset(xwalk, trtid00 %in% intersect(census2000$trtid00, xwalk$trtid00),
                  select=c(trtid00, trtid10, weight))
  
  # Interpolate the 2000 census tracts to 2010 census tracts by a weighted linear combination
  temp <- melt(join(xwalk, census2000, by=c('trtid00')),
               id.vars=c('trtid00', "Geography", 'trtid10', 'weight'))
  temp <- within(temp, value <- value * weight) # Scale the census measures by Brown et al.'s weights
  
  # Recast 2010 census tracts as a sum of the 2000 census measures
  census2000.as.2010 <- within(dcast(temp, trtid10 ~ variable, fun.aggregate=sum, value.var='value'), Geo_FIPS <- trtid10)
  
  return(census2000.as.2010)
}


normalize_census <- function(df, population.vars, target.vars){
  
  # population.vars : variable used to normalize data. Should be the total population
  # target.vars : variables tonormalize
  
  for (column in target.vars){
    df[column] <- df[column] / df[population.vars]
  }
  return(df)
}




