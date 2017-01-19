## Libraries
library(raster)
library(rasterVis)

## Assuming that the git repository has been downloaded, unzipped and set as working directory in R
load("data/GewataB2.rda")
load("data/GewataB3.rda")
load("data/GewataB4.rda")
load("data/GewataB1.rda")
load("data/GewataB5.rda")
load("data/GewataB7.rda")
load("data/vcfGewata.rda")
load("data/trainingPoly.rda")

## Delete water, cloud or cloud shadow pixel values
vcfGewata[vcfGewata > 100] <- NA

## Calculate ndvi for later comparison with VCF tree cover
ndvi <- overlay(GewataB4, GewataB3, fun=function(x,y){(x-y)/(x+y)})
gewata <- brick(vcfGewata, ndvi)

## Build a brick containing all data and store in dataframe
alldata <- brick(GewataB1, GewataB2, GewataB3, GewataB4, GewataB5, GewataB7, vcfGewata)
pairs(gewata)
pairs(alldata) ## Conclusion: gewataB4 and especially ndvi seem slightly correlated to VCF tree cover while the other datasets show less correlation
names(alldata) <- c("band1", "band2", "band3", "band4", "band5", "band7", "VCF")
df <- as.data.frame(getValues(alldata))

## Create a model
model <- lm(VCF ~ band1 + band2 + band3 + band4 + band5 + band7, data = df)
summary(model) ## Conclusion: According to this summary band 7 is likely the most important in predicting tree cover

## Predict tree cover with the model and plot it next to original
VCFplot <- predict(alldata, model = model)
comparison <- brick(VCFplot, vcfGewata)
plot(comparison)

## Compute RMSE
RMSE <- sqrt(mean((comparison$layer-comparison$vcd2000Gewata)^2 , na.rm = TRUE ))

trainingPoly@data$Code <- as.numeric(trainingPoly@data$Class)
