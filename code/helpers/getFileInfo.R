library(stringr)

getFileDirectory <- function(filepath) {
  
  temp_dir <- str_split(filepath, "/")[[1]]
  dir <- temp_dir[1: length(temp_dir) -1]
  
  return(paste0(paste(dir, collapse = "/"), "/"))
}


getFileName <- function(filepath) {
  filepath %>% 
          str_split("/") %>% .[[1]] %>% tail(n = 1) 
}

getColorPath <- function(inpath, transform){
  # get the out file
  out_dir <- inpath %>% getFileDirectory()
  out_name <- transform %>%
    str_split(pattern = "to", simplify = TRUE) %>%
    .[1, 2] %>%
    tolower() %>%
    paste0(".tif")
  
  return(paste0(out_dir, out_name)) 
}

getTexturePath <- function(inpath, window, statistic, layer){
  #Create texture file path to write
  out_file_dir <- inpath %>% 
    getFileDirectory()
  
  out_file_name <- inpath %>% 
    getFileName()  %>%
    str_split(pattern = "\\.", simplify = TRUE) %>%
    .[1,1] %>%
    paste0("_", statistic,"_L", layer,"_W", window, ".tif")
  
  return(paste0(out_file_dir, out_file_name))

}


getSegmentPath <- function(inpath, spatial_radius, range_radius, min_density){
  inpath %>% getFileName() %>%
    str_split("\\.") %>% .[[1]] %>% .[1] %>%
    paste0("_seg_",spatial_radius, "_", range_radius, "_", min_density, ".tif")
}

