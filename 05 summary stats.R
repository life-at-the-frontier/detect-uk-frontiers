## 05 Create some auxiliary statistics per ttwa 

## extra libraries 
library(toOrdinal)

##  input -----
cob_ttwa_sf <-
  readRDS(
    'temp/cleaned cob lsoa ttwa.rds'
  )


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
    pop_foreign_born = sum(nonUKBorn),
    prop_foreign_born = pop_foreign_born / pop %>% round(3), 
    di = di_func(ukBorn, nonUKBorn) %>% round(2)

  )


# 3. frontier concentration -----------------------------------------------

sfModel_list <-
  readRDS(
  'temp/uk frontier model list.rds'
)

extract_nborders <- 
  function(frontier_model){
    obj <- frontier_model %>% summary
    return(obj$n_borders) # frontiers vs 
    
  }

n_borders <- sfModel_list %>% 
  map(
    .f = function(x) safely(extract_nborders, otherwise = NA)(x)$result
    ) 
# get frontiers  ------------

sfBorders_list <- 
  readRDS(
    'output/frontier borders layer.rds'
  )

extract_nSubstantial <-
  function(x){
    x %>% filter(std_diff_phi > 1.96) %>% nrow
  }


n_substantial_frontiers <-
  sfBorders_list %>%
  map(
    .f = function(x) safely(extract_nSubstantial, otherwise = NA)(x)$result
  )


## confirm names are the same 
identical(names(sfBorders_list), names(sfModel_list))

frontier_stat_tab <-
  data.frame(
    ttwa11nm = names (sfModel_list),
    n_borders = n_borders %>% unlist,
    n_substantial_frontiers = n_substantial_frontiers %>% unlist
  ) %>%
  mutate(
    frontier_stat = n_substantial_frontiers/ n_borders %>% round(3)
  )

ttwa_summary <-
  ttwa_summary %>%
  left_join(frontier_stat_tab)

## 3. Create ranks -----------------
ttwa_summary <-
  ttwa_summary %>%
  mutate(
    frontier_rank = (frontier_stat * -1) %>% rank(ties.method = 'first'),
    di_rank = (di *-1) %>% rank(ties.method = 'first'), ## low rank = hi segregation
    
    di_rank_txt = di_rank %>% toOrdinal(),
    frontier_rank_txt = frontier_rank %>% toOrdinal()
  )

## NAs are ranked last 

## Save 
ttwa_summary %>%
  saveRDS('temp/05 summary stats.rds')
