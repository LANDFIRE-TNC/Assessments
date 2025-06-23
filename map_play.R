

library(sf)
library(dplyr)
library(leaflet)
library(htmlwidgets)

# Load the shapefile
assessments_shp <- st_read("data/assessments.shp", quiet = TRUE) %>%
  st_transform(crs = 4326) %>%
  select(c(org_nam, geometry))

# Read assessments.csv into R
assessments_attributes <- read.csv("data/assessments.csv")

# Perform the join
assessments_shp <- dplyr::left_join(assessments_shp, assessments_attributes, by = 'org_nam')

# Ensure drw_rdr is a numeric vector
assessments_shp$drw_rdr <- as.numeric(as.character(assessments_shp$drw_rdr))

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
      group = assessments_shp$dsply_n[i], # Assign group based on dsply_n
      options = pathOptions(zIndex = assessments_shp$drw_rdr[i]) # Use zIndex to control order
    )
}

# Create custom checkboxes for layer control
layer_groups <- unique(assessments_shp$dsply_n)
checkboxes <- paste0('<input type="checkbox" class="layer-checkbox" id="', layer_groups, '" checked> ', layer_groups, '<br>', collapse = '')

# Add the checkboxes to the map
map <- map %>%
  addControl(html = paste0('<div id="layer-control">', checkboxes, '</div>'), position = "topright") %>%
  setView(lng = -82.5, lat = 37, zoom = 4) %>%
  htmlwidgets::onRender("
    function() {
      // Function to toggle layer visibility
      $('.layer-checkbox').change(function() {
        var map = this._map;
        var layerGroup = $(this).attr('id');
        if (this.checked) {
          map.eachLayer(function(layer) {
            if (layer.options && layer.options.group === layerGroup) {
              map.addLayer(layer);
            }
          });
        } else {
          map.eachLayer(function(layer) {
            if (layer.options && layer.options.group === layerGroup) {
              map.removeLayer(layer);
            }
          });
        }
      });

      // Add select/deselect all button
      $('#layer-control').prepend('<button id=\"toggle-all\" style=\"display:block; margin:auto;\">Select/Deselect All</button>');
      
      // Function to toggle all layers
      $('#toggle-all').click(function() {
        var allChecked = $('.layer-checkbox:checked').length === $('.layer-checkbox').length;
        $('.layer-checkbox').each(function() {
          this.checked = !allChecked;
          $(this).trigger('change');
        });
      });
    }
  ")

map

