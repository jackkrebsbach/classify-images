# UseTraining, Testing, and Validation data set to create a RF classifier
library(tidyverse)
library(tidymodels)
library(ranger)
library(randomForest)
show_engines("rand_forest")
rf_pixel_model <- rand_forest() %>%
                  set_engine("ranger", importance = "impurity") %>%
                  set_mode("classification") %>%
                  translate()

#load("clean_data/rdata/train_values_2.RData")
#load("clean_data/rdata/val_values.RData")



#Read in the training and validation data
train_values <- train_values_2 %>% bind_rows() %>% transform(label = as.factor(label)) 
val_values <- test_values_2 %>% transform(label = as.factor(label))

train_values %<>% select(-c(poly_num, area))
val_values  %<>% select(-c(poly_num, area))


#random forest model
rf_fit <- rf_pixel_model %>% fit(label ~ yuv.1 + yuv.2 + yuv.3 , data = train_values)

val_pred <- predict(rf_fit, val_values) %>% 
    bind_cols(predict(rf_fit, val_values, type = "prob")) %>%
    bind_cols(val_values %>% dplyr::select(label)) 


rf_fit
val_pred %>% conf_mat(truth = label, .pred_class)
val_pred %>% accuracy(truth = label, .pred_class)
#save(rf_fit, file = "code/rdata/rf_fit.RData")


