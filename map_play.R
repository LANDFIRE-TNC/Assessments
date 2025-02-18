




library(flexdashboard)
library(leaflet)
library(sf)
library(leaflet.extras)
library(htmltools)


# Load the shapefile

assessments_shp <- st_read("data/assessments.shp") %>%
  st_transform(crs = 4326)





tol_muted_palette <- colorFactor(c('#88CCEE', '#44AA99', '#117733', '#332288', '#DDCC77', '#999933','#CC6677', '#882255', '#AA4499', '#52504a'), assessments_shp$org_nam) # from https://zenodo.org/records/3381072

map <- leaflet() %>%
  addTiles() %>%
  addPolygons(
    data = assessments_shp, 
    color = ~tol_muted_palette(org_nam), 
    weight = 2, 
    opacity = 1, 
    fillOpacity = 0.3,
    popup = ~paste(
      "<b>Landscape:</b> ", dsply_n, "<br>",
      "<b>Click for full report:</b> <a href='", link, "' target='_blank'>", link, "</a>"
    ),
    group = ~org_nam
  ) %>%
  addLayersControl(
    overlayGroups = unique(assessments_shp$dsply_n),
    options = layersControlOptions(collapsed = FALSE, position = "topleft")  # Change position to "topleft"
  ) %>%
  setView(lng = -96, lat = 37.8, zoom = 4)

map