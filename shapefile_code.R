

# code used to manipulate 'assessments.shp' when updating with new assessments
# many steps may not be necessary


library(sf)
library(tidyverse)


# Load the shapefile -----

## note you are messing with the master file

assessments_shp <- st_read("data/assessments.shp") %>%
  st_transform(crs = 4326) 


## note, I removed all but necessary fields as I planned to join new ones in below

# write the shapefile out as a .csv for attribute table editing.  Will not have geometry (not needed for attribute editing) ----

st_write(assessments, "data/assessements.csv")

## after editing the 'assessments.csv' file you will need to join it back to the shapefile

# read assessments.csv into R ----

assessments_attributes <- read.csv("data/assessements.csv")


# join edited attribute table to shapefile  ----

assessments_shp <- left_join(assessments_shp, assessments_attributes, by = c('org_nam' = 'org_name'))

# remove incomplete or irrelevant rows (polygons)

assessments_shp <- assessments_shp %>%
  filter(!org_name %in% c("allegheny_nf", 
                          "michigan500k", 
                          "midewin_nf"))
# write the shape

st_write(assessments_shp, "data/assessments.shp", 
         delete_layer = TRUE)


## Note names are abbreviated

# Add new polygons to assessments shapefile ----

# add info in assessments.csv in excel !!

##  st.croix  ----

st_croix_shp <- st_read("data/st_croix.shp") %>%
  st_transform(crs = 4326) 

st_croix_shp <- st_croix_shp %>%
  select(c(AREA_NAME,  
           geometry)) %>%  # need to look at fields and change this as needed only keeping the name and geometry
  rename(org_nam = AREA_NAME) %>%
  left_join(assessments_attributes, by = 'org_nam')


# add st.croix to assessments shp
assessments_shp <- rbind(assessments_shp, st_croix_shp)

st_write(assessments_shp, "data/assessments.shp", 
         delete_layer = TRUE)


## uncompahgre nf ----

uncompahgre_shp <- st_read("data/uncompahgre_nf.shp") %>%
  st_transform(crs = 4326) 

# rename the forest-too long and has commas-to name in assessments_attributes
uncompahgre_shp$FORESTNAME[1] = "uncompahgre"

# wrangle shapefile
uncompahgre_shp <- uncompahgre_shp %>%
  select(c(FORESTNAME,  
           geometry)) %>%  # need to look at fields and change this as needed only keeping the name and geometry
  rename(org_nam = FORESTNAME) %>%
  left_join(assessments_attributes, by = 'org_nam')

# add uncompahgre to assessments shp
assessments_shp <- rbind(assessments_shp, uncompahgre_shp)

plot(assessments_shp)

st_write(assessments_shp, "data/assessments.shp", 
         delete_layer = TRUE)
  


