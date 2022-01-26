
# Get working directory
getwd()


quadrats <- sprintf("clean_data/quadrats/quadrat%02d/rgb.json", seq(34, 83, 1))

for( i in 1:length(quadrats)){
  json <- jsonlite::read_json(quadrats[[i]])
    for( j in 1:length(json$shapes)){
      json$shapes[[j]]$group_id <- j
    }
json %>%
  jsonlite::write_json(quadrats[[i]], auto_unbox =TRUE, null = "null", pretty =TRUE)
}
