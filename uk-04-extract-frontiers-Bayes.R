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
sfBorders_list$error %>%
  discard(is.null)
# $Bristol
# <Rcpp::eval_error in CPL_geos_op2(op, st_geometry(x), st_geometry(y)): Evaluation error: TopologyException: Input geom 0 is invalid: Ring Self-intersection at or near point 360882.91511309094 171106.81981253525 at 360882.91511309094 171106.81981253525.>
#   
#   $Burnley
# <Rcpp::eval_error in CPL_geos_op2(op, st_geometry(x), st_geometry(y)): Evaluation error: TopologyException: Input geom 0 is invalid: Ring Self-intersection at or near point 385903.88259071077 439853.55665713502 at 385903.88259071077 439853.55665713502.>
#   
#   $Penzance
# <simpleError in frontier_as_sf(y, silent = T): Not a frontier_model object; please run frontier_detect()>
#   
#   $Yeovil
# <Rcpp::eval_error in CPL_geos_op2(op, st_geometry(x), st_geometry(y)): Evaluation error: TopologyException: Input geom 1 is invalid: Ring Self-intersection at or near point 362040.18361719657 114934.77847173659 at 362040.18361719657 114934.77847173659.>

## Restructure as spatial dataframe.... 

## Issue: this isn't working properly
# out_results <-
#   sfBorders_list$result %>%
#   discard(is.null) %>%
#   bind_rows(.id = 'ttwa')

# 3. Save  ----------------------------------------------------------------

sfBorders_list$result %>%
  saveRDS(
    'output/frontier borders layer.rds'
  )


