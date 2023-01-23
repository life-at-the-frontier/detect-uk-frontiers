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

##  3. Load ttwa 

ttwa11_sf <-
  readRDS(
    'temp/ttwa 2011.rds'
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

##  smaller buffer; for catching lsoa in ttwa
ttwa11_sf <-
  ttwa11_sf %>% st_buffer(-1)

## 4. Join the cob and ttwa data

cob_ttwa_sf <-
  cob2011_sf %>%
  st_join(ttwa11_sf)



ttwa2011_sf <- readRDS('temp/ttwa 2011.rds')
ttwa2011_sf %>% saveRDS('output/ttwa 2011 layer.rds')
