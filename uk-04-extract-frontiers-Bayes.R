# 4. Extract frontiers  ---------------------------------------------------
##  This extract frontiers from the Dean et al model

##  Input

sfModels_path <- 'temp/uk frontier model list.rds'



# 1. Load in models -------------------------------------------------------
sfModel_list <- 
  sfModels_path %>%
  readRDS

# 2. Extract the frontiers ------------------------------------------------

## create the safe function
sfBorders_list <-
  map2(## paired inputs
    .x = names(sfModel_list),
    .y = sfModel_list,
    ## define function
    .f =
      safely(function(x, y) {
        x %>% paste('in progress') %>% print()
        
        out <-
          frontier_as_sf(
            y,
            silent = T
          )
        
        # ## adhoc (can remove without effect); save LSOA11cd
        out <-
          out %>%
          transmute(
            zoneID_a = y$data$zoneID[id],
            zoneID_b = y$data$zoneID[id.1],
            phi_a = phi,
            phi_b = phi.1,
            diff_phi = abs(phi - phi.1),
            std_diff_phi = diff_phi / sd( (phi - phi.1) ),
            geometry = geometry
          )

        return(out)
        
      })
  )

## map2 drops names so reinsert in the names
names(sfBorders_list) <- 
  names(sfModel_list)

## transpose 

sfBorders_list <-
  sfBorders_list %>% transpose

##  reported errors: 
sfBorders_list$error
## Yeovil has errors 
##  burnley, 

# 3. Save  ----------------------------------------------------------------

sfBorders_list$result %>%
  saveRDS(
    'temp/uk frontier borders list.rds'
  )


