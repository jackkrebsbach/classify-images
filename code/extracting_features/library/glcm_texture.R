library(stringr)
library(raster)
library(glcm)
source("code/helpers/getFileInfo.R")

calculate_texture <- function(inpath, window = 5, statistic = "contrast", layer = 1L, doComp = TRUE) {
  #Texture Path to Write
  out_path <- getTexturePath(inpath, window, statistic, layer)
  
  if(!file.exists(inpath)){ doComp <- FALSE; message(paste0(inpath, " does not exist")) }

  if(doComp){
  #Take in file and calculate texture
  inpath %>% 
        raster(band = layer) %>%
         glcm(statistics = statistic, window = c(window, window), 
              shift = list(c(0,1), c(1,1), c(1,0), c(1,-1))) %>%
         writeRaster(filename = out_path, format= "GTiff", overwrite = TRUE)
  }
  
  #Return texture path
  return(out_path)
}

  
