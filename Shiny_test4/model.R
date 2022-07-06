####################################
# Data Professor                   #
# http://youtube.com/dataprofessor #
# http://github.com/dataprofessor  #
####################################

# Importing libraries
library(RCurl) # for downloading the iris CSV file
library(randomForest)
library(caret)

# Importing the Iris dataset
iris <- read.csv("https://raw.githubusercontent.com/dataprofessor/data/master/iris.csv")
iris$Species <- as.factor(iris$Species)

# Performs stratified random split of the data set
TrainingIndex <- createDataPartition(iris$Species, p=0.8, list = FALSE)
TrainingSet <- iris[TrainingIndex,] # Training Set
TestingSet <- iris[-TrainingIndex,] # Test Set

# Building Random forest model
model <- randomForest(Species ~ ., data = TrainingSet, ntree = 500, mtry = 4, importance = TRUE)

# Save model to RDS file 
saveRDS(model, "model.rds")

# Model predictions
model.predict <- predict(model,TestingSet)

# Model Performance
model.performance <- confusionMatrix(data = model.predict ,
                reference = TestingSet$Species)
