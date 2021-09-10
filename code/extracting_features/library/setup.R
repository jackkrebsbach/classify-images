# Load the tidyverse
library(tidyverse)
# data frame manipulation
library(multidplyr)
# string Manipulation
library(stringr)
# Meanshift Image Segmentation
library(reticulate)
Sys.setenv(
  RETICULATE_PYTHON =
    "/opt/anaconda3/envs/meanshift/bin/python"
)
source_python("code/extracting_features/library/meanshift_segmentation.py")
# Texture Calculation
source("code/extracting_features/library/glcm_texture.R")

# Color Space Transformations
source("code/extracting_features/library/color_space_transformation.R")


color_transforms_function <- function(inpaths, transforms, doComp, overWrite){
  
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


texture_calculations_function <- function(inpaths, windows, statistics, layers, doComp, overWrite){
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
  Sys.setenv(
    RETICULATE_PYTHON =
      "/opt/anaconda3/envs/meanshift/bin/python"
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