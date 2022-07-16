# Classification tree model_diabetes
 
# Importing libraries
library(randomForest)
library(caret)
library(C50) # Árbol de clasificación


# Set working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))


# Importing the df dataset
diabetes <- read.csv("diabetes.txt", stringsAsFactors = TRUE)
levels(diabetes$diabetes) <- c("Negative", "Positive")

# Performs stratified random split of the data set
set.seed(123)
TrainingIndex <- createDataPartition(diabetes$age, p=0.75, list = FALSE)
TrainingSet <- diabetes[TrainingIndex,] # Training Set
TestingSet <- diabetes[-TrainingIndex,] # Test Set

write.csv(TrainingSet, "training_diabetes.csv")
write.csv(TestingSet, "testing_diabetes.csv")

# Building model_diabetess:

# Random forest model_diabetes
# model_diabetes <- randomForest(TrainingSet$diabetes ~ ., data = TrainingSet, ntree = 500, mtry = 4, importance = TRUE)

# Decision tree
 model_diabetes<- C5.0(TrainingSet[,-9], TrainingSet[,"diabetes"],trials = 10)

# Save model_diabetes to RDS file 
saveRDS(model_diabetes, "model_diabetes.rds")

# model_diabetes predictions
model_diabetes.predict <- predict(model_diabetes,TestingSet) 


# model_diabetes Performance
model_diabetes.performance <- confusionMatrix(data = model_diabetes.predict ,
                reference = TestingSet$diabetes, positive = "Positive")
