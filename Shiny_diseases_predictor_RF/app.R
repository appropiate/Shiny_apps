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
library(huxtable)
library(data.table)
library(DT)
library(C50)

# Set working directory
setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# Read in the RF model_diabetes
model_diabetes <- readRDS("model_diabetes.rds")

####################################
# User interface                   #
####################################

# Define UI for application that draws a histogram
ui <- fluidPage(title = "Hola",
        tags$style( # output styles
          "#status {font-size:18px;
          color:black;
          font-weight: bold;
          display:block; }"),
        theme = shinytheme("sandstone"),
        navbarPage(
           #theme = 'sandstone',
           "PREDICTORS:",
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
                                         HTML('<h3> <b> Status/Output of the prediction for diabetes</b> </h3>'
                                         ), # Status/Output Text Box
                                        # verbatimTextOutput('contents'),
                                         textOutput("status"),
                                         HTML("<br>"),
                                         tableOutput('tabledata'), # Prediction results table
                                        # textOutput("explanation", container = span),
                                         HTML("<br>"),
                                         HTML("<br>"),
                                         imageOutput("emoji")   # emoji dependent on prediction)
                                        ), # Tabpanel
                               
                               tabPanel("Dataset",
                                        HTML("<br>"),
                                        HTML("<br>"),
                                        HTML('<h3> <b> Browse through the data </b> </h3>'),
                                        HTML("<br>"),
                                        DT::dataTableOutput("diabetes_table"),
                                        HTML("<br>"),
                                        HTML("<br>"),
                                        tags$iframe(src = "diabetes_summary.html",
                                                    width="100%", height="500",
                                                    scrolling="no",
                                                    seamless="seamless",
                                                    frameBorder="0")
                                       ), # Tabpanel
                                         
                               tabPanel("Prediction algorithm",
                                        tags$iframe(src = "diabetes_modelPerformance.html",
                                                    width="100%", height="800",
                                                    scrolling="no",
                                                    seamless="seamless",
                                                    frameBorder="0")    
                                        )
                             
                        
                                      ) # tabsetPanel                                                
                             )# mainPanel
                                     
               ),#tabPanel
           
               navbarMenu("About",
                          tabPanel("Contact us"),
                          tabPanel("Disclaimer" )) #NavbarMenu
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
    
    test <- read.csv(paste("input", ".csv", sep=""), header = TRUE)
    
    Output <- as.data.frame(cbind(as.character(predict(model_diabetes,test)), # prediction
                            paste(100*round(predict(model_diabetes,test,type="prob")[1],3),"%"), # "No" probability
                            paste(100*round(predict(model_diabetes,test,type="prob")[2],3),"%"))) # "Yes" probability
    
    colnames(Output) <- c("Diabetes prediction","'No' probability","'Yes' probability")
    print(Output)
    

    
  })
  ## TabPanel "Prediction"
  positive.prob <- predict(model_diabetes,test,type="prob")[2]
  
  
   
  
  # Status/Output Text Box
  output$status <- if (input$submitbutton > 0 ) { 
    renderText("Diabetes prediction complete!") 
  } else {
    renderText( "Specify inputs for each predictor and click on 'Submit'!")
  }
  
  
  
      # output$contents <- renderPrint({
      #                       if (input$submitbutton > 0 &
      #                           positive.prob > 0.6) { 
      #                            output$status <- renderText("Diabetes prediction complete!") 
      #                            output$explanation <- renderText("You possibly have diabetes, inform and confirm with your doctor!")   # Explanation text
      #                           
      #                       } else if(input$submitbutton > 0 & 
      #                                 positive.prob < 0.6 &
      #                                 positive.prob > 0.4){
      #                                   output$status <- renderText("Diabetes prediction complete!") 
      #                                   output$explanation <- renderText("Not so sure if you have diabetes, consult your doctor!")
      #                       } else if(input$submitbutton > 0 & 
      #                                 positive.prob < 0.4){
      #                                   output$status <- renderText("Diabetes prediction complete!") 
      #                                   output$explanation <- renderText("You possibly do not have diabetes, confirm with your doctor!")
      #                              }
      #                        else {
      #                         output$status <- renderText("Specify inputs for each predictor and click on 'Submit'!")
      #                       
      #                              }
      #                      })

      # Prediction results table
        output$tabledata <- renderTable({
                               if (input$submitbutton > 0) { 
                                  isolate(datasetInput()) 
                                 } 
                            })
      
      # Emoji images
         output$emoji <- renderImage({
                           if (input$submitbutton > 0 
                              ){
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
