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


# inpit/output ------------------------------------------------------------


## 0. Start with master lookup 
ttwa2011_lookup<- readRDS('temp/ttwa and lsoa lookup.rds')

##  1. lsoa gis file and join to make cob2011_sf ----

lsoa11_sf <-
  readRDS(
    'temp/lsoa 2011 sf.rds'
  )


##  2. Get the pop files from census ----

cob2011_df <-
  readRDS(
    'temp/country of birth uk 2011 oa lsoa.rds'
  )

cob2011_df <-
  cob2011_df %>%
  filter(
    zoneType == 'lsoa2011'
  )

## join data 

master_sf <-
  lsoa11_sf %>% 
  left_join(ttwa2011_lookup %>% select(-objectid)) %>% # objectid isn't a joining var
  left_join(
    cob2011_df,
    by = c('lsoa11cd' = 'zoneID')
  )

master_sf %>% summary

## data cleaning 
master_sf <-
  master_sf %>%
  rename(
    zoneID = lsoa11cd,
    zoneNm = lsoa11nm
  ) %>%
  transmute(
    zoneID,
    zoneNm,
    ttwa11cd,
    ttwa11nm,
    zoneType,
    allResidents,
    ukBorn,
    nonUKBorn
  )


# data check:  ------------------------------------------------------------
# ##  Check panel for mutually exclusive lsoa to ttwa (not quite)
# cob_ttwa_sf$lsoa11nm %>% duplicated() %>% sum ## 4277 duplicates -- liveable
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