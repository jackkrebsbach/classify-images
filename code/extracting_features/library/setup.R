knitr::opts_knit$set(root.dir = rprojroot::find_rstudio_root_file())

library(tidyverse)
library(multidplyr)
library(stringr)
library(reticulate)

Sys.setenv(
  RETICULATE_PYTHON = '/Users/krebsbach/pyenvs/reticulate/bin/python3'
  )

source("code/extracting_features/library/glcm_texture.R")
source("code/extracting_features/library/color_space_transformation.R")
source_python("code/extracting_features/library/meanshift_segmentation.py")

color_transforms_function <- function(inpaths, transforms, doComp = FALSE, overWrite = FALSE){
  
  doCompVector <- rep(doComp, length(inpaths))
  
  if(!overWrite & doComp){
    doCompVector <- list(inpaths, transforms) %>% 
      pmap(.f = getColorPath) %>% 
      unlist() %>% 
      file.exists() %>% !.
  } 
  args <- list(inpaths, transforms, doCompVector)
  args %>% 
      pmap(.f = color_transform) %>% 
    unlist() %>% return()
}


texture_calculations_function <- function(inpaths, windows, statistics, layers, doComp = FALSE, overWrite = FALSE){
  doCompVector <- rep(doComp, length(inpaths))
  
  if(!overWrite & doComp){
    doCompVector <- list(inpaths, windows, statistics, layers) %>% 
      pmap(.f = getTexturePath) %>% 
      unlist() %>% 
      file.exists() %>% !.
  } 
  
  args <- list(inpaths, windows, statistics, layers, doCompVector)
  args %>% 
    pmap(.f = calculate_texture) %>% 
    unlist() %>%
    return()
}

image_segmentation_function <- function(inpaths, spatial_radii, range_radii, min_densities, doComp = FALSE, overWrite = FALSE){
 
  #Need to set the environment here because in multidplyr the environment is not copied
   Sys.setenv(
    RETICULATE_PYTHON = '/Users/krebsbach/pyenvs/reticulate/bin/python3'
    )
  source_python("code/extracting_features/library/meanshift_segmentation.py")
  
  doCompVector <- rep(doComp, length(inpaths))
  
  if(!overWrite & doComp){
    doCompVector <- list(inpaths, spatial_radii, range_radii, min_densities) %>% 
      pmap(.f = getSegmentPath) %>% 
      unlist() %>% 
      file.exists() %>% !.
  }
  args <- list(inpaths, spatial_radii, range_radii, min_densities, doCompVector)
  args %>% 
    pmap(.f = segment) %>% 
    unlist() %>% return()
}


