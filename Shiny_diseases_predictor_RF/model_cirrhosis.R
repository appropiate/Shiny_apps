### Classification tree model ####
 
# Importing libraries
library(cumstats)
library(dplyr)
library(farff)
library(randomForest)
library(fastAdaboost)
library(xgboost)
library(plyr)
library(caret)
library(C50) # Árbol de clasificación
library(neuralnet)
library(nnet)

# Set working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))


# Importing the dataset
df <- read.csv("cirrhosis.csv")

# df <- df[complete.cases(df),] #rows with no NA values

# Data structure:
# str(df)

# Character variables to factors:
for (i in 1:ncol(df)){
  if(class(df[,i]) == "character"){
  df[,i] <- as.factor(df[,i])
  }else{
    df[,i]<- df[,i]
  }
}

# Check variables values:
summary(df)




# For further analysis, only use variables having less than 10% 
# of its observations as NA values:

na.values <- function(x){length(which(is.na(x)))} # Function giving number of NA values 
apply(df, 2, na.values) # Number of NA values per variable
names <- names(which(apply(df, 2, na.values) < nrow(df)*0.1)) # variables with less than 10% NA values
df <- df[names] # Use only variables in object "name" for downstream analyses 
dim(df)

# Removing rows with NA values for dependent variable
if(length(which(is.na(df[,ncol(df)])))>0) {
df <- df[-which(is.na(df[ncol(df)])),]
}else{
  df <- df
}

# Imputing NA values from independent variables:
 for(j in 1:(ncol(df)-1)){
   if(anyNA(df[,j]) == TRUE){
   if (class(df[,j]) == "factor"){
     df[which(is.na(df[,j])),j] = Mode(na.exclude(df[,j]))$Values[[1]]
   }else{
     df[which(is.na(df[,j])),j] = round(mean(na.exclude(df[,j])),2)
   }}
   else{
     df[,j] = df[,j]
   }
 }

#Factor variables to numeric (depending on algorithm):
for (i in 1:ncol(df)){
  if(class(df[,i]) == "factor"){
    df[,i] <- as.numeric(df[,i])
  }else{
    df[,i]<- df[,i]
  }
}

# factorize response variable:
 df[,ncol(df)] <- factor(df[,ncol(df)])

# Stratified random split of the data set
set.seed(123)
TrainingIndex <- createDataPartition(df[,ncol(df)], p=0.8, list = FALSE)
TrainingSet <- df[TrainingIndex,] # Training Set
TestingSet <- df[-TrainingIndex,] # Test Set

#Saving training and test sets
training_csv <-  "training_cirrhosis.csv"
test_csv <-"testing_cirrhosis.csv"

write.csv(TrainingSet,training_csv)
write.csv(TestingSet, test_csv)


# Building model:

# Decision tree model
 model2<- C5.0(TrainingSet[,-ncol(df)], TrainingSet[,ncol(df)],trials = 100)

## -----------------------------Alternative models ------------------------------

#Random forest model
model <- randomForest( x=TrainingSet[,-ncol(TrainingSet)],
                       y=TrainingSet[,ncol(TrainingSet)],
                       mtry = sqrt((ncol(df)-1)),
                       ntree = 500, 
                       importance = TRUE)

# Gradient Boosting

model <- train(
                x=TrainingSet[,-ncol(TrainingSet)],
                y=TrainingSet[,ncol(TrainingSet)],
                method = "xgbTree",
                trControl = trainControl("cv", number = 10),
              )


# Save model to RDS file 
saveRDS(model, "model_cirrhosis.rds")

# model predictions
model.predict <- predict(model,TestingSet[,-ncol(TestingSet)]) 
model.predict2 <- predict(model2,TestingSet[,-ncol(TestingSet)]) 

# model Performance
model.performance <- confusionMatrix(data = model.predict ,
                reference = TestingSet[,ncol(TestingSet)])
