#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(rmarkdown)
library(bookdown)
library(knitr)
library(data.table)

# Set working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

#Loading dataset
df1 <- read.csv("diabetes.txt", stringsAsFactors = TRUE)

# Read in the RF model
model <- readRDS("model.rds")

# knitting Rmarkdown document
rmdfiles <- c("about.Rmd")
sapply(rmdfiles, knit, quiet = T)

####################################
# User interface                   #
####################################

# Define UI for application that draws a histogram
ui <- fluidPage(theme = shinytheme("united"),
                navbarPage(
                  # theme = 'cerulean'
                  "Disease predictor",
                  tabPanel("Diabetes",
                           sidebarPanel(
                             tags$h3("Inputs:"),
                             numericInput(inputId = "pregnant", 
                                          label = "Pregnant", 
                                          value = 0),
                             numericInput(inputId ="glucose", 
                                          label = "Glucose", 
                                          value = 100),
                             numericInput(inputId ="pressure", 
                                          label ="Pressure", 
                                          value = 50),
                             numericInput(inputId ="triceps", 
                                          label ="Triceps", 
                                          value = 25),
                             numericInput(inputId ="insulin", 
                                          label ="Insulin", 
                                          value = 150),
                             numericInput(inputId ="mass",
                                          label ="Mass", 
                                          value = 30),
                             numericInput(inputId ="pedigree", 
                                          label ="Pedigree", 
                                          value = 2),
                             numericInput(inputId ="age", 
                                          label ="Age", 
                                          value = 30),
                             actionButton(inputId ="submitbutton",
                                          label ="Submit", 
                                          class = "btn btn-primary")
                           ), # sidebarPanel
                           mainPanel(
                                     tags$label(h3('Status/Output')), # Status/Output Text Box
                                     verbatimTextOutput('contents'),
                                     tableOutput('tabledata') # Prediction results table
                          
                           ) # mainPanel
                           ), # Navbar 1, tabPanel
                  
                  tabPanel("About", 
                           titlePanel(""), 
                           withMathJax(includeMarkdown("about.md"))
                  )
                           )#tabPanel(), About
                  
                  
                ) # fluidPage
                 

####################################
# Server                           #
####################################

# Define server logic required obtain predictions of probabilities of patient having diabetes
server <- function(input, output) {
  
  # Input Data
  datasetInput <- reactive({  
    
    df <- data.frame(
      # variable names in data set
      Name = c("pregnant",
               "glucose",
               "pressure",
               "triceps",
               "insulin",
               "mass",
               "pedigree",
               "age"),
      # Values for variables  specified in inputs
      Value = as.character(c(input$pregnant,
                             input$glucose,
                             input$pressure,
                             input$triceps,
                             input$insulin,
                             input$mass,
                             input$pedigree,
                             input$age)),
      stringsAsFactors = FALSE)
    
     # diabetes <- 0
     # df <- rbind(df, diabetes)
    input <- transpose(df)
    write.table(input,"input.csv", sep=",", quote = FALSE, row.names = FALSE, col.names = FALSE)
    
    test <- read.csv(paste("input", ".csv", sep=""), header = TRUE)
    
    Output <- data.frame("Diabetes"=predict(model,test), round(predict(model,test,type="prob"), 3))
    print(Output)
    
  })
  
  # Status/Output Text Box
  output$contents <- renderPrint({
    if (input$submitbutton > 0) { 
      isolate("Calculation complete.") 
    } else {
      return("Server is ready for calculation.")
    }
  })
  
  # Prediction results table
  output$tabledata <- renderTable({
    if (input$submitbutton > 0) { 
      isolate(datasetInput()) 
    } 
  })
  

  
} # server

# Run the application 
shinyApp(ui = ui, server = server)
