##  common-00-utils

## Local library ----------------------------------
# ## For best compatibility use windows and a local folder containing all the packs
# ##  download from google drive
# local_lib <- '4.0' ## if it's in the local R project folder -- change path whatever
# .libPaths(local_lib)
# .libPaths()

## 0. Preamble ----
sapply(
  c(
    'tidyverse',
    'tmap',
    'sf',
    'socialFrontiers'
  ),
  library, 
  character.only = T
)

