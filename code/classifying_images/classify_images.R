#Load Model
load('code/rdata/rf_fit.RData')
source('code/helpers/classify_helpers.R')

quadrat_dirs <- sprintf("clean_data/quadrats/quadrat%02d/", seq(34, 83, 1)) 

quadrats_dirs %>% 
            bmclapply(FUN = classify_image, rf_fit = rf_fit, mc.cors = 20) %>% print()
              
#( p_pred <- ggR(pred_ras, maxpixels = 5e+05, forceCat = TRUE, geom_raster = TRUE) +
#    scale_fill_discrete(name = "Class", labels = lab_levs) + theme_minimal() )
#( p_orig <- ggRGB(ras, r = 1, g = 2, b = 3, maxpixels = 5e+05) + theme_minimal() )
quadrat_dirs[[1]] %>% classify_image(rf_fit)
