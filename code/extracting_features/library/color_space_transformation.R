library(raster)
library(tidyverse)
library(magick)
library(imager)
source("code/helpers/getFileInfo.R")

# Define custom color space transforms here (transformations not in the imager package)
# color_transform takes function names from imager package
# "RGBtoHSV" "RGBtoLab" "RGBtoHSL" "RGBtoHSI" "RGBtoYCbCr" "RGBtoYUV"

color_transform <- function(inpath, transform = "RGBtoHSV", doComp = TRUE) {
  
  #Get Path to Write
  out_path <- getColorPath(inpath, transform)
  if(!file.exists(inpath)){ doComp <- FALSE; message(paste0(inpath, " does not exist")) }
  
  if (doComp) {
    # read in image with imager
    #Cant get working with imager so trying magick
    image <- inpath %>%  magick::image_read() %>% imager::magick2cimg()
    #image <- inpath %>% imager::load.image()
    # get transform from environment
    clr_transform <- transform %>% get()
    
    # do transform
    image %>%
      clr_transform() %>%
      drop() %>%
      as.array() %>%
      brick() %>%
      t() %>%
      stretch() %>%
      writeRaster(
        filename = out_path, datatype = "INT1U",
        format = "GTiff", na.rm = TRUE, overwrite = TRUE
      )
  }

  # return the written file path
  return(out_path)
}

