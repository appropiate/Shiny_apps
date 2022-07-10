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

# Set working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Read in the RF model
model <- readRDS("model.rds")

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
                             sliderInput("pregnant", 
                                         label = "Number of pregnancies:", 
                                         value = 0,
                                         min = min(TrainSet$pregnant),
                                         max = max(TrainSet$pregnant)),
                             numericInput("glucose", "Plasma glucose concentration:", ""), # txt2 will be sent to server
                             numericInput("pressure", "Diastolic blood presure (mm Hg):",""),
                             numericInput("triceps", "Triceps skin fold thickness (mm):",""),
                             numericInput("insulin", "2_Hour serum insulin (mu U/ml):",""),
                             numericInput("mass", "Body mass index:",""),
                             numericInput("pedigree", "Pedigree function:",""),
                             numericInput("age", "Age:",""),
                             actionButton("submitbutton", "Submit", class = "btn btn-primary")
                           ), # sidebarPanel
                           mainPanel(
                                     tags$label(h3('Status/Output')), # Status/Output Text Box
                                     verbatimTextOutput('contents'),
                                     tableOutput('tabledata') # Prediction results table
                          
                           ) # mainPanel
                           ), # Navbar 1, tabPanel
                  tabPanel("About", 
                           titlePanel("About"), 
                           div(includeMarkdown("about.md"), 
                               align="justify")
                  ) #tabPanel(), About
                ) #navbarPage
                ) # fluidPage

####################################
# Server                           #
####################################

# Define server logic required obtain predictions of probabilities of patient having diabetes
server <- function(input, output) {
  
  output$txtout <- renderText({
    paste(input$txt1, input$txt2, sep = " ")
  })
} # server

# Run the application 
shinyApp(ui = ui, server = server)
