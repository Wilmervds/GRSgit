#Name: Wilmer van der Spek

#libraries
library(raster)

# download and unzip modis file
download.file(url = 'https://raw.githubusercontent.com/GeoScripting-WUR/VectorRaster/gh-pages/data/MODIS.zip', destfile = 'modis.zip', method = 'auto')
unzip('modis.zip')

# import modis and municipality files to R
modis <- brick('MOD13A3.A2014001.h18v03.005.grd')
nlMunicipality <- getData('GADM',country='NLD', level=2)

# project municipality data
municipalities <- spTransform(nlMunicipality, CRS(proj4string(modis)))

# extract mean of January data from modis based on municipalities
jan <- extract(modis$January, municipalities, fun = mean)

# transform municipalities into a dataframe (to enable use of cbind)
municipalitiesDF <- data.frame(municipalities)

# add extracted mean value to municipalities dataframe, delete NA values and select max value
combined <- cbind(jan, municipalitiesDF)
combined <- combined[!is.na(combined$jan),]
greenestvalueJan <- max(combined$jan)
# from this value follows that Littenseradiel is the greenest municipality in the Netherlands in January

# repeat for August
aug <- extract(modis$August, municipalities, fun = mean)
combined <- cbind(aug, municipalitiesDF)
combined <- combined[!is.na(combined$aug),]
greenestvalueAug <- max(combined$aug)
# from this value follows that Vorden is the greenest municipality in the Netherlands in August

# compute year sum
sumyear <- modis$January + modis$February + modis$March + modis$April + modis$May + modis$June + modis$July + modis$August + modis$September + modis$October + modis$November + modis$December
year <- extract(sumyear, municipalities, fun = mean)
combined <- cbind(year, municipalitiesDF)
combined <- combined[!is.na(combined$year),]
greenestvalueYear <- max(combined$year)
# from this value follows that Graafstroom is the greenest municipality in the Netherlands average over the whole year