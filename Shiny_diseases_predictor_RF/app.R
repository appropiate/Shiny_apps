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
library(DT)

# Set working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Read in the RF model_diabetes
model_diabetes <- readRDS("model_diabetes.rds")

####################################
# User interface                   #
####################################

# Define UI for application that draws a histogram
ui <- fluidPage(title = "Hola",
        tags$style(
          "#status {font-size:15px;
          color:black;
          display:block; }"),
        theme = shinytheme("sandstone"),
        navbarPage(
           #theme = 'sandstone',
           "Predictors:",
           tabPanel("Diabetes",
                    sidebarPanel(
                     tags$h3("Predictor inputs:"),
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
                    ), # sidebarPanel
                                   
                   mainPanel(
                             
                             tabsetPanel(type = "tabs",
                                         
                              # Tabsets  in mainPanel----     
                               tabPanel("Prediction",
                                         HTML('<h3> <b> Status/Output of the prediction </b> </h3>'
                                         ), # Status/Output Text Box
                                         verbatimTextOutput('contents'),
                                         textOutput("status"),
                                         tableOutput('tabledata'), # Prediction results table
                                         textOutput("explanation", container = span),
                                         HTML("<br>"),
                                         imageOutput("emoji")   # emoji dependent on prediction)
                                        ), # Tabpanel
                               
                               tabPanel("Dataset",
                                        HTML("<br>"),
                                        DT::dataTableOutput("diabetes_table"),
                                        HTML("<br>"),
                                        tags$iframe(src = "diabetes_summary.html",
                                                    width="120%", height="400",
                                                    scrolling="no",
                                                    seamless="seamless",
                                                    frameBorder="0")
                                       ), # Tabpanel
                                         
                               tabPanel("Prediction algorithm",
                                        tags$iframe(src = "diabetes_modelPerformance.html",
                                                    width="50%", height="700",
                                                    scrolling="no",
                                                    seamless="seamless",
                                                    frameBorder="0")    
                                        )
                             
                        
                                      ) # tabsetPanel                                                
                             )# mainPanel
                                     
               ),#tabPanel
           
               navbarMenu("About",
                          tabPanel("Contact us"),
                          tabPanel("Algorithm" )) #NavbarMenu
              ) # NavbarPage  
        
            ) # fluidPage
                 

####################################
# Server                           #
####################################

# Define server logic required to obtain predictions and probabilities of having diabetes
server <- function(input, output,session) {
  
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
    
    Output <- as.data.frame(cbind(as.character(predict(model_diabetes,test)),
                            paste(100*round(predict(model_diabetes,test,type="prob")[1],3),"%"),
                            paste(100*round(predict(model_diabetes,test,type="prob")[2],3),"%")))
    
    colnames(Output) <- c("Diabetes prediction","No","Yes")
    print(Output)
    

    
  })
  ## TabPanel "Prediction"
      # Status/Output Text Box
      output$contents <- renderPrint({
                            if (input$submitbutton > 0) { 
                               output$status <- renderText("Diabetes prediction complete.") 
                               output$explanation <- renderText("this text should show below the prediction")   # Explanation text
                                
                           } else {
                            output$status <- renderText("Specify inputs and click on 'Submit'.")
                            
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
                             list(src = filename, 
                                        width = "100px" ,
                                        height= "100px")}
                           else{
                             filename <- file.path('./www/happy_emoji.png')
                             list(src = filename, 
                                        width = "50px",
                                        height= "50px")
                            }},
                                     deleteFile = FALSE)
         
         ## TabPanel "DATASET"
         diabetes.table <- read.csv("diabetes.txt", stringsAsFactors = T)
         output$diabetes_table = DT::renderDataTable({
           diabetes.table
         })
         
    

}  # server  


# Run the application 
shinyApp(ui = ui, server = server)
