# 4. Extract frontiers  ---------------------------------------------------
##  This extract frontiers from the Dean et al model

##  Input

sfModels_path <- 'temp/uk frontier model list - dan.rds'

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
        
        
        ### Step 1: Extract the edgelist only and get the sd(phi_a - phi_b)
        ## for all borders including frontiers
        out <-
          frontier_as_sf(
            y,
            non_frontiers = T,
            edgelistOnly = T,
            silent = T
          )
        
        sd_diff_phi <- sd(out$phi - out$phi.1)
        ## step 2: extract the actual frontiers only as geometry
        
        out <-
          frontier_as_sf(
            y,
            silent = T
          )
        
        
        out <-
          out %>%
          transmute(
            zoneID_a = y$data$zoneID[id],
            zoneID_b = y$data$zoneID[id.1],
            phi_a = phi,
            phi_b = phi.1,
            diff_phi = abs(phi - phi.1),
            std_diff_phi = diff_phi / sd_diff_phi ,
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
sfBorders_list$error %>%
  discard(is.null)

## Issue: 
## error for bideford (maybe delete)


# 3. Save  ----------------------------------------------------------------

sfBorders_list$result %>%
  saveRDS(
    'output/frontier borders layer - dan.rds'
  )


