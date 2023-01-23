# 0x: extract areal level data for dashboard app
## Goals:
## 1. simplify objects for quicker loading: https://www.r-bloggers.com/2021/03/simplifying-geospatial-features-in-r-with-sf-and-rmapshaper/
##  2. Convert to long lat ("EPSG:4326")


library(rmapshaper) ## needed for simplifying

# inputs ------------------------------------------------------------------

longlat_crs <- "EPSG:4326"


## Extract 
cob_ttwa_sf <-
  readRDS(
    'temp/cleaned cob lsoa ttwa.rds'
  )


## Clean and put
cob_ttwa_sf <-
  cob_ttwa_sf %>%
  transmute(
    zoneID,
    zoneNm,
    allResidents,
    ukBorn,
    nonUKBorn,
    ttwa = paste(ttwa11nm, '(2011)'),
    geometry
  )


# simplify the geometries and transform to longlat -------------------------------------------------
cob_ttwa_sf <- 
  cob_ttwa_sf %>% st_transform(crs = "EPSG:4326")

cob_ttwa_sf <-
  ms_simplify(cob_ttwa_sf, keep = 0.001,
              keep_shapes = FALSE)
## shrunk from 15mb to 2mb
# cob_ttwa_sf %>% tmap::qtm()


## Save ot 
cob_ttwa_sf %>%
  saveRDS('output/lsoa layer.rds')


# ttwa layer --------------------------------------------------------------

##  3. Load ttwa 
ttwa11_sf <-
  readRDS(
    'temp/ttwa 2011.rds'
  )

## add other stats 

ttwa_summary <-
  readRDS('temp/05 summary stats.rds')

ttwa11_sf <-
  ttwa11_sf %>% 
  left_join(
    ttwa_summary
  )

##  get england and wales only
ttwa11_sf <-
  ttwa11_sf %>%
  mutate(
    country = ttwa11cd %>% substr(1,1)
  ) %>%
  filter(
    country %in% c('E', 'W')
  )
## better name
ttwa11_sf <-
  ttwa11_sf %>%
  mutate(
    ttwa = paste(ttwa11nm, '(2011)')
  )




## convert crs and simplify 
ttwa11_sf <- 
  ttwa11_sf %>% st_transform(crs = "EPSG:4326")

ttwa11_sf <-
  ms_simplify(ttwa11_sf, keep = 0.001,
              keep_shapes = FALSE)

### save 
ttwa11_sf %>% saveRDS('output/ttwa 2011 layer.rds')
