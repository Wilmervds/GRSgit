## Libraries
library(raster)
library(randomForest)

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
RMSE <- sqrt(mean((comparison$layer - comparison$vcf2000Gewata)^2 , na.rm = TRUE ))

## Create model with randomForest and trainingsdata
trainingPoly@data$Code <- as.numeric(trainingPoly@data$Class)
classes <- rasterize(trainingPoly, ndvi, field='Code')
alldatamasked <- mask(alldata, classes)
names(classes) <- "class"
trainingbrick <- addLayer(alldatamasked, classes)
valuetable <- getValues(trainingbrick)
valuetable <- na.omit(valuetable)
valuetable <- as.data.frame(valuetable)
valuetable$class <- factor(valuetable$class, levels = c(1:3))
modelRF <- randomForest(x=valuetable[ ,c(1:5)], y=valuetable$class, importance = TRUE)

## Predict tree cover with randomForest model and compare with VCF tree cover
predTC <- predict(alldata, model=modelRF, na.rm=TRUE)
comparison2 <- brick(predTC, vcfGewata)
comparison2 <- na.omit(comparison2)
comparison2 <- as.data.frame(comparison2)
plot(comparison2)

## Calculate RMSE between predicted and VCF tree cover for all three classes
RMSE <- sqrt(mean((comparison2$layer[1] - comparison2$vcf2000Gewata)^2 , na.rm = TRUE ))
RMSE <- sqrt(mean((comparison2$layer[2] - comparison2$vcf2000Gewata)^2 , na.rm = TRUE ))
RMSE <- sqrt(mean((comparison2$layer[3] - comparison2$vcf2000Gewata)^2 , na.rm = TRUE ))