##  01: Cleanup raw data sources and save under temp data
##  goal cleanup and save the uk data in the repo

##  1. Get the census data
census_df <- 
  read.csv(
    '../data/census 2011 cob data.csv', skip = 8
  )

##  rename to better names and get a nonukborn category
census_df <-
  census_df %>%
  mutate(
    allResidents = All.usual.residents,
    ukBorn = United.Kingdom,
    nonUKBorn = allResidents - ukBorn,
    accessionBorn = Other.EU..Accession.countries.April.2001.to.March.2011
  )   

## need indicator of type of area
census_df <-
  census_df %>%
  filter(Area != '') %>% # get rid of blank Area
  mutate(
    area_prefix = Area %>% substr(1,4),
    zoneType = ifelse(area_prefix == 'lsoa', 'lsoa2011', 'oa2011')
  ) %>%
    rename(
      zoneID = mnemonic
    )
##  Now filter then save
census_df %>%
  dplyr::select(
    zoneID, zoneType, allResidents:accessionBorn
  ) %>%
  saveRDS(
    file = 'temp/country of birth uk 2011 oa lsoa.rds'
  )

##  2. We can also get some better traction by saving the LSOA files too
##  DO NOT RUN: In the end the files are too big to save (300mb compressed as rds)

##  Read in the lsoa file -- saved locally
lsoa11_sf <-
  st_read(
    dsn = '../data',
    layer = 'LSOA_(Dec_2011)_Boundaries_Generalised_Clipped_(BGC)_EW_V3'
  )

colnames(lsoa11_sf) <-
  colnames(lsoa11_sf) %>% tolower()

## save as rds 
lsoa11_sf %>%
  saveRDS(
   'temp/lsoa 2011 sf.rds'
  )


##  3. TTWA files
##  These will be much smaller

ttwa2011_sf <-
  st_read(
    dsn = '../data',
    layer = 'Travel_to_Work_Areas_(Dec_2011)_UGCB_in_United_Kingdom'
  )

colnames(ttwa2011_sf) <-
  colnames(ttwa2011_sf) %>% tolower()


ttwa2011_sf %>% saveRDS('temp/ttwa 2011.rds')
