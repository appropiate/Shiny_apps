### Classification tree model ####
 
# Importing libraries
library(cumstats)
library(farff)
library(randomForest)
library(caret)
library(C50) # Árbol de clasificación


# Set working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))


# Importing the dataset
df <- readARFF("MM-DataSet.arff")

# Removing NA values
for(j in 1:ncol(df)){
  if(anyNA(df[,j]) == TRUE){
  if (class(df[,j]) == "factor" | class(df[,j]) == "character" ){
    df[which(is.na(df[,j])),j] = Mode(na.exclude(df[,j]))$Values[[1]]
  }else{
    df[which(is.na(df[,j])),j] = round(mean(na.exclude(df[,j])),2)
  }}
  else{
    df[,j] = df[,j]
  }
}

# rename problematic colnames:
names(df)[names(df) == 'asth&bone'] <- 'asth.and.bone'
names(df)[names(df) == '24h_prot'] <- 'prot24h'

# Stratified random split of the data set
set.seed(123)
TrainingIndex <- createDataPartition(df$age, p=0.75, list = FALSE)
TrainingSet <- df[TrainingIndex,] # Training Set
TestingSet <- df[-TrainingIndex,] # Test Set

#Saving training and test sets
training_csv <-  "training_mm.csv"
test_csv <-"testing_mm.csv"

write.csv(TrainingSet,training_csv)
write.csv(TestingSet, test_csv)

## -----------------------------------------------------------------------------------

# Building model:

# Decision tree model
# model<- C5.0(TrainingSet[,-59], TrainingSet[,59],trials = 100)

# Alternative model: Random forest model
model <- randomForest( CLASS ~ ., data = TrainingSet, ntree = 500, importance = TRUE)

# Save model to RDS file 
saveRDS(model, "model.rds")

# model predictions
model.predict <- predict(model,TestingSet) 

# model Performance
model.performance <- confusionMatrix(data = model.predict ,
                reference = TestingSet$CLASS)
