# Classification tree model

# Importing libraries
library(randomForest)
library(caret)
library(C50) # Árbol de clasificación


# Set working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))


# Importing the df dataset
diabetes <- read.csv("diabetes.txt", stringsAsFactors = TRUE)


# Performs stratified random split of the data set
set.seed(123)
TrainingIndex <- createDataPartition(diabetes$age, p=0.75, list = FALSE)
TrainingSet <- diabetes[TrainingIndex,] # Training Set
TestingSet <- diabetes[-TrainingIndex,] # Test Set

write.csv(TrainingSet, "training.csv")
write.csv(TestingSet, "testing.csv")

# Building models:

# Random forest model
# model <- randomForest( ~ ., data = TrainingSet, ntree = 500, mtry = 4, importance = TRUE)

# Decision tree
model<- C5.0(diabetes[,-9], diabetes[,"diabetes"],trials = 10)

# Save model to RDS file 
saveRDS(model, "model.rds")

# Model predictions
model.predict <- predict(model,TestingSet) 


# Model Performance
model.performance <- confusionMatrix(data = model.predict ,
                reference = TestingSet$diabetes)
