#' Decentralized World map
#' 
#' @description
#' This function maps World countries in the Robinson projection system 
#' (by default) and centers the map on a meridian different from Greenwich.
#' It uses the [Natural Earth](https://www.naturalearthdata.com/) layer as a 
#' base map. All components of the map can be customized (color, line type, 
#' etc.).
#' 
#' @param res a character of length 1. One among `'small'`, `'medium'`, 
#'   `'large'`. See `?rnaturalearth::ne_countries` for further details.
#' 
#' @param crs a character of length 1. The Coordinate Reference System (CRS) of
#'   the map. See `?sp::CRS` for further details.
#'   **N.B.** the CRS must contain a parameter `+lon_0=0` in its definition.
#' 
#' @param center a numeric of length 1. The longitude of center of the map. Must
#'   be higher or equal to 0 and lower than 359.
#' 
#' @param lon a numeric vector. The longitudes to add meridians.
#' 
#' @param lat  a numeric vector. The latitudes to add parallels.
#' 
#' @param border the color of countries border.
#' 
#' @param border_box the color of map frame.
#' 
#' @param col the color of countries.
#' 
#' @param col_box the color of map frame (i.e. oceans).
#' 
#' @param col_grat the color of graticules.
#' 
#' @param lwd the lines width of countries border.
#' 
#' @param lwd_box the lines width of map frame.
#' 
#' @param lwd_grat the lines width of graticules.
#' 
#' @param lty the line type of countries border.
#' 
#' @param lty_box the line type of map frame.
#' 
#' @param lty_grat the line type of graticules.
#' 
#' @param ... other graphical parameters. See `?par`.
#' 
#' @export
#' 
#' @return No return value.
#' 
#' @examples
#' \dontrun{
#' ## Robinson World map centered on Greenwich ----
#' robinmap()
#' 
#' ## Robinson World map centered on Pacific ocean ----
#' robinmap(center = 160)
#' 
#' ## Change projection system ----
#' crs <- paste0("+proj=eck4 +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 ", 
#'               "+datum=WGS84 +units=m +no_defs")
#' 
#' robinmap(center = 160, crs = crs)
#' }

robinmap <- function(res = "small", crs = NULL, center = 0, 
                     lon = seq(-180, 180, by = 40), lat = seq(-90, 90, by = 30),
                     border = "white", border_box = col, 
                     col = "#7D7D7D", col_box = "#A3C6C7", col_grat = col, 
                     lwd = 0.25, lwd_box = 1, lwd_grat = lwd, 
                     lty = 1, lty_box = lty, lty_grat = 3, ...) {
  
  
  ## Check arguments ----
  
  if (!is.character(res) || length(res) != 1) {
    stop("Argument 'res' must be a character of length 1")
  }
  
  if (!(res %in% c("small", "medium", "large"))) {
    stop("Argument 'res' must be 'small', 'medium', or 'large'")
  }
  
  if (is.null(crs)) {
    crs <- paste0("+proj=robin +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 ", 
                  "+datum=WGS84 +units=m +no_defs")
  }
  
  if (!is.character(crs) || length(crs) != 1) {
    stop("Argument 'res' must be a character of length 1")
  }
  
  if (!is.numeric(center) || length(center) != 1) {
    stop("Argument 'center' must be a numeric of length 1")
  }
  
  if (center < 0 || center > 359) {
    stop("Argument 'center' must be higher or equal to 0 and strickly lower ",
         "than 359")
  }
  
  
  ## Save user options and parameters ----
  
  warn <- options()$"warn"
  opar <- graphics::par(no.readonly = TRUE)
  
  on.exit(options(warn = warn))
  on.exit(graphics::par(opar))
  
  
  ## Disable warning messages ----
  
  options(warn = -1)
  
  
  ## Define crs_trans system ----

  crs_trans <- gsub("lon_0=0", paste0("lon_0=", center), crs)
  
  
  ## Get base map ----
  
  world <- rnaturalearth::ne_countries(scale = res, type = "countries", 
                                       returnclass = "sf")

  
  ## Fix CRS bug ----
  
  world <- sf::st_set_crs(world, 4326)

  
  ## Translate polygons ----
  
  world <- maptools::nowrapSpatialPolygons(methods::as(world, "Spatial"), 
                                           offset = -1 * (180 - center))
  
  
  ## Convert to sf ----
  
  world <- sf::st_as_sf(world)
  
  
  ## Project to crs_trans system ----
  
  world <- sf::st_transform(world, crs_trans)
  
  
  ## Graticules ----
  
  grat <- graticule::graticule(lon, lat, xlim = range(lon), ylim = range(lat), 
                               proj = crs)


  ## Map frame ----

  bbox <- graticule::graticule(range(lon), range(lat), proj = crs, tiles = TRUE)
  
  
  ## Map ----
  
  graphics::par(...)
  
  sp::plot(bbox, col = col_box, border = NA)
  
  sp::plot(grat, lwd = lwd_grat, lty = lty_grat, col = col_grat, add = TRUE)
  
  plot(sf::st_geometry(world), lwd = lwd, lty = lty, col = col, border = border,
       add = TRUE)
  
  sp::plot(bbox, lwd = lwd_box, lty = lty_box, col = NA, border = border_box, 
           add = TRUE)
  
  invisible(world)
}
