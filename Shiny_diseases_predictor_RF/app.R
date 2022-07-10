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
                                          label = "Number of pregnancies:", 
                                          value = 0),
                             numericInput(inputId ="glucose", 
                                          label = "Plasma glucose concentration:", 
                                          value = 100),
                             numericInput(inputId ="pressure", 
                                          label ="Diastolic blood presure (mm Hg):", 
                                          value = 50),
                             numericInput(inputId ="triceps", 
                                          label ="Triceps skin fold thickness (mm):", 
                                          value = 25),
                             numericInput(inputId ="insulin", 
                                          label ="2 hour serum insulin (mu U/ml):", 
                                          value = 150),
                             numericInput(inputId ="mass",
                                          label ="Body mass index:", 
                                          value = 30),
                             numericInput(inputId ="pedigree", 
                                          label ="Pedigree function:", 
                                          value = 2),
                             numericInput(inputId ="age", 
                                          label ="Age:", 
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
                           titlePanel("About"), 
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
      Name = c("Number of pregnancies:",
               "Plasma glucose concentration:",
               "Diastolic blood presure (mm Hg):",
               "Triceps skin fold thickness (mm):",
               "2 hour serum insulin (mu U/ml):",
               "Body mass index:",
               "Pedigree function:",
               "Age:"),
      Value = as.character(c(input$pregnant,
                             input$glucose,
                             input$pressure,
                             input$triceps,
                             input$insulin,
                             input$mass,
                             input$pedigree,
                             input$age),
      stringsAsFactors = FALSE))
    
     diabetes <- 0
     df <- rbind(df, diabetes)
    input <- transpose(df)
    write.table(input,"input.csv", sep=",", quote = FALSE, row.names = FALSE, col.names = FALSE)
    
    test <- read.csv(paste("input", ".csv", sep=""), header = TRUE)
    
    Output <- data.frame(Prediction=predict(model,test), round(predict(model,test,type="prob"), 3))
    print(Output)
    
  })
  
  # Status/Output Text Box
  output$contents <- renderPrint({
    if (input$submitbutton>0) { 
      isolate("Calculation complete.") 
    } else {
      return("Server is ready for calculation.")
    }
  })
  
  # Prediction results table
  output$tabledata <- renderTable({
    if (input$submitbutton>0) { 
      isolate(datasetInput()) 
    } 
  })
  

  
} # server

# Run the application 
shinyApp(ui = ui, server = server)
