#library(sf)
#library(tidyverse)
#library(jsonlite)

#function that converts matrix to polygon
poly_from_mat <- function(point_matrix,im_ht){
  #transform y so origin is at bottom left corner of image
  point_matrix[,2] <- im_ht - point_matrix[,2]
  #repeat first point at end
  point_matrix <- rbind(point_matrix,point_matrix[1,])
  point_matrix_list <- list(point_matrix)
  #create sf polygon
  poly <- st_polygon(point_matrix_list)
  return(poly)
}


#function that takes json file name from labelme as input and outputs sf object
label_me_json_to_sf <- function(json_path){
  #read in json file from labelme
  labeled_polys_list <- read_json(json_path,simplifyVector=TRUE)
  labeled_polys_list$imageData <- NULL
  
  #get the shapes data frame with all the stuff we want
  labeled_polys_tib <- labeled_polys_list$shapes %>% as_tibble() %>%
    mutate(imagePath = labeled_polys_list$imagePath)
  im_wid <- labeled_polys_list$imageWidth
  im_ht <- labeled_polys_list$imageHeight
  
  # add polygons to the tibble
  labeled_polys_tib <- labeled_polys_tib %>% 
    mutate(polys = lapply(points,poly_from_mat,im_ht=im_ht)) %>%
    dplyr::select(-points)
  
  # create the sf object and remove unneeded variables
  labeled_polys_sf <- labeled_polys_tib %>% st_as_sf(sf_column_name="polys") %>%
    dplyr::select(-c(flags,group_id,shape_type)) %>%
    mutate(area = st_area(.$polys))
  
  return(labeled_polys_sf)
}

#Plot sf polygons on top of rasters
plot_labeled <- function(im_path, json_path, maxpixels = 5e+05, out_path = NULL){
  sf <- label_me_json_to_sf(json_path)
  ras <- brick(im_path)
  p <- ggplot() +
       ggRGB(ras, r = 1, g = 2, b = 3, ggLayer = TRUE, maxpixels = maxpixels) +
        geom_sf(data = sf, mapping = aes(fill = label)) +
        theme_minimal()
  if(!is.null(out_path)){ggsave(out_path)}
  return(p)
} 


train_val_split_polys <- function(polys,split_tib){
  # arranges by label (by factor level, not alphabetical)
  # make sure polys and split_tib have the same levels (exactly, including order)
  split_tib <- split_tib %>% arrange(label)
  
  # not pretty, but at least it's buried in a function!
  for( i in 1:nrow(split_tib)){
    if( i == 1){train_val <- c()}
    train_n <- split_tib[i,"train_n"]
    val_n <- split_tib[i,"val_n"]
    test_n <- split_tib[i, 'test_n']
    train_val <- c( train_val, sample( c( rep("train", train_n),rep("val", val_n) ,rep("test", test_n) )))
  }
  
  train_val <- as_factor(train_val)
  
  polys <- polys %>% arrange(label) %>% mutate(train_val = train_val)
  return(polys)
}

#Extract pixel values from all images in a given directory based off of previously sampled points
extract_values <- function(dir, pts, quadrats) {
  
  #List images in the directory and get the pts in a quadrat
  pts <- pts %>% filter(quadrat == dir)
  
  # images <- list.files(quadrats[dir], pattern = ".tif", full.names = TRUE )
  
  files <- list("hsv.tif", "lab.tif", "rgb.tif", "yuv.tif",
                 "rgb_seg_6_4.5_50.tif", "hsv_contrast_L3_W5.tif",
                 "hsv_contrast_L3_W3.tif", "hsv_contrast_L3_W7.tif")
  
  image <- paste0(quadrats[dir], files)
  #Get the pixel values from the raster stack 
   train_ras_mat <- stack(image, quick = TRUE) %>% 
                    raster::extract(pts)

  #Bind the pixel values to corresponding label by column
  pts %>% cbind(train_ras_mat) %>%
    st_drop_geometry() %>%
    select(-quadrat) %>%
    as_tibble() %>%
    drop_na()
}


# images <- list("hsv.tif", "lab.tif", "rgb.tif", "yuv.tif",
#                "rgb_seg_6_4.5_50.tif", "hsv_contrast_L3_W5.tif",
#                "hsv_contrast_L3_W3.tif", "hsv_contrast_L3_W7.tif")
# 
# 
# dir <- "clean_data/quadrats/quadrat34/"
# 
# files <- paste0(dir, images)
# stack <- raster::stack(files, quick = TRUE)
# stack
# 


