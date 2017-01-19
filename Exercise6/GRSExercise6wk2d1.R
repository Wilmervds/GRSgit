# import libraries
library(sp)
library(rgdal)
library(rgeos)

# download and unzip files
download.file(url = 'http://www.mapcruzin.com/download-shapefile/netherlands-railways-shape.zip', destfile = 'railways.zip', method = 'auto')
download.file(url = 'http://www.mapcruzin.com/download-shapefile/netherlands-places-shape.zip', destfile = 'places.zip', method = 'auto')
unzip('railways.zip')
unzip('places.zip')

# import shapefiles to R
railwayfile = file.path("railways.shp")
railways <- readOGR(railwayfile, layer = ogrListLayers(railwayfile))
placesfile = file.path("places.shp")
places <- readOGR(placesfile, layer = ogrListLayers(placesfile))

# select industrial railways
industrial <- railways[railways$type == "industrial", ]

# project shapefiles to Rijksdriehoeksstelsel
prj_string_RD <- CRS("+proj=sterea +lat_0=52.15616055555555 +lon_0=5.38763888888889 +k=0.9999079 +x_0=155000 +y_0=463000 +ellps=bessel +towgs84=565.2369,50.0087,465.658,-0.406857330322398,0.350732676542563,-1.8703473836068,4.0812 +units=m +no_defs")
industrialRD <- spTransform(industrial, prj_string_RD)
placesRD <- spTransform(places, prj_string_RD)

# create buffer around industrial railway
industrialBuffer <- gBuffer(industrialRD, byid=TRUE, id=NULL, width=1000.0, quadsegs=5, capStyle="ROUND", joinStyle="ROUND", mitreLimit=1.0)

# find the city that intersects industrial railway buffer
Intersection <- gIntersection(placesRD, industrialBuffer)

# plot the buffer, city point and city name (for some reason the buffer plot is removed)
plot(industrialBuffer)
plot(Intersection)
mtext("Utrecht", 1, adj = 0)

# Name city: Utrecht, Population: 100000