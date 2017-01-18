# Name: Wilmer van der Spek
# Date: 14 January 2017

# Import packages
library(raster)

# Define the function

PlotMap <- function(country, level) {
  datdir <- 'data'
  dir.create(datdir, showWarnings = FALSE)
  adm <- raster::getData("GADM", country = country,
                       level = level, path = datdir)
  plot(adm, bg = "grey", axes=T)
  plot(adm, lwd = 10, border = "black", add=T)
  plot(adm, col = "green", add = T)
  grid()
  box()
  mtext(side = 3, line = 1, paste("Map of", country), cex = 2)
  mtext(side = 1, "Longitude", line = 2.5, cex=1.1)
  mtext(side = 2, "Latitude", line = 2.5, cex=1.1)
  text(122.08, 13.22, "Projection: Geographic\n
       Coordinate System: WGS 1984\n
       Data Source: GADM.org", adj = c(0, 0), cex = 0.7, col = "grey20")
}

# An example based on that function
PlotMap("Netherlands", 2)