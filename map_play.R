



library(dplyr)
library(sf)
library(leaflet)

# Load the shapefile
assessments_shp <- st_read("data/assessments.shp") %>%
  st_transform(crs = 4326) %>%
  select(c(org_nam, geometry))

# Read assessments.csv into R
assessments_attributes <- read.csv("data/assessements.csv")

# Perform the join
assessments_shp <- dplyr::left_join(assessments_shp, assessments_attributes, by = 'org_nam')

# Ensure drw_rdr is a numeric vector
assessments_shp$drw_rdr <- as.numeric(as.character(assessments_shp$drw_rdr))

# Check the structure of assessments_shp
str(assessments_shp)

# Order your polygons in descending order based on the drw_rdr column
assessments_shp <- assessments_shp[order(-assessments_shp$drw_rdr), ]

tol_muted_palette <- colorFactor(c('#88CCEE', '#44AA99', '#117733', '#332288', '#DDCC77', '#999933','#CC6677', '#882255', '#AA4499', '#52504a'), assessments_shp$org_nam)

# Create the map
map <- leaflet() %>%
  addTiles()

# Add polygons to the map in the desired order
for (i in 1:nrow(assessments_shp)) {
  map <- map %>%
    addPolygons(
      data = assessments_shp[i, ], 
      color = ~tol_muted_palette(org_nam), 
      weight = 2, 
      opacity = 1, 
      fillOpacity = 0.3,
      popup = ~paste(
        "<b>Landscape:</b> ", dsply_n, "<br>",
        "<b>Click for full report:</b> <a href='", link, "' target='_blank'>", link, "</a>"
      ),
      options = pathOptions(zIndex = assessments_shp$drw_rdr[i]) # Use zIndex to control order
    )
}

# Add layers control
map <- map %>%
  addLayersControl(
    overlayGroups = unique(assessments_shp$dsply_n),
    options = layersControlOptions(collapsed = TRUE, position = "topright")
  ) %>%
  setView(lng = -82.5, lat = 37, zoom = 4) %>%
  htmlwidgets::onRender("
    function() {
      $('.leaflet-control-layers-overlays').prepend('<label style=\"text-align:center\">Completed Assessments</label>');
    }
  ")

map
