## check dan's cob data 

##  3. Analysis of UK social frontiers

##  1. load data-----
cob_ttwa_sf <-
  readRDS(
#    'temp/cleaned cob lsoa ttwa.rds'
    "temp/dan's 2021 lsoas.rds"
  )

cob_ttwa_sf %>% summary


# 2. Subsetting (crucial) -------------------------------------------------
##  The UK file of TTWA is very big best to subset by DI or pop or something 

# Example
# ##  First: Create the variable to subset yb
# ##  Choices:
# ##  1. population table 
# ##  incase we want to reduce to norway and sweden's 
# 
# ##  2. di 
# ##  we know social frontiers are very correlated with di ---
# ##  steal the di function from another script
# 
# di_func <-
#   function(x, y){
#     ##  Note: X and Y are counts of the minority and majority residents (order doesn't matter)
#     out <-
#       sum( abs((x / sum(x)) - (y / sum(y))) )  / 2
#     return(out)
#   }
# 
# 
# ttwa_summary <-
#   cob_ttwa_sf %>%
#   as.data.frame() %>%
#   group_by(ttwa11nm) %>%
#   summarise(
#     allResidents = sum(allResidents),
#     di = di_func(ukBorn, nonUKBorn)
#     
#   )
# 
# ##  arrange by di
# 
# ttwa_summary <-
#   ttwa_summary %>%
#   arrange(
#      -di
#   )
# 
# ttwa_summary  ## usual suspects
# ttwa_summary %>% summary ## so we can specify
# 
# ##  Second: actually subset the data
# ##  For now we can specify pop over top quartile of di
# 
# filter_ttwa <-
#   ttwa_summary # %>%
#   # filter(
#   #   
#   # di > quantile(di, 0.95) 
#   # 
#   # ) 
# 
# filter_ttwa
# filter_ttwa %>% summary
# ##  We get 42 ttwas @0.75
# ##  we get 17 ttwa @0.90

model_sf <-
  cob_ttwa_sf 


# 3. Running the model over forLoop ---------------------------------------
##  Output is a list of models

## wrap the function up in an error catcher 
## Example of error catching
# safe_log <- safely(log)
# safe_log(10)
# safe_log("a")
# 
# list("a", 10, 100) %>%
#   map(safe_log) %>%
#   transpose()
model_sf$ttwa11nm %>% table

# bugfix penzance ---------------------------------------------------------
## Need to omit isle of sicilly
# library(tmap)
# tmap_mode('view')
# model_sf %>% filter(ttwa11nm %in% c('Penzance')) %>% tmap::qtm() ## right Penzance has an island off the edge 
# End

output_list <-
  model_sf %>%
  filter(
    !(zoneNm %in% 'Isles of Scilly 001A') ## this isle has no neighbour creating issues
  ) %>%
  split(.$ttwa11nm) %>%
  map(.f =
        safely(function(this_data) {
          this_data$ttwa11nm[1] %>% paste('in progress') %>% print
          
          frontier_detect(data = this_data,
                          y = 'nonUKBorn',
                          n.trials = 'allResidents')
        }))

output_list <-
  output_list %>% transpose()

# check errors 
output_list$error %>%
  discard(is.null)


# 4. Save -----------------------------------------------------------------

output_list$result %>%
  saveRDS(
    'temp/uk frontier model list - dan.rds'
  )

##  Done


