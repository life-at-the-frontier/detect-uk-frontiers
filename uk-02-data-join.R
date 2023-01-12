##  02 UK (well England and Wales) social frontiers
##  README: Every file needed is committed in the repo except the lsoa file shp which
##  has to be manually placed in the /data folder

## 0. Preamble ----
sapply(
  c(
    'tidyverse',
    'tmap',
    'sf',
    'socialFrontiers'
  ),
  library, character.only = T
)


##  1. Get the pop files from census ----

cob2011_df <-
  readRDS(
    'temp/country of birth uk 2011 oa lsoa.rds'
  )

cob2011_df <-
  cob2011_df %>%
  filter(
    zoneType == 'lsoa2011'
  )

##  2. lsoa gis file and join to make cob2011_sf ----

lsoa11_sf <-
  readRDS(
    'temp/lsoa 2011 sf.rds'
  )

cob2011_sf <-
  lsoa11_sf %>%
  left_join(
    cob2011_df,
    by = c('lsoa11cd' = 'zoneID')
  )

cob2011_sf <-
  cob2011_sf %>% 
  rename(
    zoneID = lsoa11cd
  )

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



# data check:  ------------------------------------------------------------
# ##  Check panel for mutually exclusive lsoa to ttwa (not quite)
# cob_ttwa_sf$lsoa11nm %>% duplicated() %>% sum ## 4 duplicate -- liveable
# 
# ##  Where are they?
# cob_ttwa_sf %>%
#   filter(
#     lsoa11nm %>% duplicated
#   ) 
# ##  seem okay

##  5. Save the file! ----

cob_ttwa_sf %>% 
  saveRDS(
    file = 'temp/cleaned cob lsoa ttwa.rds'
  )

####