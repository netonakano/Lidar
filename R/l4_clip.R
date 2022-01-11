#' Clip GEDI level 4A data to an extent or Shapefile boundary
#'
#' Useful to get GEDI data for a specific study area, by clipping the data to a
#' vector boundary or extent. Remember that, by default GEDI coordinates are in
#' lon/lat format (EPSG 4326).
#'
#' @param gediL4 \code{data.table} obtained with the function \code{l4_get} or
#'   \code{l4_getmulti(...,merge=TRUE)}.
#' @param clip An object from which an extent can be obtained (xmin,ymin, xmax,
#'   ymax). Currently could be a path to a shp or tif file, an object of class
#'   \code{sf}, a Raster* object or a numeric vector of coordinates.
#' @param usegeometry Logical: should the points be clipped on the boundary of an
#'   \code{sf_object} (or path from which an \code{sf_object} can be created). NULL and FALSE
#'   will be interpreted as the same, in that case the extent of \code{clip}
#'   will be used. Deafult to NULL.
#' @param tct Numeric: tree cover threshold to filter GEDI data.
#' @details GEDI coordinates are by defautl in lon/lat format (EPSG 4326). The
#'   function will try to convert the extent of \code{clip} to lon/lat
#'   coordinate system to ensure compatibility during the clip. The only
#'   exeption is when \code{clip} is a numeric vector or a bbox object. In these
#'   cases the user must check that the extent is in lon/lat
#'   projection.
#' @return A \code{data.table} object if \code{usegeometry=NULL} or \code{FALSE},
#'   an \code{sf_object} otherwise. It return \code{NULL} if \code{gediL4} is
#'   \code{NULL}.
#' @examples
#'
#' #Specifying the path to GEDI level4A data (zip file)
#' outdir = tempdir()
#' l4_zip <- system.file("extdata",
#'                       "GEDI04_A_2020186052327_O08834_T03611_02_001_01.zip",
#'                       package="GEDI4R")
#' #Unzipping GEDI level4A data
#' l4 <- unzip(l4_zip,exdir = outdir)
#' bound <- system.file("extdata","Italy.shp",package="GEDI4R")
#' #get GEDI data
#' l4_data <- l4_get(l4)
#' #clip using path
#' #deriving extent to clip
#' clipped <- l4_clip(l4_data,clip=bound,usegeometry = F)
#' #using polygon boundary to clip
#' clipped <- l4_clip(l4_data,clip=bound,usegeometry = T)
#'
#' #clip using bbox
#' #first we need to convert coordinates in lon/lat
#' tmp <- raster::shapefile(bound)#read boundary
#' box <- t(raster::bbox(tmp))#extract bounding box
#' proj4string <- as.character(tmp@proj4string)#retrive original projection
#' pj <- proj4::project(box, proj4string, inverse=TRUE)# Transformed data in lat lon
#' box <-c(t(pj))
#' clipped <- l4_clip(l4_data,clip=box)
#' @export


l4_clip <- function (gediL4,clip,usegeometry=NULL,tct=NULL) {

  if(is.null(gediL4))return(NULL)

  #input check
  stopifnot(
    "clip is missing with no default"= !missing(clip),
    "usegeometry must be logical or NULL"= any(is.logical(usegeometry),is.null(usegeometry))
  )

  if(!is.null(tct)){
    stopifnot("tct must be of lenght 1"=length(tct)==1,
              "tct must be numeric"=is.numeric(tct))
    gediL4 <- gediL4[gediL4$tree_cover>tct,]
  }

  if(is.null(usegeometry)||usegeometry==F){
    if(any(class(clip) == "character")) {
      if (!file.exists(clip))
        stop("clip doesn't exist")
      message("Path detected")
      if (tools::file_ext(clip) == "shp") {
        message("Shp detected")
        x <- raster::shapefile(clip)
      } else if (tools::file_ext(clip) == "tif") {
        message("Tif detected")
        x <- raster::raster(clip)
      }
      #bounding box
      tmp <- t(raster::bbox(x))
      proj4string <- as.character(x@proj4string)
      # Transformed data in lat lon
      pj <- proj4::project(tmp, proj4string, inverse = TRUE)
      bbox <- c(t(pj))
    } else if (any(class(clip) %in% c("sf", "data.frame"))) {
      message("Sf object detected")
      bbox <- sf::st_bbox(clip, crs = st_crs(4326))
    } else if (class(clip) %in% c("RasterLayer", "RasterStack", "raster")) {
      b <- t(raster::bbox(clip))
      proj4string <- as.character(r@crs)
      pj <- proj4::project(b, proj4string, inverse = TRUE)
      bbox <- c(t(pj))
    } else if (class(clip) %in% c("bbox", "numeric")) {
      message("Vector detected")
      bbox <- clip
    }

    xmin <-  bbox[1]
    ymin <- bbox[2]
    xmax <- bbox[3]
    ymax <- bbox[4]
    mask = gediL4$lon_lowestmode >= xmin & gediL4$lon_lowestmode <=
      xmax & gediL4$lat_lowestmode >= ymin & gediL4$lat_lowestmode <=
      ymax & gediL4$lon_lowestmode >= xmin & gediL4$lon_lowestmode <=
      xmax & gediL4$lat_lowestmode >= ymin & gediL4$lat_lowestmode <=
      ymax

    mask[!stats::complete.cases(mask)] = FALSE
    mask  <-  (1:length(gediL4$lat_lowestmode))[mask]
    newFile <- gediL4[mask, ]

  }else {
    if(any(class(clip)=="character")){
      if(tools::file_ext(clip)=="tif"){
        stop("cannot use raster as boundary to clip points when usegeometry=T")
      }else {
        bound <- sf::read_sf(clip)
        bound <- sf::st_transform(bound, 4326)
        sf_ob <- sf::st_as_sf(gediL4,coords=c("lon_lowestmode","lat_lowestmode"))
        sf::st_crs(sf_ob) <- 4326
        clipped <- sf::st_intersection(sf_ob,bound)
        newFile <- clipped
      }
    } else if(any(class(clip)%in%c("sf","data.frame"))){
      bound <- sf::st_transform(bound, 4326)
      sf_ob <- sf::st_as_sf(gediL4,coords=c("lon_lowestmode","lat_lowestmode"))
      sf::st_crs(sf_ob) <- 4326
      clipped <- sf::st_intersection(sf_ob,bound)
      newFile <- clipped

    } else if(class(clip)%in%c("bbox","numeric")){
      stop("cannot use numeric vector to clip points when usegeometry=T")
    }
  }
  return(newFile)
}



