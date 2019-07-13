# -------------------------------------------------------------------------
# occ - download and filter
# mauricio vancine - mauricio.vancine@gmail.com
# 10-07-2019
# -------------------------------------------------------------------------

# preparate r -------------------------------------------------------------
# memory
rm(list = ls())

# packages
library(CoordinateCleaner)
library(landscapetools)
library(lubridate)
library(raster)
library(rgdal)
library(rnaturalearth)
library(rnaturalearthdata)
library(rnaturalearthhires)
library(sf)
library(spocc)
library(taxize)
library(tidyverse)

# informations
# https://ropensci.org/
# https://ropensci.github.io/spocc/
# https://cloud.r-project.org/web/packages/spocc/index.html
# https://cloud.r-project.org/web/packages/spocc/vignettes/spocc_vignette.html
# https://ropensci.github.io/taxize/
# https://cloud.r-project.org/web/packages/taxize/index.html
# https://cloud.r-project.org/web/packages/taxize/vignettes/taxize_vignette.html
# https://ropensci.github.io/CoordinateCleaner/
# https://cloud.r-project.org/web/packages/CoordinateCleaner/index.html
# https://ropensci.github.io/CoordinateCleaner/articles/Tutorial_Cleaning_GBIF_data_with_CoordinateCleaner.html
# https://github.com/ropensci/rnaturalearth
# https://www.naturalearthdata.com/
# https://github.com/r-spatial/sf

# directory
path <- "/home/mude/data/curso_mde_9cbh"
setwd(path)
dir()

# download occurrences ----------------------------------------------------
# species
sp <- c("Haddadus binotatus")
sp

# synonyms
syn <- taxize::synonyms(x = sp, db = "itis") %>% 
  taxize::synonyms_df() %>% 
  dplyr::select(.id, syn_name)
syn

# combine
sp_syn <- c(sp, syn$syn_name) %>% unique
sp_syn

# bases for download
db <- c("gbif",       # Global Biodiversity Information Facility (https://www.gbif.org/)
        "ecoengine",  # Berkeley Initiative for Global Change Biology (https://ecoengine.berkeley.edu/)
        "inat",       # iNaturalist (https://www.inaturalist.org/)
        "vertnet",    # VertNet (http://vertnet.org/)
        "ebird",      # eBird (https://ebird.org/)
        "idigbio",    # Integrated Digitized Biocollections (https://www.idigbio.org/)
        "obis",       # Ocean Biogeographic Information System (www.iobis.org)
        "ala",        # Atlas of Living Australia (https://www.ala.org.au/)
        "bison")       # Biodiversity Information Serving Our Nation (https://bison.usgs.gov)
db

# occ download
occ <- spocc::occ(query = sp_syn, 
                  from = db, 
                  # ebirdopts = list(key = ""), # make key in https://ebird.org/api/keygen
                  has_coords = TRUE, 
                  limit = 1e6)
occ

# get data
occ_data <- occ %>%
  spocc::occ2df() %>% 
  dplyr::mutate(longitude = as.numeric(longitude),
                latitude = as.numeric(latitude),
                year = lubridate::year(date),
                base = prov) %>% 
  dplyr::select(name, longitude, latitude, year, base)
occ_data

# limit brazil
br <- rnaturalearth::ne_states(country = "Brazil", returnclass = "sf")
br

# map
ggplot() +
  geom_sf(data = br) +
  geom_point(data = occ_data, aes(x = longitude, y = latitude)) +
  theme_bw()

# taxonomic filter --------------------------------------------------------
# gnr names
gnr <- taxize::gnr_resolve(sp_syn)
gnr

# adjust names
gnr_tax <- gnr %>% 
  dplyr::mutate(species = sp %>% stringr::str_to_lower() %>% stringr::str_replace(" ", "_")) %>% 
  dplyr::select(species, matched_name) %>%
  dplyr::bind_rows(tibble::tibble(species = sp %>% stringr::str_to_lower() %>% stringr::str_replace(" ", "_"),
                                  matched_name = c(sp_syn, 
                                                   sp_syn %>% stringr::str_to_title(),
                                                   sp_syn %>% stringr::str_to_lower(),
                                                   sp_syn %>% stringr::str_to_upper()))) %>% 
  dplyr::distinct() %>% 
  dplyr::arrange(matched_name)
gnr_tax

# confer
occ_data %>%
  dplyr::select(name) %>% 
  table %>% 
  tibble::as_tibble()

# taxonomic filter
occ_data_tax <- dplyr::inner_join(occ_data, gnr_tax, c(name = "matched_name")) %>% 
  dplyr::arrange(name) %>% 
  dplyr::select(name, species, everything())
occ_data_tax

# confer
occ_data$name %>% 
  table %>% 
  tibble::as_tibble()

occ_data_tax$name %>% 
  table %>% 
  tibble::as_tibble()

# map
ggplot() +
  geom_sf(data = br) +
  geom_point(data = occ_data, aes(x = longitude, y = latitude)) +
  geom_point(data = occ_data_tax, aes(x = longitude, y = latitude), color = "red") +
  theme_bw()

# date filter -------------------------------------------------------------
# verify
occ_data_tax$year %>% 
  table(useNA = "always")

# year > 1960 and < 2019
occ_data_tax_date <- occ_data_tax %>% 
  dplyr::filter(year > 1960, year <= 2019, !is.na(year)) %>% 
  dplyr::arrange(year)
occ_data_tax_date

# verify
occ_data_tax$year %>% 
  table(useNA = "always")

occ_data_tax_date$year %>% 
  table(useNA = "always")

ggplot() + 
  geom_histogram(data = occ_data_tax_date, aes(year), color = "darkred", fill = "red", bins = 10, alpha = .5) +
  theme_bw()

# map
ggplot() +
  geom_sf(data = br) +
  geom_point(data = occ_data, aes(x = longitude, y = latitude)) +
  geom_point(data = occ_data_tax_date, aes(x = longitude, y = latitude), color = "red") +
  theme_bw()

# spatial filter ----------------------------------------------------------
# remove na
occ_data_na <- occ_data_tax_date %>% 
  tidyr::drop_na(longitude, latitude)
occ_data_na

# flag data
flags_spatial <- CoordinateCleaner::clean_coordinates(
  x = occ_data_na, 
  species = "species",
  lon = "longitude", 
  lat = "latitude",
  seas_scale = 10, 
  tests = c("capitals", # radius around capitals
            "centroids", # radius around country and province centroids
            "duplicates", # records from one species with identical coordinates
            "equal", # equal coordinates
            "gbif", # radius around GBIF headquarters
            "institutions", # radius around biodiversity institutions
            "outliers", # records far away from all other records of this species
            "seas", # in the sea
            "urban", # within urban area
            "validity", # outside reference coordinate system
            "zeros" # plain zeros and lat = lon 
  )
)

# results
#' TRUE = clean coordinate entry 
#' FALSE = potentially problematic coordinate entries
flags_spatial %>% head
summary(flags_spatial)
flags_spatial$.summary

# exclude records flagged by any test
occ_data_tax_date_spa <- occ_data_na %>% 
  dplyr::filter(flags_spatial$.summary == TRUE)
occ_data_tax_date_spa

# resume data
occ_data_na$species %>% 
  table

occ_data_tax_date_spa$species %>% 
  table

# map
ggplot() +
  geom_sf(data = br) +
  geom_point(data = occ_data_na, aes(x = longitude, y = latitude)) +
  geom_point(data = occ_data_tax_date_spa, aes(x = longitude, y = latitude), color = "red") +
  theme_bw()

# limit filter
occ_data_tax_date_spa_lim <- occ_data_tax_date_spa %>% 
  dplyr::mutate(x = longitude, y = latitude) %>% 
  sf::st_as_sf(coords = c("x", "y"), crs = 4326) %>% 
  st_intersects(., sf::st_union(br), sparse = FALSE) %>% 
  tibble::as_tibble() %>% 
  dplyr::select(V1) %>%
  dplyr::rename(lim = V1) %>% 
  dplyr::bind_cols(occ_data_tax_date_spa, .) %>% 
  dplyr::filter(lim == TRUE) %>% 
  dplyr::select(-lim)
occ_data_tax_date_spa_lim

# map
ggplot() +
  geom_sf(data = br) +
  geom_point(data = occ_data, aes(x = longitude, y = latitude)) +
  geom_point(data = occ_data_tax_date_spa_lim, aes(x = longitude, y = latitude), color = "red") +
  theme_bw()

# verify filters ----------------------------------------------------------
occ_data_tax$species %>% table
occ_data_tax_date$species %>% table
occ_data_tax_date_spa$species %>% table
occ_data_tax_date_spa_lim$species %>% table

# export ------------------------------------------------------------------
# directory
dir.create("02_occ")
setwd("02_occ")

# export
readr::write_csv(occ_data, paste0("occ_spocc_bruto_", lubridate::today(), ".csv"))
readr::write_csv(occ_data_tax_date_spa_lim, paste0("occ_spocc_filtro_taxonomico_data_espatial_limite.csv"))

# end ---------------------------------------------------------------------