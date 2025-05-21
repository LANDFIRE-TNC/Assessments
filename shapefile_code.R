

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

st_write(assessments_shp, "data/assessements.csv", append = FALSE)

## after editing the 'assessments.csv' file you will need to join it back to the shapefile

# read assessments.csv into R ----

assessments_attributes <- read.csv("data/assessements.csv")


# join edited attribute table to shapefile  ----

assessments_shp <- dplyr::left_join(assessments_shp, assessments_attributes, by = 'org_nam')


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

  
## add ely ----



ely_shp <- st_read("data/ely_blm.shp") %>%
  st_transform(crs = 4326) 


# wrangle shapefile
ely_shp <- ely_shp %>%
  select(c("PARENT_NAM" ,
           "geometry")) %>%  # need to look at fields and change this as needed only keeping the name and geometry
  rename(org_nam = PARENT_NAM) %>%
  left_join(assessments_attributes, by = 'org_nam')

# add uncompahgre to assessments shp
assessments_shp <- rbind(assessments_shp, ely_shp)

plot(assessments_shp)

st_write(assessments_shp, "data/assessments.shp", 
         delete_layer = TRUE)

## add USFWS Region 6 ----



# Read and transform the shapefile
usfws_r6_shp <- st_read("data/usfws_r6.shp") %>%
  st_transform(crs = 4326)


  


# wrangle shapefile
usfws_r6_shp <- usfws_r6_shp %>%
  select(c("REGNAME" ,
           "geometry")) %>%  # need to look at fields and change this as needed only keeping the name and geometry
  rename(org_nam = REGNAME) %>%
  left_join(assessments_attributes, by = 'org_nam')

# add uncompahgre to assessments shp
assessments_shp <- rbind(assessments_shp, usfws_r6_shp)

plot(assessments_shp)

st_write(assessments_shp, "data/assessments.shp", 
         delete_layer = TRUE)

