###
  ## mining & downloading spatial data: GBIF
  # GBIF: simple query - 
  # choose your favorite species and query the database
pfal <- gbif("Phyllops", "falcatus", geo = FALSE)
  # if geo = TRUE only records with lon/lat will be downloaded
