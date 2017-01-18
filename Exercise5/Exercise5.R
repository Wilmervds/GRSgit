## Name: Wilmer van der Spek
## Date: 18 Jan 2017

## EXtract data from files
untar("data\\LC81970242014109-SC20141230042441.tar.gz")
untar("data\\LT51980241990098-SC20150107121947.tar.gz")

## Import data to R and transform to bricklayer
img1red <- raster('LC81970242014109LGN00_sr_band4.tif')
img1nir <- raster('LC81970242014109LGN00_sr_band5.tif')
img1cfmask <- raster('LC81970242014109LGN00_cfmask.tif')
img2red <- raster('LT51980241990098KIS00_sr_band3.tif')
img2nir <- raster('LT51980241990098KIS00_sr_band4.tif')
img2cfmask <- raster('LT51980241990098KIS00_cfmask.tif')
Landsat8 <- brick(img1red, img1nir, img1cfmask)
Landsat5 <- brick(img2red, img2nir, img2cfmask)

## Remove clouds from the images
Landsat8[img1cfmask != 0] <- NA
Landsat5[img2cfmask != 0] <- NA

## Crop datasets to similar extents
Landsat8 <- crop(Landsat8, Landsat5, snap='near')
Landsat5 <- crop(Landsat5, Landsat8, snap='near')

## Calculate NDVI for both images
ndvi8 <- (Landsat8[[2]] - Landsat8[[1]]) / (Landsat8[[2]] + Landsat8[[1]])
ndvi5 <- (Landsat5[[2]] - Landsat5[[1]]) / (Landsat5[[2]] + Landsat5[[1]])

## Calculate change in NDVI
ndviChange <- cellStats(ndvi8 - ndvi5, 'mean')
print(ndviChange)
## Output is 0.0519285, so it did change but not very significantly
