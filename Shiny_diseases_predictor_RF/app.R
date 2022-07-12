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

# Read in the RF model
model <- readRDS("model.rds")

# knitting Rmarkdown document
rmdfiles <- c("about.Rmd")
sapply(rmdfiles, knit, quiet = T)

####################################
# User interface                   #
####################################

# Define UI for application that draws a histogram
ui <- fixedPage(theme = shinytheme("cerulean"),
               
                navbarPage(
                   theme = 'cerulean',
                  "Disease predictor",
                  tabPanel("Diabetes predictor",
                           sidebarPanel(
                             tags$h3("Inputs:"),
                                         numericInput(inputId = "pregnant", 
                                              label = "Pregnancies", 
                                              value = 0),
                                       numericInput(inputId ="glucose", 
                                                    label = "Glucose", 
                                                    value = 100),
                                       numericInput(inputId ="pressure", 
                                                    label ="Dyastolic Pressure (mm Hg)", 
                                                    value = 50),
                                       numericInput(inputId ="triceps", 
                                                    label ="Triceps Skin Fold (mm)", 
                                                    value = 25),
                             numericInput(inputId ="insulin", 
                                          label ="Insulin", 
                                          value = 150),
                             numericInput(inputId ="mass",
                                          label ="Body Mass Index", 
                                          value = 30),
                             numericInput(inputId ="pedigree", 
                                          label ="Pedigree", 
                                          value = 2),
                             numericInput(inputId ="age", 
                                          label ="Age", 
                                          value = 30),
                             actionButton(inputId ="submitbutton",
                                          label ="Submit", 
                                          class = "btn btn-primary" ),
                             column(6,
                           
                                     ),
                             
                             column(4, )  
                                   
                            
                           
                           ), # sidebarPanel
                           mainPanel(
                                     tags$label(h3('Status/Output')), # Status/Output Text Box
                                     verbatimTextOutput('contents'),
                                     tableOutput('tabledata'), # Prediction results table
                                    imageOutput("emoji")# emoji dependent on prediction
                          
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

# Define server logic required to obtain predictions and probabilities of having diabetes
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
    
    test <<- read.csv(paste("input", ".csv", sep=""), header = TRUE)
    
    Output <- as.data.frame(cbind(as.character(predict(model,test)),
                    paste(100*round(predict(model,test,type="prob")[1],3),"%"),
                    paste(100*round(predict(model,test,type="prob")[2],3),"%")))
    colnames(Output) <- c("Diabetes prediction","No","Yes")
    print(Output)
  })
  
  # Status/Output Text Box
  output$contents <- renderPrint({
    if (input$submitbutton > 0) { 
      isolate("Diabetes prediction complete.") 
    } else {
      return("Specify inputs and click on 'Submit'.")
    }
  })
  
  # Prediction results table
  output$tabledata <- renderTable({
    if (input$submitbutton > 0) { 
      isolate(datasetInput()) 
    } 
  })
  
  # Emoji images
    
     output$emoji <- renderImage({
       if (input$submitbutton > 0){
    filename <- file.path('./www/sad_emoji.png')
     list(src = filename, width = "100px" , height= "100px")}
       else{
         filename <- file.path('./www/happy_emoji.png')
         list(src = filename, width = "100px" , height= "100px")
       }},
     deleteFile = FALSE)
}   
  # Return a list containing the filename
     
  # server

# Run the application 
shinyApp(ui = ui, server = server)
