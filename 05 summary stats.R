## 05 Create some auxiliary statistics per ttwa 


##  input -----
cob_ttwa_sf <-
  readRDS(
    'temp/cleaned cob lsoa ttwa.rds'
  )

## Create functions for indicies 
##  2. di
##  we know social frontiers are very correlated with di ---
##  steal the di function from another script

di_func <-
  function(x, y){
    ##  Note: X and Y are counts of the minority and majority residents (order doesn't matter)
    out <-
      sum( abs((x / sum(x)) - (y / sum(y))) )  / 2
    return(out)
  }


# 1. Get stats per ttwa ---------------------------------------------------

# ##  2. di 
# ##  we know social frontiers are very correlated with di ---
# ##  steal the di function from another script
# 
di_func <-
  function(x, y){
    ##  Note: X and Y are counts of the minority and majority residents (order doesn't matter)
    out <-
      sum( abs((x / sum(x)) - (y / sum(y))) )  / 2
    return(out)
  }



ttwa_summary <-
  cob_ttwa_sf %>%
  as.data.frame() %>%
  group_by(ttwa11nm) %>%
  summarise(
    pop = sum(allResidents),
    di = di_func(ukBorn, nonUKBorn) %>% round(2)

  )

ttwa_summary %>% summary


## Save 
ttwa_summary %>%
  saveRDS('temp/05 summary stats.rds')
