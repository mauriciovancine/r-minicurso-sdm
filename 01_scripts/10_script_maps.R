# -------------------------------------------------------------------------
# maps
# mauricio vancine - mauricio.vancine@gmail.com
# 27-06-2019
# -------------------------------------------------------------------------

# preparate r -------------------------------------------------------------
# memory
rm(list = ls())

# packages
library(ggspatial)
library(raster)
library(rgdal)
library(rnaturalearth)
library(tidyverse)

# directory
path <- "/home/mude/data/curso_mde_9cbh"
setwd(path)
dir()

# import data -------------------------------------------------------------
# occ
setwd("02_occ")
occ <- readr::read_csv("occ_spocc_filtro_taxonomico_data_espatial_limite_oppc.csv")
occ

# brazil
br <- rnaturalearth::ne_states(country = "Brazil", returnclass = "sf")
br
plot(br[1])

# names
na <- c("Ensemble weighted average", "Ensemble weighted average - LPT", "Ensemble weighted average - P10", 
        "Ensemble weighted average - P20", "Ensemble frequency", "Ensemble frequency - LPT", 
        "Ensemble frequency - P10", "Ensemble frequency - P20")
na

# figs --------------------------------------------------------------------
# plot
for(i in occ$species %>% unique){
  
  # information
  sp <- i %>% stringr::str_to_title() %>% stringr::str_replace("_", " ")
  print(sp)
  
  # ensembles
  setwd(path)
  setwd(paste0("05_sdm_multiple/", i))
  
  # import
  ens <- dir(pattern = "ensemble_", recursive = TRUE) %>% 
    stringr::str_subset(".tif$") %>% 
    raster::stack()
  
  # directory
  dir.create("04_maps")
  setwd("04_maps")
  
  # map
  for(j in ens %>% raster::nlayers() %>% seq){
    
    map <- ggplot() +
      geom_raster(data = raster::rasterToPoints(ens[[j]]) %>% tibble::as_tibble() %>% dplyr::rename(ens = names(ens[[j]])),
                  aes(x, y, fill = ens)) +
      geom_sf(data = br, fill = NA, color = "gray30") +
      geom_point(data = occ, aes(longitude, latitude, color = species %>% str_to_title() %>% sub("_", " ", .)), size = 2, alpha = .7) +
      scale_color_manual(values = "black", guide = guide_legend(order = 1)) +
      scale_fill_gradientn(colours = wesanderson::wes_palette("Zissou1", n = 100, type = "continuous")) +
      coord_sf(xlim = c(-74, -35)) +
      labs(x = "Longitude", y = "Latitude", fill = "Adequabilidade", color = "Ocorrências", 
           title = bquote(bold(bolditalic(.(sp)) - .(na[j])))) +
      annotation_scale(location = "br", width_hint = .3) +
      annotation_north_arrow(location = "br", which_north = "true", 
                             pad_x = unit(0, "cm"), pad_y = unit(.8, "cm"),
                             style = north_arrow_fancy_orienteering) +
      theme_bw() +
      theme(title = element_text(size = 12, face = "bold"),
            legend.title = element_text(size = 15, face = "bold"),
            legend.background = element_rect(fill = "white",
                                             size = 0.5, 
                                             linetype = "solid", 
                                             colour = "black"),
            axis.title = element_text(size = 15, face = "plain"),
            legend.position = c(.2, .25))
    map
    
    # export
    ggsave(paste0("map_", names(ens[[j]]), ".tiff"), map, wi = 20, he = 20, un = "cm", dpi = 300, comp = "lzw")
    
  }
  
}

# end ---------------------------------------------------------------------