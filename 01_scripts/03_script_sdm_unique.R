# -------------------------------------------------------------------------
# sdm - unique algorithms
# mauricio vancine - mauricio.vancine@gmail.com
# 17-07-2019
# -------------------------------------------------------------------------

# preparate r -------------------------------------------------------------
# memory
rm(list = ls())

# packages
library(dismo)
library(raster)
library(rgdal)
library(tidyverse)
library(wesanderson)

# information
# https://cran.r-project.org/web/packages/dismo/index.html
# https://biodiversityinformatics.amnh.org/open_source/maxent/
# https://rspatial.org/sdm/
# https://cran.r-project.org/web/packages/dismo/vignettes/sdm.pdf

# directory
path <- "/home/mude/data/gitlab/course-sdm"
setwd(path)
dir()

# import data -------------------------------------------------------------
# occ
setwd("02_occ")
occ <- readr::read_csv("occ_spocc_filtro_taxonomico_data_espatial_limite_oppc.csv")
occ

# var
setwd(path); setwd("03_var"); 
var <- dir(pattern = "tif$") %>% 
  raster::stack()
plot(var)

# map
landscapetools::show_landscape(var$wc20_brasil_res05g_bio03) +
  geom_polygon(data = var$wc20_brasil_res05g_bio03 %>% raster::rasterToPolygons() %>% fortify, 
               aes(x = long, y = lat, group = group), fill = NA, color = "black", size = .1) +
  geom_point(data = occ, aes(longitude, latitude), size = 3, alpha = .7) +
  theme(legend.position = "none")

# enms --------------------------------------------------------------------
# diretory
setwd(path)
dir.create("04_sdm_unico")
setwd("04_sdm_unico")

# preparate data ----------------------------------------------------------
# selecting presence and pseudo-absence/background data
pr_specie <- occ %>% 
  dplyr::select(longitude, latitude) %>% 
  dplyr::mutate(id = seq(nrow(.)))
pr_specie

pa_specie <- dismo::randomPoints(mask = var, n = nrow(pr_specie)) %>% # mask - limite de amostragem e n - pontos de pseudo-ausencia
  tibble::as_tibble() %>%
  dplyr::rename(longitude = x, latitude = y) %>% 
  dplyr::mutate(id = seq(nrow(.)))
pa_specie

landscapetools::show_landscape(var$pc01) +
  geom_point(data = pr_specie, aes(longitude, latitude), size = 3, alpha = .7, color = "red") +
  geom_point(data = pa_specie, aes(longitude, latitude), size = 3, alpha = .7, color = "blue") +
  theme(legend.position = "none")

# selecting train and test ids
pr_sample_train <- pr_specie %>% 
  dplyr::sample_frac(.7) %>% 
  dplyr::select(id) %>% 
  dplyr::pull()
pr_sample_train

pa_sample_train <- pa_specie %>% 
  dplyr::sample_frac(.7) %>% 
  dplyr::select(id) %>% 
  dplyr::pull()
pa_sample_train

landscapetools::show_landscape(var$wc20_brasil_res05g_bio03) +
  geom_polygon(data = var$wc20_brasil_res05g_bio03 %>% raster::rasterToPolygons() %>% fortify, 
               aes(x = long, y = lat, group = group), fill = NA, color = "black", size = .1) +
  geom_point(data = pr_specie %>% dplyr::filter(id %in% pr_sample_train), 
             aes(longitude, latitude), size = 3, alpha = .7, color = "red", pch = 19) +
  geom_point(data = pr_specie %>% dplyr::filter(!id %in% pr_sample_train), 
             aes(longitude, latitude), size = 3, alpha = .7, color = "red", pch = 8) +
  geom_point(data = pa_specie %>% dplyr::filter(id %in% pa_sample_train), 
             aes(longitude, latitude), size = 3, alpha = .7, color = "blue", pch = 19) +
  geom_point(data = pa_specie %>% dplyr::filter(!id %in% pa_sample_train), 
             aes(longitude, latitude), size = 3, alpha = .7, color = "blue", pch = 8) +
  theme(legend.position = "none")

# preparating train and test data
train <- dismo::prepareData(x = var, 
                            p = pr_specie %>% dplyr::filter(id %in% pr_sample_train) %>% dplyr::select(longitude, latitude), 
                            b = pa_specie %>% dplyr::filter(id %in% pa_sample_train) %>% dplyr::select(longitude, latitude)) %>% 
  na.omit
train
head(train)

test <- dismo::prepareData(x = var, 
                           p = pr_specie %>% dplyr::filter(!id %in% pr_sample_train) %>% dplyr::select(longitude, latitude), 
                           b = pa_specie %>% dplyr::filter(!id %in% pa_sample_train) %>% dplyr::select(longitude, latitude)) %>% 
  na.omit
test
head(test)

# fit model --------------------------------------------------------------
# 1 bioclim
# 1.1 fit
bioclim_fit <- dismo::bioclim(x = train[train$pb == 1, -1])	
plot(bioclim_fit)
dismo::response(bioclim_fit)

# 1.2 prediction
bioclim_proj <- dismo::predict(var, bioclim_fit, progress = "text")	
bioclim_proj

# map
landscapetools::show_landscape(bioclim_proj)

# model export
raster::writeRaster(x = bioclim_proj, 
                    filename = "sdm_bioclim", 
                    format = "GTiff", 
                    options = c("COMPRESS=DEFLATE"), 
                    overwrite = TRUE)

# 1.3 evaluation
bioclim_eval <- dismo::evaluate(p = test %>% dplyr::filter(pb == 1) %>% dplyr::select(-1),  
                                a = test %>% dplyr::filter(pb == 0) %>% dplyr::select(-1), 
                                model = bioclim_fit)
bioclim_eval 

# roc
plot(bioclim_eval, "ROC")

# auc
bioclim_eval@auc

# tss
bioclim_eval_thr_id_spec_sens <- which(bioclim_eval@t == dismo::threshold(bioclim_eval, "spec_sens"))
bioclim_eval_thr_id_spec_sens

bioclim_eval_tss_spec_sens <- bioclim_eval@TPR[bioclim_eval_thr_id_spec_sens] + bioclim_eval@TNR[bioclim_eval_thr_id_spec_sens] - 1
bioclim_eval_tss_spec_sens

# threshold cut
# sum of the sensitivity and specificity
bioclim_eval_thr$spec_sens

bioclim_proj_thr_spec_sens <- bioclim_proj >= bioclim_eval_thr$spec_sens
bioclim_proj_thr_spec_sens

landscapetools::show_landscape(bioclim_proj_thr_spec_sens, discrete = TRUE) +
  geom_polygon(data = var$wc20_brasil_res05g_bio03 %>% raster::rasterToPolygons() %>% fortify, 
               aes(x = long, y = lat, group = group), fill = NA, color = "black", size = .1) +
  geom_point(data = pr_specie %>% dplyr::filter(id %in% pr_sample_train), 
             aes(longitude, latitude), size = 3, alpha = .7, color = "red", pch = 19) +
  geom_point(data = pr_specie %>% dplyr::filter(!id %in% pr_sample_train), 
             aes(longitude, latitude), size = 3, alpha = .7, color = "red", pch = 8) +
  geom_point(data = pa_specie %>% dplyr::filter(id %in% pa_sample_train), 
             aes(longitude, latitude), size = 3, alpha = .7, color = "blue", pch = 19) +
  geom_point(data = pa_specie %>% dplyr::filter(!id %in% pa_sample_train), 
             aes(longitude, latitude), size = 3, alpha = .7, color = "blue", pch = 8) +
  theme(legend.position = "none")

# end ---------------------------------------------------------------------
