# 0x: extract areal level data for dashboard app

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
    zoneNm = lsoa11nm,
    allResidents,
    ukBorn,
    nonUKBorn,
    ttwa = paste(ttwa11nm, '(2011)'),
    geometry
  )


## Save ot 
cob_ttwa_sf %>%
  saveRDS('output/lsoa layer.rds')


# ttwa layer --------------------------------------------------------------

ttwa2011_sf <- readRDS('temp/ttwa 2011.rds')
ttwa2011_sf %>% saveRDS('output/ttwa 2011 layer.rds')
