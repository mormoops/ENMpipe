###
  ## mining & downloading spatial data: GBIF
  # GBIF: simple query - 
  # choose your favorite species to query the database
sp <- gbif("GENUS", "SPECIES", geo = FALSE)
  # if geo = TRUE only records with lon/lat will be downloaded
